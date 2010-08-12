From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: [PATCH 2/3] cgroup_freezer: Fix can_attach to prohibit moving from/to
	freezing/frozen cgroups
Date: Thu, 12 Aug 2010 11:45:22 +0200
Message-ID: <1281606323-16245-3-git-send-email-tomasz.buchert__14711.4661442631$1281606394$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<1281606323-16245-1-git-send-email-tomasz.buchert@inria.fr>
	<1281606323-16245-2-git-send-email-tomasz.buchert@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281606323-16245-2-git-send-email-tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Id: containers.vger.kernel.org

It is possible to move a task from its cgroup
even if this group is 'FREEZING'. This results in
a nasty bug - the moved task will become frozen OUTSIDE
its original cgroup and will remain in a permanent 'D' state.

This patch allows to migrate the task only between THAWED cgroups.

This behavior was observed and easily reproduced on
a single core laptop. Notice that reproducibility depends
highly on the machine used. Program and instructions how
to reproduce the bug can be fetched from:
http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c

Signed-off-by: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
---
 kernel/cgroup_freezer.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 321e2a0..c287627 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -173,24 +173,25 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
-	 *
-	 * Since orig_freezer->state == FROZEN means that @task has been
-	 * frozen, so it's sufficient to check the latter condition.
 	 */
 
-	if (is_task_frozen_enough(task))
+	freezer = cgroup_freezer(new_cgroup);
+	if (freezer->state != CGROUP_THAWED)
 		return -EBUSY;
 
-	freezer = cgroup_freezer(new_cgroup);
-	if (freezer->state == CGROUP_FROZEN)
+	rcu_read_lock();
+	if (__cgroup_freezing_or_frozen(task)) {
+		rcu_read_unlock();
 		return -EBUSY;
+	}
+	rcu_read_unlock();
 
 	if (threadgroup) {
 		struct task_struct *c;
 
 		rcu_read_lock();
 		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (is_task_frozen_enough(c)) {
+			if (__cgroup_freezing_or_frozen(c)) {
 				rcu_read_unlock();
 				return -EBUSY;
 			}
-- 
1.6.3.3
