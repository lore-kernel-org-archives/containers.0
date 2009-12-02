From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] remove clone_with_pids remnants from s390
Date: Wed, 2 Dec 2009 12:15:39 -0600
Message-ID: <20091202181539.GA14388@us.ibm.com>
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

and fix syscall numbers

c/r still doesn't work with this patch, but that's a separate
issue.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h    |    6 +++---
 arch/s390/kernel/compat_linux.c   |   19 -------------------
 arch/s390/kernel/compat_wrapper.S |    1 +
 arch/s390/kernel/syscalls.S       |    1 -
 4 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index cb8e032..5e6df5a 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -270,9 +270,9 @@
 #define __NR_rt_tgsigqueueinfo	330
 #define __NR_perf_event_open	331
 #define __NR_eclone		332
-#define __NR_checkpoint		332
-#define __NR_restart		333
-#define NR_syscalls 334
+#define __NR_checkpoint		333
+#define __NR_restart		334
+#define NR_syscalls 335
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 3ab81e5..76b7690 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -779,25 +779,6 @@ asmlinkage long sys32_clone(void)
 		       parent_tidptr, child_tidptr);
 }
 
-asmlinkage long sys32_clone_with_pids(void)
-{
-	struct pt_regs *regs = task_pt_regs(current);
-	unsigned long clone_flags;
-	unsigned long newsp;
-	int __user *parent_tidptr, *child_tidptr;
-	void __user *upid_setp;
-
-	clone_flags = regs->gprs[3] & 0xffffffffUL;
-	newsp = regs->orig_gpr2 & 0x7fffffffUL;
-	parent_tidptr = compat_ptr(regs->gprs[4]);
-	child_tidptr = compat_ptr(regs->gprs[5]);
-	upid_setp = compat_ptr(regs->gprs[7]);
-	if (!newsp)
-		newsp = regs->gprs[15];
-	return do_fork_with_pids(clone_flags, newsp, regs, 0,
-		       parent_tidptr, child_tidptr, upid_setp);
-}
-
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index 8d0ba6a..cf31567 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1877,3 +1877,4 @@ sys_restore_wrapper:
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
 	jg	compat_sys_restore
+
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index c7ca3d0..ff222e1 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -343,4 +343,3 @@ SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
 SYSCALL(sys_eclone,sys_eclone,sys_eclone_wrapper)
 SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper)
 SYSCALL(sys_restart,sys_restart,sys_restore_wrapper)
-SYSCALL(sys_clone_with_pids,sys_clone_with_pids,sys_clone_with_pids_wrapper)
-- 
1.6.1
