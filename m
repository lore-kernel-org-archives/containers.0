From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 26/36] Add the checkpoint operation for xfs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:40 -0700
Message-ID: <1247493495-23469-27-git-send-email-matthltc@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-26-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: xfs-masters-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Cc: xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/xfs/linux-2.6/xfs_file.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index f4e2554..8e1074b 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -258,6 +258,7 @@ const struct file_operations xfs_file_operations = {
 #ifdef HAVE_FOP_OPEN_EXEC
 	.open_exec	= xfs_file_open_exec,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct file_operations xfs_dir_file_operations = {
@@ -270,6 +271,7 @@ const struct file_operations xfs_dir_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.fsync		= xfs_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct vm_operations_struct xfs_file_vm_ops = {
-- 
1.5.6.3
