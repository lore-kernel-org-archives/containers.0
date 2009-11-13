From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] [RFC] checkpoint/restart signalfd
Date: Fri, 13 Nov 2009 15:05:05 -0800
Message-ID: <aa65242a98bf851a1d8432dd21850391c91607cf.1258153503.git.matthltc@us.ibm.com>
References: <41033d2ce4f31d016400bde1c5d393ae6f6b856a.1258153503.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <41033d2ce4f31d016400bde1c5d393ae6f6b856a.1258153503.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <41033d2ce4f31d016400bde1c5d393ae6f6b856a.1258153503.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <41033d2ce4f31d016400bde1c5d393ae6f6b856a.1258153503.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

signalfd uses reads of an anonymous inode-backed fd to remove
pending signals.

Since it shares the pending signal information with the regular
signal delivery path, signalfd only needs to save the sigset_t
mask associated with the file.

Upon restart, the pending signals will be restored for the
regular signal delivery path and subsequent reads of the
signalfd file will properly return the signal info.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--
NOTE: Compiles but untested -- I won't have time to convert or
	write new tests for signalfd until I've finished unlinked
	file support.
---
 checkpoint/signal.c            |   10 ------
 fs/signalfd.c                  |   62 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |   12 ++++++++
 include/linux/checkpoint_hdr.h |   16 ++++++++--
 4 files changed, 86 insertions(+), 14 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index c65ee00..c0f68fe 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -20,16 +20,6 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
-{
-	memcpy(&h->sigset, sigset, min(sizeof(*h), sizeof(*sigset)));
-}
-
-static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
-{
-	memcpy(sigset, &h->sigset, min(sizeof(*h), sizeof(*sigset)));
-}
-
 /***********************************************************************
  * sighand checkpoint/collect/restart
  */
diff --git a/fs/signalfd.c b/fs/signalfd.c
index b07565c..6a41f74 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -28,6 +28,8 @@
 #include <linux/anon_inodes.h>
 #include <linux/signalfd.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 struct signalfd_ctx {
 	sigset_t sigmask;
@@ -199,10 +201,70 @@ static ssize_t signalfd_read(struct file *file, char __user *buf, size_t count,
 	return total ? total: ret;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int signalfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
+{
+	struct signalfd_ctx *ctx;
+	struct ckpt_hdr_file_signalfd *h;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->common.f_type = CKPT_FILE_SIGNALFD;
+	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ctx = file->private_data;
+
+	/*
+	 * Pending signals, info, and handlers/actions already checkpointed
+	 * by the primary signal checkpointing code. Just need to save mask.
+	 */
+	fill_sigset(&h->sigmask, &ctx->sigmask);
+	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
+out:
+	ckpt_hdr_put(ckpt_ctx, h);
+	return ret;
+}
+
+struct file *signalfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_signalfd *h = (struct ckpt_hdr_file_signalfd *)ptr;
+	struct file *file;
+	sigset_t sigmask;
+	int ufd, ret;
+
+	/* Known: type == CKPT_HDR_FILE and f_type == CKPT_FILE_SIGNALFD */
+	if (h->common.h.len != sizeof(*h))
+		return ERR_PTR(-EINVAL);
+
+	load_sigset(&sigmask, &h->sigmask);
+	ufd = sys_signalfd4(-1, &sigmask, sizeof(sigmask), h->common.f_flags);
+	if (ufd < 0)
+		return ERR_PTR(ufd);
+	file = fget(ufd);
+	sys_close(ufd);
+	if (!file)
+		return ERR_PTR(-EBUSY);
+
+	ret = restore_file_common(ckpt_ctx, file, &h->common);
+	if (ret < 0) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+	return file;
+}
+#else
+#define signalfd_checkpoint NULL
+#endif
+
 static const struct file_operations signalfd_fops = {
 	.release	= signalfd_release,
 	.poll		= signalfd_poll,
 	.read		= signalfd_read,
+	.checkpoint     = signalfd_checkpoint,
 };
 
 SYSCALL_DEFINE4(signalfd4, int, ufd, sigset_t __user *, user_mask,
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 89e6fb3..95df4bd 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -27,6 +27,7 @@
 #ifdef CONFIG_CHECKPOINT
 
 #include <linux/sched.h>
+#include <linux/signal.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
@@ -267,6 +268,17 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 /* signals */
+struct ckpt_sigset;
+static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
+{
+	memcpy(&h->sigset, sigset, min(sizeof(*h), sizeof(*sigset)));
+}
+
+static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
+{
+	memcpy(sigset, &h->sigset, min(sizeof(*h), sizeof(*sigset)));
+}
+
 extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 5d9c088..927b409 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -482,6 +482,8 @@ enum file_type {
 #define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
 	CKPT_FILE_EVENTFD,
 #define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
+	CKPT_FILE_SIGNALFD,
+#define CKPT_FILE_SIGNALFD CKPT_FILE_SIGNALFD
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -512,6 +514,16 @@ struct ckpt_hdr_file_eventfd {
 	__u32 flags;
 } __attribute__((aligned(8)));
 
+/* signal set */
+struct ckpt_sigset {
+	__u8 sigset[CKPT_ARCH_NSIG / 8];
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_signalfd {
+	struct ckpt_hdr_file common;
+	struct ckpt_sigset sigmask;
+} __attribute__((aligned(8)));
+
 /* socket */
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
@@ -667,10 +679,6 @@ struct ckpt_hdr_pgarr {
 } __attribute__((aligned(8)));
 
 /* signals */
-struct ckpt_sigset {
-	__u8 sigset[CKPT_ARCH_NSIG / 8];
-} __attribute__((aligned(8)));
-
 struct ckpt_sigaction {
 	__u64 _sa_handler;
 	__u64 sa_flags;
-- 
1.6.3.3
