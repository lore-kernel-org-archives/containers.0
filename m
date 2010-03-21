From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Testing lxc 0.6.5 in Fedora 13
Date: Sun, 21 Mar 2010 20:50:44 +0100
Message-ID: <20100321195044.GA23757@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

I'd like to report a few problems/gotchas I ran into while testing LXC
in Fedora 13 (current Rawhide).

1. PTY allocation fails (PEBKAC/documentation issue)

While starting up a guest (CentOS 5.4) I get a series of messages:

lxc-start 1268746923.067 WARN     lxc_conf - failed to mount '/dev/pts/2'->'./rootfs.centos/dev/tty1'
lxc-start 1268746923.067 WARN     lxc_conf - failed to mount '/dev/pts/3'->'./rootfs.centos/dev/tty2'
lxc-start 1268746923.067 WARN     lxc_conf - failed to mount '/dev/pts/4'->'./rootfs.centos/dev/tty3'
lxc-start 1268746923.067 WARN     lxc_conf - failed to mount '/dev/pts/5'->'./rootfs.centos/dev/tty4'
lxc-start 1268746923.067 INFO     lxc_conf - 4 tty(s) has been setup

The mingetty set up to start at /dev/tty1 is not attached to any known
TTY and is not accessible via lxc-console:

CONTAINER    PID TTY          TIME CMD
centos      1186 ?        00:00:00 init
centos      1368 ?        00:00:00 syslogd
centos      1371 ?        00:00:00 klogd
centos      1386 ?        00:00:00 sshd
centos      1396 ?        00:00:00 mingetty

The mount fails because there are no ttyX files inside the container's
file system. This may qualify as a PEBKAC but it might be nice to
document somewhere (touching empty plain files with appropriate names
makes the container boot).

2. Weird strace behaviour across pidns boundary

When strace'ing (with -ff) lxc-start, I get a proper strace for the
directly spawned process and the container init. However, any processes
spawned by the container's init are not straced properly (I get two
empty files, named <foo>.<pid-in-root-ns> and <foo>.2 -- presumably pid
inside the container). The container also seems to malfunction under
strace (looks like exec() failing as lxc-ps shows two "init" processes).

This is quite painful as it prevents strace'ing processes in containers
even after startup. Here's a snippet of strace'ing a bash (pid 179
inside, pid 2959 outside) trying to run 'ls'. The shell hangs until I
kill the strace process.

pipe([3, 4])                            = 0
clone(Process 197 attached
child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7859708) = 197
Process 2999 attached (waiting for parent)
[pid  2959] setpgid(197, 197)           = 0
[pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
[pid  2959] close(3)                    = 0
[pid  2959] close(4)                    = 0
[pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD TSTP TTIN TTOU], [CHLD], 8) = 0
[pid  2959] ioctl(255, TIOCSPGRP, [197]) = 0
[pid  2959] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
[pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
[pid  2959] waitpid(-1, Process 2959 suspended
^C <unfinished ...>
Process 2959 detached
Process 197 detached
Process 2999 detached

'strace ls' ran completely inside the container works as expected.

3. Missing /dev/console

There's no "obviously good" default (apart maybe from lxc-start's
stdout/err) but I guess the messages from init could end up somewhere
useful (right now it tries /dev/console, /dev/tty0 and /dev/null, in
order). Maybe an extra PTY (just start counting from 0) would be enough?
Or even a symlink (tty0 -> tty1). But then I think that lxc-start should
attach to the PTY as early as possible to capture boot messages.


Best regards,
 Grzegorz Nosek
