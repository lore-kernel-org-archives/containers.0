From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] s390: clone_with_pids: fix compat wrapper
Date: Mon, 22 Jun 2009 10:30:52 -0500
Message-ID: <20090622153052.GA32517@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Martin Schwidefsky pointed out two problems with my compat
wrapper.  Define sys32_clone_with_pids() in compat_linux.c
instead of using a syscall wrapper.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/compat_linux.c   |   19 +++++++++++++++++++
 arch/s390/kernel/compat_wrapper.S |   10 ----------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 002c70d..cb4a304 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -821,6 +821,25 @@ asmlinkage long sys32_clone(void)
 		       parent_tidptr, child_tidptr);
 }
 
+asmlinkage long sys32_clone_with_pids(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags = regs->gprs[3] & 0xffffffffUL;
+	newsp = regs->orig_gpr2 & 0x7fffffffUL;
+	parent_tidptr = compat_ptr(regs->gprs[4]);
+	child_tidptr = compat_ptr(regs->gprs[5]);
+	upid_setp = compat_ptr(regs->gprs[7]);
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0,
+		       parent_tidptr, child_tidptr, upid_setp);
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index bf13315..c2228b2 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1837,13 +1837,3 @@ sys_restore_wrapper:
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
 	jg	compat_sys_restore
-
-	.globl sys_clone_with_pids_wrapper
-sys_clone_with_pids_wrapper:
-	llgfr	%r2,%r2			# unsigned long
-	llgfr	%r3,%r3			# unsigned long
-	llgtr	%r4,%r4			# int *
-	llgtr	%r5,%r5			# int *
-	llgtr	%r6,%r6			# void *
-	llgtr	%r7,%r7			# void *
-	jg	compat_sys_clone_with_pids
-- 
1.6.1
