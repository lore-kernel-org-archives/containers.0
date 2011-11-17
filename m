From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: user namespace: make signal.c respect user namespaces (v5)
Date: Thu, 17 Nov 2011 04:52:30 +0000
Message-ID: <20111117045230.GA26345@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

ipc/mqueue.c: for __SI_MESQ, convert the uid being sent to recipient's
user namespace. (new, thanks Oleg)

__send_signal: convert current's uid to the recipient's user namespace
for any siginfo which is not SI_FROMKERNEL (patch from Oleg, thanks
again :)

do_notify_parent and do_notify_parent_cldstop: map task's uid to parent's
user namespace

ptrace_signal maps parent's uid into current's user namespace before
including in signal to current.  IIUC Oleg has argued that this shouldn't
matter as the debugger will play with it, but it seems like not converting
the value currently being set is misleading.

Changelog:
Sep 20: Inspired by Oleg's suggestion, define map_cred_ns() helper to
	simplify callers and help make clear what we are translating
        (which uid into which namespace).  Passing the target task would
	make callers even easier to read, but we pass in user_ns because
	current_user_ns() != task_cred_xxx(current, user_ns).
Sep 20: As recommended by Oleg, also put task_pid_vnr() under rcu_read_lock
	in ptrace_signal().
Sep 23: In send_signal(), detect when (user) signal is coming from an
	ancestor or unrelated user namespace.  Pass that on to __send_signal,
	which sets si_uid to 0 or overflowuid if needed.
Oct 12: Base on Oleg's fixup_uid() patch.  On top of that, handle all
	SI_FROMKERNEL cases at callers, because we can't assume sender is
	current in those cases.
Nov 10: (mhelsley) rename fixup_uid to more meaningful usern_fixup_signal_uid
Nov 10: (akpm) make the !CONFIG_USER_NS case clearer

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 ipc/mqueue.c    |    7 ++++++-
 kernel/signal.c |   43 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 2e0ecfc..4dbf3cb 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -32,6 +32,7 @@
 #include <linux/nsproxy.h>
 #include <linux/pid.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/slab.h>
 
 #include <net/sock.h>
@@ -543,9 +544,13 @@ static void __do_notify(struct mqueue_inode_info *info)
 			sig_i.si_errno = 0;
 			sig_i.si_code = SI_MESGQ;
 			sig_i.si_value = info->notify.sigev_value;
+			/* map current pid/uid into info->owner's namespaces */
+			rcu_read_lock();
 			sig_i.si_pid = task_tgid_nr_ns(current,
 						ns_of_pid(info->notify_owner));
-			sig_i.si_uid = current_uid();
+			sig_i.si_uid = user_ns_map_uid(info->user->user_ns,
+						current_cred(), current_uid());
+			rcu_read_lock();
 
 			kill_pid_info(info->notify.sigev_signo,
 				      &sig_i, info->notify_owner);
diff --git a/kernel/signal.c b/kernel/signal.c
index b3f78d0..c0f0782 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -28,6 +28,7 @@
 #include <linux/freezer.h>
 #include <linux/pid_namespace.h>
 #include <linux/nsproxy.h>
+#include <linux/user_namespace.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
 
@@ -1019,6 +1020,34 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
+/*
+ * map the uid in struct cred into user namespace *ns
+ */
+static inline uid_t map_cred_ns(const struct cred *cred,
+				struct user_namespace *ns)
+{
+	return user_ns_map_uid(ns, cred, cred->uid);
+}
+
+#ifdef CONFIG_USER_NS
+static inline void userns_fixup_signal_uid(struct siginfo *info, struct task_struct *t)
+{
+	if (current_user_ns() == task_cred_xxx(t, user_ns))
+		return;
+
+	if (SI_FROMKERNEL(info))
+		return;
+
+	info->si_uid = user_ns_map_uid(task_cred_xxx(t, user_ns),
+					current_cred(), info->si_uid);
+}
+#else
+static inline void userns_fixup_signal_uid(struct siginfo *info, struct task_struct *t)
+{
+	return;
+}
+#endif
+
 static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group, int from_ancestor_ns)
 {
@@ -1088,6 +1117,9 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 				q->info.si_pid = 0;
 			break;
 		}
+
+		userns_fixup_signal_uid(info, t);
+
 	} else if (!is_si_special(info)) {
 		if (sig >= SIGRTMIN && info->si_code != SI_USER) {
 			/*
@@ -1626,7 +1658,8 @@ bool do_notify_parent(struct task_struct *tsk, int sig)
 	 */
 	rcu_read_lock();
 	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
-	info.si_uid = __task_cred(tsk)->uid;
+	info.si_uid = map_cred_ns(__task_cred(tsk),
+			task_cred_xxx(tsk->parent, user_ns));
 	rcu_read_unlock();
 
 	info.si_utime = cputime_to_clock_t(cputime_add(tsk->utime,
@@ -1711,7 +1744,8 @@ static void do_notify_parent_cldstop(struct task_struct *tsk,
 	 */
 	rcu_read_lock();
 	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
-	info.si_uid = __task_cred(tsk)->uid;
+	info.si_uid = map_cred_ns(__task_cred(tsk),
+			task_cred_xxx(parent, user_ns));
 	rcu_read_unlock();
 
 	info.si_utime = cputime_to_clock_t(tsk->utime);
@@ -2129,8 +2163,11 @@ static int ptrace_signal(int signr, siginfo_t *info,
 		info->si_signo = signr;
 		info->si_errno = 0;
 		info->si_code = SI_USER;
+		rcu_read_lock();
 		info->si_pid = task_pid_vnr(current->parent);
-		info->si_uid = task_uid(current->parent);
+		info->si_uid = map_cred_ns(__task_cred(current->parent),
+				current_user_ns());
+		rcu_read_unlock();
 	}
 
 	/* If the (new) signal is now blocked, requeue it.  */
-- 
1.7.5.4
