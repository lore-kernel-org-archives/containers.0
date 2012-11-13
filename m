From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/17] cgroup: cgroup->dentry isn't a RCU pointer
Date: Mon, 12 Nov 2012 19:01:32 -0800
Message-ID: <1352775704-9023-6-git-send-email-tj@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup->dentry is marked and used as a RCU pointer; however, it isn't
one - the final dentry put doesn't go through call_rcu().  cgroup and
dentry share the same RCU freeing rule via synchronize_rcu() in
cgroup_diput() (kfree_rcu() used on cgrp is unnecessary).  If cgrp is
accessible under RCU read lock, so is its dentry and dereferencing
cgrp->dentry doesn't need any further RCU protection or annotation.

While not being accurate, before the previous patch, the RCU accessors
served a purpose as memory barriers - cgroup->dentry used to be
assigned after the cgroup was made visible to cgroup_path(), so the
assignment and dereferencing in cgroup_path() needed the memory
barrier pair.  Now that list_add_tail_rcu() happens after
cgroup->dentry is assigned, this no longer is necessary.

Remove the now unnecessary and misleading RCU annotations from
cgroup->dentry.  To make up for the removal of rcu_dereference_check()
in cgroup_path(), add an explicit rcu_lockdep_assert(), which asserts
the dereference rule of @cgrp, not cgrp->dentry.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f64b45..d605857 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -165,7 +165,7 @@ struct cgroup {
 	struct list_head files;		/* my files */
 
 	struct cgroup *parent;		/* my parent */
-	struct dentry __rcu *dentry;	/* cgroup fs entry, RCU protected */
+	struct dentry *dentry;		/* cgroup fs entry, RCU protected */
 
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 40707cd..278752e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1756,9 +1756,11 @@ static struct kobject *cgroup_kobj;
  */
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 {
+	struct dentry *dentry = cgrp->dentry;
 	char *start;
-	struct dentry *dentry = rcu_dereference_check(cgrp->dentry,
-						      cgroup_lock_is_held());
+
+	rcu_lockdep_assert(rcu_read_lock_held() || cgroup_lock_is_held(),
+			   "cgroup_path() called without proper locking");
 
 	if (cgrp == dummytop) {
 		/*
@@ -1782,8 +1784,7 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 		if (!cgrp)
 			break;
 
-		dentry = rcu_dereference_check(cgrp->dentry,
-					       cgroup_lock_is_held());
+		dentry = cgrp->dentry;
 		if (!cgrp->parent)
 			continue;
 		if (--start < buf)
@@ -4124,7 +4125,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	/* allocation complete, commit to creation */
 	dentry->d_fsdata = cgrp;
-	rcu_assign_pointer(cgrp->dentry, dentry);
+	cgrp->dentry = dentry;
 	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
-- 
1.7.11.7
