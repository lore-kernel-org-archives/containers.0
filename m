From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Wed, 12 Jun 2013 14:03:16 -0700
Message-ID: <1371070996-20613-12-git-send-email-tj__24746.9978443862$1371071119$gmane$org@kernel.org>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

A css (cgroup_subsys_state) is how each cgroup is represented to a
controller.  As such, it can be used in hot paths across the various
subsystems different controllers are associated with.

One of the common operations is reference counting, which up until now
has been implemented using a global atomic counter and can have
significant adverse impact on scalability.  For example, css refcnt
can be gotten and put multiple times by blkcg for each IO request.
For highops configurations which try to do as much per-cpu as
possible, the global frequent refcnting can be very expensive.

In general, given the various hugely diverse paths css's end up being
used from, we need to make it cheap and highly scalable.  In its
usage, css refcnting isn't very different from module refcnting.

This patch converts css refcnting to use the recently added
percpu_ref.  css_get/tryget/put() directly maps to the matching
percpu_ref operations and the deactivation logic is no longer
necessary as percpu_ref already has refcnt killing.

The only complication is that as the refcnt is per-cpu,
percpu_ref_kill() in itself doesn't ensure that further tryget
operations will fail, which we need to guarantee before invoking
->css_offline()'s.  This is resolved collecting kill confirmation
using percpu_ref_kill_and_confirm() and initiating the offline phase
of destruction after all css refcnt's are confirmed to be seen as
killed on all CPUs.  The previous patches already splitted destruction
into two phases, so percpu_ref_kill_and_confirm() can be hooked up
easily.

This patch removes css_refcnt() which is used for rcu dereference
sanity check in css_id().  While we can add a percpu refcnt API to ask
the same question, css_id() itself is scheduled to be removed fairly
soon, so let's not bother with it.  Just drop the sanity check and use
rcu_dereference_raw() instead.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Cc: Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |  23 +++------
 kernel/cgroup.c        | 138 +++++++++++++++++++++++++++++--------------------
 2 files changed, 91 insertions(+), 70 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 58ee0f4..4d71cc2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -20,6 +20,7 @@
 #include <linux/workqueue.h>
 #include <linux/xattr.h>
 #include <linux/fs.h>
+#include <linux/percpu-refcount.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -72,13 +73,8 @@ struct cgroup_subsys_state {
 	 */
 	struct cgroup *cgroup;
 
-	/*
-	 * State maintained by the cgroup system to allow subsystems
-	 * to be "busy". Should be accessed via css_get(),
-	 * css_tryget() and css_put().
-	 */
-
-	atomic_t refcnt;
+	/* reference count - access via css_[try]get() and css_put() */
+	struct percpu_ref refcnt;
 
 	unsigned long flags;
 	/* ID for this css, if possible */
@@ -104,11 +100,9 @@ static inline void css_get(struct cgroup_subsys_state *css)
 {
 	/* We don't need to reference count the root state */
 	if (!(css->flags & CSS_ROOT))
-		atomic_inc(&css->refcnt);
+		percpu_ref_get(&css->refcnt);
 }
 
-extern bool __css_tryget(struct cgroup_subsys_state *css);
-
 /**
  * css_tryget - try to obtain a reference on the specified css
  * @css: target css
@@ -123,11 +117,9 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (css->flags & CSS_ROOT)
 		return true;
-	return __css_tryget(css);
+	return percpu_ref_tryget(&css->refcnt);
 }
 
-extern void __css_put(struct cgroup_subsys_state *css);
-
 /**
  * css_put - put a css reference
  * @css: target css
@@ -137,7 +129,7 @@ extern void __css_put(struct cgroup_subsys_state *css);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!(css->flags & CSS_ROOT))
-		__css_put(css);
+		percpu_ref_put(&css->refcnt);
 }
 
 /* bits in struct cgroup flags field */
