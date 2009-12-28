From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [patch 2/2] Remove the ns_cgroup
Date: Tue, 29 Dec 2009 00:04:56 +0100
Message-ID: <20091228230623.907397717@mai.lab.toulouse-stg.fr.ibm.com>
References: <20091228230454.000895089@mai.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=remove-ns-cgroup.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier.

For example, a single process can not handle a big amount of namespaces
without interacting with this cgroup and falling in an exponential creation
time due to the nested cgroup directory depth (eg. /cgroup/<pid>/.../<pid>/...).

That was spotted when creating a single process using multiple network namespaces,
the objective was 4096 network namespaces, but at 820 netns, the creation time
was dramatically slow and the creation time for a namespace increased from 10msec
to 10sec. After five hours, the expected numbers of netns was not reached.
Without the ns_cgroup interaction, 4K netns are created after 2 minutes.

In order to solve that, we have to mount the cgroup with all the subsystems
except the ns_cgroup, it's a little weird and hard to manage from an administration
pov because we have to know what are the cgroup available on the system and we
can't do a simple 'mount -t cgroup cgroup /cgroup'.

With the previous patch which adds a 'clone_child' parameter to a cgroup,
we should be able to remove the ns_cgroup and manage manually the creation +
adding a task to the cgroup consistenly with the rest of the subsystems.

This patch removes the ns_cgroup as suggested in the following thread:

https://lists.linux-foundation.org/pipermail/containers/2009-June/018616.html

The 'cgroup_clone' function is removed because it is no longer used.

All the ns_cgroup.c code is removed, so we don't have the rules for attaching
a task to a cgroup, but I am not sure it's really relevant. Because we must have
the CAP_SYS_ADMIN for unsharing a namespace or to create a cgroup. Concerning
cgroup hierarchy vs process attachment I am not sure to understand what is the
goal of these checks and what are they for.

Signed-off-by: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
---
 include/linux/cgroup.h        |    3 -
 include/linux/cgroup_subsys.h |    6 --
 init/Kconfig                  |    9 ---
 kernel/Makefile               |    1 
 kernel/cgroup.c               |  116 ------------------------------------------
 kernel/fork.c                 |    6 --
 kernel/ns_cgroup.c            |  110 ---------------------------------------
 kernel/nsproxy.c              |   15 +----
 8 files changed, 3 insertions(+), 263 deletions(-)

Index: linux-2.6/include/linux/cgroup.h
===================================================================
--- linux-2.6.orig/include/linux/cgroup.h
+++ linux-2.6/include/linux/cgroup.h
@@ -499,9 +499,6 @@ static inline struct cgroup* task_cgroup
 	return task_subsys_state(task, subsys_id)->cgroup;
 }
 
-int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *ss,
-							char *nodename);
-
 /* A cgroup_iter should be treated as an opaque object */
 struct cgroup_iter {
 	struct list_head *cg_link;
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -512,15 +512,6 @@ config CGROUP_DEBUG
 
 	  Say N if unsure.
 
-config CGROUP_NS
-	bool "Namespace cgroup subsystem"
-	depends on CGROUPS
-	help
-	  Provides a simple namespace cgroup subsystem to
-	  provide hierarchical naming of sets of namespaces,
-	  for instance virtual servers and checkpoint/restart
-	  jobs.
-
 config CGROUP_FREEZER
 	bool "Freezer cgroup subsystem"
 	depends on CGROUPS
Index: linux-2.6/kernel/Makefile
===================================================================
--- linux-2.6.orig/kernel/Makefile
+++ linux-2.6/kernel/Makefile
@@ -61,7 +61,6 @@ obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
-obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
Index: linux-2.6/kernel/cgroup.c
===================================================================
--- linux-2.6.orig/kernel/cgroup.c
+++ linux-2.6/kernel/cgroup.c
@@ -3564,122 +3564,6 @@ void cgroup_exit(struct task_struct *tsk
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
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -1184,12 +1184,6 @@ static struct task_struct *copy_process(
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
Index: linux-2.6/kernel/ns_cgroup.c
===================================================================
--- linux-2.6.orig/kernel/ns_cgroup.c
+++ /dev/null
@@ -1,110 +0,0 @@
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
Index: linux-2.6/kernel/nsproxy.c
===================================================================
--- linux-2.6.orig/kernel/nsproxy.c
+++ linux-2.6/kernel/nsproxy.c
@@ -170,8 +170,6 @@ void free_nsproxy(struct nsproxy *ns)
 int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 		struct nsproxy **new_nsp, struct fs_struct *new_fs)
 {
-	int err = 0;
-
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
 			       CLONE_NEWNET)))
 		return 0;
@@ -181,17 +179,10 @@ int unshare_nsproxy_namespaces(unsigned 
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
 				new_fs ? new_fs : current->fs);
-	if (IS_ERR(*new_nsp)) {
-		err = PTR_ERR(*new_nsp);
-		goto out;
-	}
+	if (IS_ERR(*new_nsp))
+		return PTR_ERR(*new_nsp);
 
-	err = ns_cgroup_clone(current, task_pid(current));
-	if (err)
-		put_nsproxy(*new_nsp);
-
-out:
-	return err;
+	return 0;
 }
 
 void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
Index: linux-2.6/include/linux/cgroup_subsys.h
===================================================================
--- linux-2.6.orig/include/linux/cgroup_subsys.h
+++ linux-2.6/include/linux/cgroup_subsys.h
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
