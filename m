From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] Ensures correct concurrent opening/reading of pidlists
	across pid namespaces
Date: Fri, 10 Jul 2009 16:02:00 -0700
Message-ID: <20090710230200.16778.89212.stgit@hastromil.mtv.corp.google.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090710230043.16778.29656.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Ensures correct concurrent opening/reading of pidlists across pid namespaces

Previously there was the problem in which two processes from different pid
namespaces reading the tasks or procs file could result in one process seeing
results from the other's namespace. Rather than one pidlist for each file in a
cgroup, we now keep a list of pidlists keyed by namespace and file type (tasks
versus procs) in which entries are placed on demand. Each pidlist has its own
lock, and that the pidlists themselves are passed around in the seq_file's
private pointer means we don't have to touch the cgroup or its master list
except when creating and destroying entries.

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h |   34 +++++++++++++--
 kernel/cgroup.c        |  108 ++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 119 insertions(+), 23 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8a3a3ac..b934b72 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -141,15 +141,36 @@ enum {
 	CGRP_WAIT_ON_RMDIR,
 };
 
+/* which pidlist file are we talking about? */
+enum cgroup_filetype {
+	CGROUP_FILE_PROCS,
+	CGROUP_FILE_TASKS,
+};
+
+/*
+ * A pidlist is a list of pids that virtually represents the contents of one
+ * of the cgroup files ("procs" or "tasks"). We keep a list of such pidlists,
+ * a pair (one each for procs, tasks) for each pid namespace that's relevant
+ * to the cgroup.
+ */
 struct cgroup_pidlist {
-	/* protects the other fields */
-	struct rw_semaphore mutex;
+	/*
+	 * used to find which pidlist is wanted. doesn't change as long as
+	 * this particular list stays in the list.
+	 */
+	struct { enum cgroup_filetype type; struct pid_namespace *ns; } key;
 	/* array of xids */
 	pid_t *list;
 	/* how many elements the above list has */
 	int length;
 	/* how many files are using the current array */
 	int use_count;
+	/* each of these stored in a list by its cgroup */
+	struct list_head links;
+	/* pointer to the cgroup we belong to, for list removal purposes */
+	struct cgroup *owner;
+	/* protects the other fields */
+	struct rw_semaphore mutex;
 };
 
 struct cgroup {
@@ -190,9 +211,12 @@ struct cgroup {
 	 */
 	struct list_head release_list;
 
-	/* we will have two separate pidlists, one for pids (the tasks file)
-	 * and one for tgids (the procs file). */
-	struct cgroup_pidlist tasks, procs;
+	/*
+	 * list of pidlists, up to two for each namespace (one for procs, one
+	 * for tasks); created on demand.
+	 */
+	struct list_head pidlists;
+	struct mutex pidlist_mutex;
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2efe5c4..33d89be 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -47,6 +47,7 @@
 #include <linux/hash.h>
 #include <linux/namei.h>
 #include <linux/smp_lock.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/atomic.h>
 
@@ -640,7 +641,11 @@ static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 static void free_cgroup_rcu(struct rcu_head *obj)
 {
 	struct cgroup *cgrp = container_of(obj, struct cgroup, rcu_head);
-
+	/*
+	 * if we're getting rid of the cgroup, refcount must have ensured
+	 * that anybody using a pidlist will have cleaned it up by now.
+	 */
+	BUG_ON(!list_empty(&cgrp->pidlists));
 	kfree(cgrp);
 }
 
@@ -960,8 +965,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
-	init_rwsem(&(cgrp->tasks.mutex));
-	init_rwsem(&(cgrp->procs.mutex));
+	INIT_LIST_HEAD(&cgrp->pidlists);
+	mutex_init(&cgrp->pidlist_mutex);
 }
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
@@ -2171,9 +2176,58 @@ static int cmppid(const void *a, const void *b)
 }
 
 /*
+ * find the appropriate pidlist for our purpose (given procs vs tasks)
+ * returns with the lock on that pidlist already held, and takes care
+ * of the use count, or returns NULL with no locks held if we're out of
+ * memory.
+ */
+static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
+						  enum cgroup_filetype type)
+{
+	struct cgroup_pidlist *l;
+	/* don't need task_nsproxy() if we're looking at ourself */
+	struct pid_namespace *ns = get_pid_ns(current->nsproxy->pid_ns);
+	/*
+	 * We can't drop the pidlist_mutex before taking the l->mutex in case
+	 * the last ref-holder is trying to remove l from the list at the same
+	 * time. Holding the pidlist_mutex precludes somebody taking whichever
+	 * list we find out from under us - compare release_pid_array().
+	 */
+	mutex_lock(&cgrp->pidlist_mutex);
+	list_for_each_entry(l, &cgrp->pidlists, links) {
+		if (l->key.type == type && l->key.ns == ns) {
+			/* found a matching list - drop the extra refcount */
+			put_pid_ns(ns);
+			/* make sure l doesn't vanish out from under us */
+			down_write(&l->mutex);
+			mutex_unlock(&cgrp->pidlist_mutex);
+			l->use_count++;
+			return l;
+		}
+	}
+	/* entry not found; create a new one */
+	l = kmalloc(sizeof(struct cgroup_pidlist), GFP_KERNEL);
+	if (!l) {
+		mutex_unlock(&cgrp->pidlist_mutex);
+		return l;
+	}
+	init_rwsem(&l->mutex);
+	down_write(&l->mutex);
+	l->key.type = type;
+	l->key.ns = ns;
+	l->use_count = 0; /* don't increment here */
+	l->list = NULL;
+	l->owner = cgrp;
+	list_add(&l->links, &cgrp->pidlists);
+	mutex_unlock(&cgrp->pidlist_mutex);
+	return l;
+}
+
+/*
  * Load a cgroup's pidarray with either procs' tgids or tasks' pids
  */
