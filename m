From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] Container Freezer: Make refrigerator always available
Date: Fri, 01 Aug 2008 12:08:09 -0700
Message-ID: <1217617689.25300.213.camel__7793.32166207514$1217618161$gmane$org@localhost.localdomain>
References: <20080801050659.924495279@us.ibm.com>
	<20080801050700.528446138@us.ibm.com>  <20080801162712.63721e8c@surf>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5458932296729009787=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080801162712.63721e8c@surf>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: linux-embedded-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Opdenacker <michael-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============5458932296729009787==
Content-Type: text/plain; charset=UTF-7
Content-Transfer-Encoding: 7bit


On Fri, 2008-08-01 at 16:27 +-0200, Thomas Petazzoni wrote:
+AD4 Hi,
+AD4 
+AD4 Le Thu, 31 Jul 2008 22:07:01 -0700,
+AD4 Matt Helsley +ADw-matthltc+AEA-us.ibm.com+AD4 a +AOk-crit :
+AD4 
+AD4 +AD4 --- a/kernel/Makefile
+AD4 +AD4 +-+-+- b/kernel/Makefile
+AD4 +AD4 +AEAAQA -5,7 +-5,7 +AEAAQA
+AD4 +AD4  obj-y     +AD0 sched.o fork.o exec+AF8-domain.o panic.o printk.o +AFw
+AD4 +AD4  	    cpu.o exit.o itimer.o time.o softirq.o resource.o +AFw
+AD4 +AD4  	    sysctl.o capability.o ptrace.o timer.o user.o +AFw
+AD4 +AD4 -	    signal.o sys.o kmod.o workqueue.o pid.o +AFw
+AD4 +AD4 +-	    signal.o sys.o kmod.o workqueue.o pid.o freezer.o +AFw
+AD4 
+AD4 I have the impression that the code in kernel/power/process.c was
+AD4 compiled only if CONFIG+AF8-PM+AF8-SLEEP was set. Now that the code has been
+AD4 moved to kernel/freezer.c, it is unconditionnaly compiled in every
+AD4 kernel. Is that correct ?
+AD4
+AD4 If so, is it possible to put this new feature under some
+AD4 CONFIG+AF8-SOMETHING option, for people who care about the kernel size ?

	How about making it depend on a combination of CONFIG variables?
Here's an RFC PATCH. Completely untested.

Signed-off-by: Matt Helsley +ADw-matthltc+AEA-us.ibm.com+AD4
---
 kernel/Makefile      +AHw    3 +-+--
 kernel/power/Kconfig +AHw    3 +-+-+-
 2 files changed, 5 insertions(+-), 1 deletion(-)

Index: linux-2.6.27-rc1-mm1/kernel/Makefile
+AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0
--- linux-2.6.27-rc1-mm1.orig/kernel/Makefile
+-+-+- linux-2.6.27-rc1-mm1/kernel/Makefile
+AEAAQA -5,7 +-5,7 +AEAAQA
 obj-y     +AD0 sched.o fork.o exec+AF8-domain.o panic.o printk.o +AFw
 	    cpu.o exit.o itimer.o time.o softirq.o resource.o +AFw
 	    sysctl.o capability.o ptrace.o timer.o user.o +AFw
-	    signal.o sys.o kmod.o workqueue.o pid.o freezer.o +AFw
+-	    signal.o sys.o kmod.o workqueue.o pid.o +AFw
 	    rcupdate.o extable.o params.o posix-timers.o +AFw
 	    kthread.o wait.o kfifo.o sys+AF8-ni.o posix-cpu-timers.o mutex.o +AFw
 	    hrtimer.o rwsem.o nsproxy.o srcu.o semaphore.o +AFw
+AEAAQA -24,6 +-24,7 +AEAAQA CFLAGS+AF8-REMOVE+AF8-sched+AF8-clock.o +AD0 -pg
 CFLAGS+AF8-REMOVE+AF8-sched.o +AD0 -mno-spe -pg
 endif
 
+-obj-+ACQ(CONFIG+AF8-FREEZER) +-+AD0 freezer.o
 obj-+ACQ(CONFIG+AF8-PROFILING) +-+AD0 profile.o
 obj-+ACQ(CONFIG+AF8-SYSCTL+AF8-SYSCALL+AF8-CHECK) +-+AD0 sysctl+AF8-check.o
 obj-+ACQ(CONFIG+AF8-STACKTRACE) +-+AD0 stacktrace.o
Index: linux-2.6.27-rc1-mm1/kernel/power/Kconfig
+AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0
--- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
+-+-+- linux-2.6.27-rc1-mm1/kernel/power/Kconfig
+AEAAQA -85,6 +-85,9 +AEAAQA config PM+AF8-SLEEP
 	depends on SUSPEND +AHwAfA HIBERNATION +AHwAfA XEN+AF8-SAVE+AF8-RESTORE
 	default y
 
+-config FREEZER
+-	def+AF8-bool PM+AF8-SLEEP +AHwAfA CGROUP+AF8-FREEZER
+-
 config SUSPEND
 	bool +ACI-Suspend to RAM and standby+ACI
 	depends on PM +ACYAJg ARCH+AF8-SUSPEND+AF8-POSSIBLE




--===============5458932296729009787==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5458932296729009787==--
