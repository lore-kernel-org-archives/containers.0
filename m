From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] Add support for checkpoint/restart of ramfs directories
Date: Sat,  7 Aug 2010 19:27:04 -0700
Message-ID: <e0f7b06ab978f7aa3966cc1ff8c891e760e477d0.1281234417.git.matthltc@us.ibm.com>
References: <c6fe338914cc217649cf15e9b518027420342e44.1281234417.git.matthltc@us.ibm.com>
	<1d060d636d34cb4cf16db39d2ff2afce5bef50a5.1281234417.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1d060d636d34cb4cf16db39d2ff2afce5bef50a5.1281234417.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <c6fe338914cc217649cf15e9b518027420342e44.1281234417.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <c6fe338914cc217649cf15e9b518027420342e44.1281234417.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

We cannot set a .checkpoint op in simple_dir_operations because they get
used mostly for pseudo-filesystem interfaces. Those provide a userspace
interface to special kernel data structures which are difficult or
impossible to checkpoint reliably for some uses of checkpoint/restart.
Specifically they may be unreliable when migrating a checkpoint to a
different machine or even across boots of the same machine with the same
kernel.

However mounts of ramfs are capable of reliably supporting checkpoint/restart
because they can be backed-up from userspace. So we add a new set of dir
operations based on simple_dir_operations but which support checkpoint.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ramfs/inode.c    |   19 ++++++++++++++++++-
 fs/ramfs/internal.h |    1 -
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index c948534..62d26c5 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -44,6 +44,23 @@
 static const struct super_operations ramfs_ops;
 static const struct inode_operations ramfs_dir_inode_operations;
 
+#ifdef CONFIG_CHECKPOINT
+static const struct file_operations ramfs_dir_operations = {
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
+#define ramfs_dir_operations simple_dir_operations
+#endif
+
 static struct backing_dev_info ramfs_backing_dev_info = {
 	.name		= "ramfs",
 	.ra_pages	= 0,	/* No readahead */
@@ -75,7 +92,7 @@ struct inode *ramfs_get_inode(struct super_block *sb, int mode, dev_t dev)
 			break;
 		case S_IFDIR:
 			inode->i_op = &ramfs_dir_inode_operations;
-			inode->i_fop = &simple_dir_operations;
+			inode->i_fop = &ramfs_dir_operations;
 
 			/* directory inodes start off with i_nlink == 2 (for "." entry) */
 			inc_nlink(inode);
diff --git a/fs/ramfs/internal.h b/fs/ramfs/internal.h
index 6b33063..9a11302 100644
--- a/fs/ramfs/internal.h
+++ b/fs/ramfs/internal.h
@@ -9,6 +9,5 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-
 extern const struct address_space_operations ramfs_aops;
 extern const struct inode_operations ramfs_file_inode_operations;
-- 
1.6.3.3
