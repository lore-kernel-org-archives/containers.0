From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/7] cgroup_freezer: make it official that writes to
	freezer.state don't fail
Date: Tue, 16 Oct 2012 15:28:42 -0700
Message-ID: <1350426526-14254-4-git-send-email-tj@kernel.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1350426526-14254-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

try_to_freeze_cgroup() has condition checks which are intended to fail
the write operation to freezer.state if there are tasks which can't be
frozen.  The condition checks have been broken for quite some time
now.  freeze_task() returns %false if the target task can't be frozen,
so num_cant_freeze_now is never incremented.

In addition, strangely, cgroup freezing proceeds even after the write
is failed, which is rather broken.

This patch rips out the non-working code intended to fail the write to
freezer.state when the cgroup contains non-freezable tasks and makes
it official that writes to freezer.state succeed whether there are
non-freezable tasks in the cgroup or not.

This leaves is_task_frozen_enough() with only one user -
upste_if_frozen().  Collapse it into the caller.  Note that this
removes an extra call to freezing().

This doesn't cause any userland behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
---
 kernel/cgroup_freezer.c |   43 +++++++++++--------------------------------
 1 files changed, 11 insertions(+), 32 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 12bfedb..05d5218 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -150,13 +150,6 @@ static void freezer_destroy(struct cgroup *cgroup)
 	kfree(freezer);
 }
 
-/* task is frozen or will freeze immediately when next it gets woken */
-static bool is_task_frozen_enough(struct task_struct *task)
-{
-	return frozen(task) ||
-		(task_is_stopped_or_traced(task) && freezing(task));
-}
-
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -222,7 +215,8 @@ static void update_if_frozen(struct cgroup *cgroup,
 	cgroup_iter_start(cgroup, &it);
 	while ((task = cgroup_iter_next(cgroup, &it))) {
 		ntotal++;
-		if (freezing(task) && is_task_frozen_enough(task))
+		if (freezing(task) && (frozen(task) ||
+				       task_is_stopped_or_traced(task)))
 			nfrozen++;
 	}
 
@@ -264,24 +258,15 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 	return 0;
 }
 
-static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
+static void freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 {
 	struct cgroup_iter it;
 	struct task_struct *task;
-	unsigned int num_cant_freeze_now = 0;
 
 	cgroup_iter_start(cgroup, &it);
-	while ((task = cgroup_iter_next(cgroup, &it))) {
-		if (!freeze_task(task))
-			continue;
-		if (is_task_frozen_enough(task))
-			continue;
-		if (!freezing(task) && !freezer_should_skip(task))
-			num_cant_freeze_now++;
-	}
+	while ((task = cgroup_iter_next(cgroup, &it)))
+		freeze_task(task);
 	cgroup_iter_end(cgroup, &it);
-
-	return num_cant_freeze_now ? -EBUSY : 0;
 }
 
 static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
@@ -295,13 +280,10 @@ static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 	cgroup_iter_end(cgroup, &it);
 }
 
-static int freezer_change_state(struct cgroup *cgroup,
-				enum freezer_state goal_state)
+static void freezer_change_state(struct cgroup *cgroup,
+				 enum freezer_state goal_state)
 {
-	struct freezer *freezer;
-	int retval = 0;
-
-	freezer = cgroup_freezer(cgroup);
+	struct freezer *freezer = cgroup_freezer(cgroup);
 
 	spin_lock_irq(&freezer->lock);
 
@@ -318,22 +300,19 @@ static int freezer_change_state(struct cgroup *cgroup,
 		if (freezer->state == CGROUP_THAWED)
 			atomic_inc(&system_freezing_cnt);
 		freezer->state = CGROUP_FREEZING;
-		retval = try_to_freeze_cgroup(cgroup, freezer);
+		freeze_cgroup(cgroup, freezer);
 		break;
 	default:
 		BUG();
 	}
 
 	spin_unlock_irq(&freezer->lock);
-
-	return retval;
 }
 
 static int freezer_write(struct cgroup *cgroup,
 			 struct cftype *cft,
 			 const char *buffer)
 {
-	int retval;
 	enum freezer_state goal_state;
 
 	if (strcmp(buffer, freezer_state_strs[CGROUP_THAWED]) == 0)
@@ -345,9 +324,9 @@ static int freezer_write(struct cgroup *cgroup,
 
 	if (!cgroup_lock_live_group(cgroup))
 		return -ENODEV;
-	retval = freezer_change_state(cgroup, goal_state);
+	freezer_change_state(cgroup, goal_state);
 	cgroup_unlock();
-	return retval;
+	return 0;
 }
 
 static struct cftype files[] = {
-- 
1.7.7.3
