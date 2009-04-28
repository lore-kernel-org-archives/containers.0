From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 41/54] ipc: helpers to save and restore kern_ipc_perm
	structures
Date: Tue, 28 Apr 2009 19:24:11 -0400
Message-ID: <1240961064-13991-42-git-send-email-orenl@cs.columbia.edu>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
 include/linux/checkpoint.h     |    7 +++-
 include/linux/checkpoint_hdr.h |   29 ++++++++++++++++
 ipc/Makefile                   |    1 +
 ipc/checkpoint.c               |   73 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    8 ++++
 5 files changed, 117 insertions(+), 1 deletions(-)
 create mode 100644 ipc/checkpoint.c

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 867033c..8a7fe9a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -12,6 +12,10 @@
 
 struct ckpt_ctx;
 
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -169,8 +173,9 @@ extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 #define CKPT_DPAGE	0x10		/* memory pages */
 #define CKPT_DOBJ	0x20		/* shared objects */
 #define CKPT_DFILE	0x40		/* files and filesystem */
+#define CKPT_DIPC	0x80		/* sysvipc */
 
-#define CKPT_DDEFAULT	0x4f		/* default debug level */
+#define CKPT_DDEFAULT	0xcf		/* default debug level */
 
 #ifndef CKPT_DFLAG
 #define CKPT_DFLAG	0x0		/* nothing */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3051031..0af5532 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -67,6 +67,11 @@ enum {
 	CKPT_HDR_FILE,
 	CKPT_HDR_FILE_PIPE,
 
+	CKPT_HDR_IPC = 401,
+	CKPT_HDR_IPC_SHM,
+	CKPT_HDR_IPC_MSG,
+	CKPT_HDR_IPC_SEM,
+
 	CKPT_HDR_TAIL = 5001
 };
 
@@ -279,4 +284,28 @@ struct ckpt_hdr_file_pipe_state {
 	__s32 pipe_nrbufs;
 } __attribute__((aligned(8)));
 
+/* ipc commons */
+struct ckpt_hdr_ipc_perms {
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
+
+#define CKPT_TST_OVERFLOW_16(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
+
+#define CKPT_TST_OVERFLOW_32(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > INT_MAX))
+
+#define CKPT_TST_OVERFLOW_64(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
+
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 4e1955e..aa6c8dd 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,4 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
new file mode 100644
index 0000000..9a6cd9d
--- /dev/null
+++ b/ipc/checkpoint.c
@@ -0,0 +1,73 @@
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
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/ipc.h>
+#include <linux/sched.h>
+#include <linux/ipc_namespace.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+int checkpoint_ipcns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
+{
+	return 0;
+}
+
+int restore_ipcns(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+void checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			       struct kern_ipc_perm *perm)
+{
+	h->id = perm->id;
+	h->key = perm->key;
+	h->uid = perm->uid;
+	h->gid = perm->gid;
+	h->cuid = perm->cuid;
+	h->cgid = perm->cgid;
+	h->mode = perm->mode & S_IRWXUGO;
+	h->seq = perm->seq;
+}
+
+int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			   struct kern_ipc_perm *perm)
+{
+	if (h->id < 0)
+		return -EINVAL;
+	if (CKPT_TST_OVERFLOW_16(h->uid, perm->uid) ||
+	    CKPT_TST_OVERFLOW_16(h->gid, perm->gid) ||
+	    CKPT_TST_OVERFLOW_16(h->cuid, perm->cuid) ||
+	    CKPT_TST_OVERFLOW_16(h->cgid, perm->cgid) ||
+	    CKPT_TST_OVERFLOW_16(h->mode, perm->mode))
+		return -EINVAL;
+	if (h->seq >= USHORT_MAX)
+		return -EINVAL;
+	if (h->mode & ~S_IRWXUGO)
+		return -EINVAL;
+
+	/* FIX: verify the ->mode field makes sense */
+
+	perm->id = h->id;
+	perm->key = h->key;
+#if 0 /* FIX: requires security checks */
+	perm->uid = h->uid;
+	perm->gid = h->gid;
+	perm->cuid = h->cuid;
+	perm->cgid = h->cgid;
+#endif
+	perm->mode = h->mode;
+	perm->seq = h->seq;
+
+	return 0;
+}
diff --git a/ipc/util.h b/ipc/util.h
index c75e3b2..d3f7367 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -11,6 +11,7 @@
 #define _IPC_UTIL_H
 
 #include <linux/err.h>
+#include <linux/checkpoint_hdr.h>
 
 #define SEQ_MULTIPLIER	(IPCMNI)
 
@@ -177,5 +178,12 @@ extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
 
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
+#ifdef CONFIG_CHECKPOINT
+extern void checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
+				      struct kern_ipc_perm *perm);
+extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
+				  struct kern_ipc_perm *perm);
+#endif
+
 
 #endif
-- 
1.5.4.3
