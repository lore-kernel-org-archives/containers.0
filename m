From: =?UTF-8?B?xYF1a2FzeiBTb3dh?= <luksow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2] cgroup: syscalls limiting subsystem
Date: Mon, 14 Nov 2011 00:52:07 +0100
Message-ID: <4EC05827.7030709__31522.2792946317$1321228360$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

As I promised, RFC v2 of the syscalls limiting cgroup subsystem is
ready. For those who missed previous one here is the shortuct:
http://marc.info/?l=linux-security-module&m=131914567720567&w=2

In v2 I made changes suggested by Paul and Will (thanks!) this means:
1. clearing bits in descendants - it enables less synchronizing so the
overhead is smaller (see below)
2. ability to turn on/off (default: off) policy checking at current (and
only current!) level of cgroup (see below)
3. some minor fixes

Details:
1. Clearing bits in descendants means that every children is in coherent
state with it's parent. This means 4 different kind of concurrent
accessing to syscalls_bitmap:
a) Copying bits from parent to children when creating new cgroup.
b) Setting bits in descendants on ALLOW/DENY write.
c) Testing all bits in sequence on printing.
d) Testing one bit in bitmap on policy checking.

c) and d) are testing bits which are guaranteed to be atomic so I
decided to not put any critical section in there because it's useless
and in d) it's significant overhead. So in c) and d) we get info that is
or was (when write occurred) true in some point of time.
Now a) and b) clearly needs syncing. Concurrent writes to the hierarchy
could damage the consistency - same with concurrent write and copying.
Finally I decided to use one global mutex for write and copying - it
saves some memory and code complexity but there is some performance
impact that I think is not important because copying and writing to
hierarchy is rare.
I think, that I did the syncing right but I am open for any comments on
this.

2. I added file (syscalls.checking) which allows to turn on/off policy
checking for current level of cgroup. This is not affecting children in
any way - all syscalls forbidden in children are still forbidden and all
syscalls forbidden in parent are still forbidden in children. I think
that making it any other way would complicate the usage to the level of
impossibility.
The good thing is that performance for processes within cgroup with
checking=0 is basically untouched - there is flag checking and jump
added only. So, we can have syscalls subsystem compiled and ready for
the use with 0% overhead which was the goal for RFC v2.
The bad thing however, is breaking clarity of this cgroup because we
have a flag that is not hierarchical (like everything in cgroup). But I
think that is a good subject for a discussion.

Last but not least - the overhead. It is lower in RFC v2 than in RFC v1
and what is even more important - it is the same on all levels in
hierarchy (thanks to the change suggested by Paul). Now I am looking for
some fair methods of benchmarking it. Previously, I ran many (like 10^8)
system calls in a loop and then measure the overhead for it (system
time) but it has two drawbacks: first is that different syscalls take
different time to complete, second - it doesn't give the real impression
on how typical process would be slower - no apps make syscalls only. So,
I would love to hear some suggestions how to measure the overhead in a
way that provides useful piece of information.

Last thing for the performance is that I found rather simple method of
optimizing it even more. Compiler is currently not inlining bitmap
checking in syscall path which means jumping and a lot of stack ops. If
I was able to write bitmap checking in assembly (or force inlining) the
overhead will be smallest possible - only dereferencing pointers and bit
testing. I am currently trying to do it but unfortunately I have not
succeeded yet. Maybe someone is willing to help with that?

That is all for RFC v2 from me. Please, let me know what you think.

