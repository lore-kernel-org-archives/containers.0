From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.14-rc3
Date: Thu, 20 Feb 2014 09:02:38 -0500
Message-ID: <20140220140238.GB6897@htj.dyndns.org>
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

Quite a few fixes this time.  Three locking fixes, all marked for
-stable.  A couple error path fixes and some misc fixes.  Hugh found a
bug in memcg offlining sequence and we thought we could fix that from
cgroup core side but that turned out to be insufficient and got
reverted.  A different fix has been applied to -mm.

The following changes since commit 38dbfb59d1175ef458d006556061adeaa8751b72:

  Linus 3.14-rc1 (2014-02-02 16:42:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.14-fixes

for you to fetch changes up to 532de3fc72adc2a6525c4d53c07bf81e1732083d:

  cgroup: update cgroup_enable_task_cg_lists() to grab siglock (2014-02-18 18:23:18 -0500)

Thanks.

----------------------------------------------------------------
Hugh Dickins (1):
      cgroup: use an ordered workqueue for cgroup destruction

Li Zefan (2):
      cpuset: update MAINTAINERS entry
      cgroup: protect modifications to cgroup_idr with cgroup_mutex

Tejun Heo (7):
      arm, pm, vmpressure: add missing slab.h includes
      nfs: include xattr.h from fs/nfs/nfs3proc.c
      cgroup: fix error return value in cgroup_mount()
      cgroup: fix error return from cgroup_create()
      cgroup: fix locking in cgroup_cfts_commit()
      Revert "cgroup: use an ordered workqueue for cgroup destruction"
      cgroup: update cgroup_enable_task_cg_lists() to grab siglock

 MAINTAINERS              |  2 ++
 arch/arm/mach-tegra/pm.c |  1 +
 fs/nfs/nfs3proc.c        |  1 +
 include/linux/cgroup.h   |  2 ++
 kernel/cgroup.c          | 60 ++++++++++++++++++++++++++----------------------
 kernel/power/console.c   |  1 +
 mm/vmpressure.c          |  1 +
 7 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b2cf5cf..41e52c5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2408,8 +2408,10 @@ F:	tools/power/cpupower/
 
 CPUSETS
 M:	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
+L:	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://www.bullopensource.org/cpuset/
 W:	http://oss.sgi.com/projects/cpusets/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git
 S:	Maintained
 F:	Documentation/cgroups/cpusets.txt
 F:	include/linux/cpuset.h
diff --git a/arch/arm/mach-tegra/pm.c b/arch/arm/mach-tegra/pm.c
index 4ae0286..f55b05a 100644
--- a/arch/arm/mach-tegra/pm.c
+++ b/arch/arm/mach-tegra/pm.c
@@ -24,6 +24,7 @@
 #include <linux/cpu_pm.h>
 #include <linux/suspend.h>
 #include <linux/err.h>
+#include <linux/slab.h>
 #include <linux/clk/tegra.h>
 
 #include <asm/smp_plat.h>
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index aa9bc97..a462ef0 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -18,6 +18,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfs_mount.h>
 #include <linux/freezer.h>
+#include <linux/xattr.h>
 
 #include "iostat.h"
 #include "internal.h"
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 5c09759..9450f02 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -166,6 +166,8 @@ struct cgroup {
 	 *
 	 * The ID of the root cgroup is always 0, and a new cgroup
 	 * will be assigned with a smallest available ID.
+	 *
+	 * Allocating/Removing ID must be protected by cgroup_mutex.
 	 */
 	int id;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e2f46ba..105f273 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -886,7 +886,9 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		 * per-subsystem and moved to css->id so that lookups are
 		 * successful until the target css is released.
 		 */
+		mutex_lock(&cgroup_mutex);
 		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
+		mutex_unlock(&cgroup_mutex);
 		cgrp->id = -1;
 
 		call_rcu(&cgrp->rcu_head, cgroup_free_rcu);
@@ -1566,10 +1568,10 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		mutex_lock(&cgroup_mutex);
 		mutex_lock(&cgroup_root_mutex);
 
-		root_cgrp->id = idr_alloc(&root->cgroup_idr, root_cgrp,
-					   0, 1, GFP_KERNEL);
-		if (root_cgrp->id < 0)
+		ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
+		if (ret < 0)
 			goto unlock_drop;
+		root_cgrp->id = ret;
 
 		/* Check for name clashes with existing mounts */
 		ret = -EBUSY;
@@ -2763,10 +2765,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	 */
 	update_before = cgroup_serial_nr_next;
 
-	mutex_unlock(&cgroup_mutex);
-
 	/* add/rm files for all cgroups created before */
-	rcu_read_lock();
 	css_for_each_descendant_pre(css, cgroup_css(root, ss)) {
 		struct cgroup *cgrp = css->cgroup;
 
@@ -2775,23 +2774,19 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 
 		inode = cgrp->dentry->d_inode;
 		dget(cgrp->dentry);
-		rcu_read_unlock();
-
 		dput(prev);
 		prev = cgrp->dentry;
 
+		mutex_unlock(&cgroup_mutex);
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
-		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
-
-		rcu_read_lock();
 		if (ret)
 			break;
 	}
-	rcu_read_unlock();
+	mutex_unlock(&cgroup_mutex);
 	dput(prev);
 	deactivate_super(sb);
 	return ret;
@@ -2910,9 +2905,14 @@ static void cgroup_enable_task_cg_lists(void)
 		 * We should check if the process is exiting, otherwise
 		 * it will race with cgroup_exit() in that the list
 		 * entry won't be deleted though the process has exited.
+		 * Do it while holding siglock so that we don't end up
+		 * racing against cgroup_exit().
 		 */
+		spin_lock_irq(&p->sighand->siglock);
 		if (!(p->flags & PF_EXITING) && list_empty(&p->cg_list))
 			list_add(&p->cg_list, &task_css_set(p)->tasks);
+		spin_unlock_irq(&p->sighand->siglock);
+
 		task_unlock(p);
 	} while_each_thread(g, p);
 	read_unlock(&tasklist_lock);
@@ -4158,7 +4158,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
-	int ssid, err = 0;
+	int ssid, err;
 	struct cgroup_subsys *ss;
 	struct super_block *sb = root->sb;
 
@@ -4168,19 +4168,13 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		return -ENOMEM;
 
 	name = cgroup_alloc_name(dentry);
-	if (!name)
+	if (!name) {
+		err = -ENOMEM;
 		goto err_free_cgrp;
+	}
 	rcu_assign_pointer(cgrp->name, name);
 
 	/*
-	 * Temporarily set the pointer to NULL, so idr_find() won't return
-	 * a half-baked cgroup.
-	 */
-	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
-	if (cgrp->id < 0)
-		goto err_free_name;
-
-	/*
 	 * Only live parents can have children.  Note that the liveliness
 	 * check isn't strictly necessary because cgroup_mkdir() and
 	 * cgroup_rmdir() are fully synchronized by i_mutex; however, do it
@@ -4189,7 +4183,17 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	if (!cgroup_lock_live_group(parent)) {
 		err = -ENODEV;
-		goto err_free_id;
+		goto err_free_name;
+	}
+
+	/*
+	 * Temporarily set the pointer to NULL, so idr_find() won't return
+	 * a half-baked cgroup.
+	 */
+	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
+	if (cgrp->id < 0) {
+		err = -ENOMEM;
+		goto err_unlock;
 	}
 
 	/* Grab a reference on the superblock so the hierarchy doesn't
@@ -4221,7 +4225,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
 	if (err < 0)
-		goto err_unlock;
+		goto err_free_id;
 	lockdep_assert_held(&dentry->d_inode->i_mutex);
 
 	cgrp->serial_nr = cgroup_serial_nr_next++;
@@ -4257,12 +4261,12 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	return 0;
 
-err_unlock:
-	mutex_unlock(&cgroup_mutex);
-	/* Release the reference count that we took on the superblock */
-	deactivate_super(sb);
 err_free_id:
 	idr_remove(&root->cgroup_idr, cgrp->id);
+	/* Release the reference count that we took on the superblock */
+	deactivate_super(sb);
+err_unlock:
+	mutex_unlock(&cgroup_mutex);
 err_free_name:
 	kfree(rcu_dereference_raw(cgrp->name));
 err_free_cgrp:
diff --git a/kernel/power/console.c b/kernel/power/console.c
index eacb8bd..aba9c54 100644
--- a/kernel/power/console.c
+++ b/kernel/power/console.c
@@ -9,6 +9,7 @@
 #include <linux/kbd_kern.h>
 #include <linux/vt.h>
 #include <linux/module.h>
+#include <linux/slab.h>
 #include "power.h"
 
 #define SUSPEND_CONSOLE	(MAX_NR_CONSOLES-1)
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 196970a..d4042e7 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -19,6 +19,7 @@
 #include <linux/mm.h>
 #include <linux/vmstat.h>
 #include <linux/eventfd.h>
+#include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/printk.h>
 #include <linux/vmpressure.h>
