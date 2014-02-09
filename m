From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/16] cgroup: enable task_cg_lists on the first cgroup mount
Date: Sun,  9 Feb 2014 08:52:31 -0500
Message-ID: <1391953964-22088-4-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Tasks are not linked on their css_sets until cgroup task iteration is
actually used.  This is to avoid incurring overhead on the fork and
exit paths for systems which have cgroup compiled in but don't use it.

This lazy binding also affects the task migration path.  It has to be
careful so that it doesn't link tasks to css_sets when task_cg_lists
linking is not enabled yet.  Unfortunately, this conditional linking
in the migration path interferes with planned migration updates.

This patch moves the lazy binding a bit earlier, to the first cgroup
mount.  It's a clear indication that cgroup is being used on the
system and task_cg_lists linking is highly likely to be enabled soon
anyway through "tasks" and "cgroup.procs" files.

This allows cgroup_task_migrate() to always link @tsk->cg_list.  Note
that it may still race with cgroup_post_fork() but who wins that race
is inconsequential.

While at it, make use_task_css_set_links a bool, add sanity checks in
cgroup_enable_task_cg_lists() and css_task_iter_start(), and update
the former so that it's guaranteed and assumes to run only once.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 40 +++++++++++++++++++++++++++-------------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index caed061..efae7e2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -173,6 +173,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
 static void cgroup_pidlist_destroy_all(struct cgroup *cgrp);
+static void cgroup_enable_task_cg_lists(void);
 
 /**
  * cgroup_css - obtain a cgroup's css for the specified subsystem
@@ -375,7 +376,7 @@ static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
  * fork()/exit() overhead for people who have cgroups compiled into their
  * kernel but not actually in use.
  */
-static int use_task_css_set_links __read_mostly;
+static bool use_task_css_set_links __read_mostly;
 
 static void __put_css_set(struct css_set *cset, int taskexit)
 {
@@ -1439,6 +1440,13 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	struct cgroup_sb_opts opts;
 	struct dentry *dentry;
 	int ret;
+
+	/*
+	 * The first time anyone tries to mount a cgroup, enable the list
+	 * linking each css_set to its tasks and fix up all existing tasks.
+	 */
+	if (!use_task_css_set_links)
+		cgroup_enable_task_cg_lists();
 retry:
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
@@ -1692,8 +1700,7 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 
 	/* Update the css_set linked lists if we're using them */
 	write_lock(&css_set_lock);
-	if (!list_empty(&tsk->cg_list))
-		list_move(&tsk->cg_list, &new_cset->tasks);
+	list_move(&tsk->cg_list, &new_cset->tasks);
 	write_unlock(&css_set_lock);
 
 	/*
@@ -2360,13 +2367,19 @@ int cgroup_task_count(const struct cgroup *cgrp)
  * To reduce the fork() overhead for systems that are not actually using
  * their cgroups capability, we don't maintain the lists running through
  * each css_set to its tasks until we see the list actually used - in other
- * words after the first call to css_task_iter_start().
+ * words after the first mount.
  */
 static void cgroup_enable_task_cg_lists(void)
 {
 	struct task_struct *p, *g;
+
 	write_lock(&css_set_lock);
-	use_task_css_set_links = 1;
+
+	if (use_task_css_set_links)
+		goto out_unlock;
+
+	use_task_css_set_links = true;
+
 	/*
 	 * We need tasklist_lock because RCU is not safe against
 	 * while_each_thread(). Besides, a forking task that has passed
@@ -2377,16 +2390,22 @@ static void cgroup_enable_task_cg_lists(void)
 	read_lock(&tasklist_lock);
 	do_each_thread(g, p) {
 		task_lock(p);
+
+		WARN_ON_ONCE(!list_empty(&p->cg_list) ||
+			     task_css_set(p) != &init_css_set);
+
 		/*
 		 * We should check if the process is exiting, otherwise
 		 * it will race with cgroup_exit() in that the list
 		 * entry won't be deleted though the process has exited.
 		 */
-		if (!(p->flags & PF_EXITING) && list_empty(&p->cg_list))
+		if (!(p->flags & PF_EXITING))
 			list_add(&p->cg_list, &task_css_set(p)->tasks);
+
 		task_unlock(p);
 	} while_each_thread(g, p);
 	read_unlock(&tasklist_lock);
+out_unlock:
 	write_unlock(&css_set_lock);
 }
 
@@ -2619,13 +2638,8 @@ void css_task_iter_start(struct cgroup_subsys_state *css,
 			 struct css_task_iter *it)
 	__acquires(css_set_lock)
 {
-	/*
-	 * The first time anyone tries to iterate across a css, we need to
-	 * enable the list linking each css_set to its tasks, and fix up
-	 * all existing tasks.
-	 */
-	if (!use_task_css_set_links)
-		cgroup_enable_task_cg_lists();
+	/* no one should try to iterate before mounting cgroups */
+	WARN_ON_ONCE(!use_task_css_set_links);
 
 	read_lock(&css_set_lock);
 
-- 
1.8.5.3
