From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] cgroups: cleanup for dummy root
Date: Fri, 28 Nov 2008 15:27:08 +0800
Message-ID: <492F9D4C.2020204__2061.74913696504$1227857450$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

- Don't link rootnode to the root list, so root_list contains active
  hierarchies only as the comment indicates.

- Don't link css_sets to the dummy cgroup, because we never want to
  run through the tasks in that dummpy cgroup (which means run
  through all the tasks in the system).

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fe00b3b..46d9981 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -84,7 +84,7 @@ struct cgroupfs_root {
 	/* Tracks how many cgroups are currently defined in hierarchy.*/
 	int number_of_cgroups;
 
-	/* A list running through the mounted hierarchies */
+	/* A list running through the active hierarchies */
 	struct list_head root_list;
 
 	/* Hierarchy-specific flags */
@@ -184,7 +184,6 @@ struct cg_cgroup_link {
  */
 
 static struct css_set init_css_set;
-static struct cg_cgroup_link init_css_set_link;
 
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
@@ -456,15 +455,6 @@ static struct css_set *find_css_set(
 			list_add(&link->cg_link_list, &res->cg_links);
 		}
 	}
-	if (list_empty(&rootnode.subsys_list)) {
-		link = list_entry(tmp_cg_links.next,
-				  struct cg_cgroup_link,
-				  cgrp_link_list);
-		list_del(&link->cgrp_link_list);
-		list_add(&link->cgrp_link_list, &dummytop->css_sets);
-		link->cg = res;
-		list_add(&link->cg_link_list, &res->cg_links);
-	}
 
 	BUG_ON(!list_empty(&tmp_cg_links));
 
@@ -2561,16 +2551,9 @@ int __init cgroup_init_early(void)
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
 	init_cgroup_root(&rootnode);
-	list_add(&rootnode.root_list, &roots);
-	root_count = 1;
+	root_count = 0;
 	init_task.cgroups = &init_css_set;
 
-	init_css_set_link.cg = &init_css_set;
-	list_add(&init_css_set_link.cgrp_link_list,
-		 &rootnode.top_cgroup.css_sets);
-	list_add(&init_css_set_link.cg_link_list,
-		 &init_css_set.cg_links);
-
 	for (i = 0; i < CSS_SET_TABLE_SIZE; i++)
 		INIT_HLIST_HEAD(&css_set_table[i]);
 
@@ -2674,9 +2657,6 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 		int subsys_id;
 		int count = 0;
 
-		/* Skip this hierarchy if it has no active subsystems */
-		if (!root->actual_subsys_bits)
-			continue;
 		seq_printf(m, "%lu:", root->subsys_bits);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
-- 
1.5.4.rc3
