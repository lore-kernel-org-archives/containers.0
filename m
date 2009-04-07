From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 24/36] Restore anonymous- and file-mapped- shared
	memory
Date: Tue,  7 Apr 2009 08:27:32 -0400
Message-ID: <1239107264-21775-25-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

The bulk of the work is in cr_read_vma(), which has been refactored:
the part that create the suitable 'struct file *' for the mapping is
now larger and moved to a separate function. What's left is to read
the VMA description, get the file pointer, create the mapping, and
proceed to read the contents in.

Both anonymous shared VMAs that have been read earlier (as indicated
by a look up to objhash) and file-mapped shared VMAs are skipped.
Anonymous shared VMAs seen for the first time have their contents
read in directly to the backing inode, as indexed by the page numbers
(as opposed to virtual addresses).

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/rstr_mem.c      |  226 +++++++++++++++++++++++++++++++++-----------
 include/linux/checkpoint.h |    1 +
 2 files changed, 172 insertions(+), 55 deletions(-)

diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 1e33e51..da3eb0e 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -75,13 +75,37 @@ static int cr_page_read(struct cr_ctx *ctx, struct page *page, char *buf)
 	return 0;
 }
 
+static struct page *cr_bring_private_page(unsigned long addr)
+{
+	struct page *page;
+	int ret;
+
+	ret = get_user_pages(current, current->mm, addr, 1, 1, 1, &page, NULL);
+	if (ret < 0)
+		page = ERR_PTR(ret);
+	return page;
+}
+
+static struct page *cr_bring_shared_page(unsigned long idx, struct inode *ino)
+{
+	struct page *page = NULL;
+	int ret;
+
+	ret = shmem_getpage(ino, idx, &page, SGP_WRITE, NULL);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	if (page)
+		unlock_page(page);
+	return page;
+}
+
 /**
  * cr_read_pages_contents - read in data of pages in page-array chain
  * @ctx - restart context
+ * @inode - inode of shmem object
  */
