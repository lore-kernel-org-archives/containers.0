From: Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 3/3] cgroup: always use RCU accessors for
	protected accesses
Date: Fri, 21 Jun 2013 15:52:33 -0700
Message-ID: <20130621225233.GE3949__44500.0344458551$1371855169$gmane$org@htj.dyndns.org>
References: <20130621225116.GC3949@htj.dyndns.org>
	<20130621225204.GD3949@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130621225204.GD3949-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

kernel/cgroup.c still has places where a RCU pointer is set and
accessed directly without going through RCU_INIT_POINTER() or
rcu_dereference_protected().  They're all properly protected accesses
so nothing is broken but it leads to spurious sparse RCU address space
warnings.

Substitute direct accesses with RCU_INIT_POINTER() and
rcu_dereference_protected().  Note that %true is specified as the
extra condition for all derference updates.  This isn't ideal as all
it does is suppressing warning without actually policing
synchronization rules; however, most are scheduled to be removed
pretty soon along with css_id itself, so no reason to be more
elaborate.

Combined with the previous changes, this removes all RCU related
sparse warnings from cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1416,7 +1416,7 @@ static void init_cgroup_root(struct cgro
 	INIT_LIST_HEAD(&root->root_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
-	cgrp->name = &root_cgroup_name;
+	RCU_INIT_POINTER(cgrp->name, &root_cgroup_name);
 	init_cgroup_housekeeping(cgrp);
 }
 
@@ -2535,7 +2535,7 @@ static int cgroup_rename(struct inode *o
 		return ret;
 	}
 
-	old_name = cgrp->name;
+	old_name = rcu_dereference_protected(cgrp->name, true);
 	rcu_assign_pointer(cgrp->name, name);
 
 	kfree_rcu(old_name, rcu_head);
@@ -4154,13 +4154,15 @@ static int cgroup_populate_dir(struct cg
 	/* This cgroup is ready now */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct css_id *id = rcu_dereference_protected(css->id, true);
+
 		/*
 		 * Update id->css pointer and make this css visible from
 		 * CSS ID functions. This pointer will be dereferened
 		 * from RCU-read-side without locks.
 		 */
-		if (css->id)
-			rcu_assign_pointer(css->id->css, css);
+		if (id)
+			rcu_assign_pointer(id->css, css);
 	}
 
 	return 0;
@@ -4837,7 +4839,7 @@ int __init cgroup_init_early(void)
 	css_set_count = 1;
 	init_cgroup_root(&rootnode);
 	root_count = 1;
-	init_task.cgroups = &init_css_set;
+	RCU_INIT_POINTER(init_task.cgroups, &init_css_set);
 
 	init_cgrp_cset_link.cset = &init_css_set;
 	init_cgrp_cset_link.cgrp = dummytop;
@@ -5371,7 +5373,8 @@ bool css_is_ancestor(struct cgroup_subsy
 
 void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
 {
-	struct css_id *id = css->id;
+	struct css_id *id = rcu_dereference_protected(css->id, true);
+
 	/* When this is called before css_id initialization, id can be NULL */
 	if (!id)
 		return;
@@ -5437,8 +5440,8 @@ static int __init_or_module cgroup_init_
 		return PTR_ERR(newid);
 
 	newid->stack[0] = newid->id;
-	newid->css = rootcss;
-	rootcss->id = newid;
+	RCU_INIT_POINTER(newid->css, rootcss);
+	RCU_INIT_POINTER(rootcss->id, newid);
 	return 0;
 }
 
@@ -5452,7 +5455,7 @@ static int alloc_css_id(struct cgroup_su
 	subsys_id = ss->subsys_id;
 	parent_css = parent->subsys[subsys_id];
 	child_css = child->subsys[subsys_id];
-	parent_id = parent_css->id;
+	parent_id = rcu_dereference_protected(parent_css->id, true);
 	depth = parent_id->depth + 1;
 
 	child_id = get_new_cssid(ss, depth);
