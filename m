From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Wed, 18 Nov 2009 16:48:38 -0800
Message-ID: <20091119004838.AD278DE0@kernel>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


This is still a bit rough, but I figured I'd post it for kicks.

Most of the process.c stuff is copy-n-paste with i386 and needs
to get consolidated.  I also need to give this the new name.

I'd appreciate anybody that knows inline assembly well to make
sure that I'm not being a complete doofus with this call below.
This seems to work, but I'm not confident it is the best way.

int clone_with_pids(long flags_low, struct clone_args *clone_args, long args_size,
                 int *pids)
{
        long retval;

        __asm__  __volatile__(
                 "movq %3, %%r10\n\t"           /* pids in r10*/
                 "pushq %%rbp\n\t"              /* save value of ebp */
                :
                :"D" (flags_low), /* rdi */
                 "S" (clone_args),/* rsi */
                 "d" (args_size), /* rdx */
                 "a" (pids)       /* use rax, which gets moved to r10 */
                );

        __asm__ __volatile__(
                 "syscall\n\t"  /* Linux/x86_64 system call */
                 "testq %0,%0\n\t"      /* check return value */
                 "jne 1f\n\t"           /* jump if parent */
                 "popq %%rbx\n\t"       /* get subthread function */
                 "call *%%rbx\n\t"      /* start subthread function */
                 "movq %2,%0\n\t"
                 "syscall\n"            /* exit system call: exit subthread */
                 "1:\n\t"
                 "popq %%rbp\t"         /* restore parent's ebp */
                :"=a" (retval)
                :"0" (__NR_clone3), "i" (__NR_exit)
                :"ebx", "ecx", "edx"
                );

        if (retval < 0) {
                errno = -retval;
                retval = -1;
        }
        return retval;
}


---

 linux-2.6.git-dave/arch/x86/include/asm/syscalls.h  |    5 ++
 linux-2.6.git-dave/arch/x86/include/asm/unistd_64.h |    2 
 linux-2.6.git-dave/arch/x86/kernel/entry_64.S       |    8 +++
 linux-2.6.git-dave/arch/x86/kernel/process_64.c     |   49 ++++++++++++++++++++
 linux-2.6.git-dave/kernel/fork.c                    |   18 +++++++
 5 files changed, 82 insertions(+)

