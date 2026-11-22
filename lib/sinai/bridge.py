import array
import contextlib
import os
from pathlib import Path
import select
import shutil
import signal
import socket
import socketserver
import subprocess
import sys
import tempfile
import threading


class LordServer(socketserver.ThreadingUnixStreamServer):
    socket_type = socket.SOCK_SEQPACKET


class LordRequest(socketserver.BaseRequestHandler):
    def handle(self):
        conn = self.request
        conn.settimeout(5)
        streams = array.array("i")
        try:
            data, ancillary, flags, _ = conn.recvmsg(
                128 * 1024, socket.CMSG_SPACE(3 * streams.itemsize), socket.MSG_CMSG_CLOEXEC
            )
        except (TimeoutError, ConnectionError):
            return
        for level, kind, payload in ancillary:
            if (level, kind) == (socket.SOL_SOCKET, socket.SCM_RIGHTS):
                streams.frombytes(payload)
        with contextlib.ExitStack() as cleanup:
            for fd in streams:
                cleanup.callback(os.close, fd)
            if (len(streams) != 3 or not data.endswith(b"\0") or
                    flags & (socket.MSG_TRUNC | socket.MSG_CTRUNC)):
                return

            guest_dir, *args = map(os.fsdecode, data[:-1].split(b"\0"))
            try:
                cwd = (self.server.root / guest_dir.lstrip("/")).resolve(strict=True)
                cwd.relative_to(self.server.root)
                status = self.run_lord(conn, cwd, args, streams)
            except (OSError, ValueError) as error:
                with contextlib.suppress(OSError):
                    os.write(streams[2], os.fsencode(f"lord: {error}\n"))
                status = 125
            if status is not None:
                with contextlib.suppress(ConnectionError):
                    conn.sendall(bytes([status if status >= 0 else 128 - status]))

    def run_lord(self, conn, cwd, args, streams):
        with subprocess.Popen(
            [self.server.lord, *args], cwd=cwd, env=self.server.env,
            stdin=streams[0], stdout=streams[1], stderr=streams[2],
            start_new_session=True,
        ) as process:
            while process.poll() is None:
                if select.select([conn], [], [], 0.1)[0]:
                    # The caller exited or was interrupted inside Sinai.
                    with contextlib.suppress(ProcessLookupError):
                        os.killpg(process.pid, signal.SIGTERM)
                    try:
                        process.wait(timeout=1)
                    except subprocess.TimeoutExpired:
                        with contextlib.suppress(ProcessLookupError):
                            os.killpg(process.pid, signal.SIGKILL)
                    return None
            return process.returncode


def main(root, command):
    root = Path(root).resolve()
    env = os.environ.copy()
    env["SINAI_ROOT"] = str(root)
    at = Path.home() / "src" / "@"
    runner = env.get("SINAI_LORD")
    if not runner and os.access(at / "bin/lord", os.X_OK):
        runner = str(at / "bin/lord")
        env.setdefault("NSH_PROGRAM", str(at / "@"))
    runner = shutil.which(runner or "lord")
    if not runner:
        raise SystemExit("sinai: put the host lord on PATH or set SINAI_LORD")

    if not command:
        command = ["/bin/sh", "-i"] if os.isatty(0) else ["/bin/sh"]
    if os.isatty(0):
        # The terminal also signals the launcher. Leave Ctrl+C to the guest.
        signal.signal(signal.SIGINT, lambda *_: None)
    with tempfile.TemporaryDirectory(prefix="sinai-", dir="/tmp") as directory:
        with LordServer(str(Path(directory) / "lord"), LordRequest) as server:
            server.root = root
            server.lord = os.path.abspath(runner)
            server.env = env
            thread = threading.Thread(target=server.serve_forever, kwargs={"poll_interval": 0.1})
            thread.start()
            try:
                return subprocess.call([
                    "bwrap", "--unshare-user", "--uid", "0", "--gid", "0",
                    "--unshare-pid", "--unshare-ipc", "--unshare-uts", "--hostname", "sinai",
                    "--die-with-parent", "--bind", str(root), "/", "--dev", "/dev",
                    "--proc", "/proc", "--ro-bind", directory, "/run/sinai",
                    "--clearenv", "--setenv", "PATH", "/bin:/usr/bin",
                    "--setenv", "HOME", "/root", "--setenv", "PS1", "sinai# ",
                    "--setenv", "TERM", os.getenv("TERM", "dumb"), "--chdir", "/",
                    "--", *command,
                ])
            finally:
                server.shutdown()
                thread.join()


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1], sys.argv[2:]))
    except KeyboardInterrupt:
        sys.exit(130)
