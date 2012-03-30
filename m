From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] cgroup: make css->refcnt clearing on cgroup removal
	optional
Date: Fri, 30 Mar 2012 15:36:06 -0700
Message-ID: <20120330223606.GK28934@google.com>
References: <20120330223423.GJ28934@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120330223423.GJ28934-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

Currently, cgroup removal tries to drain all css references.  If there
are active css references, the removal logic waits and retries
->pre_detroy() until either all refs drop to zero or removal is
cancelled.

This semantics is unusual and adds non-trivial complexity to cgroup
core and IMHO is fundamentally misguided in that it couples internal
implementation details (references to internal data structure) with
externally visible operation (rmdir).  To userland, this is a behavior
peculiarity which is unnecessary and difficult to expect (css refs is
otherwise invisible from userland), and, to policy implementations,
this is an unnecessary restriction (e.g. blkcg wants to hold css refs
for caching purposes but can't as that becomes visible as rmdir hang).

Unfortunately, memcg currently depends on ->pre_destroy() retrials and
cgroup removal vetoing and can't be immmediately switched to the new
behavior.  This patch introduces the new behavior of not waiting for
css refs to drain and maintains the old behavior for subsystems which
have __DEPRECATED_clear_css_refs set.

Once, memcg is updated, we can drop the code paths for the old
behavior as proposed in the following patch.  Note that the following
patch is incorrect in that dput work item is in cgroup and may lose
some of dputs when multiples css's are released back-to-back, and
__css_put() triggers check_for_release() when refcnt reaches 0 instead
of 1; however, it shows what part can be removed.

  http://thread.gmane.org/gmane.linux.kernel.containers/22559/focus=75251

Note that, in not-too-distant future, cgroup core will start emitting
warning messages for subsys which require the old behavior, so please
get moving.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
So, memcg can keep the current behavior for now w/
__DEPRECATED_clear_css_refs set but I'll keep increasing the
pressure. ;P

Thanks.

 include/linux/cgroup.h |   17 +++++++++++
 kernel/cgroup.c        |   71 +++++++++++++++++++++++++++++++++++++++++------
 mm/memcontrol.c        |    1 +
 3 files changed, 80 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index be81faf..565c803 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/prio_heap.h>
 #include <linux/rwsem.h>
 #include <linux/idr.h>
+#include <linux/workqueue.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -76,12 +77,16 @@ struct cgroup_subsys_state {
 	unsigned long flags;
 	/* ID for this css, if possible */
 	struct css_id __rcu *id;
+
+	/* Used to put @cgroup->dentry on the last css_put() */
+	struct work_struct dput_work;
 };
 
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
 	CSS_REMOVED, /* This CSS is dead */
+	CSS_CLEAR_CSS_REFS,		/* @ss->__DEPRECATED_clear_css_refs */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -480,6 +485,18 @@ struct cgroup_subsys {
 	 * (not available in early_init time.)
 	 */
 	bool use_id;
+
+	/*
+	 * If %true, cgroup removal will try to clear css refs by retrying
+	 * ss->pre_destroy() until there's no css ref left.  This behavior
+	 * is strictly for backward compatibility and will be removed as
+	 * soon as the current user (memcg) is updated.
+	 *
+	 * If %false, ss->pre_destroy() can't fail and cgroup removal won't
+	 * wait for css refs to drop to zero before proceeding.
+	 */
+	bool __DEPRECATED_clear_css_refs;
+
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2eade51..2905977 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -854,12 +854,17 @@ static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 	struct cgroup_subsys *ss;
 	int ret = 0;
 
-	for_each_subsys(cgrp->root, ss)
-		if (ss->pre_destroy) {
-			ret = ss->pre_destroy(cgrp);
-			if (ret)
-				break;
+	for_each_subsys(cgrp->root, ss) {
+		if (!ss->pre_destroy)
+			continue;
+
+		ret = ss->pre_destroy(cgrp);
+		if (ret) {
+			/* ->pre_destroy() failure is being deprecated */
+			WARN_ON_ONCE(!ss->__DEPRECATED_clear_css_refs);
+			break;
 		}
+	}
 
 	return ret;
 }
@@ -3859,6 +3864,14 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	return 0;
 }
 
