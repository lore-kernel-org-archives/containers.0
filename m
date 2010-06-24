From: Louis Rilling <louis.rilling@kerlabs.com>
Subject: [PATCH] pid_ns: Fix proc_flush_task() accessing freed proc_mnt
Date: Thu, 24 Jun 2010 10:37:43 +0200
Message-ID: <1277368663-32705-1-git-send-email-louis.rilling@kerlabs.com>
References: <20100623203652.GA25298@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100623203652.GA25298@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "\\\"Eric W. Biederman\\\"" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <louis.rilling@kerlabs.com>
List-Id: containers.vger.kernel.org

On 06/19, Oleg Nesterov wrote:
> And the last one on top of this series, before I go away from this
> thread ;)
>
> Since my further fixes were not approved, I think at least it makes
> sense to cleanup pid_ns_release_proc() logic a bit.

It's completely untested and could be split into three patches. But I think that
it solves the issues found so far, and that it will work with Eric's
unshare(CLONE_NEWPID) too.

What do you think about this approach?

Thanks,

Louis

On 20/06/10 20:06 +0200, Oleg Nesterov wrote:
> pid_namespace holds ns->proc_mnt, while this vfsmount has a referene to
> the namespace via PROC_I(sb->s_root->d_inode)->pid. To break this circle
> /sbin/init does mntput() in pid_ns_release_proc(). See 6f4e6433.
>
> But we have the following problems:
>
>         - Nobody does mntput() if copy_process() fails after
>           pid_ns_prepare_proc().
>
>         - proc_flush_task() checks upid->nr == 1 to verify we are init,
>           this is wrong if a multi-threaded init does exec.
>
>         - As Louis pointed out, this namespace can have the detached
>           EXIT_DEAD tasks which can use ns->proc_mnt after this mntput().

This patch does four things:
- defer pid_ns_release_proc()->mntput() to a worqueue context, so that
  pid_ns_release_proc() can be called in atomic context;
- introduce pid_ns->nr_pids, so that we can count the number of pids
  allocated by alloc_pidmap();
- move the call to pid_ns_prepare_proc() to alloc_pid(), where we know
  when the first pid of a namespace is allocated;
- move the call to pid_ns_release_proc() to free_pid(), where we are now
  able to know when the last pid of a namespace is detached.

This solves the missing mntput() in copy_process() cleanup path, since
free_pid() is called to cleanup alloc_pid().

This solves the multi-threaded init doing exec issue, since all
sub-threads including former leader have called proc_flush_task() when the
last pid is detached.

This solves the EXIT_DEAD tasks issue for the same reason.

Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
---
 fs/proc/base.c                |    4 ----
 fs/proc/root.c                |   11 ++++++++++-
 include/linux/pid_namespace.h |    3 +++
 kernel/fork.c                 |    6 ------
 kernel/pid.c                  |   16 +++++++++++++---
 kernel/pid_namespace.c        |    1 +
 6 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index acb7ef8..455b109 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2745,10 +2745,6 @@ void proc_flush_task(struct task_struct *task)
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
 	}
-
-	upid = &pid->numbers[pid->level];
-	if (upid->nr == 1)
-		pid_ns_release_proc(upid->ns);
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 4258384..9876cd9 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -215,7 +215,16 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 	return 0;
 }
 
-void pid_ns_release_proc(struct pid_namespace *ns)
+static void do_pid_ns_release_proc(struct work_struct *work)
 {
+	struct pid_namespace *ns;
+
+	ns = container_of(work, struct pid_namespace, release_proc_work);
 	mntput(ns->proc_mnt);
 }
+
+void pid_ns_release_proc(struct pid_namespace *ns)
+{
+	INIT_WORK(&ns->release_proc_work, do_pid_ns_release_proc);
+	schedule_work(&ns->release_proc_work);
+}
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 38d1032..1010733 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -4,6 +4,7 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/threads.h>
+#include <linux/workqueue.h>
 #include <linux/nsproxy.h>
 #include <linux/kref.h>
 
@@ -19,6 +20,7 @@ struct bsd_acct_struct;
 struct pid_namespace {
 	struct kref kref;
 	struct pidmap pidmap[PIDMAP_ENTRIES];
+	atomic_t nr_pids;
 	int last_pid;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
@@ -26,6 +28,7 @@ struct pid_namespace {
 	struct pid_namespace *parent;
 #ifdef CONFIG_PROC_FS
 	struct vfsmount *proc_mnt;
+	struct work_struct release_proc_work;
 #endif
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
diff --git a/kernel/fork.c b/kernel/fork.c
index b6cce14..b063a9c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1154,12 +1154,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		pid = alloc_pid(p->nsproxy->pid_ns);
 		if (!pid)
 			goto bad_fork_cleanup_io;
-
-		if (clone_flags & CLONE_NEWPID) {
-			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
-			if (retval < 0)
-				goto bad_fork_free_pid;
-		}
 	}
 
 	p->pid = pid_nr(pid);
diff --git a/kernel/pid.c b/kernel/pid.c
index e9fd8c1..fdb73e1 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -34,6 +34,7 @@
 #include <linux/bootmem.h>
 #include <linux/hash.h>
 #include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/init_task.h>
 #include <linux/syscalls.h>
 
@@ -112,7 +113,7 @@ EXPORT_SYMBOL(is_container_init);
 
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(pidmap_lock);
 
-static void free_pidmap(struct upid *upid)
+static bool free_pidmap(struct upid *upid)
 {
 	int nr = upid->nr;
 	struct pidmap *map = upid->ns->pidmap + nr / BITS_PER_PAGE;
@@ -120,6 +121,7 @@ static void free_pidmap(struct upid *upid)
 
 	clear_bit(offset, map->page);
 	atomic_inc(&map->nr_free);
+	return atomic_dec_and_test(&upid->ns->nr_pids);
 }
 
 static int alloc_pidmap(struct pid_namespace *pid_ns)
@@ -154,6 +156,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
 					atomic_dec(&map->nr_free);
+					atomic_inc(&pid_ns->nr_pids);
 					pid_ns->last_pid = pid;
 					return pid;
 				}
@@ -226,6 +229,7 @@ static void delayed_put_pid(struct rcu_head *rhp)
 void free_pid(struct pid *pid)
 {
 	/* We can be called with write_lock_irq(&tasklist_lock) held */
+	struct upid *upid;
 	int i;
 	unsigned long flags;
 
@@ -234,8 +238,11 @@ void free_pid(struct pid *pid)
 		hlist_del_rcu(&pid->numbers[i].pid_chain);
 	spin_unlock_irqrestore(&pidmap_lock, flags);
 
-	for (i = 0; i <= pid->level; i++)
-		free_pidmap(pid->numbers + i);
+	for (i = 0; i <= pid->level; i++) {
+		upid = pid->numbers + i;
+		if (free_pidmap(upid))
+			pid_ns_release_proc(upid->ns);
+	}
 
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
@@ -276,6 +283,9 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 				&pid_hash[pid_hashfn(upid->nr, upid->ns)]);
 	spin_unlock_irq(&pidmap_lock);
 
+	if (pid->numbers[pid->level].nr == 1)
+		pid_ns_prepare_proc(ns);
+
 out:
 	return pid;
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a5aff94..beba2b4 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -92,6 +92,7 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
+	atomic_set(&ns->nr_pids, 0);
 
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
-- 
1.5.6.5
