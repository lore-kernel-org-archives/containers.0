From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Userspace checkpoint/restart hack: cryo
Date: Mon, 28 Apr 2008 11:47:09 +0200
Message-ID: <48159D1D.3050302@fr.ibm.com>
References: <1209144259.12718.46.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1209144259.12718.46.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> A guy named Marc Vertes wrote this as a little demonstration of
> checkpoint/restart.  I've been using it to experiment with
> checkpoint/restart.  I thought it might be of some use as we move
> subsystems to being helped by the kernel to checkpoint and restart.
> 
> It's ptrace-based, and stuck on i386 for now.  It can probably be ported
> elsewhere without too much trouble.    It doesn't support *anything
> fancy like multuiple tasks :).  It has the advantage of being very
> feature-bare, and I think it is pretty easy to hack on.  Whatever c/r
> support we add to the kernel could easily be added on and tested.
> 
> http://userweb.kernel.org/~daveh/cryo/cryo-001.tar.gz
> 
> Usage:
> 	cr -p `pidof task` > checkpoint.cryo 
> 	cr -r < checkpoint.cryo
> 
> If anyone else has something simpler or easier to hack on, I'm all ears.

Indeed. It looks simple enough.

do you have some kernel requirement ? I run Fedora 8

Here's my first try on a program calculating decimal of PI : 

	$ ./cr -p `pidof pi1` > pi1.cryo
	attaching to pid: 11082
	[11087 cr.c:243 getfdinfo()] n : 0
	WARNING (sci.c:242) unexpected signal for 11082: 11
	[11087 sci.c:228 ptrace_waitsyscall()] WTERMSIG(status) : 11
	ERROR (sci.c:383) ptrace_getregs(11082, 0xbfe4a3d0) errno=3: No such process
	./cr[0x8051f10]
	./cr[0x8049ce9]
	./cr[0x804b7d2]
	./cr[0x804f75b]
	***STOP***

other terminal :

	$ pi1 20000
	pi1 - 20000 digits, 78.1 kbytes
	Segmentation fault (core dumped)

Thanks,

C.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
--- Makefile~   2008-04-25 19:05:57.000000000 +0200
+++ Makefile    2008-04-28 09:02:50.000000000 +0200
@@ -7,6 +7,3 @@ all : $(BIN) $(MAN1)
 
 #cr: cr.o utils.o list_hash.o ptrace_linux_x86.o
 cr: cr.o utils.o list_hash.o sci.o injlib.o
-
-include ../version.mk
-include ../c.mk
