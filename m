From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 27/36] efs: Add checkpoint file operations
Date: Mon, 04 May 2009 13:27:50 -0700
Message-ID: <425243b944309f33cea53de7f4e232397f88d291.1241462097.git.matthltc@us.ibm.com>
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

Add checkpoint operation for efs directories.


Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/efs/dir.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/efs/dir.c b/fs/efs/dir.c
index 49308a2..3322f56 100644
--- a/fs/efs/dir.c
+++ b/fs/efs/dir.c
@@ -13,6 +13,7 @@ static int efs_readdir(struct file *, void *, filldir_t);
 const struct file_operations efs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= efs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations efs_dir_inode_operations = {
-- 
1.5.6.3
