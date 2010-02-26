From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/12] Move nsproxy checkpoint ops
Date: Fri, 26 Feb 2010 00:45:05 -0800
Message-ID: <e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 checkpoint/objhash.c       |   27 ---------------------------
 include/linux/checkpoint.h |    2 --
 kernel/nsproxy.c           |   40 ++++++++++++++++++++++++++++++++++++++--
 3 files changed, 38 insertions(+), 31 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 999d731..e2c2ce3 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -144,22 +144,6 @@ static int obj_sighand_users(void *ptr)
 	return atomic_read(&((struct sighand_struct *) ptr)->count);
 }
 
-static int obj_ns_grab(void *ptr)
-{
-	get_nsproxy((struct nsproxy *) ptr);
-	return 0;
-}
-
-static void obj_ns_drop(void *ptr, int lastref)
-{
-	put_nsproxy((struct nsproxy *) ptr);
-}
-
-static int obj_ns_users(void *ptr)
-{
-	return atomic_read(&((struct nsproxy *) ptr)->count);
-}
-
 static int obj_uts_ns_grab(void *ptr)
 {
 	get_uts_ns((struct uts_namespace *) ptr);
@@ -405,16 +389,6 @@ static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
 	.ref_drop = NULL,
 	.ref_grab = NULL,
 };
-/* ns object */
-static const struct ckpt_obj_ops ckpt_obj_nsproxy_ops = {
-	.obj_name = "NSPROXY",
-	.obj_type = CKPT_OBJ_NS,
-	.ref_drop = obj_ns_drop,
-	.ref_grab = obj_ns_grab,
-	.ref_users = obj_ns_users,
-	.checkpoint = checkpoint_ns,
-	.restore = restore_ns,
-};
 /* uts_ns object */
 static const struct ckpt_obj_ops ckpt_obj_uts_ns_ops = {
 	.obj_name = "UTS_NS",
@@ -536,7 +510,6 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
 	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
 	[CKPT_OBJ_SIGHAND] = &ckpt_obj_sighand_ops,
 	[CKPT_OBJ_SIGNAL] = &ckpt_obj_signal_ops,
-	[CKPT_OBJ_NS] = &ckpt_obj_nsproxy_ops,
 	[CKPT_OBJ_UTS_NS] = &ckpt_obj_uts_ns_ops,
 	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
 	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e4d668a..1f487a8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -202,8 +202,6 @@ extern int restore_restart_block(struct ckpt_ctx *ctx);
 
 /* namespaces */
 extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
-extern void *restore_ns(struct ckpt_ctx *ctx);
 
 /* uts-ns */
 extern int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 0da0d83..746edaf 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -301,7 +301,7 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 }
 
 
-int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
+static int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
 {
 	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
 }
@@ -374,15 +374,51 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	return nsproxy;
 }
 
-void *restore_ns(struct ckpt_ctx *ctx)
+static void *restore_ns(struct ckpt_ctx *ctx)
 {
 	return (void *) do_restore_ns(ctx);
 }
+
+static int obj_ns_grab(void *ptr)
+{
+	get_nsproxy((struct nsproxy *) ptr);
+	return 0;
+}
+
+static void obj_ns_drop(void *ptr, int lastref)
+{
+	put_nsproxy((struct nsproxy *) ptr);
+}
+
+static int obj_ns_users(void *ptr)
+{
+	return atomic_read(&((struct nsproxy *) ptr)->count);
+}
+
+/* ns object */
+static const struct ckpt_obj_ops ckpt_obj_nsproxy_ops = {
+	.obj_name = "NSPROXY",
+	.obj_type = CKPT_OBJ_NS,
+	.ref_drop = obj_ns_drop,
+	.ref_grab = obj_ns_grab,
+	.ref_users = obj_ns_users,
+	.checkpoint = checkpoint_ns,
+	.restore = restore_ns,
+};
+
+static inline void register_nsproxy_checkpoint(void)
+{
+	register_checkpoint_obj(&ckpt_obj_nsproxy_ops);
+}
+#else
+static inline void register_nsproxy_checkpoint(void)
+{}
 #endif /* CONFIG_CHECKPOINT */
 
 static int __init nsproxy_cache_init(void)
 {
 	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
+	register_nsproxy_checkpoint();
 	return 0;
 }
 
-- 
1.6.3.3
