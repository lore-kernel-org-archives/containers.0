From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH][v2] SEND_SIG_NOINFO: Masquerade si_pid when crossing
	pid-ns boundary
Date: Tue, 16 Dec 2008 18:04:35 -0800
Message-ID: <20081217020435.GA2866@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758008AbYLQCFq@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com
Cc: daniel@hozac.com, bastian@waldi.eu.org, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Fri, 12 Dec 2008 17:51:43 -0800
Subject: [PATCH] SEND_SIG_NOINFO: Masquerade si_pid when crossing pid-ns boundary

For SEND_SIG_NOINFO, si_pid is currently set to the pid of sender
in sender's active pid namespace. But if the receiver is in a
different namespace, that given pid number would be incorrect.
Eg: when parent sends the 'pdeath_signal' to a child that is in
a descendant pid namespace, we should set si_pid 0.

Changelog[v2]
	- Moved change from task_pid() to task_tgid() to separate patch

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 2a64304..d11e5f8 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -856,7 +856,8 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			q->info.si_signo = sig;
 			q->info.si_errno = 0;
 			q->info.si_code = SI_USER;
-			q->info.si_pid = task_pid_vnr(current);
+			q->info.si_pid = task_pid_nr_ns(current,
+							task_active_pid_ns(t));
 			q->info.si_uid = current_uid();
 			break;
 		case (unsigned long) SEND_SIG_PRIV:
-- 
1.5.2.5
