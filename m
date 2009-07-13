From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 24/36] Add the checkpoint operation for ubifs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:38 -0700
Message-ID: <1247493495-23469-25-git-send-email-matthltc@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-24-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

I think the debug files will also work with the generic file
checkpoint helper but it needs a bit more investigation to be
certain.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Artem Bityutskiy <dedekind-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Adrian Hunter <ext-adrian.hunter-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/ubifs/debug.c |    1 +
 fs/ubifs/dir.c   |    1 +
 fs/ubifs/file.c  |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
index ce2cd83..69a8892 100644
--- a/fs/ubifs/debug.c
+++ b/fs/ubifs/debug.c
@@ -2530,6 +2530,7 @@ static ssize_t write_debugfs_file(struct file *file, const char __user *buf,
 static const struct file_operations dfs_fops = {
 	.open = open_debugfs_file,
 	.write = write_debugfs_file,
+	.checkpoint = generic_file_checkpoint,
 	.owner = THIS_MODULE,
 };
 
diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 552fb01..89ab2aa 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1228,4 +1228,5 @@ const struct file_operations ubifs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+	.checkpoint     = generic_file_checkpoint,
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 6d34dc7..2d94676 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1595,4 +1595,5 @@ const struct file_operations ubifs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+	.checkpoint     = generic_file_checkpoint,
 };
-- 
1.5.6.3