-static int pidlist_array_load(struct cgroup *cgrp, bool procs)
+static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
+			      struct cgroup_pidlist **lp)
 {
 	pid_t *array;
 	int length;
@@ -2198,7 +2252,10 @@ static int pidlist_array_load(struct cgroup *cgrp, bool procs)
 		if (unlikely(n == length))
 			break;
 		/* get tgid or pid for procs or tasks file respectively */
-		pid = (procs ? task_tgid_vnr(tsk) : task_pid_vnr(tsk));
+		if (type == CGROUP_FILE_PROCS)
+			pid = task_tgid_vnr(tsk);
+		else
+			pid = task_pid_vnr(tsk);
 		if (pid > 0) /* make sure to only use valid results */
 			array[n++] = pid;
 	}
@@ -2206,19 +2263,21 @@ static int pidlist_array_load(struct cgroup *cgrp, bool procs)
 	length = n;
 	/* now sort & (if procs) strip out duplicates */
 	sort(array, length, sizeof(pid_t), cmppid, NULL);
-	if (procs) {
+	if (type == CGROUP_FILE_PROCS) {
 		length = pidlist_uniq(&array, length);
-		l = &(cgrp->procs);
-	} else {
-		l = &(cgrp->tasks);
 	}
-	/* store array in cgroup, freeing old if necessary */
-	down_write(&l->mutex);
+	l = cgroup_pidlist_find(cgrp, type);
+	if (!l) {
+		kfree(array);
+		return -ENOMEM;
+	}
+	/* store array, freeing old if necessary - lock already held */
 	kfree(l->list);
 	l->list = array;
 	l->length = length;
 	l->use_count++;
 	up_write(&l->mutex);
+	*lp = l;
 	return 0;
 }
 
@@ -2361,13 +2420,26 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
 
 static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 {
+	/*
+	 * the case where we're the last user of this particular pidlist will
+	 * have us remove it from the cgroup's list, which entails taking the
+	 * mutex. since in pidlist_find the pidlist->lock depends on cgroup->
+	 * pidlist_mutex, we have to take pidlist_mutex first.
+	 */
+	mutex_lock(&l->owner->pidlist_mutex);
 	down_write(&l->mutex);
 	BUG_ON(!l->use_count);
 	if (!--l->use_count) {
+		/* we're the last user if refcount is 0; remove and free */
+		list_del(&l->links);
+		mutex_unlock(&l->owner->pidlist_mutex);
 		kfree(l->list);
-		l->list = NULL;
-		l->length = 0;
+		put_pid_ns(l->key.ns);
+		up_write(&l->mutex);
+		kfree(l);
+		return;
 	}
+	mutex_unlock(&l->owner->pidlist_mutex);
 	up_write(&l->mutex);
 }
 
@@ -2398,10 +2470,10 @@ static const struct file_operations cgroup_pidlist_operations = {
  * in the cgroup.
  */
 /* helper function for the two below it */
-static int cgroup_pidlist_open(struct file *file, bool procs)
+static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 {
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
-	struct cgroup_pidlist *l = (procs ? &cgrp->procs : &cgrp->tasks);
+	struct cgroup_pidlist *l;
 	int retval;
 
 	/* Nothing to do for write-only files */
@@ -2409,7 +2481,7 @@ static int cgroup_pidlist_open(struct file *file, bool procs)
 		return 0;
 
 	/* have the array populated */
-	retval = pidlist_array_load(cgrp, procs);
+	retval = pidlist_array_load(cgrp, type, &l);
 	if (retval)
 		return retval;
 	/* configure file information */
@@ -2425,11 +2497,11 @@ static int cgroup_pidlist_open(struct file *file, bool procs)
 }
 static int cgroup_tasks_open(struct inode *unused, struct file *file)
 {
-	return cgroup_pidlist_open(file, false);
+	return cgroup_pidlist_open(file, CGROUP_FILE_TASKS);
 }
 static int cgroup_procs_open(struct inode *unused, struct file *file)
 {
-	return cgroup_pidlist_open(file, true);
+	return cgroup_pidlist_open(file, CGROUP_FILE_PROCS);
 }
 
 static u64 cgroup_read_notify_on_release(struct cgroup *cgrp,
