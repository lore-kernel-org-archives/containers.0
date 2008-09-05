From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Thu, 04 Sep 2008 22:34:47 -0700
Message-ID: <48C0C4F7.2080702__8990.27878554097$1220593040$gmane$org@google.com>
References: <48B360CE.2010501@cn.fujitsu.com>	
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>	
	<48B39319.7070403@cn.fujitsu.com>	
	<6599ad830808261544w308a850m865ac0c0a1552c77@mail.gmail.com>	
	<48B4D81D.2040200@cn.fujitsu.com>
	<6599ad830808270536i353e1807kaac4e9fb74301bb0@mail.gmail.com>
	<48B69582.4000208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B69582.4000208-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Lai,

Sorry for the delay, I've been away on vacation.

Lai Jiangshan wrote:
> 
> My original purpose was to fix a bug as I described. 
> This bug and the problem that offering big enough array for a huge
> cgroup are orthogonal!
> 

You're right. So solving them separately seems fine.

It's definitely a bug that can usefully be fixed, but I think it's not quite as critical as you suggest.

I think the simplest approach is to use your basic idea of a shared pid array, but using a standard seq_file rather than hand-coded logic for handling partial reads. Something like the patch below.

Other possible extensions might include:
- delay generating the pid array until the first read
- allocate an array of single pages rather than a single kmalloc() region

Paul



Convert cgroup tasks file to use a seq_file with shared pid array

Rather than pre-generating the entire text for the "tasks" file each
time the file is opened, we instead just generate/update the array of
process ids and use a seq_file to report these to userspace. All open
file handles on the same "tasks" file can share a pid array, which may
be updated any time that no thread is actively reading the array. By
sharing the array, the potential for userspace to DoS the system by
opening many handles on the same "tasks" file is removed.

[ Based on a patch by Lai Jiangshan, extended to use seq_file ]

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 include/linux/cgroup.h |   10 ++
 kernel/cgroup.c        |  226 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 151 insertions(+), 85 deletions(-)

Index: pids-2.6.27-rc1-mm1/include/linux/cgroup.h
===================================================================
--- pids-2.6.27-rc1-mm1.orig/include/linux/cgroup.h
+++ pids-2.6.27-rc1-mm1/include/linux/cgroup.h
@@ -15,6 +15,7 @@
 #include <linux/rcupdate.h>
 #include <linux/cgroupstats.h>
 #include <linux/prio_heap.h>
+#include <linux/rwsem.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -137,6 +138,15 @@ struct cgroup {
 	 * release_list_lock
 	 */
 	struct list_head release_list;
+
+	/* pids_mutex protects the fields below */
+	struct rw_semaphore pids_mutex;
+	/* Array of process ids in the cgroup */
+	pid_t *tasks_pids;
+	/* How many files are using the current tasks_pids array */
+	int pids_use_count;
+	/* Length of the current tasks_pids array */
+	int pids_length;
 };
 
 /* A css_set is a structure holding pointers to a set of
Index: pids-2.6.27-rc1-mm1/kernel/cgroup.c
===================================================================
--- pids-2.6.27-rc1-mm1.orig/kernel/cgroup.c
+++ pids-2.6.27-rc1-mm1/kernel/cgroup.c
@@ -870,6 +870,14 @@ static struct super_operations cgroup_op
 	.remount_fs = cgroup_remount,
 };
 
+static void init_cgroup_housekeeping(struct cgroup *cgrp)
+{
+	INIT_LIST_HEAD(&cgrp->sibling);
+	INIT_LIST_HEAD(&cgrp->children);
+	INIT_LIST_HEAD(&cgrp->css_sets);
+	INIT_LIST_HEAD(&cgrp->release_list);
+	init_rwsem(&cgrp->pids_mutex);
+}
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
@@ -878,10 +886,7 @@ static void init_cgroup_root(struct cgro
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
 	cgrp->top_cgroup = cgrp;
-	INIT_LIST_HEAD(&cgrp->sibling);
-	INIT_LIST_HEAD(&cgrp->children);
-	INIT_LIST_HEAD(&cgrp->css_sets);
-	INIT_LIST_HEAD(&cgrp->release_list);
+	init_cgroup_housekeeping(cgrp);
 }
 
 static int cgroup_test_super(struct super_block *sb, void *data)
@@ -1997,16 +2002,7 @@ int cgroup_scan_tasks(struct cgroup_scan
  * but we cannot guarantee that the information we produce is correct
  * unless we produce it entirely atomically.
  *
- * Upon tasks file open(), a struct ctr_struct is allocated, that
- * will have a pointer to an array (also allocated here).  The struct
- * ctr_struct * is stored in file->private_data.  Its resources will
- * be freed by release() when the file is closed.  The array is used
- * to sprintf the PIDs and then used by read().
  */
