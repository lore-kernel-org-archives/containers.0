From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 19/38] C/R: multiple tasks
Date: Fri, 22 May 2009 08:55:13 +0400
Message-ID: <1242968132-1044-19-git-send-email-adobriyan__11579.2212695398$1242969521$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Restore task hierarchy wrt ->real_parent.

First thing soon-to-be-restored task does after birth is to find
->real_parent and glue itself to parent lists.

For this parent is dumped first and restored first, so that at the time
child starts restoration, parent is already up and running as task_struct,
and we get cheap loop-prevention check.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h  |    2 +
 kernel/kstate/kstate-object.c |    3 +-
 kernel/kstate/kstate-task.c   |   53 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index ac3c81d..348f59f 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -60,6 +60,8 @@ struct kstate_object_header {
 struct kstate_image_task_struct {
 	struct kstate_object_header hdr;
 
+	kstate_ref_t	ref_real_parent;
+
 	kstate_ref_t	ref_mm;
 
 	__u8		comm[16];
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index f9f2f33..60ba70d 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -25,7 +25,8 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	obj->o_ref.pos = 0;	/* not yet dumped */
 	obj->o_ref.id = 0;	/* not yet assigned */
 	obj->o_obj = p;
-	list_add(&obj->o_list, &ctx->obj[type]);
+	/* task_struct collecting relies on "_tail" part. */
+	list_add_tail(&obj->o_list, &ctx->obj[type]);
 
 	switch (type) {
 	case KSTATE_CTX_FILE:
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index aec97c2..4f48c32 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -11,11 +11,6 @@
 static int check_task_struct(struct task_struct *tsk)
 {
 	read_lock_irq(&tasklist_lock);
-	if (!list_empty(&tsk->children)) {
-		read_unlock_irq(&tasklist_lock);
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	if (!list_empty(&tsk->thread_group)) {
 		read_unlock_irq(&tasklist_lock);
 		WARN_ON(1);
@@ -74,8 +69,32 @@ static int collect_task_struct(struct kstate_context *ctx, struct task_struct *t
 
 int kstate_collect_all_task_struct(struct kstate_context *ctx)
 {
+	struct kstate_object *obj;
+	int rv;
+
 	/* Seed task list. */
-	return collect_task_struct(ctx, ctx->init_tsk);
+	rv = collect_task_struct(ctx, ctx->init_tsk);
+	if (rv < 0)
+		return rv;
+	/*
+	 * Children are added after parent as iteration goes on:
+	 * - parent is dumped before child, child knows position of parent's
+	 *   image and can reference it,
+	 * - task_struct restore is done in the same order: parent first.
+	 *   This is cheap loop prevention wrt "->real_parent": if real_parent
+	 *   reference can't be resolved at the time ->real_parent rewrite is
+	 *   done, image is malformed.
+	 */
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj, *child;
+
+		list_for_each_entry(child, &tsk->children, sibling) {
+			rv = collect_task_struct(ctx, child);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	return 0;
 }
 
 static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *obj)
@@ -91,6 +110,13 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	if (!i)
 		return -ENOMEM;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->real_parent, KSTATE_CTX_TASK_STRUCT);
+	if (tmp)
+		i->ref_real_parent = tmp->o_ref;
+	else
+		/* Root of hierarchy to be checkpointed. */
+		i->ref_real_parent = KSTATE_REF_UNDEF;
+
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->mm, KSTATE_CTX_MM_STRUCT);
 	i->ref_mm = tmp->o_ref;
 
@@ -206,7 +232,20 @@ static int task_struct_restorer(void *_tsk_ctx)
 	pr_debug("%s: ENTER tsk %p/%s\n", __func__, tsk, tsk->comm);
 
 	write_lock_irq(&tasklist_lock);
-	real_parent = ctx->init_tsk->nsproxy->pid_ns->child_reaper;
+	if (kstate_ref_undefined(&i->ref_real_parent))
+		real_parent = ctx->init_tsk->nsproxy->pid_ns->child_reaper;
+	else {
+		struct kstate_object *tmp;
+
+		/* Parent as task_struct should be restored already. */
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_real_parent, KSTATE_CTX_TASK_STRUCT);
+		if (!tmp) {
+			write_unlock_irq(&tasklist_lock);
+			rv = -EINVAL;
+			goto out;
+		}
+		real_parent = tmp->o_obj;
+	}
 	tsk->real_parent = tsk->parent = real_parent;
 	list_move_tail(&tsk->sibling, &tsk->real_parent->sibling);
 	write_unlock_irq(&tasklist_lock);
-- 
1.5.6.5