@@ -231,9 +223,10 @@ struct cgroup {
 	struct list_head pidlists;
 	struct mutex pidlist_mutex;
 
-	/* For RCU-protected deletion */
+	/* For css percpu_ref killing and RCU-protected deletion */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
+	atomic_t css_kill_cnt;
 
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 83e3183..769f800 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -63,9 +63,6 @@
 
 #include <linux/atomic.h>
 
-/* css deactivation bias, makes css->refcnt negative to deny new trygets */
-#define CSS_DEACT_BIAS		INT_MIN
-
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
@@ -213,19 +210,6 @@ static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			      struct cftype cfts[], bool is_add);
 
-static int css_unbias_refcnt(int refcnt)
-{
-	return refcnt >= 0 ? refcnt : refcnt - CSS_DEACT_BIAS;
-}
-
-/* the current nr of refs, always >= 0 whether @css is deactivated or not */
-static int css_refcnt(struct cgroup_subsys_state *css)
-{
-	int v = atomic_read(&css->refcnt);
-
-	return css_unbias_refcnt(v);
-}
-
 /* convenient tests for these bits */
 static inline bool cgroup_is_dead(const struct cgroup *cgrp)
 {
@@ -4139,12 +4123,20 @@ static void css_dput_fn(struct work_struct *work)
 	deactivate_super(sb);
 }
 
+static void css_release(struct percpu_ref *ref)
+{
+	struct cgroup_subsys_state *css =
+		container_of(ref, struct cgroup_subsys_state, refcnt);
+
+	schedule_work(&css->dput_work);
+}
+
 static void init_cgroup_css(struct cgroup_subsys_state *css,
 			       struct cgroup_subsys *ss,
 			       struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 1);
+	percpu_ref_init(&css->refcnt, css_release);
 	css->flags = 0;
 	css->id = NULL;
 	if (cgrp == dummytop)
@@ -4360,6 +4352,48 @@ static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	return cgroup_create(c_parent, dentry, mode | S_IFDIR);
 }
 
+static void cgroup_css_killed(struct cgroup *cgrp)
+{
+	if (!atomic_dec_and_test(&cgrp->css_kill_cnt))
+		return;
+
+	/* percpu ref's of all css's are killed, kick off the next step */
+	INIT_WORK(&cgrp->destroy_work, cgroup_offline_fn);
+	schedule_work(&cgrp->destroy_work);
+}
+
+static void css_ref_killed_fn(struct percpu_ref *ref)
+{
+	struct cgroup_subsys_state *css =
+		container_of(ref, struct cgroup_subsys_state, refcnt);
+
+	cgroup_css_killed(css->cgroup);
+}
+
+/**
+ * cgroup_destroy_locked - the first stage of cgroup destruction
+ * @cgrp: cgroup to be destroyed
+ *
+ * css's make use of percpu refcnts whose killing latency shouldn't be
+ * exposed to userland and are RCU protected.  Also, cgroup core needs to
+ * guarantee that css_tryget() won't succeed by the time ->css_offline() is
+ * invoked.  To satisfy all the requirements, destruction is implemented in
+ * the following two steps.
+ *
+ * s1. Verify @cgrp can be destroyed and mark it dying.  Remove all
+ *     userland visible parts and start killing the percpu refcnts of
+ *     css's.  Set up so that the next stage will be kicked off once all
+ *     the percpu refcnts are confirmed to be killed.
+ *
+ * s2. Invoke ->css_offline(), mark the cgroup dead and proceed with the
+ *     rest of destruction.  Once all cgroup references are gone, the
+ *     cgroup is RCU-freed.
+ *
+ * This function implements s1.  After this step, @cgrp is gone as far as
+ * the userland is concerned and a new cgroup with the same name may be
+ * created.  As cgroup doesn't care about the names internally, this
+ * doesn't cause any problem.
+ */
 static int cgroup_destroy_locked(struct cgroup *cgrp)
 	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
 {
@@ -4382,16 +4416,28 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		return -EBUSY;
 
 	/*
-	 * Block new css_tryget() by deactivating refcnt and mark @cgrp
-	 * removed.  This makes future css_tryget() attempts fail which we
-	 * guarantee to ->css_offline() callbacks.
+	 * Block new css_tryget() by killing css refcnts.  cgroup core
+	 * guarantees that, by the time ->css_offline() is invoked, no new
+	 * css reference will be given out via css_tryget().  We can't
+	 * simply call percpu_ref_kill() and proceed to offlining css's
+	 * because percpu_ref_kill() doesn't guarantee that the ref is seen
+	 * as killed on all CPUs on return.
+	 *
+	 * Use percpu_ref_kill_and_confirm() to get notifications as each
+	 * css is confirmed to be seen as killed on all CPUs.  The
+	 * notification callback keeps track of the number of css's to be
+	 * killed and schedules cgroup_offline_fn() to perform the rest of
+	 * destruction once the percpu refs of all css's are confirmed to
+	 * be killed.
 	 */
+	atomic_set(&cgrp->css_kill_cnt, 1);
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 
-		WARN_ON(atomic_read(&css->refcnt) < 0);
-		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
+		atomic_inc(&cgrp->css_kill_cnt);
+		percpu_ref_kill_and_confirm(&css->refcnt, css_ref_killed_fn);
 	}
