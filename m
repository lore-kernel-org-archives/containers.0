From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 07/36] fat: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <be7247489a833bc7ca908eb39876a219847aa64d.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation for fat files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/fat/dir.c  |    1 +
 fs/fat/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/fat/dir.c b/fs/fat/dir.c
index 3a7f603..3baecf8 100644
--- a/fs/fat/dir.c
+++ b/fs/fat/dir.c
@@ -841,6 +841,7 @@ const struct file_operations fat_dir_operations = {
 	.compat_ioctl	= fat_compat_dir_ioctl,
 #endif
 	.fsync		= file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int fat_get_short_entry(struct inode *dir, loff_t *pos,
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 0a7f4a9..f2abe6c 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -144,6 +144,7 @@ const struct file_operations fat_file_operations = {
 	.ioctl		= fat_generic_ioctl,
 	.fsync		= file_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int fat_cont_expand(struct inode *inode, loff_t size)
-- 
1.5.6.3
