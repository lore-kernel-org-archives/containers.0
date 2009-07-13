From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/36] Add the checkpoint operation for btrfs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:18 -0700
Message-ID: <1247493495-23469-5-git-send-email-matthltc@us.ibm.com>
References: <1247493495-23469-1-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-2-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-3-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-4-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-4-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/btrfs/file.c  |    1 +
 fs/btrfs/inode.c |    1 +
 fs/btrfs/super.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 7c3cd24..7084c0f 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1230,4 +1230,5 @@ struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 7ffa3d3..fda136d 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -5228,6 +5228,7 @@ static struct file_operations btrfs_dir_file_operations = {
 #endif
 	.release        = btrfs_release_file,
 	.fsync		= btrfs_sync_file,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct extent_io_ops btrfs_extent_io_ops = {
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index 9f179d4..1e404b3 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -695,6 +695,7 @@ static const struct file_operations btrfs_ctl_fops = {
 	.unlocked_ioctl	 = btrfs_control_ioctl,
 	.compat_ioctl = btrfs_control_ioctl,
 	.owner	 = THIS_MODULE,
+	.checkpoint = generic_file_checkpoint,
 };
 
 static struct miscdevice btrfs_misc = {
-- 
1.5.6.3
