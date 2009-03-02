From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] checkpoint: Note checkpointability of mm_struct (v2)
Date: Mon, 2 Mar 2009 10:11:15 -0600
Message-ID: <20090302161115.GA10484@us.ibm.com>
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
List-Id: containers.vger.kernel.org

Just sending this out for a sanity check.  This is on top of dave's
files_struct may_checkpoint patchset.

From b696c872296616a03cd7f9791664259c0461bd24 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 2 Mar 2009 10:11:05 -0500
Subject: [PATCH 1/1] checkpoint: Note checkpointability of mm_struct (v2)

A task can't be checkpointed if:
	1. it has VM_SHARED, VM_IO, etc, mappings
	2. its mm is shared with a task outside its container.

1. is a temporary prohibition until support is implemented.  2. is
permanent, as we can't have references to the mm_struct outside the
checkpointed container.  Well, the check may need to be be updated
at some point so that if the mm_struct is shared with a *child*
container that is allowed.  But right now we don't support child
containers anyway.

The checkpointability flag is reset when a new mm is created.  If
instead a task is created with CLONE_VM, then we unset the
may_checkpoint flag if any of the new-container flags
(CLONE_NEWNS etc) are also specified.

/proc/pid/status displays checkpointability of both files_struct
and task->mm.  (should this be active_mm?)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/ckpt_mem.c      |    3 ---
 fs/proc/array.c            |   15 +++++++++++++++
 include/linux/checkpoint.h |   23 +++++++++++++++++++++--
 include/linux/mm_types.h   |    3 +++
 kernel/fork.c              |    6 ++++++
 mm/mmap.c                  |    9 +++++++++
 6 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 4925ff2..b2531f7 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -448,9 +448,6 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 	hh->vm_flags = vma->vm_flags;
 	hh->vm_pgoff = vma->vm_pgoff;
 
-#define CR_BAD_VM_FLAGS  \
-	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB | VM_NONLINEAR)
-
 	if (vma->vm_flags & CR_BAD_VM_FLAGS) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
 		cr_hbuf_put(ctx, sizeof(*hh));
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 7e4877d..1d4e504 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -320,6 +320,20 @@ static inline void task_context_switch_counts(struct seq_file *m,
 			p->nivcsw);
 }
 
+static inline void task_show_checkpointable(struct seq_file *m,
+						struct task_struct *p)
+{
+	if (test_bit(0, &p->mm->may_checkpoint))
+		seq_printf(m,	"mm is checkpointable\n");
+	else
+		seq_printf(m,	"mm is not checkpointable\n");
+
+	if (test_bit(0, &p->files->may_checkpoint))
+		seq_printf(m,	"files are checkpointable\n");
+	else
+		seq_printf(m,	"files are not checkpointable\n");
+}
+
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
@@ -339,6 +353,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 	task_show_regs(m, task);
 #endif
 	task_context_switch_counts(m, task);
+	task_show_checkpointable(m, task);
 	return 0;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e10ab89..04c045c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -13,6 +13,13 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/fdtable.h>
+#include <linux/mm_types.h>
+
+#define NEW_CONTAINER_FLAGS (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | \
+		CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET)
+
+#define CR_BAD_VM_FLAGS  \
+	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB | VM_NONLINEAR)
 
 #ifdef CONFIG_CHECKPOINT_RESTART
 
@@ -103,14 +110,26 @@ extern int cr_read_files(struct cr_ctx *ctx);
 
 #define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
 
+static inline void __mm_deny_checkpointing(struct mm_struct *mm,
+		char *file, int line)
+{
+	if (!test_and_clear_bit(0, &mm->may_checkpoint))
+		return;
+	printk(KERN_INFO "process performed an (mm) action that can not be "
+			"checkpointed at: %s:%d\n", file, line);
+}
+#define mm_deny_checkpointing(f) \
+	__mm_deny_checkpointing(f, __FILE__, __LINE__)
+
+
 static inline void __files_deny_checkpointing(struct files_struct *files,
 		char *file, int line)
 {
 	if (!test_and_clear_bit(0, &files->may_checkpoint))
 		return;
-	printk(KERN_INFO "process performed an action that can not be "
+	printk(KERN_INFO "process performed a (file) action that can not be "
 			"checkpointed at: %s:%d\n", file, line);
-	WARN_ON(1);
+	//WARN_ON(1);
 }
 #define files_deny_checkpointing(f)  \
 	__files_deny_checkpointing(f, __FILE__, __LINE__)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 92915e8..28c3c9f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -274,6 +274,9 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_CHECKPOINT_RESTART
+	unsigned long may_checkpoint;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index a66fbde..525e309 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -60,6 +60,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/checkpoint.h>
 #include <trace/sched.h>
 
 #include <asm/pgtable.h>
@@ -295,6 +296,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 								-pages);
 			continue;
 		}
+		if (mpnt->vm_flags & CR_BAD_VM_FLAGS)
+			mm_deny_checkpointing(mm);
 		charge = 0;
 		if (mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
@@ -418,6 +421,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
+	set_bit(0, &mm->may_checkpoint);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
@@ -655,6 +659,8 @@ static int copy_mm(unsigned long clone_flags, struct task_struct * tsk)
 	if (clone_flags & CLONE_VM) {
 		atomic_inc(&oldmm->mm_users);
 		mm = oldmm;
+		if (clone_flags & NEW_CONTAINER_FLAGS)
+			mm_deny_checkpointing(mm);
 		goto good_mm;
 	}
 
diff --git a/mm/mmap.c b/mm/mmap.c
index fb4df8f..9472c83 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -27,6 +27,7 @@
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
 #include <linux/mmu_notifier.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -903,6 +904,14 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 		mm->stack_vm += pages;
 	if (flags & (VM_RESERVED|VM_IO))
 		mm->reserved_vm += pages;
+	if (pages > 0 && flags & CR_BAD_VM_FLAGS) {
+		if (test_bit(0, &mm->may_checkpoint)) {
+			printk(KERN_INFO "pid %d flags %lu file %s\n",
+				current->pid, flags,
+				file->f_dentry->d_name.name);
+		}
+		mm_deny_checkpointing(mm);
+	}
 }
 #endif /* CONFIG_PROC_FS */
 
-- 
1.6.1
