From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 6/7][v4] SI_USER: Masquerade si_pid when crossing pid
	ns boundary
Date: Wed, 24 Dec 2008 03:53:01 -0800
Message-ID: <20081224115301.GF8020@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753366AbYLXLyp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224114414.GA7879@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 6/7][v4] SI_USER: Masquerade si_pid when crossing pid ns boundary

When sending a signal to a descendant namespace, we must set ->si_pid to
0 since the sender does not have a valid pid in the descendant namespace.
But we cannot do this in sys_kill() since a) we do not yet know the pid
namespace of receiver b) the pid number in sys_kill() may correspond to
a process group and processes in the process group may be in different
namespaces. So masquerade si_pid at the lower level, send_signal()
function.

Note:
	- If rt_sigqueueinfo() sets si_code to SI_USER when sending a
	  signal across a pid namespace boundary, the value in ->si_pid
	  will be cleared to 0.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 660fadd..5a6aea8 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -885,6 +885,34 @@ static inline int siginfo_from_ancestor_ns(struct task_struct *t,
 	return 0;
 }
 
+/*
+ * masquerade_si_pid():
+ *
+ * 	Called when signal is crossing pid namespace boundary. Compute
+ * 	pid of sender in receiver's pid namespace.
+ *
+ * 	We only care about SI_USER here. Other si_codes are addressed
+ * 	either at the 'origin' of signal or set to a default value in
+ * 	send_signal(). But we can't address SI_USER at 'origin', i.e .
+ * 	in sys_kill(), since we may have a process group, rather than
+ * 	a specific process there. And different processes in same pgrp
+ * 	can be in different namespaces.
+ */
+static void masquerade_si_pid(struct task_struct *t, siginfo_t *info)
+{
+	if (is_si_special(info) || SI_FROMKERNEL(info))
+		return;
+
+	/*
+	 * When crossing pid namespace boundary, SI_USER signal can only
+	 * go from ancestor to descendant ns but not the other way. So,
+	 * just ->si_pid to 0 since, the sender will not have a pid in
+	 * the receiver's namespace.
+	 */
+	if (info->si_code == SI_USER)
+		info->si_pid = 0;
+}
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
 {
@@ -946,6 +974,8 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			break;
 		default:
 			copy_siginfo(&q->info, info);
+			if (from_ancestor_ns)
+				masquerade_si_pid(t, &q->info);
 			break;
 		}
 	} else if (!is_si_special(info)) {
@@ -2343,7 +2373,7 @@ sys_kill(pid_t pid, int sig)
 	info.si_signo = sig;
 	info.si_errno = 0;
 	info.si_code = SI_USER;
-	info.si_pid = task_tgid_vnr(current);
+	info.si_pid = 0;	/* masquerade in send_signal() */
 	info.si_uid = current_uid();
 
 	return kill_something_info(sig, &info, pid);
-- 
1.5.2.5
