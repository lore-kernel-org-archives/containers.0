From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] clone_with_pids: define the s390 syscall
Date: Mon, 15 Jun 2009 12:05:24 -0500
Message-ID: <20090615170524.GA14950@us.ibm.com>
References: <20090615170443.GA14808@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090615170443.GA14808-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hook up the clone_with_pids system call for s390x.  clone_with_pids()
takes an additional argument over clone(), which we pass in through
register 7.  Stub code for using the syscall looks like:

struct target_pid_set {
        int num_pids;
        pid_t *target_pids;
        unsigned long flags;
};

        register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);\
        register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);\
        register unsigned long int __r4 asm ("4") = (unsigned long int)(NULL); \
        register unsigned long int __r5 asm ("5") = (unsigned long int)(NULL); \
        register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL); \
        register unsigned long int __r7 asm ("7") = (unsigned long int)(setp); \
        register unsigned long int __result asm ("2"); \
        __asm__ __volatile__( \
                " lghi %%r1,332\n" \
                " svc 0\n" \
                : "=d" (__result) \
                : "0" (__r2), "d" (__r3), \
                  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7) \
                : "1", "cc", "memory" \
        ); \
                __result; \
        })

        struct target_pid_set pid_set;
        int pids[1] = { 19799 };
        pid_set.num_pids = 1;
        pid_set.target_pids = &pids[0];
        pid_set.flags = 0;

        rc = do_clone_with_pids(topstack, clone_flags, setp);
	if (rc == 0)
		printf("Child\n");
	else if (rc > 0)
		printf("Parent: child pid %d\n", rc);
	else
		printf("Error %d\n", rc);

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h    |    3 ++-
 arch/s390/kernel/compat_wrapper.S |   10 ++++++++++
 arch/s390/kernel/process.c        |   19 +++++++++++++++++++
 3 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index 3d22f17..d2facab 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -269,7 +269,8 @@
 #define	__NR_pwritev		329
 #define __NR_checkpoint		330
 #define __NR_restart		331
-#define NR_syscalls 332
+#define __NR_clone_with_pids	332
+#define NR_syscalls 333
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index c2228b2..bf13315 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1837,3 +1837,13 @@ sys_restore_wrapper:
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
 	jg	compat_sys_restore
+
+	.globl sys_clone_with_pids_wrapper
+sys_clone_with_pids_wrapper:
+	llgfr	%r2,%r2			# unsigned long
+	llgfr	%r3,%r3			# unsigned long
+	llgtr	%r4,%r4			# int *
+	llgtr	%r5,%r5			# int *
+	llgtr	%r6,%r6			# void *
+	llgtr	%r7,%r7			# void *
+	jg	compat_sys_clone_with_pids
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index a3acd8e..fa187bf 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -246,6 +246,25 @@ SYSCALL_DEFINE0(clone)
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE0(clone_with_pids)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr, *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags = regs->gprs[3];
+	newsp = regs->orig_gpr2;
+	parent_tidptr = (int __user *) regs->gprs[4];
+	child_tidptr = (int __user *) regs->gprs[5];
+	upid_setp = (void __user *) regs->gprs[7];
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
-- 
1.6.1