diff -puN arch/x86/include/asm/syscalls.h~cwp-x86_64 arch/x86/include/asm/syscalls.h
--- linux-2.6.git/arch/x86/include/asm/syscalls.h~cwp-x86_64	2009-11-18 16:37:09.000000000 -0800
+++ linux-2.6.git-dave/arch/x86/include/asm/syscalls.h	2009-11-18 16:37:09.000000000 -0800
@@ -78,6 +78,11 @@ asmlinkage long sys_iopl(unsigned int, s
 asmlinkage long sys_clone(unsigned long, unsigned long,
 			  void __user *, void __user *,
 			  struct pt_regs *);
+asmlinkage long sys_clone_with_pids(unsigned int flags_low,
+				struct clone_args * __user cargs,
+				int cargs_size,
+				pid_t * __user pids,
+				struct pt_regs *pt_regs);
 asmlinkage long sys_execve(char __user *, char __user * __user *,
 			   char __user * __user *,
 			   struct pt_regs *);
diff -puN arch/x86/include/asm/unistd_64.h~cwp-x86_64 arch/x86/include/asm/unistd_64.h
--- linux-2.6.git/arch/x86/include/asm/unistd_64.h~cwp-x86_64	2009-11-18 16:37:09.000000000 -0800
+++ linux-2.6.git-dave/arch/x86/include/asm/unistd_64.h	2009-11-18 16:37:09.000000000 -0800
@@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
 __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_counter_open			298
 __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
+#define __NR_clone_with_pids			299
+__SYSCALL(__NR_clone_with_pids, stub_clone_with_pids)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff -puN arch/x86/kernel/entry_64.S~cwp-x86_64 arch/x86/kernel/entry_64.S
--- linux-2.6.git/arch/x86/kernel/entry_64.S~cwp-x86_64	2009-11-18 16:37:09.000000000 -0800
+++ linux-2.6.git-dave/arch/x86/kernel/entry_64.S	2009-11-18 16:37:09.000000000 -0800
@@ -684,6 +684,13 @@ END(system_call)
 
 /*
  * Certain special system calls that need to save a complete full stack frame.
+ *
+ * 'arg' should be the register that pt_regs will show up in when
+ * 'func' is called.  Using normal calling conventions, this is:
+ *
+ * 	func(%rdi, %rsi, %rdx, %rcx, %r8, %r9)
+ *
+ * So, if you want pt_regs as the third argument, use %rdx.
  */
 	.macro PTREGSCALL label,func,arg
 ENTRY(\label)
@@ -704,6 +711,7 @@ END(\label)
 	PTREGSCALL stub_vfork, sys_vfork, %rdi
 	PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
+	PTREGSCALL stub_clone_with_pids, sys_clone_with_pids, %r8
 
 ENTRY(ptregscall_common)
 	DEFAULT_FRAME 1 8	/* offset 8: return address */
diff -puN arch/x86/kernel/process_64.c~cwp-x86_64 arch/x86/kernel/process_64.c
--- linux-2.6.git/arch/x86/kernel/process_64.c~cwp-x86_64	2009-11-18 16:37:09.000000000 -0800
+++ linux-2.6.git-dave/arch/x86/kernel/process_64.c	2009-11-18 16:37:09.000000000 -0800
@@ -534,6 +534,55 @@ sys_clone(unsigned long clone_flags, uns
 	return do_fork(clone_flags, newsp, regs, 0, parent_tid, child_tid);
 }
 
+asmlinkage long
+sys_clone_with_pids(unsigned int flags_low, struct clone_args * __user cargs,
+		int args_size, pid_t * __user pids, struct pt_regs *pt_regs)
+{
+	int rc;
+	struct clone_args kca;
+	unsigned long flags;
+	int __user *parent_tid_ptr;
+	int __user *child_tid_ptr;
+	unsigned long __user child_stack;
+	unsigned long stack_size;
+
+	printk("%s() 0\n", __func__);
+	rc = fetch_clone_args_from_user(cargs, args_size, &kca);
+	if (rc) {
+		printk("%s() 1\n", __func__);
+		return rc;
+	}
+
+	/*
+	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
+	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
+	 * 	 higher word(s) of 'flags':
+	 *
+	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
+	 */
+	printk("%s() 2\n", __func__);
+	flags = flags_low;
+	parent_tid_ptr = (int *)kca.parent_tid_ptr;
+	child_tid_ptr =  (int *)kca.child_tid_ptr;
+
+	printk("%s() 3\n", __func__);
+	stack_size = (unsigned long)kca.child_stack_size;
+	child_stack = (unsigned long)kca.child_stack_base + stack_size;
+
+	printk("%s() 4\n", __func__);
+	if (!child_stack)
+		child_stack = pt_regs->sp;
+	printk("%s() 5\n", __func__);
+
+	/*
+	 * TODO: On 32-bit systems, clone_flags is passed in as 32-bit value
+	 * 	 to several functions. Need to convert clone_flags to 64-bit.
+	 */
+	return do_fork_with_pids(flags, child_stack, pt_regs, stack_size,
+				parent_tid_ptr, child_tid_ptr, kca.nr_pids,
+				pids);
+}
+
 unsigned long get_wchan(struct task_struct *p)
 {
 	unsigned long stack;
diff -puN kernel/fork.c~cwp-x86_64 kernel/fork.c
--- linux-2.6.git/kernel/fork.c~cwp-x86_64	2009-11-18 16:37:09.000000000 -0800
+++ linux-2.6.git-dave/kernel/fork.c	2009-11-18 16:37:09.000000000 -0800
@@ -1359,8 +1359,10 @@ static pid_t *copy_target_pids(int unum_
 
 	if (!unum_pids)
 		return NULL;
+	printk("%s(%d, %p) 0\n", __func__, unum_pids, upids);
 
 	knum_pids = task_pid(current)->level + 1;
+	printk("%s(%d, %p) knum_pids: %d\n", __func__, unum_pids, upids, knum_pids);
 	if (unum_pids > knum_pids)
 		return ERR_PTR(-EINVAL);
 
@@ -1407,6 +1409,7 @@ static pid_t *copy_target_pids(int unum_
 	size = unum_pids * sizeof(pid_t);
 
 	rc = copy_from_user(&target_pids[j], upids, size);
+	printk("%s() copy(%p, %p, %d) rc: %d\n", __func__, &target_pids[j], upids, size, rc);
 	if (rc) {
 		rc = -EFAULT;
 		goto out_free;
@@ -1467,6 +1470,8 @@ long do_fork_with_pids(unsigned long clo
 	long nr;
 	pid_t *target_pids;
 
+	if (upids)
+		printk("%s() 0\n", __func__);
 	/*
 	 * Do some preliminary argument and permissions checking before we
 	 * actually start allocating stuff
@@ -1482,6 +1487,8 @@ long do_fork_with_pids(unsigned long clo
 			return -EPERM;
 	}
 
+	if (upids)
+		printk("%s() 1\n", __func__);
 	/*
 	 * We hope to recycle these flags after 2.6.26
 	 */
@@ -1501,6 +1508,7 @@ long do_fork_with_pids(unsigned long clo
 
 	target_pids = copy_target_pids(num_pids, upids);
 	if (target_pids) {
+		printk("%s() 1a\n", __func__);
 		if (IS_ERR(target_pids))
 			return PTR_ERR(target_pids);
 
@@ -1509,6 +1517,8 @@ long do_fork_with_pids(unsigned long clo
 			goto out_free;
 	}
 
+	if (upids)
+		printk("%s() 2\n", __func__);
 	/*
 	 * When called from kernel_thread, don't do user tracing stuff.
 	 */
@@ -1517,12 +1527,16 @@ long do_fork_with_pids(unsigned long clo
 
 	p = copy_process(clone_flags, stack_start, regs, stack_size,
 			 child_tidptr, NULL, target_pids, trace);
+	if (upids)
+		printk("%s() 3\n", __func__);
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
 	 * might get invalid after that point, if the thread exits quickly.
 	 */
 	if (!IS_ERR(p)) {
 		struct completion vfork;
+		if (upids)
+			printk("%s() 4\n", __func__);
 
 		trace_sched_process_fork(current, p);
 
@@ -1571,9 +1585,13 @@ long do_fork_with_pids(unsigned long clo
 		nr = PTR_ERR(p);
 	}
 
+	if (upids)
+		printk("%s() 5\n", __func__);
 out_free:
 	kfree(target_pids);
 
+	if (upids)
+		printk("%s() 6\n", __func__);
 	return nr;
 }
 
_
