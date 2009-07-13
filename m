From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 01/36] Add the checkpoint operation for affs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:15 -0700
Message-ID: <1247493495-23469-2-git-send-email-matthltc@us.ibm.com>
References: <1247493495-23469-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 fs/affs/dir.c  |    1 +
 fs/affs/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/affs/dir.c b/fs/affs/dir.c
index 8ca8f3a..6cc5e43 100644
--- a/fs/affs/dir.c
+++ b/fs/affs/dir.c
@@ -22,6 +22,7 @@ const struct file_operations affs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.readdir	= affs_readdir,
 	.fsync		= affs_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 /*
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 184e55c..d580a12 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -36,6 +36,7 @@ const struct file_operations affs_file_operations = {
 	.release	= affs_file_release,
 	.fsync		= affs_file_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations affs_file_inode_operations = {
-- 
1.5.6.3
