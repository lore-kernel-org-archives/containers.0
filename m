From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] checkpoint/restart timerfd
Date: Fri, 13 Nov 2009 16:49:35 -0800
Message-ID: <96703bfb68e1626100dd5fa6ce033ec204bcb58b.1258159772.git.matthltc@us.ibm.com>
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

Support checkpoint/restart of timers specified via timerfd. Checkpoint
essentially does the timerfd_gettime() syscall and saves the expired flags
and tick count. This ensures there will be no lost expirations/ticks
between checkpoint restart.

This should largely work as expected since the time returned from gettime
is always relative.

However, like any time-sensitive state, timerfds set with TFD_TIMER_ABSTIME
may expire/tick at the "wrong time" because that time has long since passed.
Short of introducing time namespaces there's almost nothing that can be done
to checkpoint these uses of timerfd. Would it make more sense to mark timerfds
which were (re)set with TFD_TIMER_ABSTIME and refuse to checkpoint them rather
than deliver a "best-effort" expiration/tick?

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--
NOTE: Compiles, untested.
---
 fs/timerfd.c                   |  113 ++++++++++++++++++++++++++++++++++++----
 include/linux/checkpoint.h     |   11 ++++
 include/linux/checkpoint_hdr.h |   21 +++++++
 3 files changed, 135 insertions(+), 10 deletions(-)

diff --git a/fs/timerfd.c b/fs/timerfd.c
index b042bd7..fb5a917 100644
--- a/fs/timerfd.c
+++ b/fs/timerfd.c
@@ -21,6 +21,8 @@
 #include <linux/anon_inodes.h>
 #include <linux/timerfd.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 struct timerfd_ctx {
 	struct hrtimer tmr;
@@ -156,10 +158,110 @@ static ssize_t timerfd_read(struct file *file, char __user *buf, size_t count,
 	return res;
 }
 
+static void __timerfd_gettime(struct timerfd_ctx *ctx,
+			      struct itimerspec *kotmr)
+{
+	if (ctx->expired && ctx->tintv.tv64) {
+		ctx->expired = 0;
+		ctx->ticks +=
+			hrtimer_forward_now(&ctx->tmr, ctx->tintv) - 1;
+		hrtimer_restart(&ctx->tmr);
+	}
+	kotmr->it_value = ktime_to_timespec(timerfd_get_remaining(ctx));
+	kotmr->it_interval = ktime_to_timespec(ctx->tintv);
+}
+
+#ifdef CONFIG_CHECKPOINT
+static int timerfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
+{
+	struct itimerspec kotmr;
+	struct timerfd_ctx *ctx;
+	struct ckpt_hdr_file_timerfd *h;
+	int ret = -ENOMEM;
+
+	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+	h->common.f_type = CKPT_FILE_EVENTFD;
+	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+
+	ctx = file->private_data;
+	/*
+	 * There is no way to recover the hrtimer mode or flags
+	 * used during create or settime. Rely on the timerfd state
+	 * to reflect those.
+	 */
+	spin_lock_irq(&ctx->wqh.lock);
+	h->expired = ctx->expired; /* must precede __timerfd_gettime() */
+	h->ticks = ctx->ticks; /* must precede __timerfd_gettime() */
+	h->clockid = ctx->clockid;
+	__timerfd_gettime(ctx, &kotmr);
+	spin_unlock_irq(&ctx->wqh.lock);
+	ckpt_copy_itimerspec(CKPT_CPT, &h->spec, &kotmr);
+	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
+out:
+	ckpt_hdr_put(ckpt_ctx, h);
+	return ret;
+}
+
+struct file *timerfd_restore(struct ckpt_ctx *ckpt_ctx,
+			     struct ckpt_hdr_file *ptr)
+{
+	struct itimerspec dotmr; /* dummy */
+	struct itimerspec kitmr;
+	struct ckpt_hdr_file_timerfd *h = (struct ckpt_hdr_file_timerfd *)ptr;
+	struct file *file;
+	struct timerfd_ctx *ctx;
+	int ufd, ret;
+
+	/* Known: CKPT_HDR_FILE and f_type == CKPT_FILE_TIMERFD */
+	if ((h->common.h.len != sizeof(*h)) ||
+	    (h->common.f_flags & ~TFD_SHARED_FCNTL_FLAGS))
+		return ERR_PTR(-EINVAL);
+
+	/* Fail early if the timespecs are bad */
+	ckpt_copy_itimerspec(CKPT_RST, &h->spec, &kitmr);
+	if (!timespec_valid(&kitmr.it_value) ||
+	    !timespec_valid(&kitmr.it_interval))
+		return ERR_PTR(-EINVAL);
+
+	ufd = sys_timerfd_create(h->clockid,
+				 h->common.f_flags & TFD_SHARED_FCNTL_FLAGS);
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
+
+	ctx = file->private_data;
+#define TFD_TIMER_RELTIME 0
+	ret = sys_timerfd_settime(ufd, TFD_TIMER_RELTIME,
+				  &kitmr, &dotmr);
+	/* Is there a race here between settime and spin_lock()? */
+	spin_lock_irq(&ctx->wqh.lock);
+	ctx->expired = h->expired;
+	ctx->ticks = h->ticks;
+	spin_unlock_irq(&ctx->wqh.lock);
+	return file;
+}
+#else
+#define timerfd_checkpoint NULL
+#endif
+
 static const struct file_operations timerfd_fops = {
 	.release	= timerfd_release,
 	.poll		= timerfd_poll,
 	.read		= timerfd_read,
+	.checkpoint     = timerfd_checkpoint,
 };
 
 static struct file *timerfd_fget(int fd)
