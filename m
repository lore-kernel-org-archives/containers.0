From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: 2.6.35: unshare(NEWNS) does not work inside a container anymore?
Date: Wed, 01 Sep 2010 21:27:55 +0400
Message-ID: <4C7E8D1B.2060204@msgid.tls.msk.ru>
References: <4C7CE137.5090009@msgid.tls.msk.ru>
	<20100901162833.GA13274@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100901162833.GA13274-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

01.09.2010 20:28, Serge E. Hallyn wrote:
> Quoting Michael Tokarev (mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org):
>> I just noticed a regression - immediately after updating
>> kernel from 2.6.32 to 2.6.35 (I skipped .33 and .34).
>> Namely, unshare(CLONE_NEWNS) stopped workin from within
>> a container, like this:
>>
>> unshare(CLONE_NEWNS)              = -1 EINVAL (Invalid argument)
>>
>> There's no other fancy stuff going on around, just plain
>> unshare and exec a new shell.
> 
> I'm not seeing this behavior.  I'm on 2.6.35-19-generic (ubuntu
> maverick), created a lucid container with the standard template,
> and tested with ns_exec
> 	(git clone git://git.sr71.net/~hallyn/cr_tests.git;
> 	 git checkout ns_exec; make ns_exec;
> 	 ns_exec -m /bin/bash;  play with mounts; exit)

This one is not using unshare(2), it is using clone(2) syscall.

I asked about unshare.  In particular, lxc-unshare fails withing
the container the same way too -- it too uses unshare().

> Can you give us /proc/self/status and capsh --print output
> from inside the container before you try to unshare, and
> maybe strace output from the program you were using?

Sure.

# cat /proc/self/status
Name:	cat
State:	R (running)
Tgid:	2663
Pid:	2663
PPid:	2660
TracerPid:	0
Uid:	0	0	0	0
Gid:	0	0	0	0
FDSize:	256
Groups:	0
VmPeak:	    4944 kB
VmSize:	    4944 kB
VmLck:	       0 kB
VmHWM:	     232 kB
VmRSS:	     232 kB
VmData:	     160 kB
VmStk:	     136 kB
VmExe:	      40 kB
VmLib:	    1388 kB
VmPTE:	      24 kB
VmSwap:	       0 kB
Threads:	1
SigQ:	4/63178
SigPnd:	0000000000000000
ShdPnd:	0000000000000000
SigBlk:	0000000000000000
SigIgn:	0000000000000000
SigCgt:	0000000000000000
CapInh:	0000000000000000
CapPrm:	ffffffffffbfffff
CapEff:	ffffffffffbfffff
CapBnd:	ffffffffffbfffff
Cpus_allowed:	f
Cpus_allowed_list:	0-3
Mems_allowed:	1
Mems_allowed_list:	0
voluntary_ctxt_switches:	3
nonvoluntary_ctxt_switches:	2

# capsh --print
Current: =ep cap_sys_boot-ep
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin
Securebits: 00/0x0
 secure-noroot: no (unlocked)
 secure-no-suid-fixup: no (unlocked)
 secure-keep-caps: no (unlocked)
uid=0

# strace clone --fs bash
execve("/usr/sbin/clone", ["clone", "--fs", "bash"], [/* 15 vars */]) = 0
brk(0)                                  = 0x834c000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xf76f1000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=18528, ...}) = 0
mmap2(NULL, 18528, PROT_READ, MAP_PRIVATE, 3, 0) = 0xf76ec000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/i686/cmov/libc.so.6", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\320m\1\0004\0\0\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=1327556, ...}) = 0
mmap2(NULL, 1337704, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xf75a5000
mprotect(0xf76e5000, 4096, PROT_NONE)   = 0
mmap2(0xf76e6000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x140) = 0xf76e6000
mmap2(0xf76e9000, 10600, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xf76e9000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xf75a4000
set_thread_area({entry_number:-1 -> 12, base_addr:0xf75a46c0, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
mprotect(0xf76e6000, 8192, PROT_READ)   = 0
mprotect(0xf770f000, 4096, PROT_READ)   = 0
munmap(0xf76ec000, 18528)               = 0
unshare(CLONE_NEWNS)                    = -1 EINVAL (Invalid argument)
write(2, "clone: unshare: Invalid argument"..., 33clone: unshare: Invalid argument
) = 33
exit_group(1)                           = ?

The source of this clone program is available at
http://www.corpit.ru/mjt/clone.c - I use it for
a long time, it works on this same machine
outside of containers, and it worked in 2.6.32.

Thanks!

/mjt
