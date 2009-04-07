From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 35/36] c/r: Add UTS support (v6)
Date: Tue,  7 Apr 2009 08:27:43 -0400
Message-ID: <1239107264-21775-36-git-send-email-orenl@cs.columbia.edu>
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

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes:
  - Remove the kernel restore path
  - Punt on nested namespaces
  - Use __NEW_UTS_LEN in nodename and domainname buffers
  - Add a note to Documentation/checkpoint/internals.txt to indicate where
    in the save/restore process the UTS information is kept
  - Store (and track) the objref of the namespace itself instead of the
    nsproxy (based on comments from Dave on IRC)
  - Remove explicit check for non-root nsproxy
  - Store the nodename and domainname lengths and use cr_write_string()
    to store the actual name strings
  - Catch failure of cr_obj_add_ptr() in cr_write_namespaces()
  - Remove "types" bitfield and use the "is this new" flag to determine
    whether or not we should write out a new ns descriptor
  - Replace kernel restore path
  - Move the namespace information to be directly after the task
    information record
  - Update Documentation to reflect new location of namespace info
  - Support checkpoint and restart of nested UTS namespaces

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/checkpoint/internals.txt |    1 +
 checkpoint/checkpoint.c                |    2 -
 checkpoint/ckpt_task.c                 |   87 ++++++++++++++++++++++++
 checkpoint/objhash.c                   |    7 ++
 checkpoint/rstr_task.c                 |  114 ++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h             |    1 +
 include/linux/checkpoint_hdr.h         |   12 ++++
 7 files changed, 222 insertions(+), 2 deletions(-)

diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
index 266c87a..47b70e0 100644
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
index 630b52c..d3661b1 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -258,8 +258,6 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 		return -EINVAL;
 
 	rcu_read_lock();
-	if (task_nsproxy(t)->uts_ns != ctx->root_nsproxy->uts_ns)
-		ret = -EPERM;
 	if (task_nsproxy(t)->ipc_ns != ctx->root_nsproxy->ipc_ns)
 		ret = -EPERM;
 	if (task_nsproxy(t)->mnt_ns != ctx->root_nsproxy->mnt_ns)
diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index 5d17ade..fb82b0b 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -12,6 +12,7 @@
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/poll.h>
+#include <linux/utsname.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -165,6 +166,88 @@ int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
+{
+	struct cr_hdr h;
+	struct cr_hdr_utsns *hh;
+	int domainname_len;
+	int nodename_len;
+	int ret;
+
+	h.type = CR_HDR_UTSNS;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	nodename_len = strlen(uts_ns->name.nodename) + 1;
+	domainname_len = strlen(uts_ns->name.domainname) + 1;
+
+	hh->nodename_len = nodename_len;
+	hh->domainname_len = domainname_len;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	ret = cr_write_string(ctx, uts_ns->name.nodename, nodename_len);
+	if (ret < 0)
+		return ret;
+
+	ret = cr_write_string(ctx, uts_ns->name.domainname, domainname_len);
+	return ret;
+}
+
+static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_namespaces *hh;
+	struct nsproxy *nsproxy;
+	int new_uts;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	h.type = CR_HDR_NS;
+	h.len = sizeof(*hh);
+
+	new_uts = cr_obj_add_ptr(ctx, nsproxy->uts_ns,
+				 &hh->uts_ref, CR_OBJ_UTSNS, 0);
+	if (new_uts < 0) {
+		ret = new_uts;
+		goto out;
+	}
+
+	hh->flags = 0;
+	if (new_uts)
+		hh->flags |= CLONE_NEWUTS;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	if (new_uts) {
+		ret = cr_write_utsns(ctx, nsp->uts_ns);
+		if (ret < 0)
+			goto out;
+	}
+
+	/* FIX: Write other namespaces here */
+ out:
+	put_nsproxy(nsp);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
 /* dump the entire state of a given task */
 int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -174,6 +257,10 @@ int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	cr_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_namespaces(ctx, t);
