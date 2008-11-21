From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: don't put struct cgroupfs_root protected by RCU
Date: Fri, 21 Nov 2008 16:49:28 +0800
Message-ID: <49267618.6080802__39570.9778102629$1227258168$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers@lists.l>
List-Id: containers.vger.kernel.org


we don't access struct cgroupfs_root in fast path,
so we should not put struct cgroupfs_root protected by RCU

but the comment in struct cgroup_subsys.root confuse us.

struct cgroup_subsys.root is used in these places:

1 find_css_set(): if (ss->root->subsys_list.next == &ss->sibling)
2 rebind_subsystems(): if (ss->root != &rootnode)
                       rcu_assign_pointer(ss->root, root);
                       rcu_assign_pointer(subsys[i]->root, &rootnode);
3 cgroup_has_css_refs(): if (ss->root != cgrp->root)
4 cgroup_init_subsys(): ss->root = &rootnode;
5 proc_cgroupstats_show(): ss->name, ss->root->subsys_bits,
                           ss->root->number_of_cgroups, !ss->disabled);
6 cgroup_clone(): root = subsys->root;
                  if ((root != subsys->root) ||

all these place we have held cgroup_lock() or we don't dereference to
struct cgroupfs_root. It's means wo don't need RCU when use
struct cgroup_subsys.root, and we should not put struct cgroupfs_root
protected by RCU.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1164963..22901ff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -343,7 +345,6 @@ struct cgroup_subsys {
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
-	/* Protected by RCU */
 	struct cgroupfs_root *root;
 
 	struct list_head sibling;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -717,7 +722,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			cgrp->subsys[i] = dummytop->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
 			list_add(&ss->sibling, &root->subsys_list);
-			rcu_assign_pointer(ss->root, root);
+			ss->root = root;
 			if (ss->bind)
 				ss->bind(ss, cgrp);
 
@@ -729,7 +734,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 				ss->bind(ss, dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
-			rcu_assign_pointer(subsys[i]->root, &rootnode);
+			subsys[i]->root = &rootnode;
 			list_del(&ss->sibling);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