-struct ctr_struct {
-	char *buf;
-	int bufsz;
-};
 
 /*
  * Load into 'pidarray' up to 'npids' of the tasks using cgroup
@@ -2088,42 +2084,132 @@ static int cmppid(const void *a, const v
 	return *(pid_t *)a - *(pid_t *)b;
 }
 
+
 /*
- * Convert array 'a' of 'npids' pid_t's to a string of newline separated
- * decimal pids in 'buf'.  Don't write more than 'sz' chars, but return
- * count 'cnt' of how many chars would be written if buf were large enough.
+ * seq_file methods for the "tasks" file. The seq_file position is the
+ * next pid to display; the seq_file iterator is a pointer to the pid
+ * in the cgroup->tasks_pids array.
  */
-static int pid_array_to_buf(char *buf, int sz, pid_t *a, int npids)
+
+static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
 {
-	int cnt = 0;
-	int i;
+	/*
+	 * Initially we receive a position value that corresponds to
+	 * one more than the last pid shown (or 0 on the first call or
+	 * after a seek to the start). Use a binary-search to find the
+	 * next pid to display, if any
+	 */
+	struct cgroup *cgrp = s->private;
+	int index = 0, pid = *pos;
+	int *iter;
+
+	down_read(&cgrp->pids_mutex);
+	if (pid) {
+		int end = cgrp->pids_length;
+		int i;
+		while (index < end) {
+			int mid = (index + end) / 2;
+			if (cgrp->tasks_pids[mid] == pid) {
+				index = mid;
+				break;
+			} else if (cgrp->tasks_pids[mid] <= pid)
+				index = mid + 1;
+			else
+				end = mid;
+		}
+	}
+	/* If we're off the end of the array, we're done */
+	if (index >= cgrp->pids_length)
+		return NULL;
+	/* Update the abstract position to be the actual pid that we found */
+	iter = cgrp->tasks_pids + index;
+	*pos = *iter;
+	return iter;
+}
+
+static void cgroup_tasks_stop(struct seq_file *s, void *v)
+{
+	struct cgroup *cgrp = s->private;
+	up_read(&cgrp->pids_mutex);
+}
+
+static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct cgroup *cgrp = s->private;
+	int *p = v;
+	int *end = cgrp->tasks_pids + cgrp->pids_length;
+
+	/*
+	 * Advance to the next pid in the array. If this goes off the
+	 * end, we're done
+	 */
+	p++;
+	if (p >= end) {
+		return NULL;
+	} else {
+		*pos = *p;
+		return p;
+	}
+}
+
+static int cgroup_tasks_show(struct seq_file *s, void *v)
+{
+	return seq_printf(s, "%d\n", *(int *)v);
+}
 
-	for (i = 0; i < npids; i++)
-		cnt += snprintf(buf + cnt, max(sz - cnt, 0), "%d\n", a[i]);
-	return cnt;
+static struct seq_operations cgroup_tasks_seq_operations = {
+	.start = cgroup_tasks_start,
+	.stop = cgroup_tasks_stop,
+	.next = cgroup_tasks_next,
+	.show = cgroup_tasks_show,
+};
+
+static void release_cgroup_pid_array(struct cgroup *cgrp)
+{
+	down_write(&cgrp->pids_mutex);
+	BUG_ON(!cgrp->pids_use_count);
+	if (!--cgrp->pids_use_count) {
+		kfree(cgrp->tasks_pids);
+		cgrp->tasks_pids = NULL;
+		cgrp->pids_length = 0;
+	}
+	up_write(&cgrp->pids_mutex);
+}
+
+static int cgroup_tasks_release(struct inode *inode, struct file *file)
+{
+	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
+
+	if (!(file->f_mode & FMODE_READ))
+		return 0;
+
+	release_cgroup_pid_array(cgrp);
+	return seq_release(inode, file);
 }
 
+static struct file_operations cgroup_tasks_operations = {
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.write = cgroup_file_write,
+	.release = cgroup_tasks_release,
+};
+
 /*
- * Handle an open on 'tasks' file.  Prepare a buffer listing the
+ * Handle an open on 'tasks' file.  Prepare an array containing the
  * process id's of tasks currently attached to the cgroup being opened.
- *
- * Does not require any specific cgroup mutexes, and does not take any.
  */
