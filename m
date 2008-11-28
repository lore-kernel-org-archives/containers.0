From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/3 -v2] cgroups: add inactive subsystems to
	rootnode.subsys_list
Date: Fri, 28 Nov 2008 18:10:21 +0800
Message-ID: <492FC38D.4050307__37408.230538904$1227867206$gmane$org@cn.fujitsu.com>
References: <492FC1BD.4010705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492FC1BD.4010705-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

Though for an inactive hierarchy, we have subsys->root == &rootnode,
but rootnode's subsys_list is always empty.

This conflicts with the code in find_css_set():

	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
		...
		if (ss->root->subsys_list.next == &ss->sibling) {
			...
		}
	}
	if (list_empty(&rootnode.subsys_list)) {
		...
	}

The above code assumes rootnode.subsys_list links all inactive
hierarchies.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

fix typo in title and changelog: s/root_list/subsys_list

---
 kernel/cgroup.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 33ba756..4e50e97 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -716,7 +716,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
 			cgrp->subsys[i] = dummytop->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
-			list_add(&ss->sibling, &root->subsys_list);
+			list_move(&ss->sibling, &root->subsys_list);
 			rcu_assign_pointer(ss->root, root);
 			if (ss->bind)
 				ss->bind(ss, cgrp);
@@ -730,7 +730,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
 			rcu_assign_pointer(subsys[i]->root, &rootnode);
-			list_del(&ss->sibling);
+			list_move(&ss->sibling, &rootnode.subsys_list);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
 			BUG_ON(!cgrp->subsys[i]);
@@ -2522,6 +2522,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
 	/* Create the top cgroup state for this subsystem */
+	list_add(&ss->sibling, &rootnode.root_list);
 	ss->root = &rootnode;
 	css = ss->create(ss, dummytop);
 	/* We don't handle early failures gracefully */
-- 
1.5.4.rc3
	
