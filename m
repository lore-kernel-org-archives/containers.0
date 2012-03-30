From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] cgroup: use negative bias on css->refcnt to block
	css_tryget()
Date: Fri, 30 Mar 2012 15:34:23 -0700
Message-ID: <20120330223423.GJ28934@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

When a cgroup is about to be removed, cgroup_clear_css_refs() is
called to check and ensure that there are no active css references.

This is currently achieved by dropping the refcnt to zero iff it has
only the base ref.  If all css refs could be dropped to zero, ref
clearing is successful and CSS_REMOVED is set on all css.  If not, the
base ref is restored.  While css ref is zero w/o CSS_REMOVED set, any
css_tryget() attempt on it busy loops so that they are atomic
w.r.t. the whole css ref clearing.

This does work but dropping and re-instating the base ref is somewhat
hairy and makes it difficult to add more logic to the put path as
there are two of them - the regular css_put() and the reversible base
ref clearing.

This patch updates css ref clearing such that blocking new
css_tryget() and putting the base ref are separate operations.
CSS_DEACT_BIAS, defined as INT_MIN, is added to css->refcnt and
css_tryget() busy loops while refcnt is negative.  After all css refs
are deactivated, if they were all one, ref clearing succeeded and
CSS_REMOVED is set and the base ref is put using the regular
css_put(); otherwise, CSS_DEACT_BIAS is subtracted from the refcnts
and the original postive values are restored.

css_refcnt() accessor which always returns the unbiased positive
reference counts is added and used to simplify refcnt usages.  While
at it, relocate and reformat comments in cgroup_has_css_refs().

This separates css->refcnt deactivation and putting the base ref,
which enables the next patch to make ref clearing optional.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
These two patches should be applied on top of the cftype patchset[1]
and is available in the following git branch.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git cgroup-css-refs

Thanks.

[1] http://thread.gmane.org/gmane.linux.kernel.cgroups/1322

 include/linux/cgroup.h |   12 ++---
 kernel/cgroup.c        |  119 ++++++++++++++++++++++++++++-------------------
 2 files changed, 75 insertions(+), 56 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 028478c..be81faf 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -115,16 +115,12 @@ static inline bool css_is_removed(struct cgroup_subsys_state *css)
  * the css has been destroyed.
  */
 
+extern bool __css_tryget(struct cgroup_subsys_state *css);
 static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (test_bit(CSS_ROOT, &css->flags))
 		return true;
-	while (!atomic_inc_not_zero(&css->refcnt)) {
-		if (test_bit(CSS_REMOVED, &css->flags))
-			return false;
-		cpu_relax();
-	}
-	return true;
+	return __css_tryget(css);
 }
 
 /*
@@ -132,11 +128,11 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
  * css_get() or css_tryget()
  */
 
-extern void __css_put(struct cgroup_subsys_state *css, int count);
+extern void __css_put(struct cgroup_subsys_state *css);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css, 1);
+		__css_put(css);
 }
 
 /* bits in struct cgroup flags field */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 21bba77..2eade51 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -63,6 +63,9 @@
 
 #include <linux/atomic.h>
 
+/* css deactivation bias, makes css->refcnt negative to deny new trygets */
+#define CSS_DEACT_BIAS		INT_MIN
+
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
@@ -251,6 +254,14 @@ int cgroup_lock_is_held(void)
 
 EXPORT_SYMBOL_GPL(cgroup_lock_is_held);
 
+/* the current nr of refs, always >= 0 whether @css is deactivated or not */
+static int css_refcnt(struct cgroup_subsys_state *css)
+{
+	int v = atomic_read(&css->refcnt);
+
+	return v >= 0 ? v : v - CSS_DEACT_BIAS;
+}
+
 /* convenient tests for these bits */
 inline int cgroup_is_removed(const struct cgroup *cgrp)
 {
@@ -4006,18 +4017,19 @@ static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	return cgroup_create(c_parent, dentry, mode | S_IFDIR);
 }
 
+/*
+ * Check the reference count on each subsystem. Since we already
+ * established that there are no tasks in the cgroup, if the css refcount
+ * is also 1, then there should be no outstanding references, so the
+ * subsystem is safe to destroy. We scan across all subsystems rather than
+ * using the per-hierarchy linked list of mounted subsystems since we can
+ * be called via check_for_release() with no synchronization other than
+ * RCU, and the subsystem linked list isn't RCU-safe.
+ */
 static int cgroup_has_css_refs(struct cgroup *cgrp)
 {
-	/* Check the reference count on each subsystem. Since we
-	 * already established that there are no tasks in the
-	 * cgroup, if the css refcount is also 1, then there should
-	 * be no outstanding references, so the subsystem is safe to
-	 * destroy. We scan across all subsystems rather than using
-	 * the per-hierarchy linked list of mounted subsystems since
-	 * we can be called via check_for_release() with no
-	 * synchronization other than RCU, and the subsystem linked
-	 * list isn't RCU-safe */
 	int i;
+
 	/*
 	 * We won't need to lock the subsys array, because the subsystems
 	 * we're concerned about aren't going anywhere since our cgroup root
@@ -4026,17 +4038,21 @@ static int cgroup_has_css_refs(struct cgroup *cgrp)
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 		struct cgroup_subsys_state *css;
+
 		/* Skip subsystems not present or not in this hierarchy */
 		if (ss == NULL || ss->root != cgrp->root)
 			continue;
+
 		css = cgrp->subsys[ss->subsys_id];
-		/* When called from check_for_release() it's possible
+		/*
+		 * When called from check_for_release() it's possible
 		 * that by this point the cgroup has been removed
 		 * and the css deleted. But a false-positive doesn't
 		 * matter, since it can only happen if the cgroup
 		 * has been deleted and hence no longer needs the
-		 * release agent to be called anyway. */
-		if (css && (atomic_read(&css->refcnt) > 1))
+		 * release agent to be called anyway.
+		 */
+		if (css && css_refcnt(css) > 1)
 			return 1;
 	}
 	return 0;
