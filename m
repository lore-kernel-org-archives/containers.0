From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/6] Add ckpt_obj_del() to objhash for handling error
	conditions
Date: Mon, 22 Mar 2010 12:33:33 -0700
Message-ID: <1269286415-24851-5-git-send-email-danms@us.ibm.com>
References: <1269286415-24851-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269286415-24851-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This is not something that I would expect to be used in normal situations,
but it makes the error path of codependent network interfaces much smoother.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c       |   30 ++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    1 +
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5ae2e64..306f1b6 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -739,6 +739,14 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 	return obj;
 }
 
+static void obj_del(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
+{
+	hlist_del(&obj->hash);
+	hlist_del(&obj->next);
+	obj->ops->ref_drop(obj->ptr, 1);
+	kfree(obj);
+}
+
 /**************************************************************************
  * Checkpoint
  */
@@ -1175,6 +1183,28 @@ int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
 EXPORT_SYMBOL(ckpt_obj_insert);
 
 /**
+ * ckpt_obj_del - delete object (by pointer) in objhash
+ * @ctx: checkpoint context
+ * @ref: object reference
+ * @type: object type
+ *
+ * Return: nonzero on failure
+ */
+int ckpt_obj_del(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_objref(ctx, objref);
+	BUG_ON(obj && obj->ops->obj_type != type);
+	if (obj) {
+		ckpt_debug("%s deleted from hash\n", obj->ops->obj_name);
+		obj_del(ctx, obj);
+	}
+
+	return obj ? 0 : -ESRCH;
+}
+
+/**
  * ckpt_obj_try_fetch - fetch an object by its identifier
  * @ctx: checkpoint context
  * @objref: object id
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1e7f8d3..efbc049 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -193,6 +193,7 @@ extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
+extern int ckpt_obj_del(struct ckpt_ctx *ctx, int objref, enum obj_type type);
 
 extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
-- 
1.6.2.5
