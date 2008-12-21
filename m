From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 4/6][v3] Define siginfo_from_ancestor_ns()
Date: Sat, 20 Dec 2008 16:54:24 -0800
Message-ID: <20081221005424.GD5025@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755559AbYLUAz4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081221005106.GA4912@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Sat, 20 Dec 2008 12:19:29 -0800
Subject: [RFC][PATCH 4/6][v3] Define siginfo_from_ancestor_ns()

Determine if sender of a signal is from an ancestor namespace. This
function will be used in a follow-on patch.

This is an early/lightly tested RFC patch. Would it be safe to implement
siginfo_from_user() as below and then use it dereference the pid
namespace of sender ?

This is based on discussions on the patch from Oleg Nesterov and me
http://lkml.org/lkml/2008/11/25/462.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 55f41b6..058b4c0 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -820,6 +820,47 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 {
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
+/*
+ * Return 1 if this signal originated directly from a user process (i.e via
+ * kill(), tkill(), sigqueue()).  Return 0 otherwise.
+ *
+ * TODO:
+ * 	  Making SI_ASYNCIO a kernel signal could make this less hacky.
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
+	/*
+	 * Ensure signal is from user-space before checking pid namespace
+	 */
+	if (siginfo_from_user(info)) {
+		/*
+		 * If we do not have a pid in the receiver's namespace,
+		 * we must be an ancestor of the receiver.
+		 */
+		if (task_pid_nr_ns(current, task_active_pid_ns(t)) <= 0)
+			return 1;
+	}
+
+	return 0;
+}
+#else
+static inline int siginfo_from_ancestor_ns(struct task_struct *t, siginfo_t *info)
+{
+       return 0;
+}
+#endif
+
 
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
-- 
1.5.2.5
