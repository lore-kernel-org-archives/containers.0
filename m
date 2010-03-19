From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 44/96] c/r: add generic '->checkpoint' f_op to ext
	fses
Date: Thu, 18 Mar 2010 20:59:50 -0400
Message-ID: <1268960401-16680-7-git-send-email-orenl__23158.2423592501$1268961081$gmane$org@cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268960401-16680-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

This marks ext[234] as being checkpointable.  There will be many
more to do this to, but this is a start.

Changelog[ckpt-v19-rc3]:
  - Rebase to kernel 2.6.33 (ext2)
Changelog[v1]:
  - [Serge Hallyn] Use filemap_checkpoint() in ext4_file_vm_ops

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext2/dir.c  |    1 +
 fs/ext2/file.c |    2 ++
 fs/ext3/dir.c  |    1 +
 fs/ext3/file.c |    1 +
 fs/ext4/dir.c  |    1 +
 fs/ext4/file.c |    4 ++++
 6 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 7516957..84c17f9 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -722,4 +722,5 @@ const struct file_operations ext2_dir_operations = {
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
 	.fsync		= ext2_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 586e358..b38d7b9 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -75,6 +75,7 @@ const struct file_operations ext2_file_operations = {
 	.fsync		= ext2_fsync,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 #ifdef CONFIG_EXT2_FS_XIP
@@ -90,6 +91,7 @@ const struct file_operations ext2_xip_file_operations = {
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 #endif
 
diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index 373fa90..65f98af 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -48,6 +48,7 @@ const struct file_operations ext3_dir_operations = {
 #endif
 	.fsync		= ext3_sync_file,	/* BKL held */
 	.release	= ext3_release_dir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 
diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index 388bbdf..bcd9b88 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -67,6 +67,7 @@ const struct file_operations ext3_file_operations = {
 	.fsync		= ext3_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ext3_file_inode_operations = {
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 9dc9316..f69404c 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -48,6 +48,7 @@ const struct file_operations ext4_dir_operations = {
 #endif
 	.fsync		= ext4_sync_file,
 	.release	= ext4_release_dir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 9630583..93a129b 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -84,6 +84,9 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
 	.page_mkwrite   = ext4_page_mkwrite,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
@@ -146,6 +149,7 @@ const struct file_operations ext4_file_operations = {
 	.fsync		= ext4_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-- 
1.6.3.3
