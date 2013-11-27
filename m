From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/12] cgroup: unify read path so that seq_file is always used
Date: Wed, 27 Nov 2013 18:42:35 -0500
Message-ID: <1385595759-17656-9-git-send-email-tj__24317.2023598619$1385595827$gmane$org@kernel.org>
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

With the recent removal of cftype->read() and ->read_map(), only three
operations are remaining, ->read_u64(), ->read_s64() and
->read_seq_string().  Currently, the first two are handled directly
while the last is handled through seq_file.

It is trivial to serve the first two through the seq_file path too.
This patch restructures read path so that all operations are served
through cgroup_seqfile_show().  This makes all cgroup files seq_file -
single_open/release() are now used by default,
cgroup_seqfile_operations is dropped, and cgroup_file_operations uses
seq_read() for read.

This simplifies the code and makes the read path easy to convert to
use kernfs.

Note that, while cgroup_file_operations uses seq_read() for read, it
still uses generic_file_llseek() for seeking instead of seq_lseek().
This is different from cgroup_seqfile_operations but shouldn't break
anything and brings the seeking behavior aligned with kernfs.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 68 +++++++++++++--------------------------------------------
 1 file changed, 15 insertions(+), 53 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 23abe8e..7048e7f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2295,42 +2295,6 @@ out_free:
 	return ret ?: nbytes;
 }
 
-static ssize_t cgroup_read_u64(struct cgroup_subsys_state *css,
-			       struct cftype *cft, struct file *file,
-			       char __user *buf, size_t nbytes, loff_t *ppos)
-{
-	char tmp[CGROUP_LOCAL_BUFFER_SIZE];
-	u64 val = cft->read_u64(css, cft);
-	int len = sprintf(tmp, "%llu\n", (unsigned long long) val);
-
-	return simple_read_from_buffer(buf, nbytes, ppos, tmp, len);
-}
-
-static ssize_t cgroup_read_s64(struct cgroup_subsys_state *css,
-			       struct cftype *cft, struct file *file,
-			       char __user *buf, size_t nbytes, loff_t *ppos)
-{
-	char tmp[CGROUP_LOCAL_BUFFER_SIZE];
-	s64 val = cft->read_s64(css, cft);
-	int len = sprintf(tmp, "%lld\n", (long long) val);
-
-	return simple_read_from_buffer(buf, nbytes, ppos, tmp, len);
-}
-
-static ssize_t cgroup_file_read(struct file *file, char __user *buf,
-				size_t nbytes, loff_t *ppos)
-{
-	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cftype *cft = __d_cft(file->f_dentry);
-	struct cgroup_subsys_state *css = cfe->css;
-
-	if (cft->read_u64)
-		return cgroup_read_u64(css, cft, file, buf, nbytes, ppos);
-	if (cft->read_s64)
-		return cgroup_read_s64(css, cft, file, buf, nbytes, ppos);
-	return -EINVAL;
-}
-
 /*
  * seqfile ops/methods for returning structured data. Currently just
  * supports string->u64 maps, but can be extended in future.
@@ -2342,15 +2306,17 @@ static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 	struct cftype *cft = cfe->type;
 	struct cgroup_subsys_state *css = cfe->css;
 
-	return cft->read_seq_string(css, cft, m);
-}
+	if (cft->read_seq_string)
+		return cft->read_seq_string(css, cft, m);
 
-static const struct file_operations cgroup_seqfile_operations = {
-	.read = seq_read,
-	.write = cgroup_file_write,
-	.llseek = seq_lseek,
-	.release = cgroup_file_release,
-};
+	if (cft->read_u64)
+		seq_printf(m, "%llu\n", cft->read_u64(css, cft));
+	else if (cft->read_s64)
+		seq_printf(m, "%lld\n", cft->read_s64(css, cft));
+	else
+		return -EINVAL;
+	return 0;
+}
 
 static int cgroup_file_open(struct inode *inode, struct file *file)
 {
@@ -2387,12 +2353,10 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	WARN_ON_ONCE(cfe->css && cfe->css != css);
 	cfe->css = css;
 
-	if (cft->read_seq_string) {
-		file->f_op = &cgroup_seqfile_operations;
-		err = single_open(file, cgroup_seqfile_show, cfe);
-	} else if (cft->open) {
+	if (cft->open)
 		err = cft->open(inode, file);
-	}
+	else
+		err = single_open(file, cgroup_seqfile_show, cfe);
 
 	if (css->ss && err)
 		css_put(css);
@@ -2406,9 +2370,7 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 
 	if (css->ss)
 		css_put(css);
-	if (file->f_op == &cgroup_seqfile_operations)
-		single_release(inode, file);
-	return 0;
+	return single_release(inode, file);
 }
 
 /*
@@ -2519,7 +2481,7 @@ static ssize_t cgroup_listxattr(struct dentry *dentry, char *buf, size_t size)
 }
 
 static const struct file_operations cgroup_file_operations = {
-	.read = cgroup_file_read,
+	.read = seq_read,
 	.write = cgroup_file_write,
 	.llseek = generic_file_llseek,
 	.open = cgroup_file_open,
-- 
1.8.4.2
