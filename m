From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 7/7][v4] SI_TKILL: Masquerade si_pid when crossing pid
	ns boundary
Date: Wed, 24 Dec 2008 03:53:31 -0800
Message-ID: <20081224115331.GG8020@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751590AbYLXLz1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224114414.GA7879@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 7/7][v4] SI_TKILL: Masquerade si_pid when crossing pid ns boundary

When sending a signal to a process in a descendant namespace, ->si_pid
must be set to the pid of sender in receiver's namespace. But if the
receiver is exiting (theoretically, ns == NULL), just set ->si_pid to
active pid namespace of sender (receiver won't see the signal anyway ?).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 5a6aea8..e263c23 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2385,17 +2385,22 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
 	struct siginfo info;
 	struct task_struct *p;
 	unsigned long flags;
+	struct pid_namespace *ns;
 
 	error = -ESRCH;
 	info.si_signo = sig;
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
-	info.si_pid = task_tgid_vnr(current);
 	info.si_uid = current_uid();
 
 	rcu_read_lock();
 	p = find_task_by_vpid(pid);
 	if (p && (tgid <= 0 || task_tgid_vnr(p) == tgid)) {
+		ns = task_active_pid_ns(p);
+		if (ns)
+			info.si_pid = task_tgid_nr_ns(current, ns);
+		else
+			info.si_pid = task_tgid_vnr(current);
 		error = check_kill_permission(sig, &info, p);
 		/*
 		 * The null signal is a permissions and process existence
-- 
1.5.2.5
