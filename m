From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/12] cgroup: generalize cgroup_pidlist_open_file
Date: Wed, 27 Nov 2013 18:42:36 -0500
Message-ID: <1385595759-17656-10-git-send-email-tj__34052.2365914241$1385595827$gmane$org@kernel.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

In preparation of conversion to kernfs, cgroup file handling is
updated so that it can be easily mapped to kernfs.  This patch renames
cgroup_pidlist_open_file to cgroup_open_file and updates it so that it
only contains a field to identify the specific file, ->cfe, and an
opaque ->priv pointer.  When cgroup is converted to kernfs, this will
be replaced by kernfs_open_file which contains about the same
information.

As whether the file is "cgroup.procs" or "tasks" should now be
determined from cgroup_open_file->cfe, the cftype->private for the two
files now carry the file type and cgroup_pidlist_start() reads the
type through cfe->type->private.  This makes the distinction between
cgroup_tasks_open() and cgroup_procs_open() unnecessary.
cgroup_pidlist_open() is now directly used as the open method.

This patch doesn't make any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 66 ++++++++++++++++++++++++++-------------------------------
 1 file changed, 30 insertions(+), 36 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7048e7f..bdb8e8d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3369,10 +3369,9 @@ struct cgroup_pidlist {
 };
 
 /* seq_file->private points to the following */
-struct cgroup_pidlist_open_file {
-	enum cgroup_filetype		type;
-	struct cgroup			*cgrp;
-	struct cgroup_pidlist		*pidlist;
+struct cgroup_open_file {
+	struct cfent			*cfe;
+	void				*priv;
 };
 
 /*
@@ -3689,33 +3688,35 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	 * after a seek to the start). Use a binary-search to find the
 	 * next pid to display, if any
 	 */
-	struct cgroup_pidlist_open_file *of = s->private;
-	struct cgroup *cgrp = of->cgrp;
+	struct cgroup_open_file *of = s->private;
+	struct cgroup *cgrp = of->cfe->css->cgroup;
 	struct cgroup_pidlist *l;
+	enum cgroup_filetype type = of->cfe->type->private;
 	int index = 0, pid = *pos;
 	int *iter, ret;
 
 	mutex_lock(&cgrp->pidlist_mutex);
 
 	/*
-	 * !NULL @of->pidlist indicates that this isn't the first start()
+	 * !NULL @of->priv indicates that this isn't the first start()
 	 * after open.  If the matching pidlist is around, we can use that.
-	 * Look for it.  Note that @of->pidlist can't be used directly.  It
+	 * Look for it.  Note that @of->priv can't be used directly.  It
 	 * could already have been destroyed.
 	 */
-	if (of->pidlist)
-		of->pidlist = cgroup_pidlist_find(cgrp, of->type);
+	if (of->priv)
+		of->priv = cgroup_pidlist_find(cgrp, type);
 
 	/*
 	 * Either this is the first start() after open or the matching
 	 * pidlist has been destroyed inbetween.  Create a new one.
 	 */
-	if (!of->pidlist) {
-		ret = pidlist_array_load(of->cgrp, of->type, &of->pidlist);
+	if (!of->priv) {
+		ret = pidlist_array_load(cgrp, type,
+					 (struct cgroup_pidlist **)&of->priv);
 		if (ret)
 			return ERR_PTR(ret);
 	}
-	l = of->pidlist;
+	l = of->priv;
 
 	if (pid) {
 		int end = l->length;
@@ -3742,19 +3743,19 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 
 static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
-	struct cgroup_pidlist_open_file *of = s->private;
+	struct cgroup_open_file *of = s->private;
+	struct cgroup_pidlist *l = of->priv;
 
-	if (of->pidlist)
-		mod_delayed_work(cgroup_pidlist_destroy_wq,
-				 &of->pidlist->destroy_dwork,
+	if (l)
+		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork,
 				 CGROUP_PIDLIST_DESTROY_DELAY);
-	mutex_unlock(&of->cgrp->pidlist_mutex);
+	mutex_unlock(&of->cfe->css->cgroup->pidlist_mutex);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct cgroup_pidlist_open_file *of = s->private;
-	struct cgroup_pidlist *l = of->pidlist;
+	struct cgroup_open_file *of = s->private;
+	struct cgroup_pidlist *l = of->priv;
 	pid_t *p = v;
 	pid_t *end = l->list + l->length;
 	/*
@@ -3765,7 +3766,7 @@ static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 	if (p >= end) {
 		return NULL;
 	} else {
-		*pos = cgroup_pid_fry(of->cgrp, *p);
+		*pos = cgroup_pid_fry(of->cfe->css->cgroup, *p);
 		return p;
 	}
 }
@@ -3799,10 +3800,10 @@ static const struct file_operations cgroup_pidlist_operations = {
  * in the cgroup.
  */
 /* helper function for the two below it */
-static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
+static int cgroup_pidlist_open(struct inode *unused, struct file *file)
 {
-	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
-	struct cgroup_pidlist_open_file *of;
+	struct cfent *cfe = __d_cfe(file->f_dentry);
+	struct cgroup_open_file *of;
 	int retval;
 
 	/* configure file information */
@@ -3814,18 +3815,9 @@ static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 		return retval;
 
 	of = ((struct seq_file *)file->private_data)->private;
-	of->type = type;
-	of->cgrp = cgrp;
+	of->cfe = cfe;
 	return 0;
 }
-static int cgroup_tasks_open(struct inode *unused, struct file *file)
-{
-	return cgroup_pidlist_open(file, CGROUP_FILE_TASKS);
-}
-static int cgroup_procs_open(struct inode *unused, struct file *file)
-{
-	return cgroup_pidlist_open(file, CGROUP_FILE_PROCS);
-}
 
 static u64 cgroup_read_notify_on_release(struct cgroup_subsys_state *css,
 					 struct cftype *cft)
@@ -3880,7 +3872,8 @@ static int cgroup_clone_children_write(struct cgroup_subsys_state *css,
 static struct cftype cgroup_base_files[] = {
 	{
 		.name = "cgroup.procs",
-		.open = cgroup_procs_open,
+		.open = cgroup_pidlist_open,
+		.private = CGROUP_FILE_PROCS,
 		.write_u64 = cgroup_procs_write,
 		.mode = S_IRUGO | S_IWUSR,
 	},
@@ -3904,7 +3897,8 @@ static struct cftype cgroup_base_files[] = {
 	{
 		.name = "tasks",
 		.flags = CFTYPE_INSANE,		/* use "procs" instead */
-		.open = cgroup_tasks_open,
+		.open = cgroup_pidlist_open,
+		.private = CGROUP_FILE_TASKS,
 		.write_u64 = cgroup_tasks_write,
 		.mode = S_IRUGO | S_IWUSR,
 	},
-- 
1.8.4.2
