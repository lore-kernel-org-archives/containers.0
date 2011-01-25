From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH] cgroup : remove the ns_cgroup
Date: Tue, 25 Jan 2011 10:39:48 +0100
Message-ID: <1295948388-15108-1-git-send-email-daniel.lezcano__21826.6992051669$1295948552$gmane$org@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier
and leads to some problems:

        * cgroup creation is out-of-control
        * cgroup name can conflict when pids are looping
        * it is not possible to have a single process handling
        a lot of namespaces without falling in a exponential creation time
        * we may want to create a namespace without creating a cgroup

        The ns_cgroup was replaced by a compatibility flag 'clone_children',
        where a newly created cgroup will copy the parent cgroup values.
        The userspace has to manually create a cgroup and add a task to
        the 'tasks' file.

This patch removes the ns_cgroup as suggested in the following thread:

https://lists.linux-foundation.org/pipermail/containers/2009-June/018616.html

The 'cgroup_clone' function is removed because it is no longer used.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt      |    2 +-
 arch/mips/configs/bcm47xx_defconfig    |    1 -
 arch/mn10300/configs/asb2364_defconfig |    1 -
 arch/powerpc/configs/ppc6xx_defconfig  |    1 -
 arch/powerpc/configs/pseries_defconfig |    1 -
 arch/sh/configs/apsh4ad0a_defconfig    |    1 -
 arch/sh/configs/sdk7786_defconfig      |    1 -
 arch/sh/configs/se7206_defconfig       |    1 -
 arch/sh/configs/shx3_defconfig         |    1 -
 arch/sh/configs/urquell_defconfig      |    1 -
 arch/x86/configs/i386_defconfig        |    1 -
 arch/x86/configs/x86_64_defconfig      |    1 -
 include/linux/cgroup.h                 |    3 -
 include/linux/cgroup_subsys.h          |    6 --
 include/linux/nsproxy.h                |    9 ---
 init/Kconfig                           |    8 --
 kernel/Makefile                        |    1 -
 kernel/cgroup.c                        |  116 -------------------------------
 kernel/cpuset.c                        |    7 +-
 kernel/fork.c                          |    6 --
 kernel/ns_cgroup.c                     |  118 --------------------------------
 kernel/nsproxy.c                       |    4 -
 22 files changed, 4 insertions(+), 287 deletions(-)
 delete mode 100644 kernel/ns_cgroup.c

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 44b8b7a..ac759b6 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -618,7 +618,7 @@ always handled well.
 void post_clone(struct cgroup_subsys *ss, struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
-Called at the end of cgroup_clone() to do any parameter
+Called during cgroup_create() to do any parameter
 initialization which might be required before a task could attach.  For
 example in cpusets, no task may attach before 'cpus' and 'mems' are set
 up.
diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm47xx_defconfig
index 927d58b..c4338e0 100644
--- a/arch/mips/configs/bcm47xx_defconfig
+++ b/arch/mips/configs/bcm47xx_defconfig
@@ -16,7 +16,6 @@ CONFIG_TASK_IO_ACCOUNTING=y
 CONFIG_AUDIT=y
 CONFIG_TINY_RCU=y
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_CPUACCT=y
 CONFIG_RELAY=y
 CONFIG_BLK_DEV_INITRD=y
diff --git a/arch/mn10300/configs/asb2364_defconfig b/arch/mn10300/configs/asb2364_defconfig
index 83ce2f2..d38391a 100644
--- a/arch/mn10300/configs/asb2364_defconfig
+++ b/arch/mn10300/configs/asb2364_defconfig
@@ -8,7 +8,6 @@ CONFIG_TASK_XACCT=y
 CONFIG_TASK_IO_ACCOUNTING=y
 CONFIG_LOG_BUF_SHIFT=14
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CGROUP_CPUACCT=y
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index 9d64a68..9b253f6 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -10,7 +10,6 @@ CONFIG_TASK_XACCT=y
 CONFIG_TASK_IO_ACCOUNTING=y
 CONFIG_AUDIT=y
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CGROUP_CPUACCT=y
 CONFIG_RESOURCE_COUNTERS=y
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index f87f0e1..972587f 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -15,7 +15,6 @@ CONFIG_AUDITSYSCALL=y
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CPUSETS=y
diff --git a/arch/sh/configs/apsh4ad0a_defconfig b/arch/sh/configs/apsh4ad0a_defconfig
index e71a531..f722a3d 100644
--- a/arch/sh/configs/apsh4ad0a_defconfig
+++ b/arch/sh/configs/apsh4ad0a_defconfig
@@ -7,7 +7,6 @@ CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_LOG_BUF_SHIFT=14
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CGROUP_CPUACCT=y
diff --git a/arch/sh/configs/sdk7786_defconfig b/arch/sh/configs/sdk7786_defconfig
index dc4a2eb..9fdabe2 100644
--- a/arch/sh/configs/sdk7786_defconfig
+++ b/arch/sh/configs/sdk7786_defconfig
@@ -12,7 +12,6 @@ CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_CGROUPS=y
 CONFIG_CGROUP_DEBUG=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CPUSETS=y
diff --git a/arch/sh/configs/se7206_defconfig b/arch/sh/configs/se7206_defconfig
index a468ff2..72c3fad 100644
--- a/arch/sh/configs/se7206_defconfig
+++ b/arch/sh/configs/se7206_defconfig
@@ -8,7 +8,6 @@ CONFIG_RCU_TRACE=y
 CONFIG_LOG_BUF_SHIFT=14
 CONFIG_CGROUPS=y
 CONFIG_CGROUP_DEBUG=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CGROUP_CPUACCT=y
 CONFIG_RESOURCE_COUNTERS=y
diff --git a/arch/sh/configs/shx3_defconfig b/arch/sh/configs/shx3_defconfig
index 3f92d37..6bb4130 100644
--- a/arch/sh/configs/shx3_defconfig
+++ b/arch/sh/configs/shx3_defconfig
@@ -9,7 +9,6 @@ CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_LOG_BUF_SHIFT=14
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CGROUP_CPUACCT=y
diff --git a/arch/sh/configs/urquell_defconfig b/arch/sh/configs/urquell_defconfig
index 7b3daec..8bfa4d0 100644
--- a/arch/sh/configs/urquell_defconfig
+++ b/arch/sh/configs/urquell_defconfig
@@ -9,7 +9,6 @@ CONFIG_IKCONFIG_PROC=y
 CONFIG_LOG_BUF_SHIFT=14
 CONFIG_CGROUPS=y
 CONFIG_CGROUP_DEBUG=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CGROUP_DEVICE=y
 CONFIG_CPUSETS=y
diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
index 6f98726..2bf1805 100644
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -10,7 +10,6 @@ CONFIG_TASK_IO_ACCOUNTING=y
 CONFIG_AUDIT=y
 CONFIG_LOG_BUF_SHIFT=18
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CPUSETS=y
 CONFIG_CGROUP_CPUACCT=y
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index ee01a9d..22a0dc8 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -11,7 +11,6 @@ CONFIG_TASK_IO_ACCOUNTING=y
 CONFIG_AUDIT=y
 CONFIG_LOG_BUF_SHIFT=18
 CONFIG_CGROUPS=y
-CONFIG_CGROUP_NS=y
 CONFIG_CGROUP_FREEZER=y
 CONFIG_CPUSETS=y
 CONFIG_CGROUP_CPUACCT=y
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ce104e3..d0509a3 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -552,9 +552,6 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
 	return task_subsys_state(task, subsys_id)->cgroup;
 }
 
