From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: Userspace checkpoint/restart hack: cryo
Date: Tue, 29 Apr 2008 16:50:14 +0200
Message-ID: <481735A6.8070800@bull.net>
References: <1209144259.12718.46.camel@nimitz.home.sr71.net>
	<48159D1D.3050302@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040400080104080805090108"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48159D1D.3050302-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------040400080104080805090108
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Cedric Le Goater wrote:
> Dave Hansen wrote:
> 
>>A guy named Marc Vertes wrote this as a little demonstration of
>>checkpoint/restart.  I've been using it to experiment with
>>checkpoint/restart.  I thought it might be of some use as we move
>>subsystems to being helped by the kernel to checkpoint and restart.
>>
>>It's ptrace-based, and stuck on i386 for now.  It can probably be ported
>>elsewhere without too much trouble.    It doesn't support *anything
>>fancy like multuiple tasks :).  It has the advantage of being very
>>feature-bare, and I think it is pretty easy to hack on.  Whatever c/r
>>support we add to the kernel could easily be added on and tested.
>>
>>http://userweb.kernel.org/~daveh/cryo/cryo-001.tar.gz
>>
>>Usage:
>>	cr -p `pidof task` > checkpoint.cryo 
>>	cr -r < checkpoint.cryo
>>
>>If anyone else has something simpler or easier to hack on, I'm all ears.
> 
> 
> Indeed. It looks simple enough.
> 
> do you have some kernel requirement ? I run Fedora 8
> 
> Here's my first try on a program calculating decimal of PI : 
> 
> 	$ ./cr -p `pidof pi1` > pi1.cryo
> 	attaching to pid: 11082
> 	[11087 cr.c:243 getfdinfo()] n : 0
> 	WARNING (sci.c:242) unexpected signal for 11082: 11
> 	[11087 sci.c:228 ptrace_waitsyscall()] WTERMSIG(status) : 11
> 	ERROR (sci.c:383) ptrace_getregs(11082, 0xbfe4a3d0) errno=3: No such process
> 	./cr[0x8051f10]
> 	./cr[0x8049ce9]
> 	./cr[0x804b7d2]
> 	./cr[0x804f75b]
> 	***STOP***
> 
> other terminal :
> 
> 	$ pi1 20000
> 	pi1 - 20000 digits, 78.1 kbytes
> 	Segmentation fault (core dumped)
> 
> Thanks,
> 
> C.
> 

Looks like it has worked for me (msg1 creates 1000 msg queues, sleeps 
for a while and then removes the msg queues).

Output attached.

Regards,
Nadia




--------------040400080104080805090108
Content-Type: text/plain;
 name="cryo.output"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cryo.output"

