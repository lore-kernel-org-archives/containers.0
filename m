From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Mon, 28 Sep 2009 12:01:23 -0700
Message-ID: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Save/restore epoll items during checkpoint/restart respectively.
kmalloc failures should be dealt with more kindly than just error-out
because epoll is made to poll many thousands of file descriptors.
Subsequent patches will change epoll c/r to "chunk" its output/input
respectively.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changelog:

v4:	ckpt-v18
	Use files_deferq as submitted by Dan Smith
		Cleanup to only report >= 1 items when debugging.

v3: [unposted]
	Removed most of the TODOs -- the remainder will be removed by
		subsequent patches.
	Fixed missing ep_file_collect() [Serge]
	Rather than include checkpoint_hdr.h declare (but do not define)
		the two structs needed in eventpoll.h [Oren]
	Complain with ckpt_write_err() when we detect checkpoint obj
		leaks. [Oren]
	Remove redundant is_epoll_file() check in collect. [Oren]
	Move epfile_objref lookup to simplify error handling. [Oren]
	Simplify error handling with early return in
		ep_eventpoll_checkpoint(). [Oren]
	Cleaned up a comment. [Oren]
	Shorten CKPT_HDR_FILE_EPOLL_ITEMS (-FILE) [Oren]
		Renumbered to indicate that it follows the file table.
	Renamed the epoll struct in checkpoint_hdr.h [Oren]
		Also renamed substruct.
	Fixup return of empty ep_file_restore(). [Oren]
	Changed some error returns. [Oren]
	Changed some tests to BUG_ON(). [Oren]
	Factored out watch insert with epoll_ctl() into do_epoll_ctl().
		[Cedric, Oren]
---
 checkpoint/files.c             |   21 +++-
 checkpoint/restart.c           |    2 +-
 checkpoint/sys.c               |    1 -
 fs/eventpoll.c                 |  310 ++++++++++++++++++++++++++++++++++++----
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |   14 ++
 include/linux/eventpoll.h      |   17 ++-
 7 files changed, 331 insertions(+), 35 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index eac5f3b..0c9bba2 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -22,6 +22,8 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/deferqueue.h>
+#include <linux/eventpoll.h>
 #include <net/sock.h>
 
 
@@ -311,9 +313,11 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
 	}
 
 	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
-	if (ret > 0)
+	if (ret > 0) {
+		ckpt_debug("file checkpoint deferred %d work items\n", ret);
 		ret = 0;
+	}
+
  out:
 	kfree(fdtable);
 	return ret;
@@ -604,6 +608,13 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_TTY,
 		.restore = tty_file_restore,
 	},
+#ifdef CONFIG_EPOLL
+	{
+		.file_name = "EPOLL",
+		.file_type = CKPT_FILE_EPOLL,
+		.restore = ep_file_restore,
+	},
+#endif
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
@@ -731,9 +742,11 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 	}
 
 	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
