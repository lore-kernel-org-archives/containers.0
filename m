From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] restart debug: add final process tree status
Date: Thu, 1 Oct 2009 10:33:56 -0500
Message-ID: <20091001153356.GA20565@us.ibm.com>
References: <20090929165342.GA10076@us.ibm.com>
	<20090929165402.GA10114@us.ibm.com> <4AC40CA0.8020305@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC40CA0.8020305-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Have tasks in sys_restart keep some status in a list off
> > of checkpoint_ctx, and print this info when the checkpoint_ctx
> > is freed.
> > 
> > This is mostly an RFC - in particular the error tracking is
> > pretty half-hearted so far.  But the info it does spit out
> > helped me to figured out the coordinator syncing problem
> > fixed by the previous patch.
> > 
> > Sample dmesg output:
> > [4568:4568:c/r:free_per_task_status:200] 4 tasks registered, nr_tasks was 0 nr_total 0
> > [4568:4568:c/r:free_per_task_status:202] active pid was 1, ctx->errno 0
> > [4568:4568:c/r:free_per_task_status:204] kflags 6 uflags 0 oflags 1
> > [4568:4568:c/r:free_per_task_status:206] task 0 to run was 4568
> > [4568:4568:c/r:free_per_task_status:209] pid 4566
> > [4568:4568:c/r:free_per_task_status:211] it was coordinator
> > [4568:4568:c/r:free_per_task_status:219] it was running
> > [4568:4568:c/r:free_per_task_status:209] pid 4570
> > [4568:4568:c/r:free_per_task_status:213] it was a ghost
> > [4568:4568:c/r:free_per_task_status:209] pid 4569
> > [4568:4568:c/r:free_per_task_status:213] it was a ghost
> > [4568:4568:c/r:free_per_task_status:209] pid 4568
> > [4568:4568:c/r:free_per_task_status:215] it was the root task
> > [4568:4568:c/r:free_per_task_status:221] it was a normal task
> > 
> > So, when one task died before hitting sys_restart, the first line would
> > show '3 tasks registered'.
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> [...]
> 
> This looks pretty useful. Any chance you can you make it work on top
> of the 5-patch series I posted ... ?

Here:

From 8cf006a1bf26a4b280841401302c99689d629e0a Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 1 Oct 2009 11:09:40 -0400
Subject: [PATCH 1/1] restart debug: add final process tree status (v2)

Have tasks in sys_restart keep some status in a list off
of checkpoint_ctx, and print this info when the checkpoint_ctx
is freed.

This version is mainly just ported against ckpt-v18-hallyn.

Sample output:

[3519:2:c/r:free_per_task_status:207] 3 tasks registered, nr_tasks was 0 nr_total 0
[3519:2:c/r:free_per_task_status:210] active pid was 1, ctx->errno 0
[3519:2:c/r:free_per_task_status:212] kflags 6 uflags 0 oflags 1
[3519:2:c/r:free_per_task_status:214] task 0 to run was 2
[3519:2:c/r:free_per_task_status:217] pid 3517
[3519:2:c/r:free_per_task_status:219] it was coordinator
[3519:2:c/r:free_per_task_status:227] it was running
[3519:2:c/r:free_per_task_status:217] pid 3519
[3519:2:c/r:free_per_task_status:223] it was the root task
[3519:2:c/r:free_per_task_status:229] it was a normal task
[3519:2:c/r:free_per_task_status:217] pid 3520
[3519:2:c/r:free_per_task_status:221] it was a ghost

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c             |  106 ++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c                 |   57 ++++++++++++++++++++
 include/linux/checkpoint_types.h |   20 +++++++
 3 files changed, 183 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index b12c8bd..1f356c0 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -26,6 +26,98 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#ifdef CONFIG_CHECKPOINT_DEBUG
