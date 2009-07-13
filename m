From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 32/36] Add checkpoint operations for ramfs files. NOTE: since
	simple_dir_operations are shared between multiple filesystems
	including ramfs,
	it's not currently possible to checkpoint open ramfs directories.
Date: Mon, 13 Jul 2009 06:58:46 -0700
Message-ID: <1247493495-23469-33-git-send-email-matthltc@us.ibm.com>
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
	<1247493495-23469-25-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-26-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-27-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-28-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-29-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-30-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-31-git-send-email-matthltc@us.ibm.com>
	<1247493495-23469-32-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247493495-23469-32-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
---
 fs/ramfs/file-mmu.c   |    1 +
 fs/ramfs/file-nommu.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 78f613c..4430239 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -47,6 +47,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index ebb2c41..5f7e20a 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -44,6 +44,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read		= generic_file_splice_read,
 	.splice_write		= generic_file_splice_write,
 	.llseek			= generic_file_llseek,
+	.checkpoint		= generic_file_checkpoint,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
-- 
1.5.6.3
