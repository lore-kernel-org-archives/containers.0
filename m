From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 35/36] Add the checkpoint operation to nilfs2 files and
	directories.
Date: Mon, 13 Jul 2009 06:58:49 -0700
Message-ID: <1247493495-23469-36-git-send-email-matthltc@us.ibm.com>
References: <1247493495-23469-1-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-2-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-3-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-4-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-5-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-6-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-7-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-8-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-9-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-10-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-11-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-12-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-13-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-14-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-15-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-16-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-17-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-18-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-19-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-20-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-21-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-22-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-23-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-24-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-25-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-26-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-27-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-28-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-29-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-30-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-31-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-32-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-33-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-34-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-35-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-35-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: KONISHI Ryusuke <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Cc: users-JrjvKiOkagjYtjvyW6yDsg@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/nilfs2/dir.c  |    2 +-
 fs/nilfs2/file.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 54100ac..38fd744 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -707,5 +707,5 @@ struct file_operations nilfs_dir_operations = {
 	.compat_ioctl	= nilfs_ioctl,
 #endif	/* CONFIG_COMPAT */
 	.fsync		= nilfs_sync_file,
-
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 6bd84a0..0f27ab5 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -136,6 +136,7 @@ static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
  */
 struct file_operations nilfs_file_operations = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= generic_file_aio_read,
-- 
1.5.6.3
