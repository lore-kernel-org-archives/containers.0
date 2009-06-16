From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: user_ns: fix trivial errors
Date: Tue, 16 Jun 2009 15:58:49 -0500
Message-ID: <20090616205849.GA5402@us.ibm.com>
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

Use the right identifier out of CKPT_OBJ_USER and CKPT_OBJ_USER_NS.

Don't do ckpt_hdr_put() twice in do_restore_user_ns

Don't ifdef CONFIG_USER_NS in user_namespace.c which is only compiled
when CONFIG_USER_NS.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/user.c           |    2 +-
 kernel/user_namespace.c |    7 ++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/kernel/user.c b/kernel/user.c
index 58ec18d..820cc2c 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -545,7 +545,7 @@ static int do_checkpoint_user(struct ckpt_ctx *ctx, struct user_struct *u)
 	do {
 		ns = save_u->user_ns;
 		save_u = ns->creator;
-		if (ckpt_obj_lookup(ctx, save_u, CKPT_OBJ_USER_NS))
+		if (ckpt_obj_lookup(ctx, save_u, CKPT_OBJ_USER))
 			goto found;
 		unsaved_creators[unsaved_ns_nr++] = save_u;
 		if (unsaved_ns_nr == step * UNSAVED_STRIDE) {
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index a8a46a3..eb1a714 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -125,7 +125,7 @@ static int do_checkpoint_userns(struct ckpt_ctx *ctx, struct user_namespace *ns)
 	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
 	if (ns != root_ns) {
 		creator_ref = ckpt_obj_lookup(ctx, ns->creator,
-					      CKPT_OBJ_USER_NS);
+					      CKPT_OBJ_USER);
 		if (!creator_ref)
 			return -EINVAL;
 	}
@@ -163,9 +163,7 @@ static struct user_namespace *do_restore_userns(struct ckpt_ctx *ctx)
 		goto out;
 	}
 
-#ifdef CONFIG_USER_NS
 	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
-	ckpt_hdr_put(ctx, h);
 	if (IS_ERR(creator)) {
 		ns = ERR_PTR(-EINVAL);
 		goto out;
@@ -187,10 +185,9 @@ static struct user_namespace *do_restore_userns(struct ckpt_ctx *ctx)
 	 * The objhash will keep the userns pinned until then.
 	 */
 	free_uid(new_root);
-#endif
 
  out:
-	ctx->stats.ipc_ns++;
+	ctx->stats.user_ns++;
 	ckpt_hdr_put(ctx, h);
 	return ns;
 }
-- 
1.6.1
