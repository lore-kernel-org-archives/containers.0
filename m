From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 2/6][v5] Protect init from unwanted signals more
Date: Sat, 27 Dec 2008 12:51:53 -0800
Message-ID: <20081227205153.GA27337@us.ibm.com>
References: <20081227204658.GA27197@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754859AbYL0Uxu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081227204658.GA27197@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Oleg Nesterov <oleg@redhat.com>
Date: Wed, 24 Dec 2008 13:35:23 -0800
Subject: [PATCH 2/6][v5] Protect init from unwanted signals more

(This is a modified version of the patch submitted by Oleg Nesterov
http://lkml.org/lkml/2008/11/18/249 and tries to address comments
that came up in that discussion)

init ignores the SIG_DFL signals but we queue them anyway, including
SIGKILL. This is mostly OK, the signal will be dropped silently when
dequeued, but the pending SIGKILL has 2 bad implications:

        - it implies fatal_signal_pending(), so we confuse things
          like wait_for_completion_killable/lock_page_killable.

        - for the sub-namespace inits, the pending SIGKILL can
          mask (legacy_queue) the subsequent SIGKILL from the
          parent namespace which must kill cinit reliably.
          (preparation, cinits don't have SIGNAL_UNKILLABLE yet)

The patch can't help when init is ptraced, but ptracing of init is
not "safe" anyway.

Changelog[v5]:
	- (Oleg Nesterov) Remove SIG_IGN check in sig_task_ignored()
	  and let sig_handler_ignored() check SIG_IGN.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Roland McGrath <roland@redhat.com>
---
 kernel/signal.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 7945e71..30b9c5c 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -53,10 +53,21 @@ static int sig_handler_ignored(void __user *handler, int sig)
 		(handler == SIG_DFL && sig_kernel_ignore(sig));
 }
 
-static int sig_ignored(struct task_struct *t, int sig)
+static int sig_task_ignored(struct task_struct *t, int sig)
 {
 	void __user *handler;
 
+	handler = sig_handler(t, sig);
+
+	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
+			handler == SIG_DFL)
+		return 1;
+	
+	return sig_handler_ignored(handler, sig);
+}
+
+static int sig_ignored(struct task_struct *t, int sig)
+{
 	/*
 	 * Blocked signals are never ignored, since the
 	 * signal handler may change by the time it is
@@ -65,8 +76,7 @@ static int sig_ignored(struct task_struct *t, int sig)
 	if (sigismember(&t->blocked, sig) || sigismember(&t->real_blocked, sig))
 		return 0;
 
-	handler = sig_handler(t, sig);
-	if (!sig_handler_ignored(handler, sig))
+	if (!sig_task_ignored(t, sig))
 		return 0;
 
 	/*
-- 
1.5.2.5
