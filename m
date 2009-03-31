From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 2/7] ipc: helpers to save and restore
	kern_ipc_perm structures
Date: Tue, 31 Mar 2009 01:32:27 -0400
Message-ID: <1238477552-17083-3-git-send-email-orenl@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477552-17083-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Add the helpers to save and restore the contents of 'struct
kern_ipc_perm'. Add header structures for ipc state. Put
place-holders to save and restore ipc state.

TODO:
This patch does _not_ address the issues of users/groups and the
related security issues. For now, it saves the old user/group of
ipc objects, but does not restore them during restart.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/Makefile            |    3 +-
 checkpoint/checkpoint.c        |    3 +
 checkpoint/restart.c           |    3 +
 checkpoint/util_ipc.c          |   82 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |   12 ++++++
 include/linux/checkpoint_hdr.h |   32 +++++++++++++++
 6 files changed, 134 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/util_ipc.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 607d864..71061de 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,5 @@
 #
 
 obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
+	ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o \
+	util_ipc.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ef35754..2ebaa05 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -572,6 +572,9 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	ret = cr_write_tree(ctx);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_ipc(ctx, ctx->root_nsproxy);
+	if (ret < 0)
+		goto out;
 
 	ret = cr_write_all_tasks(ctx);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index adebc1c..ed5c725 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -507,6 +507,9 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
 	ret = cr_read_tree(ctx);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_ipc(ctx);
+	if (ret < 0)
+		goto out;
 
 	ret = cr_ctx_restart(ctx, pid);
 	if (ret < 0)
diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
new file mode 100644
index 0000000..70c4b18
--- /dev/null
+++ b/checkpoint/util_ipc.c
@@ -0,0 +1,82 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifdef CONFIG_SYSVIPC
+
+#include <linux/version.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
+{
+	return 0;
+}
+
+int cr_read_ipc(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh, struct kern_ipc_perm *perm)
+{
+	hh->id = perm->id;
+	hh->key = perm->key;
+	hh->uid = perm->uid;
+	hh->gid = perm->gid;
+	hh->cuid = perm->cuid;
+	hh->cgid = perm->cgid;
+	hh->mode = perm->mode & S_IRWXUGO;
+	hh->seq = perm->seq;
+}
+
+int cr_load_ipc_perms(struct cr_hdr_ipc_perms *hh, struct kern_ipc_perm *perm)
+{
+	if (hh->id < 0)
+		return -EINVAL;
+	if (CR_TST_OVERFLOW_16(hh->uid, perm->uid) ||
+	    CR_TST_OVERFLOW_16(hh->gid, perm->gid) ||
+	    CR_TST_OVERFLOW_16(hh->cuid, perm->cuid) ||
+	    CR_TST_OVERFLOW_16(hh->cgid, perm->cgid) ||
+	    CR_TST_OVERFLOW_16(hh->mode, perm->mode))
+		return -EINVAL;
+	if (hh->seq >= USHORT_MAX)
+		return -EINVAL;
+	if (hh->mode & ~S_IRWXUGO)
+		return -EINVAL;
+
+	/* FIXME: verify the ->mode field makes sense */
+
+	perm->id = hh->id;
+	perm->key = hh->key;
+#if 0 /* FIXME: requires security checks */
+	perm->uid = hh->uid;
+	perm->gid = hh->gid;
+	perm->cuid = hh->cuid;
+	perm->cgid = hh->cgid;
+#endif
+	perm->mode = hh->mode;
+	perm->seq = hh->seq;
+
+	return 0;
+}
+
+#else
+
+int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
+{
+	return 0;
+}
+
+int cr_read_ipc(struct cr_ctx *ctx)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SYSVIPC */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 59ec563..15a9890 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -14,6 +14,7 @@
 #include <linux/fs.h>
 #include <linux/path.h>
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <asm/atomic.h>
 
 #define CR_VERSION  3
@@ -111,15 +112,26 @@ extern int cr_write_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
 extern int cr_read_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
 
 extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
+extern int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_file(struct cr_ctx *ctx, struct file *file);
 
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
+extern int cr_read_ipc(struct cr_ctx *ctx);
 extern int cr_read_mm(struct cr_ctx *ctx);
 extern int cr_read_fd_table(struct cr_ctx *ctx);
 extern int cr_read_file(struct cr_ctx *ctx, int objref);
 
+#ifdef CONFIG_SYSVIPC
+struct cr_hdr_ipc_perms;
+extern void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh,
+			      struct kern_ipc_perm *perm);
+extern int cr_load_ipc_perms(struct cr_hdr_ipc_perms *hh,
+			     struct kern_ipc_perm *perm);
+#endif
+
+
 /* useful macros to copy fields and buffers to/from cr_hdr_xxx structures */
 #define CR_CPT 1
 #define CR_RST 2
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 22b40a2..6efe8dd 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -59,9 +59,23 @@ enum {
 	CR_HDR_FILE,
 	CR_HDR_FD_PIPE,
 
+	CR_HDR_IPC = 401,
+	CR_HDR_IPC_SHM,
+	CR_HDR_IPC_MSG,
+	CR_HDR_IPC_SEM,
+
 	CR_HDR_TAIL = 5001
 };
 
+#define CR_TST_OVERFLOW_16(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
+
+#define CR_TST_OVERFLOW_32(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > INT_MAX))
+
+#define CR_TST_OVERFLOW_64(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
+
 struct cr_hdr_head {
 	__u64 magic;
 
@@ -184,4 +198,22 @@ struct cr_hdr_fd_pipe {
 	__s32 nr_bufs;
 } __attribute__((aligned(8)));
 
+/* ipc commons */
+struct cr_hdr_ipc {
+	__u32 ipc_type;
+	__u32 ipc_count;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_ipc_perms {
+	__s32 id;
+	__u32 key;
+	__u32 uid;
+	__u32 gid;
+	__u32 cuid;
+	__u32 cgid;
+	__u32 mode;
+	__u32 _padding;
+	__u64 seq;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
