From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Sat, 15 Nov 2008 13:21:33 -0800
Message-ID: <20081115212133.GA32140@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755236AbYKOVYa@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg,

I tried to address most of your comments from the earlier version.

Sukadev
---
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH] Define/use siginfo_from_ancestor_ns()

Container-init must appear like 'global-init' to processes within the
container and hence it must be immune to fatal signals from within the
container.  But container-init should appear like a normal process  to
processes in ancestor namespaces and so if same fatal signal is sent
by a process in parent namespace, the container-init must terminate.

There have been several attempts to meet these conflicting requirements
This patch (tries to) implement the approach suggested recently by Oleg
Nesterov.

Changelog[v2]:
	- Have sig_ignored() ignore unblocked SIG_DFL signals to container-init
	- Use the new SIG_FROM_USER flag and sender's namespace to clear
	  si_pid for signals crossing namespaces.
	- Move setting of SIGNAL_UNKILLABLE from copy_process() to copy_signal()
	- Clear si_pid in sys_rt_sigqueueinfo() when signalling processes in
	  descendant namespaces

Touch tested, but this is just a quick patch and has known issues.

TODO:
	- Move this new code under #ifdef CONFIG_PID_NS
	- Need additional checks for stopped/traced processes.
	- With 'si_pid = 0' sys_rt_sigqueueinfo() can still terminate own init.
	- Clear ->si_pid in other namespace-crossing cases including: F_SETSIG,
	  __do_notify(), etc

Signed-off-by Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/fork.c   |    2 +
 kernel/signal.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 78 insertions(+), 10 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 28be39a..368f25c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -814,6 +814,8 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	atomic_set(&sig->live, 1);
 	init_waitqueue_head(&sig->wait_chldexit);
 	sig->flags = 0;
+	if (clone_flags & CLONE_NEWPID)
+		sig->flags |= SIGNAL_UNKILLABLE;
 	sig->group_exit_code = 0;
 	sig->group_exit_task = NULL;
 	sig->group_stop_count = 0;
diff --git a/kernel/signal.c b/kernel/signal.c
index 4530fc6..cd4b2a5 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -53,7 +53,7 @@ static int sig_handler_ignored(void __user *handler, int sig)
 		(handler == SIG_DFL && sig_kernel_ignore(sig));
 }
 
