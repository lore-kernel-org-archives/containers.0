From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 2/3] pidns: Stop pid allocation when init dies
Date: Fri, 21 Dec 2012 20:58:06 -0800
Message-ID: <871ueiel9d.fsf@xmission.com>
References: <87d2y2elbi.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2y2elbi.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 21 Dec 2012 20:56:49 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Oleg pointed out that in a pid namespace the sequence.
- pid 1 becomes a zombie
- setns(thepidns), fork,...
- reaping pid 1.
- The injected processes exiting.

Can lead to processes attempting access their child reaper and
instead following a stale pointer.

That waitpid for init can return before all of the processes in
the pid namespace have exited is also unfortunate.

Avoid these problems by disabling the allocation of new pids in a pid
namespace when init dies, instead of when the last process in a pid
namespace is reaped.

Pointed-out-by:  Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/pid.h           |    1 +
 include/linux/pid_namespace.h |    4 +++-
 kernel/pid.c                  |   13 ++++++++++---
 kernel/pid_namespace.c        |    4 ++++
 4 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index b152d44..2381c97 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -121,6 +121,7 @@ int next_pidmap(struct pid_namespace *pid_ns, unsigned int last);
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void free_pid(struct pid *pid);
+extern void disable_pid_allocation(struct pid_namespace *ns);
 
 /*
  * ns_of_pid() returns the pid namespace in which the specified pid was
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index bf28599..215e5e3 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -21,7 +21,7 @@ struct pid_namespace {
 	struct kref kref;
 	struct pidmap pidmap[PIDMAP_ENTRIES];
 	int last_pid;
-	int nr_hashed;
+	unsigned int nr_hashed;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
@@ -42,6 +42,8 @@ struct pid_namespace {
 
 extern struct pid_namespace init_pid_ns;
 
+#define PIDNS_HASH_ADDING (1U << 31)
+
 #ifdef CONFIG_PID_NS
 static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 {
diff --git a/kernel/pid.c b/kernel/pid.c
index 36aa02f..3a5c872 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -270,7 +270,6 @@ void free_pid(struct pid *pid)
 			wake_up_process(ns->child_reaper);
 			break;
 		case 0:
-			ns->nr_hashed = -1;
 			schedule_work(&ns->proc_work);
 			break;
 		}
@@ -319,7 +318,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	upid = pid->numbers + ns->level;
 	spin_lock_irq(&pidmap_lock);
-	if (ns->nr_hashed < 0)
+	if (ns->nr_hashed < PIDNS_HASH_ADDING)
 		goto out_unlock;
 	for ( ; upid >= pid->numbers; --upid) {
 		hlist_add_head_rcu(&upid->pid_chain,
@@ -342,6 +341,14 @@ out_free:
 	goto out;
 }
 
+void disable_pid_allocation(struct pid_namespace *ns)
+{
+	spin_lock_irq(&pidmap_lock);
+	if (ns->nr_hashed >= PIDNS_HASH_ADDING)
+		ns->nr_hashed -= PIDNS_HASH_ADDING;
+	spin_unlock_irq(&pidmap_lock);
+}
+
 struct pid *find_pid_ns(int nr, struct pid_namespace *ns)
 {
 	struct hlist_node *elem;
@@ -584,7 +591,7 @@ void __init pidmap_init(void)
 	/* Reserve PID 0. We never call free_pidmap(0) */
 	set_bit(0, init_pid_ns.pidmap[0].page);
 	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
-	init_pid_ns.nr_hashed = 1;
+	init_pid_ns.nr_hashed = 1 + PIDNS_HASH_ADDING;
 
 	init_pid_ns.pid_cachep = KMEM_CACHE(pid,
 			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index fdbd0cd..c1c3dc1 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -115,6 +115,7 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
 	ns->user_ns = get_user_ns(user_ns);
+	ns->nr_hashed = PIDNS_HASH_ADDING;
 	INIT_WORK(&ns->proc_work, proc_cleanup_work);
 
 	set_bit(0, ns->pidmap[0].page);
@@ -181,6 +182,9 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 	int rc;
 	struct task_struct *task, *me = current;
 
+	/* Don't allow any more processes into the pid namespace */
+	disable_pid_allocation(pid_ns);
+
 	/* Ignore SIGCHLD causing any terminated children to autoreap */
 	spin_lock_irq(&me->sighand->siglock);
 	me->sighand->action[SIGCHLD - 1].sa.sa_handler = SIG_IGN;
-- 
1.7.5.4