-	if (ret > 0)
+	if (ret > 0) {
+		ckpt_debug("file restore deferred %d work items\n", ret);
 		ret = 0;
+	}
+
  out:
 	ckpt_hdr_put(ctx, h);
 	if (!ret) {
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 543b380..61b4921 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -193,7 +193,7 @@ int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
  *
  * Return: new buffer allocated on success, error pointer otherwise
  */
-static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
+void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 {
 	struct ckpt_hdr hh;
 	struct ckpt_hdr *h;
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 76a3fa9..b8be421 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -251,7 +251,6 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->deferqueue = deferqueue_create();
 	if (!ctx->deferqueue)
 		goto err;
-
 	ctx->files_deferq = deferqueue_create();
 	if (!ctx->files_deferq)
 		goto err;
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 085c5c0..cf3f309 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -39,6 +39,12 @@
 #include <asm/mman.h>
 #include <asm/atomic.h>
 
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/deferqueue.h>
+#endif
+
 /*
  * LOCKING:
  * There are three level of locking required by epoll :
@@ -671,10 +677,20 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
 	return pollflags != -1 ? pollflags : 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file);
+#else
+#define ep_eventpoll_checkpoint NULL
+#define ep_file_collect NULL
+#endif
+
 /* File callbacks that implement the eventpoll file behaviour */
 static const struct file_operations eventpoll_fops = {
 	.release	= ep_eventpoll_release,
-	.poll		= ep_eventpoll_poll
+	.poll		= ep_eventpoll_poll,
+	.checkpoint 	= ep_eventpoll_checkpoint,
+	.collect 	= ep_file_collect,
 };
 
 /* Fast test to see if the file is an evenpoll file */
@@ -1226,35 +1242,18 @@ SYSCALL_DEFINE1(epoll_create, int, size)
  * the eventpoll file that enables the insertion/removal/change of
  * file descriptors inside the interest set.
  */
-SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
-		struct epoll_event __user *, event)
+int do_epoll_ctl(int op, int fd,
+		 struct file *file, struct file *tfile,
+		 struct epoll_event *epds)
 {
 	int error;
-	struct file *file, *tfile;
 	struct eventpoll *ep;
 	struct epitem *epi;
-	struct epoll_event epds;
-
-	error = -EFAULT;
-	if (ep_op_has_event(op) &&
-	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
-		goto error_return;
-
-	/* Get the "struct file *" for the eventpoll file */
-	error = -EBADF;
-	file = fget(epfd);
-	if (!file)
-		goto error_return;
-
-	/* Get the "struct file *" for the target file */
-	tfile = fget(fd);
-	if (!tfile)
-		goto error_fput;
 
 	/* The target file descriptor must support poll */
 	error = -EPERM;
 	if (!tfile->f_op || !tfile->f_op->poll)
-		goto error_tgt_fput;
+		return error;
 
 	/*
 	 * We have to check that the file structure underneath the file descriptor
@@ -1263,7 +1262,7 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	 */
 	error = -EINVAL;
 	if (file == tfile || !is_file_epoll(file))
-		goto error_tgt_fput;
+		return error;
 
 	/*
 	 * At this point it is safe to assume that the "private_data" contains
@@ -1284,8 +1283,8 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 	switch (op) {
 	case EPOLL_CTL_ADD:
 		if (!epi) {
-			epds.events |= POLLERR | POLLHUP;
-			error = ep_insert(ep, &epds, tfile, fd);
+			epds->events |= POLLERR | POLLHUP;
+			error = ep_insert(ep, epds, tfile, fd);
 		} else
 			error = -EEXIST;
 		break;
@@ -1297,15 +1296,46 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 		break;
 	case EPOLL_CTL_MOD:
 		if (epi) {
-			epds.events |= POLLERR | POLLHUP;
-			error = ep_modify(ep, epi, &epds);
+			epds->events |= POLLERR | POLLHUP;
+			error = ep_modify(ep, epi, epds);
 		} else
 			error = -ENOENT;
 		break;
 	}
 	mutex_unlock(&ep->mtx);
 
-error_tgt_fput:
+	return error;
+}
+
+/*
+ * The following function implements the controller interface for
+ * the eventpoll file that enables the insertion/removal/change of
+ * file descriptors inside the interest set.
+ */
+SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
+		struct epoll_event __user *, event)
+{
+	int error;
+	struct file *file, *tfile;
+	struct epoll_event epds;
+
+	error = -EFAULT;
+	if (ep_op_has_event(op) &&
+	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
+		goto error_return;
+
+	/* Get the "struct file *" for the eventpoll file */
+	error = -EBADF;
+	file = fget(epfd);
+	if (!file)
+		goto error_return;
+
+	/* Get the "struct file *" for the target file */
+	tfile = fget(fd);
+	if (!tfile)
+		goto error_fput;
+
+	error = do_epoll_ctl(op, fd, file, tfile, &epds);
 	fput(tfile);
 error_fput:
 	fput(file);
@@ -1413,6 +1443,230 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
 
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
+#ifdef CONFIG_CHECKPOINT
+static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct rb_node *rbp;
+	struct eventpoll *ep;
+	int ret = 0;
+
+	ep = file->private_data;
+	mutex_lock(&ep->mtx);
+	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
+		struct epitem *epi;
+
+		epi = rb_entry(rbp, struct epitem, rbn);
+		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
+		if (ret < 0)
+			break;
+	}
+	mutex_unlock(&ep->mtx);
+	return ret;
+}
+
+struct epoll_deferq_entry {
+	struct ckpt_ctx *ctx;
+	struct file *epfile;
+};
+
+static int ep_items_checkpoint(void *data)
+{
+	struct epoll_deferq_entry *ep_dq_entry = data;
+	struct ckpt_ctx *ctx;
+	struct file *file;
+	struct ckpt_hdr_eventpoll_items *h;
+	struct rb_node *rbp;
+	struct eventpoll *ep;
+	__s32 epfile_objref;
+	int i, ret;
+
+	file = ep_dq_entry->epfile;
+	ctx = ep_dq_entry->ctx;
+
+	epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
+	BUG_ON(epfile_objref <= 0);
+
+
+	ep = file->private_data;
+	mutex_lock(&ep->mtx);
+	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
+	mutex_unlock(&ep->mtx);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
+			      CKPT_HDR_EPOLL_ITEMS);
+	if (!h)
+		return -ENOMEM;
+
+	h->num_items = i;
+	h->epfile_objref = epfile_objref;
+
+	ret = 0;
+	mutex_lock(&ep->mtx);
+	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {
+		struct epitem *epi;
+		int objref;
+
+		epi = rb_entry(rbp, struct epitem, rbn);
+		objref = ckpt_obj_lookup(ctx, epi->ffd.file, CKPT_OBJ_FILE);
+		if (objref <= 0) {
+			ret = -EBUSY; /* checkpoint obj leak */
+			break;
+		}
+		h->items[i].fd = epi->ffd.fd;
+		h->items[i].file_objref = objref;
+		h->items[i].events = epi->event.events;
+		h->items[i].data = epi->event.data;
+	}
+	mutex_unlock(&ep->mtx);
+	if (!ret && (i != h->num_items))
+		/*
+		 * We raced with another thread between our first and second
+		 * walks of the rbtree such that there weren't the same number
+		 * of items. This means there is a checkpoint "leak".
+		 */
+		ret = -EBUSY;
+	if (ret == -EBUSY)
+		ckpt_write_err(ctx, "ep_items_checkpoint(): checkpoint leak detected.\n", "");
+	else if (!ret)
+		ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, &h->h);
+	return ret;
+}
+
+static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file *h;
+	struct epoll_deferq_entry ep_dq_entry;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->f_type = CKPT_FILE_EPOLL;
+	ret = checkpoint_file_common(ctx, file, h);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * Defer saving the epoll items until all of the ffd.file pointers
+	 * have an objref; after the file table has been checkpointed.
+	 */
+	ep_dq_entry.ctx = ctx;
+	ep_dq_entry.epfile = file;
+	ret = deferqueue_add(ctx->files_deferq, &ep_dq_entry,
+			     sizeof(ep_dq_entry), ep_items_checkpoint, NULL);
+out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int ep_items_restore(void *data)
+{
+	struct ckpt_ctx *ctx = deferqueue_data_ptr(data);
+	struct ckpt_hdr_eventpoll_items *h;
+	struct eventpoll *ep;
+	struct file *epfile = NULL;
+	int ret, i = 0, remaining_watches;
+
+	h = ckpt_read_obj(ctx, 0,
+			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if ((h->h.type != CKPT_HDR_EPOLL_ITEMS) ||
+	    (h->h.len < sizeof(*h)))
+		goto out;
+
+	/* Make sure the items match the size we expect */
+	if (h->num_items != ((h->h.len - sizeof(*h)) / sizeof(h->items[0])))
+		goto out;
+
+	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
+	BUG_ON(IS_ERR(epfile));
+	BUG_ON(!is_file_epoll(epfile));
+
+	/* Make sure there are enough watches left. */
+	ret = -ENOSPC;
+	ep = epfile->private_data;
+	remaining_watches = (max_user_watches -
+			     atomic_read(&ep->user->epoll_watches));
+	if (h->num_items > remaining_watches)
+		goto out;
+
+	ret = 0;
+	/* Restore the epoll items/watches */
+	for (i = 0; !ret && i < h->num_items; i++) {
+		struct epoll_event epev;
+		struct file *tfile;
+
+		/* Get the file* for the target file */
+		if (h->items[i].file_objref <= 0) {
+			ret = -EINVAL;
+			break;
+		}
+		tfile = ckpt_obj_fetch(ctx, h->items[i].file_objref,
+				       CKPT_OBJ_FILE);
+		if (IS_ERR(tfile)) {
+			ret = PTR_ERR(tfile);
+			break;
+		}
+
+		epev.events = h->items[i].events;
+		epev.data = h->items[i].data;
+
+		ret = do_epoll_ctl(EPOLL_CTL_ADD, h->items[i].fd,
+				   epfile, tfile, &epev);
+	}
+out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+struct file* ep_file_restore(struct ckpt_ctx *ctx,
+			     struct ckpt_hdr_file *h)
+{
+	struct file *epfile;
+	int epfd, ret;
+
+	if (h->h.type != CKPT_HDR_FILE ||
+	    h->h.len  != sizeof(*h) ||
+	    h->f_type != CKPT_FILE_EPOLL)
+		return ERR_PTR(-EINVAL);
+
+	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
+	if (epfd < 0)
+		return ERR_PTR(epfd);
+	epfile = fget(epfd);
+	BUG_ON(!epfile);
+
+	/*
+	 * Needed before we can properly restore the watches and enforce the
+	 * limit on watch numbers.
+	 */
+	ret = restore_file_common(ctx, epfile, h);
+	if (ret < 0)
+		goto fput_out;
+
+	/*
+	 * Defer restoring the epoll items until the file table is
+	 * fully restored. Ensures that valid file objrefs will resolve.
+	 */
+	ret = deferqueue_add_ptr(ctx->files_deferq, ctx, ep_items_restore, NULL);
+	if (ret < 0) {
+fput_out:
+		fput(epfile);
+		epfile = ERR_PTR(ret);
+	}
+	sys_close(epfd); /* harmless even if an error occured */
+	return epfile;
+}
+
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init eventpoll_init(void)
 {
 	struct sysinfo si;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e00dd70..a8594cc 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -72,6 +72,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
 extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
 extern int ckpt_read_payload(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2ed523f..48736bd 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -85,6 +85,7 @@ enum {
 	CKPT_HDR_PIPE_BUF,
 	CKPT_HDR_TTY,
 	CKPT_HDR_TTY_LDISC,
+	CKPT_HDR_EPOLL_ITEMS = 391, /* Follows file-table */
 
 	CKPT_HDR_MM = 401,
 	CKPT_HDR_VMA,
@@ -380,6 +381,7 @@ enum file_type {
 	CKPT_FILE_FIFO,
 	CKPT_FILE_SOCKET,
 	CKPT_FILE_TTY,
+	CKPT_FILE_EPOLL,
 	CKPT_FILE_MAX
 };
 
@@ -475,6 +477,18 @@ struct ckpt_hdr_file_socket {
 	__s32 sock_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_eventpoll_items {
+	struct ckpt_hdr h;
+	__s32  epfile_objref;
+	__u32  num_items;
+	struct ckpt_eventpoll_item {
+		__u64 data;
+		__u32 fd;
+		__s32 file_objref;
+		__u32 events;
+	} items[0];
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
index f6856a5..34538be 100644
--- a/include/linux/eventpoll.h
+++ b/include/linux/eventpoll.h
@@ -56,6 +56,9 @@ struct file;
 
 
 #ifdef CONFIG_EPOLL
+struct ckpt_ctx;
+struct ckpt_hdr_file;
+
 
 /* Used to initialize the epoll bits inside the "struct file" */
 static inline void eventpoll_init_file(struct file *file)
@@ -95,11 +98,23 @@ static inline void eventpoll_release(struct file *file)
 	eventpoll_release_file(file);
 }
 
-#else
 
+#ifdef CONFIG_CHECKPOINT
+extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
+				    struct ckpt_hdr_file *h);
+#endif
+#else
+/* !defined(CONFIG_EPOLL) */
 static inline void eventpoll_init_file(struct file *file) {}
 static inline void eventpoll_release(struct file *file) {}
 
+#ifdef CONFIG_CHECKPOINT
+static inline struct file* ep_file_restore(struct ckpt_ctx *ctx,
+					   struct ckpt_hdr_file *ptr)
+{
+	return ERR_PTR(-ENOSYS);
+}
+#endif
 #endif
 
 #endif /* #ifdef __KERNEL__ */
-- 
1.5.6.3
