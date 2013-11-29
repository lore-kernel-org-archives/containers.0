From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.13-rc1
Date: Fri, 29 Nov 2013 10:56:39 -0500
Message-ID: <20131129155639.GG3717__48680.4142747589$1385740613$gmane$org@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

Fixes for three issues.

* cgroup destruction path could swamp system_wq possibly leading to
  deadlock.  This actually seems to happen in the wild with memcg
  because memcg destruction path adds nested dependency on system_wq.
  Resolved by isolating cgroup destruction work items on its dedicated
  workqueue.

* Possible locking context deadlock through seqcount reported by
  lockdep.

* Memory leak under certain conditions.

The fixes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.13-fixes

for you to fetch changes up to e605b36575e896edd8161534550c9ea021b03bc0:

  cgroup: fix cgroup_subsys_state leak for seq_files (2013-11-27 18:16:21 -0500)

Thanks.

----------------------------------------------------------------
Peter Zijlstra (1):
      cpuset: Fix memory allocator deadlock

Tejun Heo (2):
      cgroup: use a dedicated workqueue for cgroup destruction
      cgroup: fix cgroup_subsys_state leak for seq_files

 kernel/cgroup.c | 35 +++++++++++++++++++++++++++++++----
 kernel/cpuset.c |  8 ++++++--
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4c62513..8b729c2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -90,6 +90,14 @@ static DEFINE_MUTEX(cgroup_mutex);
 static DEFINE_MUTEX(cgroup_root_mutex);
 
 /*
+ * cgroup destruction makes heavy use of work items and there can be a lot
+ * of concurrent destructions.  Use a separate workqueue so that cgroup
+ * destruction work items don't end up filling up max_active of system_wq
+ * which may lead to deadlock.
+ */
+static struct workqueue_struct *cgroup_destroy_wq;
+
+/*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
  * populated with the built in subsystems, and modular subsystems are
  * registered after that. The mutable section of this array is protected by
@@ -191,6 +199,7 @@ static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
+static int cgroup_file_release(struct inode *inode, struct file *file);
 
 /**
  * cgroup_css - obtain a cgroup's css for the specified subsystem
@@ -871,7 +880,7 @@ static void cgroup_free_rcu(struct rcu_head *head)
 	struct cgroup *cgrp = container_of(head, struct cgroup, rcu_head);
 
 	INIT_WORK(&cgrp->destroy_work, cgroup_free_fn);
-	schedule_work(&cgrp->destroy_work);
+	queue_work(cgroup_destroy_wq, &cgrp->destroy_work);
 }
 
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
@@ -2421,7 +2430,7 @@ static const struct file_operations cgroup_seqfile_operations = {
 	.read = seq_read,
 	.write = cgroup_file_write,
 	.llseek = seq_lseek,
-	.release = single_release,
+	.release = cgroup_file_release,
 };
 
 static int cgroup_file_open(struct inode *inode, struct file *file)
@@ -2482,6 +2491,8 @@ static int cgroup_file_release(struct inode *inode, struct file *file)
 		ret = cft->release(inode, file);
 	if (css->ss)
 		css_put(css);
+	if (file->f_op == &cgroup_seqfile_operations)
+		single_release(inode, file);
 	return ret;
 }
 
@@ -4249,7 +4260,7 @@ static void css_free_rcu_fn(struct rcu_head *rcu_head)
 	 * css_put().  dput() requires process context which we don't have.
 	 */
 	INIT_WORK(&css->destroy_work, css_free_work_fn);
-	schedule_work(&css->destroy_work);
+	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
 
 static void css_release(struct percpu_ref *ref)
@@ -4539,7 +4550,7 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
 		container_of(ref, struct cgroup_subsys_state, refcnt);
 
 	INIT_WORK(&css->destroy_work, css_killed_work_fn);
-	schedule_work(&css->destroy_work);
+	queue_work(cgroup_destroy_wq, &css->destroy_work);
 }
 
 /**
@@ -5063,6 +5074,22 @@ out:
 	return err;
 }
 
+static int __init cgroup_wq_init(void)
+{
+	/*
+	 * There isn't much point in executing destruction path in
+	 * parallel.  Good chunk is serialized with cgroup_mutex anyway.
+	 * Use 1 for @max_active.
+	 *
+	 * We would prefer to do this in cgroup_init() above, but that
+	 * is called before init_workqueues(): so leave this until after.
+	 */
+	cgroup_destroy_wq = alloc_workqueue("cgroup_destroy", 0, 1);
+	BUG_ON(!cgroup_destroy_wq);
+	return 0;
+}
+core_initcall(cgroup_wq_init);
+
 /*
  * proc_cgroup_show()
  *  - Print task's cgroup paths into seq_file, one line for each hierarchy
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 6bf981e..4772034 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1033,8 +1033,10 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	need_loop = task_has_mempolicy(tsk) ||
 			!nodes_intersects(*newmems, tsk->mems_allowed);
 
-	if (need_loop)
+	if (need_loop) {
+		local_irq_disable();
 		write_seqcount_begin(&tsk->mems_allowed_seq);
+	}
 
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
@@ -1042,8 +1044,10 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
 	tsk->mems_allowed = *newmems;
 
-	if (need_loop)
+	if (need_loop) {
 		write_seqcount_end(&tsk->mems_allowed_seq);
+		local_irq_enable();
+	}
 
 	task_unlock(tsk);
 }
