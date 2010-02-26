From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/12] Move signal ckpt_obj_ops into kernel/signal.c
Date: Fri, 26 Feb 2010 00:45:09 -0800
Message-ID: <385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c       |   36 ---------------------------------
 include/linux/checkpoint.h |    2 -
 include/linux/signal.h     |    2 -
 kernel/signal.c            |   48 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 46 insertions(+), 42 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ce89066..cdbb1f1 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -112,22 +112,6 @@ static int obj_fs_users(void *ptr)
 	return ((struct fs_struct *) ptr)->users;
 }
 
-static int obj_sighand_grab(void *ptr)
-{
-	atomic_inc(&((struct sighand_struct *) ptr)->count);
-	return 0;
-}
-
-static void obj_sighand_drop(void *ptr, int lastref)
-{
-	__cleanup_sighand((struct sighand_struct *) ptr);
-}
-
-static int obj_sighand_users(void *ptr)
-{
-	return atomic_read(&((struct sighand_struct *) ptr)->count);
-}
-
 static int obj_uts_ns_grab(void *ptr)
 {
 	get_uts_ns((struct uts_namespace *) ptr);
@@ -346,23 +330,6 @@ static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
 	.checkpoint = checkpoint_fs,
 	.restore = restore_fs,
 };
-/* sighand object */
-static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
-	.obj_name = "SIGHAND",
-	.obj_type = CKPT_OBJ_SIGHAND,
-	.ref_drop = obj_sighand_drop,
-	.ref_grab = obj_sighand_grab,
-	.ref_users = obj_sighand_users,
-	.checkpoint = checkpoint_sighand,
-	.restore = restore_sighand,
-};
-/* signal object */
-static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
-	.obj_name = "SIGNAL",
-	.obj_type = CKPT_OBJ_SIGNAL,
-	.ref_drop = NULL,
-	.ref_grab = NULL,
-};
 /* uts_ns object */
 static const struct ckpt_obj_ops ckpt_obj_uts_ns_ops = {
 	.obj_name = "UTS_NS",
@@ -481,8 +448,6 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
 	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
 	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
 	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
-	[CKPT_OBJ_SIGHAND] = &ckpt_obj_sighand_ops,
-	[CKPT_OBJ_SIGNAL] = &ckpt_obj_signal_ops,
 	[CKPT_OBJ_UTS_NS] = &ckpt_obj_uts_ns_ops,
 	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
 	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
@@ -501,7 +466,6 @@ void register_checkpoint_obj(const struct ckpt_obj_ops *ops)
 	ckpt_obj_ops[ops->obj_type] = ops;
 }
 
-
 #define CKPT_OBJ_HASH_NBITS  10
 #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1f487a8..7a06272 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -308,8 +308,6 @@ extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
 
 extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
-extern void *restore_sighand(struct ckpt_ctx *ctx);
 
 extern int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 4a19f62..6d3b0e1 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -380,11 +380,9 @@ int task_has_saved_sigmask(struct task_struct *task);
 
 struct ckpt_ctx;
 int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
-int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
 int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
 int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
-void *restore_sighand(struct ckpt_ctx *ctx);
 int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
 int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
 int restore_task_signal(struct ckpt_ctx *ctx);
diff --git a/kernel/signal.c b/kernel/signal.c
index b5b5abb..362b7b5 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2727,6 +2727,7 @@ __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma)
 
 #ifdef CONFIG_CHECKPOINT
 /* default debug level for output */
+#undef CKPT_DFLAG
 #define CKPT_DFLAG  CKPT_DSYS
 
 static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
@@ -2773,7 +2774,7 @@ static int do_checkpoint_sighand(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
+static int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
 {
 	return do_checkpoint_sighand(ctx, (struct sighand_struct *) ptr);
 }
@@ -2843,7 +2844,7 @@ static struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
 	return sighand;
 }
 
-void *restore_sighand(struct ckpt_ctx *ctx)
+static void *restore_sighand(struct ckpt_ctx *ctx)
 {
 	return (void *) do_restore_sighand(ctx);
 }
@@ -3439,9 +3440,52 @@ int restore_task_signal(struct ckpt_ctx *ctx)
 	ckpt_hdr_put(ctx, h);
 	return 0;
 }
+
+static int obj_sighand_grab(void *ptr)
+{
+	atomic_inc(&((struct sighand_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_sighand_drop(void *ptr, int lastref)
+{
+	__cleanup_sighand((struct sighand_struct *) ptr);
+}
+
+static int obj_sighand_users(void *ptr)
+{
+	return atomic_read(&((struct sighand_struct *) ptr)->count);
+}
+
+/* sighand object */
+static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
+	.obj_name = "SIGHAND",
+	.obj_type = CKPT_OBJ_SIGHAND,
+	.ref_drop = obj_sighand_drop,
+	.ref_grab = obj_sighand_grab,
+	.ref_users = obj_sighand_users,
+	.checkpoint = checkpoint_sighand,
+	.restore = restore_sighand,
+};
+
+/* signal object */
+static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
+	.obj_name = "SIGNAL",
+	.obj_type = CKPT_OBJ_SIGNAL,
+};
+
+static inline void register_signal_checkpoint(void)
+{
+	register_checkpoint_obj(&ckpt_obj_sighand_ops);
+	register_checkpoint_obj(&ckpt_obj_signal_ops);
+}
+#else
+static inline void register_signal_checkpoint(void)
+{}
 #endif /* CONFIG_CHECKPOINT */
 
 void __init signals_init(void)
 {
 	sigqueue_cachep = KMEM_CACHE(sigqueue, SLAB_PANIC);
+	register_signal_checkpoint();
 }
-- 
1.6.3.3
