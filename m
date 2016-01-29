From: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/8] cgroup: introduce cgroup namespaces
Date: Fri, 29 Jan 2016 02:54:06 -0600
Message-ID: <1454057651-23959-4-git-send-email-serge.hallyn__13180.1067189828$1454057690$gmane$org@ubuntu.com>
References: <1454057651-23959-1-git-send-email-serge.hallyn@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1454057651-23959-1-git-send-email-serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

From: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Introduce the ability to create new cgroup namespace. The newly created
cgroup namespace remembers the cgroup of the process at the point
of creation of the cgroup namespace (referred as cgroupns-root).
The main purpose of cgroup namespace is to virtualize the contents
of /proc/self/cgroup file. Processes inside a cgroup namespace
are only able to see paths relative to their namespace root
(unless they are moved outside of their cgroupns-root, at which point
 they will see a relative path from their cgroupns-root).
For a correctly setup container this enables container-tools
(like libcontainer, lxc, lmctfy, etc.) to create completely virtualized
containers without leaking system level cgroup hierarchy to the task.
This patch only implements the 'unshare' part of the cgroupns.

Signed-off-by: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
Changelog: 2015-11-24
	- move cgroup_namespace.c into cgroup.c (and .h)
	- reformatting
	- make get_cgroup_ns return void
	- rename ns->root_cgrps to root_cset.
Changelog: 2015-12-08
	- Move init_cgroup_ns to other variable declarations
	- Remove accidental conversion of put-css_set to inline
	- Drop BUG_ON(NULL)
	- Remove unneeded pre declaration of struct cgroupns_operations.
	- cgroup.h: collect common ns declerations
Changelog: 2015-12-09
	- cgroup.h: move ns declarations to bottom
	- cgroup.c: undo all accidental conversions to inline
Changelog: 2015-12-22
	- update for new kernfs_path_from_node() return value.  Since
	  cgroup_path was already gpl-exported, I abstained from updating
	  its return value.
Changelog: 2015-12-23
	- cgroup_path(): use init_cgroup_ns when in interupt context.
Changelog: 2015-01-02
	- move to_cg_ns definition forward in patch series
	- cgroup_release_agent: grab css_set_lock around cgroup_path()
	- leave cgroup_path non-namespaced, use cgroup_path_ns when
	  namespaced path is desired.
Changelog: 2015-01-04
	- cgroup_path: continue to use kernfs_path.  Since cgroup_path is
	  non-namespaced, use the old version.
	- make cgroup_path_ns_locked() static.
Changelog: 2015-01-05
	- don't namespace the path printed in debugfs.
Changelog: 2015-01-27
	- remove unneeded NULL check before put_cgroup_ns()
Changelog: 2015-01-28
	- lock around task_css_set in copy_cgroup_ns, and don't
	  take rcu lock arounc copy_cgroup_ns call in cpuset.
---
 fs/proc/namespaces.c    |    3 +
 include/linux/cgroup.h  |   49 +++++++++++++
 include/linux/nsproxy.h |    2 +
 include/linux/proc_ns.h |    4 ++
 kernel/cgroup.c         |  176 ++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/cpuset.c         |    8 +--
 kernel/fork.c           |    2 +-
 kernel/nsproxy.c        |   19 ++++-
 8 files changed, 253 insertions(+), 10 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 276f124..72cb26f 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -28,6 +28,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 	&userns_operations,
 #endif
 	&mntns_operations,
+#ifdef CONFIG_CGROUPS
+	&cgroupns_operations,
+#endif
 };
 
 static const char *proc_ns_get_link(struct dentry *dentry,
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2162dca..1773af0 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -17,6 +17,11 @@
 #include <linux/seq_file.h>
 #include <linux/kernfs.h>
 #include <linux/jump_label.h>
+#include <linux/nsproxy.h>
+#include <linux/types.h>
+#include <linux/ns_common.h>
+#include <linux/nsproxy.h>
+#include <linux/user_namespace.h>
 
 #include <linux/cgroup-defs.h>
 
@@ -611,4 +616,48 @@ static inline void cgroup_sk_free(struct sock_cgroup_data *skcd) {}
 
 #endif	/* CONFIG_CGROUP_DATA */
 
+struct cgroup_namespace {
+	atomic_t		count;
+	struct ns_common	ns;
+	struct user_namespace	*user_ns;
+	struct css_set          *root_cset;
+};
+
+extern struct cgroup_namespace init_cgroup_ns;
+
+#ifdef CONFIG_CGROUPS
+
+void free_cgroup_ns(struct cgroup_namespace *ns);
+
+struct cgroup_namespace *
+copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+	       struct cgroup_namespace *old_ns);
+
+char *cgroup_path_ns(struct cgroup *cgrp, char *buf, size_t buflen,
+		     struct cgroup_namespace *ns);
+
+#else /* !CONFIG_CGROUPS */
+
+static inline void free_cgroup_ns(struct cgroup_namespace *ns) { }
+static inline struct cgroup_namespace *
+copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+	       struct cgroup_namespace *old_ns)
+{
+	return old_ns;
+}
+
+#endif /* !CONFIG_CGROUPS */
+
+static inline void get_cgroup_ns(struct cgroup_namespace *ns)
+{
+	if (ns)
+		atomic_inc(&ns->count);
+}
+
+static inline void put_cgroup_ns(struct cgroup_namespace *ns)
+{
+	if (ns && atomic_dec_and_test(&ns->count))
+		free_cgroup_ns(ns);
+}
+
 #endif /* _LINUX_CGROUP_H */
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 35fa08f..ac0d65b 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -8,6 +8,7 @@ struct mnt_namespace;
 struct uts_namespace;
 struct ipc_namespace;
 struct pid_namespace;
