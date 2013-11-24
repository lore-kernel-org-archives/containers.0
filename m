From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/9] cgroup: load and release pidlists from seq_file start and
	stop respectively
Date: Sun, 24 Nov 2013 17:11:34 -0500
Message-ID: <1385331096-7918-8-git-send-email-tj__6258.1269340173$1385331165$gmane$org@kernel.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, pidlists are reference counted from file open and release
methods.  This means that holding onto an open file may waste memory
and reads may return data which is very stale.  Both aren't critical
because pidlists are keyed and shared per namespace and, well, the
user isn't supposed to have large delay between open and reads.

cgroup is planned to be converted to use kernfs and it'd be best if we
can stick to just the seq_file operations - start, next, stop and
show.  This can be achieved by loading pidlist on demand from start
and release with time delay from stop, so that consecutive reads don't
end up reloading the pidlist on each iteration.  This would remove the
need for hooking into open and release while also avoiding issues with
holding onto pidlist for too long.

The previous patches implemented delayed release and restructured
pidlist handling so that pidlists can be loaded and released from
seq_file start / stop.  This patch actually moves pidlist load to
start and release to stop.

This means that pidlist is pinned only between start and stop and may
go away between two consecutive read calls if the two calls are apart
by more than CGROUP_PIDLIST_DESTROY_DELAY.  cgroup_pidlist_start()
thus can't re-use the stored cgroup_pid_list_open_file->pidlist
directly.  During start, it's only used as a hint indicating whether
this is the first start after open or not and pidlist is always looked
up or created.

pidlist_mutex locking and reference counting are moved out of
pidlist_array_load() so that pidlist_array_load() can perform lookup
and creation atomically.  While this enlarges the area covered by
pidlist_mutex, given how the lock is used, it's highly unlikely to be
noticeable.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 62 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 28 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4ceeab0..8d2d9d4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3471,6 +3471,8 @@ struct cgroup_pidlist_open_file {
 	struct cgroup_pidlist		*pidlist;
 };
 
+static void cgroup_release_pid_array(struct cgroup_pidlist *l);
+
 /*
  * The following two functions "fix" the issue where there are more pids
  * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
@@ -3628,6 +3630,8 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	struct task_struct *tsk;
 	struct cgroup_pidlist *l;
 
+	lockdep_assert_held(&cgrp->pidlist_mutex);
+
 	/*
 	 * If cgroup gets more users after we read count, we won't have
 	 * enough space - tough.  This race is indistinguishable to the
@@ -3658,8 +3662,6 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	if (type == CGROUP_FILE_PROCS)
 		length = pidlist_uniq(array, length);
 
-	mutex_lock(&cgrp->pidlist_mutex);
-
 	l = cgroup_pidlist_find_create(cgrp, type);
 	if (!l) {
 		mutex_unlock(&cgrp->pidlist_mutex);
@@ -3671,10 +3673,6 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	pidlist_free(l->list);
 	l->list = array;
 	l->length = length;
-	l->use_count++;
-
-	mutex_unlock(&cgrp->pidlist_mutex);
-
 	*lp = l;
 	return 0;
 }
@@ -3749,11 +3747,34 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	 * next pid to display, if any
 	 */
 	struct cgroup_pidlist_open_file *of = s->private;
-	struct cgroup_pidlist *l = of->pidlist;
+	struct cgroup *cgrp = of->cgrp;
+	struct cgroup_pidlist *l;
 	int index = 0, pid = *pos;
-	int *iter;
+	int *iter, ret;
+
+	mutex_lock(&cgrp->pidlist_mutex);
+
+	/*
+	 * !NULL @of->pidlist indicates that this isn't the first start()
+	 * after open.  If the matching pidlist is around, we can use that.
+	 * Look for it.  Note that @of->pidlist can't be used directly.  It
+	 * could already have been destroyed.
+	 */
+	if (of->pidlist)
+		of->pidlist = cgroup_pidlist_find(cgrp, of->type);
+
+	/*
+	 * Either this is the first start() after open or the matching
+	 * pidlist has been destroyed inbetween.  Create a new one.
+	 */
+	if (!of->pidlist) {
+		ret = pidlist_array_load(of->cgrp, of->type, &of->pidlist);
+		if (ret)
+			return ERR_PTR(ret);
+	}
+	l = of->pidlist;
+	l->use_count++;
 
-	mutex_lock(&of->cgrp->pidlist_mutex);
 	if (pid) {
 		int end = l->length;
 
@@ -3782,6 +3803,8 @@ static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 	struct cgroup_pidlist_open_file *of = s->private;
 
 	mutex_unlock(&of->cgrp->pidlist_mutex);
+	if (of->pidlist)
+		cgroup_release_pid_array(of->pidlist);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
@@ -3830,20 +3853,11 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 	mutex_unlock(&l->owner->pidlist_mutex);
 }
 
-static int cgroup_pidlist_release(struct inode *inode, struct file *file)
-{
-	struct cgroup_pidlist_open_file *of;
-
-	of = ((struct seq_file *)file->private_data)->private;
-	cgroup_release_pid_array(of->pidlist);
-	return seq_release_private(inode, file);
-}
-
 static const struct file_operations cgroup_pidlist_operations = {
 	.read = seq_read,
 	.llseek = seq_lseek,
 	.write = cgroup_file_write,
-	.release = cgroup_pidlist_release,
+	.release = seq_release_private,
 };
 
 /*
@@ -3856,27 +3870,19 @@ static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 {
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 	struct cgroup_pidlist_open_file *of;
-	struct cgroup_pidlist *l;
 	int retval;
 
-	/* have the array populated */
-	retval = pidlist_array_load(cgrp, type, &l);
-	if (retval)
-		return retval;
 	/* configure file information */
 	file->f_op = &cgroup_pidlist_operations;
 
 	retval = seq_open_private(file, &cgroup_pidlist_seq_operations,
 				  sizeof(*of));
-	if (retval) {
-		cgroup_release_pid_array(l);
+	if (retval)
 		return retval;
-	}
 
 	of = ((struct seq_file *)file->private_data)->private;
 	of->type = type;
 	of->cgrp = cgrp;
-	of->pidlist = l;
 	return 0;
 }
 static int cgroup_tasks_open(struct inode *unused, struct file *file)
-- 
1.8.4.2
