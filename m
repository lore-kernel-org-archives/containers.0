From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Adjust socket reference count during leak detection phase
Date: Mon, 21 Sep 2009 13:44:36 -0700
Message-ID: <1253565877-7303-2-git-send-email-danms@us.ibm.com>
References: <1253565877-7303-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253565877-7303-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Sockets that have been disconnected from their struct file have
a reference count one less than normal sockets (potentially zero if the
socket is only in the system because of an outstanding skb).  Since the
objhash assumes a minimum reference count of 2, skb's in such a situation
will always be counted as a leak.

This (probably contentious) patch adds a fixup function during the leak
detection phase to adjust SOCK_DEAD sockets' reference counts down by
one to match reality.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index b85aa77..ee9dbfd 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -816,6 +816,26 @@ static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
  */
 
 /**
+ * obj_sock_adjust_users - remove implicit reference on DEAD sockets
+ * @obj: CKPT_OBJ_SOCK object to adjust
+ *
+ * Sockets that have been disconnected from their struct file have
+ * a reference count one less than normal sockets.  The objhash's
+ * assumption of such a reference is therefore incorrect, so we correct
+ * it here.
+ */
+static inline void obj_sock_adjust_users(struct ckpt_obj *obj)
+{
+	struct sock *sk = (struct sock *)obj->ptr;
+
+	if (sock_flag(sk, SOCK_DEAD)) {
+		obj->users--;
+		ckpt_debug("Adjusting SOCK %i count to %i\n",
+			   obj->objref, obj->users);
+	}
+}
+
+/**
  * ckpt_obj_contained - test if shared objects are contained in checkpoint
  * @ctx: checkpoint context
  *
@@ -838,6 +858,10 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
 			continue;
+
+		if (obj->ops->obj_type == CKPT_OBJ_SOCK)
+			obj_sock_adjust_users(obj);
+
 		if (obj->ops->ref_users(obj->ptr) != obj->users) {
 			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
 			ckpt_write_err(ctx, "OP", "leak: usage (%d != %d (%s)",
-- 
1.6.2.5
