From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 3/7][v4] Define siginfo_from_ancestor_ns()
Date: Wed, 24 Dec 2008 03:51:24 -0800
Message-ID: <20081224115124.GC8020@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753116AbYLXLxO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224114414.GA7879@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 3/7][v4] Define siginfo_from_ancestor_ns()

Determine if sender of a signal is from an ancestor namespace. This
function will be used in a follow-on patch.

This is an early/lightly tested RFC patch. Would it be safe to implement
siginfo_from_user() as below and then use it dereference the pid
namespace of sender ?

This is based on discussions on the patch from Oleg Nesterov and me
http://lkml.org/lkml/2008/11/25/462.

Changelog[v2]:
	- siginfo_from_ancestor_ns() is fairly clean and it does not need
	  to be under CONFIG_PID_NS. Only siginfo_from_user() needs to be.
	- Warn if rt_sigqueueinfo() uses SI_ASYNCIO.
	- Added a check for pid-ns of receiver being NULL (in case it is
	  exiting).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 55f41b6..0011f99 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -820,6 +820,56 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 {
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
+/*
+ * Return 1 if this signal originated directly from a user process (i.e via
+ * kill(), tkill(), sigqueue()).  Return 0 otherwise.
+ *
+ * TODO:
+ * 	  To make this less hacky, make SI_ASYNCIO a kernel signal (and
+ * 	  remove the warning in sys_rt_sigqueueinfo()).
+ */
+#ifdef CONFIG_PID_NS
+static inline int siginfo_from_user(siginfo_t *info)
+{
+	if (!is_si_special(info) && SI_FROMUSER(info) &&
+				info->si_code != SI_ASYNCIO)
+		return 1;
+
+	return 0;
+}
+#else
+static inline int siginfo_from_user(siginfo_t *info)
+{
+	return 0;
+}
+#endif
+
+static inline int siginfo_from_ancestor_ns(struct task_struct *t,
+                       siginfo_t *info)
+{
+	struct pid_namespace *ns;
+
+	/*
+	 * Ensure signal is from user-space before checking pid namespace
+	 */
+	if (siginfo_from_user(info)) {
+		/*
+		 * If we do not have a pid in the receiver's namespace,
+		 * we must be an ancestor of the receiver. 
+		 *
+		 * CHECK:
+		 * 	If receiver is exiting, ns == NULL, signal will be
+		 * 	queued but ignored (wants_signal() is FALSES). For
+		 * 	compatibility with current behavior, assume it is
+		 * 	from ancestor and queue the signal anyway ?
+		 */
+		ns = task_active_pid_ns(t);
+		if (!ns || task_pid_nr_ns(current, ns) <= 0)
+			return 1;
+	}
+
+	return 0;
+}
 
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
@@ -2312,6 +2362,20 @@ sys_tkill(pid_t pid, int sig)
 	return do_tkill(0, pid, sig);
 }
 
+#ifdef CONFIG_PID_NS
+/*
+ * siginfo_from_user() assumes that si_code SI_ASYNCIO comes only from
+ * within the kernel. If an application is passing in SI_ASYNCIO we 
+ * want to know about it.
+ */
+static void warn_on_asyncio(siginfo_t *info)
+{
+	WARN_ON_ONCE(info->si_code == SI_ASYNCIO);
+}
+#else
+#define warn_on_asyncio(info)	{}
+#endif
+
 asmlinkage long
 sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 {
@@ -2324,6 +2388,9 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 	   Nor can they impersonate a kill(), which adds source info.  */
 	if (info.si_code >= 0)
 		return -EPERM;
+
+	warn_on_asyncio(&info);
+
 	info.si_signo = sig;
 
 	/* POSIX.1b doesn't mention process groups.  */
-- 
1.5.2.5
