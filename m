From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] c/r: Add UTS support
Date: Thu, 12 Mar 2009 10:56:52 -0700
Message-ID: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

(apologies if you see this multiple times...IBM mail server troubles)

This patch adds a "phase" of c/r that saves out information about any
namespaces the task(s) may have.  Do this by tracking the nsproxy of the
first task and making sure that the tasks that follow get hooked back to
share the same one on restart.  On restart, we also explicitly create new
namespaces for any that we support at the first task.

I tested this with single and multiple task restore, on top of Oren's
v13 tree.

This is intended to get some discussion going about how to c/r the various
namespaces.  So, if this approach isn't favorable, speak up with some
suggestions for how to do it better.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   57 ++++++++++++++++++++++++++
 checkpoint/objhash.c           |    7 +++
 checkpoint/restart.c           |   87 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |   15 +++++++
 5 files changed, 167 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 64155de..a613f2d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -193,6 +193,59 @@ static int cr_write_tail(struct cr_ctx *ctx)
 	return ret;
 }
 
+static int cr_write_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct new_utsname *n = &t->nsproxy->uts_ns->name;
+	int ret;
+
+	h.type = CR_HDR_UTSNS;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	memcpy(hh->nodename, n->nodename, sizeof(n->nodename));
+	memcpy(hh->domainname, n->domainname, sizeof(n->domainname));
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_nsproxy *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct nsproxy *nsp = t->nsproxy;
+	int ret;
+	int new;
+
+	h.type = CR_HDR_NSP;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	new = cr_obj_add_ptr(ctx, nsp, &hh->objref, CR_OBJ_NSP, 0);
+	if (new)
+		hh->types = CR_NSP_UTS; /* Record types we support */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret)
+		goto out;
+
+	if (new) {
+		ret = cr_write_ns_uts(ctx, t);
+		if (ret < 0)
+			goto out;
+
+		/* FIXME: Write other namespaces here */
+	}
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
 /* dump the task_struct of a given task */
 static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -230,6 +283,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	pr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_namespaces(ctx, t);
+	pr_debug("namespaces: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_mm(ctx, t);
 	pr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index ee31b38..aaaf583 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -12,6 +12,7 @@
 #include <linux/file.h>
 #include <linux/hash.h>
 #include <linux/checkpoint.h>
+#include <linux/utsname.h>
 
 struct cr_objref {
 	int objref;
@@ -35,6 +36,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_FILE:
 		fput((struct file *) obj->ptr);
 		break;
+	case CR_OBJ_NSP:
+		put_nsproxy((struct nsproxy *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -46,6 +50,9 @@ static void cr_obj_ref_grab(struct cr_objref *obj)
 	case CR_OBJ_FILE:
 		get_file((struct file *) obj->ptr);
 		break;
+	case CR_OBJ_NSP:
+		get_nsproxy((struct nsproxy *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 7ec4de4..513d772 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -15,6 +15,7 @@
 #include <linux/magic.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/utsname.h>
 
 #include "checkpoint_arch.h"
 
@@ -213,6 +214,88 @@ static int cr_read_tail(struct cr_ctx *ctx)
 	return ret;
 }
 
+/* Read the new UTS namespace record and adjust uts_ns accordingly */
+static int cr_read_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct new_utsname *n = &t->nsproxy->uts_ns->name;
+	int ret = 0;
+	int parent;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_UTSNS);
+	if (parent != 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	memset(n->nodename, 0, sizeof(n->nodename));
+	memcpy(n->nodename, hh->nodename, sizeof(n->nodename)-1);
+
+	memset(n->domainname, 0, sizeof(n->nodename));
+	memcpy(n->domainname, hh->domainname, sizeof(n->domainname)-1);
+
+	pr_debug("read uts_ns: nn=%s dn=%s\n", n->nodename, n->domainname);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+/* Convert our type flags to CLONE flags */
+static unsigned long cr_ns_clone_flags(unsigned long types)
+{
+	unsigned long flags = 0;
+
+	if (types & CR_NSP_UTS)
+		flags |= CLONE_NEWUTS;
+
+	return flags;
+}
+
+/* Read namespace records for this task */
+static int cr_read_namespaces(struct cr_ctx *ctx)
+{
+	struct cr_hdr_nsproxy *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct task_struct *t = current;
+	struct nsproxy *nsp;
+	int parent;
+	int ret = 0;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_NSP);
+	if (parent != 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	nsp = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_NSP);
+	if (nsp != NULL) {
+		t->nsproxy = nsp;
+		goto out;
+	}
+
+	if (hh->types == 0)
+		goto out; /* No namespaces to read */
+
+	/* Get the obligatory new set of namespaces */
+	ret = copy_namespaces(cr_ns_clone_flags(hh->types), t);
+	if (ret)
+		goto out;
+
+	ret = cr_obj_add_ref(ctx, t->nsproxy,
+			     hh->objref, CR_OBJ_NSP, 0);
+	if (ret)
+		goto out;
+
+	if (hh->types & CR_NSP_UTS)
+		ret = cr_read_ns_uts(ctx, t);
+
+	/* FIXME: Read other namespaces here */
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
 /* read the task_struct into the current task */
 static int cr_read_task_struct(struct cr_ctx *ctx)
 {
@@ -258,6 +341,10 @@ static int cr_read_task(struct cr_ctx *ctx)
 	pr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_namespaces(ctx);
+	pr_debug("namespaces: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_read_mm(ctx);
 	pr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 217cf6e..5966275 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -75,6 +75,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
 
 enum {
 	CR_OBJ_FILE = 1,
+	CR_OBJ_NSP,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 6dc739f..1413572 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -49,6 +49,8 @@ enum {
 	CR_HDR_TASK,
 	CR_HDR_THREAD,
 	CR_HDR_CPU,
+	CR_HDR_NSP,
+	CR_HDR_UTSNS,
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
@@ -156,4 +158,17 @@ struct cr_hdr_fd_data {
 	__u64 f_version;
 } __attribute__((aligned(8)));
 
+#define CR_NSP_UTS 1
+
+struct cr_hdr_nsproxy {
+	__u32 objref;
+	__u32 types;
+};
+
+struct cr_hdr_utsns {
+	/* Both of these fields are defined as 65-chars long */
+	char nodename[65];
+	char domainname[65];
+};
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.6.3
