From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/15] Move exit_task_namespaces()
Date: Thu, 26 Jul 2007 18:46:28 +0400
Message-ID: <46A8B3C4.5080601@openvz.org>
References: <46A8B37B.6050108@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A8B37B.6050108-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Make task release its namespaces after it has reparented all his
children to child_reaper, but before it notifies its parent about
its death.

The reason to release namespaces after reparenting is that when task
exits it may send a signal to its parent (SIGCHLD), but if the parent
has already exited its namespaces there will be no way to decide what
pid to dever to him - parent can be from different namespace.

The reason to release namespace before notifying the parent it that
when task sends a SIGCHLD to parent it can call wait() on this taks
and release it. But releasing the mnt namespace implies dropping
of all the mounts in the mnt namespace and NFS expects the task to
have valid sighand pointer.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

 exit.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -upr linux-2.6.23-rc1-mm1.orig/kernel/exit.c linux-2.6.23-rc1-mm1-7/kernel/exit.c
--- linux-2.6.23-rc1-mm1.orig/kernel/exit.c	2007-07-26 16:34:45.000000000 +0400
+++ linux-2.6.23-rc1-mm1-7/kernel/exit.c	2007-07-26 16:36:37.000000000 +0400
@@ -788,6 +804,10 @@ static void exit_notify(struct task_stru
 	BUG_ON(!list_empty(&tsk->children));
 	BUG_ON(!list_empty(&tsk->ptrace_children));
 
+	write_unlock_irq(&tasklist_lock);
+	exit_task_namespaces(tsk);
+	write_lock_irq(&tasklist_lock);
+
 	/*
 	 * Check to see if any process groups have become orphaned
 	 * as a result of our exiting, and if they have any stopped
@@ -999,7 +1021,6 @@ fastcall NORET_TYPE void do_exit(long co
 
 	tsk->exit_code = code;
 	proc_exit_connector(tsk);
-	exit_task_namespaces(tsk);
 	exit_notify(tsk);
 #ifdef CONFIG_NUMA
 	mpol_free(tsk->mempolicy);
