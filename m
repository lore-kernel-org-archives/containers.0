From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Interaction user namespace, /proc/1 ownership & cap_set
Date: Mon, 1 Jul 2013 17:16:25 +0100
Message-ID: <20130701161625.GQ15954@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="l76fUT7nc3MelDdI"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

I'm struggling debugging a strange problem with interaction between user
namespaces, cap_set and ownership of files in /proc/1/

I'm using a modified version (attached to this mail) of the demo program
userns_child_exec.c linked on https://lwn.net/Articles/532593/

  $ gcc -lcap -Wall -o userns_child_exec userns_child_exec.c 

First normal execution appears to work just fine (as root):

  $ ./userns_child_exec -p -m -U -M '0 1000 1' -G '0 1000 1' bash
  Launching child init
  # umount /proc/sys/fs/binfmt_misc
  # umount /proc/sys/fs/binfmt_misc
  # umount /proc/fs/nfsd
  # umount /proc
  # mount -t proc proc /proc/
  # ls -al /proc/1/environ 
  -r--------. 1 root root 0 Jul  1 17:04 /proc/1/environ


My modification adds support for a '-c' arg to call the program to use
cap_set() from libcap.so in order to remove the CAP_SYS_MODULE capability.

If I run the program with the '-c' arg present, then the files in
the /proc/1/ directory all end up owned by nfsnobody.nfsbody

  $ ./userns_child_exec -c -p -m -U -M '0 1000 1' -G '0 1000 1' bash
  Launching child init
  # umount /proc/sys/fs/binfmt_misc
  # umount /proc/sys/fs/binfmt_misc
  # umount /proc/fs/nfsd
  # umount /proc
  # mount -t proc proc /proc/
  # ls -al /proc/1/environ 
  -r--------. 1 nfsnobody nfsnobody 0 Jul  1 17:01 /proc/1/environ

Why on earth would calling 'cap_set()' to drop a capability cause
the user/group ownership of files in /proc/1/ to change ?

Any child processes launched from this point get correct ownership
on their /proc/NNN files - only /proc/1/ seems to be affected.

Via strace, we can see the libcap code only calls 3 syscalls:

capget({_LINUX_CAPABILITY_VERSION_3, 0}, NULL) = 0
capget({_LINUX_CAPABILITY_VERSION_3, 0}, {CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SET
UID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_MO
DULE|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_NICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_S
YS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER
|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RA
W|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_MODULE|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_N
ICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, 0}) = 0
capset({_LINUX_CAPABILITY_VERSION_3, 0}, {CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_NICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_NIC
 E|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, 0}) = 0

though, for added fun, when running the demo program via strace
the problem does not appear :-(



On a slightly related topic, I've noticed that it is not possible to
invoke prctl(PR_CAPBSET_DROP) to clear the bounding set for processes
inside a container. The kernel code uses capable() instead of ns_capable().
Is this intended, or a missing conversion ?

Indeed, even ignoring namespaces for a minute, I'm curious as to why
CAP_SETPCAP is required at all for PR_CAPBSET_DROP ?  Is it really
a security risk to allow a non-privileged user to remove bits from
the bounding set ? For KVM I'd like to be able to use PR_CAPBSET_DROP
to prevent a compromised KVM process from using any setuid program to
re-gain any kind of capabilities.  Similarly I think a container admin
may well wish to make use of PR_CAPBSET_DROP to lock down applications
there.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|

--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="userns_child_exec.c"

/* userns_child_exec.c

   Copyright 2013, Michael Kerrisk
   Licensed under GNU General Public License v2 or later

   Create a child process that executes a shell command in new
   namespace(s); allow UID and GID mappings to be specified when
   creating a user namespace.
*/
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <signal.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <errno.h>
#include <sys/capability.h>

/* A simple error-handling function: print an error message based
   on the value in 'errno' and terminate the calling process */

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)

struct child_args {
    char **argv;        /* Command to be executed by child, with arguments */
    int    pipe_fd[2];  /* Pipe used to synchronize parent and child */
};

static int verbose;
static int dropcaps;

static void
usage(char *pname)
{
    fprintf(stderr, "Usage: %s [options] cmd [arg...]\n\n", pname);
    fprintf(stderr, "Create a child process that executes a shell command "
            "in a new user namespace,\n"
            "and possibly also other new namespace(s).\n\n");
    fprintf(stderr, "Options can be:\n\n");
#define fpe(str) fprintf(stderr, "    %s", str);
    fpe("-c          Drop caps\n");
    fpe("-i          New IPC namespace\n");
    fpe("-m          New mount namespace\n");
    fpe("-n          New network namespace\n");
    fpe("-p          New PID namespace\n");
    fpe("-u          New UTS namespace\n");
    fpe("-U          New user namespace\n");
    fpe("-M uid_map  Specify UID map for user namespace\n");
    fpe("-G gid_map  Specify GID map for user namespace\n");
    fpe("            If -M or -G is specified, -U is required\n");
    fpe("-v          Display verbose messages\n");
    fpe("\n");
    fpe("Map strings for -M and -G consist of records of the form:\n");
    fpe("\n");
    fpe("    ID-inside-ns   ID-outside-ns   len\n");
    fpe("\n");
    fpe("A map string can contain multiple records, separated by commas;\n");
    fpe("the commas are replaced by newlines before writing to map files.\n");

    exit(EXIT_FAILURE);
}

