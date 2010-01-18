From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] add 32-bit checkpoint wrapper
Date: Mon, 18 Jan 2010 17:22:45 -0600
Message-ID: <20100118232245.GA31116@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

and get logfd from the right register (di is 5th arg)

With this patch on top of Oren's dec 6 patches, and my own patch from
earlier today, cr_tests pass on x86-32.

I will probably push these to cr-next tomorrow along with the needed
accompanying s390 and powerpc (from Nathan) changes.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint_32.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kernel/checkpoint_32.c b/arch/x86/kernel/checkpoint_32.c
index d5ea6a0..3ce9a81 100644
--- a/arch/x86/kernel/checkpoint_32.c
+++ b/arch/x86/kernel/checkpoint_32.c
@@ -19,6 +19,24 @@
 #include <linux/checkpoint_hdr.h>
 
 /*
+ * sys_checkpoint needs to be a ptregscall if sys_restart is
+ * one so self-checkpoint images can be restarted.
+ */
+long sys_checkpoint(struct pt_regs *regs)
+{
+	unsigned long flags;
+	int fd, logfd;
+	pid_t pid;
+
+	pid = regs->bx;
+	fd = regs->cx;
+	flags = regs->dx;
+	logfd = regs->si;
+
+	return do_sys_checkpoint(pid, fd, flags, logfd);
+}
+
+/*
  * sys_restart needs to access and modify the pt_regs structure to
  * restore the original state from the time of the checkpoint.
  */
@@ -31,7 +49,7 @@ long sys_restart(struct pt_regs *regs)
 	pid = regs->bx;
 	fd = regs->cx;
 	flags = regs->dx;
-	logfd = regs->di;
+	logfd = regs->si;
 
 	return do_sys_restart(pid, fd, flags, logfd);
 }
-- 
1.6.0.4
