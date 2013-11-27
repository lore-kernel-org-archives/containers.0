From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/12] cgroup: remove cftype->read(),
	->read_map() and ->write()
Date: Wed, 27 Nov 2013 18:42:33 -0500
Message-ID: <1385595759-17656-7-git-send-email-tj__4707.04884869537$1385595808$gmane$org@kernel.org>
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

In preparation of conversion to kernfs, cgroup file handling is being
consolidated so that it can be easily mapped to the seq_file based
interface of kernfs.

After recent updates, ->read() and ->read_map() don't have any user
left and ->write() never had any user.  Remove them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 25 -------------------------
 kernel/cgroup.c        | 26 ++++----------------------
 2 files changed, 4 insertions(+), 47 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 50d8cc3..53e11da 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -387,16 +387,6 @@ struct css_set {
 };
 
 /*
- * cgroup_map_cb is an abstract callback API for reporting map-valued
- * control files
- */
-
-struct cgroup_map_cb {
-	int (*fill)(struct cgroup_map_cb *cb, const char *key, u64 value);
-	void *state;
-};
-
-/*
  * struct cftype: handler definitions for cgroup control files
  *
  * When reading/writing to a file:
@@ -444,9 +434,6 @@ struct cftype {
 	struct cgroup_subsys *ss;
 
 	int (*open)(struct inode *inode, struct file *file);
-	ssize_t (*read)(struct cgroup_subsys_state *css, struct cftype *cft,
-			struct file *file,
-			char __user *buf, size_t nbytes, loff_t *ppos);
 	/*
 	 * read_u64() is a shortcut for the common case of returning a
 	 * single integer. Use it in place of read()
@@ -457,24 +444,12 @@ struct cftype {
 	 */
 	s64 (*read_s64)(struct cgroup_subsys_state *css, struct cftype *cft);
 	/*
-	 * read_map() is used for defining a map of key/value
-	 * pairs. It should call cb->fill(cb, key, value) for each
-	 * entry. The key/value pairs (and their ordering) should not
-	 * change between reboots.
-	 */
-	int (*read_map)(struct cgroup_subsys_state *css, struct cftype *cft,
-			struct cgroup_map_cb *cb);
-	/*
 	 * read_seq_string() is used for outputting a simple sequence
 	 * using seqfile.
 	 */
 	int (*read_seq_string)(struct cgroup_subsys_state *css,
 			       struct cftype *cft, struct seq_file *m);
 
-	ssize_t (*write)(struct cgroup_subsys_state *css, struct cftype *cft,
-			 struct file *file,
-			 const char __user *buf, size_t nbytes, loff_t *ppos);
-
 	/*
 	 * write_u64() is a shortcut for the common case of accepting
 	 * a single integer (as parsed by simple_strtoull) from
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c36d906..3592515 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2324,8 +2324,6 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup_subsys_state *css = cfe->css;
 
-	if (cft->write)
-		return cft->write(css, cft, file, buf, nbytes, ppos);
 	if (cft->write_u64 || cft->write_s64)
 		return cgroup_write_X64(css, cft, file, buf, nbytes, ppos);
 	if (cft->write_string)
@@ -2366,8 +2364,6 @@ static ssize_t cgroup_file_read(struct file *file, char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup_subsys_state *css = cfe->css;
 
-	if (cft->read)
-		return cft->read(css, cft, file, buf, nbytes, ppos);
 	if (cft->read_u64)
 		return cgroup_read_u64(css, cft, file, buf, nbytes, ppos);
 	if (cft->read_s64)
@@ -2380,25 +2376,12 @@ static ssize_t cgroup_file_read(struct file *file, char __user *buf,
  * supports string->u64 maps, but can be extended in future.
  */
 
-static int cgroup_map_add(struct cgroup_map_cb *cb, const char *key, u64 value)
-{
-	struct seq_file *sf = cb->state;
-	return seq_printf(sf, "%s %llu\n", key, (unsigned long long)value);
-}
-
 static int cgroup_seqfile_show(struct seq_file *m, void *arg)
 {
 	struct cfent *cfe = m->private;
 	struct cftype *cft = cfe->type;
 	struct cgroup_subsys_state *css = cfe->css;
 
-	if (cft->read_map) {
-		struct cgroup_map_cb cb = {
-			.fill = cgroup_map_add,
-			.state = m,
-		};
-		return cft->read_map(css, cft, &cb);
-	}
 	return cft->read_seq_string(css, cft, m);
 }
 
@@ -2444,7 +2427,7 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	WARN_ON_ONCE(cfe->css && cfe->css != css);
 	cfe->css = css;
 
-	if (cft->read_map || cft->read_seq_string) {
+	if (cft->read_seq_string) {
 		file->f_op = &cgroup_seqfile_operations;
 		err = single_open(file, cgroup_seqfile_show, cfe);
 	} else if (cft->open) {
@@ -2658,12 +2641,11 @@ static umode_t cgroup_file_mode(const struct cftype *cft)
 	if (cft->mode)
 		return cft->mode;
 
-	if (cft->read || cft->read_u64 || cft->read_s64 ||
-	    cft->read_map || cft->read_seq_string)
+	if (cft->read_u64 || cft->read_s64 || cft->read_seq_string)
 		mode |= S_IRUGO;
 
-	if (cft->write || cft->write_u64 || cft->write_s64 ||
-	    cft->write_string || cft->trigger)
+	if (cft->write_u64 || cft->write_s64 || cft->write_string ||
+	    cft->trigger)
 		mode |= S_IWUSR;
 
 	return mode;
-- 
1.8.4.2
