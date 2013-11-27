From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/12] cgroup: unify pidlist and other file handling
Date: Wed, 27 Nov 2013 18:42:39 -0500
Message-ID: <1385595759-17656-13-git-send-email-tj__28732.2918222801$1385595854$gmane$org@kernel.org>
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

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   6 ++-
 kernel/cgroup.c        | 109 ++++++++++++++++++++++++++++---------------------
 2 files changed, 68 insertions(+), 47 deletions(-)

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
index 39fdf75..13a3d3b 100644
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
@@ -2303,6 +2342,13 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
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
@@ -2338,20 +2384,17 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	WARN_ON_ONCE(cfe->css && cfe->css != css);
 	cfe->css = css;
 
-	if (cft->open) {
-		err = cft->open(inode, file);
-	} else {
-		err = single_open_size(file, cgroup_seqfile_show, cfe,
-				       sizeof(struct cgroup_open_file));
-		if (!err) {
-			struct seq_file *sf = file->private_data;
-			struct cgroup_open_file *of = sf->private;
+	err = seq_open_private(file, &cgroup_seq_operations,
+			       sizeof(struct cgroup_open_file));
+	if (!err) {
+		struct seq_file *sf = file->private_data;
+		struct cgroup_open_file *of = sf->private;
 
-			of->cfe = cfe;
-		}
+		of->cfe = cfe;
+		return 0;
 	}
 
-	if (css->ss && err)
+	if (css->ss)
 		css_put(css);
 	return err;
 }
@@ -2363,7 +2406,7 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 
 	if (css->ss)
 		css_put(css);
-	return single_release(inode, file);
+	return seq_release_private(inode, file);
 }
 
 /*
@@ -3774,38 +3817,6 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
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
-	int retval;
-
-	/* configure file information */
-	file->f_op = &cgroup_pidlist_operations;
-
-	retval = seq_open_private(file, &cgroup_pidlist_seq_operations,
-				  sizeof(*of));
-	if (retval)
-		return retval;
-
-	of = ((struct seq_file *)file->private_data)->private;
-	of->cfe = cfe;
-	return 0;
-}
-
 static u64 cgroup_read_notify_on_release(struct cgroup_subsys_state *css,
 					 struct cftype *cft)
 {
@@ -3859,7 +3870,10 @@ static int cgroup_clone_children_write(struct cgroup_subsys_state *css,
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
@@ -3884,7 +3898,10 @@ static struct cftype cgroup_base_files[] = {
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