[root@akt cryo-001]# ./cr -p `pidof msg1` > msg1.cryo
attaching to pid: 4689
[4695 cr.c:243 getfdinfo()] n : 0
[4695 cr.c:243 getfdinfo()] n : 1
[4695 cr.c:243 getfdinfo()] n : 2
DEBUG (utils.c::25) write_item() writing item named: 'pid' datasize: 4 to positi
on: 0
DEBUG (utils.c::25) write_item() writing item named: 'ppid' datasize: 4 to posit
ion: 10
DEBUG (utils.c::25) write_item() writing item named: 'exitsig' datasize: 4 to po
sition: 21
DEBUG (utils.c::25) write_item() writing item named: 'fpregs' datasize: 108 to p
osition: 35
DEBUG (utils.c::25) write_item() writing item named: 'regs' datasize: 68 to posi
tion: 154
DEBUG (utils.c::25) write_item() writing item named: 'exe' datasize: 32 to posit
ion: 230
DEBUG (utils.c::25) write_item() writing item named: 'argv' datasize: 7 to posit
ion: 269
DEBUG (utils.c::25) write_item() writing item named: 'env' datasize: 1137 to pos
ition: 283
DEBUG (utils.c::25) write_item() writing item named: 'cwd' datasize: 27 to posit
ion: 1429
DEBUG (utils.c::25) write_item() writing item named: 'sigact' datasize: 9240 to 
position: 1463
DEBUG (utils.c::25) write_item() writing item named: 'sigmask' datasize: 128 to 
position: 10715
DEBUG (utils.c::25) write_item() writing item named: 'sigpend' datasize: 128 to 
position: 10855
DEBUG (utils.c::25) write_item() writing item named: 'FD' datasize: 0 to positio
n: 10995
[4695 cr.c:512 checkpoint()] pi->nf : 3
DEBUG (utils.c::25) write_item() writing item named: 'fdinfo' datasize: 148 to p
osition: 11000
DEBUG (utils.c::25) write_item() writing item named: 'fdinfo' datasize: 148 to p
osition: 11159
DEBUG (utils.c::25) write_item() writing item named: 'fdinfo' datasize: 148 to p
osition: 11318
DEBUG (utils.c::25) write_item() writing item named: 'END FD' datasize: 0 to pos
ition: 11477
DEBUG (utils.c::25) write_item() writing item named: 'SOCK' datasize: 0 to posit
ion: 11486
DEBUG (utils.c::25) write_item() writing item named: 'END SOCK' datasize: 0 to p
osition: 11493
DEBUG (utils.c::25) write_item() writing item named: 'MEM' datasize: 0 to positi
on: 11504
getmaps() '' is anonymous (old test)
getmaps() '' is anonymous (new test)
getmaps() '' is anonymous (old test)
getmaps() '' is anonymous (new test)
getmaps() '' is anonymous (old test)
getmaps() '' is anonymous (new test)
getmaps() '[stack]' is anonymous (new test)
getmaps() '[vdso]' is anonymous (new test)
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 11510
DEBUG (cr.c::528) mem i=0 0x850000 -> 0x869000 /lib/ld-2.5.so
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to pos
ition: 11669
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 11678
DEBUG (cr.c::528) mem i=1 0x869000 -> 0x86a000 /lib/ld-2.5.so
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to pos
ition: 11837
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 11846
DEBUG (cr.c::528) mem i=2 0x86a000 -> 0x86b000 /lib/ld-2.5.so
DEBUG (cr.c::530) mem i=2 saved size = 4 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 4096 to 
position: 12005
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 16113
DEBUG (cr.c::528) mem i=3 0x86d000 -> 0x9a4000 /lib/libc-2.5.so
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to pos
ition: 16272
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 16281
DEBUG (cr.c::528) mem i=4 0x9a4000 -> 0x9a6000 /lib/libc-2.5.so
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to pos
ition: 16440
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to p
osition: 16449
DEBUG (cr.c::528) mem i=5 0x9a6000 -> 0x9a7000 /lib/libc-2.5.so
DEBUG (cr.c::530) mem i=5 saved size = 4 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 4096 to position: 16608
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 20716
DEBUG (cr.c::528) mem i=6 0x9a7000 -> 0x9aa000 
DEBUG (cr.c::530) mem i=6 saved size = 12 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 12288 to position: 20875
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 33176
DEBUG (cr.c::528) mem i=7 0x8048000 -> 0x8049000 /home/lkernel/src_ref/tests/msg1
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to position: 33335
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 33344
DEBUG (cr.c::528) mem i=8 0x8049000 -> 0x804a000 /home/lkernel/src_ref/tests/msg1
DEBUG (cr.c::530) mem i=8 saved size = 4 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 4096 to position: 33503
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 37611
DEBUG (cr.c::528) mem i=9 0xb7f98000 -> 0xb7f99000 
DEBUG (cr.c::530) mem i=9 saved size = 4 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 4096 to position: 37770
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 41878
DEBUG (cr.c::528) mem i=10 0xb7fa6000 -> 0xb7fa8000 
DEBUG (cr.c::530) mem i=10 saved size = 8 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 8192 to position: 42037
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 50241
DEBUG (cr.c::528) mem i=11 0xbfc93000 -> 0xbfca8000 [stack]
DEBUG (cr.c::530) mem i=11 saved size = 84 KB
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 86016 to position: 50400
DEBUG (utils.c::25) write_item() writing item named: 'memseg' datasize: 148 to position: 136429
DEBUG (cr.c::528) mem i=12 0xffffe000 -> 0xfffff000 [vdso]
DEBUG (utils.c::25) write_item() writing item named: 'membuf' datasize: 0 to position: 136588
DEBUG (utils.c::25) write_item() writing item named: 'END MEM' datasize: 0 to position: 136597


--------------040400080104080805090108
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------040400080104080805090108--