+	cr_debug("namespace: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_mm(ctx, t);
 	cr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 6584579..1082713 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -11,6 +11,7 @@
 #include <linux/kernel.h>
 #include <linux/file.h>
 #include <linux/hash.h>
+#include <linux/utsname.h>
 #include <linux/checkpoint.h>
 
 struct cr_objref {
@@ -41,6 +42,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_MM:
 		mmput((struct mm_struct *) obj->ptr);
 		break;
+	case CR_OBJ_UTSNS:
+		put_uts_ns((struct uts_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -61,6 +65,9 @@ static int cr_obj_ref_grab(struct cr_objref *obj)
 	case CR_OBJ_MM:
 		atomic_inc(&((struct mm_struct *) obj->ptr)->mm_users);
 		break;
+	case CR_OBJ_UTSNS:
+		get_uts_ns((struct uts_namespace *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
index 52206d8..13bc056 100644
--- a/checkpoint/rstr_task.c
+++ b/checkpoint/rstr_task.c
@@ -12,6 +12,8 @@
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/poll.h>
+#include <linux/utsname.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -164,6 +166,114 @@ int cr_read_restart_block(struct cr_ctx *ctx)
 	return ret;
 }
 
+static int cr_read_utsns(struct cr_ctx *ctx)
+{
+	struct cr_hdr_utsns *hh;
+	struct uts_namespace *ns;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_UTSNS);
+	if (ret < 0)
+		goto out;
+
+	ret = -EINVAL;
+	if (hh->nodename_len > sizeof(ns->name.nodename) ||
+	    hh->domainname_len > sizeof(ns->name.domainname))
+		goto out;
+
+	ns = current->nsproxy->uts_ns;
+
+	memset(ns->name.nodename, 0, sizeof(ns->name.nodename));
+	ret = cr_read_string(ctx, ns->name.nodename, hh->nodename_len);
+	if (ret < 0)
+		goto out;
+
+	memset(ns->name.domainname, 0, sizeof(ns->name.domainname));
+	ret = cr_read_string(ctx, ns->name.domainname, hh->domainname_len);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+static int cr_restore_utsns(struct cr_ctx *ctx, int ref, int flags)
+{
+	struct uts_namespace *uts_ns, *olduts_ns;
+	int ret;
+
+	uts_ns = cr_obj_get_by_ref(ctx, ref, CR_OBJ_UTSNS);
+	if (IS_ERR(uts_ns)) {
+		cr_debug("failed to get UTS ns from objhash");
+		return PTR_ERR(uts_ns);
+	}
+
+	if (!!uts_ns ^ !(flags & CLONE_NEWUTS))
+		return -EINVAL;
+
+	if (!uts_ns) {
+		ret = cr_read_utsns(ctx);
+		if (ret < 0)
+			return ret;
+		ret = cr_obj_add_ref(ctx, current->nsproxy->uts_ns,
+				     ref, CR_OBJ_UTSNS, 0);
+	} else {
+		ret = copy_namespaces(CLONE_NEWUTS, current);
+		if (ret < 0)
+			return ret;
+
+		olduts_ns = current->nsproxy->uts_ns;
+		current->nsproxy->uts_ns = uts_ns;
+		get_uts_ns(uts_ns);
+		put_uts_ns(olduts_ns);
+	}
+
+	return ret;
+}
+
+static int cr_read_namespaces(struct cr_ctx *ctx)
+{
+	struct cr_hdr_namespaces *hh;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_NS);
+	if (ret < 0)
+		goto out;
+
+	ret = -EINVAL;
+	if (hh->flags & ~CLONE_NEWUTS)
+		goto out;
+
+	/* each unseen-before namespace will be un-shared now */
+	ret = sys_unshare(hh->flags);
+	if (ret)
+		goto out;
+
+	/*
+	 * For each unseen-before namespace 'xxx', it is now safe to
+	 * modify the nsproxy->xxx_ns without locking because unshare()
+	 * gave a brand new nsproxy and nsproxy->xxx_ns, and we're the
+	 * sole users at this point.
+	 */
+
+	ret = cr_restore_utsns(ctx, hh->uts_ref, hh->flags);
+	cr_debug("uts ns: %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	/* FIX: add more namespaces here */
+
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
 /* read the entire state of the current task */
 int cr_read_task(struct cr_ctx *ctx)
 {
@@ -173,6 +283,10 @@ int cr_read_task(struct cr_ctx *ctx)
 	cr_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_namespaces(ctx);
+	cr_debug("namespace: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_read_mm(ctx);
 	cr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1bfe284..f821283 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -78,6 +78,7 @@ enum {
 	CR_OBJ_FILE = 1,
 	CR_OBJ_INODE,
 	CR_OBJ_MM,
+	CR_OBJ_UTSNS,
 	CR_OBJ_MAX
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b55e85d..212c95f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -49,6 +49,8 @@ enum {
 	CR_HDR_RESTART_BLOCK,
 	CR_HDR_THREAD,
 	CR_HDR_CPU,
+	CR_HDR_NS,
+	CR_HDR_UTSNS,
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
@@ -131,6 +133,16 @@ enum restart_block_type {
 	CR_RESTART_BLOCK_FUTEX
 };
 
+struct cr_hdr_namespaces {
+	__u32 flags;
+	__u32 uts_ref;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_utsns {
+	__u32 nodename_len;
+	__u32 domainname_len;
+} __attribute__((aligned(8)));
+
 struct cr_hdr_mm {
 	__s32 objref;		/* identifier for shared objects */
 	__u32 map_count;
-- 
1.5.4.3
