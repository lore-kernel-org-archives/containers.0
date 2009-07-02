From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Thu, 02 Jul 2009 16:26:20 -0700
Message-ID: <20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702231814.3969.44308.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Adds a read-only "procs" file similar to "tasks" that shows only unique tgids

struct cgroup used to have a bunch of fields for keeping track of the pidlist
for the tasks file. Those are now separated into a new struct cgroup_pidlist,
of which two are had, one for procs and one for tasks. The way the seq_file
operations are set up is changed so that just the pidlist struct gets passed
around as the private data.

Possible future functionality is making the procs file writable for purposes
of adding all threads with the same tgid at once.

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h |   23 +++-
 kernel/cgroup.c        |  287 ++++++++++++++++++++++++++++++------------------
 2 files changed, 195 insertions(+), 115 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 665fa70..3b937c3 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -141,6 +141,18 @@ enum {
 	CGRP_WAIT_ON_RMDIR,
 };
 
+
+struct cgroup_pidlist {
+	/* protects the other fields */
+	struct rw_semaphore mutex;
+	/* array of xids */
+	pid_t *list;
+	/* how many elements the above list has */
+	int length;
+	/* how many files are using the current array */
+	int use_count;
+};
+
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
@@ -179,14 +191,9 @@ struct cgroup {
 	 */
 	struct list_head release_list;
 
-	/* pids_mutex protects the fields below */
-	struct rw_semaphore pids_mutex;
-	/* Array of process ids in the cgroup */
-	pid_t *tasks_pids;
-	/* How many files are using the current tasks_pids array */
-	int pids_use_count;
-	/* Length of the current tasks_pids array */
-	int pids_length;
+	/* we will have two separate pidlists, one for pids (the tasks file)
+	 * and one for tgids (the procs file). */
+	struct cgroup_pidlist tasks, procs;
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ea255fe..3cf0faa 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -961,7 +961,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
-	init_rwsem(&cgrp->pids_mutex);
+	init_rwsem(&(cgrp->tasks.mutex));
+	init_rwsem(&(cgrp->procs.mutex));
 }
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
@@ -1409,15 +1410,6 @@ static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 	return ret;
 }
 
-/* The various types of files and directories in a cgroup file system */
-enum cgroup_filetype {
-	FILE_ROOT,
-	FILE_DIR,
-	FILE_TASKLIST,
-	FILE_NOTIFY_ON_RELEASE,
-	FILE_RELEASE_AGENT,
-};
-
 /**
  * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
  * @cgrp: the cgroup to be checked for liveness
@@ -2115,7 +2107,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 }
 
 /*
- * Stuff for reading the 'tasks' file.
+ * Stuff for reading the 'tasks'/'procs' files.
  *
  * Reading this file can return large amounts of data if a cgroup has
  * *lots* of attached tasks. So it may need several calls to read(),
@@ -2124,30 +2116,115 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
  *
  */
 
-/*
- * Load into 'pidarray' up to 'npids' of the tasks using cgroup
- * 'cgrp'.  Return actual number of pids loaded.  No need to
- * task_lock(p) when reading out p->cgroup, since we're in an RCU
- * read section, so the css_set can't go away, and is
- * immutable after creation.
+/**
+ * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
+ * returns -ENOMEM if the malloc fails; 0 on success
+ */
+/* this implementation relies on the fact that pids will never be -1 */
+#define PIDLIST_VALUE_NONE ((pid_t)(-1))
+static int pidlist_uniq(pid_t **p, int *length)
+{
+	int i, j = 0; /* array index */
+	int last = 0; /* index of last unique entry */
+	int count = 1; /* count of total unique entries */
+	pid_t *list, *newlist;
+	BUG_ON(p == NULL || *p == NULL || length == NULL);
+	list = *p;
+	/*
+	 * we presume the 0th element is unique, so i starts at 1. trivial
+	 * edge cases first; no work needs to be done for either
+	 */
+	if (*length == 0 || *length == 1)
+		return 0;
+	for (i = 1; i < *length; i++) {
+		BUG_ON(list[i] == PIDLIST_VALUE_NONE);
+		if (list[i] == list[last]) {
+			list[i] = PIDLIST_VALUE_NONE;
+		} else {
+			last = i;
+			count++;
+		}
+	}
+	newlist = kmalloc(count * sizeof(pid_t), GFP_KERNEL);
+	if (!newlist)
+		return -ENOMEM;
+	/* copy to new array */
+	for (i = 0; i < *length; i++) {
+		if (list[i] != PIDLIST_VALUE_NONE) {
+			newlist[j] = list[i];
+			j++;
+		}
+	}
+	BUG_ON(j != count); /* this would fail on a zero-length array */
+	kfree(list);
+	*p = newlist;
+	*length = count;
+	return 0;
+}
+
+static int cmppid(const void *a, const void *b)
+{
+	return *(pid_t *)a - *(pid_t *)b;
+}
+
+/**
+ * Load a cgroup's pidarray with either procs' tgids or tasks' pids
  */