-int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *ss,
-							char *nodename);
-
 /* A cgroup_iter should be treated as an opaque object */
 struct cgroup_iter {
 	struct list_head *cg_link;
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ccefff0..4ba5259 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -19,12 +19,6 @@ SUBSYS(debug)
 
 /* */
 
-#ifdef CONFIG_CGROUP_NS
-SUBSYS(ns)
-#endif
-
-/* */
-
 #ifdef CONFIG_CGROUP_SCHED
 SUBSYS(cpu_cgroup)
 #endif
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 7b370c7..50d20ab 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -81,13 +81,4 @@ static inline void get_nsproxy(struct nsproxy *ns)
 	atomic_inc(&ns->count);
 }
 
-#ifdef CONFIG_CGROUP_NS
-int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid);
-#else
-static inline int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid)
-{
-	return 0;
-}
-#endif
-
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index 1379adc..7acdfb4 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -582,14 +582,6 @@ config CGROUP_DEBUG
 
 	  Say N if unsure.
 
-config CGROUP_NS
-	bool "Namespace cgroup subsystem"
-	help
-	  Provides a simple namespace cgroup subsystem to
-	  provide hierarchical naming of sets of namespaces,
-	  for instance virtual servers and checkpoint/restart
-	  jobs.
-
 config CGROUP_FREEZER
 	bool "Freezer cgroup subsystem"
 	help
