From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/6] pidns: Use task_active_pid_ns where appropriate
Date: Sun, 20 Jun 2010 01:48:07 -0700
Message-ID: <m11vc2qed4.fsf_-_@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
	<m1pqzmqema.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqzmqema.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 20 Jun 2010 01\:42\:37 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org


The expressions tsk->nsproxy->pid_ns and task_active_pid_ns
aka ns_of_pid(task_pid(tsk)) should have the same number of
cache line misses with the practical difference that
ns_of_pid(task_pid(tsk)) is released later in a processes life.

Furthermore by using task_active_pid_ns it becomes trivial
to write an unshare implementation for the the pid namespace.

So I have used task_active_pid_ns everywhere I can.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
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
index de317d0..77787d2 100644
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
index 310ac20..7e154fb 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -46,7 +46,7 @@ static int proc_get_sb(struct file_system_type *fs_type,
 	if (flags & MS_KERNMOUNT)
 		ns = (struct pid_namespace *)data;
 	else
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 
 	sb = sget(fs_type, proc_test_super, proc_set_super, ns);
 	if (IS_ERR(sb))
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3ac6f5b..a162b00 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2650,8 +2650,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
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
index ff86c55..42efe59 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -4843,7 +4843,7 @@ perf_event_alloc(struct perf_event_attr *attr,
 
 	event->parent		= parent_event;
 
-	event->ns		= get_pid_ns(current->nsproxy->pid_ns);
+	event->ns		= get_pid_ns(task_active_pid_ns(current));
 	event->id		= atomic64_inc_return(&perf_event_id);
 
 	event->state		= PERF_EVENT_STATE_INACTIVE;
diff --git a/kernel/pid.c b/kernel/pid.c
index e1f26ec..0bbccc2 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -309,7 +309,7 @@ EXPORT_SYMBOL_GPL(find_pid_ns);
 
 struct pid *find_vpid(int nr)
 {
-	return find_pid_ns(nr, current->nsproxy->pid_ns);
+	return find_pid_ns(nr, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(find_vpid);
 
@@ -391,7 +391,7 @@ struct task_struct *find_task_by_pid_ns(pid_t nr, struct pid_namespace *ns)
 
 struct task_struct *find_task_by_vpid(pid_t vnr)
 {
-	return find_task_by_pid_ns(vnr, current->nsproxy->pid_ns);
+	return find_task_by_pid_ns(vnr, task_active_pid_ns(current));
 }
 
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
@@ -443,7 +443,7 @@ pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
 
 pid_t pid_vnr(struct pid *pid)
 {
-	return pid_nr_ns(pid, current->nsproxy->pid_ns);
+	return pid_nr_ns(pid, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(pid_vnr);
 
@@ -454,7 +454,7 @@ pid_t __task_pid_nr_ns(struct task_struct *task, enum pid_type type,
 
 	rcu_read_lock();
 	if (!ns)
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 	if (likely(pid_alive(task))) {
 		if (type != PIDTYPE_PID)
 			task = task->group_leader;
diff --git a/kernel/signal.c b/kernel/signal.c
index 906ae5a..bb90743 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1458,16 +1458,15 @@ int do_notify_parent(struct task_struct *tsk, int sig)
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
 
@@ -1538,7 +1537,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 	 * see comment in do_notify_parent() abot the following 3 lines
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(parent));
 	info.si_uid = __task_cred(tsk)->uid;
 	rcu_read_unlock();
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 1357c57..da4eb82 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -1350,7 +1350,7 @@ static ssize_t binary_sysctl(const int *name, int nlen,
 		goto out_putname;
 	}
 
-	mnt = current->nsproxy->pid_ns->proc_mnt;
+	mnt = task_active_pid_ns(current)->proc_mnt;
 	result = vfs_path_lookup(mnt->mnt_root, mnt, pathname, 0, &nd);
 	if (result)
 		goto out_putname;
-- 
1.6.5.2.143.g8cc62
