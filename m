From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH] checkpoint/restart: Add support for epoll
Date: Tue, 14 Jul 2009 16:54:05 -0700
Message-ID: <20090714235405.GH5213@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

 Add checkpoint/restart support for epoll files. This is the minimum
 support necessary to recreate the epoll item sets without any pending
 events.

 This is an RFC to show where I'm going with the patch and give an idea
 of how much code I expect it will take. Compiles and boots on x86 but
 I haven't tested it.

 Caveats: Does not correctly support restoring epoll fds to epoll sets
	  as this requires some recursion detection/avoidance. See the
	  "TODO" that mentions deferqueues.

	  Does not attempt to save pending event information for
	  delivery during restart.

	  TODO: Look into if we need a restart block for epoll_wait().

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |   13 +++
 fs/eventpoll.c                 |  181 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |   15 ++++
 include/linux/eventpoll.h      |   14 +++-
 4 files changed, 221 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 5ca2e6c..7233a9b 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -484,6 +484,11 @@ struct restore_file_ops {
 				  struct ckpt_hdr_file *ptr);
 };
 
+#ifdef CONFIG_EPOLL
+extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_file *ptr);
+#endif
+
 static struct restore_file_ops restore_file_ops[] = {
 	/* ignored file */
 	{
@@ -503,6 +508,14 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_PIPE,
 		.restore = pipe_file_restore,
 	},
+#ifdef CONFIG_EPOLL
+	/* epoll */
+	{
+		.file_name = "EPOLL",
+		.file_type = CKPT_FILE_EPOLL,
+		.restore = ep_file_restore,
+	},
+#endif
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 5458e80..9b2414b 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -668,10 +668,17 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
 	return pollflags != -1 ? pollflags : 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+#else
+#define ep_eventpoll_checkpoint NULL
+#endif
+
 /* File callbacks that implement the eventpoll file behaviour */
 static const struct file_operations eventpoll_fops = {
 	.release	= ep_eventpoll_release,
-	.poll		= ep_eventpoll_poll
+	.poll		= ep_eventpoll_poll,
+	.checkpoint 	= ep_eventpoll_checkpoint,
 };
 
 /* Fast test to see if the file is an evenpoll file */
@@ -1410,6 +1417,178 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
 
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_eventpoll *h;
+	struct ckpt_eventpoll_item *cepi;
+	struct rb_node *rbp;
+	struct eventpoll *ep;
+	int nitems = 0, rc = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_EPOLL);
+	if (!h)
+		return rc;
+
+	ep = file->private_data;
+	/* TODO see if we need mutex_lock(&ep->mtx);*/
+	for (rbp = rb_first(&ep->rbr); rbp && nitems++; rbp = rb_next(rbp)) {}
+	h->num_items = nitems;
+	h->common.f_type = CKPT_FILE_EPOLL;
+	rc = checkpoint_file_common(ctx, file, &h->common);
+	if (!rc) {
+		/*
+		 * We write this in such a weird way! The problem is we want
+		 * to use the common file checkpoint code above but we also
+		 * want a variable number of saved epitems to follow the
+		 * num_items field. So we write out the header type and length,
+		 * then we write the remaining, fixed-size part of the struct.
+		 * Finally we'll write each epitem by walking the rbtree.
+		 */
+		h->common.h.len += nitems*sizeof(*cepi);
+		rc = ckpt_write_obj_type(ctx, NULL, h->common.h.len,
+					 h->common.h.type);
+		ckpt_kwrite(ctx, ((void*)&h->common.h) + sizeof(h->common.h),
+			    sizeof(*h) - sizeof(h->common.h));
+	}
+	ckpt_hdr_put(ctx, h);
+	if (rc)
+		goto out;
+
+	/* 
+	 * FIXME for now we do it one at a time. Later we might do it like
+	 * checkpoint_pids() for better performance since there can be many
+	 * more epoll items than pids.
+	 */
+	cepi = ckpt_hdr_get(ctx, sizeof(*cepi));
+	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
+		struct epitem *epi = rb_entry(rbp, struct epitem, rbn);
+		cepi->fd = epi->ffd.fd;
+		cepi->events = epi->event.events;
+		cepi->data = epi->event.data;
+		if (ckpt_kwrite(ctx, cepi, sizeof(*cepi)) < 0)
+			break;
+	}
+	_ckpt_hdr_put(ctx, cepi, sizeof(*cepi));
+out:
+	/*mutex_unlock(&ep->mtx);*/
+	return rc;
+}
+
+struct file* ep_file_restore(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_eventpoll *h;
+	struct eventpoll *ep;
+	struct file *epfile;
+	int epfd, error, i;
+
+	h = container_of(ptr, struct ckpt_hdr_file_eventpoll, common);
+	if (h->common.h.type != CKPT_HDR_FILE_EPOLL ||
+	    h->common.h.len < sizeof(*h) ||
+	    h->common.f_type != CKPT_FILE_EPOLL)
+		return ERR_PTR(-EINVAL);
+
+	/* limit max ep watches and the use of flags */
+	if (h->num_items >= max_user_watches)
+		return ERR_PTR(-ENOSPC);
+	if (h->common.f_flags & ~EPOLL_CLOEXEC)
+		return ERR_PTR(-EINVAL);
+
+	/* similar to epoll_create() */
+	error = ep_alloc(&ep);
+	if (error < 0)
+		return ERR_PTR(error);
+	error = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep,
+				 ptr->f_flags & O_CLOEXEC);
+	if (error < 0) {
+		ep_free(ep);
+		return ERR_PTR(error);
+	}
+
+	/* Everything's allocated, we just need a file* */
+	epfd = error;
+	epfile = fget(epfd);
+	BUG_ON(!epfile);
+
+	/* Restore the common file bits */
+	i = 0;
+	error = restore_file_common(ctx, epfile, ptr);
+	if (error < 0)
+		goto error_return;
+
+	/* Restore the epoll items/watches */
+	for (; i < h->num_items; i++) {
+		/* 
+		 * Loop body like multiple epoll_ctl(ep, ADD, event)
+		 * calls except we've already done much of the checking.
+		 */
+		struct ckpt_eventpoll_item cepi;
+		struct epoll_event epev;
+		struct epitem *epi;
+		struct file *tfile;
+
+		error = ckpt_kread(ctx, &cepi, sizeof(cepi));
+		if (error < 0) {
+			i++;
+			break;
+		}
+		epev.events = cepi.events;
+		epev.data = cepi.data;
+
+		/* Get the file* for the target file */
+		error = -EFAULT;
+		tfile = fget(cepi.fd);
+		if (!tfile) {
+			/*
+			 * TODO delayed addition of epitem because 
+			 * tfile hasn't been restored yet.
+			 */
+			continue;
+		}
+
+		/* The target file descriptor must support poll */
+		error = -EPERM;
+		if (!tfile->f_op || !tfile->f_op->poll)
+			goto error_tgt_fput;
+
+		/* Cannot add an epoll file descriptor inside itself. */
+		error = -EINVAL;
+		if (epfile == tfile)
+			goto error_tgt_fput;
+
+		/* mutex_lock(&ep->mtx); TODO check if we need */
+		epi = ep_find(ep, tfile, cepi.fd);
+		if (!epi) {
+			epev.events |= POLLERR | POLLHUP;
+			error = ep_insert(ep, &epev, tfile, cepi.fd);
+		} else
+			error = -EEXIST;
+		/* mutex_unlock(&ep->mtx); */
+error_tgt_fput:
+		fput(tfile);
+		if (error < 0)
+			break;
+	}
+error_return:
+	/* Read the remaining number of items. */
+	for (; i < h->num_items; i++) {
+		struct ckpt_eventpoll_item cepi;
+		ckpt_kread(ctx, &cepi, sizeof(cepi));
+	}
+	if (error < 0) {
+		/* TODO closeup epfile and epfd */
+		fput(epfile);
+		sys_close(epfd);
+		epfile = ERR_PTR(error);
+	}
+	return epfile;
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init eventpoll_init(void)
 {
 	struct sysinfo si;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 874518c..58f7334 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -64,6 +64,7 @@ enum {
 	CKPT_HDR_FILE_NAME,
 	CKPT_HDR_FILE,
 	CKPT_HDR_FILE_PIPE,
+	CKPT_HDR_FILE_EPOLL,
 
 	CKPT_HDR_MM = 401,
 	CKPT_HDR_VMA,
@@ -226,6 +227,7 @@ enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
+	CKPT_FILE_EPOLL,
 	CKPT_FILE_MAX
 };
 
@@ -254,6 +256,19 @@ struct ckpt_hdr_file_pipe_state {
 	__s32 pipe_len;
 } __attribute__((aligned(8)));
 
+struct ckpt_eventpoll_item {
+	__u32 fd;
+	__u32 events;
+	__u64 data;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_eventpoll {
+	struct ckpt_hdr_file common;
+	__u32  num_items;
+	__u32  padding;
+	struct ckpt_eventpoll_item items[0];
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_utsns {
 	struct ckpt_hdr h;
 	__u32 nodename_len;
diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
index f6856a5..802053a 100644
--- a/include/linux/eventpoll.h
+++ b/include/linux/eventpoll.h
@@ -95,11 +95,23 @@ static inline void eventpoll_release(struct file *file)
 	eventpoll_release_file(file);
 }
 
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint_hdr.h>
+extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_file *ptr);
+#endif
 #else
 
 static inline void eventpoll_init_file(struct file *file) {}
 static inline void eventpoll_release(struct file *file) {}
-
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint_hdr.h>
+static inline struct file* ep_file_restore(struct ckpt_ctx *ctx,
+					   struct ckpt_hdr_file *ptr)
+{
+	return NULL;
+}
+#endif
 #endif
 
 #endif /* #ifdef __KERNEL__ */
-- 
1.5.6.3
