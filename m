From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] add pid->user_ns
Date: Thu, 11 Aug 2011 13:40:17 -0500
Message-ID: <20110811184017.GA13356__25691.5811951787$1313088067$gmane$org@peqn>
References: <4E4051A0.8030009@free.fr> <20110810221028.2e0c8590@neptune.home>
	<4E42EEE3.9050608@free.fr> <20110811183027.49275b2d@neptune.home>
	<4E44082F.6040606@free.fr> <20110811190456.77ff9280@neptune.home>
	<20110811181022.GA12307@peqn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110811181022.GA12307@peqn>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: daniel@peqn, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eric@peqn, LXC Development <Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

[ Here is the patch which you'd need to be able to add the boot
check against pid_ns ]

This will allow us to check whether a task has privilege over the
pid namespace.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/pid_namespace.h |    9 +++++++--
 kernel/nsproxy.c              |    2 +-
 kernel/pid.c                  |    1 +
 kernel/pid_namespace.c        |   13 ++++++++++---
 4 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 38d1032..c1b5a48 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -7,6 +7,9 @@
 #include <linux/nsproxy.h>
 #include <linux/kref.h>
 
+struct user_namespace;
+extern struct user_namespace init_user_ns;
+
 struct pidmap {
        atomic_t nr_free;
        void *page;
@@ -30,6 +33,7 @@ struct pid_namespace {
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
 #endif
+	struct user_namespace *user_ns;
 };
 
 extern struct pid_namespace init_pid_ns;
@@ -42,7 +46,7 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 	return ns;
 }
 
-extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
+extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct task_struct *tsk);
 extern void free_pid_ns(struct kref *kref);
 extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
 
@@ -61,8 +65,9 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 }
 
 static inline struct pid_namespace *
-copy_pid_ns(unsigned long flags, struct pid_namespace *ns)
+copy_pid_ns(unsigned long flags, struct task_struct *tsk)
 {
+	struct pid_namespace *ns = task_active_pid_ns(tsk);
 	if (flags & CLONE_NEWPID)
 		ns = ERR_PTR(-EINVAL);
 	return ns;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 9aeab4b..97e21ea 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -84,7 +84,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_ipc;
 	}
 
-	new_nsp->pid_ns = copy_pid_ns(flags, task_active_pid_ns(tsk));
+	new_nsp->pid_ns = copy_pid_ns(flags, tsk);
 	if (IS_ERR(new_nsp->pid_ns)) {
 		err = PTR_ERR(new_nsp->pid_ns);
 		goto out_pid;
diff --git a/kernel/pid.c b/kernel/pid.c
index e432057..4a1e66f 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -78,6 +78,7 @@ struct pid_namespace init_pid_ns = {
 	.last_pid = 0,
 	.level = 0,
 	.child_reaper = &init_task,
+	.user_ns = &init_user_ns,
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index e9c9adc..6818ea5 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -10,6 +10,7 @@
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -69,7 +70,8 @@ err_alloc:
 	return NULL;
 }
 
-static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_pid_ns)
+static struct pid_namespace *create_pid_namespace(struct task_struct *tsk,
+			struct pid_namespace *parent_pid_ns)
 {
 	struct pid_namespace *ns;
 	unsigned int level = parent_pid_ns->level + 1;
@@ -97,6 +99,8 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
+
 	err = pid_ns_prepare_proc(ns);
 	if (err)
 		goto out_put_parent_pid_ns;
@@ -122,13 +126,15 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 	kmem_cache_free(pid_ns_cachep, ns);
 }
 
-struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
+struct pid_namespace *copy_pid_ns(unsigned long flags, struct task_struct *tsk)
 {
+	struct pid_namespace *old_ns = task_active_pid_ns(tsk);
+
 	if (!(flags & CLONE_NEWPID))
 		return get_pid_ns(old_ns);
 	if (flags & (CLONE_THREAD|CLONE_PARENT))
 		return ERR_PTR(-EINVAL);
-	return create_pid_namespace(old_ns);
+	return create_pid_namespace(tsk, old_ns);
 }
 
 void free_pid_ns(struct kref *kref)
@@ -139,6 +145,7 @@ void free_pid_ns(struct kref *kref)
 
 	parent = ns->parent;
 	destroy_pid_namespace(ns);
+	put_user_ns(ns->user_ns);
 
 	if (parent != NULL)
 		put_pid_ns(parent);
-- 
1.7.5.4
