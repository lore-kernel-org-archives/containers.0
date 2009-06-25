From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] better file error debugging
Date: Thu, 25 Jun 2009 12:51:25 -0700
Message-ID: <1245959485.31856.74.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This should give a nice message with symbol names for when we have an
open file that doesn't have an f_op->checkpoint.

Something along the lines of:

[1133:c/r:checkpoint_file] file operations have no checkpoint handler:tty_open+0x0/0x24

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 5be7d1b..566fc9a 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -193,8 +193,11 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 {
 	struct file *file = (struct file *) ptr;

-	if (!file->f_op || !file->f_op->checkpoint)
+	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_debug("file operations have no checkpoint handler: %pS\n",
+				file->f_op);
 		return -EBADF;
+	}
 	if (d_unhashed(file->f_dentry) && !IS_ROOT(file->f_dentry))
 		return -EBADF;
 	return file->f_op->checkpoint(ctx, file);



-- Dave
