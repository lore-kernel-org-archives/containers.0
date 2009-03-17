From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Add UTS support (v3)
Date: Tue, 17 Mar 2009 09:08:59 -0700
Message-ID: <1237306139-23075-1-git-send-email-danms@us.ibm.com>
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
Cc: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the nsproxy of the
first task and making sure that the tasks that follow get hooked back to
share the same one on restart.

Restart is handled in userspace by reading the UTS record(s), calling
unshare() and setting the hostname accordingly.  See my changes to
mktree.c for details.

I tested this with single and multiple task restore, on top of Oren's
v13 tree.

Changes:
  - Remove the kernel restore path
  - Punt on nested namespaces
  - Use __NEW_UTS_LEN in nodename and domainname buffers
  - Add a note to Documentation/checkpoint/internals.txt to indicate where
    in the save/restore process the UTS information is kept

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/checkpoint/internals.txt |    2 +
 checkpoint/checkpoint.c                |   80 ++++++++++++++++++++++++++++++++
 checkpoint/objhash.c                   |    7 +++
 checkpoint/restart.c                   |    1 +
 include/linux/checkpoint.h             |    1 +
 include/linux/checkpoint_hdr.h         |   15 ++++++
 6 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
index b363e83..7a2488b 100644
--- a/Documentation/checkpoint/internals.txt
+++ b/Documentation/checkpoint/internals.txt
@@ -12,6 +12,8 @@ The order of operations, both save and restore, is as follows:
 
 * Process forest: [TBD] tasks and their relationships
 
+* Namespace section: per-container namespace information
+
 * Per task data (for each task):
   -> task state: elements of task_struct
   -> thread state: elements of thread_struct and thread_info
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 64155de..12eb1d5 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -193,6 +193,82 @@ static int cr_write_tail(struct cr_ctx *ctx)
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
+	if (nsp != ctx->root_nsproxy) {
+		/* Don't allow checkpoint of nested namespaces yet */
+		pr_debug("Task has different nsproxy than root\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	h.type = CR_HDR_NSP;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	new = cr_obj_add_ptr(ctx, nsp, &hh->objref, CR_OBJ_NSP, 0);
+	if (new)
+		hh->types = CR_NSP_UTS; /* Record types we support */
+	else
+		hh->types = 0;
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
+static int cr_write_all_namespaces(struct cr_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->tasks_nr; n++) {
+		pr_debug("dumping ns for task #%d\n", n);
+		ret = cr_write_namespaces(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
 /* dump the task_struct of a given task */
 static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -549,6 +625,10 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	ret = cr_write_all_namespaces(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = cr_write_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
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
index 7ec4de4..0ed01aa 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -15,6 +15,7 @@
 #include <linux/magic.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/utsname.h>
 
 #include "checkpoint_arch.h"
 
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
index 6dc739f..1a2fc81 100644
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
+	char nodename[__NEW_UTS_LEN+1];
+	char domainname[__NEW_UTS_LEN+1];
+};
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.6.3
