From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/5] Container Freezer: Prevent frozen tasks or cgroups from
	changing
Date: Mon, 11 Aug 2008 16:53:28 -0700
Message-ID: <20080811235325.917183517__5864.18859097666$1218500335$gmane$org@us.ibm.com>
References: <20080811235323.872291138@us.ibm.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Don't let frozen tasks or cgroups change. This means frozen tasks can't
leave their current cgroup for another cgroup. It also means that tasks
cannot be added to or removed from a cgroup in the FROZEN state. We
enforce these rules by checking for frozen tasks and cgroups in the
can_attach() function.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
Changes since v4:
v5:
	Checked use of task alloc lock for races with swsusp freeze/thaw --
		looks safe because there are explicit barriers to handle
		freeze/thaw races for individual tasks, we explicitly
		handle partial group freezing, and partial group thawing
		should be resolved without changing swsusp's loop. This should
		answer Li Zefan's last comment re: races between freeze and
		thaw.

 kernel/cgroup_freezer.c |   43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

Index: linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/cgroup_freezer.c
+++ linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
@@ -145,22 +145,40 @@ static void freezer_destroy(struct cgrou
 	kfree(cgroup_freezer(cgroup));
 }
 
+/* Task is frozen or will freeze immediately when next it gets woken */
+static bool is_task_frozen_enough(struct task_struct *task)
+{
+	return frozen(task) ||
+		(task_is_stopped_or_traced(task) && freezing(task));
+}
 
+/*
+ * The call to cgroup_lock() in the freezer.state write method prevents
+ * a write to that file racing against an attach, and hence the
+ * can_attach() result will remain valid until the attach completes.
+ */
 static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup *new_cgroup,
 			      struct task_struct *task)
 {
 	struct freezer *freezer;
-	int retval = 0;
+	int retval;
+
+	/* Anything frozen can't move or be moved to/from */
+
+	if (is_task_frozen_enough(task))
+		return -EBUSY;
 
-	/*
-	 * The call to cgroup_lock() in the freezer.state write method prevents
-	 * a write to that file racing against an attach, and hence the
-	 * can_attach() result will remain valid until the attach completes.
-	 */
 	freezer = cgroup_freezer(new_cgroup);
 	if (freezer->state == STATE_FROZEN)
+		return -EBUSY;
+
+	retval = 0;
+	task_lock(task);
+	freezer = task_freezer(task);
+	if (freezer->state == STATE_FROZEN)
 		retval = -EBUSY;
+	task_unlock(task);
 	return retval;
 }
 
@@ -193,12 +211,7 @@ static void check_if_frozen(struct cgrou
 	cgroup_iter_start(cgroup, &it);
 	while ((task = cgroup_iter_next(cgroup, &it))) {
 		ntotal++;
-		/*
-		 * Task is frozen or will freeze immediately when next it gets
-		 * woken
-		 */
-		if (frozen(task) ||
-		    (task_is_stopped_or_traced(task) && freezing(task)))
+		if (is_task_frozen_enough(task))
 			nfrozen++;
 	}
 
@@ -249,11 +262,7 @@ static int try_to_freeze_cgroup(struct c
 	while ((task = cgroup_iter_next(cgroup, &it))) {
 		if (!freeze_task(task, true))
 			continue;
-		if (task_is_stopped_or_traced(task) && freezing(task))
-			/*
-			 * The freeze flag is set so these tasks will
-			 * immediately go into the fridge upon waking.
-			 */
+		if (is_task_frozen_enough(task))
 			continue;
 		if (!freezing(task) && !freezer_should_skip(task))
 			num_cant_freeze_now++;

-- 