Best Regards,
Lukasz Sowa

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index a1fe5c1..0c92e36 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -95,6 +95,7 @@ struct thread_info {
 #define TIF_BLOCKSTEP		25	/* set when we want DEBUGCTLMSR_BTF */
 #define TIF_LAZY_MMU_UPDATES	27	/* task is updating the mmu lazily */
 #define TIF_SYSCALL_TRACEPOINT	28	/* syscall tracepoint instrumentation */
+#define TIF_SYSCALL_USE_CGROUP	29	/* is using permission checking in syscalls cgroup */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1 << TIF_NOTIFY_RESUME)
@@ -117,6 +118,7 @@ struct thread_info {
 #define _TIF_BLOCKSTEP		(1 << TIF_BLOCKSTEP)
 #define _TIF_LAZY_MMU_UPDATES	(1 << TIF_LAZY_MMU_UPDATES)
 #define _TIF_SYSCALL_TRACEPOINT	(1 << TIF_SYSCALL_TRACEPOINT)
+#define _TIF_SYSCALL_USE_CGROUP	(1 << TIF_SYSCALL_USE_CGROUP)
 
 /* work to do in syscall_trace_enter() */
 #define _TIF_WORK_SYSCALL_ENTRY	\
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index f3f6f53..6727326 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -425,6 +425,20 @@ sysenter_past_esp:
 sysenter_do_call:
 	cmpl $(nr_syscalls), %eax
 	jae syscall_badsys
+#ifdef CONFIG_CGROUP_SYSCALLS
+	testl $_TIF_SYSCALL_USE_CGROUP, TI_flags(%ebp)
+	jz syscalls_cgroup_skip_sysenter
+	push %eax
+	push %ecx
+	push %edx
+	call syscalls_cgroup_perm
+	cmpl $0, %eax
+	pop %edx
+	pop %ecx
+	pop %eax
+	je syscall_badsys
+syscalls_cgroup_skip_sysenter:
+#endif
 	call *sys_call_table(,%eax,4)
 	movl %eax,PT_EAX(%esp)
 	LOCKDEP_SYS_EXIT
@@ -507,6 +521,20 @@ ENTRY(system_call)
 	cmpl $(nr_syscalls), %eax
 	jae syscall_badsys
 syscall_call:
+#ifdef CONFIG_CGROUP_SYSCALLS
+	testl $_TIF_SYSCALL_USE_CGROUP, TI_flags(%ebp)
+	jz syscalls_cgroup_skip_syscall
+	push %eax
+	push %ecx
+	push %edx
+	call syscalls_cgroup_perm
+	cmpl $0, %eax
+	pop %edx
+	pop %ecx
+	pop %eax
+	je syscall_badsys
+syscalls_cgroup_skip_syscall:
+#endif
 	call *sys_call_table(,%eax,4)
 	movl %eax,PT_EAX(%esp)		# store the return value
 syscall_exit:
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index faf8d5e..8a9687c 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -484,6 +484,33 @@ ENTRY(system_call_after_swapgs)
 system_call_fastpath:
 	cmpq $__NR_syscall_max,%rax
 	ja badsys
+#ifdef CONFIG_CGROUP_SYSCALLS
+	testl $_TIF_SYSCALL_USE_CGROUP,TI_flags(%rcx)
+	jz syscalls_cgroup_skip_fastpath
+	pushq %rax
+	pushq %rdi
+	pushq %rsi
+	pushq %rdx
+	pushq %rcx
+	pushq %r8
+	pushq %r9
+	pushq %r10
+	pushq %r11
+	movq %rax,%rdi
+	call syscalls_cgroup_perm
+	cmpl $0,%eax
+	popq %r11
+	popq %r10
+	popq %r9
+	popq %r8
+	popq %rcx
+	popq %rdx
+	popq %rsi
+	popq %rdi
+	popq %rax
+	je badsys
+syscalls_cgroup_skip_fastpath:
+#endif
 	movq %r10,%rcx
 	call *sys_call_table(,%rax,8)  # XXX:	 rip relative
 	movq %rax,RAX-ARGOFFSET(%rsp)
@@ -600,6 +627,36 @@ tracesys:
 	RESTORE_REST
 	cmpq $__NR_syscall_max,%rax
 	ja   int_ret_from_sys_call	/* RAX(%rsp) set to -ENOSYS above */
+#ifdef CONFIG_CGROUP_SYSCALLS
+	pushq %rcx
+	GET_THREAD_INFO(%rcx)
+	testl $_TIF_SYSCALL_USE_CGROUP,TI_flags(%rcx)
+	popq %rcx
+	jz syscalls_cgroup_skip_tracesys
+	pushq %rax
+	pushq %rdi
+	pushq %rsi
+	pushq %rdx
+	pushq %rcx
+	pushq %r8
+	pushq %r9
+	pushq %r10
+	pushq %r11
+	movq %rax,%rdi
+	call syscalls_cgroup_perm
+	cmpl $0,%eax
+	popq %r11
+	popq %r10
+	popq %r9
+	popq %r8
+	popq %rcx
+	popq %rdx
+	popq %rsi
+	popq %rdi
+	popq %rax
+	je int_ret_from_sys_call
+syscalls_cgroup_skip_tracesys:
+#endif
 	movq %r10,%rcx	/* fixup for C */
 	call *sys_call_table(,%rax,8)
 	movq %rax,RAX-ARGOFFSET(%rsp)
diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index a3ef66a..a7401f1 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -26,6 +26,11 @@ extern unsigned long __sw_hweight64(__u64 w);
 	     (bit) < (size); \
 	     (bit) = find_next_bit((addr), (size), (bit) + 1))
 
+#define for_each_zero_bit(bit, addr, size) \
+	for ((bit) = find_first_zero_bit((addr), (size)); \
+	     (bit) < (size); \
+	     (bit) = find_next_zero_bit((addr), (size), (bit) + 1))
+
 static __inline__ int get_bitmask_order(unsigned int count)
 {
 	int order;
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ac663c1..ad6b600 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -64,3 +64,9 @@ SUBSYS(perf)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_SYSCALLS
+SUBSYS(syscalls)
+#endif
+
+/* */
diff --git a/init/Kconfig b/init/Kconfig
index 43298f9..9823ebe 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -609,6 +609,13 @@ config CGROUP_DEVICE
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.
 
+config CGROUP_SYSCALLS
+	bool "Syscalls controller for cgroups"
+	depends on X86
+	help
+	  Provides a way to limit access to specified syscalls for
+	  tasks in a cgroup.
+
 config CPUSETS
 	bool "Cpuset support"
 	help
diff --git a/security/Makefile b/security/Makefile
index a5e502f..1dff6c7 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_AUDIT)			+= lsm_audit.o
 obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
 obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/built-in.o
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
+obj-$(CONFIG_CGROUP_SYSCALLS)	+= syscalls_cgroup.o
 
 # Object integrity file lists
 subdir-$(CONFIG_INTEGRITY)		+= integrity
diff --git a/security/syscalls_cgroup.c b/security/syscalls_cgroup.c
new file mode 100644
index 0000000..5801533
--- /dev/null
+++ b/security/syscalls_cgroup.c
@@ -0,0 +1,273 @@
+/*
+ * security/syscalls_cgroup.c - syscalls cgroup subsystem
+ *
+ * Copyright (C) 2011 Lukasz Sowa <luksow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/bitmap.h>
+#include <linux/bitops.h>
+#include <linux/cgroup.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+
+struct syscalls_cgroup {
+	unsigned long *syscalls_bitmap;
+	struct cgroup_subsys_state css;
+	char checking;
+};
+
+static DEFINE_MUTEX(syscalls_cgroup_mutex);
+
+static inline struct syscalls_cgroup *css_to_scg(struct cgroup_subsys_state *subsys_state)
+{
+	return container_of(subsys_state, struct syscalls_cgroup, css);
+}
+
+static inline struct syscalls_cgroup *cgroup_to_scg(struct cgroup *cgroup)
+{
+	return css_to_scg(cgroup_subsys_state(cgroup,
+							 syscalls_subsys_id));
+}
+
+static inline struct syscalls_cgroup *task_to_scg(struct task_struct *task)
+{
+	return css_to_scg(task_subsys_state(task, syscalls_subsys_id));
+}
+
+/*
+ * The range of syscall number is not checked here, because it is done
+ * in low level assembly code. test_bit is guaranteed to be atomic so
+ * locking is not necessary.
+ */
+static inline int __syscalls_cgroup_perm(struct syscalls_cgroup *scg, int number)
+{
+	return test_bit(number, scg->syscalls_bitmap);
+}
+
+inline int syscalls_cgroup_perm(int number)
+{
+	return __syscalls_cgroup_perm(task_to_scg(current), number);
+}
+
+/*
+ * On cgroup creation, syscalls bitmap is simply inherited from parent. In case
+ * of root cgroup, we set all bits. We have to block while copying because it is
+ * not atomic operation.
+ */
+static struct cgroup_subsys_state *syscalls_cgroup_create(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	struct syscalls_cgroup *scg;
+	struct syscalls_cgroup *parent_scg;
+
+	scg = kmalloc(sizeof(*scg), GFP_KERNEL);
+	if (!scg)
+		return ERR_PTR(-ENOMEM);
+	scg->syscalls_bitmap = kmalloc(BITS_TO_LONGS(NR_syscalls) * sizeof(unsigned long),
+								GFP_KERNEL);
+	if (!scg->syscalls_bitmap) {
+		kfree(scg);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	scg->checking = 0;
+
+	if (cgroup->parent) {
+		parent_scg = cgroup_to_scg(cgroup->parent);
+		mutex_lock(&syscalls_cgroup_mutex);
+		bitmap_copy(scg->syscalls_bitmap,
+					parent_scg->syscalls_bitmap,
+					NR_syscalls);
+		mutex_unlock(&syscalls_cgroup_mutex);
+	} else {
+		bitmap_fill(scg->syscalls_bitmap, NR_syscalls);
+	}
+
+	return &scg->css;
+}
+
+static void syscalls_cgroup_destroy(struct cgroup_subsys *subsys,
+							struct cgroup *cgroup)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+	kfree(scg->syscalls_bitmap);
+	kfree(scg);
+}
+
+#define SYSCALLS_CGROUP_ALLOW 0
+#define SYSCALLS_CGROUP_DENY 1
+
+static int syscalls_cgroup_read(struct cgroup *cgroup, struct cftype *cftype,
+						struct seq_file *seq_file)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+	int bit = 0;
+
+	switch (cftype->private) {
+	case SYSCALLS_CGROUP_ALLOW:
+		for_each_set_bit(bit, scg->syscalls_bitmap, NR_syscalls) {
+			seq_printf(seq_file, "%d ", bit);
+		}
+		break;
+	case SYSCALLS_CGROUP_DENY:
+		for_each_zero_bit(bit, scg->syscalls_bitmap, NR_syscalls) {
+			seq_printf(seq_file, "%d ", bit);
+		}
+		break;
+	default:
+		BUG();
+	}
+	seq_printf(seq_file, "\n");
+
+	return 0;
+}
+
+/*
+ * Allowing/denying syscall is quite complicated task, so we block for whole
+ * operation. Moreover it is rare, so performance is not as important as
+ * lower complexity and memory usage.
+ */
+static int syscalls_cgroup_write(struct cgroup *cgroup, struct cftype *cftype,
+							const char *buffer)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+	struct syscalls_cgroup *next_scg;
+	struct syscalls_cgroup *parent_scg;
+	struct cgroup_subsys_state *next_css;
+	int number;
+	int ret;
+	int id;
+	int found;
+
+	ret = kstrtoint(buffer, 0, &number);
+	if (ret)
+		return ret;
+
+	if (number < 0 || number >= NR_syscalls)
+		return -ERANGE;
+
+	mutex_lock(&syscalls_cgroup_mutex);
+	switch (cftype->private) {
+	case SYSCALLS_CGROUP_ALLOW:
+		if (cgroup->parent) {
+			parent_scg = cgroup_to_scg(cgroup->parent);
+			if (test_bit(number, parent_scg->syscalls_bitmap))
+				set_bit(number, scg->syscalls_bitmap);
+			else
+				ret = -EPERM;
+		} else {
+			set_bit(number, scg->syscalls_bitmap);
+		}
+		break;
+	case SYSCALLS_CGROUP_DENY:
+		clear_bit(number, scg->syscalls_bitmap);
+
+		id = css_id(&scg->css) + 1;
+		rcu_read_lock();
+		while ((next_css = css_get_next(&syscalls_subsys,
+						id, &scg->css, &found))) {
+			next_scg = css_to_scg(next_css);
+			clear_bit(number, next_scg->syscalls_bitmap);
+			id = found + 1;
+		}
+		rcu_read_unlock();
+		break;
+	default:
+		BUG();
+	}
+	mutex_unlock(&syscalls_cgroup_mutex);
+
+	return ret;
+}
+
+static int syscalls_cgroup_switch_write(struct cgroup *cgroup,
+							struct cftype *cftype,
+							const char *buffer)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+	struct task_struct *task;
+	struct cgroup_iter it;
+	int number;
+	int ret;
+
+	ret = kstrtoint(buffer, 0, &number);
+	if (ret)
+		return ret;
+
+	cgroup_iter_start(cgroup, &it);
+	if (number) {
+		while ((task = cgroup_iter_next(cgroup, &it)))
+			set_tsk_thread_flag(task, TIF_SYSCALL_USE_CGROUP);
+	} else {
+		while ((task = cgroup_iter_next(cgroup, &it)))
+			clear_tsk_thread_flag(task, TIF_SYSCALL_USE_CGROUP);
+	}
+	cgroup_iter_end(cgroup, &it);
+
+	scg->checking = number ? 1 : 0;
+
+	return ret;
+}
+
+static int syscalls_cgroup_switch_read(struct cgroup *cgroup,
+						struct cftype *cftype,
+						struct seq_file *seq_file)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+	seq_printf(seq_file, "%d\n", scg->checking);
+	return 0;
+}
+
+static struct cftype syscalls_cgroup_files[] = {
+	{
+		.name = "allow",
+		.read_seq_string = syscalls_cgroup_read,
+		.write_string = syscalls_cgroup_write,
+		.private = SYSCALLS_CGROUP_ALLOW,
+	},
+	{
+		.name = "deny",
+		.read_seq_string = syscalls_cgroup_read,
+		.write_string = syscalls_cgroup_write,
+		.private = SYSCALLS_CGROUP_DENY,
+	},
+	{
+		.name = "checking",
+		.read_seq_string = syscalls_cgroup_switch_read,
+		.write_string  = syscalls_cgroup_switch_write
+	}
+};
+
+static int syscalls_cgroup_populate(struct cgroup_subsys *subsys,
+							struct cgroup *cgroup)
+{
+	return cgroup_add_files(cgroup, subsys, syscalls_cgroup_files,
+					ARRAY_SIZE(syscalls_cgroup_files));
+}
+
+struct cgroup_subsys syscalls_subsys = {
+	.name = "syscalls",
+	.create = syscalls_cgroup_create,
+	.destroy = syscalls_cgroup_destroy,
+	.populate = syscalls_cgroup_populate,
+	.subsys_id = syscalls_subsys_id,
+	.use_id = 1,
+	.module = THIS_MODULE,
+};
+
+static int __init init_syscalls_subsys(void)
+{
+	return cgroup_load_subsys(&syscalls_subsys);
+}
+
+static void __exit exit_syscalls_subsys(void)
+{
+	cgroup_unload_subsys(&syscalls_subsys);
+}
+
+module_init(init_syscalls_subsys);
+module_exit(exit_syscalls_subsys);
+MODULE_LICENSE("GPL");
+
