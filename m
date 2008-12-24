From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals
Date: Wed, 24 Dec 2008 03:52:29 -0800
Message-ID: <20081224115229.GE8020@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753280AbYLXLyT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224114414.GA7879@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals

Normally SIG_DFL signals to global and container-init are dropped early.
But if a signal is blocked when it is posted, we cannot drop the signal
since the receiver may install a handler before unblocking the signal.
Once this signal is queued however, the receiver container-init has
no way of knowing if the signal was sent from an ancestor or descendant
namespace.  This patch ensures that contianer-init drops all SIG_DFL
signals in get_signal_to_deliver() except SIGKILL/SIGSTOP.

If SIGSTOP/SIGKILL originate from a descendant of container-init they
are never queued (i.e dropped in sig_ignored() in an earler patch).

If SIGSTOP/SIGKILL originate from parent namespace, the signal is queued
and container-init processes the signal.

See comments in patch below for details.

Changelog[v2]:
	- Rename sig_unkillable() to unkillable_by_sig()
	- Remove SIGNAL_UNKILLABLE_FROM_NS flag and simplify (Oleg Nesterov)
	- Set SIGNAL_UNKILLABLE for container-init in this patch.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/fork.c   |    2 ++
 kernel/signal.c |   41 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index dba2d3f..d3e93ef 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -812,6 +812,8 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	atomic_set(&sig->live, 1);
 	init_waitqueue_head(&sig->wait_chldexit);
 	sig->flags = 0;
+	if (clone_flags & CLONE_NEWPID)
+		sig->flags |= SIGNAL_UNKILLABLE;
 	sig->group_exit_code = 0;
 	sig->group_exit_task = NULL;
 	sig->group_stop_count = 0;
diff --git a/kernel/signal.c b/kernel/signal.c
index 5c4374f..660fadd 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1818,6 +1818,41 @@ static int ptrace_signal(int signr, siginfo_t *info,
 	return signr;
 }
 
+/*
+ * Return 1 if the process owning @signal should NOT terminate as a result of
+ * the signal @signr. Return 0 otherwise.
+ *
+ * Specifically if process owning @signal is
+ * 	- neither global nor a container-init, return 0
+ *	- the global-init, return 1.
+ *	- container-init, return 0 if signal is SIGKILL or SIGSTOP. Return
+ *	  1 otherwise.
+ *
+ * sig_ignored() drops any unblocked fatal signals to global/container-init
+ * from within the same namespace. This of course includes SIGKILL/SIGSTOP
+ * which can never be blocked.  sig_ignored() does not drop the SIGKILL/
+ * SIGSTOP if the are from an ancestor namespace.
+ *
+ * So, @signal is for a container-init and if @signr is either SIGKILL or
+ * SIGSTOP, it must have come from an ancestor namespace. So container-init
+ * should be killable (return 0).
+ *
+ * If @signal refers to a container-init and @signr is neither SIGKILL nor
+ * SIGSTOP, it was queued because it was blocked when it was posted. The
+ * signal may have come from same container - hence it should not be
+ * killable (return 1).
+ *
+ * Note:
+ * 	This means that SIGKILL is the only sure way to terminate a
+ * 	container-init even from ancestor namespace.
+ */
+static int unkillable_by_sig(struct signal_struct *signal, int signr)
+{
+	if ((signal->flags & SIGNAL_UNKILLABLE) && !sig_kernel_only(signr))
+		return 1;
+	return 0;
+}
+
 int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 			  struct pt_regs *regs, void *cookie)
 {
@@ -1909,9 +1944,11 @@ relock:
 
 		/*
 		 * Global init gets no signals it doesn't want.
+		 * Container-init gets no signals it doesn't want from same
+		 * container.
 		 */
-		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
-		    !signal_group_exit(signal))
+		if (unkillable_by_sig(signal, signr) &&
+				!signal_group_exit(signal))
 			continue;
 
 		if (sig_kernel_stop(signr)) {
-- 
1.5.2.5
