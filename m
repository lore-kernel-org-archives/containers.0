From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/11] pidns: Wait in zap_pid_ns_processes until
	pid_ns->nr_hashed == 1
Date: Fri, 16 Nov 2012 08:35:46 -0800
Message-ID: <1353083750-3621-7-git-send-email-ebiederm__26553.6778526895$1353083840$gmane$org@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Looking at pid_ns->nr_hashed is a bit simpler and it works for
disjoint process trees that an unshare or a join of a pid_namespace
may create.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/exit.c          |   12 ------------
 kernel/pid.c           |   16 +++++++++++++---
 kernel/pid_namespace.c |   15 ++++-----------
 3 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 346616c..d7fe58d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -72,18 +72,6 @@ static void __unhash_process(struct task_struct *p, bool group_dead)
 		list_del_rcu(&p->tasks);
 		list_del_init(&p->sibling);
 		__this_cpu_dec(process_counts);
-		/*
-		 * If we are the last child process in a pid namespace to be
-		 * reaped, notify the reaper sleeping zap_pid_ns_processes().
-		 */
-		if (IS_ENABLED(CONFIG_PID_NS)) {
-			struct task_struct *parent = p->real_parent;
-
-			if ((task_active_pid_ns(parent)->child_reaper == parent) &&
-			    list_empty(&parent->children) &&
-			    (parent->flags & PF_EXITING))
-				wake_up_process(parent);
-		}
 	}
 	list_del_rcu(&p->thread_group);
 }
diff --git a/kernel/pid.c b/kernel/pid.c
index 9c21911..6e8da29 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -273,10 +273,20 @@ void free_pid(struct pid *pid)
 	spin_lock_irqsave(&pidmap_lock, flags);
 	for (i = 0; i <= pid->level; i++) {
 		struct upid *upid = pid->numbers + i;
+		struct pid_namespace *ns = upid->ns;
 		hlist_del_rcu(&upid->pid_chain);
-		if (--upid->ns->nr_hashed == 0) {
-			upid->ns->nr_hashed = -1;
-			schedule_work(&upid->ns->proc_work);
+		switch(--ns->nr_hashed) {
+		case 1:
+			/* When all that is left in the pid namespace
+			 * is the reaper wake up the reaper.  The reaper
+			 * may be sleeping in zap_pid_ns_processes().
+			 */
+			wake_up_process(ns->child_reaper);
+			break;
+		case 0:
+			ns->nr_hashed = -1;
+			schedule_work(&ns->proc_work);
+			break;
 		}
 	}
 	spin_unlock_irqrestore(&pidmap_lock, flags);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index cc44db7..e106b18 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -216,22 +216,15 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 
 	/*
 	 * sys_wait4() above can't reap the TASK_DEAD children.
-	 * Make sure they all go away, see __unhash_process().
+	 * Make sure they all go away, see free_pid().
 	 */
 	for (;;) {
-		bool need_wait = false;
-
-		read_lock(&tasklist_lock);
-		if (!list_empty(&current->children)) {
-			__set_current_state(TASK_UNINTERRUPTIBLE);
-			need_wait = true;
-		}
-		read_unlock(&tasklist_lock);
-
-		if (!need_wait)
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		if (pid_ns->nr_hashed == 1)
 			break;
 		schedule();
 	}
+	__set_current_state(TASK_RUNNING);
 
 	if (pid_ns->reboot)
 		current->signal->group_exit_code = pid_ns->reboot;
-- 
1.7.5.4
