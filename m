From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 12/12] cgroup: unify pidlist and other file handling
Date: Wed, 4 Dec 2013 10:09:43 -0500
Message-ID: <20131204150943.GM3158__17419.7586522952$1386169797$gmane$org@htj.dyndns.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-13-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1385595759-17656-13-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

From 319da8b44d61ab3452caccc46a0944755e617cbe Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 4 Dec 2013 10:06:18 -0500

In preparation of conversion to kernfs, cgroup file handling is
updated so that it can be easily mapped to kernfs.  With the previous
changes, the difference between pidlist and other files are very
small.  Both are served by seq_file in a pretty standard way with the
only difference being !pidlist files use single_open().

This patch adds cftype->seq_start(), ->seq_next and ->seq_stop() and
implements the matching cgroup_seqfile_start/next/stop() which either
emulates single_open() behavior or invokes cftype->seq_*() operations
if specified.  This allows using single seq_operations for both
pidlist and other files and makes cgroup_pidlist_operations and
cgorup_pidlist_open() no longer necessary.  As cgroup_pidlist_open()
was the only user of cftype->open(), the method is dropped together.

This brings cftype file interface very close to kernfs interface and
mapping shouldn't be too difficult.  Once converted to kernfs, most of
the plumbing code including cgroup_seqfile_*() will be removed as
kernfs provides those facilities.

This patch does not introduce any behavior changes.

v2: Refreshed on top of the updated "cgroup: introduce struct
    cgroup_pidlist_open_file".

