"""The native Python namespace for the Nahas REPL."""

import code
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import traceback

EFFORTS = ("none", "low", "medium", "high", "xhigh", "max")


def check(path):
    try:
        compile(path.read_bytes(), str(path), "exec")
    except (OSError, SyntaxError, ValueError) as exc:
        print(f"{path}: {exc}", file=sys.stderr)
        return 65
    return 0


class Nahas(code.InteractiveConsole):
    def __init__(self, launcher, config):
        super().__init__({"__name__": "__main__"})
        self.launcher = launcher
        self.config = config
        self.flags = [
            ("mode", "NW_MODE", "r", "c a r l"),
            ("nitpick", "NW_NITPICK", "1", "0 1 2"),
            ("effort", "LORD_EFFORT", "2", "0 1 2 3 4 5"),
            ("permission", "LORD_PERMISSION", "text", "text read write"),
        ]
        self.settings = {name: os.environ.get(env, default) for name, env, default, _ in self.flags}
        self.source = ""
        self.correction = ""
        self.pending = False
        self.context = ""
        self.error = ""
        self.syntax_error = False

    def showsyntaxerror(self, filename=None, **kwargs):
        self.syntax_error = True
        self.error = traceback.format_exc()
        super().showsyntaxerror(filename, **kwargs)

    def showtraceback(self):
        self.error = traceback.format_exc()
        super().showtraceback()

    def runsource(self, source, filename="<nhs>", symbol="single"):
        self.error = ""
        self.syntax_error = False
        return super().runsource(source, filename, symbol)

    def ask_agent(self):
        options = []
        for name, value in self.settings.items():
            options.extend((f"--{name}", value))
        finished = subprocess.run(
            [self.launcher, *options, "--turn", self.source],
            input=self.context.encode(),
            stdout=subprocess.PIPE,
        )
        if finished.returncode:
            return
        marker, newline, rest = finished.stdout.partition(b"\n")
        if marker == b"@ask" and newline:
            question = rest.decode(errors="replace")
            self.pending = True
            self.context += f"\nAgent question:\n{question}"
            sys.stderr.write(question)
        elif marker == b"@fail" and newline:
            sys.stderr.buffer.write(rest)
        elif marker == b"@code" and self.settings["mode"] in ("c", "a"):
            try:
                source = rest.decode()
                if not source.strip():
                    raise ValueError("Empty correction.")
                compile(source, "<correction>", "exec")
            except (SyntaxError, ValueError) as exc:
                print(exc, file=sys.stderr)
            else:
                self.correction = source
                sys.stdout.write(self.correction)
                print("Use :run to execute this correction or :link NAME to save it.", file=sys.stderr)
        elif self.settings["mode"] in ("c", "a"):
            print("The backend did not follow the turn protocol.", file=sys.stderr)
        else:
            sys.stdout.buffer.write(finished.stdout)
            sys.stdout.flush()

    def answer(self, line):
        self.pending = False
        self.context += f"\nUser answer:\n{line}\n"
        self.ask_agent()

    def control(self, line):
        command, _, value = line.partition(" ")
        if command in (":exit", ":quit"):
            raise SystemExit
        if command == ":cancel":
            self.pending = False
            self.correction = ""
            return
        if line in ("up", "dn"):
            change = 1 if line == "up" else -1
            effort = int(self.settings["effort"]) + change
            self.settings["effort"] = str(min(5, max(0, effort)))
            return
        if line in ("c", "a", "r", "l"):
            command, value = ":mode", line
        if command == ":effort" and value in EFFORTS:
            value = str(EFFORTS.index(value))
        for name, _, _, choices in self.flags:
            if command == f":{name}" and value in choices.split():
                self.settings[name] = value
                if name in ("mode", "nitpick"):
                    self.pending = False
                return
        if command == ":answer" and self.pending:
            self.answer(value)
            return
        if command == ":run" and self.correction:
            source, self.correction = self.correction, ""
            self.runcode(compile(source, "<correction>", "exec"))
            self.source = source
            return
        if command == ":link" and (self.correction or self.source):
            with tempfile.TemporaryDirectory() as directory:
                path = Path(directory, "source")
                path.write_text(self.correction or self.source)
                subprocess.run([self.launcher, "--nitpick", self.settings["nitpick"], "--link", value, str(path)])
            return
        print("Unknown or unavailable REPL command. Use --help for commands.", file=sys.stderr)

    def interact(self):
        startup = self.config / "etc" / "nhsrc.py"
        if startup.is_file():
            self.runcode(compile(startup.read_bytes(), str(startup), "exec"))
        try:
            import readline
        except ImportError:
            readline = None
        history = self.config / "history"
        if readline:
            readline.set_auto_history(False)
            try:
                readline.read_history_file(history)
            except FileNotFoundError:
                pass
        buffer = []
        while True:
            mode, nitpick, effort, permission = self.settings.values()
            if mode in ("c", "a"):
                permission = "text"
            marker = "..." if buffer else ">>?" if self.pending else ">>>"
            try:
                line = input(f"{Path(self.launcher).name}[{mode}:{nitpick}:{effort}:{permission}] {marker} ")
                if readline and line and not line.startswith(" "):
                    self.config.mkdir(mode=0o700, parents=True, exist_ok=True)
                    descriptor = os.open(history, os.O_WRONLY | os.O_APPEND | os.O_CREAT, 0o600)
                    with os.fdopen(descriptor, "a") as stream:
                        stream.write(line + "\n")
                    readline.add_history(line)
                if not buffer and line == ":paste":
                    while part := input("... "):
                        buffer.append(part)
                    source = "\n".join(buffer)
                    buffer.clear()
                    more = self.runsource(source, symbol="exec")
                elif not buffer and (line.startswith(":") or line in ("up", "dn", "c", "a", "r", "l")):
                    self.control(line)
                    continue
                elif self.pending:
                    self.answer(line)
                    continue
                else:
                    buffer.append(line)
                    source = "\n".join(buffer)
                    more = self.runsource(source)
                if more:
                    continue
                buffer.clear()
                self.source = source
                self.correction = ""
                if self.error and mode != "l" and nitpick != "2" and (self.syntax_error or nitpick == "0"):
                    self.context = f"Directory: {Path.cwd()}\nPython diagnostic:\n{self.error[-4096:]}"
                    self.ask_agent()
            except EOFError:
                print()
                return
            except KeyboardInterrupt:
                print()
                buffer.clear()
                self.pending = False
                self.correction = ""


if __name__ == "__main__":
    if sys.argv[1] == "--check":
        raise SystemExit(check(Path(sys.argv[2])))
    default = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "nhs"
    Nahas(sys.argv[1], Path(os.environ.get("NHS_HOME", default))).interact()
