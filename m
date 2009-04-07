From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 36/36] Stub implementation of IPC namespace c/r
Date: Tue,  7 Apr 2009 08:27:44 -0400
Message-ID: <1239107264-21775-37-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changes:
 - Update to match UTS changes

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    2 -
 checkpoint/ckpt_task.c         |   20 ++++++++++++++++--
 checkpoint/objhash.c           |    7 ++++++
 checkpoint/rstr_task.c         |   42 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    2 +
 6 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index d3661b1..7382cc3 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -258,8 +258,6 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 		return -EINVAL;
 
 	rcu_read_lock();
-	if (task_nsproxy(t)->ipc_ns != ctx->root_nsproxy->ipc_ns)
-		ret = -EPERM;
 	if (task_nsproxy(t)->mnt_ns != ctx->root_nsproxy->mnt_ns)
 		ret = -EPERM;
 	if (task_nsproxy(t)->pid_ns != ctx->root_nsproxy->pid_ns)
diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index fb82b0b..b5e330b 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -13,6 +13,7 @@
 #include <linux/futex.h>
 #include <linux/poll.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -205,7 +206,7 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 	struct cr_hdr h;
 	struct cr_hdr_namespaces *hh;
 	struct nsproxy *nsproxy;
-	int new_uts;
+	int new_uts, new_ipc;
 	int ret;
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
@@ -226,24 +227,37 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 		ret = new_uts;
 		goto out;
 	}
+	new_ipc = cr_obj_add_ptr(ctx, nsproxy->ipc_ns,
+				 &hh->ipc_ref, CR_OBJ_IPCNS, 0);
+	if (new_ipc < 0) {
+		ret = new_ipc;
+		goto out;
+	}
 
 	hh->flags = 0;
 	if (new_uts)
 		hh->flags |= CLONE_NEWUTS;
+	if (new_ipc)
+		hh->flags |= CLONE_NEWIPC;
 
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret < 0)
 		goto out;
 
 	if (new_uts) {
-		ret = cr_write_utsns(ctx, nsp->uts_ns);
+		ret = cr_write_utsns(ctx, nsproxy->uts_ns);
+		if (ret < 0)
+			goto out;
+	}
+	if (new_ipc) {
+		/* ret = cr_write_ipcns(ctx, nsproxy->ipc_ns); */ ret = 0;
 		if (ret < 0)
 			goto out;
 	}
 
 	/* FIX: Write other namespaces here */
  out:
-	put_nsproxy(nsp);
+	put_nsproxy(nsproxy);
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
 }
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 1082713..2ffa098 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -12,6 +12,7 @@
 #include <linux/file.h>
 #include <linux/hash.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 
 struct cr_objref {
@@ -45,6 +46,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		put_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		put_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -68,6 +72,9 @@ static int cr_obj_ref_grab(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		get_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		get_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
index 13bc056..520c15a 100644
--- a/checkpoint/rstr_task.c
+++ b/checkpoint/rstr_task.c
@@ -13,6 +13,7 @@
 #include <linux/futex.h>
 #include <linux/poll.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -233,6 +234,41 @@ static int cr_restore_utsns(struct cr_ctx *ctx, int ref, int flags)
 	return ret;
 }
 
+static int cr_restore_ipcns(struct cr_ctx *ctx, int ref, int flags)
+{
+	struct ipc_namespace *ipc_ns, *oldipc_ns;
+	int ret;
+
+	ipc_ns = cr_obj_get_by_ref(ctx, ref, CR_OBJ_IPCNS);
+	if (IS_ERR(ipc_ns)) {
+		cr_debug("failed to get IPC ns from objhash\n");
+		return PTR_ERR(ipc_ns);
+	}
+
+	if (!!ipc_ns ^ !(flags & CLONE_NEWIPC))
+		return -EINVAL;
+
+	if (!ipc_ns) {
+		/* ret = cr_read_ipcns(ctx, current); */ ret = 0;
+		if (ret < 0)
+			return ret;
+
+		ret = cr_obj_add_ref(ctx, current->nsproxy->ipc_ns,
+				     ref, CR_OBJ_IPCNS, 0);
+	} else {
+		ret = copy_namespaces(CLONE_NEWIPC, current);
+		if (ret < 0)
+			return ret;
+
+		oldipc_ns = current->nsproxy->ipc_ns;
+		current->nsproxy->ipc_ns = ipc_ns;
+		get_ipc_ns(ipc_ns);
+		put_ipc_ns(oldipc_ns);
+	}
+
+	return ret;
+}
+
 static int cr_read_namespaces(struct cr_ctx *ctx)
 {
 	struct cr_hdr_namespaces *hh;
@@ -247,7 +283,7 @@ static int cr_read_namespaces(struct cr_ctx *ctx)
 		goto out;
 
 	ret = -EINVAL;
-	if (hh->flags & ~CLONE_NEWUTS)
+	if (hh->flags & ~(CLONE_NEWUTS | CLONE_NEWIPC))
 		goto out;
 
 	/* each unseen-before namespace will be un-shared now */
@@ -266,6 +302,10 @@ static int cr_read_namespaces(struct cr_ctx *ctx)
 	cr_debug("uts ns: %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_restore_ipcns(ctx, hh->ipc_ref, hh->flags);
+	cr_debug("ipc ns: %d\n", ret);
+	if (ret < 0)
+		goto out;
 
 	/* FIX: add more namespaces here */
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index f821283..1999639 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -79,6 +79,7 @@ enum {
 	CR_OBJ_INODE,
 	CR_OBJ_MM,
 	CR_OBJ_UTSNS,
+	CR_OBJ_IPCNS,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 212c95f..5e923c3 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -51,6 +51,7 @@ enum {
 	CR_HDR_CPU,
 	CR_HDR_NS,
 	CR_HDR_UTSNS,
+	CR_HDR_IPCNS,
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
@@ -136,6 +137,7 @@ enum restart_block_type {
 struct cr_hdr_namespaces {
 	__u32 flags;
 	__u32 uts_ref;
+	__u32 ipc_ref;
 } __attribute__((aligned(8)));
 
 struct cr_hdr_utsns {
-- 
1.5.4.3
