From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 4/4] pidns: Use task_active_pid_ns where appropriate
Date: Mon, 31 Jan 2011 11:25:25 +0100
Message-ID: <1296469525-30111-5-git-send-email-daniel.lezcano__5219.46478770605$1296470352$gmane$org@free.fr>
References: <1296469525-30111-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296469525-30111-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The expressions tsk->nsproxy->pid_ns and task_active_pid_ns
aka ns_of_pid(task_pid(tsk)) should have the same number of
cache line misses with the practical difference that
ns_of_pid(task_pid(tsk)) is released later in a processes life.

Furthermore by using task_active_pid_ns it becomes trivial
to write an unshare implementation for the the pid namespace.

So I have used task_active_pid_ns everywhere I can.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 arch/powerpc/platforms/cell/spufs/sched.c |    2 +-
 arch/um/drivers/mconsole_kern.c           |    2 +-
 fs/proc/root.c                            |    2 +-
 kernel/cgroup.c                           |    3 +--
 kernel/perf_event.c                       |    2 +-
 kernel/pid.c                              |    8 ++++----
 kernel/signal.c                           |    9 ++++-----
 kernel/sysctl_binary.c                    |    2 +-
 8 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index 0b04662..82e26a0 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -1095,7 +1095,7 @@ static int show_spu_loadavg(struct seq_file *s, void *private)
 		LOAD_INT(c), LOAD_FRAC(c),
 		count_active_contexts(),
 		atomic_read(&nr_spu_contexts),
-		current->nsproxy->pid_ns->last_pid);
+		task_active_pid_ns(current)->last_pid);
 	return 0;
 }
 
diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_kern.c
index 975613b..edac0da 100644
--- a/arch/um/drivers/mconsole_kern.c
+++ b/arch/um/drivers/mconsole_kern.c
@@ -125,7 +125,7 @@ void mconsole_log(struct mc_request *req)
 void mconsole_proc(struct mc_request *req)
 {
 	struct nameidata nd;
-	struct vfsmount *mnt = current->nsproxy->pid_ns->proc_mnt;
+	struct vfsmount *mnt = task_active_pid_ns(current)->proc_mnt;
 	struct file *file;
 	int n, err;
 	char *ptr = req->request.data, *buf;
diff --git a/fs/proc/root.c b/fs/proc/root.c
index a9000e9..9ea237e 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -46,7 +46,7 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 	if (flags & MS_KERNMOUNT)
 		ns = (struct pid_namespace *)data;
 	else
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 
 	sb = sget(fs_type, proc_test_super, proc_set_super, ns);
 	if (IS_ERR(sb))
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b24d702..5cb4ae7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2741,8 +2741,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 {
 	struct cgroup_pidlist *l;
 	/* don't need task_nsproxy() if we're looking at ourself */
-	struct pid_namespace *ns = current->nsproxy->pid_ns;
-
+	struct pid_namespace *ns = task_active_pid_ns(current);
 	/*
 	 * We can't drop the pidlist_mutex before taking the l->mutex in case
 	 * the last ref-holder is trying to remove l from the list at the same
diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index 852ae8c..42bdb40 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -5581,7 +5581,7 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
 
 	event->parent		= parent_event;
 
-	event->ns		= get_pid_ns(current->nsproxy->pid_ns);
+	event->ns		= get_pid_ns(task_active_pid_ns(current));
 	event->id		= atomic64_inc_return(&perf_event_id);
 
 	event->state		= PERF_EVENT_STATE_INACTIVE;
diff --git a/kernel/pid.c b/kernel/pid.c
index 39b65b6..b45189d 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -339,7 +339,7 @@ EXPORT_SYMBOL_GPL(find_pid_ns);
 
 struct pid *find_vpid(int nr)
 {
-	return find_pid_ns(nr, current->nsproxy->pid_ns);
+	return find_pid_ns(nr, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(find_vpid);
 
@@ -422,7 +422,7 @@ struct task_struct *find_task_by_pid_ns(pid_t nr, struct pid_namespace *ns)
 
 struct task_struct *find_task_by_vpid(pid_t vnr)
 {
-	return find_task_by_pid_ns(vnr, current->nsproxy->pid_ns);
+	return find_task_by_pid_ns(vnr, task_active_pid_ns(current));
 }
 
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
@@ -474,7 +474,7 @@ pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
 
 pid_t pid_vnr(struct pid *pid)
 {
-	return pid_nr_ns(pid, current->nsproxy->pid_ns);
+	return pid_nr_ns(pid, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(pid_vnr);
 
@@ -485,7 +485,7 @@ pid_t __task_pid_nr_ns(struct task_struct *task, enum pid_type type,
 
 	rcu_read_lock();
 	if (!ns)
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 	if (likely(pid_alive(task))) {
 		if (type != PIDTYPE_PID)
 			task = task->group_leader;
diff --git a/kernel/signal.c b/kernel/signal.c
index 4e3cff1..6f10e78 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1462,16 +1462,15 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	 * we are under tasklist_lock here so our parent is tied to
 	 * us and cannot exit and release its namespace.
 	 *
-	 * the only it can is to switch its nsproxy with sys_unshare,
-	 * bu uncharing pid namespaces is not allowed, so we'll always
-	 * see relevant namespace
+	 * The only it can is to switch its nsproxy with sys_unshare,
+	 * but we use the pid_namespace for task_pid which never changes.
 	 *
 	 * write_lock() currently calls preempt_disable() which is the
 	 * same as rcu_read_lock(), but according to Oleg, this is not
 	 * correct to rely on this
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(tsk->parent));
 	info.si_uid = __task_cred(tsk)->uid;
 	rcu_read_unlock();
 
@@ -1542,7 +1541,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 	 * see comment in do_notify_parent() abot the following 3 lines
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(parent));
 	info.si_uid = __task_cred(tsk)->uid;
 	rcu_read_unlock();
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index b875bed..88c69d5 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -1349,7 +1349,7 @@ static ssize_t binary_sysctl(const int *name, int nlen,
 		goto out_putname;
 	}
 
-	mnt = current->nsproxy->pid_ns->proc_mnt;
+	mnt = task_active_pid_ns(current)->proc_mnt;
 	result = vfs_path_lookup(mnt->mnt_root, mnt, pathname, 0, &nd);
 	if (result)
 		goto out_putname;
-- 
1.7.1
