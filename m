From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: ext4: use filemap_checkpoint for ext4 file backed
	mmaps
Date: Fri, 11 Sep 2009 16:20:08 -0500
Message-ID: <20090911212008.GA15329@us.ibm.com>
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

I don't know if this is "the right thing" to do, or if
there will be special ext4 cases which this doesn't handle,
but all of my cr_tests pass with this patch applied on F11
with an ext4 rootfs (and fail without on trying to checkpoint
a library on ext4fs bc it has its own vm_ops but no
vm_ops->checkpoint()).

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext4/file.c     |    3 +++
 include/linux/mm.h |    1 +
 mm/filemap.c       |    2 +-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index a99bcc3..cdac137 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -133,6 +133,9 @@ force_commit:
 static struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f341ac..5b9b217 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1185,6 +1185,7 @@ extern void truncate_inode_pages_range(struct address_space *,
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
+extern int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma);
 
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
diff --git a/mm/filemap.c b/mm/filemap.c
index 0c4906f..eb7653d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1650,7 +1650,7 @@ page_not_uptodate:
 EXPORT_SYMBOL(filemap_fault);
 
 #ifdef CONFIG_CHECKPOINT
-static int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 	int vma_objref;
-- 
1.6.2.5
