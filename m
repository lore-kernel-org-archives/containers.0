From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Tue, 10 Aug 2010 21:53:21 +0200
Message-ID: <1281470001-14320-1-git-send-email-tomasz.buchert__37951.1227169589$1281470149$gmane$org@inria.fr>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Id: containers.vger.kernel.org

Writing 'FROZEN' to freezer.state file does not
forbid the task to be moved away from its cgroup
(for a very short time). Nevertheless the moved task
can become frozen OUTSIDE its cgroup which puts
discussed task in a permanent 'D' state.

This patch forbids migration of either FROZEN
or FREEZING tasks.

This behavior was observed and easily reproduced on
a single core laptop. Program and instructions how
to reproduce the bug can be fetched from:
http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c

Signed-off-by: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
---
 kernel/cgroup_freezer.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index ce71ed5..e49aa8c 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -161,6 +161,12 @@ static bool is_task_frozen_enough(struct task_struct *task)
 		(task_is_stopped_or_traced(task) && freezing(task));
 }
 
+/* Task is in a state that forbids any cgroup migration. */
+static bool is_task_pinned_down(struct task_struct *task)
+{
+	return freezing(task) || frozen(task);
+}
+
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -179,7 +185,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	 * frozen, so it's sufficient to check the latter condition.
 	 */
 
-	if (is_task_frozen_enough(task))
+	if (is_task_pinned_down(task))
 		return -EBUSY;
 
 	freezer = cgroup_freezer(new_cgroup);
@@ -191,7 +197,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 
 		rcu_read_lock();
 		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (is_task_frozen_enough(c)) {
+			if (is_task_pinned_down(c)) {
 				rcu_read_unlock();
 				return -EBUSY;
 			}
-- 
1.6.3.3
