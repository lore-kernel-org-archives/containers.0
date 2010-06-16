From: Louis Rilling <louis.rilling@kerlabs.com>
Subject: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Wed, 16 Jun 2010 18:34:28 +0200
Message-ID: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <louis.rilling@kerlabs.com>
List-Id: containers.vger.kernel.org

[ Resending, hopefully with all pieces ]

Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
that release_task()->proc_flush_task() of container init can be called
before it is for some detached tasks in the namespace.

Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
whatever the ordering of tasks.

Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
---
 fs/proc/base.c          |   18 ++++++++++++++++++
 include/linux/proc_fs.h |    4 ++++
 kernel/fork.c           |    1 +
 3 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index acb7ef8..d6cdd91 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2663,6 +2663,23 @@ static const struct inode_operations proc_tgid_base_inode_operations = {
 	.setattr	= proc_setattr,
 };
 
+/*
+ * Pin all proc_mnt so that detached tasks can safely call proc_flush_task()
+ * after container init calls itself proc_flush_task().
+ */
+void proc_new_task(struct task_struct *task)
+{
+	struct pid *pid;
+	int i;
+
+	if (!task->pid)
+		return;
+
+	pid = task_pid(task);
+	for (i = 0; i <= pid->level; i++)
+		mntget(pid->numbers[i].ns->proc_mnt);
+}
+
 static void proc_flush_task_mnt(struct vfsmount *mnt, pid_t pid, pid_t tgid)
 {
 	struct dentry *dentry, *leader, *dir;
@@ -2744,6 +2761,7 @@ void proc_flush_task(struct task_struct *task)
 		upid = &pid->numbers[i];
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
+		mntput(upid->ns->proc_mnt);
 	}
 
 	upid = &pid->numbers[pid->level];
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 379eaed..f24faa1 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -104,6 +104,7 @@ struct vmcore {
 
 extern void proc_root_init(void);
 
+void proc_new_task(struct task_struct *task);
 void proc_flush_task(struct task_struct *task);
 
 extern struct proc_dir_entry *create_proc_entry(const char *name, mode_t mode,
@@ -184,6 +185,9 @@ extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
 static inline void proc_net_remove(struct net *net, const char *name) {}
 
+static inline void proc_new_task(struct task_struct *task)
+{
+}
 static inline void proc_flush_task(struct task_struct *task)
 {
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index b6cce14..c6c2874 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1281,6 +1281,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	total_forks++;
 	spin_unlock(&current->sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
+	proc_new_task(p);
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	perf_event_fork(p);
-- 
1.5.6.5