@@ -4053,44 +4069,37 @@ static int cgroup_clear_css_refs(struct cgroup *cgrp)
 	struct cgroup_subsys *ss;
 	unsigned long flags;
 	bool failed = false;
+
 	local_irq_save(flags);
+
+	/*
+	 * Block new css_tryget() by deactivating refcnt.  If all refcnts
+	 * were 1 at the moment of deactivation, we succeeded.
+	 */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-		int refcnt;
-		while (1) {
-			/* We can only remove a CSS with a refcnt==1 */
-			refcnt = atomic_read(&css->refcnt);
-			if (refcnt > 1) {
-				failed = true;
-				goto done;
-			}
-			BUG_ON(!refcnt);
-			/*
-			 * Drop the refcnt to 0 while we check other
-			 * subsystems. This will cause any racing
-			 * css_tryget() to spin until we set the
-			 * CSS_REMOVED bits or abort
-			 */
-			if (atomic_cmpxchg(&css->refcnt, refcnt, 0) == refcnt)
-				break;
-			cpu_relax();
-		}
+
+		WARN_ON(atomic_read(&css->refcnt) < 0);
+		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
+		failed |= css_refcnt(css) != 1;
 	}
- done:
+
+	/*
+	 * If succeeded, set REMOVED and put all the base refs; otherwise,
+	 * restore refcnts to positive values.  Either way, all in-progress
+	 * css_tryget() will be released.
+	 */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-		if (failed) {
-			/*
-			 * Restore old refcnt if we previously managed
-			 * to clear it from 1 to 0
-			 */
-			if (!atomic_read(&css->refcnt))
-				atomic_set(&css->refcnt, 1);
-		} else {
-			/* Commit the fact that the CSS is removed */
+
+		if (!failed) {
 			set_bit(CSS_REMOVED, &css->flags);
+			css_put(css);
+		} else {
+			atomic_sub(CSS_DEACT_BIAS, &css->refcnt);
 		}
 	}
+
 	local_irq_restore(flags);
 	return !failed;
 }
@@ -4887,13 +4896,28 @@ static void check_for_release(struct cgroup *cgrp)
 }
 
 /* Caller must verify that the css is not for root cgroup */
-void __css_put(struct cgroup_subsys_state *css, int count)
+bool __css_tryget(struct cgroup_subsys_state *css)
+{
+	do {
+		int v = css_refcnt(css);
+
+		if (atomic_cmpxchg(&css->refcnt, v, v + 1) == v)
+			return true;
+		cpu_relax();
+	} while (!test_bit(CSS_REMOVED, &css->flags));
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(__css_tryget);
+
+/* Caller must verify that the css is not for root cgroup */
+void __css_put(struct cgroup_subsys_state *css)
 {
 	struct cgroup *cgrp = css->cgroup;
-	int val;
+
 	rcu_read_lock();
-	val = atomic_sub_return(count, &css->refcnt);
-	if (val == 1) {
+	atomic_dec(&css->refcnt);
+	if (css_refcnt(css) == 1) {
 		if (notify_on_release(cgrp)) {
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
@@ -4901,7 +4925,6 @@ void __css_put(struct cgroup_subsys_state *css, int count)
 		cgroup_wakeup_rmdir_waiter(cgrp);
 	}
 	rcu_read_unlock();
-	WARN_ON_ONCE(val < 1);
 }
 EXPORT_SYMBOL_GPL(__css_put);
 
@@ -5020,7 +5043,7 @@ unsigned short css_id(struct cgroup_subsys_state *css)
 	 * on this or this is under rcu_read_lock(). Once css->id is allocated,
 	 * it's unchanged until freed.
 	 */
-	cssid = rcu_dereference_check(css->id, atomic_read(&css->refcnt));
+	cssid = rcu_dereference_check(css->id, css_refcnt(css));
 
 	if (cssid)
 		return cssid->id;
@@ -5032,7 +5055,7 @@ unsigned short css_depth(struct cgroup_subsys_state *css)
 {
 	struct css_id *cssid;
 
-	cssid = rcu_dereference_check(css->id, atomic_read(&css->refcnt));
+	cssid = rcu_dereference_check(css->id, css_refcnt(css));
 
 	if (cssid)
 		return cssid->depth;
-- 
1.7.7.3
