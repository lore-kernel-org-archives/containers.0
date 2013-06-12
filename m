From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/11] cgroup: rename CGRP_REMOVED to CGRP_DEAD
Date: Wed, 12 Jun 2013 14:03:11 -0700
Message-ID: <1371070996-20613-7-git-send-email-tj__2814.31152620844$1371071074$gmane$org@kernel.org>
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

We will add another flag indicating that the cgroup is in the process
of being killed.  REMOVING / REMOVED is more difficult to distinguish
and cgroup_is_removing()/cgroup_is_removed() are a bit awkward.  Also,
later percpu_ref usage will involve "kill"ing the refcnt.

 s/CGRP_REMOVED/CGRP_DEAD/
 s/cgroup_is_removed()/cgroup_is_dead()

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 30 ++++++++++++++----------------
 2 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7b16882..75a6733 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -143,7 +143,7 @@ static inline void css_put(struct cgroup_subsys_state *css)
 /* bits in struct cgroup flags field */
 enum {
 	/* Control Group is dead */
-	CGRP_REMOVED,
+	CGRP_DEAD,
 	/*
 	 * Control Group has previously had a child cgroup or a task,
 	 * but no longer (only if CGRP_NOTIFY_ON_RELEASE is set)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 585f0a5..0343df5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -226,9 +226,9 @@ static int css_refcnt(struct cgroup_subsys_state *css)
 }
 
 /* convenient tests for these bits */
-static inline bool cgroup_is_removed(const struct cgroup *cgrp)
+static inline bool cgroup_is_dead(const struct cgroup *cgrp)
 {
-	return test_bit(CGRP_REMOVED, &cgrp->flags);
+	return test_bit(CGRP_DEAD, &cgrp->flags);
 }
 
 /**
@@ -300,7 +300,7 @@ static inline struct cftype *__d_cft(struct dentry *dentry)
 static bool cgroup_lock_live_group(struct cgroup *cgrp)
 {
 	mutex_lock(&cgroup_mutex);
-	if (cgroup_is_removed(cgrp)) {
+	if (cgroup_is_dead(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
 		return false;
 	}
@@ -892,7 +892,7 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 	if (S_ISDIR(inode->i_mode)) {
 		struct cgroup *cgrp = dentry->d_fsdata;
 
-		BUG_ON(!(cgroup_is_removed(cgrp)));
+		BUG_ON(!(cgroup_is_dead(cgrp)));
 		call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
 	} else {
 		struct cfent *cfe = __d_cfe(dentry);
@@ -2366,7 +2366,7 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 
-	if (cgroup_is_removed(cgrp))
+	if (cgroup_is_dead(cgrp))
 		return -ENODEV;
 	if (cft->write)
 		return cft->write(cgrp, cft, file, buf, nbytes, ppos);
@@ -2411,7 +2411,7 @@ static ssize_t cgroup_file_read(struct file *file, char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 
-	if (cgroup_is_removed(cgrp))
+	if (cgroup_is_dead(cgrp))
 		return -ENODEV;
 
 	if (cft->read)
@@ -2834,7 +2834,7 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
-		if (!cgroup_is_removed(cgrp))
+		if (!cgroup_is_dead(cgrp))
 			cgroup_addrm_files(cgrp, ss, cfts, is_add);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
@@ -3002,14 +3002,14 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos)
 	/*
 	 * @pos could already have been removed.  Once a cgroup is removed,
 	 * its ->sibling.next is no longer updated when its next sibling
-	 * changes.  As CGRP_REMOVED is set on removal which is fully
+	 * changes.  As CGRP_DEAD is set on removal which is fully
 	 * serialized, if we see it unasserted, it's guaranteed that the
 	 * next sibling hasn't finished its grace period even if it's
 	 * already removed, and thus safe to dereference from this RCU
 	 * critical section.  If ->sibling.next is inaccessible,
-	 * cgroup_is_removed() is guaranteed to be visible as %true here.
+	 * cgroup_is_dead() is guaranteed to be visible as %true here.
 	 */
-	if (likely(!cgroup_is_removed(pos))) {
+	if (likely(!cgroup_is_dead(pos))) {
 		next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
 		if (&next->sibling != &pos->parent->children)
 			return next;
@@ -4386,7 +4386,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * attempts fail thus maintaining the removal conditions verified
 	 * above.
 	 *
-	 * Note that CGRP_REMVOED clearing is depended upon by
+	 * Note that CGRP_DEAD assertion is depended upon by
 	 * cgroup_next_sibling() to resume iteration after dropping RCU
 	 * read lock.  See cgroup_next_sibling() for details.
 	 */
@@ -4396,7 +4396,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		WARN_ON(atomic_read(&css->refcnt) < 0);
 		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
 	}
-	set_bit(CGRP_REMOVED, &cgrp->flags);
+	set_bit(CGRP_DEAD, &cgrp->flags);
 
 	/* tell subsystems to initate destruction */
 	for_each_subsys(cgrp->root, ss)
@@ -5066,7 +5066,7 @@ static void check_for_release(struct cgroup *cgrp)
 		int need_schedule_work = 0;
 
 		raw_spin_lock(&release_list_lock);
-		if (!cgroup_is_removed(cgrp) &&
+		if (!cgroup_is_dead(cgrp) &&
 		    list_empty(&cgrp->release_list)) {
 			list_add(&cgrp->release_list, &release_list);
 			need_schedule_work = 1;
@@ -5212,9 +5212,7 @@ __setup("cgroup_disable=", cgroup_disable);
  * Functons for CSS ID.
  */
 
-/*
- *To get ID other than 0, this should be called when !cgroup_is_removed().
- */
+/* to get ID other than 0, this should be called when !cgroup_is_dead() */
 unsigned short css_id(struct cgroup_subsys_state *css)
 {
 	struct css_id *cssid;
-- 
1.8.2.1
