From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 04/11] pidns: Use task_active_pid_ns where appropriate
Date: Fri, 16 Nov 2012 08:35:43 -0800
Message-ID: <1353083750-3621-4-git-send-email-ebiederm@xmission.com>
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

The expressions tsk->nsproxy->pid_ns and task_active_pid_ns
aka ns_of_pid(task_pid(tsk)) should have the same number of
cache line misses with the practical difference that
ns_of_pid(task_pid(tsk)) is released later in a processes life.

Furthermore by using task_active_pid_ns it becomes trivial
to write an unshare implementation for the the pid namespace.

So I have used task_active_pid_ns everywhere I can.

In fork since the pid has not yet been attached to the
process I use ns_of_pid, to achieve the same effect.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/powerpc/platforms/cell/spufs/sched.c |    2 +-
 arch/um/drivers/mconsole_kern.c           |    2 +-
 drivers/staging/android/binder.c          |    3 ++-
 fs/hppfs/hppfs.c                          |    2 +-
 fs/proc/root.c                            |    2 +-
 kernel/cgroup.c                           |    2 +-
 kernel/events/core.c                      |    2 +-
 kernel/fork.c                             |    2 +-
 kernel/nsproxy.c                          |    2 +-
 kernel/pid.c                              |    8 ++++----
 kernel/signal.c                           |    2 +-
 kernel/sysctl_binary.c                    |    2 +-
 12 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index 965d381..25db92a 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -1094,7 +1094,7 @@ static int show_spu_loadavg(struct seq_file *s, void *private)
 		LOAD_INT(c), LOAD_FRAC(c),
 		count_active_contexts(),
 		atomic_read(&nr_spu_contexts),
-		current->nsproxy->pid_ns->last_pid);
+		task_active_pid_ns(current)->last_pid);
 	return 0;
 }
 
diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_kern.c
index 79ccfe6..7fc71c6 100644
--- a/arch/um/drivers/mconsole_kern.c
+++ b/arch/um/drivers/mconsole_kern.c
@@ -123,7 +123,7 @@ void mconsole_log(struct mc_request *req)
 
 void mconsole_proc(struct mc_request *req)
 {
-	struct vfsmount *mnt = current->nsproxy->pid_ns->proc_mnt;
+	struct vfsmount *mnt = task_active_pid_ns(current)->proc_mnt;
 	char *buf;
 	int len;
 	struct file *file;
diff --git a/drivers/staging/android/binder.c b/drivers/staging/android/binder.c
index 5d4610b..a97bbcd 100644
--- a/drivers/staging/android/binder.c
+++ b/drivers/staging/android/binder.c
@@ -33,6 +33,7 @@
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
+#include <linux/pid_namespace.h>
 
 #include "binder.h"
 
@@ -2344,7 +2345,7 @@ retry:
 		if (t->from) {
 			struct task_struct *sender = t->from->proc->tsk;
 			tr.sender_pid = task_tgid_nr_ns(sender,
-							current->nsproxy->pid_ns);
+							task_active_pid_ns(current));
 		} else {
 			tr.sender_pid = 0;
 		}
diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
index 78f21f8..43b315f 100644
--- a/fs/hppfs/hppfs.c
+++ b/fs/hppfs/hppfs.c
@@ -710,7 +710,7 @@ static int hppfs_fill_super(struct super_block *sb, void *d, int silent)
 	struct vfsmount *proc_mnt;
 	int err = -ENOENT;
 
