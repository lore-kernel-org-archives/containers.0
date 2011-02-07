From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 3/6] c/r: introduce ckpt_obj_count() for the total number of
	objects
Date: Mon,  7 Feb 2011 12:18:05 -0500
Message-ID: <1297099088-18683-4-git-send-email-orenl@cs.columbia.edu>
References: <1297099088-18683-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1297099088-18683-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This will be needed for pids-objects in container checkpoints.  In
userspace we will rely on the pids objects inserted to the objash
sequentially. For subtree checkpoint, the pids objects are the first
to enter the objhash, therefore their tags will counting from 1.  In
container checkpoint, other objects are inserted first, so we will
need to know how many objects were inserted earlier - so we will alos
save the count at that time.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h  |    2 ++
 kernel/checkpoint/objhash.c |    5 +++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 21fc23e..65b6477 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -211,6 +211,8 @@ extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
 extern int ckpt_obj_delete(struct ckpt_ctx *ctx, int objref,
 			   enum obj_type type);
+extern int ckpt_obj_count(struct ckpt_ctx *ctx);
+
 
 extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
index 40c2e9b..cbace7a 100644
--- a/kernel/checkpoint/objhash.c
+++ b/kernel/checkpoint/objhash.c
@@ -158,6 +158,11 @@ static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
 	return ctx->obj_hash->next_free_objref++;
 }
 
+int ckpt_obj_count(struct ckpt_ctx *ctx)
+{
+	return ctx->obj_hash->next_free_objref;
+}
+
 /**
  * ckpt_obj_new - add an object to the obj_hash
  * @ctx: checkpoint context
-- 
1.7.1
