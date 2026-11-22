#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

static int fail(const char *message)
{
    perror(message);
    return 125;
}

int main(int argc, char **argv)
{
    struct sockaddr_un address = {.sun_family = AF_UNIX, .sun_path = "/run/sinai/lord"};
    char request[128 * 1024];
    union {
        struct cmsghdr align;
        char buffer[CMSG_SPACE(3 * sizeof(int))];
    } rights = {0};
    struct iovec data = {.iov_base = request};
    struct msghdr message = {
        .msg_iov = &data,
        .msg_iovlen = 1,
        .msg_control = rights.buffer,
        .msg_controllen = sizeof(rights.buffer),
    };
    struct cmsghdr *header = CMSG_FIRSTHDR(&message);
    const int streams[] = {STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO};
    unsigned char status;
    int fd;

    if (argc == 2 && (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h"))) {
        puts("usage: lord [prompt ...]\n"
             "Send a request to the host lord from your current Sinai directory.\n"
             "Pipes and redirections work as usual.");
        return 0;
    }
    if (!getcwd(request, sizeof(request)))
        return fail("lord: getcwd");

    /* Send cwd and argv as NUL-terminated strings with the three Unix streams. */
    data.iov_len = strlen(request) + 1;
    for (int i = 1; i < argc; i++) {
        size_t length = strlen(argv[i]) + 1;
        if (length > sizeof(request) - data.iov_len) {
            fputs("lord: prompt arguments too long (use stdin)\n", stderr);
            return 2;
        }
        memcpy(request + data.iov_len, argv[i], length);
        data.iov_len += length;
    }
    header->cmsg_level = SOL_SOCKET;
    header->cmsg_type = SCM_RIGHTS;
    header->cmsg_len = CMSG_LEN(sizeof(streams));
    memcpy(CMSG_DATA(header), streams, sizeof(streams));

    fd = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
    if (fd < 0)
        return fail("lord: socket");
    if (connect(fd, (struct sockaddr *)&address, sizeof(address)) < 0)
        return fail("lord: host connection (enter with make chroot)");
    if (sendmsg(fd, &message, MSG_NOSIGNAL) < 0)
        return fail("lord: send");

    ssize_t received;
    do {
        received = read(fd, &status, 1);
    } while (received < 0 && errno == EINTR);
    if (received == 1)
        return status;
    fputs("lord: host connection closed before an exit status arrived\n", stderr);
    return 125;
}
