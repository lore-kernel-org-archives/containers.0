From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 09/11] pidns: Add setns support
Date: Fri, 16 Nov 2012 08:35:48 -0800
Message-ID: <1353083750-3621-9-git-send-email-ebiederm@xmission.com>
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

- Pid namespaces are designed to be inescapable so verify that the
  passed in pid namespace is a child of the currently active
  pid namespace or the currently active pid namespace itself.

  Allowing the currently active pid namespace is important so
  the effects of an earlier setns can be cancelled.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/namespaces.c    |    3 ++
 include/linux/proc_fs.h |    1 +
 kernel/pid_namespace.c  |   54 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index b178ed7..85ca047 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -24,6 +24,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_IPC_NS
 	&ipcns_operations,
 #endif
+#ifdef CONFIG_PID_NS
+	&pidns_operations,
+#endif
 };
 
 static const struct file_operations ns_file_operations = {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 3fd2e87..acaafcd 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -251,6 +251,7 @@ struct proc_ns_operations {
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
 extern const struct proc_ns_operations ipcns_operations;
+extern const struct proc_ns_operations pidns_operations;
 
 union proc_op {
 	int (*proc_get_link)(struct dentry *, struct path *);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 066c058..c6514f5 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -300,6 +300,60 @@ int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
 	return 0;
 }
 
+static void *pidns_get(struct task_struct *task)
+{
+	struct pid_namespace *ns;
+
+	rcu_read_lock();
+	ns = get_pid_ns(task_active_pid_ns(task));
+	rcu_read_unlock();
+
+	return ns;
+}
+
+static void pidns_put(void *ns)
+{
+	put_pid_ns(ns);
+}
+
+static int pidns_install(struct nsproxy *nsproxy, void *ns)
+{
+	struct pid_namespace *active = task_active_pid_ns(current);
+	struct pid_namespace *ancestor, *new = ns;
+
+	if (!ns_capable(new->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	/*
+	 * Only allow entering the current active pid namespace
+	 * or a child of the current active pid namespace.
+	 *
+	 * This is required for fork to return a usable pid value and
+	 * this maintains the property that processes and their
+	 * children can not escape their current pid namespace.
+	 */
+	if (new->level < active->level)
+		return -EINVAL;
+
+	ancestor = new;
+	while (ancestor->level > active->level)
+		ancestor = ancestor->parent;
+	if (ancestor != active)
+		return -EINVAL;
+
+	put_pid_ns(nsproxy->pid_ns);
+	nsproxy->pid_ns = get_pid_ns(new);
+	return 0;
+}
+
+const struct proc_ns_operations pidns_operations = {
+	.name		= "pid",
+	.type		= CLONE_NEWPID,
+	.get		= pidns_get,
+	.put		= pidns_put,
+	.install	= pidns_install,
+};
+
 static __init int pid_namespaces_init(void)
 {
 	pid_ns_cachep = KMEM_CACHE(pid_namespace, SLAB_PANIC);
-- 
1.7.5.4
