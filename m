From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 3/7][v8] Add from_ancestor_ns parameter to send_signal()
Date: Wed, 18 Feb 2009 19:06:13 -0800
Message-ID: <20090219030613.GC18990@us.ibm.com>
References: <20090219030207.GA18783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754859AbZBSDGm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090219030207.GA18783@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Tue, 6 Jan 2009 17:28:05 -0800
Subject: [PATCH 3/7][v8] Add from_ancestor_ns parameter to send_signal()

send_signal() (or its helper) needs to determine the pid namespace
of the sender. But a signal sent via kill_pid_info_as_uid() comes
from within the kernel and send_signal() does not need to determine
the pid namespace of the sender. So define a helper for send_signal()
which takes an additional parameter, 'from_ancestor_ns' and have
kill_pid_info_as_uid() use that helper directly.

The 'from_ancestor_ns' parameter will be used in a follow-on patch.

Changelog[v6]:
	- New patch added to this patchset, based on suggestions from
	  Roland McGrath and Oleg Nesterov.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 8761e4c..ff1dff9 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -823,8 +823,8 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
-static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
-			int group)
+static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
+			int group, int from_ancestor_ns)
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
@@ -899,6 +899,12 @@ out_set:
 	return 0;
 }
 
+static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
+			int group)
+{
+	return __send_signal(sig, info, t, group, 0);
+}
+
 int print_fatal_signals;
 
 static void print_fatal_signal(struct pt_regs *regs, int signr)
@@ -1143,7 +1149,7 @@ int kill_pid_info_as_uid(int sig, struct siginfo *info, struct pid *pid,
 	if (sig && p->sighand) {
 		unsigned long flags;
 		spin_lock_irqsave(&p->sighand->siglock, flags);
-		ret = __group_send_sig_info(sig, info, p);
+		ret = __send_signal(sig, info, p, 1, 0);
 		spin_unlock_irqrestore(&p->sighand->siglock, flags);
 	}
 out_unlock:
-- 
1.5.2.5