-	proc_mnt = mntget(current->nsproxy->pid_ns->proc_mnt);
+	proc_mnt = mntget(task_active_pid_ns(current)->proc_mnt);
 	if (IS_ERR(proc_mnt))
 		goto out;
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 13ef624..fc16093 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -106,7 +106,7 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 		ns = (struct pid_namespace *)data;
 		options = NULL;
 	} else {
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 		options = data;
 	}
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f24f724..0dbfba2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3390,7 +3390,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 {
 	struct cgroup_pidlist *l;
 	/* don't need task_nsproxy() if we're looking at ourself */
-	struct pid_namespace *ns = current->nsproxy->pid_ns;
+	struct pid_namespace *ns = task_active_pid_ns(current);
 
 	/*
 	 * We can't drop the pidlist_mutex before taking the l->mutex in case
diff --git a/kernel/events/core.c b/kernel/events/core.c
index dbccf83..738f356 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6155,7 +6155,7 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
 
 	event->parent		= parent_event;
 
-	event->ns		= get_pid_ns(current->nsproxy->pid_ns);
+	event->ns		= get_pid_ns(task_active_pid_ns(current));
 	event->id		= atomic64_inc_return(&perf_event_id);
 
 	event->state		= PERF_EVENT_STATE_INACTIVE;
diff --git a/kernel/fork.c b/kernel/fork.c
index 8b20ab7..7798c24 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1442,7 +1442,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 		if (thread_group_leader(p)) {
 			if (is_child_reaper(pid))
-				p->nsproxy->pid_ns->child_reaper = p;
+				ns_of_pid(pid)->child_reaper = p;
 
 			p->signal->leader_pid = pid;
 			p->signal->tty = tty_kref_get(current->signal->tty);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 5fe88e1..cf37d52 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -84,7 +84,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_ipc;
 	}
 
-	new_nsp->pid_ns = copy_pid_ns(flags, task_cred_xxx(tsk, user_ns), task_active_pid_ns(tsk));
+	new_nsp->pid_ns = copy_pid_ns(flags, task_cred_xxx(tsk, user_ns), tsk->nsproxy->pid_ns);
 	if (IS_ERR(new_nsp->pid_ns)) {
 		err = PTR_ERR(new_nsp->pid_ns);
 		goto out_pid;
diff --git a/kernel/pid.c b/kernel/pid.c
index 2a624f1..3a5f238 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -345,7 +345,7 @@ EXPORT_SYMBOL_GPL(find_pid_ns);
 
 struct pid *find_vpid(int nr)
 {
-	return find_pid_ns(nr, current->nsproxy->pid_ns);
+	return find_pid_ns(nr, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(find_vpid);
 
@@ -429,7 +429,7 @@ struct task_struct *find_task_by_pid_ns(pid_t nr, struct pid_namespace *ns)
 
 struct task_struct *find_task_by_vpid(pid_t vnr)
 {
-	return find_task_by_pid_ns(vnr, current->nsproxy->pid_ns);
+	return find_task_by_pid_ns(vnr, task_active_pid_ns(current));
 }
 
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
@@ -484,7 +484,7 @@ EXPORT_SYMBOL_GPL(pid_nr_ns);
 
 pid_t pid_vnr(struct pid *pid)
 {
-	return pid_nr_ns(pid, current->nsproxy->pid_ns);
+	return pid_nr_ns(pid, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(pid_vnr);
 
@@ -495,7 +495,7 @@ pid_t __task_pid_nr_ns(struct task_struct *task, enum pid_type type,
 
 	rcu_read_lock();
 	if (!ns)
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 	if (likely(pid_alive(task))) {
 		if (type != PIDTYPE_PID)
 			task = task->group_leader;
diff --git a/kernel/signal.c b/kernel/signal.c
index 0af8868..b2445d8 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1752,7 +1752,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk,
 	 * see comment in do_notify_parent() about the following 4 lines
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(parent));
 	info.si_uid = from_kuid_munged(task_cred_xxx(parent, user_ns), task_uid(tsk));
 	rcu_read_unlock();
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 65bdcf1..5a63844 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -1344,7 +1344,7 @@ static ssize_t binary_sysctl(const int *name, int nlen,
 		goto out_putname;
 	}
 
-	mnt = current->nsproxy->pid_ns->proc_mnt;
+	mnt = task_active_pid_ns(current)->proc_mnt;
 	file = file_open_root(mnt->mnt_root, mnt, pathname, flags);
 	result = PTR_ERR(file);
 	if (IS_ERR(file))
-- 
1.7.5.4
