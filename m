From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Add a 'cleanup' function to objhash object operations
Date: Tue, 15 Sep 2009 09:52:10 -0700
Message-ID: <1253033531-6764-2-git-send-email-danms@us.ibm.com>
References: <1253033531-6764-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253033531-6764-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds a 'cleanup' function to the object operations structure,
which is called during objhash teardown before the final reference is
dropped.  It provides a way to perform some object cleanup when checkpoint
or restart operation is finished, in scenarios where the final reference
count cannot be anticipated.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index a410346..9750483 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -34,6 +34,7 @@ struct ckpt_obj_ops {
 	int (*ref_users)(void *ptr);
 	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
 	void *(*restore)(struct ckpt_ctx *ctx);
+	void (*cleanup)(void *ptr);
 };
 
 struct ckpt_obj {
@@ -399,6 +400,8 @@ static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
 
 	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
 		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			if (obj->ops->cleanup)
+				obj->ops->cleanup(obj->ptr);
 			obj->ops->ref_drop(obj->ptr);
 			kfree(obj);
 		}
-- 
1.6.2.5
