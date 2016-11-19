From: Willy Tarreau <w@1wt.eu>
Subject: Re: [REVIEW][PATCH 0/3] Fixing ptrace vs exec vs userns interactions
Date: Sat, 19 Nov 2016 10:28:04 +0100
Message-ID: <20161119092804.GA13553__39341.5526174524$1479547704$gmane$org@1wt.eu>
References: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com>
	<20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <20161119071700.GA13347@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161119071700.GA13347-K+wRfnb2/UA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Nov 19, 2016 at 08:17:00AM +0100, Willy Tarreau wrote:
> Hi Eric,
> 
> On Thu, Nov 17, 2016 at 11:02:47AM -0600, Eric W. Biederman wrote:
> > 
> > With everyone heading to Kernel Summit and Plumbers I put this set of
> > patches down temporarily.   Now is the time to take it back up and to
> > make certain I am not missing something stupid in this set of patches.
> 
> I couldn't get your patch set to apply to any of the kernels I tried,
> I manually adjusted some parts but the second one has too many rejects.
> What kernel should I apply this to ? Or maybe some preliminary patches
> are needed ?

OK I finally managed to get it to work on top of 4.8.9 (required less changes
than master). I also had to drop the user_ns changes since there's no such
user_ns in mm_struct there.

I could run a test on it, that looks reasonable :

FS:

admin@vm:~$ strace -e trace=fstat,uname,ioctl,open uname
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7f3f9a1663e3, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open(0x7ffd01bbeeb0, O_RDONLY|O_CLOEXEC) = 3
fstat(3, {...})                         = 0
open(0x7ffd01bbee80, O_RDONLY|O_CLOEXEC) = 3
fstat(3, {...})                         = 0
uname({...})                            = 0
fstat(1, {...})                         = 0
ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7ffd01bbf400) = 0

admin@vm:~$ sudo strace -e trace=fstat,uname,ioctl,open uname
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/lib64/tls/x86_64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/lib64/tls/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/lib64/x86_64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
open("/lib64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0555, st_size=101312, ...}) = 0
open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0555, st_size=1479016, ...}) = 0
uname({sys="Linux", node="vm", ...})    = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(4, 64), ...}) = 0
ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, {B9600 opost isig icanon echo ...}) = 0

Network:

admin@vm:~$ strace -e trace=socket,setsockopt,connect /tmp/nc 198.18.3 22
socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
connect(3, {...}, 110)                  = -1 ENOENT (No such file or directory)
socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
connect(3, {...}, 110)                  = -1 ENOENT (No such file or directory)
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, 0x7ffd2c26bdbc, 4) = 0
connect(3, {...}, 16)                   = 0

admin@vm:~$ sudo strace -e trace=socket,setsockopt,connect /tmp/nc 198.18.3 22
socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 3
connect(3, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
connect(3, {sa_family=AF_INET, sin_port=htons(22), sin_addr=inet_addr("198.18.0.3")}, 16) = 0

So in short now we can at least see what syscall fails eventhough we can't
know why. I think it can be an acceptable trade-off.

Thanks,
Willy