+static struct ckpt_task_status *ckpt_debug_checkin(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return NULL;
+	s->pid = current->pid;
+	s->error = 0;
+	s->flags = RESTART_DBG_WAITING;
+	if (current == ctx->root_task)
+		s->flags |= RESTART_DBG_ROOT;
+	list_add_tail(&s->list, &ctx->per_task_status);
+	return s;
+}
+
+static struct ckpt_task_status *getme(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = NULL;
+	list_for_each_entry(s, &ctx->per_task_status, list) {
+		if (s->pid == current->pid)
+			break;
+	}
+	if (!s || s->pid != current->pid)
+		return NULL;
+	return s;
+}
+
+static void ckpt_debug_coord(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+
+	s = ckpt_debug_checkin(ctx);
+	if (s)
+		s->flags |= RESTART_DBG_COORD;
+}
+
+static void ckpt_debug_ghost(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+
+	s = ckpt_debug_checkin(ctx);
+	if (s)
+		s->flags |= RESTART_DBG_GHOST;
+}
+
+static void ckpt_debug_normal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+
+	s = ckpt_debug_checkin(ctx);
+	if (s)
+		s->flags |= RESTART_DBG_NORMAL;
+}
+
+static void ckpt_debug_log_error(struct ckpt_ctx *ctx, int err)
+{
+	struct ckpt_task_status *s = getme(ctx);
+	if (!s)
+		return;
+	s->error = err;
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags &= ~RESTART_DBG_RUNNING;
+	if (err)
+		s->flags |= RESTART_DBG_FAILED;
+	else
+		s->flags |= RESTART_DBG_SUCCESS;
+}
+
+static void ckpt_debug_log_running(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = getme(ctx);
+	if (!s)
+		return;
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags |= RESTART_DBG_RUNNING;
+}
+#else
+static inline void ckpt_debug_checkin(struct ckpt_ctx *ctx)
+{}
+static inline void ckpt_debug_coord(struct ckpt_ctx *ctx)
+{}
+static inline void ckpt_debug_ghost(struct ckpt_ctx *ctx)
+{}
+static inline void ckpt_debug_normal(struct ckpt_ctx *ctx)
+{}
+static inline void ckpt_debug_log_error(struct ckpt_ctx *ctx, int err)
+{}
+static inline void ckpt_debug_log_running(struct ckpt_ctx *ctx)
+{}
+#endif
+
 static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 {
 	char *ptr;
@@ -680,11 +772,17 @@ static int do_ghost_task(void)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
+	ckpt_debug_ghost(ctx);
+
+	ckpt_debug_log_running(ctx);
+
 	current->flags |= PF_RESTARTING;
 
 	ret = wait_event_interruptible(ctx->ghostq,
 				       all_tasks_activated(ctx) ||
 				       ckpt_test_ctx_error(ctx));
+
+	ckpt_debug_log_error(ctx, 0);
 	if (ret < 0)
 		restore_notify_error(ctx, ret);
 
@@ -752,6 +850,8 @@ static int do_restore_task(void)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
+	ckpt_debug_normal(ctx);
+
 	current->flags |= PF_RESTARTING;
 
 	ret = wait_sync_threads();
@@ -767,6 +867,8 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	ckpt_debug_log_running(ctx);
+
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
 		ret = zombie;
@@ -791,6 +893,7 @@ static int do_restore_task(void)
 	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
  out:
+	ckpt_debug_log_error(ctx, ret);
 	if (ret < 0)
 		restore_notify_error(ctx, ret);
 
@@ -964,6 +1067,9 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	ckpt_debug_coord(ctx);
+	ckpt_debug_log_running(ctx);
+
 	ret = restore_read_header(ctx);
 	ckpt_debug("restore header: %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7604089..b98812b 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -188,10 +188,64 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 	kfree(ctx->tasks_arr);
 }
 
+#ifdef CONFIG_CHECKPOINT_DEBUG
+static void free_per_task_status(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s, *p;
+	int i, count = 0;
+
+	/* The per-task debug info is for restart only */
+	if (!(ctx->kflags & CKPT_CTX_RESTART))
+		return;
+
+	/* See how many tasks registered.  Tasks which didn't reach
+	 * sys_restart() won't have registered.  So if this count is
+	 * not the same as ctx->nr_total, that's a warning bell */
+	list_for_each_entry(s, &ctx->per_task_status, list)
+		count++;
+	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
+		count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
+
+	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
+		ctx->errno);
+	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
+		ctx->uflags, ctx->oflags);
+	for (i = 0; i < ctx->active_pid; i++)
+		ckpt_debug("task %d to run was %d\n", i, ctx->pids_arr[i].vpid);
+
+	list_for_each_entry_safe(s, p, &ctx->per_task_status, list) {
+		ckpt_debug("pid %d\n", s->pid);
+		if (s->flags & RESTART_DBG_COORD)
+			ckpt_debug("it was coordinator\n");
+		if (s->flags & RESTART_DBG_GHOST)
+			ckpt_debug("it was a ghost\n");
+		if (s->flags & RESTART_DBG_ROOT)
+			ckpt_debug("it was the root task\n");
+		if (s->flags & RESTART_DBG_WAITING)
+			ckpt_debug("it was still waiting to run restart\n");
+		if (s->flags & RESTART_DBG_RUNNING)
+			ckpt_debug("it was running\n");
+		if (s->flags & RESTART_DBG_NORMAL)
+			ckpt_debug("it was a normal task\n");
+		if (s->flags & RESTART_DBG_FAILED)
+			ckpt_debug("it finished with error %d\n", s->error);
+		if (s->flags & RESTART_DBG_FAILED)
+			ckpt_debug("it finished successfully");
+		list_del(&s->list);
+		kfree(s);
+	}
+}
+#else
+static inline void free_per_task_status(struct ckpt_ctx *ctx)
+{ }
+#endif
+
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	free_per_task_status(ctx);
+
 	if (ctx->deferqueue)
 		deferqueue_destroy(ctx->deferqueue);
 
@@ -235,6 +289,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->ktime_begin = ktime_get();
 
 	atomic_set(&ctx->refcount, 0);
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	INIT_LIST_HEAD(&ctx->per_task_status);
+#endif
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index b9393f4..198d4e9 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -78,10 +78,30 @@ struct ckpt_ctx {
 	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
 	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	struct list_head per_task_status; /* list of status for each task */
+#endif
 
 	struct ckpt_stats stats;	/* statistics */
 };
 
+#ifdef CONFIG_CHECKPOINT_DEBUG
+struct ckpt_task_status {
+	pid_t pid;
+#define RESTART_DBG_ROOT	(1 << 0)
+#define RESTART_DBG_GHOST	(1 << 1)
+#define RESTART_DBG_COORD	(1 << 2)
+#define RESTART_DBG_NORMAL	(1 << 3)
+#define RESTART_DBG_WAITING	(1 << 4)
+#define RESTART_DBG_RUNNING	(1 << 5)
+#define RESTART_DBG_FAILED	(1 << 6)
+#define RESTART_DBG_SUCCESS	(1 << 7)
+	int flags;
+	int error;
+	struct list_head list;
+};
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
-- 
1.6.1