-static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
+static int pidlist_array_load(struct cgroup *cgrp, bool procs)
 {
-	int n = 0, pid;
+	pid_t *array;
+	int length;
+	int retval;
+	int pid, n = 0; /* used for populating the array */
 	struct cgroup_iter it;
 	struct task_struct *tsk;
+	struct cgroup_pidlist *l;
+
+	/*
+	 * If cgroup gets more users after we read count, we won't have
+	 * enough space - tough.  This race is indistinguishable to the
+	 * caller from the case that the additional cgroup users didn't
+	 * show up until sometime later on.
+	 */
+	length = cgroup_task_count(cgrp);
+	array = kmalloc(length * sizeof(pid_t), GFP_KERNEL);
+	if (!array)
+		return -ENOMEM;
+	/* now, populate the array */
 	cgroup_iter_start(cgrp, &it);
 	while ((tsk = cgroup_iter_next(cgrp, &it))) {
-		if (unlikely(n == npids))
+		if (unlikely(n == length))
 			break;
-		pid = task_pid_vnr(tsk);
-		if (pid > 0)
-			pidarray[n++] = pid;
+		/* get tgid or pid for procs or tasks file respectively */
+		pid = (procs ? task_tgid_vnr(tsk) : task_pid_vnr(tsk));
+		if (pid > 0) /* make sure to only use valid results */
+			array[n++] = pid;
 	}
 	cgroup_iter_end(cgrp, &it);
-	return n;
+	length = n;
+	/* now sort & (if procs) strip out duplicates */
+	sort(array, length, sizeof(pid_t), cmppid, NULL);
+	if (procs) {
+		retval = pidlist_uniq(&array, &length);
+		if (retval) { /* the malloc inside uniq can fail */
+			kfree(array);
+			return retval;
+		}
+		l = &(cgrp->procs);
+	} else {
+		l = &(cgrp->tasks);
+	}
+	/* store array in cgroup, freeing old if necessary */
+	down_write(&l->mutex);
+	kfree(l->list);
+	l->list = array;
+	l->length = length;
+	l->use_count++;
+	up_write(&l->mutex);
+	return 0;
 }
 
+
 /**
  * cgroupstats_build - build and fill cgroupstats
  * @stats: cgroupstats to fill information into
@@ -2202,19 +2279,14 @@ err:
 	return ret;
 }
 
-static int cmppid(const void *a, const void *b)
-{
-	return *(pid_t *)a - *(pid_t *)b;
-}
-
 
 /*
- * seq_file methods for the "tasks" file. The seq_file position is the
+ * seq_file methods for the tasks/procs files. The seq_file position is the
  * next pid to display; the seq_file iterator is a pointer to the pid
- * in the cgroup->tasks_pids array.
+ * in the cgroup->l->list array.
  */
 
