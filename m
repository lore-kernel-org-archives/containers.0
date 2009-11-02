From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 06/12] checkpoint/process.c ckpt_write_err->ckpt_err
Date: Mon,  2 Nov 2009 16:23:34 -0600
Message-ID: <1257200620-15499-7-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 8e4a823..2c65e77 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -256,21 +256,21 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
 	if (files_objref < 0) {
-		ckpt_write_err(ctx, "TE", "files_struct", files_objref);
+		ckpt_err(ctx, "%(T)%(E)files_struct\n", files_objref);
 		return files_objref;
 	}
 
 	mm_objref = checkpoint_obj_mm(ctx, t);
 	ckpt_debug("mm: objref %d\n", mm_objref);
 	if (mm_objref < 0) {
-		ckpt_write_err(ctx, "TE", "mm_struct", mm_objref);
+		ckpt_err(ctx, "%(T)%(E)mm_struct\n", mm_objref);
 		return mm_objref;
 	}
 
 	sighand_objref = checkpoint_obj_sighand(ctx, t);
 	ckpt_debug("sighand: objref %d\n", sighand_objref);
 	if (sighand_objref < 0) {
-		ckpt_write_err(ctx, "TE", "sighand_struct", sighand_objref);
+		ckpt_err(ctx, "%(T)%(E)sighand_struct\n", sighand_objref);
 		return sighand_objref;
 	}
 
@@ -303,7 +303,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (first)
 		ret = checkpoint_obj_signal(ctx, t);
 	if (ret < 0)
-		ckpt_write_err(ctx, "TE", "signal_struct", ret);
+		ckpt_err(ctx, "%(T)%(E)signal_struct\n", ret);
 
 	return ret;
 }
-- 
1.6.1