/* Update the mapping file 'map_file', with the value provided in
   'mapping', a string that defines a UID or GID mapping. A UID or
   GID mapping consists of one or more newline-delimited records
   of the form:

       ID_inside-ns    ID-outside-ns   length

   Requiring the user to supply a string that contains newlines is
   of course inconvenient for command-line use. Thus, we permit the
   use of commas to delimit records in this string, and replace them
   with newlines before writing the string to the file. */

static void
update_map(char *mapping, char *map_file)
{
    int fd, j;
    size_t map_len;     /* Length of 'mapping' */

    /* Replace commas in mapping string with newlines */

    map_len = strlen(mapping);
    for (j = 0; j < map_len; j++)
        if (mapping[j] == ',')
            mapping[j] = '\n';

    fd = open(map_file, O_RDWR);
    if (fd == -1) {
        fprintf(stderr, "open %s: %s\n", map_file, strerror(errno));
        exit(EXIT_FAILURE);
    }

    if (write(fd, mapping, map_len) != map_len) {
        fprintf(stderr, "write %s: %s\n", map_file, strerror(errno));
        exit(EXIT_FAILURE);
    }

    close(fd);
}

static int              /* Start function for cloned child */
childFunc(void *arg)
{
    struct child_args *args = (struct child_args *) arg;
    char ch;
 
    /* Wait until the parent has updated the UID and GID mappings. See
       the comment in main(). We wait for end of file on a pipe that will
       be closed by the parent process once it has updated the mappings. */

    close(args->pipe_fd[1]);    /* Close our descriptor for the write end
                                   of the pipe so that we see EOF when
                                   parent closes its descriptor */
    if (read(args->pipe_fd[0], &ch, 1) != 0) {
        fprintf(stderr, "Failure in child: read from pipe returned != 0\n");
        exit(EXIT_FAILURE);
    }

    /* Execute a shell command */
    if (setreuid(0, 0) < 0)
      errExit("setreuid");
    if (setregid(0, 0) < 0)
      errExit("setregid");

    if (dropcaps) {
      cap_t caps;
      cap_value_t val[] = { CAP_SYS_MODULE };
      caps = cap_get_proc();

      cap_set_flag(caps,
		   CAP_EFFECTIVE,
		   1, val, CAP_CLEAR);
      cap_set_flag(caps,
		   CAP_PERMITTED,
		   1, val, CAP_CLEAR);
      cap_set_flag(caps,
		   CAP_INHERITABLE,
		   1, val, CAP_CLEAR);

      cap_set_proc(caps);
    }

    fprintf(stderr, "Launching child init\n");
    execvp(args->argv[0], args->argv);
    errExit("execvp");
}

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];    /* Space for child's stack */

int
main(int argc, char *argv[])
{
    int flags, opt;
    pid_t child_pid;
    struct child_args args;
    char *uid_map, *gid_map;
    char map_path[PATH_MAX];

    /* Parse command-line options. The initial '+' character in
       the final getopt() argument prevents GNU-style permutation
       of command-line options. That's useful, since sometimes
       the 'command' to be executed by this program itself
       has command-line options. We don't want getopt() to treat
       those as options to this program. */

    flags = 0;
    verbose = 0;
    gid_map = NULL;
    uid_map = NULL;
    while ((opt = getopt(argc, argv, "+imnpucUM:G:v")) != -1) {
        switch (opt) {
        case 'i': flags |= CLONE_NEWIPC;        break;
        case 'm': flags |= CLONE_NEWNS;         break;
        case 'n': flags |= CLONE_NEWNET;        break;
        case 'p': flags |= CLONE_NEWPID;        break;
        case 'u': flags |= CLONE_NEWUTS;        break;
	case 'c': dropcaps = 1;                 break;
        case 'v': verbose = 1;                  break;
        case 'M': uid_map = optarg;             break;
        case 'G': gid_map = optarg;             break;
        case 'U': flags |= CLONE_NEWUSER;       break;
        default:  usage(argv[0]);
        }
    }

    /* -M or -G without -U is nonsensical */

    if ((uid_map != NULL || gid_map != NULL) &&
            !(flags & CLONE_NEWUSER))
        usage(argv[0]);

    args.argv = &argv[optind];

    /* We use a pipe to synchronize the parent and child, in order to
       ensure that the parent sets the UID and GID maps before the child
       calls execve(). This ensures that the child maintains its
       capabilities during the execve() in the common case where we
       want to map the child's effective user ID to 0 in the new user
       namespace. Without this synchronization, the child would lose
       its capabilities if it performed an execve() with nonzero
       user IDs (see the capabilities(7) man page for details of the
       transformation of a process's capabilities during execve()). */

    if (pipe(args.pipe_fd) == -1)
        errExit("pipe");

    /* Create the child in new namespace(s) */

    child_pid = clone(childFunc, child_stack + STACK_SIZE,
                      flags | SIGCHLD, &args);
    if (child_pid == -1)
        errExit("clone");

    /* Parent falls through to here */

    if (verbose)
        printf("%s: PID of child created by clone() is %ld\n",
                argv[0], (long) child_pid);

    /* Update the UID and GID maps in the child */

    if (uid_map != NULL) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/uid_map",
                (long) child_pid);
        update_map(uid_map, map_path);
    }
    if (gid_map != NULL) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/gid_map",
                (long) child_pid);
        update_map(gid_map, map_path);
    }

    /* Close the write end of the pipe, to signal to the child that we
       have updated the UID and GID maps */

    close(args.pipe_fd[1]);

    if (waitpid(child_pid, NULL, 0) == -1)      /* Wait for child */
        errExit("waitpid");

    if (verbose)
        printf("%s: terminating\n", argv[0]);

    exit(EXIT_SUCCESS);
}


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--l76fUT7nc3MelDdI--
