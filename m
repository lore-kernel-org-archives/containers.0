From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: clone-with-pids for s390
Date: Thu, 11 Jun 2009 13:01:49 -0500
Message-ID: <20090611180149.GA31458@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tThc/1wpZn/ma/RB"
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Ok, attached is a simpler version of the clone-with-pid
userspace, which works for me on s390 with the following
patch on top of ckpt-v16-x86.

-serge

From 80f9ab794dbb546aa8e33447403cc3717b448b0a Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 10 Jun 2009 15:06:25 -0400
Subject: [PATCH 1/1] s390: implement clone_with_pids()

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h    |    3 ++-
 arch/s390/kernel/compat_linux.c   |   19 +++++++++++++++++++
 arch/s390/kernel/compat_wrapper.S |    8 ++++++++
 arch/s390/kernel/process.c        |   19 +++++++++++++++++++
 arch/s390/kernel/syscalls.S       |    1 +
 5 files changed, 49 insertions(+), 1 deletions(-)

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
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 002c70d..8d5ed5c 100644
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
+	upid_setp = (void __user *)regs->gprs[6];
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index ece87c8..c874453 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1835,3 +1835,11 @@ sys_restore_wrapper:
 	lgfr	%r2,%r2			# int
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
+
+	.globl sys_clone_with_pids_wrapper
+sys_clone_with_pids_wrapper:
+	llgfr	%r2,%r2			# unsigned long
+	llgfr	%r3,%r3			# unsigned long
+	llgtr	%r4,%r4			# int *
+	llgtr	%r5,%r5			# int *
+	llgtr	%r6,%r6			# upid_setp *
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index a3acd8e..db6d454 100644
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
+	upid_setp = (void __user *)regs->gprs[6];
+	if (!newsp)
+		newsp = regs->gprs[15];
+	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index e755e93..1d638f5 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -340,3 +340,4 @@ SYSCALL(sys_preadv,sys_preadv,compat_sys_preadv_wrapper)
 SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
 SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper) /* 330 */
 SYSCALL(sys_restart,sys_restart,sys_restore_wrapper)
+SYSCALL(sys_clone_with_pids,sys_clone_with_pids,sys_clone_with_pids_wrapper)
-- 
1.6.1


--tThc/1wpZn/ma/RB
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="cwp-simple.c"

#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <malloc.h>

#define CLONE_NEWPID		0x20000000
#ifndef __NR_gettid
#ifdef __x86__
#define __NR_gettid		224
#elif __s390__
#define __NR_gettid		236
#else
#error __NR_gettid undefined
#endif
#endif

#ifndef __NR_clone_with_pids
#ifdef __x86__
#define __NR_clone_with_pids	335
#elif __s390__
#define __NR_clone_with_pids	332
#else
#error __NR_clone_with_pids undefined
#endif
#endif
/*
 * TODO: getpid() in child returns pid of parent for some reason gettid()
 * 	 returns correct pid (i.e 1 if CLONE_NEWPID or 19799 otherwise)
 */
int gettid()
{
	int rc;

	rc = syscall(__NR_gettid, 0, 0, 0);
	if (rc < 0) {
		printf("rc %d, errno %d\n", rc, errno);
		fflush(stdout);
	}
	return rc;
}

struct target_pid_set {
	int num_pids;
	pid_t *target_pids;
	unsigned long flags;
};

main()
{
	int rc;
	int clone_flags;
	struct target_pid_set pid_set;
	int stacksize = 4 * getpagesize();
	void *childsp, *topstack;
	
	int pids[1] = { 19799 };
	
	childsp = malloc(stacksize);
	if (!childsp)
		return -1;
	topstack = childsp + stacksize;

	pid_set.num_pids = 1;
	pid_set.target_pids = &pids[0];
	pid_set.flags = 0;

	//clone_flags = (CLONE_NEWPID| CLONE_FS | CLONE_FILES | SIGCHLD);
	clone_flags = ( CLONE_FS | CLONE_FILES | SIGCHLD);

	printf("Parent: Call clone_with_pids() for &pid_set %p\n", &pid_set);

	rc = syscall(__NR_clone_with_pids, topstack, clone_flags, NULL,
			NULL, &pid_set);
			//NULL, NULL);
	if (rc == 0) {
		printf("Child: tid %d\n", gettid());
		_exit(0);
	} else if (rc > 0) {
		printf("Parent: child pid %d\n", rc);
		_exit(0);
	} else {
		printf("myclone() failed, rc %d, errno %d\n", rc, errno);
	}
}

--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--tThc/1wpZn/ma/RB--
