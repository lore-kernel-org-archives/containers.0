From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 3/6][v5] Define siginfo_from_ancestor_ns()
Date: Sat, 27 Dec 2008 12:52:22 -0800
Message-ID: <20081227205222.GB27337@us.ibm.com>
References: <20081227204658.GA27197@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755086AbYL0UyX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081227204658.GA27197@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Wed, 24 Dec 2008 13:46:02 -0800
Subject: [PATCH 3/6][v5] Define siginfo_from_ancestor_ns()

Determine if sender of a signal is from an ancestor namespace. This
function will be used in a follow-on patch.

This is based on discussions on the patch from Oleg Nesterov and me
http://lkml.org/lkml/2008/11/25/462.

Changelog[v5]:
	- (Oleg Nesterov) Put siginfo_from_ancestor_ns() back under
	  CONFIG_PID_NS.
	- (Oleg Nesterov) Remove the warning in rt_sigqueueinfo().

Changelog[v4]:
	- siginfo_from_ancestor_ns() is fairly clean and it does not need
	  to be under CONFIG_PID_NS. Only siginfo_from_user() needs to be.
	- Warn if rt_sigqueueinfo() uses SI_ASYNCIO.
	- Added a check for pid-ns of receiver being NULL (in case it is
	  exiting).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 30b9c5c..f33100d 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -820,6 +820,61 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 {
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
+/*
+ * Return 1 if this signal originated directly from a user process (i.e via
+ * kill(), tkill(), sigqueue()).  Return 0 otherwise.
+ *
+ * TODO:
+ * 	  To make this less hacky, make SI_ASYNCIO a kernel signal.
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
+
+static inline int siginfo_from_ancestor_ns(struct task_struct *t,
+                       siginfo_t *info)
+{
+	struct pid_namespace *ns;
+
+	/*
+	 * Ensure signal is from user-space before checking pid namespace.
+	 * (We maybe called from interrupt context and dereferencing
+	 * pid namespace would be safe).
+	 */
+	if (siginfo_from_user(info)) {
+		/*
+		 * If we do not have a pid in the receiver's namespace,
+		 * we must be from an ancestor namespace.
+		 *
+		 * Note: 
+		 * 	If receiver is exiting, ns == NULL, signal will be
+		 * 	queued but eventually ignored anyway (wants_signal()
+		 * 	is FALSE). Assume here that signal is from ancestor
+		 * 	namespace and queue the signal.
+		 */
+		ns = task_active_pid_ns(t);
+		if (!ns || task_pid_nr_ns(current, ns) <= 0)
+			return 1;
+	}
+
+	return 0;
+}
+
+#else
+
+static inline int siginfo_from_ancestor_ns(struct task_struct *t,
+                       siginfo_t *info)
+{
+	return 0;
+}
+
+#endif
 
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
@@ -2324,6 +2379,7 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 	   Nor can they impersonate a kill(), which adds source info.  */
 	if (info.si_code >= 0)
 		return -EPERM;
+
 	info.si_signo = sig;
 
 	/* POSIX.1b doesn't mention process groups.  */
-- 
1.5.2.5
