From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/36] Add the checkpoint operation for hfs files and
	directories.
Date: Mon, 13 Jul 2009 06:58:23 -0700
Message-ID: <1247493495-23469-10-git-send-email-matthltc@us.ibm.com>
References: <1247493495-23469-1-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-2-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-3-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-4-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-5-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-6-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-7-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-8-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-9-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-9-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 fs/hfs/dir.c   |    1 +
 fs/hfs/inode.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/hfs/dir.c b/fs/hfs/dir.c
index 7c69b98..8d90a24 100644
--- a/fs/hfs/dir.c
+++ b/fs/hfs/dir.c
@@ -318,6 +318,7 @@ const struct file_operations hfs_dir_operations = {
 	.readdir	= hfs_readdir,
 	.llseek		= generic_file_llseek,
 	.release	= hfs_dir_release,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations hfs_dir_inode_operations = {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index a1cbff2..bf8950f 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -607,6 +607,7 @@ static const struct file_operations hfs_file_operations = {
 	.fsync		= file_fsync,
 	.open		= hfs_file_open,
 	.release	= hfs_file_release,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static const struct inode_operations hfs_file_inode_operations = {
-- 
1.5.6.3
