From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] objhash: fix syntax error
Date: Thu, 6 Aug 2009 21:00:52 -0500
Message-ID: <20090807020052.GA21216@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

first two args to ckpt_write_err() were switched

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 3452e83..a2fb278 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -682,8 +682,8 @@ int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 		obj->flags |= CKPT_OBJ_VISITED;
 	} else if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
 		/* if not found and full container, report reverse leak */
-		ckpt_write_err("reverse leak: %s (%d) not found\n",
-			       ctx, obj->ops->obj_name, obj->objref);
+		ckpt_write_err(ctx, "reverse leak: %s (%d) not found\n",
+			       obj->ops->obj_name, obj->objref);
 		return -EAGAIN;
 	}
 
-- 
1.6.1
