From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 37/54] c/r: Add UTS support (v6)
Date: Tue, 28 Apr 2009 19:24:07 -0400
Message-ID: <1240961064-13991-38-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes:
  - Take uts_sem around access to uts data
  - Remove the kernel restore path
  - Punt on nested namespaces
  - Use __NEW_UTS_LEN in nodename and domainname buffers
  - Add a note to Documentation/checkpoint/internals.txt to indicate where
    in the save/restore process the UTS information is kept
  - Store (and track) the objref of the namespace itself instead of the
    nsproxy (based on comments from Dave on IRC)
  - Remove explicit check for non-root nsproxy
  - Store the nodename and domainname lengths and use ckpt_write_string()
    to store the actual name strings
  - Catch failure of ckpt_obj_add_ptr() in ckpt_write_namespaces()
  - Remove "types" bitfield and use the "is this new" flag to determine
    whether or not we should write out a new ns descriptor
  - Replace kernel restore path
  - Move the namespace information to be directly after the task
    information record
  - Update Documentation to reflect new location of namespace info
  - Support checkpoint and restart of nested UTS namespaces

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Documentation/checkpoint/internals.txt |    1 +
 checkpoint/checkpoint.c                |    2 -
 checkpoint/objhash.c                   |   21 ++++
 checkpoint/process.c                   |  160 +++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h         |    9 ++
 5 files changed, 189 insertions(+), 4 deletions(-)

diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
index de2eead..41f0861 100644
--- a/Documentation/checkpoint/internals.txt
+++ b/Documentation/checkpoint/internals.txt
@@ -17,6 +17,7 @@ The order of operations, both save and restore, is as follows:
   -> thread state: elements of thread_struct and thread_info
   -> CPU state: registers etc, including FPU
   -> memory state: memory address space layout and contents
+  -> namespace information
   -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
   -> files state: open file descriptors and their state
   -> signals state: [TBD] pending signals and signal handling state
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 64b5b45..88dee51 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -218,8 +218,6 @@ static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
 	if (!nsproxy) {
 		ret = -ENOSYS;
 	} else {
-		if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
-			ret = -EPERM;
 		if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
 			ret = -EPERM;
 		if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 819a1be..abf2e47 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -59,6 +59,7 @@ void *restore_bad(struct ckpt_ctx *ctx)
  *   obj_inode_{drop,grab}: for inode objects
  *   obj_mm_{drop,grab}: for mm_struct objects
  *   obj_ns_{drop,grab}: for nsproxy objects
+ *   obj_uts_ns_{drop,grab}: for uts_namespace objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -115,6 +116,17 @@ static void obj_ns_drop(void *ptr)
 	put_nsproxy((struct nsproxy *) ptr);
 }
 
