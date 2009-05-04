From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 34/36] exofs: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <4a64b02f5999bae22e90005fd5b612b3d900ec92.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation to exofs files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Cc: Avishay Traeger <avishay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 fs/exofs/dir.c  |    1 +
 fs/exofs/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 65b0c8c..5184c15 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -669,4 +669,5 @@ const struct file_operations exofs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= exofs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 6ed7fe4..b94e792 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -68,6 +68,7 @@ static int exofs_flush(struct file *file, fl_owner_t id)
 
 const struct file_operations exofs_file_operations = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= generic_file_aio_read,
-- 
1.5.6.3
