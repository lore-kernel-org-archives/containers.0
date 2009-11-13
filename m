From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-cr] implement s390 eclone syscall
Date: Fri, 13 Nov 2009 09:56:47 -0600
Message-ID: <20091113155647.GA22321@us.ibm.com>
References: <1258089682-9934-1-git-send-email-serue@us.ibm.com>
	<20091113084730.GA4839@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091113084730.GA4839-Pmgahw53EmNLmI7Nx2oIsGnsbthNF6/HVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Heiko Carstens (heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> On Thu, Nov 12, 2009 at 11:21:20PM -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > +asmlinkage long sys32_eclone(void)
> > +{
> > +	int rc;
> > +	struct pt_regs *regs = task_pt_regs(current);
> > +	int args_size;
> > +	struct clone_args kca;
> > +	unsigned long flags;
> > +	int __user *parent_tid_ptr;
> > +	int __user *child_tid_ptr;
> > +	unsigned long __user child_stack;
> > +	unsigned long stack_size;
> > +	unsigned int flags_low;
> > +	struct clone_args __user *uca;
> > +	pid_t __user *pids;
> 
> Would you mind converting this to a syscall which takes its parameters via
> registers?
> You might have a look at git commit 2d70ca23f86647e076e3a8b64b3a90e583b894d5
> "[S390] Convert sys_clone to function with parameters."

Thanks!  That does end up looking much nicer.

New version attached.

> > +	flags_low = regs->orig_gpr2 & 0xffffffffUL;
> > +	uca = compat_ptr(regs->gprs[3]);
> > +	args_size = regs->gprs[4] & 0xffffffffUL;
> > +	pids = compat_ptr(regs->gprs[5]);
> > +
> > +	rc = fetch_clone_args_from_user(uca, args_size, &kca);
> > +	if (rc)
> > +		return rc;
> > +
> > +	if (kca.clone_flags_high)
> > +		return -EINVAL;
> > +	flags = flags_low;
> > +	parent_tid_ptr = (int __user *) kca.parent_tid_ptr;
> > +	child_tid_ptr =  (int __user *) kca.child_tid_ptr;
> 
> _If_ the kernel uses these two pointers to access user space then the most
> significant bit of the pointer values must be cleared by using compat_ptr().

It does, but IIUC I no longer need that compat function at all, since
I'm now using a simple sys_eclone_wrapper in
arch/s390/kernel/compat_wrapper.S.

thanks,
-serge

From 6c0a067eb2048b33a313244a627a47ffff351928 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 6 Nov 2009 19:03:43 -0500
Subject: [PATCH 1/1] implement s390 eclone syscall

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
	Nov 13: As suggested by Heiko, convert eclone to take its
		parameters via registers.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h    |    3 +-
 arch/s390/kernel/compat_wrapper.S |    8 +++++++
 arch/s390/kernel/process.c        |   40 +++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/syscalls.S       |    1 +
 4 files changed, 51 insertions(+), 1 deletions(-)

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
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index cbd9901..816ae61 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1849,6 +1849,14 @@ sys_clone_wrapper:
 	llgtr	%r5,%r5			# int *
 	jg	sys_clone		# branch to system call
 
+	.globl	sys_eclone_wrapper
+sys_eclone_wrapper:
+	llgfr	%r2,%r2			# unsigned int
+	llgtr	%r3,%r3			# struct clone_args *
+	lgfr	%r4,%r4			# int
+	llgtr	%r5,%r5			# pid_t *
+	jg	sys_eclone		# branch to system call
+
 	.globl	sys32_execve_wrapper
 sys32_execve_wrapper:
 	llgtr	%r2,%r2			# char *
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 5417eb5..817069e 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -241,6 +241,46 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
+		uca, int, args_size, pid_t __user *, pids)
+{
+	int rc;
+	struct pt_regs *regs = task_pt_regs(current);
+	struct clone_args kca;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long flags;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
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
