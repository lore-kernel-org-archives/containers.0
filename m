From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 14/36] Add the checkpoint operation for jffs2 files and
	directories.
Date: Mon, 13 Jul 2009 06:58:28 -0700
Message-ID: <1247493495-23469-15-git-send-email-matthltc@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-14-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 fs/jffs2/dir.c  |    1 +
 fs/jffs2/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/jffs2/dir.c b/fs/jffs2/dir.c
index 6f60cc9..c2b6487 100644
--- a/fs/jffs2/dir.c
+++ b/fs/jffs2/dir.c
@@ -41,6 +41,7 @@ const struct file_operations jffs2_dir_operations =
 	.unlocked_ioctl=jffs2_ioctl,
 	.fsync =	jffs2_fsync,
 	.llseek =	generic_file_llseek,
+	.checkpoint =	generic_file_checkpoint,
 };
 
 
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index 5edc2bf..6bc2bc6 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -50,6 +50,7 @@ const struct file_operations jffs2_file_operations =
 	.mmap =		generic_file_readonly_mmap,
 	.fsync =	jffs2_fsync,
 	.splice_read =	generic_file_splice_read,
+	.checkpoint =	generic_file_checkpoint,
 };
 
 /* jffs2_file_inode_operations */
-- 
1.5.6.3
