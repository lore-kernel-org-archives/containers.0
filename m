From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 29/36] minix: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <356f6e474db53c8850ce6d3e7911c1e3edf97323.1241462097.git.matthltc@us.ibm.com>
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

Add checkpoint operation for minix filesystem files and directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/minix/dir.c  |    1 +
 fs/minix/file.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index d4946c4..79c8759 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -23,6 +23,7 @@ const struct file_operations minix_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= minix_readdir,
 	.fsync		= minix_sync_file,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static inline void dir_put_page(struct page *page)
diff --git a/fs/minix/file.c b/fs/minix/file.c
index 17765f6..10d793e 100644
--- a/fs/minix/file.c
+++ b/fs/minix/file.c
@@ -24,6 +24,7 @@ const struct file_operations minix_file_operations = {
 	.mmap		= generic_file_mmap,
 	.fsync		= minix_sync_file,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations minix_file_inode_operations = {
-- 
1.5.6.3
