From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Thu, 30 Jul 2009 18:51:28 -0700
Message-ID: <20090731015128.27908.94055.stgit__9510.36990522898$1249005172$gmane$org@hastromil.mtv.corp.google.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090731012908.27908.62208.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Adds a read-only "procs" file similar to "tasks" that shows only unique tgids

struct cgroup used to have a bunch of fields for keeping track of the pidlist
for the tasks file. Those are now separated into a new struct cgroup_pidlist,
of which two are had, one for procs and one for tasks. The way the seq_file
operations are set up is changed so that just the pidlist struct gets passed
around as the private data.

Interface example: Suppose a multithreaded process has pid 1000 and other
threads with ids 1001, 1002, 1003:
$ cat tasks
1000
1001
1002
1003
$ cat cgroup.procs
1000
$

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h |   22 ++--
 kernel/cgroup.c        |  278 ++++++++++++++++++++++++++++++------------------
 2 files changed, 186 insertions(+), 114 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 665fa70..8a3a3ac 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -141,6 +141,17 @@ enum {
 	CGRP_WAIT_ON_RMDIR,
 };
 
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
 
@@ -179,14 +190,9 @@ struct cgroup {
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
index 3737a68..4ceee3f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -960,7 +960,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
-	init_rwsem(&cgrp->pids_mutex);
+	init_rwsem(&(cgrp->tasks.mutex));
+	init_rwsem(&(cgrp->procs.mutex));
 }
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
@@ -1408,15 +1409,6 @@ static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
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
@@ -2114,7 +2106,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 }
 
 /*
- * Stuff for reading the 'tasks' file.
+ * Stuff for reading the 'tasks'/'procs' files.
  *
  * Reading this file can return large amounts of data if a cgroup has
  * *lots* of attached tasks. So it may need several calls to read(),
@@ -2124,27 +2116,106 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
  */
 
 /*
- * Load into 'pidarray' up to 'npids' of the tasks using cgroup
- * 'cgrp'.  Return actual number of pids loaded.  No need to
- * task_lock(p) when reading out p->cgroup, since we're in an RCU
- * read section, so the css_set can't go away, and is
- * immutable after creation.
+ * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
+ * If the new stripped list is sufficiently smaller and there's enough memory
+ * to allocate a new buffer, will let go of the unneeded memory. Returns the
+ * number of unique elements.
  */
-static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
+/* is the size difference enough that we should re-allocate the array? */
+#define PIDLIST_REALLOC_DIFFERENCE(old, new) ((old) - PAGE_SIZE >= (new))
+static int pidlist_uniq(pid_t **p, int length)
 {
-	int n = 0, pid;
+	int src, dest = 1;
+	pid_t *list = *p;
+	pid_t *newlist;
+
+	/*
+	 * we presume the 0th element is unique, so i starts at 1. trivial
+	 * edge cases first; no work needs to be done for either
+	 */
+	if (length == 0 || length == 1)
+		return length;
+	/* src and dest walk down the list; dest counts unique elements */
+	for (src = 1; src < length; src++) {
+		/* find next unique element */
+		while (list[src] == list[src-1]) {
+			src++;
+			if (src == length)
+				goto after;
+		}
+		/* dest always points to where the next unique element goes */
+		list[dest] = list[src];
+		dest++;
+	}
+after:
+	/*
+	 * if the length difference is large enough, we want to allocate a
+	 * smaller buffer to save memory. if this fails due to out of memory,
+	 * we'll just stay with what we've got.
+	 */
+	if (PIDLIST_REALLOC_DIFFERENCE(length, dest)) {
+		newlist = krealloc(list, dest * sizeof(pid_t), GFP_KERNEL);
+		if (newlist)
+			*p = newlist;
+	}
+	return dest;
+}
+
+static int cmppid(const void *a, const void *b)
+{
+	return *(pid_t *)a - *(pid_t *)b;
+}
+
+/*
+ * Load a cgroup's pidarray with either procs' tgids or tasks' pids
+ */
+static int pidlist_array_load(struct cgroup *cgrp, bool procs)
+{
+	pid_t *array;
+	int length;
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
+		length = pidlist_uniq(&array, length);
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
 
 /**
@@ -2201,19 +2272,14 @@ err:
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
@@ -2221,46 +2287,45 @@ static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
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
@@ -2274,98 +2339,94 @@ static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
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
@@ -2388,21 +2449,27 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 /*
  * for the common functions, 'private' gives the type of file
  */
+/* for hysterical raisins, we can't put this on the older files */
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
 
@@ -2411,7 +2478,6 @@ static struct cftype cft_release_agent = {
 	.read_seq_string = cgroup_release_agent_show,
 	.write_string = cgroup_release_agent_write,
 	.max_write_len = PATH_MAX,
-	.private = FILE_RELEASE_AGENT,
 };
 
 static int cgroup_populate_dir(struct cgroup *cgrp)