@@ -275,19 +377,10 @@ SYSCALL_DEFINE2(timerfd_gettime, int, ufd, struct itimerspec __user *, otmr)
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 	ctx = file->private_data;
-
 	spin_lock_irq(&ctx->wqh.lock);
-	if (ctx->expired && ctx->tintv.tv64) {
-		ctx->expired = 0;
-		ctx->ticks +=
-			hrtimer_forward_now(&ctx->tmr, ctx->tintv) - 1;
-		hrtimer_restart(&ctx->tmr);
-	}
-	kotmr.it_value = ktime_to_timespec(timerfd_get_remaining(ctx));
-	kotmr.it_interval = ktime_to_timespec(ctx->tintv);
+	__timerfd_gettime(ctx, &kotmr);
 	spin_unlock_irq(&ctx->wqh.lock);
 	fput(file);
-
 	return copy_to_user(otmr, &kotmr, sizeof(kotmr)) ? -EFAULT: 0;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..f429386 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -321,6 +321,17 @@ static inline int ckpt_validate_errno(int errno)
 			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
 	} while (0)
 
+struct ckpt_itimerspec;
+struct itimerspec;
+static inline void ckpt_copy_itimerspec(int op, struct ckpt_itimerspec *h,
+					struct itimerspec *tmr)
+{
+	CKPT_COPY(op, h->interval.tv_sec,  tmr->it_interval.tv_sec);
+	CKPT_COPY(op, h->interval.tv_nsec, tmr->it_interval.tv_nsec);
+	CKPT_COPY(op, h->value.tv_sec,     tmr->it_value.tv_sec);
+	CKPT_COPY(op, h->value.tv_nsec,    tmr->it_value.tv_nsec);
+}
+
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 5d9c088..8c6982b 100644
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
@@ -512,6 +514,25 @@ struct ckpt_hdr_file_eventfd {
 	__u32 flags;
 } __attribute__((aligned(8)));
 
+/* itimers */
+struct ckpt_timespec {
+	__u64 tv_sec;
+	__u32 tv_nsec;
+} __attribute__((aligned(8)));
+
+struct ckpt_itimerspec {
+	struct ckpt_timespec interval; /* always relative */
+	struct ckpt_timespec value;    /* always relative */
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_timerfd {
+	struct ckpt_hdr_file common;
+	__u64 ticks;
+	struct ckpt_itimerspec spec;
+	__u32 clockid;
+	__u32 expired;
+} __attribute__((aligned(8)));
+
 /* socket */
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
-- 
1.6.3.3
