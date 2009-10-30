From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 02/22] Add format and message buffers to ctx and make err_str
	bigger
Date: Fri, 30 Oct 2009 18:00:24 -0500
Message-ID: <1256943629-4531-3-git-send-email-serue@us.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256943629-4531-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c                 |    5 +++++
 include/linux/checkpoint_types.h |   18 +++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index c888a12..0a486f0 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -249,6 +249,11 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	spin_lock_init(&ctx->lock);
 #endif
 
+	mutex_init(&ctx->msg_buf_mutex);
+	spin_lock_init(&ctx->err_string_lock);
+	spin_lock_init(&ctx->fmt_buf_lock);
+	ctx->err_string_len = 0;
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5cc11d9..46c58fb 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -59,7 +59,6 @@ struct ckpt_ctx {
 	struct path fs_mnt;     /* container root (FIXME) */
 
 	struct task_struct *tsk;/* checkpoint: current target task */
-	char err_string[256];	/* checkpoint: error string */
 	int errno;		/* restart: errno that caused failure */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
@@ -85,6 +84,23 @@ struct ckpt_ctx {
 	struct list_head task_status;   /* list of status for each task */
 	spinlock_t lock;
 #endif
+
+#define CKPT_MSG_BUFSZ 1024
+	/* err_string holds specific checkpoint error strings which may
+	 * be crafted in a context where we can't write it out yet */
+	char err_string[CKPT_MSG_BUFSZ];
+	spinlock_t err_string_lock;
+	int err_string_len;
+
+	/* fmt_buf holds the result of processing an enhanced format
+	 * string for use in crafting msg_buf */
+	char fmt_buf[CKPT_MSG_BUFSZ];
+	spinlock_t fmt_buf_lock;
+
+	/* msg_buf holds messages for writing to user log and syslog */
+	char msg_buf[CKPT_MSG_BUFSZ];
+	int msg_buf_len;
+	struct mutex msg_buf_mutex;
 };
 
 #endif /* __KERNEL__ */
-- 
1.6.1
