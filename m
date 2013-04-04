From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/5] cgroup: unexport locking interface and
	cgroup_attach_task()
Date: Thu,  4 Apr 2013 16:36:27 -0700
Message-ID: <1365118589-10619-4-git-send-email-tj__29012.2193903246$1365118667$gmane$org@kernel.org>
References: <1365118589-10619-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365118589-10619-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that all external cgroup_lock() users are gone, we can finally
unexport the locking interface and prevent future abuse of
cgroup_mutex.

Make cgroup_[un]lock() and cgroup_lock_live_group() static.  Also,
cgroup_attach_task() doesn't have any user left and can't be used
without locking interface anyway.  Make it static too.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 5 -----
 kernel/cgroup.c        | 9 +++------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index f8eb01d..63deb70 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -30,10 +30,7 @@ struct css_id;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
-extern void cgroup_lock(void);
 extern int cgroup_lock_is_held(void);
-extern bool cgroup_lock_live_group(struct cgroup *cgrp);
-extern void cgroup_unlock(void);
 extern void cgroup_fork(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
@@ -693,8 +690,6 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 					struct cgroup_iter *it);
 void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
-int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
-		       bool threadgroup);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ae76170..32ca030 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -336,7 +336,7 @@ static inline struct cftype *__d_cft(struct dentry *dentry)
  * On success, returns true; the lock should be later released with
  * cgroup_unlock(). On failure returns false with no lock held.
  */
-bool cgroup_lock_live_group(struct cgroup *cgrp)
+static bool cgroup_lock_live_group(struct cgroup *cgrp)
 {
 	mutex_lock(&cgroup_mutex);
 	if (cgroup_is_removed(cgrp)) {
@@ -345,7 +345,6 @@ bool cgroup_lock_live_group(struct cgroup *cgrp)
 	}
 	return true;
 }
-EXPORT_SYMBOL_GPL(cgroup_lock_live_group);
 
 /* the list of cgroups eligible for automatic release. Protected by
  * release_list_lock */
@@ -824,22 +823,20 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
  * cgroup_lock - lock out any changes to cgroup structures
  *
  */
-void cgroup_lock(void)
+static void cgroup_lock(void)
 {
 	mutex_lock(&cgroup_mutex);
 }
-EXPORT_SYMBOL_GPL(cgroup_lock);
 
 /**
  * cgroup_unlock - release lock on cgroup changes
  *
  * Undo the lock taken in a previous cgroup_lock() call.
  */
-void cgroup_unlock(void)
+static void cgroup_unlock(void)
 {
 	mutex_unlock(&cgroup_mutex);
 }
-EXPORT_SYMBOL_GPL(cgroup_unlock);
 
 /*
  * A couple of forward declarations required, due to cyclic reference loop:
-- 
1.8.1.4
