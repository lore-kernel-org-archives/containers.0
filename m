From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 20/36] reiserfs: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <a2ba928bdf1ea0f62b8d702066f6891c87dcac64.1241462097.git.matthltc@us.ibm.com>
References: <63ff4e88102e10e86bffefd5e4445ab433ed51c0.1241462097.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <63ff4e88102e10e86bffefd5e4445ab433ed51c0.1241462097.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Add the checkpoint operation for reiserfs files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: reiserfs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/reiserfs/dir.c  |    1 +
 fs/reiserfs/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/reiserfs/dir.c b/fs/reiserfs/dir.c
index 67a80d7..8c39774 100644
--- a/fs/reiserfs/dir.c
+++ b/fs/reiserfs/dir.c
@@ -24,6 +24,7 @@ const struct file_operations reiserfs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = reiserfs_compat_ioctl,
 #endif
+	.checkpoint = generic_file_checkpoint,
 };
 
 static int reiserfs_dir_fsync(struct file *filp, struct dentry *dentry,
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 9f43666..a5dcc02 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -297,6 +297,7 @@ const struct file_operations reiserfs_file_operations = {
 	.splice_read = generic_file_splice_read,
 	.splice_write = generic_file_splice_write,
 	.llseek = generic_file_llseek,
+	.checkpoint = generic_file_checkpoint,
 };
 
 const struct inode_operations reiserfs_file_inode_operations = {
-- 
1.5.6.3
