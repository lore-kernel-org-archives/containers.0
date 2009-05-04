From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 04/36] btrfs: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <d4c7782efa9f33324f65188dfb480d4ba1af7a27.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation for btrfs files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/btrfs/file.c  |    1 +
 fs/btrfs/inode.c |    1 +
 fs/btrfs/super.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 482f8db..23d5c72 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1334,4 +1334,5 @@ struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 65219f6..583d57e 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -5158,6 +5158,7 @@ static struct file_operations btrfs_dir_file_operations = {
 #endif
 	.release        = btrfs_release_file,
 	.fsync		= btrfs_sync_file,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct extent_io_ops btrfs_extent_io_ops = {
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index a7acfe6..f16be9d 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -686,6 +686,7 @@ static const struct file_operations btrfs_ctl_fops = {
 	.unlocked_ioctl	 = btrfs_control_ioctl,
 	.compat_ioctl = btrfs_control_ioctl,
 	.owner	 = THIS_MODULE,
+	.checkpoint = generic_file_checkpoint,
 };
 
 static struct miscdevice btrfs_misc = {
-- 
1.5.6.3
