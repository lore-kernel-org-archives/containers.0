From: sukadev@us.ibm.com
Subject: [PATCH 2/5] Rename child_reaper() function
Date: Sat, 14 Jul 2007 21:56:28 -0700
Message-ID: <20070715045628.GC25053@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756228AbXGOE4k@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: Pavel Emelianov <xemul@openvz.org>, serue@us.ibm.com, clg@fr.ibm.com, haveblue@us.ibm.com, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Pavel,

Pls ack this if you agree.

Suka
---

Subject: [PATCH 2/5] Rename child_reaper function.

From: Sukadev Bhattiprolu <sukadev@us.ibm.com>


Rename the child_reaper() function to task_child_reaper() to be
similar to other task_* functions and to distinguish the function
from 'struct pid_namspace.child_reaper'.

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
---
 fs/exec.c                     |    2 +-
 include/linux/pid_namespace.h |    2 +-
 kernel/exit.c                 |    4 ++--
 kernel/signal.c               |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

Index: lx26-22-rc6-mm1/include/linux/pid_namespace.h
===================================================================
--- lx26-22-rc6-mm1.orig/include/linux/pid_namespace.h	2007-07-13 13:07:48.000000000 -0700
+++ lx26-22-rc6-mm1/include/linux/pid_namespace.h	2007-07-13 13:12:01.000000000 -0700
@@ -44,7 +44,7 @@ static inline struct pid_namespace *task
 	return tsk->nsproxy->pid_ns;
 }
 
-static inline struct task_struct *child_reaper(struct task_struct *tsk)
+static inline struct task_struct *task_child_reaper(struct task_struct *tsk)
 {
 	return init_pid_ns.child_reaper;
 }
Index: lx26-22-rc6-mm1/fs/exec.c
===================================================================
--- lx26-22-rc6-mm1.orig/fs/exec.c	2007-07-13 13:07:48.000000000 -0700
+++ lx26-22-rc6-mm1/fs/exec.c	2007-07-13 13:12:01.000000000 -0700
@@ -826,7 +826,7 @@ static int de_thread(struct task_struct 
 	 * Reparenting needs write_lock on tasklist_lock,
 	 * so it is safe to do it under read_lock.
 	 */
-	if (unlikely(tsk->group_leader == child_reaper(tsk)))
+	if (unlikely(tsk->group_leader == task_child_reaper(tsk)))
 		task_active_pid_ns(tsk)->child_reaper = tsk;
 
 	zap_other_threads(tsk);
Index: lx26-22-rc6-mm1/kernel/exit.c
===================================================================
--- lx26-22-rc6-mm1.orig/kernel/exit.c	2007-07-13 13:07:48.000000000 -0700
+++ lx26-22-rc6-mm1/kernel/exit.c	2007-07-13 13:12:01.000000000 -0700
@@ -695,7 +695,7 @@ forget_original_parent(struct task_struc
 	do {
 		reaper = next_thread(reaper);
 		if (reaper == father) {
-			reaper = child_reaper(father);
+			reaper = task_child_reaper(father);
 			break;
 		}
 	} while (reaper->exit_state);
@@ -908,7 +908,7 @@ fastcall NORET_TYPE void do_exit(long co
 		panic("Aiee, killing interrupt handler!");
 	if (unlikely(!tsk->pid))
 		panic("Attempted to kill the idle task!");
-	if (unlikely(tsk == child_reaper(tsk))) {
+	if (unlikely(tsk == task_child_reaper(tsk))) {
 		if (task_active_pid_ns(tsk) != &init_pid_ns)
 			task_active_pid_ns(tsk)->child_reaper =
 					init_pid_ns.child_reaper;
Index: lx26-22-rc6-mm1/kernel/signal.c
===================================================================
--- lx26-22-rc6-mm1.orig/kernel/signal.c	2007-07-13 13:06:52.000000000 -0700
+++ lx26-22-rc6-mm1/kernel/signal.c	2007-07-13 13:12:01.000000000 -0700
@@ -1853,7 +1853,7 @@ relock:
 		 * within that pid space. It can of course get signals from
 		 * its parent pid space.
 		 */
-		if (current == child_reaper(current))
+		if (current == task_child_reaper(current))
 			continue;
 
 		if (sig_kernel_stop(signr)) {