-static int cr_read_pages_contents(struct cr_ctx *ctx)
+static int cr_read_pages_contents(struct cr_ctx *ctx, struct inode *inode)
 {
-	struct mm_struct *mm = current->mm;
 	struct cr_pgarr *pgarr;
 	unsigned long *vaddrs;
 	char *buf;
@@ -91,16 +115,21 @@ static int cr_read_pages_contents(struct cr_ctx *ctx)
 	if (!buf)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	down_read(&current->mm->mmap_sem);
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
 		for (i = 0; i < pgarr->nr_used; i++) {
 			struct page *page;
 
-			ret = get_user_pages(current, mm, vaddrs[i],
-					     1, 1, 1, &page, NULL);
-			if (ret < 0)
+			if (inode)
+				page = cr_bring_shared_page(vaddrs[i], inode);
+			else
+				page = cr_bring_private_page(vaddrs[i]);
+
+			if (IS_ERR(page)) {
+				ret = PTR_ERR(page);
 				goto out;
+			}
 
 			ret = cr_page_read(ctx, page, buf);
 			page_cache_release(page);
@@ -111,14 +140,15 @@ static int cr_read_pages_contents(struct cr_ctx *ctx)
 	}
 
  out:
-	up_read(&mm->mmap_sem);
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 	return 0;
 }
 
 /**
- * cr_read_private_vma_contents - restore contents of a VMA with private memory
+ * cr_read_vma_contents - restore contents of a VMA with private memory
  * @ctx - restart context
+ * @file - mapped file (shared memory)
  *
  * Reads a header that specifies how many pages will follow, then reads
  * a list of virtual addresses into ctx->pgarr_list page-array chain,
@@ -126,7 +156,7 @@ static int cr_read_pages_contents(struct cr_ctx *ctx)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-static int cr_read_private_vma_contents(struct cr_ctx *ctx)
+static int cr_read_vma_contents(struct cr_ctx *ctx, struct inode *inode)
 {
 	struct cr_hdr_pgarr *hh;
 	unsigned long nr_pages;
@@ -153,7 +183,7 @@ static int cr_read_private_vma_contents(struct cr_ctx *ctx)
 		ret = cr_read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = cr_read_pages_contents(ctx);
+		ret = cr_read_pages_contents(ctx, inode);
 		if (ret < 0)
 			break;
 		cr_pgarr_reset_all(ctx);
@@ -162,6 +192,39 @@ static int cr_read_private_vma_contents(struct cr_ctx *ctx)
 	return ret;
 }
 
+int cr_read_shmem_contents(struct cr_ctx *ctx, struct inode *inode)
+{
+	return cr_read_vma_contents(ctx, inode);
+}
+
+/* restore contents of a VMA with private memory */
+static int cr_read_private_vma_contents(struct cr_ctx *ctx)
+{
+	/*
+	 * CR_VMA_ANON: read contents into memory
+	 * CR_VMA_FILE: read contents into memory
+	 */
+
+	return cr_read_vma_contents(ctx, NULL);
+}
+
+/* restore contents of a VMA with shared memory */
+static int cr_read_shared_vma_contents(struct cr_ctx *ctx,
+				      struct file *file,
+				      enum cr_vma_type vma_type)
+{
+	/*
+	 * CR_VMA_SHM_ANON: read contents into shmem object
+	 * CR_VMA_SHM_ANON_SKIP: skip (has been read before)
+	 * CR_VMA_SHM_FILE: skip (contents already in file system)
+	 */
+
+	if (vma_type == CR_VMA_SHM_ANON)
+		return cr_read_shmem_contents(ctx, file->f_dentry->d_inode);
+	else
+		return 0;
+}
+
 /**
  * cr_calc_map_prot_bits - convert vm_flags to mmap protection
  * orig_vm_flags: source vm_flags
@@ -239,6 +302,72 @@ static struct file *cr_vma_read_file(struct cr_ctx *ctx, int objref)
 	return file;
 }
 
+static struct file *cr_vma_prep_file(struct cr_ctx *ctx, struct cr_hdr_vma *hh)
+{
+	struct file *file = ERR_PTR(-EINVAL);
+	unsigned long vm_flags = hh->vm_flags;
+	int add = 0;
+	int ret;
+
+	switch (hh->vma_type) {
+	case CR_VMA_ANON:		/* private anonymous mapping */
+		if (hh->shm_objref || hh->vma_objref)
+			break;
+		file = NULL;
+		break;
+	case CR_VMA_FILE:		/* private mapping from a file */
+		if (hh->shm_objref || !hh->vma_objref)
+			break;
+		file = cr_vma_read_file(ctx, hh->vma_objref);
+		break;
+	case CR_VMA_SHM_ANON:		/* shared anonymous mapping */
+		if (!hh->shm_objref || hh->vma_objref)
+			break;
+		/*
+		 * We could leave file==NULL and let mmap (below) do the
+		 * work. However, if 'shm_size != vm_end - vm_start', or if
+		 * 'vm_pgoff != 0', then this vma reflects only a portion
+		 * of the shm object. In this case we need to "manually"
+		 * create the full shm object. So we do it anyway ...
+		 */
+		file = shmem_file_setup("/dev/zero", hh->shm_size, vm_flags);
+		add = 1;
+		break;
+	case CR_VMA_SHM_ANON_SKIP:	/* shared anonymous mapping skipped */
+		if (!hh->shm_objref || hh->vma_objref)
+			break;
+		file = cr_obj_get_by_ref(ctx, hh->shm_objref, CR_OBJ_FILE);
+		if (!file)
+			file = ERR_PTR(-EINVAL);
+		if (!IS_ERR(file))
+			get_file(file);
+		break;
+	case CR_VMA_SHM_FILE:		/* shared mapping of a file */
+		if (!hh->shm_objref || !hh->vma_objref)
+			break;
+		file = cr_vma_read_file(ctx, hh->vma_objref);
+		break;
+	default:
+		file = ERR_PTR(-EINVAL);
+		break;
+	}
+
+	if (IS_ERR(file))
+		return file;
+
+	if (add) {
+		ret = cr_obj_add_ref(ctx, file,
+				     hh->shm_objref, CR_OBJ_FILE, 0);
+		if (ret < 0) {
+			if (file)
+				fput(file);
+			file = ERR_PTR(ret);
+		}
+	}
+
+	return file;
+}
+
 /**
  * cr_read_vma - read vma data, recreate it and read contents
  * @ctx: checkpoint context
@@ -253,22 +382,29 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 	unsigned long addr;
 	enum cr_vma_type vma_type;
 	struct file *file = NULL;
-	int ret;
+	int shm, ret;
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
 		return -ENOMEM;
+
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
 	if (ret < 0)
 		goto out;
 
-	cr_debug("vma %#lx-%#lx type %d\n", (unsigned long) hh->vm_start,
-		 (unsigned long) hh->vm_end, (int) hh->vma_type);
+	cr_debug("vma %#lx-%#lx flags %#lx objref %d type %d\n",
+		 (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
+		 (unsigned long) hh->vm_flags, (int) hh->shm_objref,
+		 (int) hh->vma_type);
 
 	ret = -EINVAL;
 	if (hh->vm_end < hh->vm_start)
 		goto out;
-	if (hh->vma_objref <= 0)
+	if (hh->vma_objref < 0 || hh->shm_objref < 0)
+		goto out;
+
+	shm = !!hh->shm_objref;
+	if (!(hh->vm_flags & VM_SHARED) ^ !shm)
 		goto out;
 
 	vm_start = hh->vm_start;
@@ -278,40 +414,31 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
 	vma_type = hh->vma_type;
 
-	switch (vma_type) {
-
-	case CR_VMA_VDSO:		/* special VDSO vma */
+	/* handle special VDSO vma */
+	if (vma_type == CR_VMA_VDSO) {
 		if (vm_start != (unsigned long) mm->context.vdso)
 			goto out;
 		/* FIXME: uggh ... need to dig in */
-		return 0;
+		ret = 0;
+		goto out;
+	}
 
