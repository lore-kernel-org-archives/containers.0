From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] c/r: Add (dummy) IPC support
Date: Mon, 23 Mar 2009 12:32:23 -0700
Message-ID: <1237836743-20262-3-git-send-email-danms@us.ibm.com>
References: <1237836743-20262-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237836743-20262-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Based on Serge's suggestion, this is a stub implementation of IPC support.
It defines the header object for the c/r stream and the bits in
cr_write_namespaces() to do the work.  It just needs someone to fill in
the details.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   28 ++++++++++++++++++++++++++++
 checkpoint/objhash.c           |    7 +++++++
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    6 ++++++
 4 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 466f1bd..9675daa 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -222,6 +222,23 @@ static int cr_write_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int cr_write_ns_ipc(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipcns *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_IPCNS;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	ret = cr_write_obj(ctx, &h, hh);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
 static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 {
 	struct cr_hdr h;
@@ -229,6 +246,7 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 	struct nsproxy *nsp = t->nsproxy;
 	int ret;
 	int uts;
+	int ipc;
 
 	h.type = CR_HDR_NS;
 	h.len = sizeof(*hh);
@@ -238,6 +256,10 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 	if (uts < 0)
 		goto out;
 
+	ipc = cr_obj_add_ptr(ctx, nsp->ipc_ns, &hh->ipc_ref, CR_OBJ_IPCNS, 0);
+	if (ipc < 0)
+		goto out;
+
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret)
 		goto out;
@@ -248,6 +270,12 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 			goto out;
 	}
 
+	if (ipc) {
+		ret = cr_write_ns_ipc(ctx, t);
+		if (ret < 0)
+			goto out;
+	}
+
 	/* FIXME: Write other namespaces here */
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index afcf1d1..0d40aeb 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,7 @@
 #include <linux/hash.h>
 #include <linux/checkpoint.h>
 #include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
 
 struct cr_objref {
 	int objref;
@@ -39,6 +40,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		put_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		put_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -53,6 +57,9 @@ static void cr_obj_ref_grab(struct cr_objref *obj)
 	case CR_OBJ_UTSNS:
 		get_uts_ns((struct uts_namespace *) obj->ptr);
 		break;
+	case CR_OBJ_IPCNS:
+		get_ipc_ns((struct ipc_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 02c2990..2f73734 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -76,6 +76,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
 enum {
 	CR_OBJ_FILE = 1,
 	CR_OBJ_UTSNS,
+	CR_OBJ_IPCNS,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 172ff7f..34c737b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -51,6 +51,7 @@ enum {
 	CR_HDR_CPU,
 	CR_HDR_NS,
 	CR_HDR_UTSNS,
+	CR_HDR_IPCNS,
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
@@ -159,9 +160,11 @@ struct cr_hdr_fd_data {
 } __attribute__((aligned(8)));
 
 #define CR_NS_UTS 1
+#define CR_NS_IPC 2
 
 struct cr_hdr_namespaces {
 	__u32 uts_ref; /* Objref of matching UTS namespace */
+	__u32 ipc_ref; /* Objref of matching IPC namespace */
 };
 
 struct cr_hdr_utsns {
@@ -169,4 +172,7 @@ struct cr_hdr_utsns {
 	__u32 domainname_len;
 };
 
+struct cr_hdr_ipcns {
+};
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.6.3
