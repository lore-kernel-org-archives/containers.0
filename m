From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] freezer: set PF_NOFREEZE on a dying task right before
	TASK_DEAD setting bug in freezer_change_state()
Date: Sat,  3 Sep 2011 03:27:46 +0900
Message-ID: <1314988070-12244-3-git-send-email-tj__46283.1535413445$1314988174$gmane$org@kernel.org>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314988070-12244-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index ac58259..7b6c4fa 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
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
-- 
1.7.6
