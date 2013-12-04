From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 10/12] cgroup: attach cgroup_open_file to all cgroup files
Date: Wed, 4 Dec 2013 10:09:13 -0500
Message-ID: <20131204150901.GL3158__48138.5113126182$1386169772$gmane$org@htj.dyndns.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-11-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-11-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

From dfc10ab0fd9a14efe6c279989b3e65a52b03ca40 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 4 Dec 2013 10:06:18 -0500

In preparation of conversion to kernfs, cgroup file handling is
updated so that it can be easily mapped to kernfs.  This patch
attaches cgroup_open_file, which used to be attached to pidlist files,
to all cgroup files, introduces seq_css/cft() accessors to determine
the cgroup_subsys_state and cftype associated with a given cgroup
seq_file, exports them as public interface.

This doesn't cause any behavior changes but unifies cgroup file
handling across different file types and will help converting them to
kernfs seq_show() interface.

v2: Li pointed out that the original patch was using
    single_open_size() incorrectly assuming that the size param is
    private data size.  Fix it by allocating @of separately and
    passing it to single_open() and explicitly freeing it in the
    release path.  This isn't the prettiest but this path is gonna be
    restructured by the following patches pretty soon.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
git branch updated accordingly.  Thanks.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-consolidate-file-handling

 include/linux/cgroup.h | 33 +++++++++++++++++++++++++++++++++
 kernel/cgroup.c        | 50 ++++++++++++++++++++------------------------------
 2 files changed, 53 insertions(+), 30 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 53e11da..c3d698a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -21,6 +21,7 @@
 #include <linux/xattr.h>
 #include <linux/fs.h>
 #include <linux/percpu-refcount.h>
+#include <linux/seq_file.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -490,6 +491,26 @@ struct cftype_set {
 };
 
 /*
+ * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.  Don't
+ * access directly.
+ */
+struct cfent {
+	struct list_head		node;
+	struct dentry			*dentry;
+	struct cftype			*type;
+	struct cgroup_subsys_state	*css;
+
+	/* file xattrs */
+	struct simple_xattrs		xattrs;
+};
+
+/* seq_file->private points to the following, only ->priv is public */
+struct cgroup_open_file {
+	struct cfent			*cfe;
+	void				*priv;
+};
+
+/*
  * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
  * function can be called as long as @cgrp is accessible.
  */
@@ -504,6 +525,18 @@ static inline const char *cgroup_name(const struct cgroup *cgrp)
 	return rcu_dereference(cgrp->name)->name;
 }
 
+static inline struct cgroup_subsys_state *seq_css(struct seq_file *seq)
+{
+	struct cgroup_open_file *of = seq->private;
+	return of->cfe->css;
+}
+
+static inline struct cftype *seq_cft(struct seq_file *seq)
+{
+	struct cgroup_open_file *of = seq->private;
+	return of->cfe->type;
+}
+
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 int cgroup_rm_cftypes(struct cftype *cfts);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 17272893..036c05d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -41,7 +41,6 @@
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/backing-dev.h>
-#include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/magic.h>
 #include <linux/spinlock.h>
@@ -130,19 +129,6 @@ static struct cgroupfs_root cgroup_dummy_root;
 /* dummy_top is a shorthand for the dummy hierarchy's top cgroup */
 static struct cgroup * const cgroup_dummy_top = &cgroup_dummy_root.top_cgroup;
 
-/*
- * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.
- */
-struct cfent {
-	struct list_head		node;
-	struct dentry			*dentry;
-	struct cftype			*type;
-	struct cgroup_subsys_state	*css;
-
-	/* file xattrs */
-	struct simple_xattrs		xattrs;
-};
-
 /* The list of hierarchy roots */
 
 static LIST_HEAD(cgroup_roots);
@@ -2302,9 +2288,8 @@ out_free:
 
 static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 {
-	struct cfent *cfe = m->private;
-	struct cftype *cft = cfe->type;
-	struct cgroup_subsys_state *css = cfe->css;
+	struct cftype *cft = seq_cft(m);
+	struct cgroup_subsys_state *css = seq_css(m);
 
 	if (cft->read_seq_string)
 		return cft->read_seq_string(css, cft, m);
@@ -2353,10 +2338,20 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	WARN_ON_ONCE(cfe->css && cfe->css != css);
 	cfe->css = css;
 
-	if (cft->open)
+	if (cft->open) {
 		err = cft->open(inode, file);
-	else
-		err = single_open(file, cgroup_seqfile_show, cfe);
+	} else {
+		struct cgroup_open_file *of;
+
+		err = -ENOMEM;
+		of = kzalloc(sizeof(*of), GFP_KERNEL);
+		if (of) {
+			of->cfe = cfe;
+			err = single_open(file, cgroup_seqfile_show, of);
+			if (err)
+				kfree(of);
+		}
+	}
 
 	if (css->ss && err)
 		css_put(css);
@@ -2370,6 +2365,7 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 
 	if (css->ss)
 		css_put(css);
+	kfree(((struct seq_file *)file->private_data)->private);
 	return single_release(inode, file);
 }
 
@@ -3368,12 +3364,6 @@ struct cgroup_pidlist {
 	struct delayed_work destroy_dwork;
 };
 
-/* seq_file->private points to the following */
-struct cgroup_open_file {
-	struct cfent			*cfe;
-	void				*priv;
-};
-
 /*
  * The following two functions "fix" the issue where there are more pids
  * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
@@ -3689,9 +3679,9 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	 * next pid to display, if any
 	 */
 	struct cgroup_open_file *of = s->private;
-	struct cgroup *cgrp = of->cfe->css->cgroup;
+	struct cgroup *cgrp = seq_css(s)->cgroup;
 	struct cgroup_pidlist *l;
-	enum cgroup_filetype type = of->cfe->type->private;
+	enum cgroup_filetype type = seq_cft(s)->private;
 	int index = 0, pid = *pos;
 	int *iter, ret;
 
@@ -3749,7 +3739,7 @@ static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 	if (l)
 		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork,
 				 CGROUP_PIDLIST_DESTROY_DELAY);
-	mutex_unlock(&of->cfe->css->cgroup->pidlist_mutex);
+	mutex_unlock(&seq_css(s)->cgroup->pidlist_mutex);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
@@ -3766,7 +3756,7 @@ static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 	if (p >= end) {
 		return NULL;
 	} else {
-		*pos = cgroup_pid_fry(of->cfe->css->cgroup, *p);
+		*pos = cgroup_pid_fry(seq_css(s)->cgroup, *p);
 		return p;
 	}
 }
-- 
1.8.4.2
