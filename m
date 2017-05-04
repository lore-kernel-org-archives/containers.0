From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace related changes for v4.12-rc1
Date: Thu, 04 May 2017 11:23:41 -0500
Message-ID: <87r304bng2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: d66bb1607e2d8d384e53f3d93db5c18483c8c4f7 proc: Fix unbalanced hard link numbers

This is a set of small fixes that were mostly stumbled over during more
significant development.  This proc fix and the fix to posix-timers
are the most significant of the lot.

There is a lot of good development going on but unfortunately it didn't
quite make the merge window.

Eric W. Biederman (7):
      sysctl: Remove dead register_sysctl_root
      posix-timers: Correct sanity check in posix_cpu_nsleep
      ipc: Remove unused declaration of recompute_msgmni
      ia64: Remove unused IA64_TASK_SIGHAND_OFFSET and IA64_SIGHAND_SIGLOCK_OFFSET
      signal: Remove unused definition of sig_user_definied
      rlimit: Properly call security_task_setrlimit
      signal: Make kill_proc_info static

Takashi Iwai (1):
      proc: Fix unbalanced hard link numbers

 arch/ia64/kernel/asm-offsets.c | 4 ----
 fs/proc/generic.c              | 1 +
 fs/proc/proc_sysctl.c          | 4 ----
 include/linux/sched/signal.h   | 1 -
 include/linux/signal.h         | 4 ----
 include/linux/sysctl.h         | 1 -
 ipc/util.h                     | 2 --
 kernel/signal.c                | 2 +-
 kernel/sys.c                   | 3 +--
 kernel/time/posix-cpu-timers.c | 2 +-
 net/sysctl_net.c               | 1 -
 11 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 8786c8b4f187..798bdb209d00 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -56,7 +56,6 @@ void foo(void)
 	DEFINE(IA64_TASK_PENDING_OFFSET,offsetof (struct task_struct, pending));
 	DEFINE(IA64_TASK_PID_OFFSET, offsetof (struct task_struct, pid));
 	DEFINE(IA64_TASK_REAL_PARENT_OFFSET, offsetof (struct task_struct, real_parent));
-	DEFINE(IA64_TASK_SIGHAND_OFFSET,offsetof (struct task_struct, sighand));
 	DEFINE(IA64_TASK_SIGNAL_OFFSET,offsetof (struct task_struct, signal));
 	DEFINE(IA64_TASK_TGID_OFFSET, offsetof (struct task_struct, tgid));
 	DEFINE(IA64_TASK_THREAD_KSP_OFFSET, offsetof (struct task_struct, thread.ksp));
@@ -64,9 +63,6 @@ void foo(void)
 
 	BLANK();
 
-	DEFINE(IA64_SIGHAND_SIGLOCK_OFFSET,offsetof (struct sighand_struct, siglock));
-
-	BLANK();
 
 	DEFINE(IA64_SIGNAL_GROUP_STOP_COUNT_OFFSET,offsetof (struct signal_struct,
 							     group_stop_count));
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index ee27feb34cf4..9425c0d97262 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -472,6 +472,7 @@ struct proc_dir_entry *proc_create_mount_point(const char *name)
 		ent->data = NULL;
 		ent->proc_fops = NULL;
 		ent->proc_iops = NULL;