+static int obj_uts_ns_grab(void *ptr)
+{
+	get_uts_ns((struct uts_namespace *) ptr);
+	return 0;
+}
+
+static void obj_uts_ns_drop(void *ptr)
+{
+	put_uts_ns((struct uts_namespace *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -159,6 +171,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_ns,
 		.restore = restore_ns,
 	},
+	/* uts_ns object */
+	{
+		.obj_name = "UTS_NS",
+		.obj_type = CKPT_OBJ_UTS_NS,
+		.ref_drop = obj_uts_ns_drop,
+		.ref_grab = obj_uts_ns_grab,
+		.checkpoint = checkpoint_bad,
+		.restore = restore_bad,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 2c489fd..13dd48b 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -15,8 +15,11 @@
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/poll.h>
+#include <linux/nsproxy.h>
+#include <linux/utsname.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/syscalls.h>
 
 #include "checkpoint_arch.h"
 
@@ -162,10 +165,69 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int checkpoint_uts_ns(struct ckpt_ctx *ctx, struct uts_namespace *uts_ns)
+{
+	struct ckpt_hdr_utsns *h;
+	int domainname_len;
+	int nodename_len;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	nodename_len = sizeof(uts_ns->name.nodename);
+	domainname_len = sizeof(uts_ns->name.domainname);
+
+	h->nodename_len = nodename_len;
+	h->domainname_len = domainname_len;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	down_read(&uts_sem);
+	ret = ckpt_write_string(ctx, uts_ns->name.nodename, nodename_len);
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_string(ctx, uts_ns->name.domainname, domainname_len);
+ up:
+	up_read(&uts_sem);
+	return ret;
+}
 
 static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 {
-	return 0;
+	struct ckpt_hdr_ns *h;
+	int ns_flags = 0;
+	int uts_objref;
+	int first, ret;
+
+	uts_objref = ckpt_obj_lookup_add(ctx, nsproxy->uts_ns,
+					 CKPT_OBJ_UTS_NS, &first);
+	if (uts_objref < 0)
+		return uts_objref;
+	if (first)
+		ns_flags |= CLONE_NEWUTS;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (!h)
+		return -ENOMEM;
+
+	h->flags = ns_flags;
+	h->uts_ref = uts_objref;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	if (ns_flags & CLONE_NEWUTS)
+		ret = checkpoint_uts_ns(ctx, nsproxy->uts_ns);
+
+	/* FIX: Write other namespaces here */
+	return ret;
 }
 
 int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
@@ -376,9 +438,103 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *ns;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->nodename_len > sizeof(ns->name.nodename) ||
+	    h->domainname_len > sizeof(ns->name.domainname))
+		goto out;
+
+	ns = current->nsproxy->uts_ns;
+
+	/* no need to take uts_sem because we are the sole users */
+
+	memset(ns->name.nodename, 0, sizeof(ns->name.nodename));
+	ret = _ckpt_read_string(ctx, ns->name.nodename, h->nodename_len);
+	if (ret < 0)
+		goto out;
+	memset(ns->name.domainname, 0, sizeof(ns->name.domainname));
+	ret = _ckpt_read_string(ctx, ns->name.domainname, h->domainname_len);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_uts_ns(struct ckpt_ctx *ctx, int ns_objref, int flags)
+{
+	struct uts_namespace *uts_ns;
+	int ret = 0;
+
+	uts_ns = ckpt_obj_fetch(ctx, ns_objref, CKPT_OBJ_UTS_NS);
+	if (IS_ERR(uts_ns))
+		return PTR_ERR(uts_ns);
+
+	/* sanity: CLONE_NEWUTS if-and-only-if uts_ns is NULL (first timer) */
+	if (!!uts_ns ^ !(flags & CLONE_NEWUTS))
+		return -EINVAL;
+
+	if (!uts_ns) {
+		ret = do_restore_uts_ns(ctx);
+		if (ret < 0)
+			return ret;
+		ret = ckpt_obj_insert(ctx, current->nsproxy->uts_ns,
+				    ns_objref, CKPT_OBJ_UTS_NS);
+	} else {
+		struct uts_namespace *old_uts_ns;
+
+		/* safe because nsproxy->count must be 1 ... */
+		BUG_ON(atomic_read(&current->nsproxy->count) != 1);
+
+		old_uts_ns = current->nsproxy->uts_ns;
+		current->nsproxy->uts_ns = uts_ns;
+		get_uts_ns(uts_ns);
+		put_uts_ns(old_uts_ns);
+	}
+
+	return ret;
+}
+
 static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 {
-	return task_nsproxy(current);
+	struct ckpt_hdr_ns *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (IS_ERR(h))
+		return (struct nsproxy *) h;
+
+	ret = -EINVAL;
+	if (h->uts_ref < 0)
+		goto out;
+	if (h->flags & ~CLONE_NEWUTS)
+		goto out;
+
+	/* each unseen-before namespace will be un-shared now */
+	ret = sys_unshare(h->flags);
+	if (ret)
+		goto out;
+
+	/*
+	 * For each unseen-before namespace 'xxx', it is now safe to
+	 * modify the nsproxy->xxx_ns without locking because unshare()
+	 * gave a brand new nsproxy and nsproxy->xxx_ns, and we're the
+	 * sole users at this point.
+	 */
+	ret = restore_uts_ns(ctx, h->uts_ref, h->flags);
+	ckpt_debug("uts ns: %d\n", ret);
+
+	/* FIX: add more namespaces here */
+ out:
+	ckpt_hdr_put(ctx, h);
+	return (ret < 0 ? ERR_PTR(ret) : task_nsproxy(current));
 }
 
 void *restore_ns(struct ckpt_ctx *ctx)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 405d3bc..4945de6 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -53,6 +53,8 @@ enum {
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
+	CKPT_HDR_NS,
+	CKPT_HDR_UTS_NS,
 
 	CKPT_HDR_MM = 201,
 	CKPT_HDR_VMA,
@@ -81,6 +83,7 @@ enum obj_type {
 	CKPT_OBJ_INODE,
 	CKPT_OBJ_MM,
 	CKPT_OBJ_NS,
+	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -176,6 +179,12 @@ struct ckpt_hdr_ns {
 	__u32 uts_ref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_utsns {
+	struct ckpt_hdr h;
+	__u32 nodename_len;
+	__u32 domainname_len;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
-- 
1.5.4.3
