From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/12] Move uts ns into kernel/utsname*.c
Date: Fri, 26 Feb 2010 00:45:11 -0800
Message-ID: <a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
	<c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Unlike other checkpoint object ops we're moving out of checkpoint/objhash.c,
the one for uts namespaces needs to be defined even if CONFIG_UTS_NS is not.
Because the definitions used in kernel/utsname_sysctl.c can come from
kernel/utsname.c, we declare them in include/linux/utsname.h. If the
definitions are missing then utsname_sysctl.c defines its own.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/namespace.c     |   82 --------------------------------------
 checkpoint/objhash.c       |   27 -------------
 include/linux/checkpoint.h |    4 --
 include/linux/utsname.h    |   11 +++++
 kernel/utsname.c           |   85 ++++++++++++++++++++++++++++++++++++++++
 kernel/utsname_sysctl.c    |   93 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 189 insertions(+), 113 deletions(-)

diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
index 4b3ac5a..538bd4a 100644
--- a/checkpoint/namespace.c
+++ b/checkpoint/namespace.c
@@ -18,88 +18,6 @@
 #include <linux/checkpoint_hdr.h>
 
 /*
- * uts_ns  -  this needs to compile even for !CONFIG_UTS_NS, so
- *   the code may not reside in kernel/utsname.c (which wouldn't
- *   compile then).
- */
-static int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
-				struct uts_namespace *uts_ns)
-{
-	struct ckpt_hdr_utsns *h;
-	struct new_utsname *name;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
-	if (!h)
-		return -ENOMEM;
-
-	down_read(&uts_sem);
-	name = &uts_ns->name;
-	memcpy(h->sysname, name->sysname, sizeof(name->sysname));
-	memcpy(h->nodename, name->nodename, sizeof(name->nodename));
-	memcpy(h->release, name->release, sizeof(name->release));
-	memcpy(h->version, name->version, sizeof(name->version));
-	memcpy(h->machine, name->machine, sizeof(name->machine));
-	memcpy(h->domainname, name->domainname, sizeof(name->domainname));
-	up_read(&uts_sem);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr)
-{
-	return do_checkpoint_uts_ns(ctx, (struct uts_namespace *) ptr);
-}
-
-static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_utsns *h;
-	struct uts_namespace *uts_ns = NULL;
-	struct new_utsname *name;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
-	if (IS_ERR(h))
-		return (struct uts_namespace *) h;
-
-#ifdef CONFIG_UTS_NS
-	uts_ns = create_uts_ns();
-	if (!uts_ns) {
-		uts_ns = ERR_PTR(-ENOMEM);
-		goto out;
-	}
-	down_read(&uts_sem);
-	name = &uts_ns->name;
-	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
-	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
-	memcpy(name->release, h->release, sizeof(name->release));
-	memcpy(name->version, h->version, sizeof(name->version));
-	memcpy(name->machine, h->machine, sizeof(name->machine));
-	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
-	up_read(&uts_sem);
-#else
-	/* complain if image contains multiple namespaces */
-	if (ctx->stats.uts_ns) {
-		uts_ns = ERR_PTR(-EEXIST);
-		goto out;
-	}
-	uts_ns = current->nsproxy->uts_ns;
-	get_uts_ns(uts_ns);
-#endif
-
-	ctx->stats.uts_ns++;
- out:
-	ckpt_hdr_put(ctx, h);
-	return uts_ns;
-}
-
-void *restore_uts_ns(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_uts_ns(ctx);
-}
-
-/*
  * user_ns  -  trivial checkpoint/restore for !CONFIG_USER_NS case
  */
 #ifndef CONFIG_USER_NS
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index cdbb1f1..5678943 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -112,22 +112,6 @@ static int obj_fs_users(void *ptr)
 	return ((struct fs_struct *) ptr)->users;
 }
 
-static int obj_uts_ns_grab(void *ptr)
-{
-	get_uts_ns((struct uts_namespace *) ptr);
-	return 0;
-}
-
-static void obj_uts_ns_drop(void *ptr, int lastref)
-{
-	put_uts_ns((struct uts_namespace *) ptr);
-}
-
-static int obj_uts_ns_users(void *ptr)
-{
-	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
-}
-
 static int obj_ipc_ns_grab(void *ptr)
 {
 	get_ipc_ns((struct ipc_namespace *) ptr);
@@ -330,16 +314,6 @@ static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
 	.checkpoint = checkpoint_fs,
 	.restore = restore_fs,
 };
-/* uts_ns object */
-static const struct ckpt_obj_ops ckpt_obj_uts_ns_ops = {
-	.obj_name = "UTS_NS",
-	.obj_type = CKPT_OBJ_UTS_NS,
-	.ref_drop = obj_uts_ns_drop,
-	.ref_grab = obj_uts_ns_grab,
-	.ref_users = obj_uts_ns_users,
-	.checkpoint = checkpoint_uts_ns,
-	.restore = restore_uts_ns,
-};
 /* ipc_ns object */
 static const struct ckpt_obj_ops ckpt_obj_ipc_ns_ops = {
 	.obj_name = "IPC_NS",
@@ -448,7 +422,6 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
 	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
 	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
 	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
-	[CKPT_OBJ_UTS_NS] = &ckpt_obj_uts_ns_ops,
 	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
 	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
 	[CKPT_OBJ_USER_NS] = &ckpt_obj_mnt_ns_ops,
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 0fc3f70..4a2b24b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -201,10 +201,6 @@ extern int restore_restart_block(struct ckpt_ctx *ctx);
 /* namespaces */
 extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
 
-/* uts-ns */
-extern int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr);
-extern void *restore_uts_ns(struct ckpt_ctx *ctx);
-
 /* ipc-ns */
 #ifdef CONFIG_SYSVIPC
 extern int checkpoint_ipc_ns(struct ckpt_ctx *ctx, void *ptr);
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 774001d..ce6fede 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -58,6 +58,17 @@ static inline void put_uts_ns(struct uts_namespace *ns)
 {
 	kref_put(&ns->kref, free_uts_ns);
 }