+	cgroup_css_killed(cgrp);
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
@@ -4427,12 +4473,19 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	}
 	spin_unlock(&cgrp->event_list_lock);
 
-	INIT_WORK(&cgrp->destroy_work, cgroup_offline_fn);
-	schedule_work(&cgrp->destroy_work);
-
 	return 0;
 };
 
+/**
+ * cgroup_offline_fn - the second step of cgroup destruction
+ * @work: cgroup->destroy_free_work
+ *
+ * This function is invoked from a work item for a cgroup which is being
+ * destroyed after the percpu refcnts of all css's are guaranteed to be
+ * seen as killed on all CPUs, and performs the rest of destruction.  This
+ * is the second step of destruction described in the comment above
+ * cgroup_destroy_locked().
+ */
 static void cgroup_offline_fn(struct work_struct *work)
 {
 	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
@@ -4442,7 +4495,10 @@ static void cgroup_offline_fn(struct work_struct *work)
 
 	mutex_lock(&cgroup_mutex);
 
-	/* tell subsystems to initate destruction */
+	/*
+	 * css_tryget() is guaranteed to fail now.  Tell subsystems to
+	 * initate destruction.
+	 */
 	for_each_subsys(cgrp->root, ss)
 		offline_css(ss, cgrp);
 
@@ -5100,34 +5156,6 @@ static void check_for_release(struct cgroup *cgrp)
 	}
 }
 
-/* Caller must verify that the css is not for root cgroup */
-bool __css_tryget(struct cgroup_subsys_state *css)
-{
-	while (true) {
-		int t, v;
-
-		v = css_refcnt(css);
-		t = atomic_cmpxchg(&css->refcnt, v, v + 1);
-		if (likely(t == v))
-			return true;
-		else if (t < 0)
-			return false;
-		cpu_relax();
-	}
-}
-EXPORT_SYMBOL_GPL(__css_tryget);
-
-/* Caller must verify that the css is not for root cgroup */
-void __css_put(struct cgroup_subsys_state *css)
-{
-	int v;
-
-	v = css_unbias_refcnt(atomic_dec_return(&css->refcnt));
-	if (v == 0)
-		schedule_work(&css->dput_work);
-}
-EXPORT_SYMBOL_GPL(__css_put);
-
 /*
  * Notify userspace when a cgroup is released, by running the
  * configured release agent with the name of the cgroup (path
@@ -5245,7 +5273,7 @@ unsigned short css_id(struct cgroup_subsys_state *css)
 	 * on this or this is under rcu_read_lock(). Once css->id is allocated,
 	 * it's unchanged until freed.
 	 */
-	cssid = rcu_dereference_check(css->id, css_refcnt(css));
+	cssid = rcu_dereference_raw(css->id);
 
 	if (cssid)
 		return cssid->id;
-- 
1.8.2.1
