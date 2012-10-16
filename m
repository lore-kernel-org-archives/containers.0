From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/7] cgroup_freezer: don't stall transition to FROZEN for
	PF_NOFREEZE or PF_FREEZER_SKIP tasks
Date: Tue, 16 Oct 2012 15:28:43 -0700
Message-ID: <1350426526-14254-5-git-send-email-tj@kernel.org>
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

cgroup_freezer doesn't transition from FREEZING to FROZEN if the
cgroup contains PF_NOFREEZE tasks or tasks sleeping with
PF_FREEZER_SKIP set.

Only kernel tasks can be non-freezable (PF_NOFREEZE) and there's
nothing cgroup_freezer or userland can do about or to it.  It's
pointless to stall the transition for PF_NOFREEZE tasks.

PF_FREEZER_SKIP indicates that the task can be skipped when
determining whether frozen state is reached.  A task with
PF_FREEZER_SKIP is guaranteed to perform try_to_freeze() after it
wakes up and can be considered frozen much like stopped or traced
tasks.  Note that a vfork parent uses PF_FREEZER_SKIP while waiting
for the child.

This updates update_if_frozen() such that it only considers freezable
tasks and treats %true freezer_should_skip() tasks as frozen.

This allows cgroups w/ kthreads and vfork parents successfully reach
FROZEN state.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
---
 kernel/cgroup_freezer.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 05d5218..557f367 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -214,10 +214,18 @@ static void update_if_frozen(struct cgroup *cgroup,
 
 	cgroup_iter_start(cgroup, &it);
 	while ((task = cgroup_iter_next(cgroup, &it))) {
-		ntotal++;
-		if (freezing(task) && (frozen(task) ||
-				       task_is_stopped_or_traced(task)))
-			nfrozen++;
+		if (freezing(task)) {
+			ntotal++;
+			/*
+			 * freezer_should_skip() indicates that the task
+			 * should be skipped when determining freezing
+			 * completion.  Consider it frozen in addition to
+			 * the usual frozen condition.
+			 */
+			if (frozen(task) || task_is_stopped_or_traced(task) ||
+			    freezer_should_skip(task))
+				nfrozen++;
+		}
 	}
 
 	if (old_state == CGROUP_THAWED) {
-- 
1.7.7.3
