From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 13/27] userns: Convert taskstats to handle the user and pid
	namespaces.
Date: Wed, 19 Sep 2012 18:52:15 -0700
Message-ID: <1348105949-25454-13-git-send-email-ebiederm__3640.71907611123$1348107194$gmane$org@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Explicitly limit exit task stat broadcast to the initial user and
  pid namespaces, as it is already limited to the initial network
  namespace.

- For broadcast task stats explicitly generate all of the idenitiers
  in terms of the initial user namespace and the initial pid
  namespace.

- For request stats report them in terms of the current user namespace
  and the current pid namespace.  Netlink messages are delivered
  syncrhonously to the kernel allowing us to get the user namespace
  and the pid namespace from the current task.

- Pass the namespaces for representing pids and uids and gids
  into bacct_add_task.

Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/tsacct_kern.h |    8 ++++++--
 init/Kconfig                |    1 -
 kernel/taskstats.c          |   23 +++++++++++++++++------
 kernel/tsacct.c             |   12 +++++++-----
 4 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/tsacct_kern.h b/include/linux/tsacct_kern.h
index 7e50ac7..44893e5 100644
--- a/include/linux/tsacct_kern.h
+++ b/include/linux/tsacct_kern.h
@@ -10,9 +10,13 @@
 #include <linux/taskstats.h>
 
 #ifdef CONFIG_TASKSTATS
-extern void bacct_add_tsk(struct taskstats *stats, struct task_struct *tsk);
+extern void bacct_add_tsk(struct user_namespace *user_ns,
+			  struct pid_namespace *pid_ns,
+			  struct taskstats *stats, struct task_struct *tsk);
 #else
-static inline void bacct_add_tsk(struct taskstats *stats, struct task_struct *tsk)
+static inline void bacct_add_tsk(struct user_namespace *user_ns,
+				 struct pid_namespace *pid_ns,
+				 struct taskstats *stats, struct task_struct *tsk)
 {}
 #endif /* CONFIG_TASKSTATS */
 
diff --git a/init/Kconfig b/init/Kconfig
index b5ecb4e..f0f636c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -927,7 +927,6 @@ config UIDGID_CONVERTED
 	# Features
 	depends on IMA = n
 	depends on EVM = n
-	depends on TASKSTATS = n
 	depends on TRACING = n
 	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index d0a3279..3880df2 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -27,6 +27,7 @@
 #include <linux/cgroup.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/pid_namespace.h>
 #include <net/genetlink.h>
 #include <linux/atomic.h>
 
@@ -174,7 +175,9 @@ static void send_cpu_listeners(struct sk_buff *skb,
 	up_write(&listeners->sem);
 }
 
-static void fill_stats(struct task_struct *tsk, struct taskstats *stats)
+static void fill_stats(struct user_namespace *user_ns,
+		       struct pid_namespace *pid_ns,
+		       struct task_struct *tsk, struct taskstats *stats)
 {
 	memset(stats, 0, sizeof(*stats));
 	/*
@@ -190,7 +193,7 @@ static void fill_stats(struct task_struct *tsk, struct taskstats *stats)
 	stats->version = TASKSTATS_VERSION;
 	stats->nvcsw = tsk->nvcsw;
 	stats->nivcsw = tsk->nivcsw;
-	bacct_add_tsk(stats, tsk);
+	bacct_add_tsk(user_ns, pid_ns, stats, tsk);
 
 	/* fill in extended acct fields */
 	xacct_add_tsk(stats, tsk);
@@ -207,7 +210,7 @@ static int fill_stats_for_pid(pid_t pid, struct taskstats *stats)
 	rcu_read_unlock();
 	if (!tsk)
 		return -ESRCH;
-	fill_stats(tsk, stats);
+	fill_stats(current_user_ns(), task_active_pid_ns(current), tsk, stats);
 	put_task_struct(tsk);
 	return 0;
 }
@@ -291,6 +294,12 @@ static int add_del_listener(pid_t pid, const struct cpumask *mask, int isadd)
 	if (!cpumask_subset(mask, cpu_possible_mask))
 		return -EINVAL;
 
+	if (current_user_ns() != &init_user_ns)
+		return -EINVAL;
+
+	if (task_active_pid_ns(current) != &init_pid_ns)
+		return -EINVAL;
+
 	if (isadd == REGISTER) {
 		for_each_cpu(cpu, mask) {
 			s = kmalloc_node(sizeof(struct listener),
@@ -631,11 +640,12 @@ void taskstats_exit(struct task_struct *tsk, int group_dead)
 	if (rc < 0)
 		return;
 
-	stats = mk_reply(rep_skb, TASKSTATS_TYPE_PID, tsk->pid);
+	stats = mk_reply(rep_skb, TASKSTATS_TYPE_PID,
+			 task_pid_nr_ns(tsk, &init_pid_ns));
 	if (!stats)
 		goto err;
 
-	fill_stats(tsk, stats);
+	fill_stats(&init_user_ns, &init_pid_ns, tsk, stats);
 
 	/*
 	 * Doesn't matter if tsk is the leader or the last group member leaving
@@ -643,7 +653,8 @@ void taskstats_exit(struct task_struct *tsk, int group_dead)
 	if (!is_thread_group || !group_dead)
 		goto send;
 
-	stats = mk_reply(rep_skb, TASKSTATS_TYPE_TGID, tsk->tgid);
+	stats = mk_reply(rep_skb, TASKSTATS_TYPE_TGID,
+			 task_tgid_nr_ns(tsk, &init_pid_ns));
 	if (!stats)
 		goto err;
 
diff --git a/kernel/tsacct.c b/kernel/tsacct.c
index 23b4d78..625df0b 100644
--- a/kernel/tsacct.c
+++ b/kernel/tsacct.c
@@ -26,7 +26,9 @@
 /*
  * fill in basic accounting fields
  */
-void bacct_add_tsk(struct taskstats *stats, struct task_struct *tsk)
+void bacct_add_tsk(struct user_namespace *user_ns,
+		   struct pid_namespace *pid_ns,
+		   struct taskstats *stats, struct task_struct *tsk)
 {
 	const struct cred *tcred;
 	struct timespec uptime, ts;
@@ -55,13 +57,13 @@ void bacct_add_tsk(struct taskstats *stats, struct task_struct *tsk)
 		stats->ac_flag |= AXSIG;
 	stats->ac_nice	 = task_nice(tsk);
 	stats->ac_sched	 = tsk->policy;
-	stats->ac_pid	 = tsk->pid;
+	stats->ac_pid	 = task_pid_nr_ns(tsk, pid_ns);
 	rcu_read_lock();
 	tcred = __task_cred(tsk);
-	stats->ac_uid	 = tcred->uid;
-	stats->ac_gid	 = tcred->gid;
+	stats->ac_uid	 = from_kuid_munged(user_ns, tcred->uid);
+	stats->ac_gid	 = from_kgid_munged(user_ns, tcred->gid);
 	stats->ac_ppid	 = pid_alive(tsk) ?
-				rcu_dereference(tsk->real_parent)->tgid : 0;
+		task_tgid_nr_ns(rcu_dereference(tsk->real_parent), pid_ns) : 0;
 	rcu_read_unlock();
 	stats->ac_utime = cputime_to_usecs(tsk->utime);
 	stats->ac_stime = cputime_to_usecs(tsk->stime);
-- 
1.7.5.4
