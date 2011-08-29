From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH pm-freezer 2/4] freezer: set PF_NOFREEZE on a dying task
	right before TASK_DEAD
Date: Mon, 29 Aug 2011 16:05:09 +0200
Message-ID: <20110829140509.GC18871__36970.906207762$1314626938$gmane$org@mtj.dyndns.org>
References: <20110829140418.GB18871@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110829140418.GB18871-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

3fb45733df "freezer: make exiting tasks properly unfreezable" removed
clear_freeze_flag() from exit path and set PF_NOFREEZE right after
PTRACE_EVENT_EXIT; however, Oleg pointed out that following exit paths
may cause interaction with device drivers after PM freezer consider
the system frozen.

There's no try_to_freeze() call in the exit path and the only
necessary guarantee is that freezer doesn't hang waiting for zombies.
Set PF_NOFREEZE right before setting tsk->state to TASK_DEAD instead.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
---
 kernel/exit.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: work/kernel/exit.c
===================================================================
--- work.orig/kernel/exit.c
+++ work/kernel/exit.c
@@ -913,12 +913,6 @@ NORET_TYPE void do_exit(long code)
 
 	ptrace_event(PTRACE_EVENT_EXIT, code);
 
-	/*
-	 * With ptrace notification done, there's no point in freezing from
-	 * here on.  Disallow freezing.
-	 */
-	current->flags |= PF_NOFREEZE;
-
 	validate_creds_for_do_exit(tsk);
 
 	/*
@@ -1044,6 +1038,10 @@ NORET_TYPE void do_exit(long code)
 
 	preempt_disable();
 	exit_rcu();
+
+	/* this task is now dead and freezer should ignore it */
+	current->flags |= PF_NOFREEZE;
+
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	schedule();