+
 static int cgroup_tasks_open(struct inode *unused, struct file *file)
 {
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
-	struct ctr_struct *ctr;
 	pid_t *pidarray;
 	int npids;
-	char c;
+	int retval;
 
+	/* Nothing to do for write-only files */
 	if (!(file->f_mode & FMODE_READ))
 		return 0;
 
-	ctr = kmalloc(sizeof(*ctr), GFP_KERNEL);
-	if (!ctr)
-		goto err0;
-
 	/*
 	 * If cgroup gets more users after we read count, we won't have
 	 * enough space - tough.  This race is indistinguishable to the
@@ -2131,57 +2217,31 @@ static int cgroup_tasks_open(struct inod
 	 * show up until sometime later on.
 	 */
 	npids = cgroup_task_count(cgrp);
-	if (npids) {
-		pidarray = kmalloc(npids * sizeof(pid_t), GFP_KERNEL);
-		if (!pidarray)
-			goto err1;
-
-		npids = pid_array_load(pidarray, npids, cgrp);
-		sort(pidarray, npids, sizeof(pid_t), cmppid, NULL);
-
-		/* Call pid_array_to_buf() twice, first just to get bufsz */
-		ctr->bufsz = pid_array_to_buf(&c, sizeof(c), pidarray, npids) + 1;
-		ctr->buf = kmalloc(ctr->bufsz, GFP_KERNEL);
-		if (!ctr->buf)
-			goto err2;
-		ctr->bufsz = pid_array_to_buf(ctr->buf, ctr->bufsz, pidarray, npids);
-
-		kfree(pidarray);
-	} else {
-		ctr->buf = NULL;
-		ctr->bufsz = 0;
-	}
-	file->private_data = ctr;
-	return 0;
-
-err2:
-	kfree(pidarray);
-err1:
-	kfree(ctr);
-err0:
-	return -ENOMEM;
-}
-
-static ssize_t cgroup_tasks_read(struct cgroup *cgrp,
-				    struct cftype *cft,
-				    struct file *file, char __user *buf,
-				    size_t nbytes, loff_t *ppos)
-{
-	struct ctr_struct *ctr = file->private_data;
-
-	return simple_read_from_buffer(buf, nbytes, ppos, ctr->buf, ctr->bufsz);
-}
-
-static int cgroup_tasks_release(struct inode *unused_inode,
-					struct file *file)
-{
-	struct ctr_struct *ctr;
+	pidarray = kmalloc(npids * sizeof(pid_t), GFP_KERNEL);
+	if (!pidarray)
+		return -ENOMEM;
+	npids = pid_array_load(pidarray, npids, cgrp);
+	sort(pidarray, npids, sizeof(pid_t), cmppid, NULL);
 
-	if (file->f_mode & FMODE_READ) {
-		ctr = file->private_data;
-		kfree(ctr->buf);
-		kfree(ctr);
+	/*
+	 * Store the array in the cgroup, freeing the old
+	 * array if necessary
+	 */
+	down_write(&cgrp->pids_mutex);
+	kfree(cgrp->tasks_pids);
+	cgrp->tasks_pids = pidarray;
+	cgrp->pids_length = npids;
+	cgrp->pids_use_count++;
+	up_write(&cgrp->pids_mutex);
+
+	file->f_op = &cgroup_tasks_operations;
+
+	retval = seq_open(file, &cgroup_tasks_seq_operations);
+	if (retval) {
+		release_cgroup_pid_array(cgrp);
+		return retval;
 	}
+	((struct seq_file *)file->private_data)->private = cgrp;
 	return 0;
 }
 
@@ -2210,7 +2270,6 @@ static struct cftype files[] = {
 	{
 		.name = "tasks",
 		.open = cgroup_tasks_open,
-		.read = cgroup_tasks_read,
 		.write_u64 = cgroup_tasks_write,
 		.release = cgroup_tasks_release,
 		.private = FILE_TASKLIST,
@@ -2300,10 +2359,7 @@ static long cgroup_create(struct cgroup 
 
 	mutex_lock(&cgroup_mutex);
 
-	INIT_LIST_HEAD(&cgrp->sibling);
-	INIT_LIST_HEAD(&cgrp->children);
-	INIT_LIST_HEAD(&cgrp->css_sets);
-	INIT_LIST_HEAD(&cgrp->release_list);
+	init_cgroup_housekeeping(cgrp);
 
 	cgrp->parent = parent;
 	cgrp->root = parent->root;
