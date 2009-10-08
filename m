From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: lsm: actually cache entries
Date: Thu, 8 Oct 2009 14:47:20 -0500
Message-ID: <20091008194720.GA648@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Somewhere along the way, the lsm c/r patchset seems to have
dropped the code caching whether a particular void*security
had already been checkpointed.  Note that checkpoint a
void* security means allocing a struct containing the secref
and the string representation of the context.  That leaves us
with no way to tell, given only the void*security, whether
that context has been checkpointed before (as part of checkpointing
a different object of the same object type and security context).

This patch re-introduces a moronic unsorted per-checkpoint list
of checkpointed contexts, used only at checkpoint time, so that
we can re-use secrefs.  Converting this to an rblist or hash will
be trivial, but isn't done here to try and make clear why we
actually need this.

(applies on top of existing LSM c/r patches at
git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c                 |   15 +++++++++++++
 include/linux/checkpoint_types.h |    4 +++
 security/security.c              |   43 ++++++++++++++++++++++++++++++++-----
 3 files changed, 56 insertions(+), 6 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 05370d3..9a3450e 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -210,6 +210,18 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 	kfree(ctx->tasks_arr);
 }
 
+static void seclist_free(struct ckpt_ctx *ctx)
+{
+	struct hlist_node *p, *q;
+	struct ckpt_stored_lsm *l;
+
+	hlist_for_each_entry_safe(l, p, q, &ctx->seclist, hash) {
+		hlist_del(&l->hash);
+		kfree(l->string);
+		kfree(l);
+	}
+}
+
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	BUG_ON(atomic_read(&ctx->refcount));
@@ -231,6 +243,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	path_put(&ctx->fs_mnt);
 	ckpt_pgarr_free(ctx);
 
+	seclist_free(ctx);
+
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
 
@@ -263,6 +277,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	INIT_HLIST_HEAD(&ctx->seclist);
 	init_waitqueue_head(&ctx->waitq);
 	init_waitqueue_head(&ctx->ghostq);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 8e29d5f..01cbab4 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -66,6 +66,7 @@ struct ckpt_ctx {
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+	struct hlist_head seclist; /* to become a hash list of LSM contexts */
 
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
@@ -94,6 +95,9 @@ struct ckpt_stored_lsm {
 	struct kref kref;
 	int sectype;
 	char *string;
+	int secref;
+	void *security;
+	struct hlist_node hash;
 };
 
 #endif /* __KERNEL__ */
diff --git a/security/security.c b/security/security.c
index d54a773..30097e2 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1308,6 +1308,26 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 
 #include <linux/checkpoint.h>
 
+struct ckpt_stored_lsm *
+ckpt_security_fromcache(struct ckpt_ctx *ctx, unsigned sectype, void *security)
+{
+	struct ckpt_stored_lsm *l;
+	struct hlist_node *p;
+	hlist_for_each_entry(l, p, &ctx->seclist, hash) {
+		if (l->security == security && l->sectype == sectype)
+			return l;
+	}
+	return NULL;
+}
+
+int
+ckpt_security_insertcache(struct ckpt_ctx *ctx, unsigned sectype, void *security,
+			struct ckpt_stored_lsm *l)
+{
+	hlist_add_head(&l->hash, &ctx->seclist);
+	return 0;
+}
+
 /**
  * security_checkpoint_obj - if first checkpoint of this void* security,
  * then 1. ask the LSM for a string representing the context, 2. checkpoint
@@ -1325,10 +1345,10 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
 				unsigned sectype)
 {
-	int strref;
+	int secref;
 	struct ckpt_stored_lsm *l;
 	char *str;
-	int len;
+	int ret;
 
 	/*
 	 * to simplify the LSM code, short-cut a null security
@@ -1337,6 +1357,10 @@ int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
 	if (!security)
 		return -EOPNOTSUPP;
 
+	l = ckpt_security_fromcache(ctx, sectype, security);
+	if (l)
+		return l->secref;
+
 	switch (sectype) {
 	case CKPT_SECURITY_MSG_MSG:
 		str = security_msg_msg_checkpoint(security);
@@ -1359,7 +1383,6 @@ int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
 	if (IS_ERR(str))
 		return PTR_ERR(str);
 
-	len = strlen(str);
 	l = kzalloc(sizeof(*l), GFP_KERNEL);
 	if (!l) {
 		kfree(str);
@@ -1368,14 +1391,22 @@ int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
 	kref_init(&l->kref);
 	l->sectype = sectype;
 	l->string = str;
+	l->security = security;
 
-	strref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
-	if (strref < 0) {
+	ret = ckpt_security_insertcache(ctx, sectype, security, l);
+	if (ret) {
+		kfree(str);
+		kfree(l);
+		return ret;
+	}
+	secref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
+	if (secref < 0) {
 		/* l wasn't added to objhash, so objhash won't free it */
 		kfree(str);
 		kfree(l);
 	}
-	return strref;
+	l->secref = secref;
+	return secref;
 }
 
 #endif
-- 
1.5.4.3
