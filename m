From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 1/8] CGroup Files: Clean up whitespace in struct cftype
Date: Fri, 20 Jun 2008 16:43:59 -0700
Message-ID: <20080621000729.853353000__46034.9989858971$1214007303$gmane$org@menage.corp.google.com>
References: <20080620234358.182933000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=cgroup_remove_spaces.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: pj-sJ/iWh9BUns@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch removes some extraneous spaces from method declarations in
struct cftype, to fit in with conventional kernel style.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 include/linux/cgroup.h |   32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

Index: cws-2.6.26-rc5-mm3/include/linux/cgroup.h
===================================================================
--- cws-2.6.26-rc5-mm3.orig/include/linux/cgroup.h
+++ cws-2.6.26-rc5-mm3/include/linux/cgroup.h
@@ -205,48 +205,48 @@ struct cftype {
 	 * subsystem, followed by a period */
 	char name[MAX_CFTYPE_NAME];
 	int private;
-	int (*open) (struct inode *inode, struct file *file);
-	ssize_t (*read) (struct cgroup *cgrp, struct cftype *cft,
-			 struct file *file,
-			 char __user *buf, size_t nbytes, loff_t *ppos);
+	int (*open)(struct inode *inode, struct file *file);
+	ssize_t (*read)(struct cgroup *cgrp, struct cftype *cft,
+			struct file *file,
+			char __user *buf, size_t nbytes, loff_t *ppos);
 	/*
 	 * read_u64() is a shortcut for the common case of returning a
 	 * single integer. Use it in place of read()
 	 */
-	u64 (*read_u64) (struct cgroup *cgrp, struct cftype *cft);
+	u64 (*read_u64)(struct cgroup *cgrp, struct cftype *cft);
 	/*
 	 * read_s64() is a signed version of read_u64()
 	 */
-	s64 (*read_s64) (struct cgroup *cgrp, struct cftype *cft);
+	s64 (*read_s64)(struct cgroup *cgrp, struct cftype *cft);
 	/*
 	 * read_map() is used for defining a map of key/value
 	 * pairs. It should call cb->fill(cb, key, value) for each
 	 * entry. The key/value pairs (and their ordering) should not
 	 * change between reboots.
 	 */
-	int (*read_map) (struct cgroup *cont, struct cftype *cft,
-			 struct cgroup_map_cb *cb);
+	int (*read_map)(struct cgroup *cont, struct cftype *cft,
+			struct cgroup_map_cb *cb);
 	/*
 	 * read_seq_string() is used for outputting a simple sequence
 	 * using seqfile.
 	 */
-	int (*read_seq_string) (struct cgroup *cont, struct cftype *cft,
-			 struct seq_file *m);
+	int (*read_seq_string)(struct cgroup *cont, struct cftype *cft,
+			       struct seq_file *m);
 
-	ssize_t (*write) (struct cgroup *cgrp, struct cftype *cft,
-			  struct file *file,
-			  const char __user *buf, size_t nbytes, loff_t *ppos);
+	ssize_t (*write)(struct cgroup *cgrp, struct cftype *cft,
+			 struct file *file,
+			 const char __user *buf, size_t nbytes, loff_t *ppos);
 
 	/*
 	 * write_u64() is a shortcut for the common case of accepting
 	 * a single integer (as parsed by simple_strtoull) from
 	 * userspace. Use in place of write(); return 0 or error.
 	 */
-	int (*write_u64) (struct cgroup *cgrp, struct cftype *cft, u64 val);
+	int (*write_u64)(struct cgroup *cgrp, struct cftype *cft, u64 val);
 	/*
 	 * write_s64() is a signed version of write_u64()
 	 */
-	int (*write_s64) (struct cgroup *cgrp, struct cftype *cft, s64 val);
+	int (*write_s64)(struct cgroup *cgrp, struct cftype *cft, s64 val);
 
 	/*
 	 * trigger() callback can be used to get some kick from the
@@ -256,7 +256,7 @@ struct cftype {
 	 */
 	int (*trigger)(struct cgroup *cgrp, unsigned int event);
 
-	int (*release) (struct inode *inode, struct file *file);
+	int (*release)(struct inode *inode, struct file *file);
 };
 
 struct cgroup_scanner {

--
