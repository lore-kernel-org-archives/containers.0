From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 25/36] udf: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <8847d61bf708a64051019019324d42a6e8887db1.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation for udf filesystem files and
 directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/udf/dir.c  |    1 +
 fs/udf/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/udf/dir.c b/fs/udf/dir.c
index 2efd4d5..90488f5 100644
--- a/fs/udf/dir.c
+++ b/fs/udf/dir.c
@@ -211,4 +211,5 @@ const struct file_operations udf_dir_operations = {
 	.readdir		= udf_readdir,
 	.ioctl			= udf_ioctl,
 	.fsync			= udf_fsync_file,
+	.checkpoint		= generic_file_checkpoint,
 };
diff --git a/fs/udf/file.c b/fs/udf/file.c
index eb91f3b..8e7ad98 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -212,6 +212,7 @@ const struct file_operations udf_file_operations = {
 	.fsync			= udf_fsync_file,
 	.splice_read		= generic_file_splice_read,
 	.llseek			= generic_file_llseek,
+	.checkpoint		= generic_file_checkpoint,
 };
 
 const struct inode_operations udf_file_inode_operations = {
-- 
1.5.6.3
