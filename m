From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/11] cgroup: remove cgroup->count and use
Date: Wed, 12 Jun 2013 21:04:55 -0700
Message-ID: <1371096298-24402-9-git-send-email-tj__20297.9321279146$1371096395$gmane$org@kernel.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371096298-24402-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup->count tracks the number of css_sets associated with the cgroup
and used only to verify that no css_set is associated when the cgroup
is being destroyed.  It's superflous as the destruction path can
simply check whether cgroup->cset_links is empty instead.

Drop cgroup->count and check ->cset_links directly from
cgroup_destroy_locked().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  6 ------
 kernel/cgroup.c        | 21 +++++----------------
 2 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c86a93a..81bfd02 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -169,12 +169,6 @@ struct cgroup_name {
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
-	/*
-	 * count users of this cgroup. >0 means busy, but doesn't
-	 * necessarily indicate the number of tasks in the cgroup
-	 */
-	atomic_t count;
-
 	int id;				/* ida allocated in-hierarchy ID */
 
 	/*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 22f9729..062653f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -408,8 +408,7 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 		list_del(&link->cgrp_link);
 
 		/* @cgrp can't go away while we're holding css_set_lock */
-		if (atomic_dec_and_test(&cgrp->count) &&
-		    notify_on_release(cgrp)) {
+		if (list_empty(&cgrp->cset_links) && notify_on_release(cgrp)) {
 			if (taskexit)
 				set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
@@ -616,7 +615,6 @@ static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
 	link = list_first_entry(tmp_links, struct cgrp_cset_link, cset_link);
 	link->cset = cset;
 	link->cgrp = cgrp;
-	atomic_inc(&cgrp->count);
 	list_move(&link->cset_link, &cgrp->cset_links);
 	/*
 	 * Always add links to the tail of the list so that the list
@@ -4373,11 +4371,11 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	lockdep_assert_held(&cgroup_mutex);
 
 	/*
-	 * css_set_lock prevents @cgrp from being removed while
-	 * __put_css_set() is in progress.
+	 * css_set_lock synchronizes access to ->cset_links and prevents
+	 * @cgrp from being removed while __put_css_set() is in progress.
 	 */
 	read_lock(&css_set_lock);
-	empty = !atomic_read(&cgrp->count) && list_empty(&cgrp->children);
+	empty = list_empty(&cgrp->cset_links) && list_empty(&cgrp->children);
 	read_unlock(&css_set_lock);
 	if (!empty)
 		return -EBUSY;
@@ -5057,7 +5055,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 static void check_for_release(struct cgroup *cgrp)
 {
 	if (cgroup_is_releasable(cgrp) &&
-	    !atomic_read(&cgrp->count) && list_empty(&cgrp->children)) {
+	    list_empty(&cgrp->cset_links) && list_empty(&cgrp->children)) {
 		/*
 		 * Control Group is currently removeable. If it's not
 		 * already queued for a userspace notification, queue
@@ -5425,11 +5423,6 @@ static void debug_css_free(struct cgroup *cont)
 	kfree(cont->subsys[debug_subsys_id]);
 }
 
-static u64 cgroup_refcount_read(struct cgroup *cont, struct cftype *cft)
-{
-	return atomic_read(&cont->count);
-}
-
 static u64 debug_taskcount_read(struct cgroup *cont, struct cftype *cft)
 {
 	return cgroup_task_count(cont);
@@ -5511,10 +5504,6 @@ static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
 
 static struct cftype debug_files[] =  {
 	{
-		.name = "cgroup_refcount",
-		.read_u64 = cgroup_refcount_read,
-	},
-	{
 		.name = "taskcount",
 		.read_u64 = debug_taskcount_read,
 	},
-- 
1.8.2.1
