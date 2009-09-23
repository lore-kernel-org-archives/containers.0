From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 27/80] c/r: introduce PF_RESTARTING,
	and skip notification on exit
Date: Wed, 23 Sep 2009 19:51:07 -0400
Message-ID: <1253749920-18673-28-git-send-email-orenl__14230.0020474524$1253752623$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

To restore zombie's we will create the a task, that, on its turn to
run, calls do_exit(). Unlike normal tasks that exit, we need to
prevent notification side effects that send signals to other
processes, e.g. parent (SIGCHLD) or child tasks (per child's request).

There are three main cases for such notifications:

1) do_notify_parent(): parent of a process is notified about a change
 in status (e.g. become zombie, reparent, etc). If parent ignores,
 then mark child for immediate release (skip zombie).

2) kill_orphan_pgrp(): a process group that becomes orphaned will
 signal stopped jobs (HUP then CONT).

3) reparent_thread(): children of a process are signaled (per request)
 with p->pdeath_signal

Remember that restoring signal state (for any restarting task) must
complete _before_ it is allowed to resume execution, and not during
the resume. Otherwise, a running task may send a signal to another
task that hasn't restored yet, so the new signal will be lost
soon-after.

I considered two possible way to address this:

1. Add another sync point to restart: all tasks will first restore
their state without signals (all signals blocked), and zombies call
do_exit(). A sync point then will ensure that all zombies are gone and
their effects done. Then all tasks restore their signal state (and
mask), and sync (new point) again. Only then they may resume
execution.
The main disadvantage is the added complexity and inefficiency,
for no good reason.

2. Introduce PF_RESTARTING: mark all restarting tasks with a new flag,
and teach the above three notifications to skip sending the signal if
theis flag is set.
The main advantage is simplicity and completeness. Also, such a flag
may to be useful later on. This the method implemented.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 kernel/exit.c   |    7 ++++++-
 kernel/signal.c |    4 ++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 912b1fa..41ac4cf 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -299,6 +299,10 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
 	struct pid *pgrp = task_pgrp(tsk);
 	struct task_struct *ignored_task = tsk;
 
+	/* restarting zombie doesn't trigger signals */
+	if (tsk->flags & PF_RESTARTING)
+		return;
+
 	if (!parent)
 		 /* exit: our father is in a different pgrp than
 		  * we are and we were the only connection outside.
@@ -739,7 +743,8 @@ static struct task_struct *find_new_reaper(struct task_struct *father)
 static void reparent_thread(struct task_struct *father, struct task_struct *p,
 				struct list_head *dead)
 {
-	if (p->pdeath_signal)
+	/* restarting zombie doesn't trigger signals */
+	if (p->pdeath_signal && !(p->flags & PF_RESTARTING))
 		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
 
 	list_move_tail(&p->sibling, &p->real_parent->children);
diff --git a/kernel/signal.c b/kernel/signal.c
index 64c5dee..ea217b0 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1413,6 +1413,10 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	BUG_ON(!task_ptrace(tsk) &&
 	       (tsk->group_leader != tsk || !thread_group_empty(tsk)));
 
+	/* restarting zombie doesn't notify parent */
+	if (tsk->flags & PF_RESTARTING)
+		return ret;
+
 	info.si_signo = sig;
 	info.si_errno = 0;
 	/*
-- 
1.6.0.4
