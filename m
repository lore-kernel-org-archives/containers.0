From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] use ckpt_err in ckpt_obj_fetch()
Date: Mon, 16 Nov 2009 15:00:30 -0600
Message-ID: <1258405231-13784-2-git-send-email-serge@us.ibm.com>
References: <1258405231-13784-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258405231-13784-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 9b1b2f4..1f7ce0e 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -1004,8 +1004,14 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 	struct ckpt_obj *obj;
 
 	obj = obj_find_by_objref(ctx, objref);
-	if (!obj)
+	if (!obj) {
+		ckpt_err(ctx, -EINVAL, "%(O)No such object\n", objref);
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
