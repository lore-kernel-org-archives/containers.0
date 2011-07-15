From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 5/7] clone: Introduce the CLONE_CHILD_USEPID functionality
Date: Fri, 15 Jul 2011 17:47:23 +0400
Message-ID: <4E2044EB.20001@parallels.com>
References: <4E204466.8010204@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E204466.8010204-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

The respective flag for clone() makes the latter to take the desired
pid of a new process from the child_tidptr. The given pid is used as
the pid for the pid namespace the parent is currently running in.

Needed badly for restoring a process.

Signed-off-by: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 include/linux/pid.h   |    2 +-
 include/linux/sched.h |    1 +
 kernel/fork.c         |   10 ++++++-
 kernel/pid.c          |   70 +++++++++++++++++++++++++++++++++++-------------
 4 files changed, 62 insertions(+), 21 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index cdced84..de772ab 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, unsigned int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns, int pid);
 extern void free_pid(struct pid *pid);
 
 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 781abd1..5b6c1e2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -23,6 +23,7 @@
 #define CLONE_CHILD_SETTID	0x01000000	/* set the TID in the child */
 /* 0x02000000 was previously the unused CLONE_STOPPED (Start in stopped state)
    and is now available for re-use. */
+#define CLONE_CHILD_USEPID	0x02000000	/* use the given pid */
 #define CLONE_NEWUTS		0x04000000	/* New utsname group? */
 #define CLONE_NEWIPC		0x08000000	/* New ipcs */
 #define CLONE_NEWUSER		0x10000000	/* New user namespace */
diff --git a/kernel/fork.c b/kernel/fork.c
index e7548de..f30fbdb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1183,8 +1183,16 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		goto bad_fork_cleanup_io;
 
 	if (pid != &init_struct_pid) {
+		int want_pid = 0;
+
+		if (clone_flags & CLONE_CHILD_USEPID) {
+			retval = get_user(want_pid, child_tidptr);
+			if (retval)
+				goto bad_fork_cleanup_io;
+		}
+
 		retval = -ENOMEM;
-		pid = alloc_pid(p->nsproxy->pid_ns);
+		pid = alloc_pid(p->nsproxy->pid_ns, want_pid);
 		if (!pid)
 			goto bad_fork_cleanup_io;
 	}
diff --git a/kernel/pid.c b/kernel/pid.c
index 57a8346..69ae1be 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -159,11 +159,55 @@ static void set_last_pid(struct pid_namespace *pid_ns, int base, int pid)
 	} while ((prev != last_write) && (pid_before(base, last_write, pid)));
 }
 
-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int alloc_pidmap_page(struct pidmap *map)
+{
+	if (unlikely(!map->page)) {
+		void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
+		/*
+		 * Free the page if someone raced with us
+		 * installing it:
+		 */
+		spin_lock_irq(&pidmap_lock);
+		if (!map->page) {
+			map->page = page;
+			page = NULL;
+		}
+		spin_unlock_irq(&pidmap_lock);
+		kfree(page);
+		if (unlikely(!map->page))
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int set_pidmap(struct pid_namespace *pid_ns, int pid)
+{
+	int offset;
+	struct pidmap *map;
+
+	offset = pid & BITS_PER_PAGE_MASK;
+	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+
+	if (alloc_pidmap_page(map) < 0)
+		return -ENOMEM;
+
+	if (!test_and_set_bit(offset, map->page)) {
+		atomic_dec(&map->nr_free);
+		return pid;
+	}
+
+	return -EBUSY;
+}
+
+static int alloc_pidmap(struct pid_namespace *pid_ns, int desired_pid)
 {
 	int i, offset, max_scan, pid, last = pid_ns->last_pid;
 	struct pidmap *map;
 
+	if (desired_pid)
+		return set_pidmap(pid_ns, desired_pid);
+
 	pid = last + 1;
 	if (pid >= pid_max)
 		pid = RESERVED_PIDS;
@@ -176,22 +220,9 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	 */
 	max_scan = DIV_ROUND_UP(pid_max, BITS_PER_PAGE) - !offset;
 	for (i = 0; i <= max_scan; ++i) {
-		if (unlikely(!map->page)) {
-			void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
-			/*
-			 * Free the page if someone raced with us
-			 * installing it:
-			 */
-			spin_lock_irq(&pidmap_lock);
-			if (!map->page) {
-				map->page = page;
-				page = NULL;
-			}
-			spin_unlock_irq(&pidmap_lock);
-			kfree(page);
-			if (unlikely(!map->page))
-				break;
-		}
+		if (alloc_pidmap_page(map) < 0)
+			break;
+
 		if (likely(atomic_read(&map->nr_free))) {
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
@@ -277,7 +308,7 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, int this_ns_pid)
 {
 	struct pid *pid;
 	enum pid_type type;
@@ -291,13 +322,14 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+		nr = alloc_pidmap(tmp, this_ns_pid);
 		if (nr < 0)
 			goto out_free;
 
 		pid->numbers[i].nr = nr;
 		pid->numbers[i].ns = tmp;
 		tmp = tmp->parent;
+		this_ns_pid = 0;
 	}
 
 	get_pid_ns(ns);
-- 
1.5.5.6
