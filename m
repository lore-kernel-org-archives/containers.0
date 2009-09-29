From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] restart: make sure all tasks are in sys_restart
Date: Tue, 29 Sep 2009 11:53:42 -0500
Message-ID: <20090929165342.GA10076@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Make sure that all prepared tasks are in sys_restart before the
coordinator proceeds.  Otherwise, it was possible for the last
task actually in sys_restart to sync before the straggler was in
sys_restart, sending that task a signal and causing that task to
exit.  Then since there are not enough tasks completing restart,
the restart operation ends up hanging, waiting for the killed task.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c             |   53 ++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c                 |    1 +
 include/linux/checkpoint_types.h |    2 +
 3 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 543b380..849bda5 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -655,13 +655,35 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 static int do_ghost_task(void)
 {
 	struct ckpt_ctx *ctx;
+	int ret;
 
 	ctx = wait_checkpoint_ctx();
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
+	/*
+	 * Wait until coordinator task has completed prepare_descendants().
+	 * Note that prepare_descendants() wakes each task one a time
+	 * finishing the wait_checkpoint_ctx() above.  We may want to change
+	 * that flow so tasks only sleep once, but this works for now.
+	 */
+	ret = wait_event_interruptible(ctx->waitq,
+					atomic_read(&ctx->nr_running));
+	if (ret) {
+		ckpt_debug("wait for coordinator prep returned %d\n", ret);
+		return ret;
+	}
+	/*
+	 * Now each prepared task decrements nr_running, and, when that
+	 * hits zero, wakes the coordinator.  That way the coordinator
+	 * knows that all tasks are in sys_restart(0
+	 */
+	if (atomic_dec_and_test(&ctx->nr_running))
+		complete(&ctx->all_ready);
+
 	current->flags |= PF_RESTARTING;
 
+	/* Finally wait for all ghosts to be woken up - to die */
 	wait_event_interruptible(ctx->ghostq,
 				 all_tasks_activated(ctx) ||
 				 ckpt_test_ctx_error(ctx));
@@ -682,6 +704,26 @@ static int do_restore_task(void)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
+	/*
+	 * Wait until coordinator task has completed prepare_descendants().
+	 * Note that prepare_descendants() wakes each task one a time
+	 * finishing the wait_checkpoint_ctx() above.  We may want to change
+	 * that flow so tasks only sleep once, but this works for now.
+	 */
+	ret = wait_event_interruptible(ctx->waitq,
+					atomic_read(&ctx->nr_running));
+	if (ret) {
+		ckpt_debug("wait for coordinator prep returned %d\n", ret);
+		return ret;
+	}
+	/*
+	 * Now each prepared task decrements nr_running, and, when that
+	 * hits zero, wakes the coordinator.  That way the coordinator
+	 * knows that all tasks are in sys_restart(0
+	 */
+	if (atomic_dec_and_test(&ctx->nr_running))
+		complete(&ctx->all_ready);
+
 	current->flags |= PF_RESTARTING;
 
 	/* wait for our turn, do the restore, and tell next task in line */
@@ -814,6 +856,7 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 		ret = -ESRCH;
 
 	atomic_set(&ctx->nr_total, nr_pids);
+	atomic_set(&ctx->nr_running, nr_pids);
 	return ret;
 }
 
@@ -948,6 +991,16 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		ret = prepare_descendants(ctx, ctx->root_task);
 		if (ret < 0)
 			goto out;
+
+		/* tell tasks we're ready for them to dec  ctx->nr_running */
+		wake_up_all(&ctx->waitq);
+		/* ctx->nr_running hit 0, all our tasks are in sys_restart */
+		ret = wait_for_completion_interruptible(&ctx->all_ready);
+		if (ret) {
+			ckpt_debug("waiting on all_ready returned %d\n", ret);
+			goto out;
+		}
+
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
 		if (ret < 0)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 76a3fa9..d48e261 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -233,6 +233,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
+	init_completion(&ctx->all_ready);
 
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 9b7b4dd..2a854e0 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -69,8 +69,10 @@ struct ckpt_ctx {
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
 	atomic_t nr_total;		/* total tasks count (with ghosts) */
+	atomic_t nr_running;		/* countdown of tasks in sys_restart */
 	int active_pid;			/* (next) position in pids array */
 	struct completion complete;	/* completion for container root */
+	struct completion all_ready;	/* all tasks are in sys_restart */
 	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
 	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
-- 
1.6.1
