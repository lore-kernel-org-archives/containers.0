From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 05/11] pidns: Make the pidns proc mount/umount logic obvious.
Date: Fri, 16 Nov 2012 08:35:44 -0800
Message-ID: <1353083750-3621-5-git-send-email-ebiederm@xmission.com>
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

Track the number of pids in the proc hash table.  When the number of
pids goes to 0 schedule work to unmount the kernel mount of proc.

Move the mount of proc into alloc_pid when we allocate the pid for
init.

Remove the surprising calls of pid_ns_release proc in fork and
proc_flush_task.  Those code paths really shouldn't know about proc
namespace implementation details and people have demonstrated several
times that finding and understanding those code paths is difficult and
non-obvious.

Because of the call path detach pid is alwasy called with the
rtnl_lock held free_pid is not allowed to sleep, so the work to
unmounting proc is moved to a work queue.  This has the side benefit
of not blocking the entire world waiting for the unnecessary
rcu_barrier in deactivate_locked_super.

In the process of making the code clear and obvious this fixes a bug
reported by Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> where we would leak a
mount of proc during clone(CLONE_NEWPID|CLONE_NEWNET) if copy_pid_ns
succeeded and copy_net_ns failed.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c                |    4 ----
 fs/proc/root.c                |    5 -----
 include/linux/pid_namespace.h |    2 ++
 kernel/fork.c                 |    2 --
 kernel/pid.c                  |   21 +++++++++++++++++----
 kernel/pid_namespace.c        |   14 +++++++-------
 6 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 6177fc2..7621dc5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2590,10 +2590,6 @@ void proc_flush_task(struct task_struct *task)
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
index fc16093..f2f2511 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -155,11 +155,6 @@ void __init proc_root_init(void)
 	err = register_filesystem(&proc_fs_type);
 	if (err)
 		return;
-	err = pid_ns_prepare_proc(&init_pid_ns);
-	if (err) {
-		unregister_filesystem(&proc_fs_type);
-		return;
-	}
 
 	proc_self_init();
 	proc_symlink("mounts", NULL, "self/mounts");
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index c89c9cf..4c96acd 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -21,6 +21,7 @@ struct pid_namespace {
 	struct kref kref;
 	struct pidmap pidmap[PIDMAP_ENTRIES];
 	int last_pid;
+	int nr_hashed;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
@@ -32,6 +33,7 @@ struct pid_namespace {
 	struct bsd_acct_struct *bacct;
 #endif
 	struct user_namespace *user_ns;
+	struct work_struct proc_work;
 	kgid_t pid_gid;
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
diff --git a/kernel/fork.c b/kernel/fork.c
index 7798c24..666dc8b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1476,8 +1476,6 @@ bad_fork_cleanup_io:
 	if (p->io_context)
 		exit_io_context(p);
 bad_fork_cleanup_namespaces:
-	if (unlikely(clone_flags & CLONE_NEWPID))
-		pid_ns_release_proc(p->nsproxy->pid_ns);
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
 	if (p->mm)
diff --git a/kernel/pid.c b/kernel/pid.c
index 3a5f238..e957f8b 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -36,6 +36,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/init_task.h>
 #include <linux/syscalls.h>
+#include <linux/proc_fs.h>
 
 #define pid_hashfn(nr, ns)	\
 	hash_long((unsigned long)nr + (unsigned long)ns, pidhash_shift)
@@ -270,8 +271,12 @@ void free_pid(struct pid *pid)
 	unsigned long flags;
 
 	spin_lock_irqsave(&pidmap_lock, flags);
-	for (i = 0; i <= pid->level; i++)
-		hlist_del_rcu(&pid->numbers[i].pid_chain);
+	for (i = 0; i <= pid->level; i++) {
+		struct upid *upid = pid->numbers + i;
+		hlist_del_rcu(&upid->pid_chain);
+		if (--upid->ns->nr_hashed == 0)
+			schedule_work(&upid->ns->proc_work);
+	}
 	spin_unlock_irqrestore(&pidmap_lock, flags);
 
 	for (i = 0; i <= pid->level; i++)
@@ -293,6 +298,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 		goto out;
 
 	tmp = ns;
+	pid->level = ns->level;
 	for (i = ns->level; i >= 0; i--) {
 		nr = alloc_pidmap(tmp);
 		if (nr < 0)
@@ -303,17 +309,23 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 		tmp = tmp->parent;
 	}
 
+	if (unlikely(is_child_reaper(pid))) {
+		if (pid_ns_prepare_proc(ns))
+			goto out_free;
+	}
+
 	get_pid_ns(ns);
-	pid->level = ns->level;
 	atomic_set(&pid->count, 1);
 	for (type = 0; type < PIDTYPE_MAX; ++type)
 		INIT_HLIST_HEAD(&pid->tasks[type]);
 
 	upid = pid->numbers + ns->level;
 	spin_lock_irq(&pidmap_lock);
-	for ( ; upid >= pid->numbers; --upid)
+	for ( ; upid >= pid->numbers; --upid) {
 		hlist_add_head_rcu(&upid->pid_chain,
 				&pid_hash[pid_hashfn(upid->nr, upid->ns)]);
+		upid->ns->nr_hashed++;
+	}
 	spin_unlock_irq(&pidmap_lock);
 
 out:
@@ -570,6 +582,7 @@ void __init pidmap_init(void)
 	/* Reserve PID 0. We never call free_pidmap(0) */
 	set_bit(0, init_pid_ns.pidmap[0].page);
 	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
+	init_pid_ns.nr_hashed = 1;
 
 	init_pid_ns.pid_cachep = KMEM_CACHE(pid,
 			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 7580aa0..cc44db7 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -72,6 +72,12 @@ err_alloc:
 	return NULL;
 }
 
+static void proc_cleanup_work(struct work_struct *work)
+{
+	struct pid_namespace *ns = container_of(work, struct pid_namespace, proc_work);
+	pid_ns_release_proc(ns);
+}
+
 /* MAX_PID_NS_LEVEL is needed for limiting size of 'struct pid' */
 #define MAX_PID_NS_LEVEL 32
 
@@ -105,6 +111,7 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
 	ns->user_ns = get_user_ns(user_ns);
+	INIT_WORK(&ns->proc_work, proc_cleanup_work);
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
@@ -112,15 +119,8 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
 
-	err = pid_ns_prepare_proc(ns);
-	if (err)
-		goto out_put_parent_pid_ns;
-
 	return ns;
 
-out_put_parent_pid_ns:
-	put_pid_ns(parent_pid_ns);
-	put_user_ns(user_ns);
 out_free_map:
 	kfree(ns->pidmap[0].page);
 out_free:
-- 
1.7.5.4
