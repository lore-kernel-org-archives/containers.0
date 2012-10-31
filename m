From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/8] cgroup: kill cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Wed, 31 Oct 2012 12:44:03 -0700
Message-ID: <1351712650-23709-2-git-send-email-tj@kernel.org>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351712650-23709-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

2ef37d3fe4 ("memcg: Simplify mem_cgroup_force_empty_list error
handling") removed the last user of __DEPRECATED_clear_css_refs.  This
patch removes __DEPRECATED_clear_css_refs and mechanisms to support
it.

* Conditionals dependent on __DEPRECATED_clear_css_refs removed.

* cgroup_clear_css_refs() can no longer fail.  All that needs to be
  done are deactivating refcnts, setting CSS_REMOVED and putting the
  base reference on each css.  Remove cgroup_clear_css_refs() and the
  failure path, and open-code the loops into cgroup_rmdir().

This patch keeps the two for_each_subsys() loops separate while open
coding them.  They can be merged now but there are scheduled changes
which need them to be separate, so keep them separate to reduce the
amount of churn.

local_irq_save/restore() from cgroup_clear_css_refs() are replaced
with local_irq_disable/enable() for simplicity.  This is safe as
cgroup_rmdir() is always called with IRQ enabled.  Note that this IRQ
switching is necessary to make CSS deactivation and CSS_REMOVED
assertion atomic against css_tryget() and will be removed by future
changes.

v2: cgroup_call_pre_destroy() removal dropped per Michal.  Commit
    message updated to explain local_irq_disable/enable() conversion.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
---
 include/linux/cgroup.h |  12 -----
 kernel/cgroup.c        | 131 ++++++++++++++-----------------------------------
 2 files changed, 36 insertions(+), 107 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c90eaa8..02e09c0 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -86,7 +86,6 @@ struct cgroup_subsys_state {
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
 	CSS_REMOVED, /* This CSS is dead */
-	CSS_CLEAR_CSS_REFS,		/* @ss->__DEPRECATED_clear_css_refs */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -485,17 +484,6 @@ struct cgroup_subsys {
 	 */
 	bool use_id;
 
-	/*
-	 * If %true, cgroup removal will try to clear css refs by retrying
-	 * ss->pre_destroy() until there's no css ref left.  This behavior
-	 * is strictly for backward compatibility and will be removed as
-	 * soon as the current user (memcg) is updated.
-	 *
-	 * If %false, ss->pre_destroy() can't fail and cgroup removal won't
-	 * wait for css refs to drop to zero before proceeding.
-	 */
-	bool __DEPRECATED_clear_css_refs;
-
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7981850..8c605e2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -865,11 +865,8 @@ static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 			continue;
 
 		ret = ss->pre_destroy(cgrp);
-		if (ret) {
-			/* ->pre_destroy() failure is being deprecated */
-			WARN_ON_ONCE(!ss->__DEPRECATED_clear_css_refs);
+		if (WARN_ON_ONCE(ret))
 			break;
-		}
 	}
 
 	return ret;
@@ -3901,14 +3898,12 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	cgrp->subsys[ss->subsys_id] = css;
 
 	/*
-	 * If !clear_css_refs, css holds an extra ref to @cgrp->dentry
-	 * which is put on the last css_put().  dput() requires process
-	 * context, which css_put() may be called without.  @css->dput_work
-	 * will be used to invoke dput() asynchronously from css_put().
+	 * css holds an extra ref to @cgrp->dentry which is put on the last
+	 * css_put().  dput() requires process context, which css_put() may
+	 * be called without.  @css->dput_work will be used to invoke
+	 * dput() asynchronously from css_put().
 	 */
 	INIT_WORK(&css->dput_work, css_dput_fn);
-	if (ss->__DEPRECATED_clear_css_refs)
-		set_bit(CSS_CLEAR_CSS_REFS, &css->flags);
 }
 
 /*
@@ -3978,10 +3973,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (err < 0)
 		goto err_remove;
 
-	/* If !clear_css_refs, each css holds a ref to the cgroup's dentry */
+	/* each css holds a ref to the cgroup's dentry */
 	for_each_subsys(root, ss)
-		if (!ss->__DEPRECATED_clear_css_refs)
-			dget(dentry);
+		dget(dentry);
 
 	/* The cgroup directory was pre-locked for us */
 	BUG_ON(!mutex_is_locked(&cgrp->dentry->d_inode->i_mutex));
@@ -4066,71 +4060,6 @@ static int cgroup_has_css_refs(struct cgroup *cgrp)
 	return 0;
 }
 
