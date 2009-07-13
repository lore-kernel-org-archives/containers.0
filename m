From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 17/36] Add the checkpoint operation for ntfs directories.
Date: Mon, 13 Jul 2009 06:58:31 -0700
Message-ID: <1247493495-23469-18-git-send-email-matthltc@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-17-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Anton Altaparmakov <aia21-5LkwijKnu/2sTnJN9+BGXg@public.gmane.org>
Cc: linux-ntfs-dev-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/ntfs/dir.c  |    1 +
 fs/ntfs/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index 5a9e344..4fe3759 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -1572,4 +1572,5 @@ const struct file_operations ntfs_dir_ops = {
 	/*.ioctl	= ,*/			/* Perform function on the
 						   mounted filesystem. */
 	.open		= ntfs_dir_open,	/* Open directory. */
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 3140a44..d63336e 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2282,6 +2282,7 @@ const struct file_operations ntfs_file_ops = {
 						    on the ntfs partition.  We
 						    do not need to care about
 						    the data source. */
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ntfs_file_inode_ops = {
-- 
1.5.6.3
