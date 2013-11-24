From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/9] cgroup: refactor cgroup_pidlist_find()
Date: Sun, 24 Nov 2013 17:11:32 -0500
Message-ID: <1385331096-7918-6-git-send-email-tj__22286.6303207867$1385331150$gmane$org@kernel.org>
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

Rename cgroup_pidlist_find() to cgroup_pidlist_find_create() and
separate out finding proper to cgroup_pidlist_find().  Also, move
locking to the caller.

This patch is preparation for pidlist restructure and doesn't
introduce any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 65 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 38 insertions(+), 27 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0e902f4..33b6c4d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3573,48 +3573,50 @@ static int cmppid(const void *a, const void *b)
 	return *(pid_t *)a - *(pid_t *)b;
 }
 
+static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
+						  enum cgroup_filetype type)
+{
+	struct cgroup_pidlist *l;
+	/* don't need task_nsproxy() if we're looking at ourself */
+	struct pid_namespace *ns = task_active_pid_ns(current);
+
+	lockdep_assert_held(&cgrp->pidlist_mutex);
+
+	list_for_each_entry(l, &cgrp->pidlists, links)
+		if (l->key.type == type && l->key.ns == ns)
+			return l;
+	return NULL;
+}
+
 /*
  * find the appropriate pidlist for our purpose (given procs vs tasks)
  * returns with the lock on that pidlist already held, and takes care
  * of the use count, or returns NULL with no locks held if we're out of
  * memory.
  */
-static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
-						  enum cgroup_filetype type)
+static struct cgroup_pidlist *cgroup_pidlist_find_create(struct cgroup *cgrp,
+						enum cgroup_filetype type)
 {
 	struct cgroup_pidlist *l;
-	/* don't need task_nsproxy() if we're looking at ourself */
-	struct pid_namespace *ns = task_active_pid_ns(current);
 
-	/*
-	 * We can't drop the pidlist_mutex before taking the l->rwsem in case
-	 * the last ref-holder is trying to remove l from the list at the same
-	 * time. Holding the pidlist_mutex precludes somebody taking whichever
-	 * list we find out from under us - compare release_pid_array().
-	 */
-	mutex_lock(&cgrp->pidlist_mutex);
-	list_for_each_entry(l, &cgrp->pidlists, links) {
-		if (l->key.type == type && l->key.ns == ns) {
-			/* make sure l doesn't vanish out from under us */
-			down_write(&l->rwsem);
-			mutex_unlock(&cgrp->pidlist_mutex);
-			return l;
-		}
-	}
+	lockdep_assert_held(&cgrp->pidlist_mutex);
+
+	l = cgroup_pidlist_find(cgrp, type);
+	if (l)
+		return l;
+
 	/* entry not found; create a new one */
 	l = kzalloc(sizeof(struct cgroup_pidlist), GFP_KERNEL);
-	if (!l) {
-		mutex_unlock(&cgrp->pidlist_mutex);
+	if (!l)
 		return l;
-	}
+
 	init_rwsem(&l->rwsem);
 	INIT_DELAYED_WORK(&l->destroy_dwork, cgroup_pidlist_destroy_work_fn);
-	down_write(&l->rwsem);
 	l->key.type = type;
-	l->key.ns = get_pid_ns(ns);
+	/* don't need task_nsproxy() if we're looking at ourself */
+	l->key.ns = get_pid_ns(task_active_pid_ns(current));
 	l->owner = cgrp;
 	list_add(&l->links, &cgrp->pidlists);
-	mutex_unlock(&cgrp->pidlist_mutex);
 	return l;
 }
 
@@ -3660,17 +3662,26 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	sort(array, length, sizeof(pid_t), cmppid, NULL);
 	if (type == CGROUP_FILE_PROCS)
 		length = pidlist_uniq(array, length);
-	l = cgroup_pidlist_find(cgrp, type);
+
+	mutex_lock(&cgrp->pidlist_mutex);
+
+	l = cgroup_pidlist_find_create(cgrp, type);
 	if (!l) {
+		mutex_unlock(&cgrp->pidlist_mutex);
 		pidlist_free(array);
 		return -ENOMEM;
 	}
-	/* store array, freeing old if necessary - lock already held */
+
+	/* store array, freeing old if necessary */
+	down_write(&l->rwsem);
 	pidlist_free(l->list);
 	l->list = array;
 	l->length = length;
 	l->use_count++;
 	up_write(&l->rwsem);
+
+	mutex_unlock(&cgrp->pidlist_mutex);
+
 	*lp = l;
 	return 0;
 }
-- 
1.8.4.2