+struct cgroup_namespace;
 struct fs_struct;
 
 /*
@@ -33,6 +34,7 @@ struct nsproxy {
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns_for_children;
 	struct net 	     *net_ns;
+	struct cgroup_namespace *cgroup_ns;
 };
 extern struct nsproxy init_nsproxy;
 
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 42dfc61..de0e771 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -9,6 +9,8 @@
 struct pid_namespace;
 struct nsproxy;
 struct path;
+struct task_struct;
+struct inode;
 
 struct proc_ns_operations {
 	const char *name;
@@ -24,6 +26,7 @@ extern const struct proc_ns_operations ipcns_operations;
 extern const struct proc_ns_operations pidns_operations;
 extern const struct proc_ns_operations userns_operations;
 extern const struct proc_ns_operations mntns_operations;
+extern const struct proc_ns_operations cgroupns_operations;
 
 /*
  * We always define these enumerators
@@ -34,6 +37,7 @@ enum {
 	PROC_UTS_INIT_INO	= 0xEFFFFFFEU,
 	PROC_USER_INIT_INO	= 0xEFFFFFFDU,
 	PROC_PID_INIT_INO	= 0xEFFFFFFCU,
+	PROC_CGROUP_INIT_INO	= 0xEFFFFFFBU,
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c03a640..d828e1f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -58,6 +58,9 @@
 #include <linux/kthread.h>
 #include <linux/delay.h>
 #include <linux/atomic.h>
+#include <linux/proc_ns.h>
+#include <linux/nsproxy.h>
+#include <linux/proc_ns.h>
 #include <net/sock.h>
 
 /*
@@ -208,6 +211,15 @@ static unsigned long have_fork_callback __read_mostly;
 static unsigned long have_exit_callback __read_mostly;
 static unsigned long have_free_callback __read_mostly;
 
+/* Cgroup namespace for init task */
+struct cgroup_namespace init_cgroup_ns = {
+	.count		= { .counter = 2, },
+	.user_ns	= &init_user_ns,
+	.ns.ops		= &cgroupns_operations,
+	.ns.inum	= PROC_CGROUP_INIT_INO,
+	.root_cset	= &init_css_set,
+};
+
 /* Ditto for the can_fork callback. */
 static unsigned long have_canfork_callback __read_mostly;
 
@@ -2166,6 +2178,36 @@ static struct file_system_type cgroup2_fs_type = {
 	.kill_sb = cgroup_kill_sb,
 };
 
