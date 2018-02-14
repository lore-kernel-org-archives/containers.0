From: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 16:02:18 +0100
Message-ID: <4f620eb7-c00c-487b-2e06-8cc4c97af38c__31453.9171442904$1518620506$gmane$org@metux.net>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<2658681.ustYaP9yci@blindfold>
	<a2a6f189-008e-38f2-afcb-b9393d8d440a@metux.net>
	<2050418.Dl5pXkWGsk@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2050418.Dl5pXkWGsk@blindfold>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 14.02.2018 15:19, Richard Weinberger wrote:

> Works here(tm).
> Can you debug it? Maybe we miss something obvious.

daemon@alphabox:~ strace unshare -U -r --setgroups=deny
execve("/bin/unshare", ["unshare", "-U", "-r", "--setgroups=deny"], 
0x7ee51e0c /* 11 vars */) = 0
brk(NULL)                               = 0x58000
fcntl64(0, F_GETFD)                     = 0
fcntl64(1, F_GETFD)                     = 0
fcntl64(2, F_GETFD)                     = 0
access("/etc/suid-debug", F_OK)         = -1 ENOENT (No such file or 
directory)
uname({sysname="Linux", nodename="alphabox", ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 
0) = 0x76f90000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file 
or directory)
open("/lib/tls/v7l/neon/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT 
(No such file or directory)
stat64("/lib/tls/v7l/neon/vfp", 0x7eae8710) = -1 ENOENT (No such file or 
directory)
open("/lib/tls/v7l/neon/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No 
such file or directory)
stat64("/lib/tls/v7l/neon", 0x7eae8710) = -1 ENOENT (No such file or 
directory)
open("/lib/tls/v7l/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No 
such file or directory)
stat64("/lib/tls/v7l/vfp", 0x7eae8710)  = -1 ENOENT (No such file or 
directory)
open("/lib/tls/v7l/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/tls/v7l", 0x7eae8710)      = -1 ENOENT (No such file or 
directory)
open("/lib/tls/neon/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No 
such file or directory)
stat64("/lib/tls/neon/vfp", 0x7eae8710) = -1 ENOENT (No such file or 
directory)
open("/lib/tls/neon/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/tls/neon", 0x7eae8710)     = -1 ENOENT (No such file or 
directory)
open("/lib/tls/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/tls/vfp", 0x7eae8710)      = -1 ENOENT (No such file or 
directory)
open("/lib/tls/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file 
or directory)
stat64("/lib/tls", 0x7eae8710)          = -1 ENOENT (No such file or 
directory)
open("/lib/v7l/neon/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No 
such file or directory)
stat64("/lib/v7l/neon/vfp", 0x7eae8710) = -1 ENOENT (No such file or 
directory)
open("/lib/v7l/neon/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/v7l/neon", 0x7eae8710)     = -1 ENOENT (No such file or 
directory)
open("/lib/v7l/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/v7l/vfp", 0x7eae8710)      = -1 ENOENT (No such file or 
directory)
open("/lib/v7l/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file 
or directory)
stat64("/lib/v7l", 0x7eae8710)          = -1 ENOENT (No such file or 
directory)
open("/lib/neon/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/neon/vfp", 0x7eae8710)     = -1 ENOENT (No such file or 
directory)
open("/lib/neon/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such 
file or directory)
stat64("/lib/neon", 0x7eae8710)         = -1 ENOENT (No such file or 
directory)
open("/lib/vfp/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file 
or directory)
stat64("/lib/vfp", 0x7eae8710)          = -1 ENOENT (No such file or 
directory)
open("/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, 
"\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0(\0\1\0\0\0Yi\1\0004\0\0\0"..., 512) 
= 512
fstat64(3, {st_mode=S_IFREG|0755, st_size=878136, ...}) = 0
mmap2(NULL, 947496, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 
0) = 0x76e82000
mprotect(0x76f55000, 61440, PROT_NONE)  = 0
mmap2(0x76f64000, 12288, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0xd2000) = 0x76f64000
mmap2(0x76f67000, 9512, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x76f67000
close(3)                                = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 
0) = 0x76f8f000
set_tls(0x76f8f4c0, 0x76f8fb98, 0x76f92050, 0x76f8f4c0, 0x76f92050) = 0
mprotect(0x76f64000, 8192, PROT_READ)   = 0
mprotect(0x76f91000, 4096, PROT_READ)   = 0
getuid32()                              = 1
stat64("/etc/busybox.conf", {st_mode=S_IFREG|0644, st_size=198, ...}) = 0
brk(NULL)                               = 0x58000
brk(0x79000)                            = 0x79000
open("/etc/busybox.conf", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=198, ...}) = 0
read(3, "[SUID]\n#lines starting with # ar"..., 1024) = 198
read(3, "", 1024)                       = 0
close(3)                                = 0
getgid32()                              = 1
setgid32(1)                             = 0
setuid32(1)                             = 0
geteuid32()                             = 1
getegid32()                             = 1
unshare(CLONE_NEWUTS|CLONE_NEWUSER)     = 0
open("/proc/self/setgroups", O_WRONLY|O_LARGEFILE) = 3
write(3, "deny", 4)                     = 4
close(3)                                = 0
open("/proc/self/uid_map", O_WRONLY|O_LARGEFILE) = 3
write(3, "1 0 1", 5)                    = -1 EPERM (Operation not permitted)
write(2, "unshare: write error: Operation "..., 46unshare: write error: 
Operation not permitted
) = 46
exit_group(1)                           = ?
+++ exited with 1 +++

Seems it fails to write the uid map.
Is the order of setgroups vs uid_map correct ?

>> What's the exact relation between user and mnt namespace ?
>> Why do I need an own user ns for private mnt ns ? (except for the suid
>> bit, which I wanna get rid of anyways).
> 
> mount related system calls are root-only. Therefore you need the user
> namespace to become a root in your own little world. :)

I'm looking for a way to do that w/o being root (or something similar).
Actually, I don't like to change the user namespace, as it would cause
a lot of trouble w/ the /dev/cap[hash|use] devices, which I'm using for
user switching (as said: I'm going to get rid of suid completely).

--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org -- +49-151-27565287
