From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [C/R ARM v2][PATCH 2/3] ARM: Add the eclone system call
Date: Mon, 26 Apr 2010 17:43:42 -0400
Message-ID: <1272318223-28438-3-git-send-email-christofferdall__29745.0485792526$1272499072$gmane$org@christofferdall.dk>
References: <1272318223-28438-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272318223-28438-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
List-Id: containers.vger.kernel.org

In addition to doing everything that clone() system call does, the
eclone() system call:

	- allows additional clone flags (31 of 32 bits in the flags
	  parameter to clone() are in use)

	- allows user to specify a pid for the child process in its
	  active and ancestor pid namespaces.

Eclone is needed for restarting a process from a checkpoint. See more
in Documentation/eclone and refer to the original LKML posting:
http://lkml.org/lkml/2009/11/11/361

The new system call for ARM has number 366.

Changelog[v2]:
	- Removed __user attribute on long type

Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
Cc: libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/arm/include/asm/unistd.h  |    1 +
 arch/arm/kernel/calls.S        |    1 +
 arch/arm/kernel/entry-common.S |    6 ++++++
 arch/arm/kernel/sys_arm.c      |   39 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index dd2bf53..8dcb42a 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -392,6 +392,7 @@
 #define __NR_rt_tgsigqueueinfo		(__NR_SYSCALL_BASE+363)
 #define __NR_perf_event_open		(__NR_SYSCALL_BASE+364)
 #define __NR_recvmmsg			(__NR_SYSCALL_BASE+365)
+#define __NR_eclone			(__NR_SYSCALL_BASE+366)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 37ae301..80047c8 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -375,6 +375,7 @@
 		CALL(sys_rt_tgsigqueueinfo)
 		CALL(sys_perf_event_open)
 /* 365 */	CALL(sys_recvmmsg)
+		CALL(sys_eclone_wrapper)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
index 2c1db77..ba365dc 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -380,6 +380,12 @@ sys_clone_wrapper:
 		b	sys_clone
 ENDPROC(sys_clone_wrapper)
 
+sys_eclone_wrapper:
+		add	ip, sp, #S_OFF
+		str	ip, [sp, #0]
+		b	sys_eclone
+ENDPROC(sys_eclone_wrapper)
+
 sys_sigreturn_wrapper:
 		add	r0, sp, #S_OFF
 		b	sys_sigreturn
diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
index c235018..c23f133 100644
--- a/arch/arm/kernel/sys_arm.c
+++ b/arch/arm/kernel/sys_arm.c
@@ -54,6 +54,45 @@ asmlinkage int sys_clone(unsigned long clone_flags, unsigned long newsp,
 	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
 }
 
+asmlinkage int sys_eclone(unsigned flags_low, struct clone_args __user *uca,
+			  int args_size, pid_t __user *pids,
+			  struct pt_regs *regs)
+{
+	int rc;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tidp;
+	int __user *child_tidp;
+	unsigned long child_stack;
+	unsigned long stack_size;
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
+
+	/*
+	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
+	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
+	 * 	 higher word(s) of 'flags':
+	 *
+	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
+	 */
+	flags = flags_low;
+	parent_tidp = (int *)(unsigned long)kca.parent_tid_ptr;
+	child_tidp = (int *)(unsigned long)kca.child_tid_ptr;
+
+	stack_size = (unsigned long)kca.child_stack_size;
+	if (stack_size)
+		return -EINVAL;
+
+	child_stack = (unsigned long)kca.child_stack;
+	if (!child_stack)
+		child_stack = regs->ARM_sp;
+
+	return do_fork_with_pids(flags, child_stack, regs, stack_size,
+				parent_tidp, child_tidp, kca.nr_pids, pids);
+}
+
 asmlinkage int sys_vfork(struct pt_regs *regs)
 {
 	return do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, regs->ARM_sp, regs, 0, NULL, NULL);
-- 
1.5.6.5
