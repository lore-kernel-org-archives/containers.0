From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroup: remove duplicate code in allocate_cg_link()
Date: Mon, 28 Jul 2008 10:20:58 +0800
Message-ID: <488D2D0A.7050006__26249.8619304553$1217212433$gmane$org@cn.fujitsu.com>
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

- just call free_cg_links() in allocate_cg_links()
- the list will get initialized in allocate_cg_links(), so don't init
  it twice

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 28debe4..249a517 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -355,6 +355,17 @@ static struct css_set *find_existing_css_set(
 	return NULL;
 }
 
+static void free_cg_links(struct list_head *tmp)
+{
+	struct cg_cgroup_link *link;
+	struct cg_cgroup_link *saved_link;
+
+	list_for_each_entry_safe(link, saved_link, tmp, cgrp_link_list) {
+		list_del(&link->cgrp_link_list);
+		kfree(link);
+	}
+}
+
 /*
  * allocate_cg_links() allocates "count" cg_cgroup_link structures
  * and chains them on tmp through their cgrp_link_list fields. Returns 0 on
@@ -363,17 +374,12 @@ static struct css_set *find_existing_css_set(
 static int allocate_cg_links(int count, struct list_head *tmp)
 {
 	struct cg_cgroup_link *link;
-	struct cg_cgroup_link *saved_link;
 	int i;
 	INIT_LIST_HEAD(tmp);
 	for (i = 0; i < count; i++) {
 		link = kmalloc(sizeof(*link), GFP_KERNEL);
 		if (!link) {
-			list_for_each_entry_safe(link, saved_link, tmp,
-						 cgrp_link_list) {
-				list_del(&link->cgrp_link_list);
-				kfree(link);
-			}
+			free_cg_links(tmp);
 			return -ENOMEM;
 		}
 		list_add(&link->cgrp_link_list, tmp);
@@ -381,17 +387,6 @@ static int allocate_cg_links(int count, struct list_head *tmp)
 	return 0;
 }
 
-static void free_cg_links(struct list_head *tmp)
-{
-	struct cg_cgroup_link *link;
-	struct cg_cgroup_link *saved_link;
-
-	list_for_each_entry_safe(link, saved_link, tmp, cgrp_link_list) {
-		list_del(&link->cgrp_link_list);
-		kfree(link);
-	}
-}
-
 /*
  * find_css_set() takes an existing cgroup group and a
  * cgroup object, and returns a css_set object that's
@@ -956,7 +951,6 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 	struct super_block *sb;
 	struct cgroupfs_root *root;
 	struct list_head tmp_cg_links;
-	INIT_LIST_HEAD(&tmp_cg_links);
 
 	/* First find the desired set of subsystems */
 	ret = parse_cgroupfs_options(data, &opts);
-- 
1.5.4.rc3