-static int sig_ignored(struct task_struct *t, int sig)
+static int sig_ignored(struct task_struct *t, int sig, int same_ns)
 {
 	void __user *handler;
 
@@ -68,6 +68,14 @@ static int sig_ignored(struct task_struct *t, int sig)
 	handler = sig_handler(t, sig);
 	if (!sig_handler_ignored(handler, sig))
 		return 0;
+	/*
+	 * ignores SIGSTOP/SIGKILL signals to init from same namespace.
+	 *
+	 * TODO: Ignore unblocked SIG_DFL signals also here or drop them
+	 * 	 in get_signal_to_deliver() ?
+	 */
+	if (is_container_init(t) && same_ns && sig_kernel_only(sig))
+		return 1;
 
 	/*
 	 * Tracers may want to know about even ignored signals.
@@ -609,11 +617,16 @@ static int check_kill_permission(int sig, struct siginfo *info,
  * Returns true if the signal should be actually delivered, otherwise
  * it should be dropped.
  */
-static int prepare_signal(int sig, struct task_struct *p)
+static int prepare_signal(int sig, struct task_struct *p, int same_ns)
 {
 	struct signal_struct *signal = p->signal;
 	struct task_struct *t;
 
+	/*
+	 * TODO: If cinit is stopped by a process from ancestor ns, it
+	 *  	 must not be continued by a SIGCONT from a descendant
+	 *  	 process. And vice-versa
+	 */
 	if (unlikely(signal->flags & SIGNAL_GROUP_EXIT)) {
 		/*
 		 * The process is in the middle of dying, nothing to do.
@@ -693,7 +706,7 @@ static int prepare_signal(int sig, struct task_struct *p)
 		}
 	}
 
-	return !sig_ignored(p, sig);
+	return !sig_ignored(p, sig, same_ns);
 }
 
 /*
@@ -798,16 +811,38 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
+/*
+ * Return TRUE if this signal originated directly from the user (i.e via
+ * kill(), tkill(), sigqueue()). 
+ *
+ * This differs from similarly named, SI_FROMUSER() in that the latter
+ * includes signals such as timer, async-io, or message-queue that
+ * originate _from kernel_.
+ */
+#define SIG_FROM_USER	INT_MIN		/* MSB */
+static inline int siginfo_from_user(siginfo_t *info)
+{
+	return !is_si_special(info) && (info->si_signo & SIG_FROM_USER);
+}
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
+	int from_ancestor_ns;
+
+	from_ancestor_ns = 0;
+	if (siginfo_from_user(info)) {
+		/* if t can't see us we are from parent ns */
+		if (task_pid_nr_ns(current, task_active_pid_ns(t)) == 0)
+			from_ancestor_ns = 1;
+	}
 
 	trace_sched_signal_send(sig, t);
 
 	assert_spin_locked(&t->sighand->siglock);
-	if (!prepare_signal(sig, t))
+	if (!prepare_signal(sig, t, !from_ancestor_ns))
 		return 0;
 
 	pending = group ? &t->signal->shared_pending : &t->pending;
@@ -855,6 +890,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			break;
 		default:
 			copy_siginfo(&q->info, info);
+			if (from_ancestor_ns)
+				q->info.si_pid = 0;
+			q->info.si_signo &= ~SIG_FROM_USER;
 			break;
 		}
 	} else if (!is_si_special(info)) {
@@ -864,6 +902,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 		 * and sent by user using something other than kill().
 		 */
 			return -EAGAIN;
+
+		if (from_ancestor_ns)
+			return -ENOMEM;
 	}
 
 out_set:
@@ -1295,7 +1336,7 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
 		goto ret;
 
 	ret = 1; /* the signal is ignored */
-	if (!prepare_signal(sig, t))
+	if (!prepare_signal(sig, t, 1))
 		goto out;
 
 	ret = 0;
@@ -1722,6 +1763,11 @@ static int ptrace_signal(int signr, siginfo_t *info,
 	return signr;
 }
 
+static inline int siginfo_from_ancestor_ns(siginfo_t *info)
+{
+	return SI_FROMUSER(info) && (info->si_pid == 0);
+}
+
 int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 			  struct pt_regs *regs, void *cookie)
 {
@@ -1813,9 +1859,12 @@ relock:
 
 		/*
 		 * Global init gets no signals it doesn't want.
+		 * Container-init gets no signals from its descendants, it
+		 * doesn't want.
 		 */
 		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
-		    !signal_group_exit(signal))
+				!siginfo_from_ancestor_ns(info) &&
+				!signal_group_exit(signal))
 			continue;
 
 		if (sig_kernel_stop(signr)) {
@@ -2207,7 +2256,7 @@ sys_kill(pid_t pid, int sig)
 {
 	struct siginfo info;
 
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_USER;
 	info.si_pid = task_tgid_vnr(current);
@@ -2224,7 +2273,7 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
 	unsigned long flags;
 
 	error = -ESRCH;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
 	info.si_pid = task_tgid_vnr(current);
@@ -2288,6 +2337,8 @@ asmlinkage long
 sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 {
 	siginfo_t info;
+	struct pid *spid;
+	int error;
 
 	if (copy_from_user(&info, uinfo, sizeof(siginfo_t)))
 		return -EFAULT;
@@ -2296,10 +2347,25 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 	   Nor can they impersonate a kill(), which adds source info.  */
 	if (info.si_code >= 0)
 		return -EPERM;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 
 	/* POSIX.1b doesn't mention process groups.  */
-	return kill_proc_info(sig, &info, pid);
+	rcu_read_lock();
+	spid = find_vpid(pid);
+	/* 
+	 * A container-init (cinit) ignores/drops fatal signals unless sender
+	 * is in an ancestor namespace.  Cinit uses 'si_pid == 0' to check if
+	 * sender is an ancestor. See siginfo_from_ancestor_ns().
+	 *
+	 * If signalling a descendant cinit, set si_pid to 0 so it does not
+	 * get ignored/dropped.
+	 */
+	if (!pid_nr_ns(spid, task_active_pid_ns(current)))
+		info.si_pid = 0;
+	error = kill_pid_info(sig, &info, spid);
+	rcu_read_unlock();
+
+	return error;
 }
 
 int do_sigaction(int sig, struct k_sigaction *act, struct k_sigaction *oact)
-- 
1.5.2.5
