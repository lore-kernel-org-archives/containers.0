From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/9] cgroup: remove cgroup_pidlist->use_count
Date: Sun, 24 Nov 2013 17:11:35 -0500
Message-ID: <1385331096-7918-9-git-send-email-tj__29503.881201572$1385331168$gmane$org@kernel.org>
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

After the recent changes, pidlist ref is held only between
cgroup_pidlist_start() and cgroup_pidlist_stop() during which
cgroup->pidlist_mutex is also held.  IOW, the reference count is
redundant now.  While in use, it's always one and pidlist_mutex is
held - holding the mutex has exactly the same protection.

This patch collapses destroy_dwork queueing into cgroup_pidlist_stop()
so that pidlist_mutex is not released inbetween and drops
pidlist->use_count.

This patch shouldn't introduce any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 28 +++++++---------------------
 1 file changed, 7 insertions(+), 21 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8d2d9d4..5c8cf0b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3454,8 +3454,6 @@ struct cgroup_pidlist {
 	pid_t *list;
 	/* how many elements the above list has */
 	int length;
-	/* how many files are using the current array */
-	int use_count;
 	/* each of these stored in a list by its cgroup */
 	struct list_head links;
 	/* pointer to the cgroup we belong to, for list removal purposes */
@@ -3471,8 +3469,6 @@ struct cgroup_pidlist_open_file {
 	struct cgroup_pidlist		*pidlist;
 };
 
-static void cgroup_release_pid_array(struct cgroup_pidlist *l);
-
 /*
  * The following two functions "fix" the issue where there are more pids
  * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
@@ -3522,10 +3518,10 @@ static void cgroup_pidlist_destroy_work_fn(struct work_struct *work)
 	mutex_lock(&l->owner->pidlist_mutex);
 
 	/*
-	 * Destroy iff we didn't race with a new user or get queued again.
-	 * Queued state won't change as it can only be queued while locked.
+	 * Destroy iff we didn't get queued again.  The state won't change
+	 * as destroy_dwork can only be queued while locked.
 	 */
-	if (!l->use_count && !delayed_work_pending(dwork)) {
+	if (!delayed_work_pending(dwork)) {
 		list_del(&l->links);
 		pidlist_free(l->list);
 		put_pid_ns(l->key.ns);
@@ -3773,7 +3769,6 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 			return ERR_PTR(ret);
 	}
 	l = of->pidlist;
-	l->use_count++;
 
 	if (pid) {
 		int end = l->length;
@@ -3802,9 +3797,11 @@ static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
 	struct cgroup_pidlist_open_file *of = s->private;
 
-	mutex_unlock(&of->cgrp->pidlist_mutex);
 	if (of->pidlist)
-		cgroup_release_pid_array(of->pidlist);
+		mod_delayed_work(cgroup_pidlist_destroy_wq,
+				 &of->pidlist->destroy_dwork,
+				 CGROUP_PIDLIST_DESTROY_DELAY);
+	mutex_unlock(&of->cgrp->pidlist_mutex);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
@@ -3842,17 +3839,6 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
 	.show = cgroup_pidlist_show,
 };
 
-static void cgroup_release_pid_array(struct cgroup_pidlist *l)
-{
-	mutex_lock(&l->owner->pidlist_mutex);
-	BUG_ON(!l->use_count);
-	/* if the last user, arm the destroy work */
-	if (!--l->use_count)
-		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork,
-				 CGROUP_PIDLIST_DESTROY_DELAY);
-	mutex_unlock(&l->owner->pidlist_mutex);
-}
-
 static const struct file_operations cgroup_pidlist_operations = {
 	.read = seq_read,
 	.llseek = seq_lseek,
-- 
1.8.4.2
