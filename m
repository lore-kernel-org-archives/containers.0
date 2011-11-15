From: =?UTF-8?B?xYF1a2FzeiBTb3dh?= <luksow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2] cgroup: syscalls limiting subsystem
Date: Tue, 15 Nov 2011 17:17:51 +0100
Message-ID: <4EC290AF.4070209__30040.1443885223$1321373908$gmane$org@gmail.com>
References: <4EC05827.7030709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4EC05827.7030709-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

> As I promised, RFC v2 of the syscalls limiting cgroup subsystem is 
> ready. For those who missed previous one here is the shortuct: 
> http://marc.info/?l=linux-security-module&m=131914567720567&w=2

Oops, I did the posting a little too early and pushed wrong version with
missing functions for for and attach_task. Correct version below.

One interesting thing that I found out is possible race between
syscalls_cgroup_fork() and syscalls_cgroup_switch_write() I don't know
how to avoid. If syscalls_cgroup_switch_write() will happen between
cgroup_fork_callbacks() and cgroup_post_fork() it will lead to
inconsistent setting of TIF in tasks. After some longer thinking the
only nice & clean solution I found is to add another callback to
cgroup_subsys struct: post_fork. It would be invoked just after the
cgroup_post_fork() which will guarantee that task is already on tasks
list making it possible to avoid the race. However, this solutions
requires to modify the cgroups internals just for my subsystem (at the
moment of course) which may not be desired. I would love to hear other
solutions/hacks/workarounds.

Thanks,
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
index 0000000..d634040
--- /dev/null
+++ b/security/syscalls_cgroup.c
@@ -0,0 +1,309 @@
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
+#include <linux/rwsem.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+
+struct syscalls_cgroup {
+	unsigned long *syscalls_bitmap;
+	struct cgroup_subsys_state css;
+	char checking;
+};
+
+/*
+ * Should be taken while modyfing any syscalls_bitmap
+ * in syscalls_cgroup struct.
+ */
+static DEFINE_MUTEX(syscalls_cgroup_bitmaps_mutex);
+
+/*
+ * Should be taken while writing or sensitive reading
+ * of any checking flag in syscalls_cgroup struct.
+ */
+static DECLARE_RWSEM(syscalls_cgroup_switch_sem);
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
+		mutex_lock(&syscalls_cgroup_bitmaps_mutex);
+		bitmap_copy(scg->syscalls_bitmap,
+					parent_scg->syscalls_bitmap,
+					NR_syscalls);
+		mutex_unlock(&syscalls_cgroup_bitmaps_mutex);
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
+/*
+ * For explanation of locking see syscalls_cgroup_switch_write.
+ */
+static void syscalls_cgroup_attach_task(struct cgroup *cgroup,
+						struct task_struct *task)
+{
+	struct syscalls_cgroup *scg = cgroup_to_scg(cgroup);
+
+	down_read(&syscalls_cgroup_switch_sem);
+	if (scg->checking)
+		set_tsk_thread_flag(task, TIF_SYSCALL_USE_CGROUP);
+	else
+		clear_tsk_thread_flag(task, TIF_SYSCALL_USE_CGROUP);
+	up_read(&syscalls_cgroup_switch_sem);
+}
+
+/*
+ * For explanation of locking see syscalls_cgroup_switch_write.
+ */
+static void syscalls_cgroup_fork(struct cgroup_subsys *subsys,
+						struct task_struct *task)
+{
+	struct syscalls_cgroup *scg = task_to_scg(task);
+
+	down_read(&syscalls_cgroup_switch_sem);
+	if (scg->checking)
+		set_tsk_thread_flag(task, TIF_SYSCALL_USE_CGROUP);
+	up_read(&syscalls_cgroup_switch_sem);
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
+	mutex_lock(&syscalls_cgroup_bitmaps_mutex);
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
+	mutex_unlock(&syscalls_cgroup_bitmaps_mutex);
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
+/*
+ * Locking here prevents racing with funcs that use checking flag
+ * in syscalls_cgroup struct. Any races between reading and writing
+ * may lead to inconsistency in setting thread info flags and syscalls
+ * cgroup malfunction (e.g. bypassing policy check).
+ */
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
+	down_write(&syscalls_cgroup_switch_sem);
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
+	up_write(&syscalls_cgroup_switch_sem);
+
+	return ret;
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
+	.attach_task = syscalls_cgroup_attach_task,
+	.fork = syscalls_cgroup_fork,
+	.populate = syscalls_cgroup_populate,
+	.subsys_id = syscalls_subsys_id,
+	.use_id = 1,
+};
+
