From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH linux-cr] implement s390 eclone syscall
Date: Thu, 12 Nov 2009 23:24:44 -0600
Message-ID: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This patch implements the s390 hook for sys_eclone.

The user-space clone-with-pids glue for s390 (clone_s390x.c
from the user-cr package) is now:

struct pid_set {
	int num_pids;
	pid_t *pids;
};

 #define do_eclone(flags, pids, args, sz) \
( { \
  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_eclone); \
  register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
  register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
  register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
  register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
  register long int __result asm ("2"); \
  __asm__ __volatile__( \
	  " svc 0\n" /* do __NR_eclone syscall */ \
	  " ltgr %%r2,%%r2\n" /* returned 0? */ \
	  " jnz 1f\n" /* if not goto label 1 */ \
	  " lg %%r3,0(%%r15)\n"   /* get fnarg off stack into arg 1 */ \
	  " lg %%r2,8(%%r15)\n"   /* get fn off stack int r3 basr*/ \
	  " lgr %%r1,%%r15\n" /* tmp store old stack pointer */ \
	  " aghi %%r15,-160\n" /* move the stack */ \
	  " stg %%r1,0(%%r15)\n" /* and save old stack pointer */ \
	  " basr %%r14,%%r3\n" /* call fn(arg) */ \
	  " svc 1\n"  /* call exit */ \
	  " 1:\n" \
	  : "=d" (__result) \
	  : "d" (__r1), "0" (__r2), "d" (__r3), "d" (__r4), "d" (__r5) \
	  : "memory"); \
	__result; \
} )
int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
			struct pid_set *target_pids, void *arg)
{
	struct clone_args clone_args, *ca = &clone_args;
	u64 *s;

	memset(ca, 0, sizeof(struct clone_args));
	ca->nr_pids = target_pids->num_pids;
	if (!child_stack) {
		/* we could pass in null and then in eclone not
		 * call exit if child_stack was null, but we'll
		 * just malloc here */
		int sz = 4*getpagesize();
		child_stack = malloc(sz);
		if (!child_stack)
			return -ENOMEM;
		child_stack += sz; /* we'll decrement before assigning */
	}
	ca->child_stack = (u64) child_stack;
	s = (u64 *) ca->child_stack;
	*--s = (u64) arg;
	*--s = (u64) fn;
	ca->child_stack -= 16;
	return do_eclone(flags, target_pids->pids, ca,
				    sizeof(struct clone_args));
}

Changelog:
	Nov 12: switch to latest (Nov 12) eclone format
	Nov 10: use orig_gpr2, not gprs[2] for input arg 1

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h  |    3 +-
 arch/s390/kernel/compat_linux.c |   47 ++++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/process.c      |   48 +++++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/syscalls.S     |    1 +
 4 files changed, 98 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index cb5232d..cbf6c7c 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -269,7 +269,8 @@
 #define	__NR_pwritev		329
 #define __NR_rt_tgsigqueueinfo	330
 #define __NR_perf_event_open	331
-#define NR_syscalls 332
+#define __NR_eclone		332
+#define NR_syscalls 333
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 0debcec..c3dc6bd 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -762,6 +762,53 @@ asmlinkage long sys32_write(unsigned int fd, char __user * buf, size_t count)
 	return sys_write(fd, buf, count);
 }
 
+asmlinkage long sys32_eclone(void)
+{
+	int rc;
+	struct pt_regs *regs = task_pt_regs(current);
+	int args_size;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
+	unsigned int flags_low;
+	struct clone_args __user *uca;
+	pid_t __user *pids;
+
+	flags_low = regs->orig_gpr2 & 0xffffffffUL;
+	uca = compat_ptr(regs->gprs[3]);
+	args_size = regs->gprs[4] & 0xffffffffUL;
+	pids = compat_ptr(regs->gprs[5]);
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
+
+	if (kca.clone_flags_high)
+		return -EINVAL;
+	flags = flags_low;
+	parent_tid_ptr = (int __user *) kca.parent_tid_ptr;
+	child_tid_ptr =  (int __user *) kca.child_tid_ptr;
+
+	stack_size = (unsigned long) kca.child_stack_size;
+	if (stack_size)
+		return -EINVAL;
+
+	child_stack = (unsigned long) kca.child_stack;
+	if (!child_stack)
+		child_stack = regs->gprs[15];
+
+	/*
+	 * TODO: On 32-bit systems, clone_flags is passed in as 32-bit value
+	 * 	 to several functions. Need to convert clone_flags to 64-bit.
+	 */
+	return do_fork_with_pids(flags, child_stack, regs, stack_size,
+				parent_tid_ptr, child_tid_ptr, kca.nr_pids,
+				pids);
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 5417eb5..51f11a1 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -241,6 +241,54 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE0(eclone)
+{
+	int rc;
+	struct pt_regs *regs = task_pt_regs(current);
+	int args_size;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
+	unsigned int flags_low;
+	struct clone_args __user *uca;
+	pid_t __user *pids;
+
+	flags_low = regs->orig_gpr2;
+	uca = (struct clone_args __user *) regs->gprs[3];
+	args_size = regs->gprs[4];
+	pids = (pid_t __user *) regs->gprs[5];
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
+
+	if (kca.clone_flags_high)
+		return -EINVAL;
+
+	flags = flags_low;
+	parent_tid_ptr = (int __user *) kca.parent_tid_ptr;
+	child_tid_ptr =  (int __user *) kca.child_tid_ptr;
+
+	stack_size = (unsigned long) kca.child_stack_size;
+	if (stack_size)
+		return -EINVAL;
+
+	child_stack = (unsigned long) kca.child_stack;
+	if (!child_stack)
+		child_stack = regs->gprs[15];
+
+	/*
+	 * TODO: On 32-bit systems, clone_flags is passed in as 32-bit value
+	 * 	 to several functions. Need to convert clone_flags to 64-bit.
+	 */
+	return do_fork_with_pids(flags, child_stack, regs, stack_size,
+				parent_tid_ptr, child_tid_ptr, kca.nr_pids,
+				pids);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 30eca07..fb8708d 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -340,3 +340,4 @@ SYSCALL(sys_preadv,sys_preadv,compat_sys_preadv_wrapper)
 SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
 SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo_wrapper) /* 330 */
 SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
+SYSCALL(sys_eclone,sys_eclone,sys_eclone_wrapper)
-- 
1.6.1