-	case CR_VMA_ANON:		/* anonymous private mapping */
-		if (vm_flags & VM_SHARED)
-			goto out;
-		/*
-		 * vm_pgoff for anonymous mapping is the "global" page
-		 * offset (namely from addr 0x0), so we force a zero
-		 */
+	/*
+	 * vm_pgoff for anonymous mapping is the "global" page
+	 * offset (namely from addr 0x0), so we force a zero
+	 */
+	if (vma_type == CR_VMA_ANON)
 		vm_pgoff = 0;
-		break;
-
-	case CR_VMA_FILE:		/* private mapping from a file */
-		if (vm_flags & VM_SHARED)
-			goto out;
-		file = cr_vma_read_file(ctx, hh->vma_objref);
-		if (IS_ERR(file)) {
-			ret = PTR_ERR(file);
-			file = NULL;
-			goto out;
-		}
-		break;
 
-	default:
+	/* prepare the file for this vma */
+	file = cr_vma_prep_file(ctx, hh);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		file = NULL;
 		goto out;
-
 	}
 
+	/* create a new vma */
 	down_write(&mm->mmap_sem);
 	addr = do_mmap_pgoff(file, vm_start, vm_size,
 			     vm_prot, vm_flags, vm_pgoff);
@@ -324,23 +451,11 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		goto out;
 	}
 
-	/*
-	 * CR_VMA_ANON: read in memory as is
-	 * CR_VMA_FILE: read in memory as is
-	 * (more to follow ...)
-	 */
-
-	switch (vma_type) {
-	case CR_VMA_ANON:
-	case CR_VMA_FILE:
-		/* standard case: read the data into the memory */
+	/* read in the contents of this vma */
+	if (shm)
+		ret = cr_read_shared_vma_contents(ctx, file, vma_type);
+	else
 		ret = cr_read_private_vma_contents(ctx);
-		break;
-	default:
-		/* pacify gcc (the default is caught above) ... */
-		ret = -EINVAL;
-		break;
-	}
 
  out:
 	if (file)
@@ -385,6 +500,7 @@ int cr_read_mm(struct cr_ctx *ctx)
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
 		return -ENOMEM;
+
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
 	if (ret < 0)
 		goto out;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7a73608..c83e448 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -111,6 +111,7 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 				       int flags, int mode);
 
 extern int cr_write_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
+extern int cr_read_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
 
 extern int cr_write_task(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t);
-- 
1.5.4.3
