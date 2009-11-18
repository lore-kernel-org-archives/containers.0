From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/6] use ckpt_err in ckpt_obj_fetch()
Date: Tue, 17 Nov 2009 19:53:29 -0600
Message-ID: <1258509213-15318-2-git-send-email-serue@us.ibm.com>
References: <1258509213-15318-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258509213-15318-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changelog:
	Nov 17: print requested obj type

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 9b1b2f4..2e50025 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -1004,8 +1004,15 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 	struct ckpt_obj *obj;
 
 	obj = obj_find_by_objref(ctx, objref);
-	if (!obj)
+	if (!obj) {
+		ckpt_err(ctx, -EINVAL, "%(O)No such object (type %d)\n",
+			 objref, type);
 		return ERR_PTR(-EINVAL);
+	}
 	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
-	return (obj->ops->obj_type == type ? obj->ptr : ERR_PTR(-ENOMSG));
+	if (obj->ops->obj_type == type)
+		return obj->ptr;
+	ckpt_err(ctx, -ENOMSG, "%(O)Hashed objed was type %d, not %d\n",
+		 objref, obj->ops->obj_type, type);
+	return ERR_PTR(-ENOMSG);
 }
-- 
1.6.1
