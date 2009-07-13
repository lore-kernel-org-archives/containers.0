From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 15/36] Add the checkpoint operation for jfs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:29 -0700
Message-ID: <1247493495-23469-16-git-send-email-matthltc@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-15-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Dave Kleikamp <shaggy-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
Cc: jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/jfs/file.c  |    1 +
 fs/jfs/namei.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/jfs/file.c b/fs/jfs/file.c
index 7f6063a..90ab090 100644
--- a/fs/jfs/file.c
+++ b/fs/jfs/file.c
@@ -116,4 +116,5 @@ const struct file_operations jfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
index 514ee2e..5486db9 100644
--- a/fs/jfs/namei.c
+++ b/fs/jfs/namei.c
@@ -1556,6 +1556,7 @@ const struct file_operations jfs_dir_operations = {
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int jfs_ci_hash(struct dentry *dir, struct qstr *this)
-- 
1.5.6.3
