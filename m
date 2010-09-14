From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/8] checkpoint/restart of SysV SHM_HUGETLB regions
Date: Tue, 14 Sep 2010 15:02:10 -0500
Message-ID: <1284494530-25946-9-git-send-email-ntl@pobox.com>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284494530-25946-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Large page-backed shm regions require special handling, especially
during restart.  The association of a large page with a shm region's
inode can occur only in the context of a process causing a fault with
the region mapped into its mm.  In order to restore that association,
temporarily shmat-attach the restored SHM_HUGETLB region to the
restarting process's mm, using the just-restored ipc namespace
instead of the current one (the nsproxy switch hasn't occured yet).

Since the temporary shmat of the region during restart causes some of
the shm attributes to be updated, re-restore them from the ipc_shm
checkpoint header after unmapping.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 ipc/checkpoint_shm.c |  154 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 142 insertions(+), 12 deletions(-)

diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 69ba35a..7f9d701 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -32,6 +32,69 @@
  * ipc checkpoint
  */
 
+#define CKPT_HDR_HPAGE_LAST ~(0UL)
+static bool ckpt_hdr_hpage_last(const struct ckpt_hdr_hpage *hdr)
+{
+	return hdr->index == CKPT_HDR_HPAGE_LAST;
+}
+
+static void ckpt_hdr_hpage_init(struct ckpt_hdr_hpage *hdr, unsigned long shift)
+{
+	hdr->h.type = CKPT_HDR_HPAGE;
+	hdr->h.len = sizeof(struct ckpt_hdr_hpage);
+	hdr->shift = shift;
+	hdr->index = 0; /* to be filled in by user */
+}
+
+static int shm_hugetlb_checkpoint_contents(struct ckpt_ctx *ctx, struct file *filp)
+{
+	struct hstate *h = hstate_file(filp);
+	struct address_space *mapping = filp->f_mapping;
+	struct inode *inode = mapping->host;
+	struct ckpt_hdr_hpage hdr;
+	unsigned long end_index;
+	unsigned long index;
+	ssize_t retval = 0;
+	loff_t isize;
+
+	isize = i_size_read(inode);
+	if (isize == 0)
+		goto out;
+
+	end_index = (isize - 1) >> huge_page_shift(h);
+
+	ckpt_hdr_hpage_init(&hdr, huge_page_shift(h));
+
+	for (index = 0; index < end_index + 1; index++) {
+		struct page *page;
+
+		page = find_get_page(mapping, index);
+
+		/* skip holes */
+		if (!page)
+			continue;
+
+		hdr.index = index;
+
+		retval = ckpt_write_obj(ctx, &hdr.h);
+		if (retval < 0)
+			goto release;
+
+		retval = hugetlb_checkpoint_page(ctx, page);
+release:
+		page_cache_release(page);
+		if (retval < 0)
+			break;
+	}
+
+	if (retval < 0)
+		goto out;
+	hdr.index = CKPT_HDR_HPAGE_LAST;
+	retval = ckpt_write_obj(ctx, &hdr.h);
+out:
+	return retval;
+}
+
 /* called with the msgids->rw_mutex is read-held */
 static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_shm *h,
@@ -59,10 +122,8 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
 	h->flags = 0;
 
-	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
 	if (is_file_hugepages(shp->shm_file)) {
-		pr_warning("c/r: unsupported SHM_HUGETLB\n");
-		ret = -ENOSYS;
+		h->flags |= SHM_HUGETLB;
 	} else {
 		struct shmem_inode_info *info;
 
@@ -117,7 +178,10 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
 	if (ret < 0)
 		goto out;
 
-	ret = checkpoint_memory_contents(ctx, NULL, inode);
+	if (is_file_hugepages(shp->shm_file))
+		ret = shm_hugetlb_checkpoint_contents(ctx, shp->shm_file);
+	else
+		ret = checkpoint_memory_contents(ctx, NULL, inode);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -149,6 +213,75 @@ struct dq_ipcshm_del {
 	int id;
 };
 
+static void __load_ipc_shm_hdr(const struct ckpt_hdr_ipc_shm *h, struct shmid_kernel *shp)
+{
+	shp->shm_atim = h->shm_atim;
+	shp->shm_dtim = h->shm_dtim;
+	shp->shm_ctim = h->shm_ctim;
+	shp->shm_cprid = h->shm_cprid;
+	shp->shm_lprid = h->shm_lprid;
+}
+
+static int shm_hugetlb_restore_contents(struct ckpt_ctx *ctx, struct ipc_namespace *ipcns, struct shmid_kernel *shp, const struct ckpt_hdr_ipc_shm *hdr)
+{
+	unsigned long start;
+	int ret;
+
+	ret = do_shmat_ns_pgoff(ipcns, shp->shm_perm.id, (char __user *)0,
+				0, &start, 0, 0);
+	if (ret != 0)
+		return ret;
+
+	ckpt_debug("temporarily using %#lx for huge shm restore\n", start);
+
+	while (1) {
+		struct ckpt_hdr_hpage *hdr;
+		unsigned long hpagesize;
+		unsigned long index;
+		unsigned long addr;
+		struct page *page;
+		bool last;
+
+		hdr = ckpt_read_obj_type(ctx, sizeof(*hdr), CKPT_HDR_HPAGE);
+		if (IS_ERR(hdr)) {
+			ret = PTR_ERR(hdr);
+			break;
+		}
+
+		last = ckpt_hdr_hpage_last(hdr);
+		index = (unsigned long)hdr->index;
+		hpagesize = 1UL << hdr->shift;
+
+		ckpt_hdr_put(ctx, hdr);
+
+		if (last)
+			break;
+
+		addr = start + (hpagesize * index);
+
+		down_read(&current->mm->mmap_sem);
+		ret = get_user_pages(current, current->mm, addr, 1, 1, 1,
+				     &page, NULL);
+		up_read(&current->mm->mmap_sem);
+
+		if (ret < 0)
+			break;
+
+		ret = hugetlb_restore_page(ctx, page);
+
+		page_cache_release(page);
+
+		if (ret < 0)
+			break;
+	}
+
+	sys_shmdt((void __user *)start);
+
+	__load_ipc_shm_hdr(hdr, shp);
+
+	return ret;
+}
+
 static int _ipc_shm_delete(struct ipc_namespace *ns, int id)
 {
 	mm_segment_t old_fs;
@@ -190,11 +323,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 	if (h->shm_cprid < 0 || h->shm_lprid < 0)
 		return -EINVAL;
 
-	shp->shm_atim = h->shm_atim;
-	shp->shm_dtim = h->shm_dtim;
-	shp->shm_ctim = h->shm_ctim;
-	shp->shm_cprid = h->shm_cprid;
-	shp->shm_lprid = h->shm_lprid;
+	__load_ipc_shm_hdr(h, shp);
 
 	return 0;
 }
@@ -224,8 +353,6 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = -ENOSYS;
 	if (h->mlock_uid != (unsigned int) -1)	/* FIXME: support SHM_LOCK */
 		goto out;
-	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
-		goto out;
 
 	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
@@ -294,7 +421,10 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
 	if (ret < 0)
 		goto fput;
-	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+	if (is_file_hugepages(file))
+		ret = shm_hugetlb_restore_contents(ctx, ns, shp, h);
+	else
+		ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
 fput:
 	fput(file);
 
-- 
1.7.2.2
