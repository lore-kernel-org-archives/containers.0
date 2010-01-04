From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Sun, 3 Jan 2010 20:54:20 -0600
Message-ID: <68e6eac61001031854v35c9b0a0sebce033812977e73@mail.gmail.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
	<68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <68e6eac61001031746r44668e6cheb497c7df5f68a18-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

# strace lxc-start -n arch64-1 /root/boot-init.sh
execve("/usr/bin/lxc-start", ["lxc-start", "-n", "arch64-1",
"/root/boot-init.sh"], [/* 21 vars */]) =3D 0
brk(0)                                  =3D 0x1bf9000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8223000
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8221000
access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/usr/lib/lxc/tls/x86_64/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No
such file or directory)
stat("/usr/lib/lxc/tls/x86_64", 0x7fffc47e4220) =3D -1 ENOENT (No such
file or directory)
open("/usr/lib/lxc/tls/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
stat("/usr/lib/lxc/tls", 0x7fffc47e4220) =3D -1 ENOENT (No such file or dir=
ectory)
open("/usr/lib/lxc/x86_64/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No
such file or directory)
stat("/usr/lib/lxc/x86_64", 0x7fffc47e4220) =3D -1 ENOENT (No such file
or directory)
open("/usr/lib/lxc/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No such file
or directory)
stat("/usr/lib/lxc", {st_mode=3DS_IFDIR|0755, st_size=3D80, ...}) =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x7feca8217000
close(3)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libutil.so.1", O_RDONLY)     =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\16\0\0\0\0\0\0@"=
...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D10648, ...}) =3D 0
mmap(NULL, 2105608, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7feca7e05000
mprotect(0x7feca7e07000, 2093056, PROT_NONE) =3D 0
mmap(0x7feca8006000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) =3D 0x7feca8006000
close(3)                                =3D 0
open("/usr/lib/lxc/liblxc-0.6.3.so", O_RDONLY) =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@_\0\0\0\0\0\0@"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D116160, ...}) =3D 0
mmap(NULL, 2211736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7feca7be9000
mprotect(0x7feca7c04000, 2097152, PROT_NONE) =3D 0
mmap(0x7feca7e04000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) =3D 0x7feca7e04000
close(3)                                =3D 0
open("/usr/lib/lxc/libc.so.6", O_RDONLY) =3D -1 ENOENT (No such file or dir=
ectory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libc.so.6", O_RDONLY)        =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\353\1\0\0\0\0\0=
@"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D1379752, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8216000
mmap(NULL, 3487784, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7feca7895000
mprotect(0x7feca79df000, 2097152, PROT_NONE) =3D 0
mmap(0x7feca7bdf000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14a000) =3D 0x7feca7bdf000
mmap(0x7feca7be4000, 18472, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x7feca7be4000
close(3)                                =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8215000
arch_prctl(ARCH_SET_FS, 0x7feca82156f0) =3D 0
mprotect(0x7feca7bdf000, 16384, PROT_READ) =3D 0
mprotect(0x7feca8006000, 4096, PROT_READ) =3D 0
mprotect(0x7feca8224000, 4096, PROT_READ) =3D 0
munmap(0x7feca8217000, 38247)           =3D 0
open("/proc/self/fd", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) =3D 3
fcntl(3, F_GETFD)                       =3D 0x1 (flags FD_CLOEXEC)
brk(0)                                  =3D 0x1bf9000
brk(0x1c22000)                          =3D 0x1c22000
getdents(3, /* 6 entries */, 32768)     =3D 144
getdents(3, /* 0 entries */, 32768)     =3D 0
close(3)                                =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
access("/var/lib/lxc/arch64-1", R_OK|W_OK|X_OK) =3D 0
open("/var/lib/lxc/arch64-1", O_RDONLY|O_DIRECTORY) =3D 3
fcntl(3, F_SETFD, FD_CLOEXEC)           =3D 0
flock(3, LOCK_EX|LOCK_NB)               =3D 0
open("/var/lib/lxc/arch64-1/state", O_WRONLY) =3D 4
flock(4, LOCK_EX)                       =3D 0
ftruncate(4, 0)                         =3D 0
write(4, "STARTING"..., 8)              =3D 8
close(4)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 4
sendto(4, "\0\0\0\0arch64-1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(4)                                =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
readlink("/proc/self/fd/0", "/dev/pts/0"..., 4095) =3D 10
stat("/var/lib/lxc/arch64-1/tty", {st_mode=3DS_IFREG|0755, st_size=3D3, ...=
}) =3D 0
open("/var/lib/lxc/arch64-1/tty", O_RDONLY) =3D 4
read(4, "1\n\0"..., 4)                  =3D 3
close(4)                                =3D 0
open("/dev/ptmx", O_RDWR)               =3D 4
statfs("/dev/pts", {f_type=3D"DEVPTS_SUPER_MAGIC", f_bsize=3D4096,
f_blocks=3D0, f_bfree=3D0, f_bavail=3D0, f_files=3D0, f_ffree=3D0, f_fsid=
=3D{0,
0}, f_namelen=3D255, f_frsize=3D4096}) =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
statfs("/dev/pts/1", {f_type=3D"DEVPTS_SUPER_MAGIC", f_bsize=3D4096,
f_blocks=3D0, f_bfree=3D0, f_bavail=3D0, f_files=3D0, f_ffree=3D0, f_fsid=
=3D{0,
0}, f_namelen=3D255, f_frsize=3D4096}) =3D 0
fstat(4, {st_mode=3DS_IFCHR|0666, st_rdev=3Dmakedev(5, 2), ...}) =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
getuid()                                =3D 0
socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) =3D 5
connect(5, {sa_family=3DAF_FILE, path=3D"/var/run/nscd/socket"...}, 110) =
=3D
-1 ENOENT (No such file or directory)
close(5)                                =3D 0
socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) =3D 5
connect(5, {sa_family=3DAF_FILE, path=3D"/var/run/nscd/socket"...}, 110) =
=3D
-1 ENOENT (No such file or directory)
close(5)                                =3D 0
open("/etc/nsswitch.conf", O_RDONLY)    =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D475, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8220000
read(5, "# /etc/nsswitch.conf\n#\n# Example "..., 4096) =3D 475
read(5, ""..., 4096)                    =3D 0
close(5)                                =3D 0
munmap(0x7feca8220000, 4096)            =3D 0
open("/usr/lib/lxc/libnss_compat.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 5, 0) =3D 0x7feca8217000
close(5)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_compat.so.2", O_RDONLY) =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\23\0\0\0\0\0\0@"=
...,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D31616, ...}) =3D 0
mmap(NULL, 2127088, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7feca768d000
mprotect(0x7feca7694000, 2093056, PROT_NONE) =3D 0
mmap(0x7feca7893000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x6000) =3D 0x7feca7893000
close(5)                                =3D 0
open("/usr/lib/lxc/libnsl.so.1", O_RDONLY) =3D -1 ENOENT (No such file
or directory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnsl.so.1", O_RDONLY)      =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300@\0\0\0\0\0\0@".=
..,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D89064, ...}) =3D 0
mmap(NULL, 2194128, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7feca7475000
mprotect(0x7feca748a000, 2093056, PROT_NONE) =3D 0
mmap(0x7feca7689000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x14000) =3D 0x7feca7689000
mmap(0x7feca768b000, 6864, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x7feca768b000
close(5)                                =3D 0
mprotect(0x7feca7689000, 4096, PROT_READ) =3D 0
mprotect(0x7feca7893000, 4096, PROT_READ) =3D 0
munmap(0x7feca8217000, 38247)           =3D 0
open("/usr/lib/lxc/libnss_nis.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 5, 0) =3D 0x7feca8217000
close(5)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_nis.so.2", O_RDONLY)  =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0
\0\0\0\0\0\0@"..., 832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D43552, ...}) =3D 0
mmap(NULL, 2139320, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7feca726a000
mprotect(0x7feca7274000, 2093056, PROT_NONE) =3D 0
mmap(0x7feca7473000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x9000) =3D 0x7feca7473000
close(5)                                =3D 0
open("/usr/lib/lxc/libnss_files.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_files.so.2", O_RDONLY) =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p!\0\0\0\0\0\0@"...,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D47616, ...}) =3D 0
mmap(NULL, 2143624, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7feca705e000
mprotect(0x7feca7069000, 2093056, PROT_NONE) =3D 0
mmap(0x7feca7268000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0xa000) =3D 0x7feca7268000
close(5)                                =3D 0
mprotect(0x7feca7268000, 4096, PROT_READ) =3D 0
mprotect(0x7feca7473000, 4096, PROT_READ) =3D 0
munmap(0x7feca8217000, 38247)           =3D 0
open("/etc/group", O_RDONLY|O_CLOEXEC)  =3D 5
fcntl(5, F_GETFD)                       =3D 0x1 (flags FD_CLOEXEC)
lseek(5, 0, SEEK_CUR)                   =3D 0
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D714, ...}) =3D 0
mmap(NULL, 714, PROT_READ, MAP_SHARED, 5, 0) =3D 0x7feca8220000
lseek(5, 714, SEEK_SET)                 =3D 714
munmap(0x7feca8220000, 714)             =3D 0
close(5)                                =3D 0
chown("/dev/pts/1", 0, 5)               =3D 0
chmod("/dev/pts/1", 0620)               =3D 0
ioctl(4, TIOCSPTLCK, [0])               =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
open("/dev/pts/1", O_RDWR|O_NOCTTY)     =3D 5
fcntl(4, F_SETFD, FD_CLOEXEC)           =3D 0
fcntl(5, F_SETFD, FD_CLOEXEC)           =3D 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) =3D 0
syscall_289(0xffffffffffffffff, 0x7fffc47e4910, 0x8, 0,
0x7fffc47e4910, 0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0,
0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0,
0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0,
0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0,
0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0, 0x1bfa0a0) =3D 0x6
fcntl(6, F_SETFD, FD_CLOEXEC)           =3D 0
rt_sigaction(SIGINT, {0x7feca7bf0070, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7feca78c6fd0}, {SIG_DFL}, 8) =3D 0
rt_sigaction(SIGQUIT, {0x7feca7bf0090, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7feca78c6fd0}, {SIG_DFL}, 8) =3D 0
socketpair(PF_FILE, SOCK_STREAM, 0, [7, 8]) =3D 0
stat("/var/lib/lxc/arch64-1/network", {st_mode=3DS_IFDIR|0755,
st_size=3D8, ...}) =3D 0
clone(child_stack=3D0x7fffc47e4900, flags=3DCLONE_NEWNS|0x6c000000|SIGCHLD)=
 =3D 3679
close(7)                                =3D 0
read(8, "\377\377\377\377"..., 4)       =3D 4
open("/etc/mtab", O_RDONLY)             =3D 7
fstat(7, {st_mode=3DS_IFREG|0644, st_size=3D722, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7feca8220000
read(7, "/dev/sda3 / jfs rw,noatime,errors"..., 4096) =3D 722
read(7, ""..., 4096)                    =3D 0
close(7)                                =3D 0
munmap(0x7feca8220000, 4096)            =3D 0
access("/cgroup/arch64-1", F_OK)        =3D 0
rmdir("/cgroup/arch64-1")               =3D -1 EBUSY (Device or resource bu=
sy)
write(2, "lxc-start: "..., 11lxc-start: )          =3D 11
write(2, "Device or resource busy - failed "..., 77Device or resource
busy - failed to remove previous cgroup '/cgroup/arch64-1') =3D 77
write(2, "\n"..., 1
)                    =3D 1
open("/var/lib/lxc/arch64-1/state", O_WRONLY) =3D 7
flock(7, LOCK_EX)                       =3D 0
ftruncate(7, 0)                         =3D 0
write(7, "ABORTING"..., 8)              =3D 8
close(7)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 7
sendto(7, "\0\0\0\0arch64-1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(7)                                =3D 0
kill(3679, SIGKILL)                     =3D 0
close(7)                                =3D -1 EBADF (Bad file descriptor)
close(8)                                =3D 0
write(2, "lxc-start: "..., 11lxc-start: )          =3D 11
write(2, "failed to spawn '/root/boot-init."..., 36failed to spawn
'/root/boot-init.sh') =3D 36
write(2, "\n"..., 1
)                    =3D 1
open("/var/lib/lxc/arch64-1/state", O_WRONLY) =3D 7
flock(7, LOCK_EX)                       =3D 0
ftruncate(7, 0)                         =3D 0
write(7, "STOPPING"..., 8)              =3D 8
close(7)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 7
sendto(7, "\0\0\0\0arch64-1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(7)                                =3D 0
open("/var/lib/lxc/arch64-1/state", O_WRONLY) =3D 7
flock(7, LOCK_EX)                       =3D 0
ftruncate(7, 0)                         =3D 0
write(7, "STOPPED"..., 7)               =3D 7
close(7)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 7
sendto(7, "\0\0\0\0arch64-1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(7)                                =3D 0
readlink("/var/lib/lxc/arch64-1/nsgroup", 0x7fffc47e2990, 4095) =3D -1
ENOENT (No such file or directory)
unlink("/var/lib/lxc/arch64-1/nsgroup") =3D -1 ENOENT (No such file or dire=
ctory)
unlink("/var/lib/lxc/arch64-1/init")    =3D -1 ENOENT (No such file or dire=
ctory)
close(4)                                =3D 0
close(5)                                =3D 0
flock(3, LOCK_UN)                       =3D 0
close(3)                                =3D 0
rt_sigaction(SIGQUIT, {SIG_DFL}, NULL, 8) =3D 0
rt_sigaction(SIGINT, {SIG_DFL}, NULL, 8) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
rt_sigaction(SIGTTOU, {SIG_IGN}, {SIG_DFL}, 8) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_STOP or TCSETSW, {B38400 opost isig icanon echo ...}) =
=3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
rt_sigaction(SIGTTOU, {SIG_DFL}, {SIG_IGN}, 8) =3D 0
exit_group(-1)                          =3D ?

////// Ok, that one did not restart

# lxc-ls
arch64-1  suzy111-640

////// I'll see if the next one will start

# strace lxc-start -n suzy111-640 /root/boot-init.sh
execve("/usr/bin/lxc-start", ["lxc-start", "-n", "suzy111-640",
"/root/boot-init.sh"], [/* 21 vars */]) =3D 0
brk(0)                                  =3D 0x1151000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c54061000
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c5405f000
access("/etc/ld.so.preload", R_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/usr/lib/lxc/tls/x86_64/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No
such file or directory)
stat("/usr/lib/lxc/tls/x86_64", 0x7fffaba45840) =3D -1 ENOENT (No such
file or directory)
open("/usr/lib/lxc/tls/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
stat("/usr/lib/lxc/tls", 0x7fffaba45840) =3D -1 ENOENT (No such file or dir=
ectory)
open("/usr/lib/lxc/x86_64/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No
such file or directory)
stat("/usr/lib/lxc/x86_64", 0x7fffaba45840) =3D -1 ENOENT (No such file
or directory)
open("/usr/lib/lxc/libutil.so.1", O_RDONLY) =3D -1 ENOENT (No such file
or directory)
stat("/usr/lib/lxc", {st_mode=3DS_IFDIR|0755, st_size=3D80, ...}) =3D 0
open("/etc/ld.so.cache", O_RDONLY)      =3D 3
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 3, 0) =3D 0x7f3c54055000
close(3)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libutil.so.1", O_RDONLY)     =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\16\0\0\0\0\0\0@"=
...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D10648, ...}) =3D 0
mmap(NULL, 2105608, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7f3c53c43000
mprotect(0x7f3c53c45000, 2093056, PROT_NONE) =3D 0
mmap(0x7f3c53e44000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) =3D 0x7f3c53e44000
close(3)                                =3D 0
open("/usr/lib/lxc/liblxc-0.6.3.so", O_RDONLY) =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@_\0\0\0\0\0\0@"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0644, st_size=3D116160, ...}) =3D 0
mmap(NULL, 2211736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7f3c53a27000
mprotect(0x7f3c53a42000, 2097152, PROT_NONE) =3D 0
mmap(0x7f3c53c42000, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1b000) =3D 0x7f3c53c42000
close(3)                                =3D 0
open("/usr/lib/lxc/libc.so.6", O_RDONLY) =3D -1 ENOENT (No such file or dir=
ectory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libc.so.6", O_RDONLY)        =3D 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\353\1\0\0\0\0\0=
@"...,
832) =3D 832
fstat(3, {st_mode=3DS_IFREG|0755, st_size=3D1379752, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c54054000
mmap(NULL, 3487784, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) =3D 0x7f3c536d3000
mprotect(0x7f3c5381d000, 2097152, PROT_NONE) =3D 0
mmap(0x7f3c53a1d000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14a000) =3D 0x7f3c53a1d000
mmap(0x7f3c53a22000, 18472, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x7f3c53a22000
close(3)                                =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c54053000
arch_prctl(ARCH_SET_FS, 0x7f3c540536f0) =3D 0
mprotect(0x7f3c53a1d000, 16384, PROT_READ) =3D 0
mprotect(0x7f3c53e44000, 4096, PROT_READ) =3D 0
mprotect(0x7f3c54062000, 4096, PROT_READ) =3D 0
munmap(0x7f3c54055000, 38247)           =3D 0
open("/proc/self/fd", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) =3D 3
fcntl(3, F_GETFD)                       =3D 0x1 (flags FD_CLOEXEC)
brk(0)                                  =3D 0x1151000
brk(0x117a000)                          =3D 0x117a000
getdents(3, /* 6 entries */, 32768)     =3D 144
getdents(3, /* 0 entries */, 32768)     =3D 0
close(3)                                =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
access("/var/lib/lxc/suzy111-640", R_OK|W_OK|X_OK) =3D 0
open("/var/lib/lxc/suzy111-640", O_RDONLY|O_DIRECTORY) =3D 3
fcntl(3, F_SETFD, FD_CLOEXEC)           =3D 0
flock(3, LOCK_EX|LOCK_NB)               =3D 0
open("/var/lib/lxc/suzy111-640/state", O_WRONLY) =3D 4
flock(4, LOCK_EX)                       =3D 0
ftruncate(4, 0)                         =3D 0
write(4, "STARTING"..., 8)              =3D 8
close(4)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 4
sendto(4, "\0\0\0\0suzy111-640\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(4)                                =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
readlink("/proc/self/fd/0", "/dev/pts/0"..., 4095) =3D 10
stat("/var/lib/lxc/suzy111-640/tty", {st_mode=3DS_IFREG|0755, st_size=3D3, =
...}) =3D 0
open("/var/lib/lxc/suzy111-640/tty", O_RDONLY) =3D 4
read(4, "1\n\0"..., 4)                  =3D 3
close(4)                                =3D 0
open("/dev/ptmx", O_RDWR)               =3D 4
statfs("/dev/pts", {f_type=3D"DEVPTS_SUPER_MAGIC", f_bsize=3D4096,
f_blocks=3D0, f_bfree=3D0, f_bavail=3D0, f_files=3D0, f_ffree=3D0, f_fsid=
=3D{0,
0}, f_namelen=3D255, f_frsize=3D4096}) =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
statfs("/dev/pts/1", {f_type=3D"DEVPTS_SUPER_MAGIC", f_bsize=3D4096,
f_blocks=3D0, f_bfree=3D0, f_bavail=3D0, f_files=3D0, f_ffree=3D0, f_fsid=
=3D{0,
0}, f_namelen=3D255, f_frsize=3D4096}) =3D 0
fstat(4, {st_mode=3DS_IFCHR|0666, st_rdev=3Dmakedev(5, 2), ...}) =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
getuid()                                =3D 0
socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) =3D 5
connect(5, {sa_family=3DAF_FILE, path=3D"/var/run/nscd/socket"...}, 110) =
=3D
-1 ENOENT (No such file or directory)
close(5)                                =3D 0
socket(PF_FILE, 0x80801 /* SOCK_??? */, 0) =3D 5
connect(5, {sa_family=3DAF_FILE, path=3D"/var/run/nscd/socket"...}, 110) =
=3D
-1 ENOENT (No such file or directory)
close(5)                                =3D 0
open("/etc/nsswitch.conf", O_RDONLY)    =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D475, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c5405e000
read(5, "# /etc/nsswitch.conf\n#\n# Example "..., 4096) =3D 475
read(5, ""..., 4096)                    =3D 0
close(5)                                =3D 0
munmap(0x7f3c5405e000, 4096)            =3D 0
open("/usr/lib/lxc/libnss_compat.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 5, 0) =3D 0x7f3c54055000
close(5)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_compat.so.2", O_RDONLY) =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20\23\0\0\0\0\0\0@"=
...,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D31616, ...}) =3D 0
mmap(NULL, 2127088, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7f3c534cb000
mprotect(0x7f3c534d2000, 2093056, PROT_NONE) =3D 0
mmap(0x7f3c536d1000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x6000) =3D 0x7f3c536d1000
close(5)                                =3D 0
open("/usr/lib/lxc/libnsl.so.1", O_RDONLY) =3D -1 ENOENT (No such file
or directory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnsl.so.1", O_RDONLY)      =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\300@\0\0\0\0\0\0@".=
..,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D89064, ...}) =3D 0
mmap(NULL, 2194128, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7f3c532b3000
mprotect(0x7f3c532c8000, 2093056, PROT_NONE) =3D 0
mmap(0x7f3c534c7000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x14000) =3D 0x7f3c534c7000
mmap(0x7f3c534c9000, 6864, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) =3D 0x7f3c534c9000
close(5)                                =3D 0
mprotect(0x7f3c534c7000, 4096, PROT_READ) =3D 0
mprotect(0x7f3c536d1000, 4096, PROT_READ) =3D 0
munmap(0x7f3c54055000, 38247)           =3D 0
open("/usr/lib/lxc/libnss_nis.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
open("/etc/ld.so.cache", O_RDONLY)      =3D 5
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D38247, ...}) =3D 0
mmap(NULL, 38247, PROT_READ, MAP_PRIVATE, 5, 0) =3D 0x7f3c54055000
close(5)                                =3D 0
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_nis.so.2", O_RDONLY)  =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0
\0\0\0\0\0\0@"..., 832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D43552, ...}) =3D 0
mmap(NULL, 2139320, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7f3c530a8000
mprotect(0x7f3c530b2000, 2093056, PROT_NONE) =3D 0
mmap(0x7f3c532b1000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x9000) =3D 0x7f3c532b1000
close(5)                                =3D 0
open("/usr/lib/lxc/libnss_files.so.2", O_RDONLY) =3D -1 ENOENT (No such
file or directory)
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or dire=
ctory)
open("/lib/libnss_files.so.2", O_RDONLY) =3D 5
read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p!\0\0\0\0\0\0@"...,
832) =3D 832
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D47616, ...}) =3D 0
mmap(NULL, 2143624, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5,
0) =3D 0x7f3c52e9c000
mprotect(0x7f3c52ea7000, 2093056, PROT_NONE) =3D 0
mmap(0x7f3c530a6000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0xa000) =3D 0x7f3c530a6000
close(5)                                =3D 0
mprotect(0x7f3c530a6000, 4096, PROT_READ) =3D 0
mprotect(0x7f3c532b1000, 4096, PROT_READ) =3D 0
munmap(0x7f3c54055000, 38247)           =3D 0
open("/etc/group", O_RDONLY|O_CLOEXEC)  =3D 5
fcntl(5, F_GETFD)                       =3D 0x1 (flags FD_CLOEXEC)
lseek(5, 0, SEEK_CUR)                   =3D 0
fstat(5, {st_mode=3DS_IFREG|0644, st_size=3D714, ...}) =3D 0
mmap(NULL, 714, PROT_READ, MAP_SHARED, 5, 0) =3D 0x7f3c5405e000
lseek(5, 714, SEEK_SET)                 =3D 714
munmap(0x7f3c5405e000, 714)             =3D 0
close(5)                                =3D 0
chown("/dev/pts/1", 0, 5)               =3D 0
chmod("/dev/pts/1", 0620)               =3D 0
ioctl(4, TIOCSPTLCK, [0])               =3D 0
ioctl(4, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
ioctl(4, TIOCGPTN, [1])                 =3D 0
stat("/dev/pts/1", {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(136, 1), ...}=
) =3D 0
open("/dev/pts/1", O_RDWR|O_NOCTTY)     =3D 5
fcntl(4, F_SETFD, FD_CLOEXEC)           =3D 0
fcntl(5, F_SETFD, FD_CLOEXEC)           =3D 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) =3D 0
syscall_289(0xffffffffffffffff, 0x7fffaba45f30, 0x8, 0,
0x7fffaba45f30, 0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0,
0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0,
0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0,
0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0,
0x11520a0, 0x11520a0, 0x11520a0, 0x11520a0) =3D 0x6
fcntl(6, F_SETFD, FD_CLOEXEC)           =3D 0
rt_sigaction(SIGINT, {0x7f3c53a2e070, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7f3c53704fd0}, {SIG_DFL}, 8) =3D 0
rt_sigaction(SIGQUIT, {0x7f3c53a2e090, ~[RTMIN RT_1],
SA_RESTORER|SA_SIGINFO, 0x7f3c53704fd0}, {SIG_DFL}, 8) =3D 0
socketpair(PF_FILE, SOCK_STREAM, 0, [7, 8]) =3D 0
stat("/var/lib/lxc/suzy111-640/network", {st_mode=3DS_IFDIR|0755,
st_size=3D8, ...}) =3D 0
clone(child_stack=3D0x7fffaba45f20, flags=3DCLONE_NEWNS|0x6c000000|SIGCHLD)=
 =3D 3699
close(7)                                =3D 0
read(8, "\377\377\377\377"..., 4)       =3D 4
open("/etc/mtab", O_RDONLY)             =3D 7
fstat(7, {st_mode=3DS_IFREG|0644, st_size=3D722, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c5405e000
read(7, "/dev/sda3 / jfs rw,noatime,errors"..., 4096) =3D 722
read(7, ""..., 4096)                    =3D 0
close(7)                                =3D 0
munmap(0x7f3c5405e000, 4096)            =3D 0
access("/cgroup/suzy111-640", F_OK)     =3D -1 ENOENT (No such file or dire=
ctory)
rename("/cgroup/3699", "/cgroup/suzy111-640") =3D 0
open("/etc/mtab", O_RDONLY)             =3D 7
fstat(7, {st_mode=3DS_IFREG|0644, st_size=3D722, ...}) =3D 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x7f3c5405e000
read(7, "/dev/sda3 / jfs rw,noatime,errors"..., 4096) =3D 722
read(7, ""..., 4096)                    =3D 0
close(7)                                =3D 0
munmap(0x7f3c5405e000, 4096)            =3D 0
unlink("/var/lib/lxc/suzy111-640/nsgroup") =3D -1 ENOENT (No such file
or directory)
symlink("/cgroup/suzy111-640", "/var/lib/lxc/suzy111-640/nsgroup") =3D 0
open("/var/lib/lxc/suzy111-640/network",
O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) =3D 7
getdents(7, /* 3 entries */, 32768)     =3D 80
getdents(7, /* 0 entries */, 32768)     =3D 0
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/network/veth0/link", O_RDONLY) =3D 7
read(7, "lxcbr0\n\0"..., 16)            =3D 8
close(7)                                =3D 0
socket(PF_NETLINK, SOCK_RAW, 0)         =3D 7
setsockopt(7, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(7, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(7, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D 0
getsockname(7, {sa_family=3DAF_NETLINK, pid=3D3698, groups=3D00000000},
[18446744069414584332]) =3D 0
sendmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"h\0\0\0\20\0\5\6\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\=
0\0\0008"...,
104}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 104
recvmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0\0\0\0\0r\16\0\0\0\0\0\0h\0\0\0\20\0\5\6\0\0=
\0\0\0"...,
8192}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 36
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/network/veth0/mtu", O_RDONLY) =3D -1
ENOENT (No such file or directory)
close(4294967295)                       =3D -1 EBADF (Bad file descriptor)
access("/proc/net", R_OK)               =3D 0
access("/proc/net/unix", R_OK)          =3D 0
socket(PF_FILE, 0x80002 /* SOCK_??? */, 0) =3D 7
ioctl(7, SIOCGIFINDEX, {ifr_name=3D"veth0_3699", ifr_index=3D14}) =3D 0
close(7)                                =3D 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 7
ioctl(7, 0x89a2, 0x7fffaba44dd0)        =3D 0
close(7)                                =3D 0
socket(PF_FILE, 0x80002 /* SOCK_??? */, 0) =3D 7
ioctl(7, SIOCGIFINDEX, {ifr_name=3D"veth0~3699", ifr_index=3D13}) =3D 0
close(7)                                =3D 0
creat("/var/lib/lxc/suzy111-640/network/veth0/ifindex", 0755) =3D 7
write(7, "13"..., 2)                    =3D 2
write(7, "\n\0"..., 2)                  =3D 2
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/network/veth0/up", O_RDONLY) =3D 7
read(7, "\n\0"..., 8)                   =3D 2
close(7)                                =3D 0
socket(PF_NETLINK, SOCK_RAW, 0)         =3D 7
setsockopt(7, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(7, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(7, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D 0
getsockname(7, {sa_family=3DAF_NETLINK, pid=3D3698, groups=3D00000000},
[18446744069414584332]) =3D 0
socket(PF_FILE, 0x80002 /* SOCK_??? */, 0) =3D 9
ioctl(9, SIOCGIFINDEX, {ifr_name=3D"veth0_3699", ifr_index=3D14}) =3D 0
close(9)                                =3D 0
sendmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000}, msg_iov(1)=3D[{"
\0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\16\0\0\0\1\0\0\0\1\0\0\0"...,
32}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 32
recvmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0\0\0\0\0r\16\0\0\0\0\0\0
\0\0\0\20\0\5\0\0\0\0\0\0"..., 8192}], msg_controllen=3D0, msg_flags=3D0},
0) =3D 36
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/network",
O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) =3D 7
getdents(7, /* 3 entries */, 32768)     =3D 80
getdents(7, /* 0 entries */, 32768)     =3D 0
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/network/veth0/ifindex", O_RDONLY) =3D 7
read(7, "13\n\0"..., 20)                =3D 4
close(7)                                =3D 0
socket(PF_FILE, 0x80002 /* SOCK_??? */, 0) =3D 7
ioctl(7, SIOCGIFNAME, {ifr_index=3D13, ifr_name=3D"veth0~3699"}) =3D 0
close(7)                                =3D 0
socket(PF_NETLINK, SOCK_RAW, 0)         =3D 7
setsockopt(7, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(7, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(7, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D 0
getsockname(7, {sa_family=3DAF_NETLINK, pid=3D3698, groups=3D00000000},
[18446744069414584332]) =3D 0
socket(PF_FILE, 0x80002 /* SOCK_??? */, 0) =3D 9
ioctl(9, SIOCGIFINDEX, {ifr_name=3D"veth0~3699", ifr_index=3D13}) =3D 0
close(9)                                =3D 0
sendmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"8\0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\r\0\0\0\0\0\0\0\0\=
0\0\0\10"...,
56}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 56
recvmsg(7, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\2\0\0\0\0\0\0\0r\16\0\0\0\0\0\0008\0\0\0\20\0\5\0\0=
\0\0\0\0"...,
56}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 36
close(7)                                =3D 0
write(8, "\377\377\377\377"..., 4)      =3D 4
read(8, ""..., 4)                       =3D 0
open("/var/lib/lxc/suzy111-640/init", O_WRONLY|O_CREAT|O_TRUNC, 0600) =3D 7
write(7, "3699\n"..., 5)                =3D 5
close(7)                                =3D 0
open("/var/lib/lxc/suzy111-640/state", O_WRONLY) =3D 7
flock(7, LOCK_EX)                       =3D 0
ftruncate(7, 0)                         =3D 0
write(7, "RUNNING"..., 7)               =3D 7
close(7)                                =3D 0
socket(PF_FILE, SOCK_DGRAM, 0)          =3D 7
sendto(7, "\0\0\0\0suzy111-640\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
4104, 0, {sa_family=3DAF_FILE, path=3D@"lxc-monitor"...}, 110) =3D -1
ECONNREFUSED (Connection refused)
close(7)                                =3D 0
close(7)                                =3D -1 EBADF (Bad file descriptor)
close(8)                                =3D 0
ioctl(2, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}=
) =3D 0
close(1)                                =3D 0
close(0)                                =3D 0
socket(PF_FILE, SOCK_STREAM, 0)         =3D 0
bind(0, {sa_family=3DAF_FILE, path=3D@"suzy111-640"...}, 110) =3D 0
listen(0, 100)                          =3D 0
fcntl(0, F_SETFD, FD_CLOEXEC)           =3D 0
epoll_create(1)                         =3D 1
epoll_ctl(1, EPOLL_CTL_ADD, 6, {EPOLLIN, {u32=3D18174704, u64=3D18174704}})=
 =3D 0
epoll_ctl(1, EPOLL_CTL_ADD, 0, {EPOLLIN, {u32=3D18174768, u64=3D18174768}})=
 =3D 0
epoll_wait(1, Starting up container suzy111-640
Removing stale pids and locks
Setting default route and DNS
Initializing /etc/mtab
Starting up container suzy111-640 services
Starting syslog services

                                    done
Starting CRON daemon

                                    done
Starting SSH daemon

                                    done
Welcome root@suzy111-640

////// And it did start, which is normally how the first one starts.

Ok, a bit of more information that may be useful.
In the last few times I've had this problem, it is when I restarted
networking on root-node, so the network bridge device in use by the
container in question got taken apart then put back together.

$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug lan0
auto lan0
iface lan0 inet dhcp
hwaddress ether 08:00:27:5c:9b:c7

auto  lxctap0
iface lxctap0 inet static
  pre-up tunctl -u root -t lxctap0
  address 0.0.0.1
  netmask 255.255.255.254

auto  lxcbr0
iface lxcbr0 inet static
  address 192.168.3.1
  network 192.168.3.0
  netmask 255.255.255.0
  broadcast 192.168.3.255
  bridge_ports lxctap0
  bridge_fd 0

$ cat /ve/lxc/config/arch64-1.rc
lxc.utsname =3D arch64-1
lxc.network.type =3D veth
lxc.network.flags =3D up
lxc.network.link =3D lxcbr0
lxc.network.ipv4 =3D 192.168.3.3/24
#lxc.network.hwaddr =3D 4a:49:43:49:79:bd
lxc.network.name =3D vlan0
lxc.mount =3D /ve/lxc/fstab/arch64-1
lxc.rootfs =3D /ve/lxc/rootfs/arch64-1

lxc.tty =3D 1
lxc.pts =3D 1024

lxc.cgroup.devices.deny =3D a # Deny all access to devices

lxc.cgroup.devices.allow =3D c 5:1 rwm # console
lxc.cgroup.devices.allow =3D c 1:7 rwm # full
lxc.cgroup.devices.allow =3D c 1:3 rwm # null
lxc.cgroup.devices.allow =3D c 5:2 rwm # ptmx
lxc.cgroup.devices.allow =3D c 1:8 rwm # random
lxc.cgroup.devices.allow =3D c 5:0 rwm # tty
lxc.cgroup.devices.allow =3D c 4:0 rwm # tty0
#lxc.cgroup.devices.allow =3D c 4:1 rwm # tty1
#lxc.cgroup.devices.allow =3D c 4:2 rwm # tty2
#lxc.cgroup.devices.allow =3D c 4:3 rwm # tty3

lxc.cgroup.devices.allow =3D c 1:9 rwm # urandom
lxc.cgroup.devices.allow =3D c 1:5 rwm # dev/zero

lxc.cgroup.devices.allow =3D c 136:* rwm # pts/*

lxc.cgroup.devices.allow =3D c 10:200 rwm # net/tun

lxc.cgroup.devices.allow =3D c 116:* rwm

 $ cat /ve/lxc/fstab/arch64-1
none   /ve/lxc/rootfs/arch64-1/dev/pts	devpts	defaults 0 0
none   /ve/lxc/rootfs/arch64-1/proc	proc	defaults 0 0
none   /ve/lxc/rootfs/arch64-1/sys	sysfs	defaults 0 0
none   /ve/lxc/rootfs/arch64-1/dev/shm	tmpfs	defaults 0 0

Not sure if any of that is useful additional information.

--
Dwight

On Sun, Jan 3, 2010 at 7:46 PM, Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Sun, Jan 3, 2010 at 7:22 PM, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
>> Can you please paste the output of cat /proc/cgroups and cat /proc/mounts
> Sure.
>
>> This should not really happen, /proc/cgroups will help us figure out what
>> is going on. As an alternative, if you can compile the debug cgroup cont=
ainer,
>> you'll get a lot of useful debug information (CONFIG_CGROUP_DEBUG).
>
> Yeah, I did not think that should happen.
>
> Ok, here goes:
>
> =A0$ sudo lxc-start -n arch64-1 /root/boot-init.sh
> lxc-start: Device or resource busy - failed to remove previous cgroup
> '/cgroup/arch64-1'
> lxc-start: failed to spawn '/root/boot-init.sh'
>
> $ sudo lxc-stop -n arch64-1
> lxc-stop: container 'arch64-1' is not active
>
> =A0$ cat /proc/cgroups
> #subsys_name =A0 =A0hierarchy =A0 =A0 =A0 num_cgroups =A0 =A0 enabled
> cpuset =A0127 =A0 =A0 7 =A0 =A0 =A0 1
> ns =A0 =A0 =A0127 =A0 =A0 7 =A0 =A0 =A0 1
> cpu =A0 =A0 127 =A0 =A0 7 =A0 =A0 =A0 1
> cpuacct 127 =A0 =A0 7 =A0 =A0 =A0 1
> devices 127 =A0 =A0 7 =A0 =A0 =A0 1
> freezer 127 =A0 =A0 7 =A0 =A0 =A0 1
> net_cls 127 =A0 =A0 7 =A0 =A0 =A0 1
>
> =A0$ cat /proc/mounts
> rootfs / rootfs rw 0 0
> none /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
> none /proc proc rw,nosuid,nodev,noexec,relatime 0 0
> udev /dev tmpfs rw,relatime,size=3D10240k,mode=3D755 0 0
> /dev/sda3 / jfs rw,noatime 0 0
> tmpfs /lib/init/rw tmpfs rw,nosuid,relatime,mode=3D755 0 0
> usbfs /proc/bus/usb usbfs rw,nosuid,nodev,noexec,relatime 0 0
> tmpfs /dev/shm tmpfs rw,nosuid,nodev,relatime 0 0
> devpts /dev/pts devpts rw,nosuid,noexec,relatime,mode=3D600,ptmxmode=3D00=
0 0 0
> /dev/sda1 /boot ext3 rw,noatime,errors=3Dcontinue,data=3Dordered 0 0
> /dev/sda9 /home jfs rw,noatime 0 0
> /dev/sda6 /opt jfs rw,noatime 0 0
> /dev/sda5 /tmp jfs rw,noatime 0 0
> /dev/sda8 /usr jfs rw,noatime 0 0
> /dev/sda7 /var jfs rw,noatime 0 0
> /dev/sda9 /ve jfs rw,noatime 0 0
> none /cgroup cgroup rw,noatime,net_cls,freezer,devices,cpuacct,cpu,ns,cpu=
set 0 0
> /dev/sda9 /ve/lxc/rootfs/arch64-1/home/dwight/workspace jfs rw,noatime 0 0
>
> =A0$ mount
> /dev/sda3 on / type jfs (rw,noatime,errors=3Dremount-ro)
> tmpfs on /lib/init/rw type tmpfs (rw,nosuid,mode=3D0755)
> proc on /proc type proc (rw,noexec,nosuid,nodev)
> sysfs on /sys type sysfs (rw,noexec,nosuid,nodev)
> procbususb on /proc/bus/usb type usbfs (rw)
> udev on /dev type tmpfs (rw,mode=3D0755)
> tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
> devpts on /dev/pts type devpts (rw,noexec,nosuid,gid=3D5,mode=3D620)
> /dev/sda1 on /boot type ext3 (rw,noatime)
> /dev/sda9 on /home type jfs (rw,noatime)
> /dev/sda6 on /opt type jfs (rw,noatime)
> /dev/sda5 on /tmp type jfs (rw,noatime)
> /dev/sda8 on /usr type jfs (rw,noatime)
> /dev/sda7 on /var type jfs (rw,noatime)
> /home/ve on /ve type none (rw,bind,noatime)
> none on /cgroup type cgroup (rw,noatime)
> /home/dwight/workspace on
> /ve/lxc/rootfs/arch64-1/home/dwight/workspace type none (rw,bind)
>
> # I've been using bind mounts like that for a couple months now, no
> problems there
> # When it is in this state where I can't start arch64-1, I can start a
> different container.
>
> $ sudo screen lxc-start -n suzy111-640 /root/boot-init.sh
> [detached]
>
>
> =A0$ cat /proc/cgroups
> #subsys_name =A0 =A0hierarchy =A0 =A0 =A0 num_cgroups =A0 =A0 enabled
> cpuset =A0127 =A0 =A0 8 =A0 =A0 =A0 1
> ns =A0 =A0 =A0127 =A0 =A0 8 =A0 =A0 =A0 1
> cpu =A0 =A0 127 =A0 =A0 8 =A0 =A0 =A0 1
> cpuacct 127 =A0 =A0 8 =A0 =A0 =A0 1
> devices 127 =A0 =A0 8 =A0 =A0 =A0 1
> freezer 127 =A0 =A0 8 =A0 =A0 =A0 1
> net_cls 127 =A0 =A0 8 =A0 =A0 =A0 1
>
>
> $ cat /proc/mounts
> rootfs / rootfs rw 0 0
> none /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
> none /proc proc rw,nosuid,nodev,noexec,relatime 0 0
> udev /dev tmpfs rw,relatime,size=3D10240k,mode=3D755 0 0
> /dev/sda3 / jfs rw,noatime 0 0
> tmpfs /lib/init/rw tmpfs rw,nosuid,relatime,mode=3D755 0 0
> usbfs /proc/bus/usb usbfs rw,nosuid,nodev,noexec,relatime 0 0
> tmpfs /dev/shm tmpfs rw,nosuid,nodev,relatime 0 0
> devpts /dev/pts devpts rw,nosuid,noexec,relatime,mode=3D600,ptmxmode=3D00=
0 0 0
> /dev/sda1 /boot ext3 rw,noatime,errors=3Dcontinue,data=3Dordered 0 0
> /dev/sda9 /home jfs rw,noatime 0 0
> /dev/sda6 /opt jfs rw,noatime 0 0
> /dev/sda5 /tmp jfs rw,noatime 0 0
> /dev/sda8 /usr jfs rw,noatime 0 0
> /dev/sda7 /var jfs rw,noatime 0 0
> /dev/sda9 /ve jfs rw,noatime 0 0
> none /cgroup cgroup rw,noatime,net_cls,freezer,devices,cpuacct,cpu,ns,cpu=
set 0 0
> /dev/sda9 /ve/lxc/rootfs/arch64-1/home/dwight/workspace jfs rw,noatime 0 0
>
>
> # OK, then I go and halt that container.
> =A0$ sudo screen -R
> [screen is terminating]
>
> $ sudo lxc-info --name arch64-1
> 'arch64-1' is STOPPED
> $ sudo lxc-info --name suzy111-640
> 'suzy111-640' is STOPPED
>
> # OK, no running containers
>
> =A0$ cat /proc/cgroups
> #subsys_name =A0 =A0hierarchy =A0 =A0 =A0 num_cgroups =A0 =A0 enabled
> cpuset =A0127 =A0 =A0 7 =A0 =A0 =A0 1
> ns =A0 =A0 =A0127 =A0 =A0 7 =A0 =A0 =A0 1
> cpu =A0 =A0 127 =A0 =A0 7 =A0 =A0 =A0 1
> cpuacct 127 =A0 =A0 7 =A0 =A0 =A0 1
> devices 127 =A0 =A0 7 =A0 =A0 =A0 1
> freezer 127 =A0 =A0 7 =A0 =A0 =A0 1
> net_cls 127 =A0 =A0 7 =A0 =A0 =A0 1
>
> That is all the information I have right now.
> Dwight Schauer
>
