From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 19/36] qnx4: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <6b4d4d8ef45f037ead04d65fab5dd3566106a8d6.1241462097.git.matthltc@us.ibm.com>
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

Add the checkpoint operation for qnx4 files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/qnx4/dir.c  |    1 +
 fs/qnx4/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/qnx4/dir.c b/fs/qnx4/dir.c
index ea9ffef..2905691 100644
--- a/fs/qnx4/dir.c
+++ b/fs/qnx4/dir.c
@@ -85,6 +85,7 @@ const struct file_operations qnx4_dir_operations =
 	.read		= generic_read_dir,
 	.readdir	= qnx4_readdir,
 	.fsync		= file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations qnx4_dir_inode_operations =
diff --git a/fs/qnx4/file.c b/fs/qnx4/file.c
index 867f42b..495885e 100644
--- a/fs/qnx4/file.c
+++ b/fs/qnx4/file.c
@@ -31,6 +31,7 @@ const struct file_operations qnx4_file_operations =
 	.aio_write	= generic_file_aio_write,
 	.fsync		= qnx4_sync_file,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations qnx4_file_inode_operations =
-- 
1.5.6.3
