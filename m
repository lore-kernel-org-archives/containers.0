From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/9] cgroup: implement delayed destruction for cgroup_pidlist
Date: Sun, 24 Nov 2013 17:11:30 -0500
Message-ID: <1385331096-7918-4-git-send-email-tj__47847.774581942$1385331137$gmane$org@kernel.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, pidlists are reference counted from file open and release
methods.  This means that holding onto an open file may waste memory
and reads may return data which is very stale.  Both aren't critical
because pidlists are keyed and shared per namespace and, well, the
user isn't supposed to have large delay between open and reads.

cgroup is planned to be converted to use kernfs and it'd be best if we
can stick to just the seq_file operations - start, next, stop and
show.  This can be achieved by loading pidlist on demand from start
and release with time delay from stop, so that consecutive reads don't
end up reloading the pidlist on each iteration.  This would remove the
need for hooking into open and release while also avoiding issues with
holding onto pidlist for too long.

This patch implements delayed release of pidlist.  As pidlists could
be lingering on cgroup removal waiting for the timer to expire, cgroup
free path needs to queue the destruction work item immediately and
flush.  As those work items are self-destroying, each work item can't
be flushed directly.  A new workqueue - cgroup_pidlist_destroy_wq - is
added to serve as flush domain.

Note that this patch just adds delayed release on top of the current
implementation and doesn't change where pidlist is loaded and
released.  Following patches will make those changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 99 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 76 insertions(+), 23 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2fd888f..2e21490 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -62,6 +62,14 @@
 #include <linux/atomic.h>
 
 /*
+ * pidlists linger the following amount before being destroyed.  The goal
+ * is avoiding frequent destruction in the middle of consecutive read calls
+ * Expiring in the middle is a performance problem not a correctness one.
+ * 1 sec should be enough.
+ */
+#define CGROUP_PIDLIST_DESTROY_DELAY	HZ
+
+/*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
  *
@@ -95,6 +103,12 @@ static DEFINE_MUTEX(cgroup_root_mutex);
 static struct workqueue_struct *cgroup_destroy_wq;
 
 /*
+ * pidlist destructions need to be flushed on cgroup destruction.  Use a
+ * separate workqueue as flush domain.
+ */
+static struct workqueue_struct *cgroup_pidlist_destroy_wq;
+
+/*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
  * populated with the built in subsystems, and modular subsystems are
  * registered after that. The mutable section of this array is protected by
@@ -166,6 +180,7 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
+static void cgroup_pidlist_destroy_all(struct cgroup *cgrp);
 
 /**
  * cgroup_css - obtain a cgroup's css for the specified subsystem
@@ -829,11 +844,7 @@ static void cgroup_free_fn(struct work_struct *work)
 	 */
 	deactivate_super(cgrp->root->sb);
 
-	/*
-	 * if we're getting rid of the cgroup, refcount should ensure
-	 * that there are no pidlists left.
-	 */
-	BUG_ON(!list_empty(&cgrp->pidlists));
+	cgroup_pidlist_destroy_all(cgrp);
 
 	simple_xattrs_free(&cgrp->xattrs);
 
@@ -3451,6 +3462,8 @@ struct cgroup_pidlist {
 	struct cgroup *owner;
 	/* protects the other fields */
 	struct rw_semaphore rwsem;
+	/* for delayed destruction */
+	struct delayed_work destroy_dwork;
 };
 
 /*
@@ -3466,6 +3479,7 @@ static void *pidlist_allocate(int count)
 	else
 		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
 }
+
 static void pidlist_free(void *p)
 {
 	if (is_vmalloc_addr(p))
@@ -3475,6 +3489,49 @@ static void pidlist_free(void *p)
 }
 
 /*
+ * Used to destroy all pidlists lingering waiting for destroy timer.  None
+ * should be left afterwards.
+ */
+static void cgroup_pidlist_destroy_all(struct cgroup *cgrp)
+{
+	struct cgroup_pidlist *l, *tmp_l;
+
+	mutex_lock(&cgrp->pidlist_mutex);
+	list_for_each_entry_safe(l, tmp_l, &cgrp->pidlists, links)
+		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork, 0);
+	mutex_unlock(&cgrp->pidlist_mutex);
+
+	flush_workqueue(cgroup_pidlist_destroy_wq);
+	BUG_ON(!list_empty(&cgrp->pidlists));
+}
+
+static void cgroup_pidlist_destroy_work_fn(struct work_struct *work)
+{
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct cgroup_pidlist *l = container_of(dwork, struct cgroup_pidlist,
+						destroy_dwork);
+	struct cgroup_pidlist *tofree = NULL;
+
+	mutex_lock(&l->owner->pidlist_mutex);
+	down_write(&l->rwsem);
+
+	/*
+	 * Destroy iff we didn't race with a new user or get queued again.
+	 * Queued state won't change as it can only be queued while locked.
+	 */
+	if (!l->use_count && !delayed_work_pending(dwork)) {
+		list_del(&l->links);
+		pidlist_free(l->list);
+		put_pid_ns(l->key.ns);
+		tofree = l;
+	}
+
+	up_write(&l->rwsem);
+	mutex_unlock(&l->owner->pidlist_mutex);
+	kfree(tofree);
+}
+
+/*
  * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
  * Returns the number of unique elements.
  */
@@ -3544,6 +3601,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 		return l;
 	}
 	init_rwsem(&l->rwsem);
+	INIT_DELAYED_WORK(&l->destroy_dwork, cgroup_pidlist_destroy_work_fn);
 	down_write(&l->rwsem);
 	l->key.type = type;
 	l->key.ns = get_pid_ns(ns);
@@ -3749,26 +3807,12 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
 
 static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 {
-	/*
-	 * the case where we're the last user of this particular pidlist will
-	 * have us remove it from the cgroup's list, which entails taking the
-	 * mutex. since in pidlist_find the pidlist->lock depends on cgroup->
-	 * pidlist_mutex, we have to take pidlist_mutex first.
-	 */
-	mutex_lock(&l->owner->pidlist_mutex);
 	down_write(&l->rwsem);
 	BUG_ON(!l->use_count);
-	if (!--l->use_count) {
-		/* we're the last user if refcount is 0; remove and free */
-		list_del(&l->links);
-		mutex_unlock(&l->owner->pidlist_mutex);
-		pidlist_free(l->list);
-		put_pid_ns(l->key.ns);
-		up_write(&l->rwsem);
-		kfree(l);
-		return;
-	}
-	mutex_unlock(&l->owner->pidlist_mutex);
+	/* if the last user, arm the destroy work */
+	if (!--l->use_count)
+		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork,
+				 CGROUP_PIDLIST_DESTROY_DELAY);
 	up_write(&l->rwsem);
 }
 
@@ -4810,6 +4854,15 @@ static int __init cgroup_wq_init(void)
 	 */
 	cgroup_destroy_wq = alloc_workqueue("cgroup_destroy", 0, 1);
 	BUG_ON(!cgroup_destroy_wq);
+
+	/*
+	 * Used to destroy pidlists and separate to serve as flush domain.
+	 * Cap @max_active to 1 too.
+	 */
+	cgroup_pidlist_destroy_wq = alloc_workqueue("cgroup_pidlist_destroy",
+						    0, 1);
+	BUG_ON(!cgroup_pidlist_destroy_wq);
+
 	return 0;
 }
 core_initcall(cgroup_wq_init);
-- 
1.8.4.2
