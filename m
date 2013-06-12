From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/11] cgroup: drop unnecessary RCU dancing from
	__put_css_set()
Date: Wed, 12 Jun 2013 14:03:12 -0700
Message-ID: <1371070996-20613-8-git-send-email-tj@kernel.org>
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
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

__put_css_set() does RCU read access on @cgrp across dropping
@cgrp->count so that it can continue accessing @cgrp even if the count
reached zero and destruction of the cgroup commenced.  Given that both
sides - __css_put() and cgroup_destroy_locked() - are cold paths, this
is unnecessary.  Just making cgroup_destroy_locked() grab css_set_lock
while checking @cgrp->count is enough.

Remove the RCU read locking from __put_css_set() and make
cgroup_destroy_locked() read-lock css_set_lock when checking
@cgrp->count.  This will also allow removing @cgrp->count.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0343df5..efe500b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -407,19 +407,13 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 		list_del_init(&link->cset_link);
 		list_del_init(&link->cgrp_link);
 
-		/*
-		 * We may not be holding cgroup_mutex, and if cgrp->count is
-		 * dropped to 0 the cgroup can be destroyed at any time, hence
-		 * rcu_read_lock is used to keep it alive.
-		 */
-		rcu_read_lock();
+		/* @cgrp can't go away while we're holding css_set_lock */
 		if (atomic_dec_and_test(&cgrp->count) &&
 		    notify_on_release(cgrp)) {
 			if (taskexit)
 				set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
 		}
-		rcu_read_unlock();
 
 		kfree(link);
 	}
@@ -4373,11 +4367,19 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	struct cgroup *parent = cgrp->parent;
 	struct cgroup_event *event, *tmp;
 	struct cgroup_subsys *ss;
+	bool empty;
 
 	lockdep_assert_held(&d->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_mutex);
 
-	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children))
+	/*
+	 * css_set_lock prevents @cgrp from being removed while
+	 * __put_css_set() is in progress.
+	 */
+	read_lock(&css_set_lock);
+	empty = !atomic_read(&cgrp->count) && list_empty(&cgrp->children);
+	read_unlock(&css_set_lock);
+	if (!empty)
 		return -EBUSY;
 
 	/*
@@ -5054,8 +5056,6 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 
 static void check_for_release(struct cgroup *cgrp)
 {
-	/* All of these checks rely on RCU to keep the cgroup
-	 * structure alive */
 	if (cgroup_is_releasable(cgrp) &&
 	    !atomic_read(&cgrp->count) && list_empty(&cgrp->children)) {
 		/*
-- 
1.8.2.1