+
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+extern int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
+				struct uts_namespace *uts_ns);
+
+extern struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx);
+extern int obj_uts_ns_grab(void *ptr);
+extern void obj_uts_ns_drop(void *ptr, int lastref);
+extern int obj_uts_ns_users(void *ptr);
+#endif /* CONFIG_CHECKPOINT */
 #else
 static inline void get_uts_ns(struct uts_namespace *ns)
 {
diff --git a/kernel/utsname.c b/kernel/utsname.c
index c82ed83..865a6f4 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -74,3 +74,88 @@ void free_uts_ns(struct kref *kref)
 	ns = container_of(kref, struct uts_namespace, kref);
 	kfree(ns);
 }
+
+#ifdef CONFIG_CHECKPOINT
+/* default debug level for output */
+#undef CKPT_DFLAG
+#define CKPT_DFLAG  CKPT_DSYS
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * uts_ns  -  this needs to compile even for !CONFIG_UTS_NS, so
+ *   the code may not reside in kernel/utsname.c (which wouldn't
+ *   compile then).
+ */
+int do_checkpoint_uts_ns(struct ckpt_ctx *ctx, struct uts_namespace *uts_ns)
+{
+	struct ckpt_hdr_utsns *h;
+	struct new_utsname *name;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(h->sysname, name->sysname, sizeof(name->sysname));
+	memcpy(h->nodename, name->nodename, sizeof(name->nodename));
+	memcpy(h->release, name->release, sizeof(name->release));
+	memcpy(h->version, name->version, sizeof(name->version));
+	memcpy(h->machine, name->machine, sizeof(name->machine));
+	memcpy(h->domainname, name->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns = NULL;
+	struct new_utsname *name;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (struct uts_namespace *) h;
+
+	uts_ns = create_uts_ns();
+	if (!uts_ns) {
+		uts_ns = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
+	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
+	memcpy(name->release, h->release, sizeof(name->release));
+	memcpy(name->version, h->version, sizeof(name->version));
+	memcpy(name->machine, h->machine, sizeof(name->machine));
+	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+
+	ctx->stats.uts_ns++;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return uts_ns;
+}
+
+int obj_uts_ns_grab(void *ptr)
+{
+	get_uts_ns((struct uts_namespace *) ptr);
+	return 0;
+}
+
+void obj_uts_ns_drop(void *ptr, int lastref)
+{
+	put_uts_ns((struct uts_namespace *) ptr);
+}
+
+int obj_uts_ns_users(void *ptr)
+{
+	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
+}
+#endif /* CONFIG_CHECKPOINT */
diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index a2cd77e..774a0ec 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -13,6 +13,9 @@
 #include <linux/uts.h>
 #include <linux/utsname.h>
 #include <linux/sysctl.h>
+#include <linux/nsproxy.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 static void *get_uts(ctl_table *table, int write)
 {
@@ -57,6 +60,95 @@ static int proc_do_uts_string(ctl_table *table, int write,
 #define proc_do_uts_string NULL
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+/* default debug level for output */
+#undef CKPT_DFLAG
+#define CKPT_DFLAG  CKPT_DSYS
+
+#ifndef CONFIG_UTS_NS
+static int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
+				struct uts_namespace *uts_ns)
+{
+	struct ckpt_hdr_utsns *h;
+	struct new_utsname *name;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(h->sysname, name->sysname, sizeof(name->sysname));
+	memcpy(h->nodename, name->nodename, sizeof(name->nodename));
+	memcpy(h->release, name->release, sizeof(name->release));
+	memcpy(h->version, name->version, sizeof(name->version));
+	memcpy(h->machine, name->machine, sizeof(name->machine));
+	memcpy(h->domainname, name->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns = NULL;
+	struct new_utsname *name;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (struct uts_namespace *) h;
+
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.uts_ns) {
+		uts_ns = ERR_PTR(-EEXIST);
+		goto out;
+	}
+	uts_ns = current->nsproxy->uts_ns;
+	get_uts_ns(uts_ns);
+
+	ctx->stats.uts_ns++;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return uts_ns;
+}
+#endif
+
+static int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_uts_ns(ctx, (struct uts_namespace *) ptr);
+}
+
+static void *restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_uts_ns(ctx);
+}
+
+/* uts_ns object */
+static const struct ckpt_obj_ops ckpt_obj_uts_ns_ops = {
+	.obj_name = "UTS_NS",
+	.obj_type = CKPT_OBJ_UTS_NS,
+#ifdef CONFIG_UTS_NS
+	.ref_drop = obj_uts_ns_drop,
+	.ref_grab = obj_uts_ns_grab,
+	.ref_users = obj_uts_ns_users,
+#endif
+	.checkpoint = checkpoint_uts_ns,
+	.restore = restore_uts_ns,
+};
+
+static inline void register_utsname_checkpoint(void)
+{
+	register_checkpoint_obj(&ckpt_obj_uts_ns_ops);
+}
+#else
+static inline void register_utsname_checkpoint(void)
+{}
+#endif /* CONFIG_CHECKPOINT */
+
 static struct ctl_table uts_kern_table[] = {
 	{
 		.procname	= "ostype",
@@ -108,6 +200,7 @@ static struct ctl_table uts_root_table[] = {
 static int __init utsname_sysctl_init(void)
 {
 	register_sysctl_table(uts_root_table);
+	register_utsname_checkpoint();
 	return 0;
 }
 
-- 
1.6.3.3
