From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Tue, 30 Oct 2012 21:22:39 -0700
Message-ID: <1351657365-25055-3-git-send-email-tj@kernel.org>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351657365-25055-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

CSS_REMOVED is one of the several contortions which were necessary to
support css reference draining on cgroup removal.  All css->refcnts
which need draining should be deactivated and verified to equal zero
atomically w.r.t. css_tryget().  If any one isn't zero, all refcnts
needed to be re-activated and css_tryget() shouldn't fail in the
process.

This was achieved by letting css_tryget() busy-loop until either the
refcnt is reactivated (failed removal attempt) or CSS_REMOVED is set
(committing to removal).

Now that css refcnt draining is no longer used, there's no need for
atomic rollback mechanism.  css_tryget() simply can look at the
reference count and fail if the it's deactivated - it's never getting
re-activated.

This patch removes CSS_REMOVED and updates __css_tryget() to fail if
the refcnt is deactivated.

Note that this removes css_is_removed() whose only user is VM_BUG_ON()
in memcontrol.c.  We can replace it with a check on the refcnt but
given that the only use case is a debug assert, I think it's better to
simply unexport it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |  6 ------
 kernel/cgroup.c        | 31 ++++++++++++-------------------
 mm/memcontrol.c        |  7 +++----
 3 files changed, 15 insertions(+), 29 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 02e09c0..a309804 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -85,7 +85,6 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
-	CSS_REMOVED, /* This CSS is dead */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -108,11 +107,6 @@ static inline void css_get(struct cgroup_subsys_state *css)
 		__css_get(css, 1);
 }
 
-static inline bool css_is_removed(struct cgroup_subsys_state *css)
-{
-	return test_bit(CSS_REMOVED, &css->flags);
-}
-
 /*
  * Call css_tryget() to take a reference on a css if your existing
  * (known-valid) reference isn't already ref-counted. Returns false if
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 033bf4b..a49cdbc 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -170,8 +170,8 @@ struct css_id {
 	 * The css to which this ID points. This pointer is set to valid value
 	 * after cgroup is populated. If cgroup is removed, this will be NULL.
 	 * This pointer is expected to be RCU-safe because destroy()
-	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
-	 * css_tryget() should be used for avoiding race.
+	 * is called after synchronize_rcu(). But for safe use, css_tryget()
+	 * should be used for avoiding race.
 	 */
 	struct cgroup_subsys_state __rcu *css;
 	/*
@@ -4088,8 +4088,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	}
 	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
 
-	local_irq_disable();
-
 	/* block new css_tryget() by deactivating refcnt */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
@@ -4099,21 +4097,14 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	}
 
 	/*
-	 * Set REMOVED.  All in-progress css_tryget() will be released.
 	 * Put all the base refs.  Each css holds an extra reference to the
 	 * cgroup's dentry and cgroup removal proceeds regardless of css
 	 * refs.  On the last put of each css, whenever that may be, the
 	 * extra dentry ref is put so that dentry destruction happens only
 	 * after all css's are released.
 	 */
-	for_each_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-
-		set_bit(CSS_REMOVED, &css->flags);
-		css_put(css);
-	}
-
-	local_irq_enable();
+	for_each_subsys(cgrp->root, ss)
+		css_put(cgrp->subsys[ss->subsys_id]);
 
 	finish_wait(&cgroup_rmdir_waitq, &wait);
 	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
@@ -4837,15 +4828,17 @@ static void check_for_release(struct cgroup *cgrp)
 /* Caller must verify that the css is not for root cgroup */
 bool __css_tryget(struct cgroup_subsys_state *css)
 {
-	do {
-		int v = css_refcnt(css);
+	while (true) {
+		int t, v;
 
-		if (atomic_cmpxchg(&css->refcnt, v, v + 1) == v)
+		v = css_refcnt(css);
+		t = atomic_cmpxchg(&css->refcnt, v, v + 1);
+		if (likely(t == v))
 			return true;
+		else if (t < 0)
+			return false;
 		cpu_relax();
-	} while (!test_bit(CSS_REMOVED, &css->flags));
-
-	return false;
+	}
 }
 EXPORT_SYMBOL_GPL(__css_tryget);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5a1d584..6f8bd9d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2343,7 +2343,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 again:
 	if (*ptr) { /* css should be a valid one */
 		memcg = *ptr;
-		VM_BUG_ON(css_is_removed(&memcg->css));
 		if (mem_cgroup_is_root(memcg))
 			goto done;
 		if (nr_pages == 1 && consume_stock(memcg))
@@ -2483,9 +2482,9 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
 
 /*
  * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock(). The caller must check css_is_removed() or some if
- * it's concern. (dropping refcnt from swap can be called against removed
- * memcg.)
+ * rcu_read_lock(). The caller is responsible for verifying the returned
+ * memcg is still alive if necessary. (dropping refcnt from swap can be
+ * called against removed memcg.)
  */
 static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 {
-- 
1.7.11.7