+static void css_dput_fn(struct work_struct *work)
+{
+	struct cgroup_subsys_state *css =
+		container_of(work, struct cgroup_subsys_state, dput_work);
+
+	dput(css->cgroup->dentry);
+}
+
 static void init_cgroup_css(struct cgroup_subsys_state *css,
 			       struct cgroup_subsys *ss,
 			       struct cgroup *cgrp)
@@ -3871,6 +3884,16 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 		set_bit(CSS_ROOT, &css->flags);
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
 	cgrp->subsys[ss->subsys_id] = css;
+
+	/*
+	 * If !clear_css_refs, css holds an extra ref to @cgrp->dentry
+	 * which is put on the last css_put().  dput() requires process
+	 * context, which css_put() may be called without.  @css->dput_work
+	 * will be used to invoke dput() asynchronously from css_put().
+	 */
+	INIT_WORK(&css->dput_work, css_dput_fn);
+	if (ss->__DEPRECATED_clear_css_refs)
+		set_bit(CSS_CLEAR_CSS_REFS, &css->flags);
 }
 
 static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
@@ -3973,6 +3996,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (err < 0)
 		goto err_remove;
 
+	/* If !clear_css_refs, each css holds a ref to the cgroup's dentry */
+	for_each_subsys(root, ss)
+		if (!ss->__DEPRECATED_clear_css_refs)
+			dget(dentry);
+
 	/* The cgroup directory was pre-locked for us */
 	BUG_ON(!mutex_is_locked(&cgrp->dentry->d_inode->i_mutex));
 
@@ -4062,8 +4090,24 @@ static int cgroup_has_css_refs(struct cgroup *cgrp)
  * Atomically mark all (or else none) of the cgroup's CSS objects as
  * CSS_REMOVED. Return true on success, or false if the cgroup has
  * busy subsystems. Call with cgroup_mutex held
+ *
+ * Depending on whether a subsys has __DEPRECATED_clear_css_refs set or
+ * not, cgroup removal behaves differently.
+ *
+ * If clear is set, css refcnt for the subsystem should be zero before
+ * cgroup removal can be committed.  This is implemented by
+ * CGRP_WAIT_ON_RMDIR and retry logic around ->pre_destroy(), which may be
+ * called multiple times until all css refcnts reach zero and is allowed to
+ * veto removal on any invocation.  This behavior is deprecated and will be
+ * removed as soon as the existing user (memcg) is updated.
+ *
+ * If clear is not set, each css holds an extra reference to the cgroup's
+ * dentry and cgroup removal proceeds regardless of css refs.
+ * ->pre_destroy() will be called at least once and is not allowed to fail.
+ * On the last put of each css, whenever that may be, the extra dentry ref
+ * is put so that dentry destruction happens only after all css's are
+ * released.
  */
-
 static int cgroup_clear_css_refs(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
@@ -4074,14 +4118,17 @@ static int cgroup_clear_css_refs(struct cgroup *cgrp)
 
 	/*
 	 * Block new css_tryget() by deactivating refcnt.  If all refcnts
-	 * were 1 at the moment of deactivation, we succeeded.
+	 * for subsystems w/ clear_css_refs set were 1 at the moment of
+	 * deactivation, we succeeded.
 	 */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 
 		WARN_ON(atomic_read(&css->refcnt) < 0);
 		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
-		failed |= css_refcnt(css) != 1;
+
+		if (ss->__DEPRECATED_clear_css_refs)
+			failed |= css_refcnt(css) != 1;
 	}
 
 	/*
@@ -4917,12 +4964,18 @@ void __css_put(struct cgroup_subsys_state *css)
 
 	rcu_read_lock();
 	atomic_dec(&css->refcnt);
-	if (css_refcnt(css) == 1) {
+	switch (css_refcnt(css)) {
+	case 1:
 		if (notify_on_release(cgrp)) {
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
 		}
 		cgroup_wakeup_rmdir_waiter(cgrp);
+		break;
+	case 0:
+		if (!test_bit(CSS_CLEAR_CSS_REFS, &css->flags))
+			schedule_work(&css->dput_work);
+		break;
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bef1142..d28359c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5635,6 +5635,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.base_cftypes = mem_cgroup_files,
 	.early_init = 0,
 	.use_id = 1,
+	.__DEPRECATED_clear_css_refs = true,
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
-- 
1.7.7.3