-static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
+static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 {
 	/*
 	 * Initially we receive a position value that corresponds to
@@ -2222,46 +2294,45 @@ static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
 	 * after a seek to the start). Use a binary-search to find the
 	 * next pid to display, if any
 	 */
-	struct cgroup *cgrp = s->private;
+	struct cgroup_pidlist *l = s->private;
 	int index = 0, pid = *pos;
 	int *iter;
 
-	down_read(&cgrp->pids_mutex);
+	down_read(&l->mutex);
 	if (pid) {
-		int end = cgrp->pids_length;
+		int end = l->length;
 
 		while (index < end) {
 			int mid = (index + end) / 2;
-			if (cgrp->tasks_pids[mid] == pid) {
+			if (l->list[mid] == pid) {
 				index = mid;
 				break;
-			} else if (cgrp->tasks_pids[mid] <= pid)
+			} else if (l->list[mid] <= pid)
 				index = mid + 1;
 			else
 				end = mid;
 		}
 	}
 	/* If we're off the end of the array, we're done */
-	if (index >= cgrp->pids_length)
+	if (index >= l->length)
 		return NULL;
 	/* Update the abstract position to be the actual pid that we found */
-	iter = cgrp->tasks_pids + index;
+	iter = l->list + index;
 	*pos = *iter;
 	return iter;
 }
 
-static void cgroup_tasks_stop(struct seq_file *s, void *v)
+static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
-	struct cgroup *cgrp = s->private;
-	up_read(&cgrp->pids_mutex);
+	struct cgroup_pidlist *l = s->private;
+	up_read(&l->mutex);
 }
 
-static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
+static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct cgroup *cgrp = s->private;
-	int *p = v;
-	int *end = cgrp->tasks_pids + cgrp->pids_length;
-
+	struct cgroup_pidlist *l = s->private;
+	pid_t *p = v;
+	pid_t *end = l->list + l->length;
 	/*
 	 * Advance to the next pid in the array. If this goes off the
 	 * end, we're done
@@ -2275,98 +2346,95 @@ static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
 	}
 }
 
-static int cgroup_tasks_show(struct seq_file *s, void *v)
+static int cgroup_pidlist_show(struct seq_file *s, void *v)
 {
 	return seq_printf(s, "%d\n", *(int *)v);
 }
 
-static struct seq_operations cgroup_tasks_seq_operations = {
-	.start = cgroup_tasks_start,
-	.stop = cgroup_tasks_stop,
-	.next = cgroup_tasks_next,
-	.show = cgroup_tasks_show,
+/*
+ * seq_operations functions for iterating on pidlists through seq_file -
+ * independent of whether it's tasks or procs
+ */
+static const struct seq_operations cgroup_pidlist_seq_operations = {
+	.start = cgroup_pidlist_start,
+	.stop = cgroup_pidlist_stop,
+	.next = cgroup_pidlist_next,
+	.show = cgroup_pidlist_show,
 };
 
