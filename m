From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 1/3] Save dump_root into pid_namespace
Date: Tue, 7 Jun 2016 19:29:35 +0800
Message-ID: <2c239efa286e79a732e912fe2eed690a68fa9d3e.1465293010.git.zhaolei@cn.fujitsu.com>
References: <cover.1465293010.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1465293010.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

In current system, when we set core_pattern to a pipe, both pipe program
and program's output are in host's filesystem.
But when we set core_pattern to a file, the container will write dump
into container's filesystem.

Reason of above different is:
In pipe_mode dump_pattern setting, the process who write the dumpfile
is a kernel thread, whose fs_root always point to host's root fs.

This patch save the dump_root into pid_namespace, and when a crach
happened in container, this dump_root can be used as fs_root of
dump_writter_thread.

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/pid_namespace.h |  3 +++
 kernel/pid.c                  |  1 +
 kernel/pid_namespace.c        |  6 ++++++
 kernel/sysctl.c               | 33 +++++++++++++++++++++++++++++----
 4 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 918b117..535a532 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/kref.h>
 #include <linux/ns_common.h>
+#include <linux/path.h>
 
 struct pidmap {
        atomic_t nr_free;
@@ -45,6 +46,8 @@ struct pid_namespace {
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
 	struct ns_common ns;
+	spinlock_t root_for_dump_lock;
+	struct path root_for_dump;
 };
 
 extern struct pid_namespace init_pid_ns;
diff --git a/kernel/pid.c b/kernel/pid.c
index f66162f..ef4cd85 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -83,6 +83,7 @@ struct pid_namespace init_pid_ns = {
 #ifdef CONFIG_PID_NS
 	.ns.ops = &pidns_operations,
 #endif
+	.root_for_dump_lock = __SPIN_LOCK_UNLOCKED(init_pid_ns.root_for_dump_lock),
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a65ba13..3d0eced 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -123,6 +123,8 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
+	spin_lock_init(&ns->root_for_dump_lock);
+
 	return ns;
 
 out_free_map:
@@ -147,6 +149,10 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	put_user_ns(ns->user_ns);
+
+	if (ns->root_for_dump.mnt)
+		path_put(&ns->root_for_dump);
+
 	call_rcu(&ns->rcu, delayed_free_pidns);
 }
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 87b2fc3..0e82b2f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -65,6 +65,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/kexec.h>
 #include <linux/bpf.h>
+#include <linux/fs_struct.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -2372,10 +2373,34 @@ static int proc_dointvec_minmax_coredump(struct ctl_table *table, int write,
 static int proc_dostring_coredump(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int error = proc_dostring(table, write, buffer, lenp, ppos);
-	if (!error)
-		validate_coredump_safety();
-	return error;
+	struct pid_namespace *pid_ns;
+	struct path old_path;
+	int error;
+
+	error = proc_dostring(table, write, buffer, lenp, ppos);
+	if (error)
+		return error;
+
+	pid_ns = task_active_pid_ns(current);
+	if (WARN_ON(!pid_ns))
+		return -EINVAL;
+
+	spin_lock(&pid_ns->root_for_dump_lock);
+
+	old_path = pid_ns->root_for_dump;
+
+	spin_lock(&current->fs->lock);
+	pid_ns->root_for_dump = current->fs->root;
+	path_get(&pid_ns->root_for_dump);
+	spin_unlock(&current->fs->lock);
+
+	spin_unlock(&pid_ns->root_for_dump_lock);
+
+	if (old_path.mnt)
+		path_put(&old_path);
+
+	validate_coredump_safety();
+	return 0;
 }
 #endif
 
-- 
1.8.5.1
