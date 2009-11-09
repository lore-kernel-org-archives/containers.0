From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v11][PATCH 8/9] Define clone_with_pids() syscall
Date: Mon, 9 Nov 2009 14:37:19 -0600
Message-ID: <20091109203719.GA14448__33515.3609900319$1257799099$gmane$org@us.ibm.com>
References: <20091105053053.GA11289@us.ibm.com>
	<20091105054124.GH16142@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091105054124.GH16142-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Here is a stab at the s390 syscall.

From f710be4f1296d50551210bcc9ff6ba25d288bc46 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 6 Nov 2009 19:03:43 -0500
Subject: [PATCH 1/1] implement s390 clone_with_pids syscall

This does the s390 hook for v11 of clone-with-pids.

I've got a program using the syscall successfully passing
args to the child function and continuing to run - but I
haven't yet gotten that hooked into user-cr/restart.c
successfully.

The core of my user-space code to use it is:

int do_child(void *arg)
{
	int iarg = (int ) arg;

	printf("here i am, i was passed %d, my tid is %d\n", iarg, gettid());
	return 0;
}

 #define do_cwp(flags, pids, args, sz) \
( { \
	register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
	register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
	register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
	register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
	register unsigned long int __result asm ("2"); \
	__asm__ __volatile__( \
		" lghi %%r1,%5\n" /* put __NR_cwp in r1 for svc 0 */ \
		" svc 0\n" /* do __NR_cwp syscall */ \
		" ltgr %%r2,%%r2\n" /* returned 0? */ \
		" jnz 1f\n" /* if not goto label 1 */ \
		" lg %%r3,0(%%r15)\n"   /* get fnarg off stack into arg 1 */ \
		" lg %%r2,8(%%r15)\n"   /* get fn off stack into r3 for basr*/ \
		" lgr %%r1,%%r15\n" /* tmp store old stack pointer */ \
		" aghi %%r15,-160\n" /* move the stack */ \
		" stg %%r1,0(%%r15)\n" /* and save old stack pointer */ \
		" basr %%r14,%%r3\n" /* call fn(arg) */ \
		" svc 1\n"  /* call exit */ \
		" 1:\n" \
		: "=d" (__result) \
		: "0" (__r2), "d" (__r3), "d" (__r4), "d" (__r5), \
		  "i" (__NR_clone_with_pids) \
		: "1", "cc", "memory"); \
	__result; \
} )

int clone_with_pids(int (*fn)(void *), int flags, int nrpids, int *pids,
		    void *fnarg)
{
	long retval;
	struct clone_args clone_args, *ca = &clone_args;
	int stacksize;
	void *sb;
	u64 *s;
	int i;

	memset(ca, 0, sizeof(struct clone_args));
	stacksize = 4*getpagesize();
	sb  = (void *) malloc(stacksize);
	if (!sb) {
		perror("malloc");
		_exit(1);
	}

	ca->child_stack_base = (u64) sb;
	ca->child_stack_size = stacksize-8;
	s = (u64 *)(sb + ca->child_stack_size);
	*--s = (u64)fnarg;
	*--s = (u64)fn;
	ca->child_stack_size -= 16;
	ca->nr_pids = nrpids;
	retval = do_cwp(flags, pids, ca, sizeof(struct clone_args));

	return retval;
}

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/unistd.h  |    3 +-
 arch/s390/kernel/compat_linux.c |   50 ++++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/process.c      |   51 +++++++++++++++++++++++++++++++++++++++
 arch/s390/kernel/syscalls.S     |    1 +
 4 files changed, 104 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index cb5232d..ae9474e 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -269,7 +269,8 @@
 #define	__NR_pwritev		329
 #define __NR_rt_tgsigqueueinfo	330
 #define __NR_perf_event_open	331
-#define NR_syscalls 332
+#define __NR_clone_with_pids	332
+#define NR_syscalls 333
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 0debcec..1750fae 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -762,6 +762,56 @@ asmlinkage long sys32_write(unsigned int fd, char __user * buf, size_t count)
 	return sys_write(fd, buf, count);
 }
 
+asmlinkage long sys32_clone_with_pids(void)
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
+	flags_low = regs->gprs[2] & 0xffffffffUL;
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
+	child_stack = (unsigned long)kca.child_stack_base + stack_size;
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
+}
+
 /*
  * 31 bit emulation wrapper functions for sys_fadvise64/fadvise64_64.
  * These need to rewrite the advise values for POSIX_FADV_{DONTNEED,NOREUSE}
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 5417eb5..e27a1b4 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -241,6 +241,57 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 		       parent_tidptr, child_tidptr);
 }
 
+SYSCALL_DEFINE0(clone_with_pids)
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
+	flags_low = regs->gprs[2];
+	uca = (struct clone_args __user *)regs->gprs[3];
+	args_size = regs->gprs[4];
+	pids = (pid_t __user *)regs->gprs[5];
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
index 30eca07..c6dc240 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -340,3 +340,4 @@ SYSCALL(sys_preadv,sys_preadv,compat_sys_preadv_wrapper)
 SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
 SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo_wrapper) /* 330 */
 SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
+SYSCALL(sys_clone_with_pids,sys_clone_with_pids,sys_clone_with_pids_wrapper)
-- 
1.6.1
