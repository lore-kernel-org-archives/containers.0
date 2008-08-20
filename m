From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 7/9] remove temporary buffer structures
Date: Wed, 20 Aug 2008 12:26:05 -0700
Message-ID: <20080820192605.7D7FB8D7@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


These will eventually help the efficiency of the restore and
aid in creating incremental checkpoints.  But, for now, they
do not give us much, and introduce some unnecessary
abstraction.  Kill them for now, but we can always add them
back later.

We use stack allocations for some of these, and kmalloc() for
the larger ones.

---

 oren-cr.git-dave/checkpoint/checkpoint.c |   38 +++++++----
 oren-cr.git-dave/checkpoint/ckpt_mem.c   |   58 ++++++++---------
 oren-cr.git-dave/checkpoint/restart.c    |   47 ++------------
 oren-cr.git-dave/checkpoint/rstr_mem.c   |   11 +--
 oren-cr.git-dave/checkpoint/x86.c        |  104 ++++++++++++++++++++++---------
 5 files changed, 142 insertions(+), 116 deletions(-)

diff -puN checkpoint/checkpoint.c~0009-hbuf-compile-fixes checkpoint/checkpoint.c
--- oren-cr.git/checkpoint/checkpoint.c~0009-hbuf-compile-fixes	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/checkpoint.c	2008-08-20 12:12:51.000000000 -0700
@@ -88,7 +88,7 @@ int cr_write_str(struct cr_ctx *ctx, cha
 static int cr_write_hdr(struct cr_ctx *ctx)
 {
 	struct cr_hdr h;
-	struct cr_hdr_head *hh = ctx->tbuf;
+	struct cr_hdr_head hh;
 	struct timeval ktv;
 
 	h.type = CR_HDR_HEAD;
@@ -97,24 +97,28 @@ static int cr_write_hdr(struct cr_ctx *c
 
 	do_gettimeofday(&ktv);
 
-	hh->magic = CR_HEADER_MAGIC;
-	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
-	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
-	hh->patch = (LINUX_VERSION_CODE) & 0xff;
+	hh.magic = CR_HEADER_MAGIC;
+	hh.major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	hh.minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	hh.patch = (LINUX_VERSION_CODE) & 0xff;
 
-	hh->version = 1;
+	hh.version = 1;
 
-	hh->flags = ctx->flags;
-	hh->time = ktv.tv_sec;
+	hh.flags = ctx->flags;
+	hh.time = ktv.tv_sec;
 
-	return cr_write_obj(ctx, &h, hh);
+	return cr_write_obj(ctx, &h, &hh);
 }
 
 /* write the checkpoint trailer */
 static int cr_write_tail(struct cr_ctx *ctx)
 {
 	struct cr_hdr h;
-	struct cr_hdr_tail *hh = ctx->tbuf;
+	struct cr_hdr_tail *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+	int ret;
+
+	if (!hh)
+		return -ENOMEM;
 
 	h.type = CR_HDR_TAIL;
 	h.len = sizeof(*hh);
@@ -123,14 +127,20 @@ static int cr_write_tail(struct cr_ctx *
 	hh->magic = CR_HEADER_MAGIC;
 	hh->cksum[0] = hh->cksum[1] = 1;	/* TBD ... */
 
-	return cr_write_obj(ctx, &h, hh);
+	ret = cr_write_obj(ctx, &h, hh);
+	kfree(hh);
+	return ret;
 }
 
 /* dump the task_struct of a given task */
 static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
-	struct cr_hdr_task *hh = ctx->tbuf;
+	struct cr_hdr_task *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+	int ret;
+
+	if (!hh)
+		return -ENOMEM;
 
 	h.type = CR_HDR_TASK;
 	h.len = sizeof(*hh);
@@ -163,7 +173,9 @@ static int cr_write_task_struct(struct c
 	hh->task_comm_len = TASK_COMM_LEN;
 	memcpy(hh->comm, t->comm, TASK_COMM_LEN);
 
-	return cr_write_obj(ctx, &h, hh);
+	ret = cr_write_obj(ctx, &h, hh);
+	kfree(hh);
+	return ret;
 }
 
 /* dump the entire state of a given task */
diff -puN checkpoint/ckpt_mem.c~0009-hbuf-compile-fixes checkpoint/ckpt_mem.c
--- oren-cr.git/checkpoint/ckpt_mem.c~0009-hbuf-compile-fixes	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt_mem.c	2008-08-20 12:12:51.000000000 -0700
@@ -261,28 +261,28 @@ static int cr_vma_dump_pages(struct cr_c
 static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct cr_hdr h;
-	struct cr_hdr_vma *hh = ctx->tbuf;
+	struct cr_hdr_vma hh;
 	int nr, ret;
 
 	h.type = CR_HDR_VMA;
-	h.len = sizeof(*hh);
+	h.len = sizeof(hh);
 	h.id = ctx->pid;
 
-	hh->vm_start = vma->vm_start;
-	hh->vm_end = vma->vm_end;
-	hh->vm_page_prot = vma->vm_page_prot.pgprot;
-	hh->vm_flags = vma->vm_flags;
-	hh->vm_pgoff = vma->vm_pgoff;
+	hh.vm_start = vma->vm_start;
+	hh.vm_end = vma->vm_end;
+	hh.vm_page_prot = vma->vm_page_prot.pgprot;
+	hh.vm_flags = vma->vm_flags;
+	hh.vm_pgoff = vma->vm_pgoff;
 
 	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
 		printk(KERN_WARNING "CR: unknown VMA %#lx\n", vma->vm_flags);
 		return -ETXTBSY;
 	}
 
-	hh->how = CR_VMA_ANON;
-	hh->namelen = 0;
+	hh.how = CR_VMA_ANON;
+	hh.namelen = 0;
 	if (vma->vm_file)
-		hh->how = CR_VMA_FILE;
+		hh.how = CR_VMA_FILE;
 
 	/*
 	 * it seems redundant now, but we do it in 3 steps for because:
@@ -299,12 +299,12 @@ static int cr_write_vma(struct cr_ctx *c
 	if (nr < 0)
 		return nr;
 
-	hh->npages = nr;
-	ret = cr_write_obj(ctx, &h, hh);
+	hh.npages = nr;
+	ret = cr_write_obj(ctx, &h, &hh);
 
 	/* if there is a backing file, assume private-mapped */
 	/* (NEED: check if the file is unlinked) */
-	if (hh->how == CR_VMA_FILE)
+	if (hh.how == CR_VMA_FILE)
 		ret = cr_write_fname(ctx, &vma->vm_file->f_path, ctx->vfsroot);
 
 	if (ret < 0)
@@ -323,36 +323,36 @@ static int cr_write_vma(struct cr_ctx *c
 int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
-	struct cr_hdr_mm *hh = ctx->tbuf;
+	struct cr_hdr_mm hh;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int ret;
 
 	h.type = CR_HDR_MM;
-	h.len = sizeof(*hh);
+	h.len = sizeof(hh);
 	h.id = ctx->pid;
 
 	mm = get_task_mm(t);
 
-	hh->tag = 1;	/* non-zero will mean first time encounter */
+	hh.tag = 1;	/* non-zero will mean first time encounter */
 
-	hh->start_code = mm->start_code;
-	hh->end_code = mm->end_code;
-	hh->start_data = mm->start_data;
-	hh->end_data = mm->end_data;
-	hh->start_brk = mm->start_brk;
-	hh->brk = mm->brk;
-	hh->start_stack = mm->start_stack;
-	hh->arg_start = mm->arg_start;
-	hh->arg_end = mm->arg_end;
-	hh->env_start = mm->env_start;
-	hh->env_end = mm->env_end;
+	hh.start_code = mm->start_code;
+	hh.end_code = mm->end_code;
+	hh.start_data = mm->start_data;
+	hh.end_data = mm->end_data;
+	hh.start_brk = mm->start_brk;
+	hh.brk = mm->brk;
+	hh.start_stack = mm->start_stack;
+	hh.arg_start = mm->arg_start;
+	hh.arg_end = mm->arg_end;
+	hh.env_start = mm->env_start;
+	hh.env_end = mm->env_end;
 
-	hh->map_count = mm->map_count;
+	hh.map_count = mm->map_count;
 
 	/* FIX: need also mm->flags */
 
-	ret = cr_write_obj(ctx, &h, hh);
+	ret = cr_write_obj(ctx, &h, &hh);
 	if (ret < 0)
 		goto out;
 
diff -puN checkpoint/restart.c~0009-hbuf-compile-fixes checkpoint/restart.c
--- oren-cr.git/checkpoint/restart.c~0009-hbuf-compile-fixes	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/restart.c	2008-08-20 12:12:51.000000000 -0700
@@ -8,13 +8,6 @@
  *  distribution for more details.
  */
 
-/*
- * During restart the code reads in data from the chekcpoint image into a
- * temporary buffer (ctx->hbuf). Because operations can be nested, one
- * should call cr_hbuf_get() to reserve space in the buffer, and then
- * cr_hbuf_put() when it no longer needs that space
- */
-
 #include <linux/version.h>
 #include <linux/magic.h>
 #include <linux/sched.h>
@@ -24,33 +17,7 @@
 #include "ckpt_hdr.h"
 #include "ckpt_arch.h"
 
-/**
- * cr_hbuf_get - reserve space on the hbuf
- * @ctx: checkpoint context
- * @n: number of bytes to reserve
- */
-void *cr_hbuf_get(struct cr_ctx *ctx, int n)
-{
-	void *ptr;
-
-	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
-	ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
-	ctx->hpos += n;
-	return ptr;
-}
-
-/**
- * cr_hbuf_put - unreserve space on the hbuf
- * @ctx: checkpoint context
- * @n: number of bytes to reserve
- */
-void cr_hbuf_put(struct cr_ctx *ctx, int n)
-{
-	BUG_ON(ctx->hpos < n);
-	ctx->hpos -= n;
-}
-
-/**
+/*
  * cr_read_obj - read a whole record (cr_hdr followed by payload)
  * @ctx: checkpoint context
  * @h: record descriptor
@@ -104,7 +71,7 @@ int cr_read_str(struct cr_ctx *ctx, void
 /* read the checkpoint header */
 static int cr_read_hdr(struct cr_ctx *ctx)
 {
-	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_head *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	int ret;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
@@ -122,14 +89,14 @@ static int cr_read_hdr(struct cr_ctx *ct
 
 	ctx->oflags = hh->flags;
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+	kfree(hh);
 	return 0;
 }
 
 /* read the checkpoint trailer */
 static int cr_read_tail(struct cr_ctx *ctx)
 {
-	struct cr_hdr_tail *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_tail *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	int ret;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TAIL);
@@ -140,14 +107,14 @@ static int cr_read_tail(struct cr_ctx *c
 	    hh->cksum[0] != 1 || hh->cksum[1] != 1)
 		return -EINVAL;
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+	kfree(hh);
 	return 0;
 }
 
 /* read the task_struct into the current task */
 static int cr_read_task_struct(struct cr_ctx *ctx)
 {
-	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_task *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	struct task_struct *t = current;
 	int ret;
 
@@ -162,7 +129,7 @@ static int cr_read_task_struct(struct cr
 	memset(t->comm, 0, TASK_COMM_LEN);
 	memcpy(t->comm, hh->comm, hh->task_comm_len);
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+	kfree(hh);
 	return 0;
 }
 
diff -puN checkpoint/rstr_mem.c~0009-hbuf-compile-fixes checkpoint/rstr_mem.c
--- oren-cr.git/checkpoint/rstr_mem.c~0009-hbuf-compile-fixes	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/rstr_mem.c	2008-08-20 12:12:51.000000000 -0700
@@ -187,7 +187,7 @@ static unsigned long cr_calc_map_flags_b
 
 static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 {
-	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_vma *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
 	void *addr;
 	unsigned long flags;
@@ -214,7 +214,7 @@ static int cr_read_vma(struct cr_ctx *ct
 	vm_pgoff = hh->vm_pgoff;
 
 	if (hh->namelen) {
-		fname = ctx->tbuf;
+		fname = kmalloc(PAGE_SIZE, GFP_KERNEL);
 		ret = cr_read_str(ctx, fname, PAGE_SIZE);
 		if (ret < 0)
 			return ret;
@@ -280,8 +280,9 @@ static int cr_read_vma(struct cr_ctx *ct
 	if (vm_prot & PROT_EXEC)
 		flush_icache_range(hh->vm_start, hh->vm_end);
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+	kfree(hh);
 	pr_debug("vma retval %d\n", ret);
+	kfree(fname);
 	return 0;
 }
 
@@ -303,7 +304,7 @@ static int cr_destroy_mm(struct mm_struc
 
 int cr_read_mm(struct cr_ctx *ctx)
 {
-	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_mm *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	struct mm_struct *mm;
 	int nr, ret;
 
@@ -348,7 +349,7 @@ int cr_read_mm(struct cr_ctx *ctx)
 			return ret;
 	}
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+	kfree(hh);
 
 	return cr_read_mm_context(ctx, mm);
 }
diff -puN checkpoint/x86.c~0009-hbuf-compile-fixes checkpoint/x86.c
--- oren-cr.git/checkpoint/x86.c~0009-hbuf-compile-fixes	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/x86.c	2008-08-20 12:12:51.000000000 -0700
@@ -10,11 +10,14 @@
 int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
-	struct cr_hdr_thread *hh = ctx->tbuf;
 	struct thread_struct *thread;
 	struct desc_struct *desc;
 	int ntls = 0;
 	int n, ret;
+	struct cr_hdr_thread *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+
+	if (!hh)
+		return -ENOMEM;
 
 	h.type = CR_HDR_THREAD;
 	h.len = sizeof(*hh);
@@ -35,7 +38,7 @@ int cr_write_thread(struct cr_ctx *ctx, 
 
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	/* for simplicity dump the entire array, cherry-pick upon restart */
 	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
@@ -44,17 +47,23 @@ int cr_write_thread(struct cr_ctx *ctx, 
 
 	/* IGNORE RESTART BLOCKS FOR NOW ... */
 
+out:
+	kfree(hh);
 	return ret;
 }
 
 /* dump the cpu state and registers of a given task */
 int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
 {
+	int ret = 0;
 	struct cr_hdr h;
-	struct cr_hdr_cpu *hh = ctx->tbuf;
 	struct thread_struct *thread;
 	struct thread_info *thread_info;
 	struct pt_regs *regs;
+	struct cr_hdr_cpu *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+
+	if (!hh)
+		return -ENOMEM;
 
 	h.type = CR_HDR_CPU;
 	h.len = sizeof(*hh);
@@ -146,42 +155,57 @@ int cr_write_cpu(struct cr_ctx *ctx, str
 
 	pr_debug("math %d debug %d\n", hh->used_math, hh->uses_debug);
 
-	return cr_write_obj(ctx, &h, hh);
+	ret = cr_write_obj(ctx, &h, hh);
+	kfree(hh);
+	return ret;
 }
 
 /* read the thread_struct into the current task */
 int cr_read_thread(struct cr_ctx *ctx)
 {
-	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
 	struct task_struct *t = current;
 	struct thread_struct *thread = &t->thread;
-	int ret;
+	int ret = 0;
+	struct cr_hdr_thread *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+
+	if (!hh)
+		return -ENOMEM;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_THREAD);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	pr_debug("ntls %d\n", hh->ntls);
 
 	if (hh->gdt_entry_tls_entries != GDT_ENTRY_TLS_ENTRIES ||
 	    hh->sizeof_tls_array != sizeof(thread->tls_array) ||
-	    hh->ntls < 0 || hh->ntls > GDT_ENTRY_TLS_ENTRIES)
-		return -EINVAL;
+	    hh->ntls < 0 || hh->ntls > GDT_ENTRY_TLS_ENTRIES) {
+		ret = -EINVAL;
+		goto out;
+	}
 
 	if (hh->ntls > 0) {
-
 		/* restore TLS by hand: why convert to struct user_desc if
 		 * sys_set_thread_entry() will convert it back ? */
 
-		struct desc_struct *buf = ctx->tbuf;
+		/*
+		 * This little hunk is ugly and probably needs its own
+		 * function...
+		 */
+
+		struct desc_struct *buf;
 		int size = sizeof(*buf) * GDT_ENTRY_TLS_ENTRIES;
 		int cpu;
 
-		BUG_ON(size > CR_TBUF_TOTAL);
+		buf = kmalloc(size, GFP_KERNEL);
+		if (!buf) {
+			ret = -ENOMEM;
+			goto out;
+		}
 
 		ret = cr_kread(ctx, buf, size);
 		if (ret < 0)
-			return ret;
+			goto out_ntls;
 
 		/* FIX: add sanity checks (eg. that values makes sense, that
 		 * that we don't overwrite old values, etc */
@@ -190,24 +214,31 @@ int cr_read_thread(struct cr_ctx *ctx)
 		memcpy(thread->tls_array, buf, size);
 		load_TLS(thread, cpu);
 		put_cpu();
+	out_ntls:
+		kfree(buf);
 	}
 
-	return 0;
+out:
+	kfree(hh);
+	return ret;
 }
 
 /* read the cpu state nad registers for the current task */
 int cr_read_cpu(struct cr_ctx *ctx)
 {
-	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
 	struct task_struct *t = current;
 	struct thread_struct *thread;
 	struct thread_info *thread_info;
 	struct pt_regs *regs;
-	int ret;
+	int ret = 0;
+	struct cr_hdr_cpu *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+
+	if (!hh)
+		return -ENOMEM;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	/* FIX: sanity check for sensitive registers (eg. eflags) */
 
@@ -249,7 +280,8 @@ int cr_read_cpu(struct cr_ctx *ctx)
 	else {
 		if (hh->has_fxsr != cpu_has_fxsr) {
 			force_sig(SIGFPE, t);
-			return -EINVAL;
+			ret = -EINVAL;
+			goto out;
 		}
 		memcpy(&thread->xstate, &hh->xstate, sizeof(thread->xstate));
 		set_used_math();
@@ -267,15 +299,20 @@ int cr_read_cpu(struct cr_ctx *ctx)
 
 	preempt_enable();
 
-	return 0;
+out:
+	kfree(hh);
+	return ret;
 }
 
 int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 {
 	struct cr_hdr h;
-	struct cr_hdr_mm_context *hh = ctx->tbuf;
+	struct cr_hdr_mm_context *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
 	int ret;
 
+	if (!hh)
+		return -ENOMEM;
+
 	h.type = CR_HDR_MM_CONTEXT;
 	h.len = sizeof(*hh);
 	h.id = ctx->pid;
@@ -289,28 +326,36 @@ int cr_write_mm_context(struct cr_ctx *c
 
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
 
 	mutex_unlock(&mm->context.lock);
 
+out:
+	kfree(hh);
 	return ret;
 }
 
 int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 {
-	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
-	int n, ret;
+	int n;
+	struct cr_hdr_mm_context *hh = kmalloc(sizeof(*hh), GFP_KERNEL);
+	int ret = 0;
+
+	if (!hh)
+		return -ENOMEM;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	pr_debug("nldt %d\n", hh->nldt);
 
-	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
-		return -EINVAL;
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE) {
+		ret = -EINVAL;
+		goto out;
+	}
 
 	/* to utilize the syscall modify_ldt() we first convert the data
 	 * in the checkpoint image from 'struct desc_struct' to 'struct
@@ -323,7 +368,7 @@ int cr_read_mm_context(struct cr_ctx *ct
 
 		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
 		if (ret < 0)
-			return ret;
+			goto out;
 
 		info.entry_number = n;
 		info.base_addr = desc.base0 | (desc.base1 << 16);
@@ -343,11 +388,12 @@ int cr_read_mm_context(struct cr_ctx *ct
 		set_fs(old_fs);
 
 		if (ret < 0)
-			return ret;
+			goto out;
 	}
 
 	load_LDT(&mm->context);
 
-	cr_hbuf_put(ctx, sizeof(*hh));
+out:
+	kfree(hh);
 	return 0;
 }
_
