From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 08/10] Add generic '->checkpoint' f_op to ext filesystems
Date: Mon, 28 Feb 2011 17:40:30 -0600
Message-ID: <1298936432-29607-9-git-send-email-ntl__46917.0724660673$1298937096$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

This marks ext[234] as being checkpointable.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 fs/ext2/dir.c  |    3 +++
 fs/ext2/file.c |    6 ++++++
 fs/ext3/dir.c  |    3 +++
 fs/ext3/file.c |    3 +++
 fs/ext4/dir.c  |    3 +++
 fs/ext4/file.c |    6 ++++++
 6 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 2709b34..7aefb74 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -721,4 +721,7 @@ const struct file_operations ext2_dir_operations = {
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
 	.fsync		= ext2_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 49eec94..c8991c8 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -76,6 +76,9 @@ const struct file_operations ext2_file_operations = {
 	.fsync		= ext2_fsync,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif /* CONFIG_CHECKPOINT */
 };
 
 #ifdef CONFIG_EXT2_FS_XIP
@@ -91,6 +94,9 @@ const struct file_operations ext2_xip_file_operations = {
 	.open		= dquot_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_fsync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif /* CONFIG_CHECKPOINT */
 };
 #endif
 
diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index e2e72c3..e2f5948 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -48,6 +48,9 @@ const struct file_operations ext3_dir_operations = {
 #endif
 	.fsync		= ext3_sync_file,	/* BKL held */
 	.release	= ext3_release_dir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 
diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index f55df0e..2cf4ef2 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -68,6 +68,9 @@ const struct file_operations ext3_file_operations = {
 	.fsync		= ext3_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ext3_file_inode_operations = {
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index ece76fb..0101873 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -48,6 +48,9 @@ const struct file_operations ext4_dir_operations = {
 #endif
 	.fsync		= ext4_sync_file,
 	.release	= ext4_release_dir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 5a5c55d..142dde6 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -86,6 +86,9 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
@@ -188,6 +191,9 @@ const struct file_operations ext4_file_operations = {
 	.fsync		= ext4_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-- 
1.7.4
