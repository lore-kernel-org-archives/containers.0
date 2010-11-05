From: =?UTF-8?Q?=D0=9F=D1=91=D1=82=D1=80_=D0=92=D0=BE=D0=BB=D0=BA=D0=BE?=
	=?UTF-8?Q?=D0=B2?= <pva-IzMiZDvh46SHXe+LvDLADg@public.gmane.org>
Subject: Re: Need help to debug freeze on kernel side (somehow related to lxc)
Date: Fri, 05 Nov 2010 15:41:04 +0300
Message-ID: <1288960864.2958.17.camel@tablet>
References: <1288355260.4451.121.camel@tablet>
	<20101031003652.GD3566@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ghwyP9xjH/vhhJxYtDup"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101031003652.GD3566-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org
List-Id: containers.vger.kernel.org


--=-ghwyP9xjH/vhhJxYtDup
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id oA5CgBEa018254

Thank you Matt, for your help!

I've changed a bit subject to make it more clear that lxc freezer itself
have no relation (I've did checks you provided, just to be sure). Now
server freezed again and I had some time to gather a bit of information.
Yet still I'm unsure what to do with this freeze.

By freeze I mean that `ps aux` output freeze at some point and I'm
unable to kill it with ctrl+C. strace pointed that it hangs on
reading /proc/3780/cmdline file (environ file is unreadable too). exe
symlink pointed on /usr/sbin/sshd and this time I was unable to ssh,
while previously it was possible (so different processes occur in the
same situation from time to time). This process does not belongs to
cgroup (it's in / cgroup). kill/kill -9 3780 did nothing. I've tried to
gather more proc information from /proc/3780 (in attachment), also there
is kern.log with some sysrq information (memory info, kernel dump and
similar). Could you help me to see what other information could be of
interest here? How to find out where sshd hanged and why? I
thought /proc/3780/syscall could help here, but I failed to find what
this file has inside and numbers there are not addresses of functions in
System.map (or grep was unable to find them). Any suggestions, please?


With best regards,
--
Peter.


=D0=92 =D0=A1=D0=B1=D1=82, 30/10/2010 =D0=B2 17:36 -0700, Matt Helsley =D0=
=BF=D0=B8=D1=88=D0=B5=D1=82:=20
> On Fri, Oct 29, 2010 at 04:27:40PM +0400, =D0=9F=D1=91=D1=82=D1=80 =D0=92=
=D0=BE=D0=BB=D0=BA=D0=BE=D0=B2 wrote:
> > Hi. We are using lxc to separate different services into containers: =
for
> > this discussions we have apache+php, mysql, nginx containers to serve
> > our web application. After upgrade (I think from kernel 2.6.32 into
> > something newer, now we are using 2.6.35, but tried 34 too) we've
> > experience following issue: at some point nginx starts to show us "50=
4
> > Gateway Time-out" error and while it is possible to ssh on server `ps
> > aux` hangs (with no ability to stop it), it is impossible to restart
> > apache container (hangs on stop) and the only way to fix this is to
> > restart server using sysrq or power button. At the same time there is
> > nothing in the logs. I suspect apache starts to eat lots of memory bu=
t
> > oom killer somehow freezes container but I don't have any proves. Wha=
t
>=20
> The OOM killer does not freeze tasks. Now if the tasks were already
> frozen and if the OOM killer selected them then I can see how that
> would be a problem. However, again I doubt that's what's happening here
> for several reasons.
>=20
> 1. lxc doesn't arbitrarily freeze tasks -- unless you were checkpointin=
g
> 	or freezing the task yourself (or using a custom script to do
> 	so), the tasks in the container's cgroup should not be frozen.
>=20
> 2. If the task(s) are frozen then by definition they are not allocating
> 	memory. At best they're pinning the memory they've already
> 	allocated before being frozen. [ The tasks will respond to
> 	kill signals when thawed. ]
>=20
> > could you suggest to debug this issue? What sysrq information could b=
e
> > useful here?
>=20
> [ Cc'ing lxc-users-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org for lxc-specific debugging ideas/advice=
. ]
>=20
> Here's some info on collecting and diagnosing the state of the freezer
> so that hopefully we can eliminate your concerns about it being invovle=
d
> and confirm what I've said above:
>=20
> If you want to figure out if the cgroup freezer is involved at all
> debugging it requires that you be in the "host". Find out which
> process ids are your apache/nginx/etc processes. Then look at their
> cgroups in /proc/<pid>/cgroup. Keep in mind that the "/" in those
> paths isn't the same as "/" -- it's the directory the cgroup
> subsystems are mounted at (see /proc/mounts to figure out where).
> You want the line that says "freezer".
>=20
> Look at the cgroups mount point with the freezer subssystem in the
> cgroup(s) of these processes (it'll say "freezer" in the mount options).
> Confirm that your pids are listed in the cgroup by looking at the tasks
> file.
>=20
> If the freezer.state file of those cgroups contains the word "THAWED"
> then the problem lies elsewhere. If the freezer.state says "FREEZING"
> or "FROZEN" however then you'll want to look at the state of the
> processes. Some or all should be in the "D" state while "FREEZING".
> All should be in "D" state while "FROZEN".
>=20
> "FREEZING" is an intermediate state however so it's not possible to
> determine if there's a bug based purely on the info collected so far.
> The best you can do with "FREEZING" is try and write "FROZEN" into
> freezer.state one or more times and see if it 'eventually' succeeds
> -- say within 10 seconds or 20 attempts, whichever takes longer.
> If it doesn't then you need to strace the processes and see if any
> are stuck in a syscall -- vfork perhaps. You can also try writing
> "THAWED". If it doesn't thaw on the first try then there's a bug.
>=20
> Whenever you write a new state to freezer.state you should read the
> file again to find out whether the state change took place. Some
> transitions are handled lazily and only take place when you ask for
> the state by reading it.
>=20
> That's the way to figure out if the freezer is involved and, if so,
> where it's stuck.
>=20
> Cheers,
> 	-Matt Helsley


--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-cgroup"
Content-Type: text/plain; name="3780-cgroup"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

1:blkio,freezer,devices,memory,cpuacct,cpu,ns,debug,cpuset:/

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-maps"
Content-Type: text/plain; name="3780-maps"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

7d0bc56000-7d0bcca000 r-xp 00000000 fe:00 221                            /usr/sbin/sshd
7d0bec9000-7d0becb000 r--p 00073000 fe:00 221                            /usr/sbin/sshd
7d0becb000-7d0becc000 rw-p 00075000 fe:00 221                            /usr/sbin/sshd
7d0becc000-7d0befd000 rw-p 00000000 00:00 0                              [heap]
312a1beb000-312a1bf6000 r-xp 00000000 08:03 7686                         /lib64/libnss_files-2.12.1.so (deleted)
312a1bf6000-312a1df6000 ---p 0000b000 08:03 7686                         /lib64/libnss_files-2.12.1.so (deleted)
312a1df6000-312a1df7000 r--p 0000b000 08:03 7686                         /lib64/libnss_files-2.12.1.so (deleted)
312a1df7000-312a1df8000 rw-p 0000c000 08:03 7686                         /lib64/libnss_files-2.12.1.so (deleted)
312a1df8000-312a1e02000 r-xp 00000000 08:03 7684                         /lib64/libnss_nis-2.12.1.so (deleted)
312a1e02000-312a2001000 ---p 0000a000 08:03 7684                         /lib64/libnss_nis-2.12.1.so (deleted)
312a2001000-312a2002000 r--p 00009000 08:03 7684                         /lib64/libnss_nis-2.12.1.so (deleted)
312a2002000-312a2003000 rw-p 0000a000 08:03 7684                         /lib64/libnss_nis-2.12.1.so (deleted)
312a2003000-312a2018000 r-xp 00000000 08:03 7687                         /lib64/libnsl-2.12.1.so (deleted)
312a2018000-312a2217000 ---p 00015000 08:03 7687                         /lib64/libnsl-2.12.1.so (deleted)
312a2217000-312a2218000 r--p 00014000 08:03 7687                         /lib64/libnsl-2.12.1.so (deleted)
312a2218000-312a2219000 rw-p 00015000 08:03 7687                         /lib64/libnsl-2.12.1.so (deleted)
312a2219000-312a221b000 rw-p 00000000 00:00 0 
312a221b000-312a2222000 r-xp 00000000 08:03 7591                         /lib64/libnss_compat-2.12.1.so (deleted)
312a2222000-312a2421000 ---p 00007000 08:03 7591                         /lib64/libnss_compat-2.12.1.so (deleted)
312a2421000-312a2422000 r--p 00006000 08:03 7591                         /lib64/libnss_compat-2.12.1.so (deleted)
312a2422000-312a2423000 rw-p 00007000 08:03 7591                         /lib64/libnss_compat-2.12.1.so (deleted)
312a2423000-312a2425000 r-xp 00000000 08:03 7682                         /lib64/libdl-2.12.1.so (deleted)
312a2425000-312a2625000 ---p 00002000 08:03 7682                         /lib64/libdl-2.12.1.so (deleted)
312a2625000-312a2626000 r--p 00002000 08:03 7682                         /lib64/libdl-2.12.1.so (deleted)
312a2626000-312a2627000 rw-p 00003000 08:03 7682                         /lib64/libdl-2.12.1.so (deleted)
312a2627000-312a2784000 r-xp 00000000 08:03 7689                         /lib64/libc-2.12.1.so (deleted)
312a2784000-312a2983000 ---p 0015d000 08:03 7689                         /lib64/libc-2.12.1.so (deleted)
312a2983000-312a2987000 r--p 0015c000 08:03 7689                         /lib64/libc-2.12.1.so (deleted)
312a2987000-312a2988000 rw-p 00160000 08:03 7689                         /lib64/libc-2.12.1.so (deleted)
312a2988000-312a298d000 rw-p 00000000 00:00 0 
312a298d000-312a2995000 r-xp 00000000 08:03 7473                         /lib64/libcrypt-2.12.1.so (deleted)
312a2995000-312a2b94000 ---p 00008000 08:03 7473                         /lib64/libcrypt-2.12.1.so (deleted)
312a2b94000-312a2b95000 r--p 00007000 08:03 7473                         /lib64/libcrypt-2.12.1.so (deleted)
312a2b95000-312a2b96000 rw-p 00008000 08:03 7473                         /lib64/libcrypt-2.12.1.so (deleted)
312a2b96000-312a2bc4000 rw-p 00000000 00:00 0 
312a2bc4000-312a2bc6000 r-xp 00000000 08:03 7483                         /lib64/libutil-2.12.1.so (deleted)
312a2bc6000-312a2dc5000 ---p 00002000 08:03 7483                         /lib64/libutil-2.12.1.so (deleted)
312a2dc5000-312a2dc6000 r--p 00001000 08:03 7483                         /lib64/libutil-2.12.1.so (deleted)
312a2dc6000-312a2dc7000 rw-p 00002000 08:03 7483                         /lib64/libutil-2.12.1.so (deleted)
312a2dc7000-312a2ddf000 r-xp 00000000 08:03 86                           /lib64/libz.so.1.2.5
312a2ddf000-312a2fde000 ---p 00018000 08:03 86                           /lib64/libz.so.1.2.5
312a2fde000-312a2fdf000 r--p 00017000 08:03 86                           /lib64/libz.so.1.2.5
312a2fdf000-312a2fe0000 rw-p 00018000 08:03 86                           /lib64/libz.so.1.2.5
312a2fe0000-312a3194000 r-xp 00000000 fe:00 11819                        /usr/lib64/libcrypto.so.1.0.0
312a3194000-312a3393000 ---p 001b4000 fe:00 11819                        /usr/lib64/libcrypto.so.1.0.0
312a3393000-312a33ad000 r--p 001b3000 fe:00 11819                        /usr/lib64/libcrypto.so.1.0.0
312a33ad000-312a33b7000 rw-p 001cd000 fe:00 11819                        /usr/lib64/libcrypto.so.1.0.0
312a33b7000-312a33ba000 rw-p 00000000 00:00 0 
312a33ba000-312a33c7000 r-xp 00000000 08:03 7172                         /lib64/libpam.so.0.82.3
312a33c7000-312a35c6000 ---p 0000d000 08:03 7172                         /lib64/libpam.so.0.82.3
312a35c6000-312a35c7000 r--p 0000c000 08:03 7172                         /lib64/libpam.so.0.82.3
312a35c7000-312a35c8000 rw-p 0000d000 08:03 7172                         /lib64/libpam.so.0.82.3
312a35c8000-312a35d0000 r-xp 00000000 08:03 5808                         /lib64/libwrap.so.0.7.6
312a35d0000-312a37d0000 ---p 00008000 08:03 5808                         /lib64/libwrap.so.0.7.6
312a37d0000-312a37d1000 r--p 00008000 08:03 5808                         /lib64/libwrap.so.0.7.6
312a37d1000-312a37d2000 rw-p 00009000 08:03 5808                         /lib64/libwrap.so.0.7.6
312a37d2000-312a37f0000 r-xp 00000000 08:03 7485                         /lib64/ld-2.12.1.so (deleted)
312a39dd000-312a39e2000 rw-p 00000000 00:00 0 
312a39ed000-312a39ee000 rw-p 00000000 00:00 0 
312a39ee000-312a39ef000 r-xp 00000000 00:00 0                            [vdso]
312a39ef000-312a39f0000 r--p 0001d000 08:03 7485                         /lib64/ld-2.12.1.so (deleted)
312a39f0000-312a39f1000 rw-p 0001e000 08:03 7485                         /lib64/ld-2.12.1.so (deleted)
312a39f1000-312a39f2000 rw-p 00000000 00:00 0 
38c1aa4b000-38c1aa6c000 rw-p 00000000 00:00 0                            [stack]
ffffffffff600000-ffffffffff601000 r--p 00000000 00:00 0                  [vsyscall]

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-sched"
Content-Type: text/plain; name="3780-sched"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

sshd (3780, #threads: 1)
---------------------------------------------------------
se.exec_start                      :      28127759.101429
se.vruntime                        :      44278157.160161
se.sum_exec_runtime                :             0.025137
se.statistics.wait_start           :             0.000000
se.statistics.sleep_start          :             0.000000
se.statistics.block_start          :      28127759.101429
se.statistics.sleep_max            :             0.000000
se.statistics.block_max            :             0.000000
se.statistics.exec_max             :             0.025137
se.statistics.slice_max            :             0.000000
se.statistics.wait_max             :             0.000000
se.statistics.wait_sum             :             0.000000
se.statistics.wait_count           :                    1
se.statistics.iowait_sum           :             0.000000
se.statistics.iowait_count         :                    0
sched_info.bkl_count               :                    0
se.nr_migrations                   :                    1
se.statistics.nr_migrations_cold   :                    0
se.statistics.nr_failed_migrations_affine:                    0
se.statistics.nr_failed_migrations_running:                    0
se.statistics.nr_failed_migrations_hot:                    0
se.statistics.nr_forced_migrations :                    0
se.statistics.nr_wakeups           :                    0
se.statistics.nr_wakeups_sync      :                    0
se.statistics.nr_wakeups_migrate   :                    0
se.statistics.nr_wakeups_local     :                    0
se.statistics.nr_wakeups_remote    :                    0
se.statistics.nr_wakeups_affine    :                    0
se.statistics.nr_wakeups_affine_attempts:                    0
se.statistics.nr_wakeups_passive   :                    0
se.statistics.nr_wakeups_idle      :                    0
avg_atom                           :             0.025137
avg_per_cpu                        :             0.025137
nr_switches                        :                    1
nr_voluntary_switches              :                    1
nr_involuntary_switches            :                    0
se.load.weight                     :                 1024
policy                             :                    0
prio                               :                  120
clock-delta                        :                   81

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-schedstat"
Content-Type: text/plain; name="3780-schedstat"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

25137 0 1

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-stat"
Content-Type: text/plain; name="3780-stat"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

3780 (sshd) D 6788 6788 6788 0 -1 4202560 2 0 0 0 0 0 0 0 20 0 1 0 2812775 30244864 22 18446744073709551615 537068396544 537068867916 3900277437424 3900277434256 3378569316729 256 0 4096 81925 0 0 0 17 7 0 0 0 0 0

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-statm"
Content-Type: text/plain; name="3780-statm"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

7384 22 0 116 0 146 0

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-status"
Content-Type: text/plain; name="3780-status"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Name:	sshd
State:	D (disk sleep)
Tgid:	3780
Pid:	3780
PPid:	6788
TracerPid:	0
Uid:	0	0	0	0
Gid:	0	0	0	0
FDSize:	64
Groups:	
VmPeak:	   29536 kB
VmSize:	   29536 kB
VmLck:	       0 kB
VmHWM:	      88 kB
VmRSS:	      88 kB
VmData:	     452 kB
VmStk:	     132 kB
VmExe:	     464 kB
VmLib:	    3684 kB
VmPTE:	      60 kB
VmSwap:	     328 kB
Threads:	1
SigQ:	10/31080
SigPnd:	0000000000000100
ShdPnd:	0000000000004100
SigBlk:	0000000000000000
SigIgn:	0000000000001000
SigCgt:	0000000000014005
CapInh:	0000000000000000
CapPrm:	ffffffffffffffff
CapEff:	ffffffffffffffff
CapBnd:	ffffffffffffffff
Cpus_allowed:	ff
Cpus_allowed_list:	0-7
Mems_allowed:	1
Mems_allowed_list:	0
voluntary_ctxt_switches:	1
nonvoluntary_ctxt_switches:	0
PaX:	PeMRs

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="3780-syscall"
Content-Type: text/plain; name="3780-syscall"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

-1 0x38c1aa6a790 0x312a26c8979

--=-ghwyP9xjH/vhhJxYtDup
Content-Disposition: attachment; filename="kern.log"
Content-Type: text/x-log; name="kern.log"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: reg 10: [mem 0xd0000000-0xd7ffffff pref]
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: reg 14: [io  0x4000-0x40ff]
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: reg 18: [mem 0xda300000-0xda30ffff]
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: reg 30: [mem 0x00000000-0x0001ffff pref]
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: supports D1 D2
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0: PCI bridge to [bus 0b-0b] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [io  0x4000-0x4fff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0xda300000-0xda3fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xd7ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000d3fff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000d4000-0x000d7fff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000d8000-0x000dbfff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000dc000-0x000dffff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0x000e0000-0x000e3fff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xfebfffff] (subtractive decode)
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: on NUMA node 0
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD0.PXH0._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD0.PXH1._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMD0.BPD2._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2.BMF3._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11 14 15) *9
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 10 11 14 15)
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11 14 15)
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 *10 11 14 15)
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 14 15) *0, disabled.
Nov  3 14:58:28 euclid kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 4 5 6 7 10 11 14 15) *0, disabled.
Nov  3 14:58:28 euclid kernel: vgaarb: device added: PCI:0000:0b:01.0,decodes=io+mem,owns=io+mem,locks=none
Nov  3 14:58:28 euclid kernel: vgaarb: loaded
Nov  3 14:58:28 euclid kernel: SCSI subsystem initialized
Nov  3 14:58:28 euclid kernel: libata version 3.00 loaded.
Nov  3 14:58:28 euclid kernel: usbcore: registered new interface driver usbfs
Nov  3 14:58:28 euclid kernel: usbcore: registered new interface driver hub
Nov  3 14:58:28 euclid kernel: usbcore: registered new device driver usb
Nov  3 14:58:28 euclid kernel: PCI: Using ACPI for IRQ routing
Nov  3 14:58:28 euclid kernel: PCI: pci_cache_line_size set to 64 bytes
Nov  3 14:58:28 euclid kernel: reserve RAM buffer: 000000000009c400 - 000000000009ffff 
Nov  3 14:58:28 euclid kernel: reserve RAM buffer: 00000000cff60000 - 00000000cfffffff 
Nov  3 14:58:28 euclid kernel: hpet clockevent registered
Nov  3 14:58:28 euclid kernel: HPET: 3 timers in total, 0 timers will be used for per-cpu timer
Nov  3 14:58:28 euclid kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
Nov  3 14:58:28 euclid kernel: hpet0: 3 comparators, 64-bit 14.318180 MHz counter
Nov  3 14:58:28 euclid kernel: Switching to clocksource tsc
Nov  3 14:58:28 euclid kernel: Slow work thread pool: Starting up
Nov  3 14:58:28 euclid kernel: Slow work thread pool: Ready
Nov  3 14:58:28 euclid kernel: FS-Cache: Loaded
Nov  3 14:58:28 euclid kernel: CacheFiles: Loaded
Nov  3 14:58:28 euclid kernel: pnp: PnP ACPI init
Nov  3 14:58:28 euclid kernel: ACPI: bus type pnp registered
Nov  3 14:58:28 euclid kernel: pnp: PnP ACPI: found 13 devices
Nov  3 14:58:28 euclid kernel: ACPI: ACPI bus type pnp unregistered
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x04d0-0x04d1] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x0295-0x0296] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x0ca2-0x0ca3] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x0ca8-0x0caf] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x1000-0x107f] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x1180-0x11bf] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0x0800-0x080f] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [io  0xfe00] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xe0000000-0xefffffff] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xfee00000-0xfee0ffff] could not be reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xfec80000-0xfec80fff] could not be reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xfed1c000-0xfed1ffff] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xfe000000-0xfe01ffff] has been reserved
Nov  3 14:58:28 euclid kernel: system 00:01: [mem 0xfe600000-0xfe6fffff] has been reserved
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: BAR 14: assigned [mem 0xda400000-0xda5fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: BAR 15: assigned [mem 0xda700000-0xda8fffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: BAR 13: assigned [io  0x5000-0x5fff]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.0: PCI bridge to [bus 04-04]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.0:   bridge window [io  disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.0:   bridge window [mem disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.2: PCI bridge to [bus 05-05]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.2:   bridge window [io  disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.2:   bridge window [mem disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.2:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0: PCI bridge to [bus 03-05]
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0:   bridge window [io  disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0:   bridge window [mem disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0: PCI bridge to [bus 06-06]
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0:   bridge window [io  0x2000-0x2fff]
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0:   bridge window [mem 0xda000000-0xda0fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0: PCI bridge to [bus 02-06]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0:   bridge window [io  0x2000-0x2fff]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0:   bridge window [mem 0xda000000-0xda0fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:07:01.0: BAR 6: assigned [mem 0xda120000-0xda13ffff pref]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.3: PCI bridge to [bus 07-07]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.3:   bridge window [io  0x3000-0x3fff]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.3:   bridge window [mem 0xda100000-0xda1fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.3:   bridge window [mem 0xd8000000-0xd9ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0: PCI bridge to [bus 01-07]
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0:   bridge window [io  0x2000-0x3fff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0:   bridge window [mem 0xda000000-0xda2fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0:   bridge window [mem 0xd8000000-0xd9ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0: PCI bridge to [bus 08-08]
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0:   bridge window [io  disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0:   bridge window [mem disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0: PCI bridge to [bus 09-09]
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0:   bridge window [io  disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0:   bridge window [mem disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0:   bridge window [mem pref disabled]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: PCI bridge to [bus 0a-0a]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0:   bridge window [io  0x5000-0x5fff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0:   bridge window [mem 0xda400000-0xda5fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0:   bridge window [mem 0xda700000-0xda8fffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: BAR 6: assigned [mem 0xda320000-0xda33ffff pref]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0: PCI bridge to [bus 0b-0b]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [io  0x4000-0x4fff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0xda300000-0xda3fffff]
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0:   bridge window [mem 0xd0000000-0xd7ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 16 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: pci 0000:00:02.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: pci 0000:02:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:03:00.2: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 18 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Nov  3 14:58:28 euclid kernel: pci 0000:02:02.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:01:00.3: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: pci 0000:00:04.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: pci 0000:00:06.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 17 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Nov  3 14:58:28 euclid kernel: pci 0000:00:1c.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci 0000:00:1e.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:00: resource 12 [mem 0xd0000000-0xfebfffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:01: resource 0 [io  0x2000-0x3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:01: resource 1 [mem 0xda000000-0xda2fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:01: resource 2 [mem 0xd8000000-0xd9ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:02: resource 0 [io  0x2000-0x2fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:02: resource 1 [mem 0xda000000-0xda0fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:06: resource 0 [io  0x2000-0x2fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:06: resource 1 [mem 0xda000000-0xda0fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:07: resource 0 [io  0x3000-0x3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:07: resource 1 [mem 0xda100000-0xda1fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:07: resource 2 [mem 0xd8000000-0xd9ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0a: resource 0 [io  0x5000-0x5fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0a: resource 1 [mem 0xda400000-0xda5fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0a: resource 2 [mem 0xda700000-0xda8fffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 0 [io  0x4000-0x4fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 1 [mem 0xda300000-0xda3fffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 2 [mem 0xd0000000-0xd7ffffff 64bit pref]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 4 [io  0x0000-0x0cf7]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 5 [io  0x0d00-0xffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 6 [mem 0x000a0000-0x000bffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 7 [mem 0x000d0000-0x000d3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 8 [mem 0x000d4000-0x000d7fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 9 [mem 0x000d8000-0x000dbfff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 10 [mem 0x000dc000-0x000dffff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 11 [mem 0x000e0000-0x000e3fff]
Nov  3 14:58:28 euclid kernel: pci_bus 0000:0b: resource 12 [mem 0xd0000000-0xfebfffff]
Nov  3 14:58:28 euclid kernel: NET: Registered protocol family 2
Nov  3 14:58:28 euclid kernel: IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
Nov  3 14:58:28 euclid kernel: TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
Nov  3 14:58:28 euclid kernel: TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
Nov  3 14:58:28 euclid kernel: TCP: Hash tables configured (established 262144 bind 65536)
Nov  3 14:58:28 euclid kernel: TCP reno registered
Nov  3 14:58:28 euclid kernel: UDP hash table entries: 2048 (order: 4, 65536 bytes)
Nov  3 14:58:28 euclid kernel: UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
Nov  3 14:58:28 euclid kernel: NET: Registered protocol family 1
Nov  3 14:58:28 euclid kernel: RPC: Registered udp transport module.
Nov  3 14:58:28 euclid kernel: RPC: Registered tcp transport module.
Nov  3 14:58:28 euclid kernel: RPC: Registered tcp NFSv4.1 backchannel transport module.
Nov  3 14:58:28 euclid kernel: PCI: CLS mismatch (32 != 64), using 64 bytes
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: Boot video device
Nov  3 14:58:28 euclid kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Nov  3 14:58:28 euclid kernel: Placing 64MB software IO TLB between ffff88000a400000 - ffff88000e400000
Nov  3 14:58:28 euclid kernel: software IO TLB at phys 0xa400000 - 0xe400000
Nov  3 14:58:28 euclid kernel: kvm: disabled by bios
Nov  3 14:58:28 euclid kernel: Simple Boot Flag at 0x38 set to 0x1
Nov  3 14:58:28 euclid kernel: microcode: CPU0 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU1 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU2 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU3 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU4 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU5 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU6 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: CPU7 sig=0x10676, pf=0x40, revision=0x60b
Nov  3 14:58:28 euclid kernel: microcode: Microcode Update Driver: v2.00 <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>, Peter Oruba
Nov  3 14:58:28 euclid kernel: Scanning for low memory corruption every 60 seconds
Nov  3 14:58:28 euclid kernel: Intel AES-NI instructions are not detected.
Nov  3 14:58:28 euclid kernel: audit: initializing netlink socket (disabled)
Nov  3 14:58:28 euclid kernel: type=2000 audit(1288785475.785:1): initialized
Nov  3 14:58:28 euclid kernel: HugeTLB registered 2 MB page size, pre-allocated 0 pages
Nov  3 14:58:28 euclid kernel: VFS: Disk quotas dquot_6.5.2
Nov  3 14:58:28 euclid kernel: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Nov  3 14:58:28 euclid kernel: Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
Nov  3 14:58:28 euclid kernel: fuse init (API version 7.14)
Nov  3 14:58:28 euclid kernel: Btrfs loaded
Nov  3 14:58:28 euclid kernel: msgmni has been set to 7770
Nov  3 14:58:28 euclid kernel: alg: No test for cipher_null (cipher_null-generic)
Nov  3 14:58:28 euclid kernel: alg: No test for ecb(cipher_null) (ecb-cipher_null)
Nov  3 14:58:28 euclid kernel: alg: No test for digest_null (digest_null-generic)
Nov  3 14:58:28 euclid kernel: alg: No test for compress_null (compress_null-generic)
Nov  3 14:58:28 euclid kernel: alg: No test for fcrypt (fcrypt-generic)
Nov  3 14:58:28 euclid kernel: alg: No test for stdrng (krng)
Nov  3 14:58:28 euclid kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
Nov  3 14:58:28 euclid kernel: io scheduler noop registered
Nov  3 14:58:28 euclid kernel: io scheduler deadline registered
Nov  3 14:58:28 euclid kernel: io scheduler cfq registered (default)
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:02.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 64 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:02.0: irq 64 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:04.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 65 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:04.0: irq 65 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:06.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 66 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:06.0: irq 66 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:1c.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 67 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:00:1c.0: irq 67 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: pcieport 0000:01:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: pcieport 0000:02:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 68 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:02:00.0: irq 68 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: pcieport 0000:02:02.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 69 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: pcieport 0000:02:02.0: irq 69 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: aer 0000:00:02.0:pcie02: AER service couldn't init device: no _OSC support
Nov  3 14:58:28 euclid kernel: aer 0000:00:04.0:pcie02: AER service couldn't init device: no _OSC support
Nov  3 14:58:28 euclid kernel: aer 0000:00:06.0:pcie02: AER service couldn't init device: no _OSC support
Nov  3 14:58:28 euclid kernel: pci_hotplug: PCI Hot Plug PCI Core version: 0.5
Nov  3 14:58:28 euclid kernel: pciehp: PCI Express Hot Plug Controller Driver version: 0.4
Nov  3 14:58:28 euclid kernel: shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Nov  3 14:58:28 euclid kernel: vesafb: framebuffer at 0xd0000000, mapped to 0xffffc90000c80000, using 3072k, total 16384k
Nov  3 14:58:28 euclid kernel: vesafb: mode is 1024x768x16, linelength=2048, pages=9
Nov  3 14:58:28 euclid kernel: vesafb: scrolling: redraw
Nov  3 14:58:28 euclid kernel: vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
Nov  3 14:58:28 euclid kernel: Console: switching to colour frame buffer device 128x48
Nov  3 14:58:28 euclid kernel: fb0: VESA VGA frame buffer device
Nov  3 14:58:28 euclid kernel: intel_idle: MWAIT substates: 0x2220
Nov  3 14:58:28 euclid kernel: intel_idle: does not run on family 6 model 23
Nov  3 14:58:28 euclid kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/PNP0C0C:00/input/input0
Nov  3 14:58:28 euclid kernel: ACPI: Power Button [PWRB]
Nov  3 14:58:28 euclid kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
Nov  3 14:58:28 euclid kernel: ACPI: Power Button [PWRF]
Nov  3 14:58:28 euclid kernel: ACPI: acpi_idle registered with cpuidle
Nov  3 14:58:28 euclid kernel: Non-volatile memory driver v1.3
Nov  3 14:58:28 euclid kernel: Intel 82802 RNG detected
Nov  3 14:58:28 euclid kernel: Linux agpgart interface v0.103
Nov  3 14:58:28 euclid kernel: ipmi message handler version 39.2
Nov  3 14:58:28 euclid kernel: ipmi device interface
Nov  3 14:58:28 euclid kernel: IPMI System Interface driver.
Nov  3 14:58:28 euclid kernel: ipmi_si: probing via SMBIOS
Nov  3 14:58:28 euclid kernel: ipmi_si: Adding SMBIOS-specified kcs state machine
Nov  3 14:58:28 euclid kernel: ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xca2, slave address 0x20, irq 0
Nov  3 14:58:28 euclid kernel: ipmi_si ipmi_si.0: Found new BMC (man_id: 0x0028c5, prod_id: 0x0004, dev_id: 0x22)
Nov  3 14:58:28 euclid kernel: ipmi_si ipmi_si.0: IPMI kcs interface initialized
Nov  3 14:58:28 euclid kernel: IPMI Watchdog: driver initialized
Nov  3 14:58:28 euclid kernel: Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
Nov  3 14:58:28 euclid kernel: IPMI poweroff: ATCA Detect mfg 0x28C5 prod 0x4
Nov  3 14:58:28 euclid kernel: IPMI poweroff: Found a chassis style poweroff function
Nov  3 14:58:28 euclid kernel: Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
Nov  3 14:58:28 euclid kernel: Hangcheck: Using getrawmonotonic().
Nov  3 14:58:28 euclid kernel: [drm] Initialized drm 1.1.0 20060810
Nov  3 14:58:28 euclid kernel: [drm] radeon defaulting to userspace modesetting.
Nov  3 14:58:28 euclid kernel: pci 0000:0b:01.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Nov  3 14:58:28 euclid kernel: [drm] Initialized radeon 1.33.0 20080528 for 0000:0b:01.0 on minor 0
Nov  3 14:58:28 euclid kernel: Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
Nov  3 14:58:28 euclid kernel: serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Nov  3 14:58:28 euclid kernel: serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Nov  3 14:58:28 euclid kernel: 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Nov  3 14:58:28 euclid kernel: 00:0a: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Nov  3 14:58:28 euclid kernel: brd: module loaded
Nov  3 14:58:28 euclid kernel: loop: module loaded
Nov  3 14:58:28 euclid kernel: Loading iSCSI transport class v2.0-870.
Nov  3 14:58:28 euclid kernel: iscsi: registered transport (tcp)
Nov  3 14:58:28 euclid kernel: 3ware 9000 Storage Controller device driver for Linux v2.26.02.014.
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 24 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: 3w-9xxx 0000:07:01.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
Nov  3 14:58:28 euclid kernel: 3w-9xxx: scsi0: AEN: WARNING (0x04:0x0008): Unclean shutdown detected:unit=0.
Nov  3 14:58:28 euclid kernel: scsi0 : 3ware 9000 Storage Controller
Nov  3 14:58:28 euclid kernel: 3w-9xxx: scsi0: Found a 3ware 9000 Storage Controller at 0xda100000, IRQ: 24.
Nov  3 14:58:28 euclid kernel: 3w-9xxx: scsi0: Firmware FE9X 3.08.00.029, BIOS BE9X 3.10.00.003, Ports: 4.
Nov  3 14:58:28 euclid kernel: scsi 0:0:0:0: Direct-Access     AMCC     9550SXU-4L DISK  3.08 PQ: 0 ANSI: 5
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: [sda] 976541696 512-byte logical blocks: (499 GB/465 GiB)
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: Attached scsi generic sg0 type 0
Nov  3 14:58:28 euclid kernel: SCSI Media Changer driver v0.25 
Nov  3 14:58:28 euclid kernel: ata_piix 0000:00:1f.1: version 2.13
Nov  3 14:58:28 euclid kernel: ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Nov  3 14:58:28 euclid kernel: ata_piix 0000:00:1f.1: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: scsi1 : ata_piix
Nov  3 14:58:28 euclid kernel: scsi2 : ata_piix
Nov  3 14:58:28 euclid kernel: ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1860 irq 14
Nov  3 14:58:28 euclid kernel: ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1868 irq 15
Nov  3 14:58:28 euclid kernel: ata2: port disabled. ignoring.
Nov  3 14:58:28 euclid kernel: e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k4
Nov  3 14:58:28 euclid kernel: e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 70 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: irq 70 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:30:48:32:e1:80
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: eth0: Intel(R) PRO/1000 Network Connection
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: eth0: MAC: 5, PHY: 5, PBA No: ffffff-0ff
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 19 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 71 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: irq 71 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:30:48:32:e1:81
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: eth1: MAC: 5, PHY: 5, PBA No: ffffff-0ff
Nov  3 14:58:28 euclid kernel: PPP generic driver version 2.4.2
Nov  3 14:58:28 euclid kernel: tun: Universal TUN/TAP device driver, 1.6
Nov  3 14:58:28 euclid kernel: tun: (C) 1999-2004 Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Nov  3 14:58:28 euclid kernel: I2O subsystem v1.325
Nov  3 14:58:28 euclid kernel: i2o: max drivers = 8
Nov  3 14:58:28 euclid kernel: I2O Configuration OSM v1.323
Nov  3 14:58:28 euclid kernel: I2O Bus Adapter OSM v1.317
Nov  3 14:58:28 euclid kernel: I2O Block Device OSM v1.325
Nov  3 14:58:28 euclid kernel: I2O SCSI Peripheral OSM v1.316
Nov  3 14:58:28 euclid kernel: I2O ProcFS OSM v1.316
Nov  3 14:58:28 euclid kernel: Fusion MPT base driver 3.04.15
Nov  3 14:58:28 euclid kernel: Copyright (c) 1999-2008 LSI Corporation
Nov  3 14:58:28 euclid kernel: Fusion MPT SPI Host driver 3.04.15
Nov  3 14:58:28 euclid kernel: Fusion MPT misc device (ioctl) driver 3.04.15
Nov  3 14:58:28 euclid kernel: mptctl: Registered with Fusion MPT base driver
Nov  3 14:58:28 euclid kernel: mptctl: /dev/mptctl @ (major,minor=10,220)
Nov  3 14:58:28 euclid kernel: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
Nov  3 14:58:28 euclid kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
Nov  3 14:58:28 euclid kernel: serio: i8042 AUX port at 0x60,0x64 irq 12
Nov  3 14:58:28 euclid kernel: mice: PS/2 mouse device common for all mice
Nov  3 14:58:28 euclid kernel: rtc_cmos 00:04: RTC can wake from S4
Nov  3 14:58:28 euclid kernel: rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
Nov  3 14:58:28 euclid kernel: rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
Nov  3 14:58:28 euclid kernel: i2c /dev entries driver
Nov  3 14:58:28 euclid kernel: i801_smbus 0000:00:1f.3: PCI INT B -> GSI 19 (level, low) -> IRQ 19
Nov  3 14:58:28 euclid kernel: ata1.01: ATAPI: MATSHITADVD-ROM SR-8178, PZ16, max UDMA/66
Nov  3 14:58:28 euclid kernel: ata1.01: limited to UDMA/33 due to 40-wire cable
Nov  3 14:58:28 euclid kernel: ata1.01: configured for UDMA/33
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: [sda] Write Protect is off
Nov  3 14:58:28 euclid kernel: iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
Nov  3 14:58:28 euclid kernel: iTCO_wdt: Found a 631xESB/632xESB TCO device (Version=2, TCOBASE=0x1060)
Nov  3 14:58:28 euclid kernel: iTCO_wdt: cannot register miscdev on minor=130 (err=-16)
Nov  3 14:58:28 euclid kernel: iTCO_wdt: probe of iTCO_wdt failed with error -16
Nov  3 14:58:28 euclid kernel: iTCO_vendor_support: vendor-support=0
Nov  3 14:58:28 euclid kernel: device-mapper: uevent: version 1.0.3
Nov  3 14:58:28 euclid kernel: device-mapper: ioctl: 4.17.0-ioctl (2010-03-05) initialised: dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Nov  3 14:58:28 euclid kernel: device-mapper: multipath: version 1.1.1 loaded
Nov  3 14:58:28 euclid kernel: device-mapper: multipath round-robin: version 1.0.0 loaded
Nov  3 14:58:28 euclid kernel: device-mapper: multipath queue-length: version 0.1.0 loaded
Nov  3 14:58:28 euclid kernel: device-mapper: multipath service-time: version 0.2.0 loaded
Nov  3 14:58:28 euclid kernel: device-mapper: dm-log-userspace: version 1.0.0 loaded
Nov  3 14:58:28 euclid kernel: EDAC MC: Ver: 2.1.0 Oct 17 2010
Nov  3 14:58:28 euclid kernel: EDAC MC0: Giving out device to 'i5000_edac.c' 'I5000': DEV 0000:00:10.0
Nov  3 14:58:28 euclid kernel: EDAC PCI0: Giving out device to module 'i5000_edac' controller 'EDAC PCI controller': DEV '0000:00:10.0' (POLLED)
Nov  3 14:58:28 euclid kernel: cpuidle: using governor ladder
Nov  3 14:58:28 euclid kernel: cpuidle: using governor menu
Nov  3 14:58:28 euclid kernel: No iBFT detected.
Nov  3 14:58:28 euclid kernel: ioatdma: Intel(R) QuickData Technology Driver 4.00
Nov  3 14:58:28 euclid kernel: ioatdma 0000:00:08.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Nov  3 14:58:28 euclid kernel: ioatdma 0000:00:08.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: [sda] Mode Sense: 23 00 00 00
Nov  3 14:58:28 euclid kernel: alloc irq_desc for 72 on node -1
Nov  3 14:58:28 euclid kernel: alloc kstat_irqs on node -1
Nov  3 14:58:28 euclid kernel: ioatdma 0000:00:08.0: irq 72 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: [sda] Write cache: enabled, read cache: disabled, doesn't support DPO or FUA
Nov  3 14:58:28 euclid kernel: Netfilter messages via NETLINK v0.30.
Nov  3 14:58:28 euclid kernel: nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
Nov  3 14:58:28 euclid kernel: CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
Nov  3 14:58:28 euclid kernel: nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
Nov  3 14:58:28 euclid kernel: sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
Nov  3 14:58:28 euclid kernel: ctnetlink v0.93: registering with nfnetlink.
Nov  3 14:58:28 euclid kernel: NF_TPROXY: Transparent proxy support initialized, version 4.1.0
Nov  3 14:58:28 euclid kernel: NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
Nov  3 14:58:28 euclid kernel: xt_time: kernel timezone is -0000
Nov  3 14:58:28 euclid kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Nov  3 14:58:28 euclid kernel: ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
Nov  3 14:58:28 euclid kernel: arp_tables: (C) 2002 David S. Miller
Nov  3 14:58:28 euclid kernel: TCP cubic registered
Nov  3 14:58:28 euclid kernel: sda:
Nov  3 14:58:28 euclid kernel: NET: Registered protocol family 10
Nov  3 14:58:28 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:58:28 euclid kernel: ip6_tables: (C) 2000-2006 Netfilter Core Team
Nov  3 14:58:28 euclid kernel: NET: Registered protocol family 17
Nov  3 14:58:28 euclid kernel: Bridge firewalling registered
Nov  3 14:58:28 euclid kernel: 802.1Q VLAN Support v1.8 Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Nov  3 14:58:28 euclid kernel: All bugs added by David S. Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Nov  3 14:58:28 euclid kernel: registered taskstats version 1
Nov  3 14:58:28 euclid kernel: rtc_cmos 00:04: setting system clock to 2010-11-03 11:58:10 UTC (1288785490)
Nov  3 14:58:28 euclid kernel: BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
Nov  3 14:58:28 euclid kernel: sda1 sda2 sda3 sda4
Nov  3 14:58:28 euclid kernel: sd 0:0:0:0: [sda] Attached SCSI disk
Nov  3 14:58:28 euclid kernel: scsi 1:0:1:0: CD-ROM            MATSHITA DVD-ROM SR-8178  PZ16 PQ: 0 ANSI: 5
Nov  3 14:58:28 euclid kernel: sr0: scsi3-mmc drive: 61x/61x cd/rw xa/form2 cdda tray
Nov  3 14:58:28 euclid kernel: Uniform CD-ROM driver Revision: 3.20
Nov  3 14:58:28 euclid kernel: sr 1:0:1:0: Attached scsi CD-ROM sr0
Nov  3 14:58:28 euclid kernel: sr 1:0:1:0: Attached scsi generic sg1 type 5
Nov  3 14:58:28 euclid kernel: Freeing unused kernel memory: 1564k freed
Nov  3 14:58:28 euclid kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: EHCI Host Controller
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: debug port 1
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: irq 17, io mem 0xda600000
Nov  3 14:58:28 euclid kernel: ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
Nov  3 14:58:28 euclid kernel: hub 1-0:1.0: USB hub found
Nov  3 14:58:28 euclid kernel: hub 1-0:1.0: 6 ports detected
Nov  3 14:58:28 euclid kernel: Initializing USB Mass Storage driver...
Nov  3 14:58:28 euclid kernel: usbcore: registered new interface driver usb-storage
Nov  3 14:58:28 euclid kernel: USB Mass Storage support registered.
Nov  3 14:58:28 euclid kernel: uhci_hcd: USB Universal Host Controller Interface driver
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.0: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.0: UHCI Host Controller
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.0: irq 17, io base 0x00001800
Nov  3 14:58:28 euclid kernel: hub 2-0:1.0: USB hub found
Nov  3 14:58:28 euclid kernel: hub 2-0:1.0: 2 ports detected
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.1: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.1: UHCI Host Controller
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.1: irq 19, io base 0x00001820
Nov  3 14:58:28 euclid kernel: hub 3-0:1.0: USB hub found
Nov  3 14:58:28 euclid kernel: hub 3-0:1.0: 2 ports detected
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.2: setting latency timer to 64
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.2: UHCI Host Controller
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
Nov  3 14:58:28 euclid kernel: uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001840
Nov  3 14:58:28 euclid kernel: hub 4-0:1.0: USB hub found
Nov  3 14:58:28 euclid kernel: hub 4-0:1.0: 2 ports detected
Nov  3 14:58:28 euclid kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
Nov  3 14:58:28 euclid kernel: usbcore: registered new interface driver hiddev
Nov  3 14:58:28 euclid kernel: usbcore: registered new interface driver usbhid
Nov  3 14:58:28 euclid kernel: usbhid: USB HID core driver
Nov  3 14:58:28 euclid kernel: sl811: driver sl811-hcd, 19 May 2005
Nov  3 14:58:28 euclid kernel: usb 1-6: new high speed USB device using ehci_hcd and address 2
Nov  3 14:58:28 euclid kernel: input: Peppercon AG Multidevice as /devices/pci0000:00/0000:00:1d.7/usb1/1-6/1-6:1.0/input/input2
Nov  3 14:58:28 euclid kernel: generic-usb 0003:14DD:0002.0001: input: USB HID v1.01 Mouse [Peppercon AG Multidevice] on usb-0000:00:1d.7-6/input0
Nov  3 14:58:28 euclid kernel: input: Peppercon AG Multidevice as /devices/pci0000:00/0000:00:1d.7/usb1/1-6/1-6:1.1/input/input3
Nov  3 14:58:28 euclid kernel: generic-usb 0003:14DD:0002.0002: input: USB HID v1.01 Keyboard [Peppercon AG Multidevice] on usb-0000:00:1d.7-6/input1
Nov  3 14:58:28 euclid kernel: REISERFS (device sda3): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device sda3): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device sda3): journal params: device sda3, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device sda3): checking transaction log (sda3)
Nov  3 14:58:28 euclid kernel: REISERFS (device sda3): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: udev[4001]: starting version 163
Nov  3 14:58:28 euclid kernel: input: PC Speaker as /devices/platform/pcspkr/input/input4
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-4): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-4): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-4): journal params: device dm-4, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-4): checking transaction log (dm-4)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-4): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-3): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-3): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-3): journal params: device dm-3, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-3): checking transaction log (dm-3)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-3): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-1): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-1): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-1): journal params: device dm-1, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-1): checking transaction log (dm-1)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-1): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-2): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-2): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-2): journal params: device dm-2, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-2): checking transaction log (dm-2)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-2): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-0): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-0): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-0): journal params: device dm-0, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-0): checking transaction log (dm-0)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-0): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-6): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-6): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-6): journal params: device dm-6, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-6): checking transaction log (dm-6)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-6): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-5): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-5): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-5): journal params: device dm-5, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-5): checking transaction log (dm-5)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-5): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-8): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-8): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-8): journal params: device dm-8, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-8): checking transaction log (dm-8)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-8): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): journal params: device dm-7, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): checking transaction log (dm-7)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): replayed 1 transactions in 0 seconds
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3369791 4602816 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3369791 4601916 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3369791 4601834 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3369791 4600504 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3369791 4600474 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3198574 3447944 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3198574 3447480 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3198574 3447425 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3286832 3409713 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3286832 3409712 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3286832 3409711 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3328313 3367491 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3328313 3363878 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3328313 3363875 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3535706 3363791 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3535706 3363786 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3535706 3344178 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3120917 3342624 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3120917 3342623 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3120917 3342622 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3074041 3342613 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3074041 3342610 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3074041 3342609 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3203874 3342507 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3203874 3342506 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): Removing [3203874 3342504 0x0 SD]..done
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-7): There were 26 uncompleted unlinks/truncates. Completed
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-10): found reiserfs format "3.6" with standard journal
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-10): using ordered data mode
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-10): journal params: device dm-10, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-10): checking transaction log (dm-10)
Nov  3 14:58:28 euclid kernel: REISERFS (device dm-10): Using r5 hash to sort names
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: irq 70 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: irq 70 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: irq 71 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.1: irq 71 for MSI/MSI-X
Nov  3 14:58:28 euclid kernel: ADDRCONF(NETDEV_UP): eth1: link is not ready
Nov  3 14:58:28 euclid kernel: Adding 7999996k swap on /dev/sda2.  Priority:-1 extents:1 across:7999996k 
Nov  3 14:58:28 euclid kernel: e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
Nov  3 14:58:28 euclid kernel: e1000e 0000:06:00.0: eth0: 10/100 speed: disabling TSO
Nov  3 14:58:28 euclid kernel: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Nov  3 14:58:28 euclid kernel: IPv6 over IPv4 tunneling driver
Nov  3 14:58:28 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:58:28 euclid kernel: six0: Disabled Privacy Extensions
Nov  3 14:58:59 euclid kernel: w83627hf: Found W83627HF chip at 0x290
Nov  3 14:58:59 euclid kernel: w83793 0-002f: Registered watchdog chardev major 10, minor: 212
Nov  3 14:58:59 euclid kernel: device apache entered promiscuous mode
Nov  3 14:58:59 euclid kernel: ADDRCONF(NETDEV_UP): apache: link is not ready
Nov  3 14:58:59 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:58:59 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:58:59 euclid kernel: ADDRCONF(NETDEV_CHANGE): apache: link becomes ready
Nov  3 14:58:59 euclid kernel: br0: port 1(apache) entering learning state
Nov  3 14:58:59 euclid kernel: br0: port 1(apache) entering learning state
Nov  3 14:59:00 euclid kernel: device jabber entered promiscuous mode
Nov  3 14:59:00 euclid kernel: ADDRCONF(NETDEV_UP): jabber: link is not ready
Nov  3 14:59:00 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:00 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:00 euclid kernel: ADDRCONF(NETDEV_CHANGE): jabber: link becomes ready
Nov  3 14:59:00 euclid kernel: br0: port 2(jabber) entering learning state
Nov  3 14:59:00 euclid kernel: br0: port 2(jabber) entering learning state
Nov  3 14:59:01 euclid kernel: device ldap entered promiscuous mode
Nov  3 14:59:01 euclid kernel: ADDRCONF(NETDEV_UP): ldap: link is not ready
Nov  3 14:59:01 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:01 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:01 euclid kernel: ADDRCONF(NETDEV_CHANGE): ldap: link becomes ready
Nov  3 14:59:01 euclid kernel: br0: port 3(ldap) entering learning state
Nov  3 14:59:01 euclid kernel: br0: port 3(ldap) entering learning state
Nov  3 14:59:02 euclid kernel: device mail entered promiscuous mode
Nov  3 14:59:02 euclid kernel: ADDRCONF(NETDEV_UP): mail: link is not ready
Nov  3 14:59:02 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:02 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:02 euclid kernel: ADDRCONF(NETDEV_CHANGE): mail: link becomes ready
Nov  3 14:59:02 euclid kernel: br0: port 4(mail) entering learning state
Nov  3 14:59:02 euclid kernel: br0: port 4(mail) entering learning state
Nov  3 14:59:03 euclid kernel: device mysql entered promiscuous mode
Nov  3 14:59:03 euclid kernel: ADDRCONF(NETDEV_UP): mysql: link is not ready
Nov  3 14:59:03 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:03 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:03 euclid kernel: ADDRCONF(NETDEV_CHANGE): mysql: link becomes ready
Nov  3 14:59:03 euclid kernel: br0: port 5(mysql) entering learning state
Nov  3 14:59:03 euclid kernel: br0: port 5(mysql) entering learning state
Nov  3 14:59:04 euclid kernel: device nginx entered promiscuous mode
Nov  3 14:59:04 euclid kernel: ADDRCONF(NETDEV_UP): nginx: link is not ready
Nov  3 14:59:04 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:04 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:04 euclid kernel: ADDRCONF(NETDEV_CHANGE): nginx: link becomes ready
Nov  3 14:59:04 euclid kernel: br0: port 6(nginx) entering learning state
Nov  3 14:59:04 euclid kernel: br0: port 6(nginx) entering learning state
Nov  3 14:59:05 euclid kernel: device ns entered promiscuous mode
Nov  3 14:59:05 euclid kernel: ADDRCONF(NETDEV_UP): ns: link is not ready
Nov  3 14:59:05 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:05 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:05 euclid kernel: ADDRCONF(NETDEV_CHANGE): ns: link becomes ready
Nov  3 14:59:05 euclid kernel: br0: port 7(ns) entering learning state
Nov  3 14:59:05 euclid kernel: br0: port 7(ns) entering learning state
Nov  3 14:59:06 euclid kernel: device postgres entered promiscuous mode
Nov  3 14:59:06 euclid kernel: ADDRCONF(NETDEV_UP): postgres: link is not ready
Nov  3 14:59:06 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:06 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:06 euclid kernel: ADDRCONF(NETDEV_CHANGE): postgres: link becomes ready
Nov  3 14:59:06 euclid kernel: br0: port 8(postgres) entering learning state
Nov  3 14:59:06 euclid kernel: br0: port 8(postgres) entering learning state
Nov  3 14:59:08 euclid kernel: device redmine entered promiscuous mode
Nov  3 14:59:08 euclid kernel: ADDRCONF(NETDEV_UP): redmine: link is not ready
Nov  3 14:59:08 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:08 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:08 euclid kernel: ADDRCONF(NETDEV_CHANGE): redmine: link becomes ready
Nov  3 14:59:08 euclid kernel: br0: port 9(redmine) entering learning state
Nov  3 14:59:08 euclid kernel: br0: port 9(redmine) entering learning state
Nov  3 14:59:09 euclid kernel: device transifex entered promiscuous mode
Nov  3 14:59:09 euclid kernel: ADDRCONF(NETDEV_UP): transifex: link is not ready
Nov  3 14:59:09 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:09 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:09 euclid kernel: ADDRCONF(NETDEV_CHANGE): transifex: link becomes ready
Nov  3 14:59:09 euclid kernel: br0: port 10(transifex) entering learning state
Nov  3 14:59:09 euclid kernel: br0: port 10(transifex) entering learning state
Nov  3 14:59:10 euclid kernel: device vcs entered promiscuous mode
Nov  3 14:59:10 euclid kernel: ADDRCONF(NETDEV_UP): vcs: link is not ready
Nov  3 14:59:10 euclid kernel: lo: Disabled Privacy Extensions
Nov  3 14:59:10 euclid kernel: sit0: Disabled Privacy Extensions
Nov  3 14:59:10 euclid kernel: ADDRCONF(NETDEV_CHANGE): vcs: link becomes ready
Nov  3 14:59:10 euclid kernel: br0: port 11(vcs) entering learning state
Nov  3 14:59:10 euclid kernel: br0: port 11(vcs) entering learning state
Nov  3 14:59:12 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x000C): Initialize started:unit=0.
Nov  3 14:59:14 euclid kernel: br0: port 1(apache) entering forwarding state
Nov  3 14:59:15 euclid kernel: br0: port 2(jabber) entering forwarding state
Nov  3 14:59:16 euclid kernel: br0: port 3(ldap) entering forwarding state
Nov  3 14:59:22 euclid kernel: br0: port 4(mail) entering forwarding state
Nov  3 14:59:22 euclid kernel: br0: port 5(mysql) entering forwarding state
Nov  3 14:59:22 euclid kernel: br0: port 6(nginx) entering forwarding state
Nov  3 14:59:22 euclid kernel: br0: port 7(ns) entering forwarding state
Nov  3 14:59:22 euclid kernel: br0: port 8(postgres) entering forwarding state
Nov  3 14:59:23 euclid kernel: br0: port 9(redmine) entering forwarding state
Nov  3 14:59:24 euclid kernel: br0: port 10(transifex) entering forwarding state
Nov  3 14:59:25 euclid kernel: br0: port 11(vcs) entering forwarding state
Nov  3 17:55:01 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x0007): Initialize completed:unit=0.
Nov  3 17:56:12 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
Nov  3 20:53:41 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
Nov  4 00:06:12 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
Nov  4 03:25:31 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
Nov  5 00:06:14 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
Nov  5 03:19:47 euclid kernel: 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
Nov  5 14:22:40 euclid kernel: SysRq : Nice All RT Tasks
Nov  5 14:22:40 euclid kernel: SysRq : Nice All RT Tasks
Nov  5 14:23:25 euclid kernel: SysRq : Emergency Sync
Nov  5 14:23:25 euclid kernel: Emergency Sync complete
Nov  5 14:24:15 euclid kernel: SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) 
Nov  5 14:24:15 euclid kernel: SysRq : Show Memory
Nov  5 14:24:15 euclid kernel: Mem-Info:
Nov  5 14:24:15 euclid kernel: DMA per-cpu:
Nov  5 14:24:15 euclid kernel: CPU    0: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    1: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    2: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    3: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    4: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    5: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    6: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: CPU    7: hi:    0, btch:   1 usd:   0
Nov  5 14:24:15 euclid kernel: DMA32 per-cpu:
Nov  5 14:24:15 euclid kernel: CPU    0: hi:  186, btch:  31 usd: 176
Nov  5 14:24:15 euclid kernel: CPU    1: hi:  186, btch:  31 usd:  40
Nov  5 14:24:15 euclid kernel: CPU    2: hi:  186, btch:  31 usd: 167
Nov  5 14:24:15 euclid kernel: CPU    3: hi:  186, btch:  31 usd:  66
Nov  5 14:24:15 euclid kernel: CPU    4: hi:  186, btch:  31 usd:  63
Nov  5 14:24:15 euclid kernel: CPU    5: hi:  186, btch:  31 usd:  61
Nov  5 14:24:15 euclid kernel: CPU    6: hi:  186, btch:  31 usd: 185
Nov  5 14:24:15 euclid kernel: CPU    7: hi:  186, btch:  31 usd: 117
Nov  5 14:24:15 euclid kernel: Normal per-cpu:
Nov  5 14:24:15 euclid kernel: CPU    0: hi:  186, btch:  31 usd: 160
Nov  5 14:24:15 euclid kernel: CPU    1: hi:  186, btch:  31 usd: 164
Nov  5 14:24:15 euclid kernel: CPU    2: hi:  186, btch:  31 usd:  69
Nov  5 14:24:15 euclid kernel: CPU    3: hi:  186, btch:  31 usd: 161
Nov  5 14:24:15 euclid kernel: CPU    4: hi:  186, btch:  31 usd: 173
Nov  5 14:24:15 euclid kernel: CPU    5: hi:  186, btch:  31 usd:  35
Nov  5 14:24:15 euclid kernel: CPU    6: hi:  186, btch:  31 usd: 109
Nov  5 14:24:15 euclid kernel: CPU    7: hi:  186, btch:  31 usd:  61
Nov  5 14:24:15 euclid kernel: active_anon:245676 inactive_anon:117443 isolated_anon:0
Nov  5 14:24:15 euclid kernel: active_file:274280 inactive_file:102722 isolated_file:0
Nov  5 14:24:15 euclid kernel: unevictable:0 dirty:27 writeback:0 unstable:0
Nov  5 14:24:15 euclid kernel: free:173788 slab_reclaimable:34409 slab_unreclaimable:9998
Nov  5 14:24:15 euclid kernel: mapped:16452 shmem:225 pagetables:5536 bounce:0
Nov  5 14:24:15 euclid kernel: DMA free:15824kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15696kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Nov  5 14:24:15 euclid kernel: lowmem_reserve[]: 0 3255 4013 4013
Nov  5 14:24:15 euclid kernel: DMA32 free:676244kB min:6564kB low:8204kB high:9844kB active_anon:751628kB inactive_anon:324492kB active_file:930760kB inactive_file:342164kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3333728kB mlocked:0kB dirty:64kB writeback:0kB mapped:32488kB shmem:36kB slab_reclaimable:119164kB slab_unreclaimable:12208kB kernel_stack:1360kB pagetables:11652kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Nov  5 14:24:15 euclid kernel: lowmem_reserve[]: 0 0 757 757
Nov  5 14:24:15 euclid kernel: Normal free:3084kB min:1524kB low:1904kB high:2284kB active_anon:231076kB inactive_anon:145280kB active_file:166360kB inactive_file:68724kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:775680kB mlocked:0kB dirty:44kB writeback:0kB mapped:33320kB shmem:864kB slab_reclaimable:18472kB slab_unreclaimable:27752kB kernel_stack:2992kB pagetables:10492kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Nov  5 14:24:15 euclid kernel: lowmem_reserve[]: 0 0 0 0
Nov  5 14:24:16 euclid kernel: DMA: 0*4kB 0*8kB 1*16kB 2*32kB 2*64kB 2*128kB 2*256kB 1*512kB 0*1024kB 1*2048kB 3*4096kB = 15824kB
Nov  5 14:24:16 euclid kernel: DMA32: 42593*4kB 31100*8kB 11357*16kB 1609*32kB 267*64kB 37*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 676244kB
Nov  5 14:24:16 euclid kernel: Normal: 709*4kB 31*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3084kB
Nov  5 14:24:16 euclid kernel: 376403 total pagecache pages
Nov  5 14:24:16 euclid kernel: 4433 pages in swap cache
Nov  5 14:24:16 euclid kernel: Swap cache stats: add 23693, delete 19260, find 1618/2206
Nov  5 14:24:16 euclid kernel: Free swap  = 7927996kB
Nov  5 14:24:16 euclid kernel: Total swap = 7999996kB
Nov  5 14:24:16 euclid kernel: 1048560 pages RAM
Nov  5 14:24:16 euclid kernel: 53608 pages reserved
Nov  5 14:24:16 euclid kernel: 276057 pages shared
Nov  5 14:24:16 euclid kernel: 642087 pages non-shared
Nov  5 14:26:36 euclid kernel: SysRq : Emergency Sync
Nov  5 14:26:36 euclid kernel: Emergency Sync complete
Nov  5 14:26:44 euclid kernel: SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) 
Nov  5 14:27:17 euclid kernel: SysRq : Show Regs
Nov  5 14:27:17 euclid kernel: CPU 5 
Nov  5 14:27:17 euclid kernel: Modules linked in: w83793 w83627hf hwmon_vid sit tunnel4 pcspkr scsi_wait_scan sl811_hcd usbhid ohci_hcd uhci_hcd usb_storage ehci_hcd
Nov  5 14:27:17 euclid kernel: 
Nov  5 14:27:17 euclid kernel: Pid: 0, comm: swapper Not tainted 2.6.35-hardened-r3 #2 X7DB8/X7DB8
Nov  5 14:27:17 euclid kernel: RIP: 0010:[<ffffffff81036b97>]  [<ffffffff81036b97>] mwait_idle+0x57/0x80
Nov  5 14:27:17 euclid kernel: RSP: 0018:ffff88012fcd5f00  EFLAGS: 00000246
Nov  5 14:27:17 euclid kernel: RAX: 0000000000000000 RBX: ffffffff85d63700 RCX: 0000000000000000
Nov  5 14:27:17 euclid kernel: RDX: 0000000000000000 RSI: ffff88012fcd5fd8 RDI: ffffffff85f90408
Nov  5 14:27:17 euclid kernel: RBP: ffffffff8174d50e R08: 0000000000000000 R09: 0000000000000005
Nov  5 14:27:17 euclid kernel: R10: 00009b7d13f19074 R11: 000000010a2c0593 R12: ffff880006348320
Nov  5 14:27:17 euclid kernel: R13: 0000000000000008 R14: 0000000000000086 R15: ffff88012ad63900
Nov  5 14:27:17 euclid kernel: FS:  0000000000000000(0000) GS:ffff880006340000(0000) knlGS:0000000000000000
Nov  5 14:27:17 euclid kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov  5 14:27:17 euclid kernel: CR2: ffffffffff600400 CR3: 0000000001a0b000 CR4: 00000000000006f0
Nov  5 14:27:17 euclid kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov  5 14:27:17 euclid kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov  5 14:27:17 euclid kernel: Process swapper (pid: 0, threadinfo ffff88012fcd4000, task ffff88012fcbaf80)
Nov  5 14:27:17 euclid kernel: Stack:
Nov  5 14:27:17 euclid kernel: ffffffff8102cee4 0000000000000000 77569a5a89bd7429 0000000000000000
Nov  5 14:27:17 euclid kernel: <0> 0000000000000005 0000000000000000 ffffffff81745ace 0000000000000000
Nov  5 14:27:17 euclid kernel: <0> 10dde67e4204b20f 0000000000000000 0000000000000000 0000000000000000
Nov  5 14:27:17 euclid kernel: Call Trace:
Nov  5 14:27:17 euclid kernel: [<ffffffff8102cee4>] ? cpu_idle+0xa4/0x100
Nov  5 14:27:17 euclid kernel: [<ffffffff81745ace>] ? start_secondary+0x200/0x204
Nov  5 14:27:17 euclid kernel: Code: 48 8b 34 25 c8 46 00 00 31 d2 48 8d 86 38 e0 ff ff 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 1c 31 c0 fb 0f 01 c9 <c3> 0f 1f 84 00 00 00 00 00 48 81 ea d8 1f 00 00 0f ae 7a 10 eb 
Nov  5 14:27:17 euclid kernel: Call Trace:
Nov  5 14:27:17 euclid kernel: [<ffffffff8102cee4>] ? cpu_idle+0xa4/0x100
Nov  5 14:27:17 euclid kernel: [<ffffffff81745ace>] ? start_secondary+0x200/0x204
Nov  5 14:27:17 euclid kernel: 
Nov  5 14:27:17 euclid kernel: CPU#5: ctrl:       ffffffffffffffff
Nov  5 14:27:17 euclid kernel: CPU#5: status:     0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5: overflow:   0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5: fixed:      0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5: pebs:       0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5: active:     0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5:   gen-PMC0 ctrl:  0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5:   gen-PMC0 count: 0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5:   gen-PMC0 left:  0000000000000000
Nov  5 14:27:17 euclid kernel: CPU#5:   gen-PMC1 ctrl:  0000000000000000
Nov  5 14:27:18 euclid kernel: CPU#5:   gen-PMC1 count: 0000000000000000
Nov  5 14:27:18 euclid kernel: CPU#5:   gen-PMC1 left:  0000000000000000
Nov  5 14:27:18 euclid kernel: CPU#5: fixed-PMC0 count: 0000000000000000
Nov  5 14:27:18 euclid kernel: CPU#5: fixed-PMC1 count: 0000000000000000
Nov  5 14:27:18 euclid kernel: CPU#5: fixed-PMC2 count: 0000000000000000
Nov  5 14:27:43 euclid kernel: SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) 
Nov  5 14:31:21 euclid kernel: .sched_goidle                  : 26229101
Nov  5 14:31:21 euclid kernel: .avg_idle                      : 1000000
Nov  5 14:31:21 euclid kernel: .ttwu_count                    : 26998286
Nov  5 14:31:21 euclid kernel: .ttwu_local                    : 6527672
Nov  5 14:31:21 euclid kernel: .bkl_count                     : 25
Nov  5 14:31:21 euclid kernel: 
Nov  5 14:31:21 euclid kernel: cfs_rq[6]:/vcs
Nov  5 14:31:21 euclid kernel: .exec_clock                    : 9535.457625
Nov  5 14:31:21 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:21 euclid kernel: .min_vruntime                  : 15675.735786
Nov  5 14:31:21 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:21 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:21 euclid kernel: .spread0                       : -64372906.520805
Nov  5 14:31:21 euclid kernel: .nr_running                    : 0
Nov  5 14:31:21 euclid kernel: .load                          : 0
Nov  5 14:31:21 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:21 euclid kernel: .shares                        : 0
Nov  5 14:31:21 euclid kernel: .se->exec_start                : 171154336.615794
Nov  5 14:31:21 euclid kernel: .se->vruntime                  : 65235503.191176
Nov  5 14:31:21 euclid kernel: .se->sum_exec_runtime          : 9535.457625
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.exec_max       : 1.018850
Nov  5 14:31:21 euclid kernel: .se->statistics.slice_max      : 4.108061
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_max       : 2.590183
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_sum       : 42.121986
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_count     : 13073
Nov  5 14:31:21 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:21 euclid kernel: 
Nov  5 14:31:21 euclid kernel: cfs_rq[6]:/transifex
Nov  5 14:31:21 euclid kernel: .exec_clock                    : 103165.767878
Nov  5 14:31:21 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:21 euclid kernel: .min_vruntime                  : 183187.211501
Nov  5 14:31:21 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:21 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:21 euclid kernel: .spread0                       : -64205395.045090
Nov  5 14:31:21 euclid kernel: .nr_running                    : 0
Nov  5 14:31:21 euclid kernel: .load                          : 0
Nov  5 14:31:21 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:21 euclid kernel: .shares                        : 0
Nov  5 14:31:21 euclid kernel: .se->exec_start                : 168696952.769698
Nov  5 14:31:21 euclid kernel: .se->vruntime                  : 65209791.099526
Nov  5 14:31:21 euclid kernel: .se->sum_exec_runtime          : 103165.769249
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:21 euclid kernel: .se->statistics.exec_max       : 1.056442
Nov  5 14:31:21 euclid kernel: .se->statistics.slice_max      : 3.539242
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_max       : 1.639113
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_sum       : 80.229049
Nov  5 14:31:21 euclid kernel: .se->statistics.wait_count     : 70771
Nov  5 14:31:21 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:21 euclid kernel: 
Nov  5 14:31:21 euclid kernel: cfs_rq[6]:/redmine
Nov  5 14:31:21 euclid kernel: .exec_clock                    : 426.383273
Nov  5 14:31:22 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .min_vruntime                  : 2099.531704
Nov  5 14:31:22 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:22 euclid kernel: .spread0                       : -64386482.724887
Nov  5 14:31:22 euclid kernel: .nr_running                    : 0
Nov  5 14:31:22 euclid kernel: .load                          : 0
Nov  5 14:31:22 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:22 euclid kernel: .shares                        : 0
Nov  5 14:31:22 euclid kernel: .se->exec_start                : 112155088.928754
Nov  5 14:31:22 euclid kernel: .se->vruntime                  : 60621118.146897
Nov  5 14:31:22 euclid kernel: .se->sum_exec_runtime          : 426.383273
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.exec_max       : 1.003106
Nov  5 14:31:22 euclid kernel: .se->statistics.slice_max      : 0.050478
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_max       : 0.285066
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_sum       : 4.030208
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_count     : 4054
Nov  5 14:31:22 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:22 euclid kernel: 
Nov  5 14:31:22 euclid kernel: cfs_rq[6]:/postgres
Nov  5 14:31:22 euclid kernel: .exec_clock                    : 205.730639
Nov  5 14:31:22 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .min_vruntime                  : 1843.271953
Nov  5 14:31:22 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:22 euclid kernel: .spread0                       : -64386738.984638
Nov  5 14:31:22 euclid kernel: .nr_running                    : 0
Nov  5 14:31:22 euclid kernel: .load                          : 0
Nov  5 14:31:22 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:22 euclid kernel: .shares                        : 0
Nov  5 14:31:22 euclid kernel: .se->exec_start                : 98467265.523984
Nov  5 14:31:22 euclid kernel: .se->vruntime                  : 58260345.837336
Nov  5 14:31:22 euclid kernel: .se->sum_exec_runtime          : 205.730639
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.exec_max       : 1.000110
Nov  5 14:31:22 euclid kernel: .se->statistics.slice_max      : 0.181052
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_max       : 2.068864
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_sum       : 3.644083
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_count     : 4247
Nov  5 14:31:22 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:22 euclid kernel: 
Nov  5 14:31:22 euclid kernel: cfs_rq[6]:/ns
Nov  5 14:31:22 euclid kernel: .exec_clock                    : 7545.886998
Nov  5 14:31:22 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .min_vruntime                  : 5498.501492
Nov  5 14:31:22 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:22 euclid kernel: .spread0                       : -64383083.755099
Nov  5 14:31:22 euclid kernel: .nr_running                    : 0
Nov  5 14:31:22 euclid kernel: .load                          : 0
Nov  5 14:31:22 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:22 euclid kernel: .shares                        : 0
Nov  5 14:31:22 euclid kernel: .se->exec_start                : 171190131.869452
Nov  5 14:31:22 euclid kernel: .se->vruntime                  : 65237564.907629
Nov  5 14:31:22 euclid kernel: .se->sum_exec_runtime          : 7545.774276
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.exec_max       : 73.776136
Nov  5 14:31:22 euclid kernel: .se->statistics.slice_max      : 0.689588
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_max       : 14.277966
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_sum       : 505.914475
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_count     : 124859
Nov  5 14:31:22 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:22 euclid kernel: 
Nov  5 14:31:22 euclid kernel: cfs_rq[6]:/nginx
Nov  5 14:31:22 euclid kernel: .exec_clock                    : 22602.702073
Nov  5 14:31:22 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .min_vruntime                  : 23434.298121
Nov  5 14:31:22 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:22 euclid kernel: .spread0                       : -64365147.958470
Nov  5 14:31:22 euclid kernel: .nr_running                    : 0
Nov  5 14:31:22 euclid kernel: .load                          : 0
Nov  5 14:31:22 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:22 euclid kernel: .shares                        : 0
Nov  5 14:31:22 euclid kernel: .se->exec_start                : 171196642.471808
Nov  5 14:31:22 euclid kernel: .se->vruntime                  : 65237657.198698
Nov  5 14:31:22 euclid kernel: .se->sum_exec_runtime          : 22602.649167
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.exec_max       : 1.010742
Nov  5 14:31:22 euclid kernel: .se->statistics.slice_max      : 2.469462
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_max       : 8.295855
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_sum       : 427.430734
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_count     : 182754
Nov  5 14:31:22 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:22 euclid kernel: 
Nov  5 14:31:22 euclid kernel: cfs_rq[6]:/mysql
Nov  5 14:31:22 euclid kernel: .exec_clock                    : 7068157.043265
Nov  5 14:31:22 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .min_vruntime                  : 7506696.691394
Nov  5 14:31:22 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:22 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:22 euclid kernel: .spread0                       : -56881885.565197
Nov  5 14:31:22 euclid kernel: .nr_running                    : 0
Nov  5 14:31:22 euclid kernel: .load                          : 0
Nov  5 14:31:22 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:22 euclid kernel: .shares                        : 0
Nov  5 14:31:22 euclid kernel: .se->exec_start                : 171186796.676091
Nov  5 14:31:22 euclid kernel: .se->vruntime                  : 65237539.063256
Nov  5 14:31:22 euclid kernel: .se->sum_exec_runtime          : 7068156.728417
Nov  5 14:31:22 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:22 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.exec_max       : 1.993782
Nov  5 14:31:23 euclid kernel: .se->statistics.slice_max      : 178.189110
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_max       : 18.627476
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_sum       : 29654.626203
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_count     : 14099784
Nov  5 14:31:23 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:23 euclid kernel: 
Nov  5 14:31:23 euclid kernel: cfs_rq[6]:/mail
Nov  5 14:31:23 euclid kernel: .exec_clock                    : 8396.782312
Nov  5 14:31:23 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .min_vruntime                  : 18136.322914
Nov  5 14:31:23 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:23 euclid kernel: .spread0                       : -64370445.933677
Nov  5 14:31:23 euclid kernel: .nr_running                    : 0
Nov  5 14:31:23 euclid kernel: .load                          : 0
Nov  5 14:31:23 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:23 euclid kernel: .shares                        : 0
Nov  5 14:31:23 euclid kernel: .se->exec_start                : 171186873.059737
Nov  5 14:31:23 euclid kernel: .se->vruntime                  : 65237539.103755
Nov  5 14:31:23 euclid kernel: .se->sum_exec_runtime          : 8396.772267
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.exec_max       : 1.020034
Nov  5 14:31:23 euclid kernel: .se->statistics.slice_max      : 5.655119
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_max       : 7.997808
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_sum       : 89.691666
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_count     : 69389
Nov  5 14:31:23 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:23 euclid kernel: 
Nov  5 14:31:23 euclid kernel: cfs_rq[6]:/ldap
Nov  5 14:31:23 euclid kernel: .exec_clock                    : 11453.176697
Nov  5 14:31:23 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .min_vruntime                  : 10361.132788
Nov  5 14:31:23 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:23 euclid kernel: .spread0                       : -64378221.123803
Nov  5 14:31:23 euclid kernel: .nr_running                    : 0
Nov  5 14:31:23 euclid kernel: .load                          : 0
Nov  5 14:31:23 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:23 euclid kernel: .shares                        : 0
Nov  5 14:31:23 euclid kernel: .se->exec_start                : 171186813.424991
Nov  5 14:31:23 euclid kernel: .se->vruntime                  : 65237539.061422
Nov  5 14:31:23 euclid kernel: .se->sum_exec_runtime          : 11453.141811
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.exec_max       : 1.017532
Nov  5 14:31:23 euclid kernel: .se->statistics.slice_max      : 34.197562
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_max       : 7.691299
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_sum       : 65.719741
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_count     : 34570
Nov  5 14:31:23 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:23 euclid kernel: 
Nov  5 14:31:23 euclid kernel: cfs_rq[6]:/jabber
Nov  5 14:31:23 euclid kernel: .exec_clock                    : 367413.751689
Nov  5 14:31:23 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .min_vruntime                  : 326460.384352
Nov  5 14:31:23 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:23 euclid kernel: .spread0                       : -64062121.872239
Nov  5 14:31:23 euclid kernel: .nr_running                    : 0
Nov  5 14:31:23 euclid kernel: .load                          : 0
Nov  5 14:31:23 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:23 euclid kernel: .shares                        : 0
Nov  5 14:31:23 euclid kernel: .se->exec_start                : 171201203.059648
Nov  5 14:31:23 euclid kernel: .se->vruntime                  : 65237695.931735
Nov  5 14:31:23 euclid kernel: .se->sum_exec_runtime          : 367413.516032
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.exec_max       : 49.568434
Nov  5 14:31:23 euclid kernel: .se->statistics.slice_max      : 39.591747
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_max       : 73.776136
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_sum       : 7020.277877
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_count     : 6913814
Nov  5 14:31:23 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:23 euclid kernel: 
Nov  5 14:31:23 euclid kernel: cfs_rq[6]:/apache
Nov  5 14:31:23 euclid kernel: .exec_clock                    : 5014560.851545
Nov  5 14:31:23 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .min_vruntime                  : 4870799.007209
Nov  5 14:31:23 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:23 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:23 euclid kernel: .spread0                       : -59517783.249382
Nov  5 14:31:23 euclid kernel: .nr_running                    : 0
Nov  5 14:31:23 euclid kernel: .load                          : 0
Nov  5 14:31:23 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:23 euclid kernel: .shares                        : 0
Nov  5 14:31:23 euclid kernel: .se->exec_start                : 170966698.178228
Nov  5 14:31:23 euclid kernel: .se->vruntime                  : 65233977.341406
Nov  5 14:31:23 euclid kernel: .se->sum_exec_runtime          : 5014560.809574
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:23 euclid kernel: .se->statistics.exec_max       : 11.299523
Nov  5 14:31:23 euclid kernel: .se->statistics.slice_max      : 172.869331
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_max       : 29.546500
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_sum       : 22223.788309
Nov  5 14:31:23 euclid kernel: .se->statistics.wait_count     : 5790645
Nov  5 14:31:24 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: cfs_rq[6]:/
Nov  5 14:31:24 euclid kernel: .exec_clock                    : 12790228.246447
Nov  5 14:31:24 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:24 euclid kernel: .min_vruntime                  : 65237695.931735
Nov  5 14:31:24 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:24 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:24 euclid kernel: .spread0                       : 849113.675144
Nov  5 14:31:24 euclid kernel: .nr_running                    : 0
Nov  5 14:31:24 euclid kernel: .load                          : 0
Nov  5 14:31:24 euclid kernel: .nr_spread_over                : 42540
Nov  5 14:31:24 euclid kernel: .shares                        : 0
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/vcs
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/transifex
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/redmine
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/postgres
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/ns
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/nginx
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/mysql
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/mail
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/ldap
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/jabber
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/apache
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: rt_rq[6]:/
Nov  5 14:31:24 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:24 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:24 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:24 euclid kernel: .rt_runtime                    : 950.000000
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: runnable tasks:
Nov  5 14:31:24 euclid kernel: task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
Nov  5 14:31:24 euclid kernel: ----------------------------------------------------------------------------------------------------------
Nov  5 14:31:24 euclid kernel: 
Nov  5 14:31:24 euclid kernel: cpu#7, 2000.168 MHz
Nov  5 14:31:24 euclid kernel: .nr_running                    : 0
Nov  5 14:31:24 euclid kernel: .load                          : 0
Nov  5 14:31:24 euclid kernel: .nr_switches                   : 52528922
Nov  5 14:31:24 euclid kernel: .nr_load_updates               : 22826430
Nov  5 14:31:24 euclid kernel: .nr_uninterruptible            : 17
Nov  5 14:31:24 euclid kernel: .next_balance                  : 4465.868372
Nov  5 14:31:24 euclid kernel: .curr->pid                     : 0
Nov  5 14:31:24 euclid kernel: .clock                         : 171201198.002844
Nov  5 14:31:24 euclid kernel: .cpu_load[0]                   : 0
Nov  5 14:31:24 euclid kernel: .cpu_load[1]                   : 0
Nov  5 14:31:24 euclid kernel: .cpu_load[2]                   : 0
Nov  5 14:31:24 euclid kernel: .cpu_load[3]                   : 0
Nov  5 14:31:24 euclid kernel: .cpu_load[4]                   : 0
Nov  5 14:31:24 euclid kernel: .yld_count                     : 189
Nov  5 14:31:24 euclid kernel: .sched_switch                  : 0
Nov  5 14:31:24 euclid kernel: .sched_count                   : 56500271
Nov  5 14:31:24 euclid kernel: .sched_goidle                  : 25828445
Nov  5 14:31:24 euclid kernel: .avg_idle                      : 1000000
Nov  5 14:31:24 euclid kernel: .ttwu_count                    : 26584184
Nov  5 14:31:25 euclid kernel: .ttwu_local                    : 6556548
Nov  5 14:31:25 euclid kernel: .bkl_count                     : 50
Nov  5 14:31:25 euclid kernel: 
Nov  5 14:31:25 euclid kernel: cfs_rq[7]:/vcs
Nov  5 14:31:25 euclid kernel: .exec_clock                    : 5867.773738
Nov  5 14:31:25 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .min_vruntime                  : 13048.569653
Nov  5 14:31:25 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:25 euclid kernel: .spread0                       : -64375533.686938
Nov  5 14:31:25 euclid kernel: .nr_running                    : 0
Nov  5 14:31:25 euclid kernel: .load                          : 0
Nov  5 14:31:25 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:25 euclid kernel: .shares                        : 0
Nov  5 14:31:25 euclid kernel: .se->exec_start                : 171154337.081613
Nov  5 14:31:25 euclid kernel: .se->vruntime                  : 65887851.580048
Nov  5 14:31:25 euclid kernel: .se->sum_exec_runtime          : 5867.771130
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.exec_max       : 1.015609
Nov  5 14:31:25 euclid kernel: .se->statistics.slice_max      : 4.737584
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_max       : 0.437739
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_sum       : 44.616898
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_count     : 6003
Nov  5 14:31:25 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:25 euclid kernel: 
Nov  5 14:31:25 euclid kernel: cfs_rq[7]:/transifex
Nov  5 14:31:25 euclid kernel: .exec_clock                    : 107583.004956
Nov  5 14:31:25 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .min_vruntime                  : 194055.124746
Nov  5 14:31:25 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:25 euclid kernel: .spread0                       : -64194527.131845
Nov  5 14:31:25 euclid kernel: .nr_running                    : 0
Nov  5 14:31:25 euclid kernel: .load                          : 0
Nov  5 14:31:25 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:25 euclid kernel: .shares                        : 0
Nov  5 14:31:25 euclid kernel: .se->exec_start                : 127321280.336087
Nov  5 14:31:25 euclid kernel: .se->vruntime                  : 65066167.134177
Nov  5 14:31:25 euclid kernel: .se->sum_exec_runtime          : 107583.005022
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.exec_max       : 2.062888
Nov  5 14:31:25 euclid kernel: .se->statistics.slice_max      : 6.189779
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_max       : 3.271532
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_sum       : 102.810306
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_count     : 67569
Nov  5 14:31:25 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:25 euclid kernel: 
Nov  5 14:31:25 euclid kernel: cfs_rq[7]:/redmine
Nov  5 14:31:25 euclid kernel: .exec_clock                    : 415.813275
Nov  5 14:31:25 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .min_vruntime                  : 1991.745209
Nov  5 14:31:25 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:25 euclid kernel: .spread0                       : -64386590.511382
Nov  5 14:31:25 euclid kernel: .nr_running                    : 0
Nov  5 14:31:25 euclid kernel: .load                          : 0
Nov  5 14:31:25 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:25 euclid kernel: .shares                        : 0
Nov  5 14:31:25 euclid kernel: .se->exec_start                : 125152401.157764
Nov  5 14:31:25 euclid kernel: .se->vruntime                  : 64779191.433261
Nov  5 14:31:25 euclid kernel: .se->sum_exec_runtime          : 415.813275
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.exec_max       : 1.006534
Nov  5 14:31:25 euclid kernel: .se->statistics.slice_max      : 0.166192
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_max       : 1.634993
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_sum       : 14.277223
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_count     : 3218
Nov  5 14:31:25 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:25 euclid kernel: 
Nov  5 14:31:25 euclid kernel: cfs_rq[7]:/postgres
Nov  5 14:31:25 euclid kernel: .exec_clock                    : 202.416542
Nov  5 14:31:25 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .min_vruntime                  : 1467.922796
Nov  5 14:31:25 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:25 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:25 euclid kernel: .spread0                       : -64387114.333795
Nov  5 14:31:25 euclid kernel: .nr_running                    : 0
Nov  5 14:31:25 euclid kernel: .load                          : 0
Nov  5 14:31:25 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:25 euclid kernel: .shares                        : 0
Nov  5 14:31:25 euclid kernel: .se->exec_start                : 162265335.021361
Nov  5 14:31:25 euclid kernel: .se->vruntime                  : 65800741.932030
Nov  5 14:31:25 euclid kernel: .se->sum_exec_runtime          : 202.416542
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:25 euclid kernel: .se->statistics.exec_max       : 0.999756
Nov  5 14:31:25 euclid kernel: .se->statistics.slice_max      : 0.105406
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_max       : 1.997140
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_sum       : 6.646940
Nov  5 14:31:25 euclid kernel: .se->statistics.wait_count     : 5602
Nov  5 14:31:25 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:25 euclid kernel: 
Nov  5 14:31:25 euclid kernel: cfs_rq[7]:/ns
Nov  5 14:31:25 euclid kernel: .exec_clock                    : 7411.476423
Nov  5 14:31:25 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .min_vruntime                  : 5557.886526
Nov  5 14:31:26 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:26 euclid kernel: .spread0                       : -64383024.370065
Nov  5 14:31:26 euclid kernel: .nr_running                    : 0
Nov  5 14:31:26 euclid kernel: .load                          : 0
Nov  5 14:31:26 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:26 euclid kernel: .shares                        : 0
Nov  5 14:31:26 euclid kernel: .se->exec_start                : 171196735.657137
Nov  5 14:31:26 euclid kernel: .se->vruntime                  : 65889503.350770
Nov  5 14:31:26 euclid kernel: .se->sum_exec_runtime          : 7411.417223
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.exec_max       : 3.705902
Nov  5 14:31:26 euclid kernel: .se->statistics.slice_max      : 1.544114
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_max       : 8.642504
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_sum       : 441.489053
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_count     : 119349
Nov  5 14:31:26 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:26 euclid kernel: 
Nov  5 14:31:26 euclid kernel: cfs_rq[7]:/nginx
Nov  5 14:31:26 euclid kernel: .exec_clock                    : 23019.044191
Nov  5 14:31:26 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .min_vruntime                  : 24491.240917
Nov  5 14:31:26 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:26 euclid kernel: .spread0                       : -64364091.015674
Nov  5 14:31:26 euclid kernel: .nr_running                    : 0
Nov  5 14:31:26 euclid kernel: .load                          : 0
Nov  5 14:31:26 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:26 euclid kernel: .shares                        : 0
Nov  5 14:31:26 euclid kernel: .se->exec_start                : 171194243.091042
Nov  5 14:31:26 euclid kernel: .se->vruntime                  : 65889499.448599
Nov  5 14:31:26 euclid kernel: .se->sum_exec_runtime          : 23018.988025
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.exec_max       : 1.011994
Nov  5 14:31:26 euclid kernel: .se->statistics.slice_max      : 6.509410
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_max       : 8.828631
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_sum       : 392.028519
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_count     : 178528
Nov  5 14:31:26 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:26 euclid kernel: 
Nov  5 14:31:26 euclid kernel: cfs_rq[7]:/mysql
Nov  5 14:31:26 euclid kernel: .exec_clock                    : 7007397.678591
Nov  5 14:31:26 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .min_vruntime                  : 7453990.801229
Nov  5 14:31:26 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:26 euclid kernel: .spread0                       : -56934591.455362
Nov  5 14:31:26 euclid kernel: .nr_running                    : 0
Nov  5 14:31:26 euclid kernel: .load                          : 0
Nov  5 14:31:26 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:26 euclid kernel: .shares                        : 0
Nov  5 14:31:26 euclid kernel: .se->exec_start                : 162294323.826866
Nov  5 14:31:26 euclid kernel: .se->vruntime                  : 65800813.731010
Nov  5 14:31:26 euclid kernel: .se->sum_exec_runtime          : 7007397.478955
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.exec_max       : 113.452815
Nov  5 14:31:26 euclid kernel: .se->statistics.slice_max      : 67.193120
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_max       : 18.785440
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_sum       : 29192.833539
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_count     : 13978871
Nov  5 14:31:26 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:26 euclid kernel: 
Nov  5 14:31:26 euclid kernel: cfs_rq[7]:/mail
Nov  5 14:31:26 euclid kernel: .exec_clock                    : 19171.181164
Nov  5 14:31:26 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .min_vruntime                  : 75936.250682
Nov  5 14:31:26 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:26 euclid kernel: .spread0                       : -64312646.005909
Nov  5 14:31:26 euclid kernel: .nr_running                    : 0
Nov  5 14:31:26 euclid kernel: .load                          : 0
Nov  5 14:31:26 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:26 euclid kernel: .shares                        : 0
Nov  5 14:31:26 euclid kernel: .se->exec_start                : 171190318.001819
Nov  5 14:31:26 euclid kernel: .se->vruntime                  : 65889491.094254
Nov  5 14:31:26 euclid kernel: .se->sum_exec_runtime          : 19171.247911
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:26 euclid kernel: .se->statistics.exec_max       : 1.020049
Nov  5 14:31:26 euclid kernel: .se->statistics.slice_max      : 1.021306
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_max       : 5.879714
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_sum       : 84.037310
Nov  5 14:31:26 euclid kernel: .se->statistics.wait_count     : 75472
Nov  5 14:31:26 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:26 euclid kernel: 
Nov  5 14:31:26 euclid kernel: cfs_rq[7]:/ldap
Nov  5 14:31:26 euclid kernel: .exec_clock                    : 9339.703698
Nov  5 14:31:26 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .min_vruntime                  : 8742.959591
Nov  5 14:31:26 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:26 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:26 euclid kernel: .spread0                       : -64379839.297000
Nov  5 14:31:26 euclid kernel: .nr_running                    : 0
Nov  5 14:31:26 euclid kernel: .load                          : 0
Nov  5 14:31:27 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:27 euclid kernel: .shares                        : 0
Nov  5 14:31:27 euclid kernel: .se->exec_start                : 171157366.735785
Nov  5 14:31:27 euclid kernel: .se->vruntime                  : 65887869.328566
Nov  5 14:31:27 euclid kernel: .se->sum_exec_runtime          : 9339.693374
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.exec_max       : 1.183312
Nov  5 14:31:27 euclid kernel: .se->statistics.slice_max      : 1.510731
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_max       : 7.958139
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_sum       : 68.753526
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_count     : 27603
Nov  5 14:31:27 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: cfs_rq[7]:/jabber
Nov  5 14:31:27 euclid kernel: .exec_clock                    : 373582.675479
Nov  5 14:31:27 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .min_vruntime                  : 332867.406766
Nov  5 14:31:27 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:27 euclid kernel: .spread0                       : -64055714.849825
Nov  5 14:31:27 euclid kernel: .nr_running                    : 0
Nov  5 14:31:27 euclid kernel: .load                          : 0
Nov  5 14:31:27 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:27 euclid kernel: .shares                        : 0
Nov  5 14:31:27 euclid kernel: .se->exec_start                : 171201192.156430
Nov  5 14:31:27 euclid kernel: .se->vruntime                  : 65889526.282705
Nov  5 14:31:27 euclid kernel: .se->sum_exec_runtime          : 373582.344035
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.exec_max       : 76.662176
Nov  5 14:31:27 euclid kernel: .se->statistics.slice_max      : 36.706281
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_max       : 113.452815
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_sum       : 7022.136030
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_count     : 6929335
Nov  5 14:31:27 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: cfs_rq[7]:/apache
Nov  5 14:31:27 euclid kernel: .exec_clock                    : 4807495.078322
Nov  5 14:31:27 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .min_vruntime                  : 4665339.654120
Nov  5 14:31:27 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:27 euclid kernel: .spread0                       : -59723242.602471
Nov  5 14:31:27 euclid kernel: .nr_running                    : 0
Nov  5 14:31:27 euclid kernel: .load                          : 0
Nov  5 14:31:27 euclid kernel: .nr_spread_over                : 0
Nov  5 14:31:27 euclid kernel: .shares                        : 0
Nov  5 14:31:27 euclid kernel: .se->exec_start                : 139902699.101583
Nov  5 14:31:27 euclid kernel: .se->vruntime                  : 65670914.311882
Nov  5 14:31:27 euclid kernel: .se->sum_exec_runtime          : 4807494.973921
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:31:27 euclid kernel: .se->statistics.exec_max       : 61.655470
Nov  5 14:31:27 euclid kernel: .se->statistics.slice_max      : 175.820498
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_max       : 37.758816
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_sum       : 23573.922062
Nov  5 14:31:27 euclid kernel: .se->statistics.wait_count     : 5470822
Nov  5 14:31:27 euclid kernel: .se->load.weight               : 128
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: cfs_rq[7]:/
Nov  5 14:31:27 euclid kernel: .exec_clock                    : 12552095.563914
Nov  5 14:31:27 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .min_vruntime                  : 65889526.282705
Nov  5 14:31:27 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:31:27 euclid kernel: .spread                        : 0.000000
Nov  5 14:31:27 euclid kernel: .spread0                       : 1500944.026114
Nov  5 14:31:27 euclid kernel: .nr_running                    : 0
Nov  5 14:31:27 euclid kernel: .load                          : 0
Nov  5 14:31:27 euclid kernel: .nr_spread_over                : 42540
Nov  5 14:31:27 euclid kernel: .shares                        : 0
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: rt_rq[7]:/vcs
Nov  5 14:31:27 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:27 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:27 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:27 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: rt_rq[7]:/transifex
Nov  5 14:31:27 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:27 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:27 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:27 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: rt_rq[7]:/redmine
Nov  5 14:31:27 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:27 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:27 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:27 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: rt_rq[7]:/postgres
Nov  5 14:31:27 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:27 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:27 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:27 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:27 euclid kernel: 
Nov  5 14:31:27 euclid kernel: rt_rq[7]:/ns
Nov  5 14:31:27 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:27 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:27 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:27 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/nginx
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/mysql
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/mail
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/ldap
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/jabber
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/apache
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 0.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: rt_rq[7]:/
Nov  5 14:31:28 euclid kernel: .rt_nr_running                 : 0
Nov  5 14:31:28 euclid kernel: .rt_throttled                  : 0
Nov  5 14:31:28 euclid kernel: .rt_time                       : 0.000000
Nov  5 14:31:28 euclid kernel: .rt_runtime                    : 950.000000
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:31:28 euclid kernel: runnable tasks:
Nov  5 14:31:28 euclid kernel: task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
Nov  5 14:31:28 euclid kernel: ----------------------------------------------------------------------------------------------------------
Nov  5 14:31:28 euclid kernel: 
Nov  5 14:32:53 euclid kernel: .sched_goidle                  : 26235021
Nov  5 14:32:53 euclid kernel: .avg_idle                      : 1000000
Nov  5 14:32:53 euclid kernel: .ttwu_count                    : 27004028
Nov  5 14:32:53 euclid kernel: .ttwu_local                    : 6532087
Nov  5 14:32:53 euclid kernel: .bkl_count                     : 25
Nov  5 14:32:53 euclid kernel: 
Nov  5 14:32:53 euclid kernel: cfs_rq[6]:/vcs
Nov  5 14:32:53 euclid kernel: .exec_clock                    : 9535.457625
Nov  5 14:32:53 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .min_vruntime                  : 15675.735786
Nov  5 14:32:53 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:53 euclid kernel: .spread0                       : -64374051.789013
Nov  5 14:32:53 euclid kernel: .nr_running                    : 0
Nov  5 14:32:53 euclid kernel: .load                          : 0
Nov  5 14:32:53 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:53 euclid kernel: .shares                        : 0
Nov  5 14:32:53 euclid kernel: .se->exec_start                : 171154336.615794
Nov  5 14:32:53 euclid kernel: .se->vruntime                  : 65235503.191176
Nov  5 14:32:53 euclid kernel: .se->sum_exec_runtime          : 9535.457625
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.exec_max       : 1.018850
Nov  5 14:32:53 euclid kernel: .se->statistics.slice_max      : 4.108061
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_max       : 2.590183
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_sum       : 42.121986
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_count     : 13073
Nov  5 14:32:53 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:53 euclid kernel: 
Nov  5 14:32:53 euclid kernel: cfs_rq[6]:/transifex
Nov  5 14:32:53 euclid kernel: .exec_clock                    : 103165.767878
Nov  5 14:32:53 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .min_vruntime                  : 183187.211501
Nov  5 14:32:53 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:53 euclid kernel: .spread0                       : -64206540.313298
Nov  5 14:32:53 euclid kernel: .nr_running                    : 0
Nov  5 14:32:53 euclid kernel: .load                          : 0
Nov  5 14:32:53 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:53 euclid kernel: .shares                        : 0
Nov  5 14:32:53 euclid kernel: .se->exec_start                : 168696952.769698
Nov  5 14:32:53 euclid kernel: .se->vruntime                  : 65209791.099526
Nov  5 14:32:53 euclid kernel: .se->sum_exec_runtime          : 103165.769249
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.exec_max       : 1.056442
Nov  5 14:32:53 euclid kernel: .se->statistics.slice_max      : 3.539242
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_max       : 1.639113
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_sum       : 80.229049
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_count     : 70771
Nov  5 14:32:53 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:53 euclid kernel: 
Nov  5 14:32:53 euclid kernel: cfs_rq[6]:/redmine
Nov  5 14:32:53 euclid kernel: .exec_clock                    : 426.383273
Nov  5 14:32:53 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .min_vruntime                  : 2099.531704
Nov  5 14:32:53 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:53 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:53 euclid kernel: .spread0                       : -64387627.993095
Nov  5 14:32:53 euclid kernel: .nr_running                    : 0
Nov  5 14:32:53 euclid kernel: .load                          : 0
Nov  5 14:32:53 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:53 euclid kernel: .shares                        : 0
Nov  5 14:32:53 euclid kernel: .se->exec_start                : 112155088.928754
Nov  5 14:32:53 euclid kernel: .se->vruntime                  : 60621118.146897
Nov  5 14:32:53 euclid kernel: .se->sum_exec_runtime          : 426.383273
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:53 euclid kernel: .se->statistics.exec_max       : 1.003106
Nov  5 14:32:53 euclid kernel: .se->statistics.slice_max      : 0.050478
Nov  5 14:32:53 euclid kernel: .se->statistics.wait_max       : 0.285066
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_sum       : 4.030208
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_count     : 4054
Nov  5 14:32:54 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:54 euclid kernel: 
Nov  5 14:32:54 euclid kernel: cfs_rq[6]:/postgres
Nov  5 14:32:54 euclid kernel: .exec_clock                    : 205.730639
Nov  5 14:32:54 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .min_vruntime                  : 1843.271953
Nov  5 14:32:54 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:54 euclid kernel: .spread0                       : -64387884.252846
Nov  5 14:32:54 euclid kernel: .nr_running                    : 0
Nov  5 14:32:54 euclid kernel: .load                          : 0
Nov  5 14:32:54 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:54 euclid kernel: .shares                        : 0
Nov  5 14:32:54 euclid kernel: .se->exec_start                : 98467265.523984
Nov  5 14:32:54 euclid kernel: .se->vruntime                  : 58260345.837336
Nov  5 14:32:54 euclid kernel: .se->sum_exec_runtime          : 205.730639
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.exec_max       : 1.000110
Nov  5 14:32:54 euclid kernel: .se->statistics.slice_max      : 0.181052
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_max       : 2.068864
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_sum       : 3.644083
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_count     : 4247
Nov  5 14:32:54 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:54 euclid kernel: 
Nov  5 14:32:54 euclid kernel: cfs_rq[6]:/ns
Nov  5 14:32:54 euclid kernel: .exec_clock                    : 7552.223042
Nov  5 14:32:54 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .min_vruntime                  : 5502.586409
Nov  5 14:32:54 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:54 euclid kernel: .spread0                       : -64384224.938390
Nov  5 14:32:54 euclid kernel: .nr_running                    : 0
Nov  5 14:32:54 euclid kernel: .load                          : 0
Nov  5 14:32:54 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:54 euclid kernel: .shares                        : 0
Nov  5 14:32:54 euclid kernel: .se->exec_start                : 171289051.559024
Nov  5 14:32:54 euclid kernel: .se->vruntime                  : 65239686.614362
Nov  5 14:32:54 euclid kernel: .se->sum_exec_runtime          : 7552.110320
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.exec_max       : 73.776136
Nov  5 14:32:54 euclid kernel: .se->statistics.slice_max      : 0.689588
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_max       : 14.277966
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_sum       : 505.917244
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_count     : 124990
Nov  5 14:32:54 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:54 euclid kernel: 
Nov  5 14:32:54 euclid kernel: cfs_rq[6]:/nginx
Nov  5 14:32:54 euclid kernel: .exec_clock                    : 22604.454429
Nov  5 14:32:54 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .min_vruntime                  : 23436.050477
Nov  5 14:32:54 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:54 euclid kernel: .spread0                       : -64366291.474322
Nov  5 14:32:54 euclid kernel: .nr_running                    : 0
Nov  5 14:32:54 euclid kernel: .load                          : 0
Nov  5 14:32:54 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:54 euclid kernel: .shares                        : 0
Nov  5 14:32:54 euclid kernel: .se->exec_start                : 171281719.496690
Nov  5 14:32:54 euclid kernel: .se->vruntime                  : 65239606.898996
Nov  5 14:32:54 euclid kernel: .se->sum_exec_runtime          : 22604.401523
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.exec_max       : 1.010742
Nov  5 14:32:54 euclid kernel: .se->statistics.slice_max      : 2.469462
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_max       : 8.295855
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_sum       : 427.430734
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_count     : 182773
Nov  5 14:32:54 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:54 euclid kernel: 
Nov  5 14:32:54 euclid kernel: cfs_rq[6]:/mysql
Nov  5 14:32:54 euclid kernel: .exec_clock                    : 7068157.117750
Nov  5 14:32:54 euclid kernel: .MIN_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .min_vruntime                  : 7506696.691394
Nov  5 14:32:54 euclid kernel: .max_vruntime                  : 0.000001
Nov  5 14:32:54 euclid kernel: .spread                        : 0.000000
Nov  5 14:32:54 euclid kernel: .spread0                       : -56883030.833405
Nov  5 14:32:54 euclid kernel: .nr_running                    : 0
Nov  5 14:32:54 euclid kernel: .load                          : 0
Nov  5 14:32:54 euclid kernel: .nr_spread_over                : 0
Nov  5 14:32:54 euclid kernel: .shares                        : 0
Nov  5 14:32:54 euclid kernel: .se->exec_start                : 171246796.868950
Nov  5 14:32:54 euclid kernel: .se->vruntime                  : 65238127.896862
Nov  5 14:32:54 euclid kernel: .se->sum_exec_runtime          : 7068156.802902
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_start     : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_start    : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.sleep_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.block_max      : 0.000000
Nov  5 14:32:54 euclid kernel: .se->statistics.exec_max       : 1.993782
Nov  5 14:32:54 euclid kernel: .se->statistics.slice_max      : 178.189110
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_max       : 18.627476
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_sum       : 29654.626203
Nov  5 14:32:54 euclid kernel: .se->statistics.wait_count     : 14099786
Nov  5 14:32:54 euclid kernel: .se->load.weight               : 128
Nov  5 14:32:54 euclid kernel: 
Nov  5 14:32:54 euclid kernel: cfs_rq[6]:/mail
Nov  5 14:32:54 euclid kernel: .exec_clock                    : 8397.248217

--=-ghwyP9xjH/vhhJxYtDup
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--=-ghwyP9xjH/vhhJxYtDup--
