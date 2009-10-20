From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] Send checkpoint and restart debug info to a log file
Date: Tue, 20 Oct 2009 17:59:38 -0500
Message-ID: <20091020225938.GA20803@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Until now, debug data was sent to syslog.  That's not really
right.

This patch sends ckpt_debug output to a logfile provided by
the caller.  If no logfile is provided, then no debug output
is needed.  So the user can pass in -1 for the logfd to say
so.

Note that this does not address the potential (inevitable?)
lockup of writing out a debug msg while checkpointing the
debug file.  In practice so far it seems to work rather well.

This also means that we have to be more careful than we have
been about not writing out sensitive data.

I keep the logfd in the ckpt_ctx, so all functions calling
ckpt_debug() are now passed the ctx.  There weren't actually
many lacking this.  Other than that, the meat is in the
include/linux/checkpoint.h and checkpoint/sys.c hunks.
(Hmm, the ckpt_syslog() hunks are now dead code.)

This is pure RFC, not meant to be pretty.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/compat_wrapper.S |    2 +
 arch/x86/mm/checkpoint.c          |    8 ++--
 checkpoint/checkpoint.c           |   19 ++++---
 checkpoint/files.c                |   26 +++++-----
 checkpoint/memory.c               |   39 +++++++++------
 checkpoint/objhash.c              |   30 +++++++-----
 checkpoint/process.c              |   82 ++++++++++++++++----------------
 checkpoint/restart.c              |   96 ++++++++++++++++++-------------------
 checkpoint/signal.c               |    2 +-
 checkpoint/sys.c                  |   69 ++++++++++++++++++++++++---
 drivers/char/tty_io.c             |   22 ++++----
 include/linux/checkpoint.h        |   48 +++++++++++++-----
 include/linux/checkpoint_types.h  |    5 +-
 include/linux/syscalls.h          |    5 +-
 ipc/checkpoint.c                  |   10 ++--
 ipc/checkpoint_msg.c              |   10 ++--
 ipc/checkpoint_sem.c              |   10 ++--
 ipc/checkpoint_shm.c              |   12 ++--
 kernel/cred.c                     |    2 +-
 mm/filemap.c                      |    2 +-
 mm/shmem.c                        |    2 +-
 net/checkpoint.c                  |   45 +++++++++--------
 net/ipv4/checkpoint.c             |   26 +++++-----
 net/unix/checkpoint.c             |   66 ++++++++++++++-----------
 24 files changed, 370 insertions(+), 268 deletions(-)

diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index e882f99..414226e 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1846,6 +1846,7 @@ sys_checkpoint_wrapper:
 	lgfr	%r2,%r2			# pid_t
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
+	lgfr	%r5,%r5			# int
 	jg	compat_sys_checkpoint
 
 	.globl sys_restore_wrapper
@@ -1853,4 +1854,5 @@ sys_restore_wrapper:
 	lgfr	%r2,%r2			# int
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
+	lgfr	%r5,%r5			# int
 	jg	compat_sys_restore
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 9dd8e12..1773c85 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -292,7 +292,7 @@ int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
 	save_cpu_debug(h, t);
 	save_cpu_fpu(h, t);
 
-	ckpt_debug("math %d debug %d\n", h->used_math, !!h->debugreg7);
+	ckpt_debug(ctx, "math %d debug %d\n", h->used_math, !!h->debugreg7);
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	if (ret < 0)
@@ -341,7 +341,7 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	h->ldt_entry_size = LDT_ENTRY_SIZE;
 	h->nldt = mm->context.size;
 
