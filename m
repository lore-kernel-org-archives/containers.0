From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] cr: track mm checkpointability
Date: Fri, 6 Mar 2009 14:00:53 -0600
Message-ID: <20090306200053.GB9632@us.ibm.com>
References: <20090306195911.GA9512@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090306195911.GA9512-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cedric Le Goater <clg@>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Track checkpointability of an mm_struct.  When a new mm_struct is
created, it is checkpointable.  If an mmap is added using one of
the non-checkpointable flags (i.e. VM_IO) then the mm_struct becomes
forevermore uncheckpointable.

Also, creating a new container with a shared mm_struct makes the mm
uncheckpointable.

I realize vm_stat_account() may seem like an odd choice, but it
really seems like the best fit...

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |   24 ++++++++++++++++++++++++
 include/linux/checkpoint.h |   32 ++++++++++++++++++++++++++++++++
 include/linux/mm.h         |    1 +
 include/linux/mm_types.h   |    3 +++
 kernel/fork.c              |    5 +++++
 mm/mmap.c                  |    2 ++
 6 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 5debe70..d8febd1 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -30,6 +30,15 @@ static atomic_t cr_ctx_count = ATOMIC_INIT(0);
 
 void task_checkpoint_status(struct seq_file *m, struct task_struct *p)
 {
+	struct mm_struct *mm = get_task_mm(p);
+	if (mm) {
+		if (test_bit(0, &mm->may_checkpoint))
+			seq_printf(m, "mm is checkpointable\n");
+		else
+			seq_printf(m, "mm is not checkpointable\n");
+		mmput(mm);
+	} else
+		seq_printf(m, "task has no mm\n");
 	if (!p->files) {
 		seq_printf(m, "task has no files_struct\n");
 		return;
@@ -41,6 +50,21 @@ void task_checkpoint_status(struct seq_file *m, struct task_struct *p)
 		seq_printf(m, "files are not checkpointable\n");
 }
 
+void checkpoint_assert_flags(struct mm_struct *mm, unsigned long flags)
+{
+	if (flags & CR_BAD_VM_FLAGS)
+		mm_deny_checkpointing(mm);
+}
+
+void checkpoint_account_mm(struct mm_struct *mm, unsigned long flags,
+			long pages)
+{
+	if (pages < 0)
+		return;
+
+	checkpoint_assert_flags(mm, flags);
+}
+
 /**
  * cr_write_obj - write a record described by a cr_hdr
  * @ctx: checkpoint context
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 0e90b67..a60e0b3 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -13,6 +13,11 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/fdtable.h>
+#include <linux/mm.h>
+#include <linux/mm_types.h>
+
+#define NEW_CONTAINER_FLAGS (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | \
+		CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET)
 
 #ifdef CONFIG_CHECKPOINT_RESTART
 
@@ -105,6 +110,19 @@ extern int cr_read_files(struct cr_ctx *ctx);
 
 #define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
 
+static inline void __mm_deny_checkpointing(struct mm_struct *mm,
+		char *file, int line)
+{
+	if (!mm)
+		return;
+	if (!test_and_clear_bit(0, &mm->may_checkpoint))
+		return;
+	printk(KERN_INFO "process loaded a vma which can not be "
+			"checkpointed at: %s:%d\n", file, line);
+}
+#define mm_deny_checkpointing(mm)  \
+	__mm_deny_checkpointing(mm, __FILE__, __LINE__)
+
 static inline void __files_deny_checkpointing(struct files_struct *files,
 		char *file, int line)
 {
@@ -124,6 +142,14 @@ static inline int cr_enabled(void)
 }
 
 extern void task_checkpoint_status(struct seq_file *m, struct task_struct *p);
+extern void checkpoint_assert_flags(struct mm_struct *mm, unsigned long flags);
+extern void checkpoint_account_mm(struct mm_struct *mm, unsigned long flags,
+				long pages);
+
+static inline void checkpoint_clear_mm_flag(struct mm_struct *mm)
+{
+	set_bit(0, &mm->may_checkpoint);
+}
 
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
@@ -145,7 +171,13 @@ static inline int cr_enabled(void)
 	return 0;
 }
 
+static inline void checkpoint_clear_mm_flag(struct mm_struct *mm) {}
+static inline void mm_deny_checkpointing(struct mm_struct *mm) {}
 static inline void task_checkpoint_status(struct seq_file *m,
 			struct task_struct *p) {}
+static inline void checkpoint_assert_flags(struct mm_struct *mm,
+			unsigned long flags) {}
+static inline void checkpoint_account_mm(struct mm_struct *mm,
+			unsigned long flags, long pages) {}
 #endif /* CONFIG_CHECKPOINT_RESTART */
 #endif /* _CHECKPOINT_CKPT_H_ */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065cdf8..b3a0bd8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1255,6 +1255,7 @@ void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
 static inline void vm_stat_account(struct mm_struct *mm,
 			unsigned long flags, struct file *file, long pages)
 {
+	checkpoint_account_mm(mm, flags, files, pages);
 }
 #endif /* CONFIG_PROC_FS */
 
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
index a66fbde..89c6c6b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -60,6 +60,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/checkpoint.h>
 #include <trace/sched.h>
 
 #include <asm/pgtable.h>
@@ -295,6 +296,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 								-pages);
 			continue;
 		}
+		checkpoint_assert_flags(mm, mpnt->vm_flags);
 		charge = 0;
 		if (mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
@@ -418,6 +420,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
+	checkpoint_clear_mm_flag(mm);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
@@ -655,6 +658,8 @@ static int copy_mm(unsigned long clone_flags, struct task_struct * tsk)
 	if (clone_flags & CLONE_VM) {
 		atomic_inc(&oldmm->mm_users);
 		mm = oldmm;
+		if (clone_flags & NEW_CONTAINER_FLAGS)
+			mm_deny_checkpointing(mm);
 		goto good_mm;
 	}
 
diff --git a/mm/mmap.c b/mm/mmap.c
index fb4df8f..8141fd0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -27,6 +27,7 @@
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
 #include <linux/mmu_notifier.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -903,6 +904,7 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 		mm->stack_vm += pages;
 	if (flags & (VM_RESERVED|VM_IO))
 		mm->reserved_vm += pages;
+	checkpoint_account_mm(mm, flags, pages);
 }
 #endif /* CONFIG_PROC_FS */
 
-- 
1.5.4.3
