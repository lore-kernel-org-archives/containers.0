From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/8] cgroup: remove CGRP_WAIT_ON_RMDIR,
	cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir()
Date: Wed, 31 Oct 2012 11:16:28 -0700
Message-ID: <1351707391-22287-6-git-send-email-tj__22530.9982001365$1351707453$gmane$org@kernel.org>
References: <1351707391-22287-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351707391-22287-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

CGRP_WAIT_ON_RMDIR is another kludge which was added to make cgroup
destruction rollback somewhat working.  cgroup_rmdir() used to drain
CSS references and CGRP_WAIT_ON_RMDIR and the associated waitqueue and
helpers were used to allow the task performing rmdir to wait for the
next relevant event.

Unfortunately, the wait is visible to controllers too and the
mechanism got exposed to memcg by 887032670d ("cgroup avoid permanent
sleep at rmdir").

Now that the draining and retries are gone, CGRP_WAIT_ON_RMDIR is
unnecessary.  Remove it and all the mechanisms supporting it.  Note
that memcontrol.c changes are essentially revert of 887032670d
("cgroup avoid permanent sleep at rmdir").

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h | 21 ---------------------
 kernel/cgroup.c        | 51 --------------------------------------------------
 mm/memcontrol.c        | 24 +-----------------------
 3 files changed, 1 insertion(+), 95 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a309804..47868a8 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -145,10 +145,6 @@ enum {
 	/* Control Group requires release notifications to userspace */
 	CGRP_NOTIFY_ON_RELEASE,
 	/*
-	 * A thread in rmdir() is wating for this cgroup.
-	 */
-	CGRP_WAIT_ON_RMDIR,
-	/*
 	 * Clone cgroup values when creating a new child cgroup
 	 */
 	CGRP_CLONE_CHILDREN,
@@ -412,23 +408,6 @@ int cgroup_task_count(const struct cgroup *cgrp);
 int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
 
 /*
- * When the subsys has to access css and may add permanent refcnt to css,
- * it should take care of racy conditions with rmdir(). Following set of
- * functions, is for stop/restart rmdir if necessary.
- * Because these will call css_get/put, "css" should be alive css.
- *
- *  cgroup_exclude_rmdir();
- *  ...do some jobs which may access arbitrary empty cgroup
- *  cgroup_release_and_wakeup_rmdir();
- *
- *  When someone removes a cgroup while cgroup_exclude_rmdir() holds it,
- *  it sleeps and cgroup_release_and_wakeup_rmdir() will wake him up.
- */
-
-void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
-void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css);
-
-/*
  * Control Group taskset, used to pass around set of tasks to cgroup_subsys
  * methods.
  */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 66204a6..c5f6fb2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -966,33 +966,6 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
 }
 
 /*
- * A queue for waiters to do rmdir() cgroup. A tasks will sleep when
- * cgroup->count == 0 && list_empty(&cgroup->children) && subsys has some
- * reference to css->refcnt. In general, this refcnt is expected to goes down
- * to zero, soon.
- *
- * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
- */
-static DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
-
-static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
-{
-	if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
-		wake_up_all(&cgroup_rmdir_waitq);
-}
-
-void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
-{
-	css_get(css);
-}
-
-void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css)
-{
-	cgroup_wakeup_rmdir_waiter(css->cgroup);
-	css_put(css);
-}
-
-/*
  * Call with cgroup_mutex held. Drops reference counts on modules, including
  * any duplicate ones that parse_cgroupfs_options took. If this function
  * returns an error, no reference counts are touched.
@@ -1963,12 +1936,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	}
 
 	synchronize_rcu();
-
-	/*
-	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
-	 * is no longer empty.
-	 */
-	cgroup_wakeup_rmdir_waiter(cgrp);
 out:
 	if (retval) {
 		for_each_subsys(root, ss) {
@@ -2138,7 +2105,6 @@ static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * step 5: success! and cleanup
 	 */
 	synchronize_rcu();
-	cgroup_wakeup_rmdir_waiter(cgrp);
 	retval = 0;
 out_put_css_set_refs:
 	if (retval) {
@@ -4058,26 +4024,13 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	struct cgroup_event *event, *tmp;
 	struct cgroup_subsys *ss;
 
-	/*
-	 * In general, subsystem has no css->refcnt after pre_destroy(). But
-	 * in racy cases, subsystem may have to get css->refcnt after
-	 * pre_destroy() and it makes rmdir return with -EBUSY. This sometimes
-	 * make rmdir return -EBUSY too often. To avoid that, we use waitqueue
-	 * for cgroup's rmdir. CGRP_WAIT_ON_RMDIR is for synchronizing rmdir
-	 * and subsystem's reference count handling. Please see css_get/put
-	 * and css_tryget() and cgroup_wakeup_rmdir_waiter() implementation.
-	 */
-	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-
 	/* the vfs holds both inode->i_mutex already */
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
 	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
-	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
 
 	/*
 	 * Block new css_tryget() by deactivating refcnt and mark @cgrp
@@ -4114,9 +4067,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	for_each_subsys(cgrp->root, ss)
 		css_put(cgrp->subsys[ss->subsys_id]);
 
-	finish_wait(&cgroup_rmdir_waitq, &wait);
-	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-
 	raw_spin_lock(&release_list_lock);
 	if (!list_empty(&cgrp->release_list))
 		list_del_init(&cgrp->release_list);
@@ -4864,7 +4814,6 @@ void __css_put(struct cgroup_subsys_state *css)
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
 		}
-		cgroup_wakeup_rmdir_waiter(cgrp);
 		break;
 	case 0:
 		schedule_work(&css->dput_work);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6f8bd9d..1033b2b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2681,13 +2681,6 @@ static int mem_cgroup_move_account(struct page *page,
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
-	/*
-	 * We charges against "to" which may not have any tasks. Then, "to"
-	 * can be under rmdir(). But in current implementation, caller of
-	 * this function is just force_empty() and move charge, so it's
-	 * guaranteed that "to" is never removed. So, we don't check rmdir
-	 * status here.
-	 */
 	move_unlock_mem_cgroup(from, &flags);
 	ret = 0;
 unlock:
@@ -2893,7 +2886,6 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
 		return;
 	if (!memcg)
 		return;
-	cgroup_exclude_rmdir(&memcg->css);
 
 	__mem_cgroup_commit_charge(memcg, page, 1, ctype, true);
 	/*
@@ -2907,12 +2899,6 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
 		swp_entry_t ent = {.val = page_private(page)};
 		mem_cgroup_uncharge_swap(ent);
 	}
-	/*
-	 * At swapin, we may charge account against cgroup which has no tasks.
-	 * So, rmdir()->pre_destroy() can be called while we do this charge.
-	 * In that case, we need to call pre_destroy() again. check it here.
-	 */
-	cgroup_release_and_wakeup_rmdir(&memcg->css);
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page,
@@ -3360,8 +3346,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 
 	if (!memcg)
 		return;
-	/* blocks rmdir() */
-	cgroup_exclude_rmdir(&memcg->css);
+
 	if (!migration_ok) {
 		used = oldpage;
 		unused = newpage;
@@ -3395,13 +3380,6 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	 */
 	if (anon)
 		mem_cgroup_uncharge_page(used);
-	/*
-	 * At migration, we may charge account against cgroup which has no
-	 * tasks.
-	 * So, rmdir()->pre_destroy() can be called while we do this charge.
-	 * In that case, we need to call pre_destroy() again. check it here.
-	 */
-	cgroup_release_and_wakeup_rmdir(&memcg->css);
 }
 
 /*
-- 
1.7.11.7
