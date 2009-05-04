From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 15/36] jfs: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <18aef99b5f0c2a6e7845b06a6c2cf871c6801a78.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation for jfs files and directories.


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
