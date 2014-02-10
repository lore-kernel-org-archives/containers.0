From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/5] cgroup: add css_set->mg_tasks
Date: Mon, 10 Feb 2014 15:21:30 -0500
Message-ID: <1392063694-26465-2-git-send-email-tj@kernel.org>
References: <1392063694-26465-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392063694-26465-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently, while migrating tasks from one cgroup to another,
cgroup_attach_task() builds a flex array of all target tasks;
unfortunately, this has a couple issues.

* Flex array has size limit.  On 64bit, struct task_and_cgroup is
  24bytes making the flex element limit around 87k.  It is a high
  number but not impossible to hit.  This means that the current
  cgroup implementation can't migrate a process with more than 87k
  threads.

* Process migration involves memory allocation whose size is dependent
  on the number of threads the process has.  This means that cgroup
  core can't guarantee success or failure of multi-process migrations
  as memory allocation failure can happen in the middle.  This is in
  part because cgroup can't grab threadgroup locks of multiple
  processes at the same time, so when there are multiple processes to
  migrate, it is imposible to tell how many tasks are to be migrated
  beforehand.

  Note that this already affects cgroup_transfer_tasks().  cgroup
  currently cannot guarantee atomic success or failure of the
  operation.  It may fail in the middle and after such failure cgroup
  doesn't have enough information to roll back properly.  It just
  aborts with some tasks migrated and others not.

To resolve the situation, we're going to use task->cg_list during
migration too.  Instead of building a separate array, target tasks
will be linked into a dedicated migration list_head on the owning
css_set.  Tasks on the migration list are treated the same as tasks on
the usual tasks list; however, being on a separate list allows cgroup
migration code path to keep track of the target tasks by simply
keeping the list of css_sets with tasks being migrated, making
unpredictable dynamic allocation unnecessary.

In prepartion of such migration path update, this patch introduces
css_set->mg_tasks list and updates css_set task iterations so that
they walk both css_set->tasks and ->mg_tasks.  Note that ->mg_tasks
isn't used yet.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  8 ++++++--
 kernel/cgroup.c        | 56 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 21887b6..559a4cf 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -322,10 +322,14 @@ struct css_set {
 	struct hlist_node hlist;
 
 	/*
-	 * List running through all tasks using this cgroup
-	 * group. Protected by css_set_lock
+	 * Lists running through all tasks using this cgroup group.
+	 * mg_tasks lists tasks which belong to this cset but are in the
+	 * process of being migrated out or in.  Protected by
+	 * css_set_rwsem, but, during migration, once tasks are moved to
+	 * mg_tasks, it can be read safely while holding cgroup_mutex.
 	 */
 	struct list_head tasks;
+	struct list_head mg_tasks;
 
 	/*
 	 * List of cgrp_cset_links pointing at cgroups referenced from this
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6006710..e183466 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -644,6 +644,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	atomic_set(&cset->refcount, 1);
 	INIT_LIST_HEAD(&cset->cgrp_links);
 	INIT_LIST_HEAD(&cset->tasks);
+	INIT_LIST_HEAD(&cset->mg_tasks);
 	INIT_HLIST_NODE(&cset->hlist);
 
 	/* Copy the set of subsystem state objects generated in
@@ -2581,9 +2582,14 @@ static void css_advance_task_iter(struct css_task_iter *it)
 		}
 		link = list_entry(l, struct cgrp_cset_link, cset_link);
 		cset = link->cset;
-	} while (list_empty(&cset->tasks));
+	} while (list_empty(&cset->tasks) && list_empty(&cset->mg_tasks));
+
 	it->cset_link = l;
-	it->task = cset->tasks.next;
+
+	if (!list_empty(&cset->tasks))
+		it->task = cset->tasks.next;
+	else
+		it->task = cset->mg_tasks.next;
 }
 
 /**
@@ -2627,24 +2633,29 @@ struct task_struct *css_task_iter_next(struct css_task_iter *it)
 {
 	struct task_struct *res;
 	struct list_head *l = it->task;
-	struct cgrp_cset_link *link;
+	struct cgrp_cset_link *link = list_entry(it->cset_link,
+					struct cgrp_cset_link, cset_link);
 
 	/* If the iterator cg is NULL, we have no tasks */
 	if (!it->cset_link)
 		return NULL;
 	res = list_entry(l, struct task_struct, cg_list);
-	/* Advance iterator to find next entry */
+
+	/*
+	 * Advance iterator to find next entry.  cset->tasks is consumed
+	 * first and then ->mg_tasks.  After ->mg_tasks, we move onto the
+	 * next cset.
+	 */
 	l = l->next;
-	link = list_entry(it->cset_link, struct cgrp_cset_link, cset_link);
-	if (l == &link->cset->tasks) {
-		/*
-		 * We reached the end of this task list - move on to the
-		 * next cgrp_cset_link.
-		 */
+
+	if (l == &link->cset->tasks)
+		l = link->cset->mg_tasks.next;
+
+	if (l == &link->cset->mg_tasks)
 		css_advance_task_iter(it);
-	} else {
+	else
 		it->task = l;
-	}
+
 	return res;
 }
 
@@ -4493,16 +4504,23 @@ static int cgroup_css_links_read(struct seq_file *seq, void *v)
 		struct css_set *cset = link->cset;
 		struct task_struct *task;
 		int count = 0;
+
 		seq_printf(seq, "css_set %p\n", cset);
+
 		list_for_each_entry(task, &cset->tasks, cg_list) {
-			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {
-				seq_puts(seq, "  ...\n");
-				break;
-			} else {
-				seq_printf(seq, "  task %d\n",
-					   task_pid_vnr(task));
-			}
+			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
+				goto overflow;
+			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
+		}
+
+		list_for_each_entry(task, &cset->mg_tasks, cg_list) {
+			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
+				goto overflow;
+			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
 		}
+		continue;
+	overflow:
+		seq_puts(seq, "  ...\n");
 	}
 	up_read(&css_set_rwsem);
 	return 0;
-- 
1.8.5.3
