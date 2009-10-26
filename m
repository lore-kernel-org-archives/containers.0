From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] [RFC] Enable non-blocking writes to the cgroup
	freezer.state file
Date: Mon, 26 Oct 2009 08:15:30 -0700
Message-ID: <1256570129-13107-2-git-send-email-matthltc@us.ibm.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Currently the cgroup freezer never blocks in the kernel.

This patch uses the f_flags parameter of the cgroups write_string
op to determine if blocking in the kernel is requested. Without
O_NONBLOCK the write blocks until freezing fails for other reasons
(though only -EAGAIN is possible now), the writer receives a signal,
or the cgroup is completely frozen. When O_NONBLOCK is set
writes to the freezer state return when some of the tasks in the
cgroup could not be frozen.

The change to the num_cant_freeze_now count enables blocking
while the test of dont_block outside of all the locks re-enables
non-blocking operations when O_NONBLOCK is set.

The change to EAGAIN from EBUSY for the write path should bring us
in line with standard non-blocking errno values (See Bugs/Weirdness).

Passes existing LTP tests and a vfork testcase from Nathan Lynch.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

NOTE: This patch has one small hunk (passing !!O_NONBLOCK to
	freezer_change_state()) for the checkpoint/restart tree. The
	rest applies to mainline too.

Bugs/Weirdness to look into:
	A task freezing itself now gets EINTR
		freeze_self_thaw.sh 9/11: TINFO  3910 freezing itself
		/bin/echo: write error: Interrupted system call

		I think this happens after it gets woken up, not after
		it becomes frozen:

	stop_freeze_sleep_thaw_cont consistently WARNS during test
		cleanup.

	When using O_NONBLOCK I am getting E2BIG instead of EAGAIN
		for some reason.
---
 kernel/cgroup_freezer.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index c97680f..9fe9e65 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -288,12 +288,11 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 			continue;
 		if (is_task_frozen_enough(task))
 			continue;
-		if (!freezing(task) && !freezer_should_skip(task))
-			num_cant_freeze_now++;
+		num_cant_freeze_now++;
 	}
 	cgroup_iter_end(cgroup, &it);
 
-	return num_cant_freeze_now ? -EBUSY : 0;
+	return num_cant_freeze_now ? -EAGAIN : 0;
 }
 
 static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
@@ -320,7 +319,7 @@ static int freezer_change_state(struct cgroup *cgroup,
 
 	spin_lock_irq(&freezer->lock);
 	if (freezer->state == CGROUP_CHECKPOINTING) {
-		retval = -EBUSY;
+		retval = -EAGAIN;
 		goto out;
 	}
 	update_freezer_state(cgroup, freezer);
@@ -339,7 +338,6 @@ static int freezer_change_state(struct cgroup *cgroup,
 	}
 out:
 	spin_unlock_irq(&freezer->lock);
-
 	return retval;
 }
 
@@ -356,10 +354,22 @@ static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
 	else
 		return -EINVAL;
 
+retry:
 	if (!cgroup_lock_live_group(cgroup))
 		return -ENODEV;
 	retval = freezer_change_state(cgroup, goal_state);
 	cgroup_unlock();
+
+	if ((f_flags & O_NONBLOCK) || (retval != -EAGAIN))
+		return retval;
+
+	/* block while we haven't changed the state to the goal state */
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule();
+	__set_current_state(TASK_RUNNING);
+	if (!signal_pending(current))
+		goto retry;
+	retval = -EINTR;
 	return retval;
 }
 
-- 
1.5.6.3
