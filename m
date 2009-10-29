From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 13/17] ckpt_error in checkpoint/files.c
Date: Thu, 29 Oct 2009 15:54:38 -0500
Message-ID: <1256849682-858-14-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Convert two ckpt_debugs to ckpt_errors - however, given that they
are merely doubling information available in ckpt_write_err(), should
they simply be removed?

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 1f2ab07..e67a13f 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -206,12 +206,14 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	if (!file->f_op || !file->f_op->checkpoint) {
 		ckpt_write_err(ctx, "%(T)%(E)%(P)%(S)f_op lacks checkpoint",
 			       -EBADF, file, file->f_op);
-		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
+		ckpt_error(ctx, "%(T)f_op lacks checkpoint handler: %pS\n",
+			   file->f_op);
 		return -EBADF;
 	}
 	if (d_unlinked(file->f_dentry)) {
 		ckpt_write_err(ctx, "%(T)%(E)%(P)unlinked file", -EBADF, file);
-		ckpt_debug("unlinked files are unsupported\n");
+		ckpt_error(ctx, "%(T)%(P)unlinked files are unsupported\n",
+			   file);
 		return -EBADF;
 	}
 
-- 
1.6.1
