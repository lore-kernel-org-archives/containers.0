From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/7] cgroup_freezer: prepare update_if_frozen() for locking
	change
Date: Tue, 16 Oct 2012 15:28:45 -0700
Message-ID: <1350426526-14254-7-git-send-email-tj@kernel.org>
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

Locking will change such that migration can happen while
freezer_read/write() is in progress.  This means that
update_if_frozen() can no longer assume that all tasks in the cgroup
coform to the current freezer state - newly migrated tasks which
haven't finished freezer_attach() yet might be in any state.

This patch updates update_if_frozen() such that it no longer verifies
task states against freezer state.  It now simply decides whether
FREEZING stage is complete.

This removal of verification makes it meaningless to call from
freezer_change_state().  Drop it and move the fast exit test from
freezer_read() - the only left caller - to update_if_frozen().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |   43 +++++++++++++++++--------------------------
 1 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 0b0e105..3d45503 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -213,41 +213,39 @@ out:
 }
 
 /*
- * caller must hold freezer->lock
+ * We change from FREEZING to FROZEN lazily if the cgroup was only
+ * partially frozen when we exitted write.  Caller must hold freezer->lock.
+ *
+ * Task states and freezer state might disagree while tasks are being
+ * migrated into @cgroup, so we can't verify task states against @freezer
+ * state here.  See freezer_attach() for details.
  */
-static void update_if_frozen(struct cgroup *cgroup,
-				 struct freezer *freezer)
+static void update_if_frozen(struct cgroup *cgroup, struct freezer *freezer)
 {
 	struct cgroup_iter it;
 	struct task_struct *task;
-	unsigned int nfrozen = 0, ntotal = 0;
-	enum freezer_state old_state = freezer->state;
+
+	if (freezer->state != CGROUP_FREEZING)
+		return;
 
 	cgroup_iter_start(cgroup, &it);
+
 	while ((task = cgroup_iter_next(cgroup, &it))) {
 		if (freezing(task)) {
-			ntotal++;
 			/*
 			 * freezer_should_skip() indicates that the task
 			 * should be skipped when determining freezing
 			 * completion.  Consider it frozen in addition to
 			 * the usual frozen condition.
 			 */
-			if (frozen(task) || task_is_stopped_or_traced(task) ||
-			    freezer_should_skip(task))
-				nfrozen++;
+			if (!frozen(task) && !task_is_stopped_or_traced(task) &&
+			    !freezer_should_skip(task))
+				goto notyet;
 		}
 	}
 
-	if (old_state == CGROUP_THAWED) {
-		BUG_ON(nfrozen > 0);
-	} else if (old_state == CGROUP_FREEZING) {
-		if (nfrozen == ntotal)
-			freezer->state = CGROUP_FROZEN;
-	} else { /* old_state == CGROUP_FROZEN */
-		BUG_ON(nfrozen != ntotal);
-	}
-
+	freezer->state = CGROUP_FROZEN;
+notyet:
 	cgroup_iter_end(cgroup, &it);
 }
 
@@ -262,13 +260,8 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 
 	freezer = cgroup_freezer(cgroup);
 	spin_lock_irq(&freezer->lock);
+	update_if_frozen(cgroup, freezer);
 	state = freezer->state;
-	if (state == CGROUP_FREEZING) {
-		/* We change from FREEZING to FROZEN lazily if the cgroup was
-		 * only partially frozen when we exitted write. */
-		update_if_frozen(cgroup, freezer);
-		state = freezer->state;
-	}
 	spin_unlock_irq(&freezer->lock);
 	cgroup_unlock();
 
@@ -306,8 +299,6 @@ static void freezer_change_state(struct cgroup *cgroup,
 
 	spin_lock_irq(&freezer->lock);
 
-	update_if_frozen(cgroup, freezer);
-
 	switch (goal_state) {
 	case CGROUP_THAWED:
 		if (freezer->state != CGROUP_THAWED)
-- 
1.7.7.3