-	ckpt_debug("nldt %d vdso %#llx\n", h->nldt, h->vdso);
+	ckpt_debug(ctx, "nldt %d vdso %#llx\n", h->nldt, h->vdso);
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -522,7 +522,7 @@ int restore_cpu(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("math %d debug %d\n", h->used_math, !!h->debugreg7);
+	ckpt_debug(ctx, "math %d debug %d\n", h->used_math, !!h->debugreg7);
 
 	ret = load_cpu_regs(h, t);
 	if (ret < 0)
@@ -572,7 +572,7 @@ int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("nldt %d vdso %#lx (%p)\n",
+	ckpt_debug(ctx, "nldt %d vdso %#lx (%p)\n",
 		 h->nldt, (unsigned long) h->vdso, mm->context.vdso);
 
 	ret = -EINVAL;
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6eb8f3b..fab7966 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -38,7 +38,7 @@ static atomic_t ctx_count = ATOMIC_INIT(0);
  */
 int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 {
-	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	_ckpt_debug(ctx, CKPT_DRW, "type %d len %d\n", h->type, h->len);
 	return ckpt_kwrite(ctx, h, h->len);
 }
 
@@ -63,7 +63,7 @@ int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
 	h->type = type;
 	h->len = len + sizeof(*h);
 
-	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
+	_ckpt_debug(ctx, CKPT_DRW, "type %d len %d\n", h->type, h->len);
 	ret = ckpt_kwrite(ctx, h, sizeof(*h));
 	if (ret < 0)
 		goto out;
@@ -213,7 +213,7 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
 	va_end(aq);
 	kfree(format);
 
-	ckpt_debug("c/r: checkpoint error: %s\n", str);
+	ckpt_debug(ctx, "c/r: checkpoint error: %s\n", str);
 }
 
 /**
@@ -392,7 +392,7 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 	int n, ret = 0;
 
 	for (n = 0; n < ctx->nr_tasks; n++) {
-		ckpt_debug("dumping task #%d\n", n);
+		ckpt_debug(ctx, "dumping task #%d\n", n);
 		ret = checkpoint_task(ctx, ctx->tasks_arr[n]);
 		if (ret < 0)
 			break;
@@ -407,7 +407,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct nsproxy *nsproxy;
 	int ret = 0;
 
-	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
+	ckpt_debug(ctx, "check %d\n",
+		   task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
 	if (t->exit_state == EXIT_DEAD) {
 		__ckpt_write_err(ctx, "TE", "task state EXIT_DEAD\n", -EBUSY);
@@ -499,7 +500,8 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 			h[n].vpgid = task_pgrp_nr_ns(task, ns);
 			h[n].vsid = task_session_nr_ns(task, ns);
 			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
-			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
+			ckpt_debug(ctx,
+				   "task[%d]: vpid %d vtgid %d parent %d\n",
 				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
 			pos++;
 		}
@@ -522,7 +524,7 @@ static int collect_objects(struct ckpt_ctx *ctx)
 	int n, ret = 0;
 
 	for (n = 0; n < ctx->nr_tasks; n++) {
-		ckpt_debug("dumping task #%d\n", n);
+		ckpt_debug(ctx, "dumping task #%d\n", n);
 		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
 		if (ret < 0) {
 			ctx->tsk = ctx->tasks_arr[n];
@@ -579,7 +581,8 @@ static int tree_count_tasks(struct ckpt_ctx *ctx)
 	data.ctx = ctx;
 	data.nr = 0;
 
-	return walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
+	return walk_task_subtree(ctx, ctx->root_task, __tree_count_tasks,
+				 &data);
 }
 
 /*
diff --git a/checkpoint/files.c b/checkpoint/files.c
index f6de07e..318fa1f 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -159,7 +159,7 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
-	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
+	ckpt_debug(ctx, "file %s credref %d", file->f_dentry->d_name.name,
 		h->f_credref);
 
 	/* FIX: need also file->f_owner, etc */
@@ -204,12 +204,13 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	if (!file->f_op || !file->f_op->checkpoint) {
 		ckpt_write_err(ctx, "TEPS", "f_op lacks checkpoint",
 			       -EBADF, file, file->f_op);
-		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
+		ckpt_debug(ctx, "f_op lacks checkpoint handler: %pS\n",
+			   file->f_op);
 		return -EBADF;
 	}
 	if (d_unlinked(file->f_dentry)) {
 		ckpt_write_err(ctx, "TEP", "unlinked file", -EBADF, file);
-		ckpt_debug("unlinked files are unsupported\n");
+		ckpt_debug(ctx, "unlinked files are unsupported\n");
 		return -EBADF;
 	}
 
@@ -264,7 +265,8 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	 * a reference to it, dump its state while at it.
 	 */
 	objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
-	ckpt_debug("fd %d objref %d file %p coe %d)\n", fd, objref, file, coe);
+	ckpt_debug(ctx, "fd %d objref %d file %p coe %d)\n", fd, objref, file,
+		   coe);
 	if (objref < 0) {
 		ret = objref;
 		goto out;
@@ -306,7 +308,7 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
 	if (ret < 0)
 		goto out;
 
-	ckpt_debug("nfds %d\n", nfds);
+	ckpt_debug(ctx, "nfds %d\n", nfds);
 	for (n = 0; n < nfds; n++) {
 		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
 		if (ret < 0)
@@ -314,7 +316,7 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
 	}
 
 	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
+	ckpt_debug(ctx, "files_deferq ran %d entries\n", ret);
 	if (ret > 0)
 		ret = 0;
  out:
@@ -452,7 +454,7 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
 	if (IS_ERR(h))
 		return (struct file *) h;
 	fname = (char *) (h + 1);
-	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
+	ckpt_debug(ctx, "fname '%s' flags %#x\n", fname, flags);
 
 	file = filp_open(fname, flags, 0);
 	ckpt_hdr_put(ctx, h);
@@ -623,7 +625,7 @@ static struct file *do_restore_file(struct ckpt_ctx *ctx)
 	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_FILE);
 	if (IS_ERR(h))
 		return (struct file *) h;
-	ckpt_debug("flags %#x mode %#x type %d\n",
+	ckpt_debug(ctx, "flags %#x mode %#x type %d\n",
 		 h->f_flags, h->f_mode, h->f_type);
 
 	if (h->f_type >= CKPT_FILE_MAX)
@@ -662,7 +664,7 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
-	ckpt_debug("ref %d fd %d c.o.e %d\n",
+	ckpt_debug(ctx, "ref %d fd %d c.o.e %d\n",
 		 h->fd_objref, h->fd_descriptor, h->fd_close_on_exec);
 
 	ret = -EINVAL;
@@ -681,7 +683,7 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
 		goto out;
 	}
 
-	ckpt_debug("newfd got %d wanted %d\n", newfd, h->fd_descriptor);
+	ckpt_debug(ctx, "newfd got %d wanted %d\n", newfd, h->fd_descriptor);
 
 	/* reposition if newfd isn't desired fd */
 	if (newfd != h->fd_descriptor) {
@@ -709,7 +711,7 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return (struct files_struct *) h;
 
-	ckpt_debug("nfds %d\n", h->fdt_nfds);
+	ckpt_debug(ctx, "nfds %d\n", h->fdt_nfds);
 
 	ret = -EMFILE;
 	if (h->fdt_nfds < 0 || h->fdt_nfds > sysctl_nr_open)
@@ -734,7 +736,7 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 	}
 
 	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
+	ckpt_debug(ctx, "files_deferq ran %d entries\n", ret);
 	if (ret > 0)
 		ret = 0;
  out:
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 0da948f..bbcb516 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -98,7 +98,6 @@ static inline struct ckpt_pgarr *pgarr_from_pool(struct ckpt_ctx *ctx)
 /* release pages referenced by a page-array */
 static void pgarr_release_pages(struct ckpt_pgarr *pgarr)
 {
-	ckpt_debug("total pages %d\n", pgarr->nr_used);
 	/*
 	 * both checkpoint and restart use 'nr_used', however we only
 	 * collect pages during checkpoint; in restart we simply return
@@ -197,8 +196,11 @@ static void pgarr_reset_all(struct ckpt_ctx *ctx)
 {
 	struct ckpt_pgarr *pgarr;
 
-	list_for_each_entry(pgarr, &ctx->pgarr_list, list)
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list) {
+		ckpt_debug(ctx, "call pgarr_release_pages: total pages %d\n",
+			   pgarr->nr_used);
 		pgarr_release_pages(pgarr);
+	}
 	list_splice_init(&ctx->pgarr_list, &ctx->pgarr_pool);
 }
 
@@ -369,7 +371,7 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 				return PTR_ERR(page);
 
 			if (page) {
-				_ckpt_debug(CKPT_DPAGE,
+				_ckpt_debug(ctx, CKPT_DPAGE,
 					    "got page %#lx\n", addr);
 				pgarr->pages[pgarr->nr_used] = page;
 				pgarr->vaddrs[pgarr->nr_used] = addr;
@@ -508,7 +510,7 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 		else if (cnt < 0)
 			return cnt;
 
-		ckpt_debug("collected %d pages\n", cnt);
+		ckpt_debug(ctx, "collected %d pages\n", cnt);
 
 		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
 		if (!h)
@@ -551,7 +553,7 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 	struct ckpt_hdr_vma *h;
 	int ret;
 
-	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
+	ckpt_debug(ctx, "vma %#lx-%#lx flags %#lx type %d\n",
 		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
@@ -615,7 +617,7 @@ int shmem_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 	struct file *file = vma->vm_file;
 	int ret;
 
-	ckpt_debug("type %d, ino_ref %d\n", type, ino_objref);
+	ckpt_debug(ctx, "type %d, ino_ref %d\n", type, ino_objref);
 	BUG_ON(!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
 	BUG_ON(!file);
 
@@ -694,7 +696,7 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
 	/* write the vma's */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
+		ckpt_debug(ctx, "vma %#lx-%#lx flags %#lx\n",
 			 vma->vm_start, vma->vm_end, vma->vm_flags);
 		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
 			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
@@ -895,7 +897,8 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
 		for (i = 0; i < pgarr->nr_used; i++) {
 			struct page *page;
 
-			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
+			_ckpt_debug(ctx, CKPT_DPAGE, "got page %#lx\n",
+				    vaddrs[i]);
 			if (inode)
 				page = bring_shared_page(vaddrs[i], inode);
 			else
@@ -942,7 +945,8 @@ int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
 		if (IS_ERR(h))
 			break;
 
-		ckpt_debug("total pages %ld\n", (unsigned long) h->nr_pages);
+		ckpt_debug(ctx, "total pages %ld\n",
+			   (unsigned long) h->nr_pages);
 
 		nr_pages = h->nr_pages;
 		ckpt_hdr_put(ctx, h);
@@ -1012,11 +1016,13 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
 
 /**
  * generic_vma_restore - restore a vma
+ * @ctx - checkpoint context
  * @mm - address space
  * @file - file to map (NULL for anonymous)
  * @h - vma header data
  */
-unsigned long generic_vma_restore(struct mm_struct *mm,
+unsigned long generic_vma_restore(struct ckpt_ctx *ctx,
+				  struct mm_struct *mm,
 				  struct file *file,
 				  struct ckpt_hdr_vma *h)
 {
@@ -1038,7 +1044,7 @@ unsigned long generic_vma_restore(struct mm_struct *mm,
 	addr = do_mmap_pgoff(file, vm_start, vm_size,
 			     vm_prot, vm_flags, vm_pgoff);
 	up_write(&mm->mmap_sem);
-	ckpt_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+	ckpt_debug(ctx, "size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
 		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
 
 	return addr;
@@ -1059,7 +1065,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (h->vm_flags & (VM_SHARED | VM_MAYSHARE))
 		return -EINVAL;
 
-	addr = generic_vma_restore(mm, file, h);
+	addr = generic_vma_restore(ctx, mm, file, h);
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
@@ -1175,7 +1181,8 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d inoref %d\n",
+	ckpt_debug(ctx,
+		   "vma %#lx-%#lx flags %#lx type %d vmaref %d inoref %d\n",
 		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
 		   (unsigned long) h->vm_flags, (int) h->vma_type,
 		   (int) h->vma_objref, (int) h->ino_objref);
@@ -1196,10 +1203,10 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	BUG_ON(ops->vma_type != h->vma_type);
 
 	if (ops->restore) {
-		ckpt_debug("vma type %s\n", ops->vma_name);
+		ckpt_debug(ctx, "vma type %s\n", ops->vma_name);
 		ret = ops->restore(ctx, mm, h);
 	} else {
-		ckpt_debug("vma ignored\n");
+		ckpt_debug(ctx, "vma ignored\n");
 		ret = 0;
 	}
  out:
@@ -1237,7 +1244,7 @@ static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return (struct mm_struct *) h;
 
-	ckpt_debug("map_count %d\n", h->map_count);
+	ckpt_debug(ctx, "map_count %d\n", h->map_count);
 
 	/* XXX need more sanity checks */
 
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 730dd82..e89e685 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -624,7 +624,7 @@ int ckpt_obj_collect(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	obj = obj_lookup_add(ctx, ptr, type, &first);
 	if (IS_ERR(obj))
 		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d first %d\n",
+	ckpt_debug(ctx, "%s objref %d first %d\n",
 		   obj->ops->obj_name, obj->objref, first);
 	return (first ? obj->objref : 0);
 }
@@ -645,7 +645,8 @@ int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	obj = obj_find_by_ptr(ctx, ptr);
 	BUG_ON(obj && obj->ops->obj_type != type);
 	if (obj)
-		ckpt_debug("%s objref %d\n", obj->ops->obj_name, obj->objref);
+		ckpt_debug(ctx, "%s objref %d\n", obj->ops->obj_name,
+			   obj->objref);
 	return obj ? obj->objref : 0;
 }
 
@@ -682,7 +683,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 	obj = obj_lookup_add(ctx, ptr, type, first);
 	if (IS_ERR(obj))
 		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d first %d\n",
+	ckpt_debug(ctx, "%s objref %d first %d\n",
 		   obj->ops->obj_name, obj->objref, *first);
 
 	if (*first && obj_reverse_leak(ctx, obj))
@@ -780,7 +781,7 @@ int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 			return -EBUSY;
 		}
 	} else {
-		ckpt_debug("visit %s objref %d\n",
+		ckpt_debug(ctx, "visit %s objref %d\n",
 			   obj->ops->obj_name, obj->objref);
 		obj->flags |= CKPT_OBJ_VISITED;
 	}
@@ -823,6 +824,7 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
 
 /**
  * obj_sock_adjust_users - remove implicit reference on DEAD sockets
+ * @ctx: checkpoint context
  * @obj: CKPT_OBJ_SOCK object to adjust
  *
  * Sockets that have been disconnected from their struct file have
@@ -830,13 +832,14 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
  * assumption of such a reference is therefore incorrect, so we correct
  * it here.
  */
-static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
+static inline void obj_sock_adjust_users(struct ckpt_ctx *ctx,
+					 struct ckpt_obj *obj)
 {
 	struct sock *sk = (struct sock *)obj->ptr;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
 		obj->users--;
-		ckpt_debug("Adjusting SOCK %i count to %i\n",
+		ckpt_debug(ctx, "Adjusting SOCK %i count to %i\n",
 			   obj->objref, obj->users);
 	}
 }
@@ -858,6 +861,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 
 	/* account for ctx->file reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	if (ctx->logfile)
+		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
 	/* account for ctx->root_nsproxy reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
 
@@ -866,10 +871,10 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 			continue;
 
 		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
-			obj_sock_adjust_users(obj);
+			obj_sock_adjust_users(ctx, obj);
 
 		if (obj->ops->ref_users(obj->ptr) != obj->users) {
-			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
+			ckpt_debug(ctx, "usage leak: %s\n", obj->ops->obj_name);
 			ckpt_write_err(ctx, "OP", "leak: usage (%d != %d (%s)",
 				       obj->objref, obj->ptr,
 				       obj->ops->ref_users(obj->ptr),
@@ -894,7 +899,7 @@ int ckpt_obj_visited(struct ckpt_ctx *ctx)
 
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!(obj->flags & CKPT_OBJ_VISITED)) {
-			ckpt_debug("reverse leak: %s (%d)\n",
+			ckpt_debug(ctx, "reverse leak: %s (%d)\n",
 				   obj->ops->obj_name, obj->objref);
 			ckpt_write_err(ctx, "OP", "leak: not visited (%s)",
 				       obj->objref, obj->ptr,
@@ -929,7 +934,8 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
 	struct ckpt_obj *obj;
 	void *ptr = NULL;
 
-	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
+	ckpt_debug(ctx, "len %d ref %d type %d\n", h->h.len, h->objref,
+		   h->objtype);
 	if (h->objtype >= CKPT_OBJ_MAX)
 		return -EINVAL;
 	if (h->objref <= 0)
@@ -985,7 +991,7 @@ int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
 	obj = obj_new(ctx, ptr, objref, type);
 	if (IS_ERR(obj))
 		return PTR_ERR(obj);
-	ckpt_debug("%s objref %d\n", obj->ops->obj_name, objref);
+	ckpt_debug(ctx, "%s objref %d\n", obj->ops->obj_name, objref);
 	return obj->objref;
 }
 
@@ -1007,6 +1013,6 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 	obj = obj_find_by_objref(ctx, objref);
 	if (!obj)
 		return ERR_PTR(-EINVAL);
-	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
+	ckpt_debug(ctx, "%s ref %d\n", obj->ops->obj_name, obj->objref);
 	return (obj->ops->obj_type == type ? obj->ptr : ERR_PTR(-ENOMSG));
 }
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 6b2ef4c..69ea33d 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -174,7 +174,7 @@ static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	ns_objref = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
 	put_nsproxy(nsproxy);
 
-	ckpt_debug("nsproxy: objref %d\n", ns_objref);
+	ckpt_debug(ctx, "nsproxy: objref %d\n", ns_objref);
 	if (ns_objref < 0)
 		return ns_objref;
 
@@ -245,30 +245,30 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	 */
 
 	ret = checkpoint_task_creds(ctx, t);
-	ckpt_debug("cred: objref %d\n", ret);
+	ckpt_debug(ctx, "cred: objref %d\n", ret);
 	if (!ret) {
 		ret = checkpoint_task_ns(ctx, t);
-		ckpt_debug("ns: objref %d\n", ret);
+		ckpt_debug(ctx, "ns: objref %d\n", ret);
 	}
 	if (ret < 0)
 		return ret;
 
 	files_objref = checkpoint_obj_file_table(ctx, t);
-	ckpt_debug("files: objref %d\n", files_objref);
+	ckpt_debug(ctx, "files: objref %d\n", files_objref);
 	if (files_objref < 0) {
 		ckpt_write_err(ctx, "TE", "files_struct", files_objref);
 		return files_objref;
 	}
 
 	mm_objref = checkpoint_obj_mm(ctx, t);
-	ckpt_debug("mm: objref %d\n", mm_objref);
+	ckpt_debug(ctx, "mm: objref %d\n", mm_objref);
 	if (mm_objref < 0) {
 		ckpt_write_err(ctx, "TE", "mm_struct", mm_objref);
 		return mm_objref;
 	}
 
 	sighand_objref = checkpoint_obj_sighand(ctx, t);
-	ckpt_debug("sighand: objref %d\n", sighand_objref);
+	ckpt_debug(ctx, "sighand: objref %d\n", sighand_objref);
 	if (sighand_objref < 0) {
 		ckpt_write_err(ctx, "TE", "sighand_struct", sighand_objref);
 		return sighand_objref;
@@ -283,7 +283,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	 */
 	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
 					    CKPT_OBJ_SIGNAL, &first);
-	ckpt_debug("signal: objref %d\n", signal_objref);
+	ckpt_debug(ctx, "signal: objref %d\n", signal_objref);
 	if (signal_objref < 0)
 		return signal_objref;
 
@@ -330,7 +330,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (fn == do_no_restart_syscall) {
 
 		h->function_type = CKPT_RESTART_BLOCK_NONE;
-		ckpt_debug("restart_block: non\n");
+		ckpt_debug(ctx, "restart_block: non\n");
 
 	} else if (fn == hrtimer_nanosleep_restart) {
 
@@ -338,7 +338,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->arg_0 = restart_block->nanosleep.index;
 		h->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
 		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: hrtimer expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: hrtimer expire %lld now %lld\n",
 			 expire, base);
 
 	} else if (fn == posix_cpu_nsleep_restart) {
@@ -350,7 +350,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		ts.tv_sec = restart_block->arg2;
 		ts.tv_nsec = restart_block->arg3;
 		expire = timespec_to_ns(&ts);
-		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: posix_cpu expire %lld now %lld\n",
 			 expire, base);
 
 #ifdef CONFIG_COMPAT
@@ -361,7 +361,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
 		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
 		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: compat expire %lld now %lld\n",
 			 expire, base);
 
 	} else if (fn == compat_clock_nanosleep_restart) {
@@ -371,7 +371,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
 		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
 		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: compat_clock expire %lld now %lld\n",
 			 expire, base);
 
 #endif
@@ -383,7 +383,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->arg_2 = restart_block->futex.flags;
 		h->arg_3 = restart_block->futex.bitset;
 		expire = restart_block->futex.time;
-		ckpt_debug("restart_block: futex expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: futex expire %lld now %lld\n",
 			 expire, base);
 
 	} else if (fn == do_restart_poll) {
@@ -396,7 +396,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		ts.tv_sec = restart_block->poll.tv_sec;
 		ts.tv_nsec = restart_block->poll.tv_nsec;
 		expire = timespec_to_ns(&ts);
-		ckpt_debug("restart_block: poll expire %lld now %lld\n",
+		ckpt_debug(ctx, "restart_block: poll expire %lld now %lld\n",
 			 expire, base);
 
 	} else {
@@ -408,13 +408,13 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 	/* common to all restart blocks: */
 	h->arg_4 = (base < expire ? expire - base : 0);
 
-	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+	ckpt_debug(ctx, "restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
 		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
-	ckpt_debug("restart_block ret %d\n", ret);
+	ckpt_debug(ctx, "restart_block ret %d\n", ret);
 	return ret;
 }
 
@@ -426,7 +426,7 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ctx->tsk = t;
 
 	ret = checkpoint_task_struct(ctx, t);
-	ckpt_debug("task %d\n", ret);
+	ckpt_debug(ctx, "task %d\n", ret);
 
 	if (ret < 0)
 		goto out;
@@ -436,23 +436,23 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return 0;
 
 	ret = checkpoint_task_objs(ctx, t);
-	ckpt_debug("objs %d\n", ret);
+	ckpt_debug(ctx, "objs %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_thread(ctx, t);
-	ckpt_debug("thread %d\n", ret);
+	ckpt_debug(ctx, "thread %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_restart_block(ctx, t);
-	ckpt_debug("restart-blocks %d\n", ret);
+	ckpt_debug(ctx, "restart-blocks %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_cpu(ctx, t);
-	ckpt_debug("cpu %d\n", ret);
+	ckpt_debug(ctx, "cpu %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_task_signal(ctx, t);
-	ckpt_debug("task-signal %d\n", ret);
+	ckpt_debug(ctx, "task-signal %d\n", ret);
  out:
 	ctx->tsk = NULL;
 	return ret;
@@ -564,7 +564,7 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
 		switch_task_namespaces(current, nsproxy);
 	}
  out:
-	ckpt_debug("nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
+	ckpt_debug(ctx, "nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -581,14 +581,14 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 
 	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(realcred)) {
-		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
+		ckpt_debug(ctx, "Error %ld fetching realcred (ref %d)\n",
 			PTR_ERR(realcred), h->cred_ref);
 		ret = PTR_ERR(realcred);
 		goto out;
 	}
 	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(ecred)) {
-		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
+		ckpt_debug(ctx, "Error %ld fetching ecred (ref %d)\n",
 			PTR_ERR(ecred), h->ecred_ref);
 		ret = PTR_ERR(ecred);
 		goto out;
@@ -597,7 +597,7 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 	ctx->ecred = ecred;
 
 out:
-	ckpt_debug("Returning %d\n", ret);
+	ckpt_debug(ctx, "Returning %d\n", ret);
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -614,38 +614,38 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 */
 	ret = restore_task_creds(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_creds returned %d\n", ret);
+		ckpt_debug(ctx, "restore_task_creds returned %d\n", ret);
 		return ret;
 	}
 	ret = restore_task_ns(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_ns returned %d\n", ret);
+		ckpt_debug(ctx, "restore_task_ns returned %d\n", ret);
 		return ret;
 	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h)) {
-		ckpt_debug("Error fetching task obj\n");
+		ckpt_debug(ctx, "Error fetching task obj\n");
 		return PTR_ERR(h);
 	}
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
-	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+	ckpt_debug(ctx, "file_table: ret %d (%p)\n", ret, current->files);
 	if (ret < 0)
 		goto out;
 
 	ret = restore_obj_mm(ctx, h->mm_objref);
-	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+	ckpt_debug(ctx, "mm: ret %d (%p)\n", ret, current->mm);
 	if (ret < 0)
 		goto out;
 
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
-	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	ckpt_debug(ctx, "sighand: ret %d (%p)\n", ret, current->sighand);
 	if (ret < 0)
 		goto out;
 
 	ret = restore_obj_signal(ctx, h->signal_objref);
-	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
+	ckpt_debug(ctx, "signal: ret %d (%p)\n", ret, current->signal);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -694,9 +694,9 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	expire = ktime_to_ns(ctx->ktime_begin) + h->arg_4;
 	restart_block.fn = NULL;
 
-	ckpt_debug("restart_block: expire %lld begin %lld\n",
+	ckpt_debug(ctx, "restart_block: expire %lld begin %lld\n",
 		 expire, ktime_to_ns(ctx->ktime_begin));
-	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+	ckpt_debug(ctx, "restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
 		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
 
 	switch (h->function_type) {
@@ -876,7 +876,7 @@ int restore_task(struct ckpt_ctx *ctx)
 	int ret;
 
 	ret = restore_task_struct(ctx);
-	ckpt_debug("task %d\n", ret);
+	ckpt_debug(ctx, "task %d\n", ret);
 	if (ret < 0)
 		goto out;
 
@@ -888,23 +888,23 @@ int restore_task(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 	ret = restore_task_objs(ctx);
-	ckpt_debug("objs %d\n", ret);
+	ckpt_debug(ctx, "objs %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = restore_thread(ctx);
-	ckpt_debug("thread %d\n", ret);
+	ckpt_debug(ctx, "thread %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = restore_restart_block(ctx);
-	ckpt_debug("restart-blocks %d\n", ret);
+	ckpt_debug(ctx, "restart-blocks %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = restore_cpu(ctx);
-	ckpt_debug("cpu %d\n", ret);
+	ckpt_debug(ctx, "cpu %d\n", ret);
 	if (ret < 0)
 		goto out;
 	ret = restore_creds(ctx);
-	ckpt_debug("creds: ret %d\n", ret);
+	ckpt_debug(ctx, "creds: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 32a9fc5..5e17de4 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -64,7 +64,7 @@ static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
 
 	s = kmalloc(sizeof(*s), GFP_KERNEL);
 	if (!s) {
-		ckpt_debug("no memory to register ?!\n");
+		ckpt_debug(ctx, "no memory to register ?!\n");
 		return -ENOMEM;
 	}
 	s->pid = current->pid;
@@ -137,15 +137,16 @@ void restore_debug_free(struct ckpt_ctx *ctx)
 	 */
 	list_for_each_entry(s, &ctx->task_status, list)
 		count++;
-	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
+	ckpt_debug(ctx, "%d tasks registered, nr_tasks was %d nr_total %d\n",
 		   count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
 
-	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
+	ckpt_debug(ctx, "active pid was %d, ctx->errno %d\n", ctx->active_pid,
 		   ctx->errno);
-	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
+	ckpt_debug(ctx, "kflags %lu uflags %lu oflags %lu", ctx->kflags,
 		   ctx->uflags, ctx->oflags);
 	for (i = 0; i < ctx->active_pid; i++)
-		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
+		ckpt_debug(ctx, "task[%d] to run %d\n", i,
+			   ctx->pids_arr[i].vpid);
 
 	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
 		if (s->flags & RESTART_DBG_COORD)
@@ -170,7 +171,8 @@ void restore_debug_free(struct ckpt_ctx *ctx)
 			state = "Exited";
 		else
 			state = "??????";
-		ckpt_debug("pid %d type %s state %s\n", s->pid, which, state);
+		ckpt_debug(ctx, "pid %d type %s state %s\n", s->pid, which,
+			   state);
 		list_del(&s->list);
 		kfree(s);
 	}
@@ -194,13 +196,13 @@ static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 	len = h->len - sizeof(*h);
 	ptr = kzalloc(len + 1, GFP_KERNEL);
 	if (!ptr) {
-		ckpt_debug("insufficient memory to report image error\n");
+		ckpt_debug(ctx, "insufficient memory to report image error\n");
 		return -ENOMEM;
 	}
 
 	ret = ckpt_kread(ctx, ptr, len);
 	if (ret >= 0) {
-		ckpt_debug("%s\n", &ptr[1]);
+		ckpt_debug(ctx, "%s\n", &ptr[1]);
 		ret = -EIO;
 	}
 
@@ -224,7 +226,7 @@ static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
 
 	*h = *hh;	/* yay ! */
 
-	_ckpt_debug(CKPT_DOBJ, "shared len %d type %d\n", h->len, h->type);
+	_ckpt_debug(ctx, CKPT_DOBJ, "shared len %d type %d\n", h->len, h->type);
 	ret = ckpt_kread(ctx, (h + 1), hh->len - sizeof(struct ckpt_hdr));
 	if (ret < 0)
 		goto out;
@@ -255,7 +257,7 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
 	ret = ckpt_kread(ctx, h, sizeof(*h));
 	if (ret < 0)
 		return ret;
-	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+	_ckpt_debug(ctx, CKPT_DRW, "type %d len %d(%d,%d)\n",
 		    h->type, h->len, len, max);
 	if (h->len < sizeof(*h))
 		return -EINVAL;
@@ -363,7 +365,7 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 	ret = ckpt_kread(ctx, &hh, sizeof(hh));
 	if (ret < 0)
 		return ERR_PTR(ret);
-	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
+	_ckpt_debug(ctx, CKPT_DRW, "type %d len %d(%d,%d)\n",
 		    hh.type, hh.len, len, max);
 	if (hh.len < sizeof(*h))
 		return ERR_PTR(-EINVAL);
@@ -706,7 +708,7 @@ static inline void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
 {
 	/* first to fail: notify everyone (racy but harmless) */
 	if (!ckpt_test_ctx_error(ctx)) {
-		ckpt_debug("setting restart error %d\n", errno); \
+		ckpt_debug(ctx, "setting restart error %d\n", errno); \
 		ckpt_set_ctx_error(ctx, errno);
 		complete(&ctx->complete);
 		wake_up_all(&ctx->waitq);
@@ -720,7 +722,8 @@ static inline void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
 */
 #define restore_notify_error(ctx, errno) \
 do { \
-	ckpt_debug("restart error %d, root pid %d\n", errno, ctx->root_pid); \
+	ckpt_debug(ctx, "restart error %d, root pid %d\n", errno, \
+		   ctx->root_pid); \
 	_restore_notify_error(ctx, errno); \
 } while(0)
 
@@ -744,7 +747,8 @@ static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
 		task->checkpoint_ctx = ckpt_ctx_get(ctx);
 		ret = 0;
 	} else {
-		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
+		ckpt_debug(ctx, "task %d has checkpoint_ctx\n",
+			   task_pid_vnr(task));
 		ret = 1;
 	}
 	task_unlock(task);
@@ -760,7 +764,7 @@ static void clear_task_ctx(struct task_struct *task)
 	task->checkpoint_ctx = NULL;
 	task_unlock(task);
 
-	ckpt_debug("task %d clear checkpoint_ctx\n", task_pid_vnr(task));
+	ckpt_debug(old, "task %d clear checkpoint_ctx\n", task_pid_vnr(task));
 	ckpt_ctx_put(old);
 }
 
@@ -794,7 +798,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
-			ckpt_debug("could not find task %d\n", pid);
+			ckpt_debug(ctx, "could not find task %d\n", pid);
 			restore_notify_error(ctx, -ESRCH);
 			return -ESRCH;
 		}
@@ -811,11 +815,11 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 	pid_t pid = task_pid_vnr(current);
 	int ret;
 
-	ckpt_debug("pid %d waiting\n", pid);
+	ckpt_debug(ctx, "pid %d waiting\n", pid);
 	ret = wait_event_interruptible(ctx->waitq,
 				       is_task_active(ctx, pid) ||
 				       ckpt_test_ctx_error(ctx));
-	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
+	ckpt_debug(ctx, "active %d < %d (ret %d, errno %d)\n",
 		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
 	if (!ret && ckpt_test_ctx_error(ctx))
 		ret = -EBUSY;
@@ -824,9 +828,9 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 
 static int wait_task_sync(struct ckpt_ctx *ctx)
 {
-	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	ckpt_debug(ctx, "pid %d syncing\n", task_pid_vnr(current));
 	wait_event_interruptible(ctx->waitq, ckpt_test_ctx_complete(ctx));
-	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
+	ckpt_debug(ctx, "task sync done (errno %d)\n", ctx->errno);
 	if (ckpt_test_ctx_error(ctx))
 		return -EBUSY;
 	return 0;
@@ -844,16 +848,12 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 	 * reference to its restart context.
 	 */
 	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
-	if (ret < 0) {
-		ckpt_debug("wait_checkpoint_ctx: failed (%d)\n", ret);
+	if (ret < 0)
 		return ERR_PTR(ret);
-	}
 
 	ctx = get_task_ctx(current);
-	if (!ctx) {
-		ckpt_debug("wait_checkpoint_ctx: checkpoint_ctx missing\n");
+	if (!ctx)
 		return ERR_PTR(-EAGAIN);
-	}
 
 	return ctx;
 }
@@ -1009,15 +1009,15 @@ static int __prepare_descendants(struct task_struct *task, void *data)
 {
 	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
 
-	ckpt_debug("consider task %d\n", task_pid_vnr(task));
+	ckpt_debug(ctx, "consider task %d\n", task_pid_vnr(task));
 
 	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
-		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
+		ckpt_debug(ctx, "stranger task %d\n", task_pid_vnr(task));
 		return -EPERM;
 	}
 
 	if (task_ptrace(task) & PT_PTRACED) {
-		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		ckpt_debug(ctx, "ptraced task %d\n", task_pid_vnr(task));
 		return -EBUSY;
 	}
 
@@ -1034,7 +1034,7 @@ static int __prepare_descendants(struct task_struct *task, void *data)
 	if (!task->exit_state) {
 		if (set_task_ctx(task, ctx))
 			return -EBUSY;
-		ckpt_debug("prepare task %d\n", task_pid_vnr(task));
+		ckpt_debug(ctx, "prepare task %d\n", task_pid_vnr(task));
 		wake_up_process(task);
 		return 1;
 	}
@@ -1054,8 +1054,8 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 {
 	int nr_pids;
 
-	nr_pids = walk_task_subtree(root, __prepare_descendants, ctx);
-	ckpt_debug("nr %d/%d\n", ctx->nr_pids, nr_pids);
+	nr_pids = walk_task_subtree(ctx, root, __prepare_descendants, ctx);
+	ckpt_debug(ctx, "nr %d/%d\n", ctx->nr_pids, nr_pids);
 	if (nr_pids < 0)
 		return nr_pids;
 
@@ -1082,7 +1082,7 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 		return ret;
 
 	ret = wait_for_completion_interruptible(&ctx->complete);
-	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
+	ckpt_debug(ctx, "final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
 	/*
 	 * Usually when restart fails, the restarting task will first
 	 * set @ctx->errno before waking us up. In the rare event that
@@ -1160,7 +1160,7 @@ static int __destroy_descendants(struct task_struct *task, void *data)
 
 static void destroy_descendants(struct ckpt_ctx *ctx)
 {
-	walk_task_subtree(ctx->root_task, __destroy_descendants, ctx);
+	walk_task_subtree(ctx, ctx->root_task, __destroy_descendants, ctx);
 }
 
 static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
@@ -1173,15 +1173,15 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	restore_debug_running(ctx);
 
 	ret = restore_read_header(ctx);
-	ckpt_debug("restore header: %d\n", ret);
+	ckpt_debug(ctx, "restore header: %d\n", ret);
 	if (ret < 0)
 		return ret;
 	ret = restore_container(ctx);
-	ckpt_debug("restore container: %d\n", ret);
+	ckpt_debug(ctx, "restore container: %d\n", ret);
 	if (ret < 0)
 		return ret;
 	ret = restore_read_tree(ctx);
-	ckpt_debug("restore tree: %d\n", ret);
+	ckpt_debug(ctx, "restore tree: %d\n", ret);
 	if (ret < 0)
 		return ret;
 
@@ -1198,14 +1198,12 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 * that ancestor won't proceed deeper to interfere with our
 	 * descendants that are restarting.
 	 */
-	if (set_task_ctx(current, ctx)) {
+	if (set_task_ctx(current, ctx))
 		/*
 		 * We are a bad-behaving descendant: an ancestor must
 		 * have prepare_descendants() us as part of a restart.
 		 */
-		ckpt_debug("coord already has checkpoint_ctx\n");
 		return -EBUSY;
-	}
 
 	/*
 	 * From now on we are committed to the restart. If anything
@@ -1215,39 +1213,39 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = pre_restore_task();
-		ckpt_debug("pre restore task: %d\n", ret);
+		ckpt_debug(ctx, "pre restore task: %d\n", ret);
 		if (ret < 0)
 			goto out;
 		ret = restore_task(ctx);
-		ckpt_debug("restore task: %d\n", ret);
+		ckpt_debug(ctx, "restore task: %d\n", ret);
 		if (ret < 0)
 			goto out;
 	} else {
 		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
-		ckpt_debug("restore prepare: %d\n", ret);
+		ckpt_debug(ctx, "restore prepare: %d\n", ret);
 		if (ret < 0)
 			goto out;
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
-		ckpt_debug("restore finish: %d\n", ret);
+		ckpt_debug(ctx, "restore finish: %d\n", ret);
 		if (ret < 0)
 			goto out;
 	}
 
 	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
-	ckpt_debug("restore deferqueue: %d\n", ret);
+	ckpt_debug(ctx, "restore deferqueue: %d\n", ret);
 	if (ret < 0)
 		goto out;
 
 	ret = restore_read_tail(ctx);
-	ckpt_debug("restore tail: %d\n", ret);
+	ckpt_debug(ctx, "restore tail: %d\n", ret);
 	if (ret < 0)
 		goto out;
 
 	if (ctx->uflags & RESTART_FROZEN) {
 		ret = cgroup_freezer_make_frozen(ctx->root_task);
-		ckpt_debug("freezing restart tasks ... %d\n", ret);
+		ckpt_debug(ctx, "freezing restart tasks ... %d\n", ret);
 	}
  out:
 	if (ctx->uflags & RESTART_TASKSELF)
@@ -1344,14 +1342,14 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
 		if (ret < 0) {
 			/* partial restore is undefined: terminate */
-			ckpt_debug("restart err %ld, exiting\n", ret);
+			ckpt_debug(ctx, "restart err %ld, exiting\n", ret);
 			force_sig(SIGKILL, current);
 		} else {
 			ret = restore_retval();
 		}
 	}
 
-	ckpt_debug("sys_restart returns %ld\n", ret);
+	ckpt_debug(ctx, "sys_restart returns %ld\n", ret);
 	return ret;
 }
 
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index cdfb142..852c735 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -367,7 +367,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 		 * the signal from this very expiry won't be sent before
 		 * we release t->sighand->siglock).
 		 */
-		ckpt_debug("active ! %lld\n", delta.tv64);
+		ckpt_debug(ctx, "active ! %lld\n", delta.tv64);
 		if (delta.tv64 <= 0)
 			delta.tv64 = NSEC_PER_USEC;
 		h->it_real_value = ktime_to_ns(delta);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..a07c8fa 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -204,6 +204,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	if (ctx->file)
 		fput(ctx->file);
+	if (ctx->logfile)
+		fput(ctx->logfile);
 
 	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->fs_mnt);
@@ -225,7 +227,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 }
 
 static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
-				       unsigned long kflags)
+				       unsigned long kflags, int logfd)
 {
 	struct ckpt_ctx *ctx;
 	int err;
@@ -238,6 +240,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	/* If logfd's a bad fd that's fine, no log output required... */
+	ctx->logfile = fget(logfd);
+
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
@@ -285,7 +290,7 @@ void ckpt_ctx_put(struct ckpt_ctx *ctx)
 		ckpt_ctx_free(ctx);
 }
 
-int walk_task_subtree(struct task_struct *root,
+int walk_task_subtree(struct ckpt_ctx *ctx, struct task_struct *root,
 		      int (*func)(struct task_struct *, void *),
 		      void *data)
 {
@@ -335,10 +340,59 @@ int walk_task_subtree(struct task_struct *root,
 	}
 	read_unlock(&tasklist_lock);
 
-	ckpt_debug("total %d ret %d\n", total, ret);
+	ckpt_debug(ctx, "total %d ret %d\n", total, ret);
 	return (ret < 0 ? ret : total);
 }
 
+int do_ckpt_debug(struct ckpt_ctx *ctx, char *fmt, int p1, int p2,
+	const char *f, int l, ...)
+{
+	mm_segment_t fs;
+	struct file *file = ctx->logfile;
+	int ret, count;
+	char buf[200], *bufp = buf;
+	va_list args;
+
+	/* write the prefix */
+	count = snprintf(buf, 200, "[%d:%d:%s:%d] ", p1, p2, f, l);
+	if (count > 200) {
+		bufp = kmalloc(count, GFP_KERNEL);
+		if (!bufp)
+			return -ENOMEM; /* ignored */
+		count = snprintf(bufp, count, "[%d:%d:%s:%d] ", p1, p2, f, l);
+	}
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+	if (bufp != buf)
+		kfree(bufp);
+	if (ret < 0)
+		return ret;
+	bufp = buf;
+
+	/* now write the actual error msg */
+	va_start(args, l);
+	count = vsnprintf(bufp, 200, fmt, args);
+	va_end(args);
+	if (count > 200) {
+		bufp = kmalloc(count, GFP_KERNEL);
+		if (!bufp)
+			return -ENOMEM; /* ignored */
+		va_start(args, l);
+		count = vsnprintf(bufp, count, fmt, args);
+		va_end(args);
+	}
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kwrite(file, bufp, count);
+	set_fs(fs);
+
+	if (bufp != buf)
+		kfree(bufp);
+	return ret;
+}
 
 /**
  * sys_checkpoint - checkpoint a container
@@ -349,7 +403,8 @@ int walk_task_subtree(struct task_struct *root,
  * Returns positive identifier on success, 0 when returning from restart
  * or negative value on error
  */
-SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
 {
 	struct ckpt_ctx *ctx;
 	long ret;
@@ -362,7 +417,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 
 	if (pid == 0)
 		pid = task_pid_vnr(current);
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
+	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
@@ -384,7 +439,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  * Returns negative value on error, or otherwise returns in the realm
  * of the original checkpoint
  */
-SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags, int, logfd)
 {
 	struct ckpt_ctx *ctx = NULL;
 	long ret;
@@ -397,7 +452,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 		return -EPERM;
 
 	if (pid)
-		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 1b220c1..2fd2cd4 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2664,7 +2664,7 @@ static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	 */
 
 	real_tty = tty_pair_get_tty(tty);
-	ckpt_debug("tty: %p, real_tty: %p\n", tty, real_tty);
+	ckpt_debug(ctx, "tty: %p, real_tty: %p\n", tty, real_tty);
 
 	master_objref = checkpoint_obj(ctx, real_tty->link, CKPT_OBJ_TTY);
 	if (master_objref < 0)
@@ -2672,7 +2672,7 @@ static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	slave_objref = checkpoint_obj(ctx, real_tty, CKPT_OBJ_TTY);
 	if (slave_objref < 0)
 		return slave_objref;
-	ckpt_debug("master %p %d, slave %p %d\n",
+	ckpt_debug(ctx, "master %p %d, slave %p %d\n",
 		   real_tty->link, master_objref, real_tty, slave_objref);
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
@@ -2704,7 +2704,7 @@ static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file)
 	if (!tty_can_checkpoint(ctx, tty))
 		return -ENOSYS;
 
-	ckpt_debug("collecting tty: %p\n", tty);
+	ckpt_debug(ctx, "collecting tty: %p\n", tty);
 	ret = ckpt_obj_collect(ctx, tty, CKPT_OBJ_TTY);
 	if (ret < 0)
 		return ret;
@@ -2714,7 +2714,7 @@ static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file)
 			ckpt_write_err(ctx, "TP", "tty: missing link\n", tty);
 			return -EIO;
 		}
-		ckpt_debug("collecting slave tty: %p\n", tty->link);
+		ckpt_debug(ctx, "collecting slave tty: %p\n", tty->link);
 		ret = ckpt_obj_collect(ctx, tty->link, CKPT_OBJ_TTY);
 	}
 
@@ -2781,7 +2781,7 @@ static int checkpoint_tty_ldisc(struct ckpt_ctx *ctx, struct tty_struct *tty)
 	if (ret < 0)
 		return ret;
 
-	ckpt_debug("datalen %d\n", datalen);
+	ckpt_debug(ctx, "datalen %d\n", datalen);
 	if (datalen) {
 		ret = ckpt_write_buffer(ctx, NULL, datalen);
 		if (ret < 0)
@@ -2836,7 +2836,7 @@ static int do_checkpoint_tty(struct ckpt_ctx *ctx, struct tty_struct *tty)
 
 	/* if master, reserve an objref (see do_restore_tty) */
 	h->file_objref = (master ? ckpt_obj_reserve(ctx) : 0);
-	ckpt_debug("link %d file %d\n", h->link_objref, h->file_objref);
+	ckpt_debug(ctx, "link %d file %d\n", h->link_objref, h->file_objref);
 
 	h->index = tty->index;
 	h->ldisc = tty->ldisc->ops->num;
@@ -2889,7 +2889,7 @@ struct file *tty_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		return ERR_PTR(-EINVAL);
 
 	tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
-	ckpt_debug("tty %p objref %d\n", tty, h->tty_objref);
+	ckpt_debug(ctx, "tty %p objref %d\n", tty, h->tty_objref);
 
 	/* at this point the tty should have been restore already */
 	if (IS_ERR(tty))
@@ -2910,13 +2910,13 @@ struct file *tty_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 					typeof(*file), f_u.fu_list);
 		get_file(file);
 		file_list_unlock();
-		ckpt_debug("master file %p\n", file);
+		ckpt_debug(ctx, "master file %p\n", file);
 	} else {
 		sprintf(slavepath, "/dev/pts/%d", tty->index);
 		slavelock = test_bit(TTY_PTY_LOCK, &tty->link->flags);
 		clear_bit(TTY_PTY_LOCK, &tty->link->flags);
 		file = filp_open(slavepath, O_RDWR | O_NOCTTY, 0);
-		ckpt_debug("slave file %p (idnex %d)\n", file, tty->index);
+		ckpt_debug(ctx, "slave file %p (idnex %d)\n", file, tty->index);
 		if (IS_ERR(file))
 			return file;
 		if (slavelock)
@@ -3026,7 +3026,7 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	if (test_bit(TTY_HUPPED, (unsigned long *) &h->flags) && master)
 		goto out;
 
-	ckpt_debug("sanity checks passed, link %d\n", h->link_objref);
+	ckpt_debug(ctx, "sanity checks passed, link %d\n", h->link_objref);
 
 	/*
 	 * If we ever support more than PTYs, this would be tty-type
@@ -3060,7 +3060,7 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 		tty = tty->link;
 	}
 
-	ckpt_debug("tty %p (hup %d)\n",
+	ckpt_debug(ctx, "tty %p (hup %d)\n",
 		   tty, test_bit(TTY_HUPPED, (unsigned long *) &h->flags));
 
 	/* we now have the desired tty: restore its state as per @h */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..c96337a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -50,7 +50,7 @@
 	 RESTART_FROZEN | \
 	 RESTART_GHOST)
 
-extern int walk_task_subtree(struct task_struct *task,
+extern int walk_task_subtree(struct ckpt_ctx *ctx, struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
 			     void *data);
 extern void exit_checkpoint(struct task_struct *tsk);
@@ -253,7 +253,8 @@ extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_mm(struct ckpt_ctx *ctx);
 
-extern unsigned long generic_vma_restore(struct mm_struct *mm,
+extern unsigned long generic_vma_restore(struct ckpt_ctx *ctx,
+					 struct mm_struct *mm,
 					 struct file *file,
 					 struct ckpt_hdr_vma *h);
 
@@ -337,13 +338,15 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DFLAG	0xffff		/* everything */
 #endif
 
+extern int do_ckpt_debug(struct ckpt_ctx *ctx, char *fmt, int p1, int p2,
+	const char *f, int l, ...);
+
 #ifdef CONFIG_CHECKPOINT_DEBUG
 
 extern void restore_debug_free(struct ckpt_ctx *ctx);
 extern unsigned long ckpt_debug_level;
 
-/* use this to select a specific debug level */
-#define _ckpt_debug(level, fmt, args...)				\
+#define ckpt_syslog(level, fmt, args...)				\
 	do {								\
 		if (ckpt_debug_level & (level))				\
 			printk(KERN_DEBUG "[%d:%d:c/r:%s:%d] " fmt,	\
@@ -353,23 +356,40 @@ extern unsigned long ckpt_debug_level;
 				__func__, __LINE__, ## args);		\
 	} while (0)
 
-/*
- * CKPT_DBASE is the base flags, doesn't change
- * CKPT_DFLAG is to be redfined in each source file
- */
-
-#define ckpt_debug(fmt, args...)  \
-	_ckpt_debug(CKPT_DBASE | CKPT_DFLAG, fmt, ## args)
-
 #else
 
+#define ckpt_syslog(fmt, args...)  \
+	_ckpt_syslog(CKPT_DBASE | CKPT_DFLAG, fmt, ## args)
+
 static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
-#define _ckpt_debug(level, fmt, args...)	do { } while (0)
-#define ckpt_debug(fmt, args...)		do { } while (0)
+#define _ckpt_syslog(level, fmt, args...)	do { } while (0)
+#define ckpt_syslog(fmt, args...)		do { } while (0)
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+/* use this to select a specific debug level */
+/*
+ * XXX I think it's better to just drop the error msgs rather than
+ * default to syslog, but let's see what others think
+ */
+#define _ckpt_debug(ctx, level, fmt, args...)				\
+	do {								\
+		if (ctx && ctx->logfile && ckpt_debug_level & (level))	\
+			do_ckpt_debug(ctx, fmt,	current->pid,		\
+				current->nsproxy ?			\
+				task_pid_vnr(current) : -1,		\
+				__func__, __LINE__, ## args);		\
+	} while (0)
+
+/*
+ * CKPT_DBASE is the base flags, doesn't change
+ * CKPT_DFLAG is to be redfined in each source file
+ */
+
+#define ckpt_debug(ctx, fmt, args...)  \
+	_ckpt_debug(ctx, CKPT_DBASE | CKPT_DFLAG, fmt, ## args)
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index fa57cdc..8182a9c 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -47,8 +47,9 @@ struct ckpt_ctx {
 	unsigned long uflags;	/* user flags */
 	unsigned long oflags;	/* restart: uflags from checkpoint */
 
-	struct file *file;	/* input/output file */
-	int total;		/* total read/written */
+	struct file *file;		/* input/output file */
+	struct file *logfile;	/* debug log file */
+	int total;			/* total read/written */
 
 	atomic_t refcount;
 
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 33bce6e..c460d87 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -754,8 +754,9 @@ asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
 asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  struct timespec __user *, const sigset_t __user *,
 			  size_t);
-asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
-asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags,
+				int logfd);
+asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 8e6e9ba..3a073d9 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -65,7 +65,8 @@ static int checkpoint_ipc_any(struct ckpt_ctx *ctx,
 
 	h->ipc_type = ipc_type;
 	h->ipc_count = ipc_ids->in_use;
-	ckpt_debug("ipc-%s count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+	ckpt_debug(ctx, "ipc-%s count %d\n", ipc_ind_to_str[ipc_ind],
+		   h->ipc_count);
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -73,7 +74,7 @@ static int checkpoint_ipc_any(struct ckpt_ctx *ctx,
 		goto out;
 
 	ret = idr_for_each(&ipc_ids->ipcs_idr, func, ctx);
-	ckpt_debug("ipc-%s ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+	ckpt_debug(ctx, "ipc-%s ret %d\n", ipc_ind_to_str[ipc_ind], ret);
  out:
 	up_read(&ipc_ids->rw_mutex);
 	return ret;
@@ -229,7 +230,8 @@ static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("ipc-%s: count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+	ckpt_debug(ctx, "ipc-%s: count %d\n", ipc_ind_to_str[ipc_ind],
+		   h->ipc_count);
 
 	ret = -EINVAL;
 	if (h->ipc_type != ipc_type)
@@ -242,7 +244,7 @@ static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
 			goto out;
 	}
  out:
-	ckpt_debug("ipc-%s: ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+	ckpt_debug(ctx, "ipc-%s: ret %d\n", ipc_ind_to_str[ipc_ind], ret);
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index b933c19..a274e74 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -52,7 +52,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 
  unlock:
 	ipc_unlock(&msq->q_perm);
-	ckpt_debug("msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
+	ckpt_debug(ctx, "msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
 		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
 
 	return ret;
@@ -181,7 +181,7 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 	if (ret < 0)
 		return ret;
 
-	ckpt_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
+	ckpt_debug(ctx, "msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
 		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
 
 	if (h->q_lspid < 0 || h->q_lrpid < 0)
@@ -323,10 +323,10 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 	/* restore the message queue */
 	msgflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
-	ckpt_debug("msg: do_msgget key %d flag %#x id %d\n",
+	ckpt_debug(ctx, "msg: do_msgget key %d flag %#x id %d\n",
 		 h->perms.key, msgflag, h->perms.id);
 	ret = do_msgget(ns, h->perms.key, msgflag, h->perms.id);
-	ckpt_debug("msg: do_msgget ret %d\n", ret);
+	ckpt_debug(ctx, "msg: do_msgget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 
@@ -352,7 +352,7 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = load_ipc_msg_hdr(ctx, h, msq);
 
 	if (ret < 0) {
-		ckpt_debug("msq: need to remove (%d)\n", ret);
+		ckpt_debug(ctx, "msq: need to remove (%d)\n", ret);
 		freeque(ns, perms);
 	} else
 		ipc_unlock(perms);
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 76eb2b9..38dc0c4 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -47,7 +47,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 
  unlock:
 	ipc_unlock(&sem->sem_perm);
-	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+	ckpt_debug(ctx, "sem: nsems %u\n", h->sem_nsems);
 
 	return ret;
 }
@@ -117,7 +117,7 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 	if (ret < 0)
 		return ret;
 
-	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+	ckpt_debug(ctx, "sem: nsems %u\n", h->sem_nsems);
 
 	sem->sem_otime = h->sem_otime;
 	sem->sem_ctime = h->sem_ctime;
@@ -191,10 +191,10 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 	/* restore the message queue now */
 	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
-	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
+	ckpt_debug(ctx, "sem: do_semget key %d flag %#x id %d\n",
 		 h->perms.key, semflag, h->perms.id);
 	ret = do_semget(ns, h->perms.key, h->sem_nsems, semflag, h->perms.id);
-	ckpt_debug("sem: do_semget ret %d\n", ret);
+	ckpt_debug(ctx, "sem: do_semget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 
@@ -209,7 +209,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 	ret = load_ipc_sem_hdr(ctx, h, sem);
 	if (ret < 0) {
-		ckpt_debug("sem: need to remove (%d)\n", ret);
+		ckpt_debug(ctx, "sem: need to remove (%d)\n", ret);
 		freeary(ns, perms);
 	} else
 		ipc_unlock(perms);
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 826e430..fd3da08 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -69,7 +69,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
  unlock:
 	ipc_unlock(&shp->shm_perm);
-	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+	ckpt_debug(ctx, "shm: cprid %d lprid %d segsz %lld mlock %d\n",
 		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
 
 	return ret;
@@ -106,7 +106,7 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
 		goto out;
 
 	h->objref = objref;
-	ckpt_debug("shm: objref %d\n", h->objref);
+	ckpt_debug(ctx, "shm: objref %d\n", h->objref);
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	if (ret < 0)
@@ -169,7 +169,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 	if (ret < 0)
 		return ret;
 
-	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+	ckpt_debug(ctx, "shm: cprid %d lprid %d segsz %lld mlock %d\n",
 		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
 
 	if (h->shm_cprid < 0 || h->shm_lprid < 0)
@@ -237,10 +237,10 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	}
 
 	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
-	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
+	ckpt_debug(ctx, "shm: do_shmget size %lld flag %#x id %d\n",
 		 h->shm_segsz, shmflag, h->perms.id);
 	ret = do_shmget(ns, h->perms.key, h->shm_segsz, shmflag, h->perms.id);
-	ckpt_debug("shm: do_shmget ret %d\n", ret);
+	ckpt_debug(ctx, "shm: do_shmget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
 
@@ -266,7 +266,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
  mutex:
 	fput(file);
 	if (ret < 0) {
-		ckpt_debug("shm: need to remove (%d)\n", ret);
+		ckpt_debug(ctx, "shm: need to remove (%d)\n", ret);
 		do_shm_rmid(ns, perms);
 	} else
 		ipc_unlock(perms);
diff --git a/kernel/cred.c b/kernel/cred.c
index 62d28a4..850c9c6 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -724,7 +724,7 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	if (!h)
 		return -ENOMEM;
 
-	ckpt_debug("cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
+	ckpt_debug(ctx, "cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
 			cred->gid);
 	h->uid = cred->uid;
 	h->suid = cred->suid;
diff --git a/mm/filemap.c b/mm/filemap.c
index eb7653d..ff8571b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1730,7 +1730,7 @@ int filemap_restore(struct ckpt_ctx *ctx,
 		ret = private_vma_restore(ctx, mm, file, h);
 	} else {
 		/* shared mapped file */
-		addr = generic_vma_restore(mm, file, h);
+		addr = generic_vma_restore(ctx, mm, file, h);
 		ret = (IS_ERR((void *) addr) ? PTR_ERR((void *) addr) : 0);
 	}
 	return ret;
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cfff8d..b5954de 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2449,7 +2449,7 @@ int shmem_restore(struct ckpt_ctx *ctx,
 		get_file(file);
 	}
 
-	addr = generic_vma_restore(mm, file, h);
+	addr = generic_vma_restore(ctx, mm, file, h);
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9a72aae..1364d71 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -183,12 +183,12 @@ int sock_deferred_write_buffers(void *data)
 	}
 
 	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue, dst_objref);
-	ckpt_debug("write recv buffers: %i\n", ret);
+	ckpt_debug(ctx, "write recv buffers: %i\n", ret);
 	if (ret < 0)
 		return ret;
 
 	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue, dst_objref);
-	ckpt_debug("write send buffers: %i\n", ret);
+	ckpt_debug(ctx, "write send buffers: %i\n", ret);
 
 	return ret;
 }
@@ -270,20 +270,20 @@ static int sock_cptrst_opt(int op, struct socket *sock,
 #define CKPT_COPY_SOPT(op, sk, name, opt) \
 	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
 
-static int sock_cptrst_bufopts(int op, struct sock *sk,
+static int sock_cptrst_bufopts(struct ckpt_ctx *ctx, int op, struct sock *sk,
 			       struct ckpt_hdr_socket *h)
 {
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
 		if ((op == CKPT_RST) &&
 		    CKPT_COPY_SOPT(op, sk, SO_RCVBUFFORCE, &h->sock.rcvbuf)) {
-			ckpt_debug("Failed to set SO_RCVBUF");
+			ckpt_debug(ctx, "Failed to set SO_RCVBUF");
 			return -EINVAL;
 		}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_SNDBUF, &h->sock.sndbuf))
 		if ((op == CKPT_RST) &&
 		    CKPT_COPY_SOPT(op, sk, SO_SNDBUFFORCE, &h->sock.sndbuf)) {
-			ckpt_debug("Failed to set SO_SNDBUF");
+			ckpt_debug(ctx, "Failed to set SO_SNDBUF");
 			return -EINVAL;
 		}
 
@@ -335,7 +335,8 @@ static int sock_restore_flag(struct socket *sock,
 }
 
 
-static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
+static int sock_restore_flags(struct ckpt_ctx *ctx, struct socket *sock,
+			      struct ckpt_hdr_socket *h)
 {
 	unsigned long sk_flags = h->sock.flags;
 	unsigned long sock_flags = h->socket.flags;
@@ -347,7 +348,7 @@ static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
 		int flag = sk_flag_map[i].flag;
 		ret = sock_restore_flag(sock, &sk_flags, flag, opt);
 		if (ret) {
-			ckpt_debug("Failed to set skopt %i: %i\n", opt, ret);
+			ckpt_debug(ctx, "Failed to set skopt %i: %i\n", opt, ret);
 			return ret;
 		}
 	}
@@ -357,7 +358,7 @@ static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
 		int flag = sock_flag_map[i].flag;
 		ret = sock_restore_flag(sock, &sock_flags, flag, opt);
 		if (ret) {
-			ckpt_debug("Failed to set sockopt %i: %i\n", opt, ret);
+			ckpt_debug(ctx, "Failed to set sockopt %i: %i\n", opt, ret);
 			return ret;
 		}
 	}
@@ -370,7 +371,7 @@ static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
 	    test_bit(SOCK_TIMESTAMPING_SOFTWARE, &sk_flags) ||
 	    test_bit(SOCK_TIMESTAMPING_RAW_HARDWARE, &sk_flags) ||
 	    test_bit(SOCK_TIMESTAMPING_SYS_HARDWARE, &sk_flags)) {
-		ckpt_debug("SOF_TIMESTAMPING_* flags are not supported\n");
+		ckpt_debug(ctx, "SOF_TIMESTAMPING_* flags are not supported\n");
 		return -ENOSYS;
 	}
 
@@ -382,7 +383,7 @@ static int sock_restore_flags(struct socket *sock, struct ckpt_hdr_socket *h)
 	 * our protocol's default set, indicates an error
 	 */
 	if (sk_flags & ~sock->sk->sk_flags) {
-		ckpt_debug("Unhandled sock flags: %lx\n", sk_flags);
+		ckpt_debug(ctx, "Unhandled sock flags: %lx\n", sk_flags);
 		return -EINVAL;
 	}
 
@@ -427,36 +428,36 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 	CKPT_COPY(op, h->sock.state, sk->sk_state);
 	CKPT_COPY(op, h->sock.backlog, sk->sk_max_ack_backlog);
 
-	if (sock_cptrst_bufopts(op, sk, h))
+	if (sock_cptrst_bufopts(ctx, op, sk, h))
 		return -EINVAL;
 
 	if (CKPT_COPY_SOPT(op, sk, SO_REUSEADDR, &h->sock_common.reuse)) {
-		ckpt_debug("Failed to set SO_REUSEADDR");
+		ckpt_debug(ctx, "Failed to set SO_REUSEADDR");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_PRIORITY, &h->sock.priority)) {
-		ckpt_debug("Failed to set SO_PRIORITY");
+		ckpt_debug(ctx, "Failed to set SO_PRIORITY");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVLOWAT, &h->sock.rcvlowat)) {
-		ckpt_debug("Failed to set SO_RCVLOWAT");
+		ckpt_debug(ctx, "Failed to set SO_RCVLOWAT");
 		return -EINVAL;
 	}
 
 	if (CKPT_COPY_SOPT(op, sk, SO_LINGER, &h->sock.linger)) {
-		ckpt_debug("Failed to set SO_LINGER");
+		ckpt_debug(ctx, "Failed to set SO_LINGER");
 		return -EINVAL;
 	}
 
 	if (sock_copy_timeval(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
-		ckpt_debug("Failed to set SO_SNDTIMEO");
+		ckpt_debug(ctx, "Failed to set SO_SNDTIMEO");
 		return -EINVAL;
 	}
 
 	if (sock_copy_timeval(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
-		ckpt_debug("Failed to set SO_RCVTIMEO");
+		ckpt_debug(ctx, "Failed to set SO_RCVTIMEO");
 		return -EINVAL;
 	}
 
@@ -469,7 +470,7 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		ret = sock_restore_flags(sk->sk_socket, h);
+		ret = sock_restore_flags(ctx, sk->sk_socket, h);
 		set_fs(old_fs);
 		if (ret)
 			return ret;
@@ -477,15 +478,15 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 
 	if ((h->socket.state == SS_CONNECTED) &&
 	    (h->sock.state != TCP_ESTABLISHED)) {
-		ckpt_debug("socket/sock in inconsistent state: %i/%i",
+		ckpt_debug(ctx, "socket/sock in inconsistent state: %i/%i",
 			   h->socket.state, h->sock.state);
 		return -EINVAL;
 	} else if ((h->sock.state < TCP_ESTABLISHED) ||
 		   (h->sock.state >= TCP_MAX_STATES)) {
-		ckpt_debug("sock in invalid state: %i", h->sock.state);
+		ckpt_debug(ctx, "sock in invalid state: %i", h->sock.state);
 		return -EINVAL;
 	} else if (h->socket.state > SS_DISCONNECTING) {
-		ckpt_debug("socket in invalid state: %i",
+		ckpt_debug(ctx, "socket in invalid state: %i",
 			   h->socket.state);
 		return -EINVAL;
 	}
@@ -692,7 +693,7 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 		goto err;
 
 	if (!sock->ops->restore) {
-		ckpt_debug("proto_ops lacks checkpoint: %pS\n", sock->ops);
+		ckpt_debug(ctx, "proto_ops lacks checkpoint: %pS\n", sock->ops);
 		ret = -EINVAL;
 		goto err;
 	}
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 9cbbf5e..21bfa82 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -71,7 +71,7 @@ static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 		ret = len;
 		goto out;
 	} else if (len > SKB_MAX_ALLOC) {
-		ckpt_debug("Socket buffer too big (%i > %lu)",
+		ckpt_debug(ctx, "Socket buffer too big (%i > %lu)",
 			   len, SKB_MAX_ALLOC);
 		ret = -ENOSPC;
 		goto out;
@@ -111,12 +111,12 @@ static int inet_read_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 
 	for (i = 0; i < h->skb_count; i++) {
 		ret = inet_read_buffer(ctx, queue);
-		ckpt_debug("read inet buffer %i: %i", i, ret);
+		ckpt_debug(ctx, "read inet buffer %i: %i", i, ret);
 		if (ret < 0)
 			goto out;
 
 		if (ret > h->total_bytes) {
-			ckpt_debug("Buffers exceeded claim");
+			ckpt_debug(ctx, "Buffers exceeded claim");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -139,12 +139,12 @@ static int inet_deferred_restore_buffers(void *data)
 	int ret;
 
 	ret = inet_read_buffers(ctx, &sk->sk_receive_queue);
-	ckpt_debug("(R) inet_read_buffers: %i\n", ret);
+	ckpt_debug(ctx, "(R) inet_read_buffers: %i\n", ret);
 	if (ret < 0)
 		return ret;
 
 	ret = inet_read_buffers(ctx, &sk->sk_write_queue);
-	ckpt_debug("(W) inet_read_buffers: %i\n", ret);
+	ckpt_debug(ctx, "(W) inet_read_buffers: %i\n", ret);
 
 	return ret;
 }
@@ -162,15 +162,11 @@ static int inet_defer_restore_buffers(struct ckpt_ctx *ctx, struct sock *sk)
 
 static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
 {
-	if (in->laddr_len > sizeof(struct sockaddr_in)) {
-		ckpt_debug("laddr_len is too big\n");
+	if (in->laddr_len > sizeof(struct sockaddr_in))
 		return -EINVAL;
-	}
 
-	if (in->raddr_len > sizeof(struct sockaddr_in)) {
-		ckpt_debug("raddr_len is too big\n");
+	if (in->raddr_len > sizeof(struct sockaddr_in))
 		return -EINVAL;
-	}
 
 	return 0;
 }
@@ -187,8 +183,10 @@ int inet_restore(struct ckpt_ctx *ctx,
 		return PTR_ERR(in);
 
 	ret = inet_precheck(sock, in);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug(ctx, "laddr_len or raddr_len is too big\n");
 		goto out;
+	}
 
 	/* Listening sockets and those that are closed but have a local
 	 * address need to call bind()
@@ -200,13 +198,13 @@ int inet_restore(struct ckpt_ctx *ctx,
 		ret = sock->ops->bind(sock,
 				      (struct sockaddr *)&in->laddr,
 				      in->laddr_len);
-		ckpt_debug("inet bind: %i\n", ret);
+		ckpt_debug(ctx, "inet bind: %i\n", ret);
 		if (ret < 0)
 			goto out;
 
 		if (h->sock.state == TCP_LISTEN) {
 			ret = sock->ops->listen(sock, h->sock.backlog);
-			ckpt_debug("inet listen: %i\n", ret);
+			ckpt_debug(ctx, "inet listen: %i\n", ret);
 			if (ret < 0)
 				goto out;
 		}
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 8b7cb22..e3c4784 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -49,13 +49,13 @@ static int unix_deferred_join(void *data)
 
 	src = ckpt_obj_fetch(ctx, dq->src_objref, CKPT_OBJ_SOCK);
 	if (!src) {
-		ckpt_debug("Missing src sock ref %i\n", dq->src_objref);
+		ckpt_debug(ctx, "Missing src sock ref %i\n", dq->src_objref);
 		return -EINVAL;
 	}
 
 	dst = ckpt_obj_fetch(ctx, dq->dst_objref, CKPT_OBJ_SOCK);
 	if (!src) {
-		ckpt_debug("Missing dst sock ref %i\n", dq->dst_objref);
+		ckpt_debug(ctx, "Missing dst sock ref %i\n", dq->dst_objref);
 		return -EINVAL;
 	}
 
@@ -110,7 +110,7 @@ static int unix_write_cwd(struct ckpt_ctx *ctx,
 
 	fqpath[offset] = '\0';
 
-	ckpt_debug("writing socket directory: %s\n", fqpath);
+	ckpt_debug(ctx, "writing socket directory: %s\n", fqpath);
 	ret = ckpt_write_string(ctx, fqpath, offset + 1);
  out:
 	kfree(buf);
@@ -214,7 +214,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 		ret = len;
 		goto out;
 	} else if (len > SKB_MAX_ALLOC) {
-		ckpt_debug("Socket buffer too big (%i > %lu)",
+		ckpt_debug(ctx, "Socket buffer too big (%i > %lu)",
 			   len, SKB_MAX_ALLOC);
 		ret = -ENOSPC;
 		goto out;
@@ -234,13 +234,13 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 		struct sock *pr;
 		pr = ckpt_obj_fetch(ctx, h->pr_objref, CKPT_OBJ_SOCK);
 		if (IS_ERR(pr)) {
-			ckpt_debug("Failed to get our peer: %li\n", PTR_ERR(pr));
+			ckpt_debug(ctx, "Failed to get our peer: %li\n", PTR_ERR(pr));
 			ret = PTR_ERR(pr);
 			goto out;
 		}
 		ret = unix_join(sk, pr);
 		if (ret < 0) {
-			ckpt_debug("Failed to join: %i\n", ret);
+			ckpt_debug(ctx, "Failed to join: %i\n", ret);
 			goto out;
 		}
 	}
@@ -279,7 +279,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
 		sk->sk_sndbuf = sysctl_wmem_max;
 
 	ret = kernel_sendmsg(sk->sk_socket, &msg, &kvec, 1, len);
-	ckpt_debug("kernel_sendmsg(%i,%i): %i\n", h->sk_objref, len, ret);
+	ckpt_debug(ctx, "kernel_sendmsg(%i,%i): %i\n", h->sk_objref, len, ret);
 	if ((ret > 0) && (ret != len))
 		ret = -ENOMEM;
 
@@ -307,12 +307,12 @@ static int unix_read_buffers(struct ckpt_ctx *ctx,
 
 	for (i = 0; i < h->skb_count; i++) {
 		ret = sock_read_buffer_sendmsg(ctx, addr, addrlen);
-		ckpt_debug("read_buffer_sendmsg(%i): %i\n", i, ret);
+		ckpt_debug(ctx, "read_buffer_sendmsg(%i): %i\n", i, ret);
 		if (ret < 0)
 			goto out;
 
 		if (ret > h->total_bytes) {
-			ckpt_debug("Buffers exceeded claim");
+			ckpt_debug(ctx, "Buffers exceeded claim");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -338,7 +338,7 @@ static int unix_deferred_restore_buffers(void *data)
 
 	sk = ckpt_obj_fetch(ctx, dq->sk_objref, CKPT_OBJ_SOCK);
 	if (!sk) {
-		ckpt_debug("Missing sock ref %i\n", dq->sk_objref);
+		ckpt_debug(ctx, "Missing sock ref %i\n", dq->sk_objref);
 		return -EINVAL;
 	}
 
@@ -348,12 +348,12 @@ static int unix_deferred_restore_buffers(void *data)
 	}
 
 	ret = unix_read_buffers(ctx, addr, addrlen);
-	ckpt_debug("read recv buffers: %i\n", ret);
+	ckpt_debug(ctx, "read recv buffers: %i\n", ret);
 	if (ret < 0)
 		return ret;
 
 	ret = unix_read_buffers(ctx, addr, addrlen);
-	ckpt_debug("read send buffers: %i\n", ret);
+	ckpt_debug(ctx, "read send buffers: %i\n", ret);
 	if (ret > 0)
 		ret = -EINVAL; /* No send buffers for UNIX sockets */
 
@@ -422,14 +422,14 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
 		sk->sk_peercred.uid = un->peercred_uid;
 		sk->sk_peercred.gid = un->peercred_gid;
 	} else {
-		ckpt_debug("peercred %i:%i would require setuid",
+		ckpt_debug(ctx, "peercred %i:%i would require setuid",
 			   un->peercred_uid, un->peercred_gid);
 		return -EPERM;
 	}
 
 	if (!dead && (un->peer > 0)) {
 		ret = unix_defer_join(ctx, un->this, un->peer);
-		ckpt_debug("unix_defer_join: %i\n", ret);
+		ckpt_debug(ctx, "unix_defer_join: %i\n", ret);
 	}
 
 	if (!dead && !ret)
@@ -438,7 +438,7 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-static int unix_unlink(const char *name)
+static int unix_unlink(struct ckpt_ctx *ctx, const char *name)
 {
 	struct path spath;
 	struct path ppath;
@@ -453,13 +453,13 @@ static int unix_unlink(const char *name)
 		goto out_s;
 
 	if (!spath.dentry) {
-		ckpt_debug("No dentry found for %s\n", name);
+		ckpt_debug(ctx, "No dentry found for %s\n", name);
 		ret = -ENOENT;
 		goto out_p;
 	}
 
 	if (!ppath.dentry || !ppath.dentry->d_inode) {
-		ckpt_debug("No inode for parent of %s\n", name);
+		ckpt_debug(ctx, "No inode for parent of %s\n", name);
 		ret = -ENOENT;
 		goto out_p;
 	}
@@ -476,7 +476,8 @@ static int unix_unlink(const char *name)
 /* Call bind() for socket, optionally changing (temporarily) to @path first
  * if non-NULL
  */
-static int unix_chdir_and_bind(struct socket *sock,
+static int unix_chdir_and_bind(struct ckpt_ctx *ctx,
+			       struct socket *sock,
 			       const char *path,
 			       struct sockaddr *addr,
 			       unsigned long addrlen)
@@ -487,7 +488,7 @@ static int unix_chdir_and_bind(struct socket *sock,
 	int ret;
 
 	if (path) {
-		ckpt_debug("switching to cwd %s for unix bind", path);
+		ckpt_debug(ctx, "switching to cwd %s for unix bind", path);
 
 		ret = kern_path(path, 0, &dir);
 		if (ret)
@@ -504,8 +505,8 @@ static int unix_chdir_and_bind(struct socket *sock,
 		write_unlock(&current->fs->lock);
 	}
 
-	ret = unix_unlink(un->sun_path);
-	ckpt_debug("unlink(%s): %i\n", un->sun_path, ret);
+	ret = unix_unlink(ctx, un->sun_path);
+	ckpt_debug(ctx, "unlink(%s): %i\n", un->sun_path, ret);
 	if ((ret == 0) || (ret == -ENOENT))
 		ret = sock_bind(sock, addr, addrlen);
 
@@ -535,7 +536,8 @@ static int unix_fakebind(struct socket *sock,
 	return 0;
 }
 
-static int unix_restore_bind(struct ckpt_hdr_socket *h,
+static int unix_restore_bind(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_socket *h,
 			     struct ckpt_hdr_socket_unix *un,
 			     struct socket *sock,
 			     const char *path)
@@ -552,11 +554,13 @@ static int unix_restore_bind(struct ckpt_hdr_socket *h,
 	else if (!(un->flags & CKPT_UNIX_LINKED))
 		return unix_fakebind(sock, &un->laddr, len);
 	else
-		return unix_chdir_and_bind(sock, path, addr, len);
+		return unix_chdir_and_bind(ctx, sock, path, addr, len);
 }
 
 /* Some easy pre-flight checks before we get underway */
-static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
+static int unix_precheck(struct ckpt_ctx *ctx,
+			 struct socket *sock,
+			 struct ckpt_hdr_socket *h)
 {
 	struct net *net = sock_net(sock->sk);
 	unsigned long sk_flags = h->sock.flags;
@@ -564,7 +568,7 @@ static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 	if ((h->socket.state == SS_CONNECTING) ||
 	    (h->socket.state == SS_DISCONNECTING) ||
 	    (h->socket.state == SS_FREE)) {
-		ckpt_debug("AF_UNIX socket can't be SS_(DIS)CONNECTING");
+		ckpt_debug(ctx, "AF_UNIX socket can't be SS_(DIS)CONNECTING");
 		return -EINVAL;
 	}
 
@@ -574,13 +578,14 @@ static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 	 */
 	if ((h->sock.type == SOCK_DGRAM) &&
 	    (h->sock.backlog > net->unx.sysctl_max_dgram_qlen)) {
-		ckpt_debug("DGRAM backlog of %i exceeds system max of %i\n",
+		ckpt_debug(ctx,
+			   "DGRAM backlog of %i exceeds system max of %i\n",
 			   h->sock.backlog, net->unx.sysctl_max_dgram_qlen);
 		return -EINVAL;
 	}
 
 	if (test_bit(SOCK_USE_WRITE_QUEUE, &sk_flags)) {
-		ckpt_debug("AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
+		ckpt_debug(ctx, "AF_UNIX socket has SOCK_USE_WRITE_QUEUE set");
 		return -EINVAL;
 	}
 
@@ -595,7 +600,7 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 	int ret = -EINVAL;
 	char *cwd = NULL;
 
-	ret = unix_precheck(sock, h);
+	ret = unix_precheck(ctx, sock, h);
 	if (ret)
 		return ret;
 
@@ -616,7 +621,7 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 
 	if ((h->sock.state != TCP_ESTABLISHED) &&
 	    !UNIX_ADDR_EMPTY(un->laddr_len)) {
-		ret = unix_restore_bind(h, un, sock, cwd);
+		ret = unix_restore_bind(ctx, h, un, sock, cwd);
 		if (ret)
 			goto out;
 	}
@@ -626,7 +631,8 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 	else if (h->sock.state == TCP_LISTEN)
 		ret = sock->ops->listen(sock, h->sock.backlog);
 	else
-		ckpt_debug("unsupported UNIX socket state %i\n", h->sock.state);
+		ckpt_debug(ctx, "unsupported UNIX socket state %i\n",
+			   h->sock.state);
  out:
 	ckpt_hdr_put(ctx, un);
 	kfree(cwd);
-- 
1.6.1