diff --git a/kernel/Makefile b/kernel/Makefile
index 353d3fe..bd1b486 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -62,7 +62,6 @@ obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
-obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b24d702..9b92442 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4267,122 +4267,6 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 }
 
 /**
- * cgroup_clone - clone the cgroup the given subsystem is attached to
- * @tsk: the task to be moved
- * @subsys: the given subsystem
- * @nodename: the name for the new cgroup
- *
- * Duplicate the current cgroup in the hierarchy that the given
- * subsystem is attached to, and move this task into the new
- * child.
- */
-int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
-							char *nodename)
-{
-	struct dentry *dentry;
-	int ret = 0;
-	struct cgroup *parent, *child;
-	struct inode *inode;
-	struct css_set *cg;
-	struct cgroupfs_root *root;
-	struct cgroup_subsys *ss;
-
-	/* We shouldn't be called by an unregistered subsystem */
-	BUG_ON(!subsys->active);
-
-	/* First figure out what hierarchy and cgroup we're dealing
-	 * with, and pin them so we can drop cgroup_mutex */
-	mutex_lock(&cgroup_mutex);
- again:
-	root = subsys->root;
-	if (root == &rootnode) {
-		mutex_unlock(&cgroup_mutex);
-		return 0;
-	}
-
-	/* Pin the hierarchy */
-	if (!atomic_inc_not_zero(&root->sb->s_active)) {
-		/* We race with the final deactivate_super() */
-		mutex_unlock(&cgroup_mutex);
-		return 0;
-	}
-
-	/* Keep the cgroup alive */
-	task_lock(tsk);
-	parent = task_cgroup(tsk, subsys->subsys_id);
-	cg = tsk->cgroups;
-	get_css_set(cg);
-	task_unlock(tsk);
-
-	mutex_unlock(&cgroup_mutex);
-
-	/* Now do the VFS work to create a cgroup */
-	inode = parent->dentry->d_inode;
-
-	/* Hold the parent directory mutex across this operation to
-	 * stop anyone else deleting the new cgroup */
-	mutex_lock(&inode->i_mutex);
-	dentry = lookup_one_len(nodename, parent->dentry, strlen(nodename));
-	if (IS_ERR(dentry)) {
-		printk(KERN_INFO
-		       "cgroup: Couldn't allocate dentry for %s: %ld\n", nodename,
-		       PTR_ERR(dentry));
-		ret = PTR_ERR(dentry);
-		goto out_release;
-	}
-
-	/* Create the cgroup directory, which also creates the cgroup */
-	ret = vfs_mkdir(inode, dentry, 0755);
-	child = __d_cgrp(dentry);
-	dput(dentry);
-	if (ret) {
-		printk(KERN_INFO
-		       "Failed to create cgroup %s: %d\n", nodename,
-		       ret);
-		goto out_release;
-	}
-
-	/* The cgroup now exists. Retake cgroup_mutex and check
-	 * that we're still in the same state that we thought we
-	 * were. */
-	mutex_lock(&cgroup_mutex);
-	if ((root != subsys->root) ||
-	    (parent != task_cgroup(tsk, subsys->subsys_id))) {
-		/* Aargh, we raced ... */
-		mutex_unlock(&inode->i_mutex);
-		put_css_set(cg);
-
-		deactivate_super(root->sb);
-		/* The cgroup is still accessible in the VFS, but
-		 * we're not going to try to rmdir() it at this
-		 * point. */
-		printk(KERN_INFO
-		       "Race in cgroup_clone() - leaking cgroup %s\n",
-		       nodename);
-		goto again;
-	}
-
-	/* do any required auto-setup */
-	for_each_subsys(root, ss) {
-		if (ss->post_clone)
-			ss->post_clone(ss, child);
-	}
-
-	/* All seems fine. Finish by moving the task into the new cgroup */
-	ret = cgroup_attach_task(child, tsk);
-	mutex_unlock(&cgroup_mutex);
-
- out_release:
-	mutex_unlock(&inode->i_mutex);
-
-	mutex_lock(&cgroup_mutex);
-	put_css_set(cg);
-	mutex_unlock(&cgroup_mutex);
-	deactivate_super(root->sb);
-	return ret;
-}
-
-/**
  * cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
  * @cgrp: the cgroup in question
  * @task: the task in question
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4349935..10f1835 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1828,10 +1828,9 @@ static int cpuset_populate(struct cgroup_subsys *ss, struct cgroup *cont)
 }
 
 /*
- * post_clone() is called at the end of cgroup_clone().
- * 'cgroup' was just created automatically as a result of
- * a cgroup_clone(), and the current task is about to
- * be moved into 'cgroup'.
+ * post_clone() is called during cgroup_create() when the
+ * clone_children mount argument was specified.  The cgroup
+ * can not yet have any tasks.
  *
  * Currently we refuse to set up the cgroup - thereby
  * refusing the task to be entered, and as a result refusing
diff --git a/kernel/fork.c b/kernel/fork.c
index 25e4291..4326cbe 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1193,12 +1193,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	if (clone_flags & CLONE_THREAD)
 		p->tgid = current->tgid;
 
-	if (current->nsproxy != p->nsproxy) {
-		retval = ns_cgroup_clone(p, pid);
-		if (retval)
-			goto bad_fork_free_pid;
-	}
-
 	p->set_child_tid = (clone_flags & CLONE_CHILD_SETTID) ? child_tidptr : NULL;
 	/*
 	 * Clear TID on mm_release()?
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
deleted file mode 100644
index 2c98ad9..0000000
--- a/kernel/ns_cgroup.c
+++ /dev/null
@@ -1,118 +0,0 @@
-/*
- * ns_cgroup.c - namespace cgroup subsystem
- *
- * Copyright 2006, 2007 IBM Corp
- */
-
-#include <linux/module.h>
-#include <linux/cgroup.h>
-#include <linux/fs.h>
-#include <linux/proc_fs.h>
-#include <linux/slab.h>
-#include <linux/nsproxy.h>
-
-struct ns_cgroup {
-	struct cgroup_subsys_state css;
-};
-
-struct cgroup_subsys ns_subsys;
-
-static inline struct ns_cgroup *cgroup_to_ns(
-		struct cgroup *cgroup)
-{
-	return container_of(cgroup_subsys_state(cgroup, ns_subsys_id),
-			    struct ns_cgroup, css);
-}
-
-int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
-{
-	char name[PROC_NUMBUF];
-
-	snprintf(name, PROC_NUMBUF, "%d", pid_vnr(pid));
-	return cgroup_clone(task, &ns_subsys, name);
-}
-
-/*
- * Rules:
- *   1. you can only enter a cgroup which is a descendant of your current
- *     cgroup
- *   2. you can only place another process into a cgroup if
- *     a. you have CAP_SYS_ADMIN
- *     b. your cgroup is an ancestor of task's destination cgroup
- *       (hence either you are in the same cgroup as task, or in an
- *        ancestor cgroup thereof)
- */
-static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
-			 struct task_struct *task, bool threadgroup)
-{
-	if (current != task) {
-		if (!capable(CAP_SYS_ADMIN))
-			return -EPERM;
-
-		if (!cgroup_is_descendant(new_cgroup, current))
-			return -EPERM;
-	}
-
-	if (!cgroup_is_descendant(new_cgroup, task))
-		return -EPERM;
-
-	if (threadgroup) {
-		struct task_struct *c;
-		rcu_read_lock();
-		list_for_each_entry_rcu(c, &task->thread_group, thread_group) {
-			if (!cgroup_is_descendant(new_cgroup, c)) {
-				rcu_read_unlock();
-				return -EPERM;
-			}
-		}
-		rcu_read_unlock();
-	}
-
-	return 0;
-}
-
-/*
- * Rules: you can only create a cgroup if
- *     1. you are capable(CAP_SYS_ADMIN)
- *     2. the target cgroup is a descendant of your own cgroup
- */
-static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
-						struct cgroup *cgroup)
-{
-	struct ns_cgroup *ns_cgroup;
-
-	if (!capable(CAP_SYS_ADMIN))
-		return ERR_PTR(-EPERM);
-	if (!cgroup_is_descendant(cgroup, current))
-		return ERR_PTR(-EPERM);
-	if (test_bit(CGRP_CLONE_CHILDREN, &cgroup->flags)) {
-		printk("ns_cgroup can't be created with parent "
-		       "'clone_children' set.\n");
-		return ERR_PTR(-EINVAL);
-	}
-
-	printk_once("ns_cgroup deprecated: consider using the "
-		    "'clone_children' flag without the ns_cgroup.\n");
-
-	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
-	if (!ns_cgroup)
-		return ERR_PTR(-ENOMEM);
-	return &ns_cgroup->css;
-}
-
-static void ns_destroy(struct cgroup_subsys *ss,
-			struct cgroup *cgroup)
-{
-	struct ns_cgroup *ns_cgroup;
-
-	ns_cgroup = cgroup_to_ns(cgroup);
-	kfree(ns_cgroup);
-}
-
-struct cgroup_subsys ns_subsys = {
-	.name = "ns",
-	.can_attach = ns_can_attach,
-	.create = ns_create,
-	.destroy  = ns_destroy,
-	.subsys_id = ns_subsys_id,
-};
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f74e6c0..014a90d 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -198,10 +198,6 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 		goto out;
 	}
 
-	err = ns_cgroup_clone(current, task_pid(current));
-	if (err)
-		put_nsproxy(*new_nsp);
-
 out:
 	return err;
 }
-- 
1.7.1
