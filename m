From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/9] cgroup: remove cgroup_pidlist->rwsem
Date: Sun, 24 Nov 2013 17:11:33 -0500
Message-ID: <1385331096-7918-7-git-send-email-tj__47206.921518273$1385331155$gmane$org@kernel.org>
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

cgroup_pidlist locking is needlessly complicated.  It has outer
cgroup->pidlist_mutex to protect the list of pidlists associated with
a cgroup and then each pidlist has rwsem to synchronize updates and
reads.  Given that the only read access is from seq_file operations
which are always invoked back-to-back, the rwsem is a giant overkill.
All it does is adding unnecessary complexity.

This patch removes cgroup_pidlist->rwsem and protects all accesses to
pidlists belonging to a cgroup with cgroup->pidlist_mutex.
pidlist->rwsem locking is removed if it's nested inside
cgroup->pidlist_mutex; otherwise, it's replaced with
cgroup->pidlist_mutex locking.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 33b6c4d..4ceeab0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3460,8 +3460,6 @@ struct cgroup_pidlist {
 	struct list_head links;
 	/* pointer to the cgroup we belong to, for list removal purposes */
 	struct cgroup *owner;
-	/* protects the other fields */
-	struct rw_semaphore rwsem;
 	/* for delayed destruction */
 	struct delayed_work destroy_dwork;
 };
@@ -3520,7 +3518,6 @@ static void cgroup_pidlist_destroy_work_fn(struct work_struct *work)
 	struct cgroup_pidlist *tofree = NULL;
 
 	mutex_lock(&l->owner->pidlist_mutex);
-	down_write(&l->rwsem);
 
 	/*
 	 * Destroy iff we didn't race with a new user or get queued again.
@@ -3533,7 +3530,6 @@ static void cgroup_pidlist_destroy_work_fn(struct work_struct *work)
 		tofree = l;
 	}
 
-	up_write(&l->rwsem);
 	mutex_unlock(&l->owner->pidlist_mutex);
 	kfree(tofree);
 }
@@ -3610,7 +3606,6 @@ static struct cgroup_pidlist *cgroup_pidlist_find_create(struct cgroup *cgrp,
 	if (!l)
 		return l;
 
-	init_rwsem(&l->rwsem);
 	INIT_DELAYED_WORK(&l->destroy_dwork, cgroup_pidlist_destroy_work_fn);
 	l->key.type = type;
 	/* don't need task_nsproxy() if we're looking at ourself */
@@ -3673,12 +3668,10 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	}
 
 	/* store array, freeing old if necessary */
-	down_write(&l->rwsem);
 	pidlist_free(l->list);
 	l->list = array;
 	l->length = length;
 	l->use_count++;
-	up_write(&l->rwsem);
 
 	mutex_unlock(&cgrp->pidlist_mutex);
 
@@ -3760,7 +3753,7 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 	int index = 0, pid = *pos;
 	int *iter;
 
-	down_read(&l->rwsem);
+	mutex_lock(&of->cgrp->pidlist_mutex);
 	if (pid) {
 		int end = l->length;
 
@@ -3788,7 +3781,7 @@ static void cgroup_pidlist_stop(struct seq_file *s, void *v)
 {
 	struct cgroup_pidlist_open_file *of = s->private;
 
-	up_read(&of->pidlist->rwsem);
+	mutex_unlock(&of->cgrp->pidlist_mutex);
 }
 
 static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
@@ -3828,13 +3821,13 @@ static const struct seq_operations cgroup_pidlist_seq_operations = {
 
 static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 {
-	down_write(&l->rwsem);
+	mutex_lock(&l->owner->pidlist_mutex);
 	BUG_ON(!l->use_count);
 	/* if the last user, arm the destroy work */
 	if (!--l->use_count)
 		mod_delayed_work(cgroup_pidlist_destroy_wq, &l->destroy_dwork,
 				 CGROUP_PIDLIST_DESTROY_DELAY);
-	up_write(&l->rwsem);
+	mutex_unlock(&l->owner->pidlist_mutex);
 }
 
 static int cgroup_pidlist_release(struct inode *inode, struct file *file)
-- 
1.8.4.2
