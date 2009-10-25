From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] Checkpoint/restart eventfd
Date: Sat, 24 Oct 2009 22:13:10 -0700
Message-ID: <1256447590-31138-1-git-send-email-matthltc@us.ibm.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Save/restore eventfd files. These are anon_inodes just like epoll
but instead of a set of files to poll they are a 64-bit counter
and a flag value. Used for AIO.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

NOTE: Marked [RFC] because it strangely does not pass my adapted LTP
	test cases unless it's running from a checkpointed image.
	Seems to be a mistake in the test case adaptation.
---
 checkpoint/files.c             |    7 +++++
 fs/eventfd.c                   |   51 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    8 ++++++
 include/linux/eventfd.h        |   10 ++++++++
 4 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index f6de07e..43b95cc 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -23,6 +23,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <net/sock.h>
+#include <linux/eventfd.h>
 
 
 /**************************************************************************
@@ -607,6 +608,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_TTY,
 		.restore = tty_file_restore,
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
index 31d12de..5d30cd5 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -18,6 +18,8 @@
 #include <linux/module.h>
 #include <linux/kref.h>
 #include <linux/eventfd.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 struct eventfd_ctx {
 	struct kref kref;
@@ -223,11 +225,34 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
 	return res;
 }
 
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
 static const struct file_operations eventfd_fops = {
 	.release	= eventfd_release,
 	.poll		= eventfd_poll,
 	.read		= eventfd_read,
 	.write		= eventfd_write,
+	.checkpoint     = eventfd_checkpoint,
 };
 
 /**
@@ -335,3 +360,29 @@ SYSCALL_DEFINE1(eventfd, unsigned int, count)
 	return sys_eventfd2(count, 0);
 }
 
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_eventfd *h = (struct ckpt_hdr_file_eventfd *)ptr;
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
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ff2e4aa..dc22244 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -476,6 +476,8 @@ enum file_type {
 #define CKPT_FILE_SOCKET CKPT_FILE_SOCKET
 	CKPT_FILE_TTY,
 #define CKPT_FILE_TTY CKPT_FILE_TTY
+	CKPT_FILE_EVENTFD,
+#define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
 	CKPT_FILE_MAX
 #define CKPT_FILE_MAX CKPT_FILE_MAX
 };
@@ -500,6 +502,12 @@ struct ckpt_hdr_file_pipe {
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
index 3b85ba6..a904633 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -34,6 +34,15 @@ struct eventfd_ctx *eventfd_ctx_fdget(int fd);
 struct eventfd_ctx *eventfd_ctx_fileget(struct file *file);
 int eventfd_signal(struct eventfd_ctx *ctx, int n);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
+struct file *eventfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr);
+#else
+#define eventfd_restore NULL
+#endif
 #else /* CONFIG_EVENTFD */
 
 /*
@@ -55,6 +64,7 @@ static inline void eventfd_ctx_put(struct eventfd_ctx *ctx)
 
 }
 
+#define eventfd_restore NULL
 #endif
 
 #endif /* _LINUX_EVENTFD_H */
-- 
1.5.6.3