v3: Refreshed on top of the updated "cgroup: attach cgroup_open_file
    to all cgroup files".

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |   6 ++-
 kernel/cgroup.c        | 112 +++++++++++++++++++++++++++----------------------
 2 files changed, 68 insertions(+), 50 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b32a0f8..8b9a594 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -434,7 +434,6 @@ struct cftype {
 	 */
 	struct cgroup_subsys *ss;
 
-	int (*open)(struct inode *inode, struct file *file);
 	/*
 	 * read_u64() is a shortcut for the common case of returning a
 	 * single integer. Use it in place of read()
@@ -448,6 +447,11 @@ struct cftype {
 	/* generic seq_file read interface */
 	int (*seq_show)(struct seq_file *sf, void *v);
 
+	/* optional ops, implement all or none */
+	void *(*seq_start)(struct seq_file *sf, loff_t *ppos);
+	void *(*seq_next)(struct seq_file *sf, void *v, loff_t *ppos);
+	void (*seq_stop)(struct seq_file *sf, void *v);
+
 	/*
 	 * write_u64() is a shortcut for the common case of accepting
 	 * a single integer (as parsed by simple_strtoull) from
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c45e633..f9ae38a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2286,6 +2286,45 @@ out_free:
  * supports string->u64 maps, but can be extended in future.
  */
 
+static void *cgroup_seqfile_start(struct seq_file *seq, loff_t *ppos)
+{
+	struct cftype *cft = seq_cft(seq);
+
+	if (cft->seq_start) {
+		return cft->seq_start(seq, ppos);
+	} else {
+		/*
+		 * The same behavior and code as single_open().  Returns
+		 * !NULL if pos is at the beginning; otherwise, NULL.
+		 */
+		return NULL + !*ppos;
+	}
+}
+
+static void *cgroup_seqfile_next(struct seq_file *seq, void *v, loff_t *ppos)
+{
+	struct cftype *cft = seq_cft(seq);
+
+	if (cft->seq_next) {
+		return cft->seq_next(seq, v, ppos);
+	} else {
+		/*
+		 * The same behavior and code as single_open(), always
+		 * terminate after the initial read.
+		 */
+		++*ppos;
+		return NULL;
+	}
+}
+
+static void cgroup_seqfile_stop(struct seq_file *seq, void *v)
+{
+	struct cftype *cft = seq_cft(seq);
+
+	if (cft->seq_stop)
+		cft->seq_stop(seq, v);
+}
+
 static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 {
 	struct cftype *cft = seq_cft(m);
@@ -2303,12 +2342,20 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 	return 0;
 }
 
+static struct seq_operations cgroup_seq_operations = {
+	.start		= cgroup_seqfile_start,
+	.next		= cgroup_seqfile_next,
+	.stop		= cgroup_seqfile_stop,
+	.show		= cgroup_seqfile_show,
+};
+
 static int cgroup_file_open(struct inode *inode, struct file *file)
 {
 	struct cfent *cfe = __d_cfe(file->f_dentry);
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup *cgrp = __d_cgrp(cfe->dentry->d_parent);
 	struct cgroup_subsys_state *css;
+	struct cgroup_open_file *of;
 	int err;
 
 	err = generic_file_open(inode, file);
@@ -2338,24 +2385,16 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	WARN_ON_ONCE(cfe->css && cfe->css != css);
 	cfe->css = css;
 
-	if (cft->open) {
-		err = cft->open(inode, file);
-	} else {
-		struct cgroup_open_file *of;
-
-		err = -ENOMEM;
-		of = kzalloc(sizeof(*of), GFP_KERNEL);
-		if (of) {
-			of->cfe = cfe;
-			err = single_open(file, cgroup_seqfile_show, of);
-			if (err)
-				kfree(of);
-		}
+	of = __seq_open_private(file, &cgroup_seq_operations,
+				sizeof(struct cgroup_open_file));
+	if (of) {
+		of->cfe = cfe;
+		return 0;
 	}
 
-	if (css->ss && err)
+	if (css->ss)
 		css_put(css);
-	return err;
+	return -ENOMEM;
 }
 
 static int cgroup_file_release(struct inode *inode, struct file *file)
@@ -2365,8 +2404,7 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 
 	if (css->ss)
 		css_put(css);
-	kfree(((struct seq_file *)file->private_data)->private);
-	return single_release(inode, file);
+	return seq_release_private(inode, file);
 }
 
 /*
@@ -3777,36 +3815,6 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
 	.show = cgroup_pidlist_show,
 };
 
-static const struct file_operations cgroup_pidlist_operations = {
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.write = cgroup_file_write,
-	.release = seq_release_private,
-};
-
-/*
- * The following functions handle opens on a file that displays a pidlist
- * (tasks or procs). Prepare an array of the process/thread IDs of whoever's
- * in the cgroup.
- */
-/* helper function for the two below it */
-static int cgroup_pidlist_open(struct inode *unused, struct file *file)
-{
-	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cgroup_open_file *of;
-
-	/* configure file information */
-	file->f_op = &cgroup_pidlist_operations;
-
-	of = __seq_open_private(file, &cgroup_pidlist_seq_operations,
-				sizeof(*of));
-	if (!of)
-		return -ENOMEM;
-
-	of->cfe = cfe;
-	return 0;
-}
-
 static u64 cgroup_read_notify_on_release(struct cgroup_subsys_state *css,
 					 struct cftype *cft)
 {
@@ -3860,7 +3868,10 @@ static int cgroup_clone_children_write(struct cgroup_subsys_state *css,
 static struct cftype cgroup_base_files[] = {
 	{
 		.name = "cgroup.procs",
-		.open = cgroup_pidlist_open,
+		.seq_start = cgroup_pidlist_start,
+		.seq_next = cgroup_pidlist_next,
+		.seq_stop = cgroup_pidlist_stop,
+		.seq_show = cgroup_pidlist_show,
 		.private = CGROUP_FILE_PROCS,
 		.write_u64 = cgroup_procs_write,
 		.mode = S_IRUGO | S_IWUSR,
@@ -3885,7 +3896,10 @@ static struct cftype cgroup_base_files[] = {
 	{
 		.name = "tasks",
 		.flags = CFTYPE_INSANE,		/* use "procs" instead */
-		.open = cgroup_pidlist_open,
+		.seq_start = cgroup_pidlist_start,
+		.seq_next = cgroup_pidlist_next,
+		.seq_stop = cgroup_pidlist_stop,
+		.seq_show = cgroup_pidlist_show,
 		.private = CGROUP_FILE_TASKS,
 		.write_u64 = cgroup_tasks_write,
 		.mode = S_IRUGO | S_IWUSR,
-- 
1.8.4.2
