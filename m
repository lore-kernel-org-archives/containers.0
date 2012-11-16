From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/11] pidns: Capture the user namespace and filter ns_last_pid
Date: Fri, 16 Nov 2012 08:35:42 -0800
Message-ID: <1353083750-3621-3-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Capture the the user namespace that creates the pid namespace
- Use that user namespace to test if it is ok to write to
  /proc/sys/kernel/ns_last_pid.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/pid_namespace.h |    8 +++++---
 kernel/nsproxy.c              |    2 +-
 kernel/pid.c                  |    1 +
 kernel/pid_namespace.c        |   16 +++++++++++-----
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 65e3e87..c89c9cf 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -31,6 +31,7 @@ struct pid_namespace {
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
 #endif
+	struct user_namespace *user_ns;
 	kgid_t pid_gid;
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
@@ -46,7 +47,8 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 	return ns;
 }
 
-extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
+extern struct pid_namespace *copy_pid_ns(unsigned long flags,
+	struct user_namespace *user_ns, struct pid_namespace *ns);
 extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
 extern int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd);
 extern void put_pid_ns(struct pid_namespace *ns);
@@ -59,8 +61,8 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 	return ns;
 }
 
-static inline struct pid_namespace *
-copy_pid_ns(unsigned long flags, struct pid_namespace *ns)
+static inline struct pid_namespace *copy_pid_ns(unsigned long flags,
+	struct user_namespace *user_ns, struct pid_namespace *ns)
 {
 	if (flags & CLONE_NEWPID)
 		ns = ERR_PTR(-EINVAL);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b576f7f..5fe88e1 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -84,7 +84,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_ipc;
 	}
 
-	new_nsp->pid_ns = copy_pid_ns(flags, task_active_pid_ns(tsk));
+	new_nsp->pid_ns = copy_pid_ns(flags, task_cred_xxx(tsk, user_ns), task_active_pid_ns(tsk));
 	if (IS_ERR(new_nsp->pid_ns)) {
 		err = PTR_ERR(new_nsp->pid_ns);
 		goto out_pid;
diff --git a/kernel/pid.c b/kernel/pid.c
index aebd4f5..2a624f1 100644
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
index 7b07cc0..7580aa0 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -10,6 +10,7 @@
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -74,7 +75,8 @@ err_alloc:
 /* MAX_PID_NS_LEVEL is needed for limiting size of 'struct pid' */
 #define MAX_PID_NS_LEVEL 32
 
-static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_pid_ns)
+static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns,
+	struct pid_namespace *parent_pid_ns)
 {
 	struct pid_namespace *ns;
 	unsigned int level = parent_pid_ns->level + 1;
@@ -102,6 +104,7 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 	kref_init(&ns->kref);
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
+	ns->user_ns = get_user_ns(user_ns);
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
@@ -117,6 +120,7 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 
 out_put_parent_pid_ns:
 	put_pid_ns(parent_pid_ns);
+	put_user_ns(user_ns);
 out_free_map:
 	kfree(ns->pidmap[0].page);
 out_free:
@@ -134,13 +138,14 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 	kmem_cache_free(pid_ns_cachep, ns);
 }
 
-struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
+struct pid_namespace *copy_pid_ns(unsigned long flags,
+	struct user_namespace *user_ns, struct pid_namespace *old_ns)
 {
 	if (!(flags & CLONE_NEWPID))
 		return get_pid_ns(old_ns);
 	if (flags & (CLONE_THREAD|CLONE_PARENT))
 		return ERR_PTR(-EINVAL);
-	return create_pid_namespace(old_ns);
+	return create_pid_namespace(user_ns, old_ns);
 }
 
 static void free_pid_ns(struct kref *kref)
@@ -239,9 +244,10 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 static int pid_ns_ctl_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct pid_namespace *pid_ns = task_active_pid_ns(current);
 	struct ctl_table tmp = *table;
 
-	if (write && !capable(CAP_SYS_ADMIN))
+	if (write && !ns_capable(pid_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/*
@@ -250,7 +256,7 @@ static int pid_ns_ctl_handler(struct ctl_table *table, int write,
 	 * it should synchronize its usage with external means.
 	 */
 
-	tmp.data = &current->nsproxy->pid_ns->last_pid;
+	tmp.data = &pid_ns->last_pid;
 	return proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 }
 
-- 
1.7.5.4
