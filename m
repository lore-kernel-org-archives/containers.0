From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 83/96] c/r: checkpoint/restart eventfd
Date: Thu, 18 Mar 2010 20:59:59 -0400
Message-ID: <1268960401-16680-16-git-send-email-orenl__33399.3179061965$1268961117$gmane$org@cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268960401-16680-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Save/restore eventfd files. These are anon_inodes just like epoll
but instead of a set of files to poll they are a 64-bit counter
and a flag value. Used for AIO.

[Oren Laadan] Added #ifdef's around checkpoint/restart to compile even
without CONFIG_CHECKPOINT

Changelog[v19]:
  - Fix broken compilation for architectures that don't support c/r

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |    7 +++++
 fs/eventfd.c                   |   55 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    8 ++++++
 include/linux/eventfd.h        |   12 ++++++++
 4 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 6aaaf22..4b551fe 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -23,6 +23,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/eventpoll.h>
+#include <linux/eventfd.h>
 #include <net/sock.h>
 
 
@@ -644,6 +645,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_EPOLL,
 		.restore = ep_file_restore,
 	},
+	/* eventfd */
+	{
+		.file_name = "EVENTFD",
+		.file_type = CKPT_FILE_EVENTFD,
+		.restore = eventfd_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/eventfd.c b/fs/eventfd.c
index 7758cc3..f2785c0 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/kref.h>
 #include <linux/eventfd.h>
+#include <linux/checkpoint.h>
 
 struct eventfd_ctx {
 	struct kref kref;
@@ -287,11 +288,65 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
 	return res;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int eventfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
+{
+	struct eventfd_ctx *ctx;
+	struct ckpt_hdr_file_eventfd *h;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->common.f_type = CKPT_FILE_EVENTFD;
+	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ctx = file->private_data;
+	h->count = ctx->count;
+	h->flags = ctx->flags;
+	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
+out:
+	ckpt_hdr_put(ckpt_ctx, h);
+	return ret;
+}
+
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_eventfd *h = (struct ckpt_hdr_file_eventfd *) ptr;
+	struct file *evfile;
+	int evfd, ret;
+
+	/* Already know type == CKPT_HDR_FILE and f_type == CKPT_FILE_EVENTFD */
+	if (h->common.h.len != sizeof(*h))
+		return ERR_PTR(-EINVAL);
+
+	evfd = sys_eventfd2(h->count, h->flags);
+	if (evfd < 0)
+		return ERR_PTR(evfd);
+	evfile = fget(evfd);
+	sys_close(evfd);
+	if (!evfile)
+		return ERR_PTR(-EBUSY);
+
+	ret = restore_file_common(ckpt_ctx, evfile, &h->common);
+	if (ret < 0) {
+		fput(evfile);
+		return ERR_PTR(ret);
+	}
+	return evfile;
+}
+#else
+#define eventfd_checkpoint NULL
+#endif
+
 static const struct file_operations eventfd_fops = {
 	.release	= eventfd_release,
 	.poll		= eventfd_poll,
 	.read		= eventfd_read,
 	.write		= eventfd_write,
+	.checkpoint     = eventfd_checkpoint,
 };
 
 /**
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b96d2dc..0b36430 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -481,6 +481,8 @@ enum file_type {
 #define CKPT_FILE_TTY CKPT_FILE_TTY
 	CKPT_FILE_EPOLL,
 #define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
+	CKPT_FILE_EVENTFD,
+#define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -505,6 +507,12 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_eventfd {
+	struct ckpt_hdr_file common;
+	__u64 count;
+	__u32 flags;
+} __attribute__((aligned(8)));
+
 /* socket */
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index 91bb4f2..2ce8525 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -39,6 +39,16 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt);
 int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
 				  __u64 *cnt);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr);
+#else
+#define eventfd_restore NULL
+#endif
+
 #else /* CONFIG_EVENTFD */
 
 /*
@@ -77,6 +87,8 @@ static inline int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx,
 	return -ENOSYS;
 }
 
+#define eventfd_restore NULL
+
 #endif
 
 #endif /* _LINUX_EVENTFD_H */
-- 
1.6.3.3
