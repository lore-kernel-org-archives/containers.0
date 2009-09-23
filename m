From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 39/80] c/r: add generic '->checkpoint' f_op to ext fses
Date: Wed, 23 Sep 2009 19:51:19 -0400
Message-ID: <1253749920-18673-40-git-send-email-orenl__39510.0287198604$1253755760$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

This marks ext[234] as being checkpointable.  There will be many
more to do this to, but this is a start.

Changelog[v1]:
  - [Serge Hallyn] Use filemap_checkpoint() in ext4_file_vm_ops

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/ext2/dir.c  |    1 +
 fs/ext2/file.c |    2 ++
 fs/ext3/dir.c  |    1 +
 fs/ext3/file.c |    1 +
 fs/ext4/dir.c  |    1 +
 fs/ext4/file.c |    4 ++++
 6 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 6cde970..78e9157 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -722,4 +722,5 @@ const struct file_operations ext2_dir_operations = {
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 2b9e47d..edbc3dc 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -58,6 +58,7 @@ const struct file_operations ext2_file_operations = {
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 #ifdef CONFIG_EXT2_FS_XIP
@@ -73,6 +74,7 @@ const struct file_operations ext2_xip_file_operations = {
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= simple_fsync,
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
index 5b49704..a421e07 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -126,6 +126,7 @@ const struct file_operations ext3_file_operations = {
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
index 3f1873f..cdac137 100644
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
@@ -195,6 +198,7 @@ const struct file_operations ext4_file_operations = {
 	.fsync		= ext4_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-- 
1.6.0.4
