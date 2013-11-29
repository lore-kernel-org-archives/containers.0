From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 4/9] cgroup: introduce struct cgroup_pidlist_open_file
Date: Fri, 29 Nov 2013 10:44:53 -0500
Message-ID: <20131129154453.GD3717@htj.dyndns.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
	<1385331096-7918-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385331096-7918-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From 62236858f3cc558135d1ab6b2af44d22c489bb7f Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Fri, 29 Nov 2013 10:42:58 -0500

For pidlist files, seq_file->private pointed to the loaded
cgroup_pidlist; however, pidlist loading is planned to be moved to
cgroup_pidlist_start() for kernfs conversion and seq_file->private
needs to carry more information from open to allow that.

This patch introduces struct cgroup_pidlist_open_file which contains
type, cgrp and pidlist and updates pidlist seq_file->private to point
to it using seq_open_private() and seq_release_private().  Note that
this eventually will be replaced by kernfs_open_file.

While this patch makes more information available to seq_file
operations, they don't use it yet and this patch doesn't introduce any
behavior changes except for allocation of the extra private struct.

v2: use __seq_open_private() instead of seq_open_private() for brevity
    as suggested by Li.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 39 +++++++++++++++++++++++++++------------
 1 file changed, 27 insertions(+), 12 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index acdcddf..ef019c0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3468,6 +3468,13 @@ struct cgroup_pidlist {
 	struct delayed_work destroy_dwork;
 };
 
+/* seq_file->private points to the following */
+struct cgroup_pidlist_open_file {
+	enum cgroup_filetype		type;
+	struct cgroup			*cgrp;
+	struct cgroup_pidlist		*pidlist;
+};
+
 /*
  * The following two functions "fix" the issue where there are more pids
  * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
@@ -3739,7 +3746,8 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	 * after a seek to the start). Use a binary-search to find the
 	 * next pid to display, if any
 	 */
-	struct cgroup_pidlist *l = s->private;
+	struct cgroup_pidlist_open_file *of = s->private;
+	struct cgroup_pidlist *l = of->pidlist;
 	int index = 0, pid = *pos;
 	int *iter;
 
@@ -3769,13 +3777,15 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 
 static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
-	struct cgroup_pidlist *l = s->private;
-	up_read(&l->rwsem);
+	struct cgroup_pidlist_open_file *of = s->private;
+
+	up_read(&of->pidlist->rwsem);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct cgroup_pidlist *l = s->private;
+	struct cgroup_pidlist_open_file *of = s->private;
+	struct cgroup_pidlist *l = of->pidlist;
 	pid_t *p = v;
 	pid_t *end = l->list + l->length;
 	/*
@@ -3820,11 +3830,11 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 
 static int cgroup_pidlist_release(struct inode *inode, struct file *file)
 {
-	struct cgroup_pidlist *l;
+	struct cgroup_pidlist_open_file *of;
 
-	l = ((struct seq_file *)file->private_data)->private;
-	cgroup_release_pid_array(l);
-	return seq_release(inode, file);
+	of = ((struct seq_file *)file->private_data)->private;
+	cgroup_release_pid_array(of->pidlist);
+	return seq_release_private(inode, file);
 }
 
 static const struct file_operations cgroup_pidlist_operations = {
@@ -3843,6 +3853,7 @@ static const struct file_operations cgroup_pidlist_operations = {
 static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 {
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
+	struct cgroup_pidlist_open_file *of;
 	struct cgroup_pidlist *l;
 	int retval;
 
@@ -3853,12 +3864,16 @@ static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 	/* configure file information */
 	file->f_op = &cgroup_pidlist_operations;
 
-	retval = seq_open(file, &cgroup_pidlist_seq_operations);
-	if (retval) {
+	of = __seq_open_private(file, &cgroup_pidlist_seq_operations,
+				sizeof(*of));
+	if (!of) {
 		cgroup_release_pid_array(l);
-		return retval;
+		return -ENOMEM;
 	}
-	((struct seq_file *)file->private_data)->private = l;
+
+	of->type = type;
+	of->cgrp = cgrp;
+	of->pidlist = l;
 	return 0;
 }
 static int cgroup_tasks_open(struct inode *unused, struct file *file)
-- 
1.8.4.2