+static char *
+cgroup_path_ns_locked(struct cgroup *cgrp, char *buf, size_t buflen,
+		      struct cgroup_namespace *ns)
+{
+	int ret;
+	struct cgroup *root = cset_cgroup_from_root(ns->root_cset, cgrp->root);
+
+	ret = kernfs_path_from_node(cgrp->kn, root->kn, buf, buflen);
+	if (ret < 0 || ret >= buflen)
+		return NULL;
+	return buf;
+}
+
+char *cgroup_path_ns(struct cgroup *cgrp, char *buf, size_t buflen,
+		     struct cgroup_namespace *ns)
+{
+	char *ret;
+
+	mutex_lock(&cgroup_mutex);
+	spin_lock_bh(&css_set_lock);
+
+	ret = cgroup_path_ns_locked(cgrp, buf, buflen, ns);
+
+	spin_unlock_bh(&css_set_lock);
+	mutex_unlock(&cgroup_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cgroup_path_ns);
+
 /**
  * task_cgroup_path - cgroup path of a task in the first cgroup hierarchy
  * @task: target task
@@ -2193,7 +2235,8 @@ char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 
 	if (root) {
 		cgrp = task_cgroup_from_root(task, root);
-		path = cgroup_path(cgrp, buf, buflen);
+		path = cgroup_path_ns_locked(cgrp, buf, buflen,
+					     &init_cgroup_ns);
 	} else {
 		/* if no hierarchy exists, everyone is in "/" */
 		if (strlcpy(buf, "/", buflen) < buflen)
@@ -5272,6 +5315,8 @@ int __init cgroup_init(void)
 	BUG_ON(cgroup_init_cftypes(NULL, cgroup_dfl_base_files));
 	BUG_ON(cgroup_init_cftypes(NULL, cgroup_legacy_base_files));
 
+	get_user_ns(init_cgroup_ns.user_ns);
+
 	mutex_lock(&cgroup_mutex);
 
 	/* Add init_css_set to the hash table */
@@ -5409,7 +5454,8 @@ int proc_cgroup_show(struct seq_file *m, struct pid_namespace *ns,
 		 * " (deleted)" is appended to the cgroup path.
 		 */
 		if (cgroup_on_dfl(cgrp) || !(tsk->flags & PF_EXITING)) {
-			path = cgroup_path(cgrp, buf, PATH_MAX);
+			path = cgroup_path_ns_locked(cgrp, buf, PATH_MAX,
+						     current->nsproxy->cgroup_ns);
 			if (!path) {
 				retval = -ENAMETOOLONG;
 				goto out_unlock;
@@ -5691,7 +5737,10 @@ static void cgroup_release_agent(struct work_struct *work)
 	if (!pathbuf || !agentbuf)
 		goto out;
 
-	path = cgroup_path(cgrp, pathbuf, PATH_MAX);
+	spin_lock_bh(&css_set_lock);
+	path = cgroup_path_ns_locked(cgrp, pathbuf, PATH_MAX,
+				     &init_cgroup_ns);
+	spin_unlock_bh(&css_set_lock);
 	if (!path)
 		goto out;
 
@@ -5875,6 +5924,127 @@ void cgroup_sk_free(struct sock_cgroup_data *skcd)
 
 #endif	/* CONFIG_SOCK_CGROUP_DATA */
 
+/* cgroup namespaces */
+
+static struct cgroup_namespace *alloc_cgroup_ns(void)
+{
+	struct cgroup_namespace *new_ns;
+	int ret;
+
+	new_ns = kzalloc(sizeof(struct cgroup_namespace), GFP_KERNEL);
+	if (!new_ns)
+		return ERR_PTR(-ENOMEM);
+	ret = ns_alloc_inum(&new_ns->ns);
+	if (ret) {
+		kfree(new_ns);
+		return ERR_PTR(ret);
+	}
+	atomic_set(&new_ns->count, 1);
+	new_ns->ns.ops = &cgroupns_operations;
+	return new_ns;
+}
+
+void free_cgroup_ns(struct cgroup_namespace *ns)
+{
+	put_css_set(ns->root_cset);
+	put_user_ns(ns->user_ns);
+	ns_free_inum(&ns->ns);
+	kfree(ns);
+}
+EXPORT_SYMBOL(free_cgroup_ns);
+
+struct cgroup_namespace *
+copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
+	       struct cgroup_namespace *old_ns)
+{
+	struct cgroup_namespace *new_ns = NULL;
+	struct css_set *cset = NULL;
+	int err;
+
+	BUG_ON(!old_ns);
+
+	if (!(flags & CLONE_NEWCGROUP)) {
+		get_cgroup_ns(old_ns);
+		return old_ns;
+	}
+
+	/* Allow only sysadmin to create cgroup namespace. */
+	err = -EPERM;
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
+		goto err_out;
+
+	mutex_lock(&cgroup_mutex);
+	spin_lock_bh(&css_set_lock);
+
+	cset = task_css_set(current);
+	get_css_set(cset);
+
+	spin_unlock_bh(&css_set_lock);
+	mutex_unlock(&cgroup_mutex);
+
+	err = -ENOMEM;
+	new_ns = alloc_cgroup_ns();
+	if (!new_ns)
+		goto err_out;
+
+	new_ns->user_ns = get_user_ns(user_ns);
+	new_ns->root_cset = cset;
+
+	return new_ns;
+
+err_out:
+	if (cset)
+		put_css_set(cset);
+	kfree(new_ns);
+	return ERR_PTR(err);
+}
+
+static inline struct cgroup_namespace *to_cg_ns(struct ns_common *ns)
+{
+	return container_of(ns, struct cgroup_namespace, ns);
+}
+
+static int cgroupns_install(struct nsproxy *nsproxy, void *ns)
+{
+	pr_info("setns not supported for cgroup namespace");
+	return -EINVAL;
+}
+
+static struct ns_common *cgroupns_get(struct task_struct *task)
+{
+	struct cgroup_namespace *ns = NULL;
+	struct nsproxy *nsproxy;
+
+	task_lock(task);
+	nsproxy = task->nsproxy;
+	if (nsproxy) {
+		ns = nsproxy->cgroup_ns;
+		get_cgroup_ns(ns);
+	}
+	task_unlock(task);
+
+	return ns ? &ns->ns : NULL;
+}
+
+static void cgroupns_put(struct ns_common *ns)
+{
+	put_cgroup_ns(to_cg_ns(ns));
+}
+
+const struct proc_ns_operations cgroupns_operations = {
+	.name		= "cgroup",
+	.type		= CLONE_NEWCGROUP,
+	.get		= cgroupns_get,
+	.put		= cgroupns_put,
+	.install	= cgroupns_install,
+};
+
+static __init int cgroup_namespaces_init(void)
+{
+	return 0;
+}
+subsys_initcall(cgroup_namespaces_init);
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *
 debug_css_alloc(struct cgroup_subsys_state *parent_css)
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3e945fc..62d6108 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2687,10 +2687,10 @@ int proc_cpuset_show(struct seq_file *m, struct pid_namespace *ns,
 		goto out;
 
 	retval = -ENAMETOOLONG;
-	rcu_read_lock();
-	css = task_css(tsk, cpuset_cgrp_id);
-	p = cgroup_path(css->cgroup, buf, PATH_MAX);
-	rcu_read_unlock();
+	css = task_get_css(tsk, cpuset_cgrp_id);
+	p = cgroup_path_ns(css->cgroup, buf, PATH_MAX,
+			   current->nsproxy->cgroup_ns);
+	css_put(css);
 	if (!p)
 		goto out_free;
 	seq_puts(m, p);
diff --git a/kernel/fork.c b/kernel/fork.c
index 2e391c7..6611a62 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1884,7 +1884,7 @@ static int check_unshare_flags(unsigned long unshare_flags)
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
 				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
-				CLONE_NEWUSER|CLONE_NEWPID))
+				CLONE_NEWUSER|CLONE_NEWPID|CLONE_NEWCGROUP))
 		return -EINVAL;
 	/*
 	 * Not implemented, but pretend it works if there is nothing
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 49746c8..782102e 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -25,6 +25,7 @@
 #include <linux/proc_ns.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
+#include <linux/cgroup.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -39,6 +40,9 @@ struct nsproxy init_nsproxy = {
 #ifdef CONFIG_NET
 	.net_ns			= &init_net,
 #endif
+#ifdef CONFIG_CGROUPS
+	.cgroup_ns		= &init_cgroup_ns,
+#endif
 };
 
 static inline struct nsproxy *create_nsproxy(void)
@@ -92,6 +96,13 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_pid;
 	}
 
+	new_nsp->cgroup_ns = copy_cgroup_ns(flags, user_ns,
+					    tsk->nsproxy->cgroup_ns);
+	if (IS_ERR(new_nsp->cgroup_ns)) {
+		err = PTR_ERR(new_nsp->cgroup_ns);
+		goto out_cgroup;
+	}
+
 	new_nsp->net_ns = copy_net_ns(flags, user_ns, tsk->nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
 		err = PTR_ERR(new_nsp->net_ns);
@@ -101,6 +112,8 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	return new_nsp;
 
 out_net:
+	put_cgroup_ns(new_nsp->cgroup_ns);
+out_cgroup:
 	if (new_nsp->pid_ns_for_children)
 		put_pid_ns(new_nsp->pid_ns_for_children);
 out_pid:
@@ -128,7 +141,8 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	struct nsproxy *new_ns;
 
 	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			      CLONE_NEWPID | CLONE_NEWNET)))) {
+			      CLONE_NEWPID | CLONE_NEWNET |
+			      CLONE_NEWCGROUP)))) {
 		get_nsproxy(old_ns);
 		return 0;
 	}
@@ -165,6 +179,7 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns_for_children)
 		put_pid_ns(ns->pid_ns_for_children);
+	put_cgroup_ns(ns->cgroup_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
@@ -180,7 +195,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWNET | CLONE_NEWPID)))
+			       CLONE_NEWNET | CLONE_NEWPID | CLONE_NEWCGROUP)))
 		return 0;
 
 	user_ns = new_cred ? new_cred->user_ns : current_user_ns();
-- 
1.7.9.5
