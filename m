From: Miguel F Mascarenhas Sousa Filipe <miguel.filipe-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: lxc-start fails on clone(child_stack=0,
	flags=CLONE_NEWNS|0x6c000000|SIGCHLD) = -1 EINVAL (Invalid argument)
Date: Fri, 5 Jun 2009 14:30:44 +0100
Message-ID: <f058a9c30906050630p2bb36451odef8863081c2bef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

I'm trying to play with lxc, but I'm unable to start a container
created with lxc-debian in two diferent linux systems I have.

linux-2.6.29-gentoo-r5 x86_64.
linux-2.6.28-11-generic ubuntu x86_64.

Lxc version 0.6.2, git checkout of yesterday.

lxc-debian sucessfully creates a new container:

root@feynman:/mnt# lxc-info -n x86deb
'x86deb' is STOPPED
root@feynman:/mnt# lxc-start -n x86deb
lxc-start: Invalid argument - failed to fork into a new namespace
lxc-start: failed to spawn '/sbin/init'

I only have the ubuntu machine acessible now, but my problem on the
gentoo was the same I believe.

In this ubuntu machine, lxc-showconfig gives me this:

root@feynman:/mnt# lxc-checkconfig
Kernel config /proc/config.gz not found, looking in other places...
Found kernel config file /boot/config-2.6.28-11-generic
--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: enabled
User namespace: disabled
Network namespace: disabled
Multiple /dev/pts instances: disabled

--- Control groups ---
Cgroup: enabled
Cgroup namespace: enabled
Cgroup device: disabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: enabled
Cgroup cpuset: enabled

--- Misc ---
Veth pair device: enabled
Macvlan: enabled





------------ strace of lxc-start follows ---------------
...
stat("/dev/pts/6", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 6), ...}) = 0
statfs("/dev/pts/6", {f_type="DEVPTS_SUPER_MAGIC", f_bsize=4096,
f_blocks=0, f_bfree=0, f_bavail=0, f_files=0, f_ffree=0, f_fsid={0,
0}, f_namelen=255, f_frsize=4096}) = 0
ioctl(8, TIOCSPTLCK, [0])               = 0
ioctl(8, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}) = 0
ioctl(8, TIOCGPTN, [6])                 = 0
stat("/dev/pts/6", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 6), ...}) = 0
open("/dev/pts/6", O_RDWR|O_NOCTTY)     = 9
fcntl(8, F_SETFD, FD_CLOEXEC)           = 0
fcntl(9, F_SETFD, FD_CLOEXEC)           = 0
open("/dev/ptmx", O_RDWR)               = 10
ioctl(10, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon
echo ...}) = 0
ioctl(10, TIOCGPTN, [8])                = 0
stat("/dev/pts/8", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 8), ...}) = 0
statfs("/dev/pts/8", {f_type="DEVPTS_SUPER_MAGIC", f_bsize=4096,
f_blocks=0, f_bfree=0, f_bavail=0, f_files=0, f_ffree=0, f_fsid={0,
0}, f_namelen=255, f_frsize=4096}) = 0
ioctl(10, TIOCSPTLCK, [0])              = 0
ioctl(10, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon
echo ...}) = 0
ioctl(10, TIOCGPTN, [8])                = 0
stat("/dev/pts/8", {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 8), ...}) = 0
open("/dev/pts/8", O_RDWR|O_NOCTTY)     = 11
fcntl(10, F_SETFD, FD_CLOEXEC)          = 0
fcntl(11, F_SETFD, FD_CLOEXEC)          = 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  = 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
syscall_289(0xffffffffffffffff, 0x7fffbfa191a0, 0x8, 0,
0xfefefefefefefeff, 0xffffffffff000000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) = 0xc
fcntl(12, F_SETFD, FD_CLOEXEC)          = 0
rt_sigaction(SIGINT, {0x7fa1b73e2c20, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7fa1b709d040}, {SIG_DFL}, 8) = 0
rt_sigaction(SIGQUIT, {0x7fa1b73e2c40, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7fa1b709d040}, {SIG_DFL}, 8) = 0
socketpair(PF_FILE, SOCK_STREAM, 0, [13, 14]) = 0
stat("/usr/local/var/lib/lxc/x86deb/utsname", {st_mode=S_IFREG|0755,
st_size=8, ...}) = 0
stat("/usr/local/var/lib/lxc/x86deb/network", {st_mode=S_IFDIR|0755,
st_size=4096, ...}) = 0
clone(child_stack=0, flags=CLONE_NEWNS|0x6c000000|SIGCHLD) = -1 EINVAL
(Invalid argument)
write(2, "lxc-start: "..., 11lxc-start: )          = 11
write(2, "Invalid argument - failed to fork"..., 54Invalid argument -
failed to fork into a new namespace) = 54
write(2, "\n"..., 1
)                    = 1
close(13)                               = 0
close(14)                               = 0
write(2, "lxc-start: "..., 11lxc-start: )          = 11
write(2, "failed to spawn '/sbin/init'"..., 28failed to spawn '/sbin/init') = 28
write(2, "\n"..., 1
)                    = 1
...
-----------------------------------------

Thanks in advance.

-- 
Miguel Sousa Filipe