-/*
- * Atomically mark all (or else none) of the cgroup's CSS objects as
- * CSS_REMOVED. Return true on success, or false if the cgroup has
- * busy subsystems. Call with cgroup_mutex held
- *
- * Depending on whether a subsys has __DEPRECATED_clear_css_refs set or
- * not, cgroup removal behaves differently.
- *
- * If clear is set, css refcnt for the subsystem should be zero before
- * cgroup removal can be committed.  This is implemented by
- * CGRP_WAIT_ON_RMDIR and retry logic around ->pre_destroy(), which may be
- * called multiple times until all css refcnts reach zero and is allowed to
- * veto removal on any invocation.  This behavior is deprecated and will be
- * removed as soon as the existing user (memcg) is updated.
- *
- * If clear is not set, each css holds an extra reference to the cgroup's
- * dentry and cgroup removal proceeds regardless of css refs.
- * ->pre_destroy() will be called at least once and is not allowed to fail.
- * On the last put of each css, whenever that may be, the extra dentry ref
- * is put so that dentry destruction happens only after all css's are
- * released.
- */
-static int cgroup_clear_css_refs(struct cgroup *cgrp)
-{
-	struct cgroup_subsys *ss;
-	unsigned long flags;
-	bool failed = false;
-
-	local_irq_save(flags);
-
-	/*
-	 * Block new css_tryget() by deactivating refcnt.  If all refcnts
-	 * for subsystems w/ clear_css_refs set were 1 at the moment of
-	 * deactivation, we succeeded.
-	 */
-	for_each_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-
-		WARN_ON(atomic_read(&css->refcnt) < 0);
-		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
-
-		if (ss->__DEPRECATED_clear_css_refs)
-			failed |= css_refcnt(css) != 1;
-	}
-
-	/*
-	 * If succeeded, set REMOVED and put all the base refs; otherwise,
-	 * restore refcnts to positive values.  Either way, all in-progress
-	 * css_tryget() will be released.
-	 */
-	for_each_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-
-		if (!failed) {
-			set_bit(CSS_REMOVED, &css->flags);
-			css_put(css);
-		} else {
-			atomic_sub(CSS_DEACT_BIAS, &css->refcnt);
-		}
-	}
-
-	local_irq_restore(flags);
-	return !failed;
-}
-
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	struct cgroup *cgrp = dentry->d_fsdata;
@@ -4138,10 +4067,10 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	struct cgroup *parent;
 	DEFINE_WAIT(wait);
 	struct cgroup_event *event, *tmp;
+	struct cgroup_subsys *ss;
 	int ret;
 
 	/* the vfs holds both inode->i_mutex already */
-again:
 	mutex_lock(&cgroup_mutex);
 	if (atomic_read(&cgrp->count) != 0) {
 		mutex_unlock(&cgroup_mutex);
@@ -4182,21 +4111,34 @@ again:
 		return -EBUSY;
 	}
 	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
-	if (!cgroup_clear_css_refs(cgrp)) {
-		mutex_unlock(&cgroup_mutex);
-		/*
-		 * Because someone may call cgroup_wakeup_rmdir_waiter() before
-		 * prepare_to_wait(), we need to check this flag.
-		 */
-		if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
-			schedule();
-		finish_wait(&cgroup_rmdir_waitq, &wait);
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-		if (signal_pending(current))
-			return -EINTR;
-		goto again;
+
+	local_irq_disable();
+
+	/* block new css_tryget() by deactivating refcnt */
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		WARN_ON(atomic_read(&css->refcnt) < 0);
+		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
+	}
+
+	/*
+	 * Set REMOVED.  All in-progress css_tryget() will be released.
+	 * Put all the base refs.  Each css holds an extra reference to the
+	 * cgroup's dentry and cgroup removal proceeds regardless of css
+	 * refs.  On the last put of each css, whenever that may be, the
+	 * extra dentry ref is put so that dentry destruction happens only
+	 * after all css's are released.
+	 */
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		set_bit(CSS_REMOVED, &css->flags);
+		css_put(css);
 	}
-	/* NO css_tryget() can success after here. */
+
+	local_irq_enable();
+
 	finish_wait(&cgroup_rmdir_waitq, &wait);
 	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
@@ -4949,8 +4891,7 @@ void __css_put(struct cgroup_subsys_state *css)
 		cgroup_wakeup_rmdir_waiter(cgrp);
 		break;
 	case 0:
-		if (!test_bit(CSS_CLEAR_CSS_REFS, &css->flags))
-			schedule_work(&css->dput_work);
+		schedule_work(&css->dput_work);
 		break;
 	}
 	rcu_read_unlock();
-- 
1.7.11.7
