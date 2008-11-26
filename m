From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 4/5] Protect cinit from fatal signals
Date: Tue, 25 Nov 2008 19:46:34 -0800
Message-ID: <20081126034634.GD23238@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754536AbYKZDrA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081126034242.GA23120@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From 4ea8f0b4ae48da5f18d44b68ce3634408c89f230 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Tue, 25 Nov 2008 10:29:10 -0800
Subject: [PATCH 4/5] Protect cinit from fatal signals

To protect container-init from fatal signals, set SIGNAL_UNKILLABLE but
clear it if it receives SIGKILL from parent namespace - so it is still
killable from ancestor namespace.

Note that container-init is still somewhat special compared to 'normal
processes' - unhandled fatal signals like SIGUSR1 to a container-init
are dropped even if they are from ancestor namespace. SIGKILL from an
ancestor namespace is the only reliable way to kill a container-init.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/fork.c   |    2 ++
 kernel/signal.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 28be39a..368f25c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -814,6 +814,8 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	atomic_set(&sig->live, 1);
 	init_waitqueue_head(&sig->wait_chldexit);
 	sig->flags = 0;
+	if (clone_flags & CLONE_NEWPID)
+		sig->flags |= SIGNAL_UNKILLABLE;
 	sig->group_exit_code = 0;
 	sig->group_exit_task = NULL;
 	sig->group_stop_count = 0;
diff --git a/kernel/signal.c b/kernel/signal.c
index 45aebf0..8c294c1 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -828,6 +828,8 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 	trace_sched_signal_send(sig, t);
 
 	from_ancestor_ns = siginfo_from_ancestor_ns(t, info);
+	if (from_ancestor_ns && sig == SIGKILL)
+		t->signal->flags &= ~SIGNAL_UNKILLABLE;
 
 	assert_spin_locked(&t->sighand->siglock);
 	if (!prepare_signal(sig, t))
-- 
1.5.2.5
