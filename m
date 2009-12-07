From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: [x86_32] sys_restore to use ptregs prototype
Date: Mon, 07 Dec 2009 14:55:07 -0600
Message-ID: <1260219307.7151.3.camel@localhost.localdomain>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
	<4B1C357C.2090003@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B1C357C.2090003-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


> > * Changes the syscall prototype and definition to accept the pt_regs
> >   struct as an argument (into %eax register).
> 
> I forgot to mention that this of course breaks s390 and ppc: you
> need to provide an arch-dependent sys_restart() similar to how it's
> done here.

Thanks, here's the fixup for powerpc.


From 981dca4f3a879827d6e19a0cf32c7fd25b08a878 Mon Sep 17 00:00:00 2001
From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date: Mon, 7 Dec 2009 14:51:13 -0600
Subject: [PATCH] checkpoint/powerpc: fix up restart code for ptregscall semantics

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/kernel/process.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 457c269..f9da9eb 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -30,6 +30,7 @@
 #include <linux/init_task.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/checkpoint.h>
 #include <linux/mqueue.h>
 #include <linux/hardirq.h>
 #include <linux/utsname.h>
@@ -990,6 +991,25 @@ out:
 	return error;
 }
 
+int sys_restart(unsigned long a0, unsigned long a1, unsigned long a2,
+	       unsigned long a3, unsigned long a4, unsigned long a5,
+	       struct pt_regs *regs)
+{
+	unsigned long flags;
+	pid_t pid;
+	int logfd;
+	int fd;
+
+	CHECK_FULL_REGS(regs);
+
+	pid = a0;
+	fd = a1;
+	flags = a2;
+	logfd = a3;
+
+	return do_sys_restart(pid, fd, flags, logfd);
+}
+
 #ifdef CONFIG_IRQSTACKS
 static inline int valid_irq_stack(unsigned long sp, struct task_struct *p,
 				  unsigned long nbytes)
-- 
1.6.0.6
