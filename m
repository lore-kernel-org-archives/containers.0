From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 1/1][v2] Add reboot_pid_ns to handle the reboot syscall
Date: Sun,  4 Dec 2011 00:51:20 +0100
Message-ID: <1322956280-13831-2-git-send-email-daniel.lezcano@free.fr>
References: <1322956280-13831-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1322956280-13831-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

In the case of a child pid namespace, rebooting the system does not
really makes sense. When the pid namespace is used in conjunction
with the other namespaces in order to create a linux container, the
reboot syscall leads to some problems.

A container can reboot the host. That can be fixed by dropping
the sys_reboot capability but we are unable to correctly to poweroff/
halt/reboot a container and the container stays stuck at the shutdown
time with the container's init process waiting indefinitively.

After several attempts, no solution from userspace was found to reliabily
handle the shutdown from a container.

This patch propose to store the reboot value in the 16 upper bits of the
exit code from the processes belonging to a pid namespace which has
rebooted. When the reboot syscall is called and we are not in the initial
pid namespace, we kill the pid namespace.

By this way the parent process of the child pid namespace to know if
it rebooted or not and take the right decision.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/pid_namespace.h |    9 ++++++-
 kernel/pid_namespace.c        |   54 +++++++++++++++++++++++++++++++++++++++++
 kernel/sys.c                  |    3 ++
 3 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index e7cf666..f5f1f60 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -32,6 +32,8 @@ struct pid_namespace {
 #endif
 	gid_t pid_gid;
 	int hide_pid;
+	int reboot;
+	spinlock_t reboot_lock;
 };
 
 extern struct pid_namespace init_pid_ns;
@@ -47,6 +49,7 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
 extern void free_pid_ns(struct kref *kref);
 extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
+extern int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd);
 
 static inline void put_pid_ns(struct pid_namespace *ns)
 {
@@ -74,11 +77,15 @@ static inline void put_pid_ns(struct pid_namespace *ns)
 {
 }
 
-
 static inline void zap_pid_ns_processes(struct pid_namespace *ns)
 {
 	BUG();
 }
+
+static inline int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
+{
+	BUG();
+}
 #endif /* CONFIG_PID_NS */
 
 extern struct pid_namespace *task_active_pid_ns(struct task_struct *tsk);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a896839..a1fe60c 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -15,6 +15,7 @@
 #include <linux/acct.h>
 #include <linux/slab.h>
 #include <linux/proc_fs.h>
+#include <linux/reboot.h>
 
 #define BITS_PER_PAGE		(PAGE_SIZE*8)
 
@@ -90,6 +91,7 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 	kref_init(&ns->kref);
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
+	spin_lock_init(&ns->reboot_lock);
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
@@ -187,6 +189,9 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 		rc = sys_wait4(-1, NULL, __WALL, NULL);
 	} while (rc != -ECHILD);
 
+	if (pid_ns->reboot)
+		current->signal->group_exit_code = pid_ns->reboot;
+
 	acct_exit_ns(pid_ns);
 	return;
 }
@@ -221,6 +226,55 @@ static struct ctl_table pid_ns_ctl_table[] = {
 
 static struct ctl_path kern_path[] = { { .procname = "kernel", }, { } };
 
+static inline int __reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
+{
+	/* A reboot already occured, just ignore this request
+	 * all the processes of the pid namespace will be killed
+	 * by the previous 'reboot' call
+	 */
+	if (pid_ns->reboot)
+		return -EBUSY;
+
+	switch(cmd) {
+	case LINUX_REBOOT_CMD_RESTART2:
+	case LINUX_REBOOT_CMD_RESTART:
+		pid_ns->reboot = SYSTEM_RESTART << 16;
+		break;
+
+	case LINUX_REBOOT_CMD_HALT:
+		pid_ns->reboot = SYSTEM_HALT << 16;
+		break;
+
+	case LINUX_REBOOT_CMD_POWER_OFF:
+		pid_ns->reboot = SYSTEM_POWER_OFF << 16;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int reboot_pid_ns(struct pid_namespace *pid_ns, int cmd)
+{
+	int ret;
+
+	spin_lock(&pid_ns->reboot_lock);
+	ret = __reboot_pid_ns(pid_ns, cmd);
+	spin_unlock(&pid_ns->reboot_lock);
+	if (ret)
+		goto out;
+
+	read_lock(&tasklist_lock);
+	force_sig(SIGKILL, pid_ns->child_reaper);
+	read_unlock(&tasklist_lock);
+
+	do_exit(0);
+	/* Not reached */
+out:
+	return ret;
+}
+
 static __init int pid_namespaces_init(void)
 {
 	pid_ns_cachep = KMEM_CACHE(pid_namespace, SLAB_PANIC);
diff --git a/kernel/sys.c b/kernel/sys.c
index ddf8155..31acf63 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -444,6 +444,9 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
 	                magic2 != LINUX_REBOOT_MAGIC2C))
 		return -EINVAL;
 
+	if (task_active_pid_ns(current) != &init_pid_ns)
+		return reboot_pid_ns(task_active_pid_ns(current), cmd);
+
 	/* Instead of trying to make the power_off code look like
 	 * halt when pm_power_off is not set do it the easy way.
 	 */
-- 
1.7.5.4
