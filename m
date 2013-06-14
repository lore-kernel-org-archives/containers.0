From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH ] cgroup: rename cont to cgrp
Date: Fri, 14 Jun 2013 11:17:19 +0800
Message-ID: <51BA8B3F.3060606__8215.88926851309$1371179863$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cont is short for container. control group was named process container
at first, but then people found container already has a meaning in
linux kernel.

Clean up the leftover variable name @cont.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---

I'll clean up this for memcg later.

---
 include/linux/cgroup.h |  4 ++--
 kernel/cgroup.c        | 22 +++++++++++-----------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b7bd4be..9f6e26a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -436,13 +436,13 @@ struct cftype {
 	 * entry. The key/value pairs (and their ordering) should not
 	 * change between reboots.
 	 */
-	int (*read_map)(struct cgroup *cont, struct cftype *cft,
+	int (*read_map)(struct cgroup *cgrp, struct cftype *cft,
 			struct cgroup_map_cb *cb);
 	/*
 	 * read_seq_string() is used for outputting a simple sequence
 	 * using seqfile.
 	 */
-	int (*read_seq_string)(struct cgroup *cont, struct cftype *cft,
+	int (*read_seq_string)(struct cgroup *cgrp, struct cftype *cft,
 			       struct seq_file *m);
 
 	ssize_t (*write)(struct cgroup *cgrp, struct cftype *cft,
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index dd4ab91..25f1054 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5473,7 +5473,7 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cont)
+static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
 
@@ -5483,23 +5483,23 @@ static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cont)
 	return css;
 }
 
-static void debug_css_free(struct cgroup *cont)
+static void debug_css_free(struct cgroup *cgrp)
 {
-	kfree(cont->subsys[debug_subsys_id]);
+	kfree(cgrp->subsys[debug_subsys_id]);
 }
 
-static u64 debug_taskcount_read(struct cgroup *cont, struct cftype *cft)
+static u64 debug_taskcount_read(struct cgroup *cgrp, struct cftype *cft)
 {
-	return cgroup_task_count(cont);
+	return cgroup_task_count(cgrp);
 }
 
-static u64 current_css_set_read(struct cgroup *cont, struct cftype *cft)
+static u64 current_css_set_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	return (u64)(unsigned long)current->cgroups;
 }
 
-static u64 current_css_set_refcount_read(struct cgroup *cont,
-					   struct cftype *cft)
+static u64 current_css_set_refcount_read(struct cgroup *cgrp,
+					 struct cftype *cft)
 {
 	u64 count;
 
@@ -5509,7 +5509,7 @@ static u64 current_css_set_refcount_read(struct cgroup *cont,
 	return count;
 }
 
-static int current_css_set_cg_links_read(struct cgroup *cont,
+static int current_css_set_cg_links_read(struct cgroup *cgrp,
 					 struct cftype *cft,
 					 struct seq_file *seq)
 {
@@ -5536,14 +5536,14 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
 }
 
 #define MAX_TASKS_SHOWN_PER_CSS 25
-static int cgroup_css_links_read(struct cgroup *cont,
+static int cgroup_css_links_read(struct cgroup *cgrp,
 				 struct cftype *cft,
 				 struct seq_file *seq)
 {
 	struct cgrp_cset_link *link;
 
 	read_lock(&css_set_lock);
-	list_for_each_entry(link, &cont->cset_links, cset_link) {
+	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 		struct task_struct *task;
 		int count = 0;
-- 
1.8.0.2