-static void release_cgroup_pid_array(struct cgroup *cgrp)
+static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 {
-	down_write(&cgrp->pids_mutex);
-	BUG_ON(!cgrp->pids_use_count);
-	if (!--cgrp->pids_use_count) {
-		kfree(cgrp->tasks_pids);
-		cgrp->tasks_pids = NULL;
-		cgrp->pids_length = 0;
+	down_write(&l->mutex);
+	BUG_ON(!l->use_count);
+	if (!--l->use_count) {
+		kfree(l->list);
+		l->list = NULL;
+		l->length = 0;
 	}
-	up_write(&cgrp->pids_mutex);
+	up_write(&l->mutex);
 }
 
-static int cgroup_tasks_release(struct inode *inode, struct file *file)
+static int cgroup_pidlist_release(struct inode *inode, struct file *file)
 {
-	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
-
+	struct cgroup_pidlist *l;
 	if (!(file->f_mode & FMODE_READ))
 		return 0;
-
-	release_cgroup_pid_array(cgrp);
+	/*
+	 * the seq_file will only be initialized if the file was opened for
+	 * reading; hence we check if it's not null only in that case.
+	 */
+	BUG_ON(!file->private_data);
+	l = ((struct seq_file *)file->private_data)->private;
+	cgroup_release_pid_array(l);
 	return seq_release(inode, file);
 }
 
-static struct file_operations cgroup_tasks_operations = {
+static const struct file_operations cgroup_pidlist_operations = {
 	.read = seq_read,
 	.llseek = seq_lseek,
 	.write = cgroup_file_write,
-	.release = cgroup_tasks_release,
+	.release = cgroup_pidlist_release,
 };
 
 /*
- * Handle an open on 'tasks' file.  Prepare an array containing the
- * process id's of tasks currently attached to the cgroup being opened.
+ * The following functions handle opens on a file that displays a pidlist
+ * (tasks or procs). Prepare an array of the process/thread IDs of whoever's
+ * in the cgroup.
  */
-
-static int cgroup_tasks_open(struct inode *unused, struct file *file)
+/* helper function for the two below it */
+static int cgroup_pidlist_open(struct file *file, bool procs)
 {
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
-	pid_t *pidarray;
-	int npids;
+	struct cgroup_pidlist *l = (procs ? &cgrp->procs : &cgrp->tasks);
 	int retval;
 
 	/* Nothing to do for write-only files */
 	if (!(file->f_mode & FMODE_READ))
 		return 0;
 
-	/*
-	 * If cgroup gets more users after we read count, we won't have
-	 * enough space - tough.  This race is indistinguishable to the
-	 * caller from the case that the additional cgroup users didn't
-	 * show up until sometime later on.
-	 */
-	npids = cgroup_task_count(cgrp);
-	pidarray = kmalloc(npids * sizeof(pid_t), GFP_KERNEL);
-	if (!pidarray)
-		return -ENOMEM;
-	npids = pid_array_load(pidarray, npids, cgrp);
-	sort(pidarray, npids, sizeof(pid_t), cmppid, NULL);
-
-	/*
-	 * Store the array in the cgroup, freeing the old
-	 * array if necessary
-	 */
-	down_write(&cgrp->pids_mutex);
-	kfree(cgrp->tasks_pids);
-	cgrp->tasks_pids = pidarray;
-	cgrp->pids_length = npids;
-	cgrp->pids_use_count++;
-	up_write(&cgrp->pids_mutex);
-
-	file->f_op = &cgroup_tasks_operations;
+	/* have the array populated */
+	retval = pidlist_array_load(cgrp, procs);
+	if (retval)
+		return retval;
+	/* configure file information */
+	file->f_op = &cgroup_pidlist_operations;
 
-	retval = seq_open(file, &cgroup_tasks_seq_operations);
+	retval = seq_open(file, &cgroup_pidlist_seq_operations);
 	if (retval) {
-		release_cgroup_pid_array(cgrp);
+		cgroup_release_pid_array(l);
 		return retval;
 	}
-	((struct seq_file *)file->private_data)->private = cgrp;
+	((struct seq_file *)file->private_data)->private = l;
 	return 0;
 }
+static int cgroup_tasks_open(struct inode *unused, struct file *file)
+{
+	return cgroup_pidlist_open(file, false);
+}
+static int cgroup_procs_open(struct inode *unused, struct file *file)
+{
+	return cgroup_pidlist_open(file, true);
+}
 
 static u64 cgroup_read_notify_on_release(struct cgroup *cgrp,
 					    struct cftype *cft)
@@ -2389,21 +2457,27 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 /*
  * for the common functions, 'private' gives the type of file
  */
+/* for hysterical reasons, we can't put this on the older files */
+#define CGROUP_FILE_GENERIC_PREFIX "cgroup."
 static struct cftype files[] = {
 	{
 		.name = "tasks",
 		.open = cgroup_tasks_open,
 		.write_u64 = cgroup_tasks_write,
-		.release = cgroup_tasks_release,
-		.private = FILE_TASKLIST,
+		.release = cgroup_pidlist_release,
 		.mode = S_IRUGO | S_IWUSR,
 	},
-
+	{
+		.name = CGROUP_FILE_GENERIC_PREFIX "procs",
+		.open = cgroup_procs_open,
+		/* .write_u64 = cgroup_procs_write, TODO */
+		.release = cgroup_pidlist_release,
+		.mode = S_IRUGO,
+	},
 	{
 		.name = "notify_on_release",
 		.read_u64 = cgroup_read_notify_on_release,
 		.write_u64 = cgroup_write_notify_on_release,
-		.private = FILE_NOTIFY_ON_RELEASE,
 	},
 };
 
@@ -2412,7 +2486,6 @@ static struct cftype cft_release_agent = {
 	.read_seq_string = cgroup_release_agent_show,
 	.write_string = cgroup_release_agent_write,
 	.max_write_len = PATH_MAX,
-	.private = FILE_RELEASE_AGENT,
 };
 
 static int cgroup_populate_dir(struct cgroup *cgrp)
