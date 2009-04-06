From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] Stub implementation of IPC namespace c/r (v3)
Date: Mon,  6 Apr 2009 09:05:56 -0700
Message-ID: <1239033956-25898-4-git-send-email-danms@us.ibm.com>
References: <1239033956-25898-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239033956-25898-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Changes:
 - Update to match UTS changes
 - Change ipc to newipc
 - Check return value of cr_hbuf_get()

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   30 ++++++++++++++++++++++++
 checkpoint/objhash.c           |    7 +++++
 checkpoint/restart.c           |   49 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    6 +++++
 5 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ae0d3f8..2212e21 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -243,6 +243,24 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct new_utsname *name)
 	return ret;
 }
 
+static int cr_write_ipcns(struct cr_ctx *ctx, struct ipc_namespace *ipc)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipcns *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	if (!hh)
+		return -ENOMEM;
+
+	h.type = CR_HDR_IPCNS;
+	h.len = sizeof(*hh);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
 static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
@@ -250,6 +268,7 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 	struct nsproxy *nsp = t->nsproxy;
 	int ret;
 	int newuts;
+	int newipc;
 
 	if (!hh)
 		return -ENOMEM;
@@ -262,6 +281,11 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 	if (newuts < 0)
 		goto out;
 
+	newipc = cr_obj_add_ptr(ctx, nsp->ipc_ns, &hh->ipc_ref,
+				CR_OBJ_IPCNS, 0);
+	if (newipc < 0)
+		goto out;
+
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret)
 		goto out;
@@ -272,6 +296,12 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 			goto out;
 	}
 
+	if (newipc) {
+		ret = cr_write_ipcns(ctx, nsp->ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
+
 	/* FIXME: Write other namespaces here */
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index c6ae7c1..b04f8df 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,7 @@
 #include <linux/hash.h>
 #include <linux/checkpoint.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 
 struct cr_objref {
 	int objref;
@@ -42,6 +43,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		put_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		put_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -62,6 +66,9 @@ static int cr_obj_ref_grab(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		get_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		get_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 1767460..3cb6786 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -16,6 +16,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 #include <linux/syscalls.h>
 
 #include "checkpoint_arch.h"
@@ -324,6 +325,49 @@ static int cr_restore_utsns(struct cr_ctx *ctx, int ref)
 	return 0;
 }
 
+static int cr_read_ipcns(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr_ipcns hh;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, &hh, sizeof(hh), CR_HDR_IPCNS);
+	if (ret < 0)
+		return ret;
+
+	/* FIXME: Implement this */
+
+	return 0;
+}
+
+static int cr_restore_ipcns(struct cr_ctx *ctx, int ref)
+{
+	struct ipc_namespace *ipc;
+	int ret;
+
+	ipc = cr_obj_get_by_ref(ctx, ref, CR_OBJ_IPCNS);
+	if (ipc == NULL) {
+		ret = cr_read_ipcns(ctx, current);
+		if (ret < 0)
+			return ret;
+
+		return cr_obj_add_ref(ctx, current->nsproxy->ipc_ns,
+				      ref, CR_OBJ_IPCNS, 0);
+	} else if (IS_ERR(ipc)) {
+		cr_debug("Failed to get IPC ns from objhash\n");
+		return PTR_ERR(ipc);
+	}
+
+	ret = copy_namespaces(CLONE_NEWIPC, current);
+	if (ret < 0)
+		return ret;
+
+	put_ipc_ns(current->nsproxy->ipc_ns);
+	get_ipc_ns(ipc);
+	current->nsproxy->ipc_ns = ipc;
+
+	return 0;
+}
+
 static int cr_read_namespaces(struct cr_ctx *ctx)
 {
 	struct cr_hdr_namespaces hh;
@@ -338,6 +382,11 @@ static int cr_read_namespaces(struct cr_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ret = cr_restore_ipcns(ctx, hh.ipc_ref);
+	cr_debug("ipc ns: %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	/* FIXME: Add more namespaces here */
 
 	return 0;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index cf20746..ba66bcf 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -76,6 +76,7 @@ enum {
 	CR_OBJ_FILE = 1,
 	CR_OBJ_INODE,
 	CR_OBJ_UTSNS,
+	CR_OBJ_IPCNS,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 97f5761..3ebbfd5 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -50,6 +50,7 @@ enum {
 	CR_HDR_CPU,
 	CR_HDR_NS,
 	CR_HDR_UTSNS,
+	CR_HDR_IPCNS,
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
@@ -188,6 +189,7 @@ struct cr_hdr_fd_pipe {
 
 struct cr_hdr_namespaces {
 	__u32 uts_ref;
+	__u32 ipc_ref;
 };
 
 struct cr_hdr_utsns {
@@ -195,4 +197,8 @@ struct cr_hdr_utsns {
 	__u32 domainname_len;
 };
 
+struct cr_hdr_ipcns {
+	/* FIXME: Fill this in */
+};
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.6.3