+		parent->nlink++;
 		if (proc_register(parent, ent) < 0) {
 			kfree(ent);
 			parent->nlink--;
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 8f91ec66baa3..35eed95b26d5 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -408,10 +408,6 @@ static void next_entry(struct ctl_table_header **phead, struct ctl_table **pentr
 	*pentry = entry;
 }
 
-void register_sysctl_root(struct ctl_table_root *root)
-{
-}
-
 /*
  * sysctl_perm does NOT grant the superuser all rights automatically, because
  * some sysctl variables are readonly even to root.
diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index 2cf446704cd4..c06d63b3a583 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -293,7 +293,6 @@ extern int kill_pid_info_as_cred(int, struct siginfo *, struct pid *,
 				const struct cred *, u32);
 extern int kill_pgrp(struct pid *pid, int sig, int priv);
 extern int kill_pid(struct pid *pid, int sig, int priv);
-extern int kill_proc_info(int, struct siginfo *, pid_t);
 extern __must_check bool do_notify_parent(struct task_struct *, int);
 extern void __wake_up_parent(struct task_struct *p, struct task_struct *parent);
 extern void force_sig(int, struct task_struct *);
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 94ad6eea9550..1f5a16620693 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -390,10 +390,6 @@ int unhandled_signal(struct task_struct *tsk, int sig);
 #define sig_kernel_ignore(sig)		siginmask(sig, SIG_KERNEL_IGNORE_MASK)
 #define sig_kernel_stop(sig)		siginmask(sig, SIG_KERNEL_STOP_MASK)
 
-#define sig_user_defined(t, signr) \
-	(((t)->sighand->action[(signr)-1].sa.sa_handler != SIG_DFL) &&	\
-	 ((t)->sighand->action[(signr)-1].sa.sa_handler != SIG_IGN))
-
 #define sig_fatal(t, signr) \
 	(!siginmask(signr, SIG_KERNEL_IGNORE_MASK|SIG_KERNEL_STOP_MASK) && \
 	 (t)->sighand->action[(signr)-1].sa.sa_handler == SIG_DFL)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index b7e82049fec7..80d07816def0 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -180,7 +180,6 @@ extern void setup_sysctl_set(struct ctl_table_set *p,
 	int (*is_seen)(struct ctl_table_set *));
 extern void retire_sysctl_set(struct ctl_table_set *set);
 
-void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_table(
 	struct ctl_table_set *set,
 	const char *path, struct ctl_table *table);
diff --git a/ipc/util.h b/ipc/util.h
index 51f7ca58ac67..60ddccca464d 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -153,8 +153,6 @@ extern struct msg_msg *load_msg(const void __user *src, size_t len);
 extern struct msg_msg *copy_msg(struct msg_msg *src, struct msg_msg *dst);
 extern int store_msg(void __user *dest, struct msg_msg *msg, size_t len);
 
-extern void recompute_msgmni(struct ipc_namespace *);
-
 static inline int ipc_buildid(int id, int seq)
 {
 	return SEQ_MULTIPLIER * seq + id;
diff --git a/kernel/signal.c b/kernel/signal.c
index 7e59ebc2c25e..a8c54f384553 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1318,7 +1318,7 @@ int kill_pid_info(int sig, struct siginfo *info, struct pid *pid)
 	}
 }
 
-int kill_proc_info(int sig, struct siginfo *info, pid_t pid)
+static int kill_proc_info(int sig, struct siginfo *info, pid_t pid)
 {
 	int error;
 	rcu_read_lock();
diff --git a/kernel/sys.c b/kernel/sys.c
index 7ff6d1b10cec..ad1eff7933cb 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1396,8 +1396,7 @@ int do_prlimit(struct task_struct *tsk, unsigned int resource,
 				!capable(CAP_SYS_RESOURCE))
 			retval = -EPERM;
 		if (!retval)
-			retval = security_task_setrlimit(tsk->group_leader,
-					resource, new_rlim);
+			retval = security_task_setrlimit(tsk, resource, new_rlim);
 		if (resource == RLIMIT_CPU && new_rlim->rlim_cur == 0) {
 			/*
 			 * The caller is asking for an immediate RLIMIT_CPU
diff --git a/kernel/time/posix-cpu-timers.c b/kernel/time/posix-cpu-timers.c
index 4513ad16a253..37f9bb8c193e 100644
--- a/kernel/time/posix-cpu-timers.c
+++ b/kernel/time/posix-cpu-timers.c
@@ -1312,7 +1312,7 @@ static int posix_cpu_nsleep(const clockid_t which_clock, int flags,
 	 */
 	if (CPUCLOCK_PERTHREAD(which_clock) &&
 	    (CPUCLOCK_PID(which_clock) == 0 ||
-	     CPUCLOCK_PID(which_clock) == current->pid))
+	     CPUCLOCK_PID(which_clock) == task_pid_vnr(current)))
 		return -EINVAL;
 
 	error = do_cpu_nanosleep(which_clock, flags, rqtp, &it);
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 919981324171..9aed6fe1bf1a 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -106,7 +106,6 @@ __init int net_sysctl_init(void)
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
 	if (ret)
 		goto out1;
-	register_sysctl_root(&net_sysctl_root);
 out:
 	return ret;
 out1:


Eric
