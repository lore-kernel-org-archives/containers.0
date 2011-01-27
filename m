From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Remove update_freezer_state()
Date: Thu, 27 Jan 2011 05:14:20 -0800
Message-ID: <bcd897d608bc2de8867fb3a031e5affc352fb559.1296134057.git.matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

update_freezer_state() was renamed to update_if_frozen(). Use the
newly name of the function and remove the old copy.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |   33 +--------------------------------
 1 files changed, 1 insertions(+), 32 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 507cb43..2691bd8 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -72,37 +72,6 @@ static bool is_task_frozen_enough(struct task_struct *task)
 }
 
 /*
- * caller must hold freezer->lock
- */
-static void update_freezer_state(struct cgroup *cgroup,
-				 struct freezer *freezer)
-{
-	struct cgroup_iter it;
-	struct task_struct *task;
-	unsigned int nfrozen = 0, ntotal = 0;
-
-	cgroup_iter_start(cgroup, &it);
-	while ((task = cgroup_iter_next(cgroup, &it))) {
-		ntotal++;
-		if (is_task_frozen_enough(task))
-			nfrozen++;
-	}
-
-	/*
-	 * Transition to FROZEN when no new tasks can be added ensures
-	 * that we never exist in the FROZEN state while there are unfrozen
-	 * tasks.
-	 */
-	if (nfrozen == ntotal)
-		freezer->state = CGROUP_FROZEN;
-	else if (nfrozen > 0)
-		freezer->state = CGROUP_FREEZING;
-	else
-		freezer->state = CGROUP_THAWED;
-	cgroup_iter_end(cgroup, &it);
-}
-
-/*
  * cgroups_write_string() limits the size of freezer state strings to
  * CGROUP_LOCAL_BUFFER_SIZE
  */
@@ -485,7 +454,7 @@ static int freezer_checkpointing(struct task_struct *task,
 		/* May be in middle of a lazy FREEZING -> FROZEN transition */
 		if (cgroup_lock_live_group(css->cgroup)) {
 			spin_lock_irq(&freezer->lock);
-			update_freezer_state(css->cgroup, freezer);
+			update_if_frozen(css->cgroup, freezer);
 			spin_unlock_irq(&freezer->lock);
 			cgroup_unlock();
 		}
-- 
1.6.3.3
