From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] implement s390 clone_with_pids syscall
Date: Tue, 10 Nov 2009 10:37:08 -0600
Message-ID: <20091110163708.GA19122@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This does the s390 hook for v11 of clone-with-pids.  This
patch is on top of the linux-cr tree.  A pair of patches
against user-cr is coming next to (a) make restart work
with the new clone-with-pids, and (b) demonstrate clone-with-pids
more generally using the ns_exec (namespace manipulation)
program.

The full kernel tree/changelog can be seen as branch cwp.2 at
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git

The user-space clone-with-pids glue for s390 (clone_s390x.c
from the user-cr package) is now:

struct pid_set {
	int num_pids;
	pid_t *pids;
};

typedef unsigned long long u64;
typedef unsigned int u32;
typedef int pid_t;
struct clone_args {
	u64 clone_flags_high;

	u64 child_stack_base;
	u64 child_stack_size;

	u64 parent_tid_ptr;
	u64 child_tid_ptr;

	u32 nr_pids;

	u32 reserved0;
	u64 reserved1;
};

 #define do_cwp(flags, pids, args, sz) \
( { \
  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_clone_with_pids); \
  register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
  register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
  register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
  register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
  register long int __result asm ("2"); \
  __asm__ __volatile__( \
	  " svc 0\n" /* do __NR_cwp syscall */ \
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

int clone_with_pids(int (*fn)(void *), void *child_stack,
			unsigned long stack_size, unsigned long flags,
			struct pid_set *target_pids, void *arg)
{
	struct clone_args clone_args, *ca = &clone_args;
	u64 *s;

	memset(ca, 0, sizeof(struct clone_args));
	ca->nr_pids = target_pids->num_pids;
	ca->child_stack_size = stack_size - 16;
	ca->child_stack_base = (u64) child_stack;
	if (child_stack) {
		s = (u64 *) (ca->child_stack_base + ca->child_stack_size);
		*--s = (u64) arg;
		*--s = (u64) fn;
		ca->child_stack_size -= 16;
	}

	return do_cwp(flags, target_pids->pids, ca,
				    sizeof(struct clone_args));
}

Changelog:
	Nov 09: fix compat code (thanks, Suka)
	Nov 10: use orig_gpr2, not gprs[2] for input arg 1
---
 arch/s390/kernel/compat_linux.c |   63 ++++++++++++++++++++++++++++++--------
 arch/s390/kernel/process.c      |   58 +++++++++++++++++++++++++++--------
 2 files changed, 94 insertions(+), 27 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index c6dc681..e26ad2c 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -821,20 +821,55 @@ asmlinkage long sys32_clone(void)
 asmlinkage long sys32_clone_with_pids(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
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
+	int rc;
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
+	/*
+	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
+	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
+	 * 	 higher word(s) of 'flags':
+	 *
+	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
+	 */
+	flags = flags_low;
+	parent_tid_ptr = (int *)kca.parent_tid_ptr;
+	child_tid_ptr =  (int *)kca.child_tid_ptr;
+
+	stack_size = (unsigned long)kca.child_stack_size;
+	child_stack = (unsigned long)kca.child_stack_base;
+	if (child_stack)
+		child_stack += stack_size;
+	else
+		child_stack = regs->gprs[15];
+
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
 }
 
 /*
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 263d3ab..865e791 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -250,20 +250,52 @@ SYSCALL_DEFINE0(clone)
 SYSCALL_DEFINE0(clone_with_pids)
 {
 	struct pt_regs *regs = task_pt_regs(current);
-	unsigned long clone_flags;
-	unsigned long newsp;
-	int __user *parent_tidptr, *child_tidptr;
-	void __user *upid_setp;
+	int rc;
+	int args_size;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
+	unsigned long flags_low;
+	struct clone_args __user *uca;
+	pid_t __user *pids;
+
+	flags_low = regs->orig_gpr2;
+	uca = (struct clone_args __user *)regs->gprs[3];
+	args_size = regs->gprs[4];
+	pids = (pid_t __user *)regs->gprs[5];
+
+	rc = fetch_clone_args_from_user(uca, args_size, &kca);
+	if (rc)
+		return rc;
 
-	clone_flags = regs->gprs[3];
-	newsp = regs->orig_gpr2;
-	parent_tidptr = (int __user *) regs->gprs[4];
-	child_tidptr = (int __user *) regs->gprs[5];
-	upid_setp = (void __user *) regs->gprs[7];
-	if (!newsp)
-		newsp = regs->gprs[15];
-	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
-			child_tidptr, upid_setp);
+	/*
+	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
+	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
+	 * 	 higher word(s) of 'flags':
+	 *
+	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
+	 */
+	flags = flags_low;
+	parent_tid_ptr = (int *)kca.parent_tid_ptr;
+	child_tid_ptr =  (int *)kca.child_tid_ptr;
+
+	stack_size = (unsigned long)kca.child_stack_size;
+	child_stack = (unsigned long)kca.child_stack_base;
+	if (child_stack)
+		child_stack += stack_size;
+	else
+		child_stack = regs->gprs[15];
+
+	/*
+	 * TODO: On 32-bit systems, clone_flags is passed in as 32-bit value
+	 * 	 to several functions. Need to convert clone_flags to 64-bit.
+	 */
+	return do_fork_with_pids(flags, child_stack, regs, stack_size,
+				parent_tid_ptr, child_tid_ptr, kca.nr_pids,
+				pids);
 }
 
 /*
-- 
1.6.1
