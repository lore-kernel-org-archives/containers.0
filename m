From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 7/8] hugetlbfs checkpoint/restart hooks
Date: Tue, 14 Sep 2010 15:02:09 -0500
Message-ID: <1284494530-25946-8-git-send-email-ntl@pobox.com>
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

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 fs/hugetlbfs/inode.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a0bbd3d..575f837 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -21,6 +21,7 @@
 #include <linux/string.h>
 #include <linux/capability.h>
 #include <linux/ctype.h>
+#include <linux/checkpoint.h>
 #include <linux/backing-dev.h>
 #include <linux/hugetlb.h>
 #include <linux/pagevec.h>
@@ -463,6 +464,24 @@ out:
 	return error;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static const struct file_operations hugetlbfs_dir_operations = {
+	/* Just like simple_dir_operations except... */
+	.open		= dcache_dir_open,
+	.release	= dcache_dir_close,
+	.llseek		= dcache_dir_lseek,
+	.read		= generic_read_dir,
+	.readdir	= dcache_readdir,
+	.fsync		= simple_sync_file,
+
+	/* The checkpoint ops are unlike simple_dir_operations */
+	.checkpoint	= generic_file_checkpoint,
+};
+#else
+#define hugetlbfs_dir_operations simple_dir_operations
+#endif
+
+
 static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid, 
 					gid_t gid, int mode, dev_t dev)
 {
@@ -497,7 +516,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 			break;
 		case S_IFDIR:
 			inode->i_op = &hugetlbfs_dir_inode_operations;
-			inode->i_fop = &simple_dir_operations;
+			inode->i_fop = &hugetlbfs_dir_operations;
 
 			/* directory inodes start off with i_nlink == 2 (for "." entry) */
 			inc_nlink(inode);
@@ -690,6 +709,9 @@ const struct file_operations hugetlbfs_file_operations = {
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= simple_sync_file,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
-- 
1.7.2.2
