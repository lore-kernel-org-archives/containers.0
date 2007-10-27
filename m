From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] fork: Don't special case CLONE_NEWPID for process or
	sessions
Date: Fri, 26 Oct 2007 19:49:48 -0600
Message-ID: <m11wbhuy0z.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Given that the kernel supports sys_setsid we don't need a special case
in fork if we want to set: session == pgrp == pid.

The historical (although not 2.6) linux behavior has been to start the
init with session == pgrp == 0 which is effectively what removing this
special case will do. 

Is there any reason why we want/need this special case in fork?  Or
can we remove it and save some code, make copy_process easier to read
easier to maintain, and possibly a little faster?

I know it is a little weird belong to a process groups that isn't
visible in your pid namespace, but it there are no good reasons
why it shouldn't work.

I think making this change makes the interface more flexible,
and general.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index ddafdfa..b0de799 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1292,20 +1292,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		if (thread_group_leader(p)) {
 			if (clone_flags & CLONE_NEWPID) {
 				p->nsproxy->pid_ns->child_reaper = p;
-				p->signal->tty = NULL;
-				set_task_pgrp(p, p->pid);
-				set_task_session(p, p->pid);
-				attach_pid(p, PIDTYPE_PGID, pid);
-				attach_pid(p, PIDTYPE_SID, pid);
-			} else {
-				p->signal->tty = current->signal->tty;
-				set_task_pgrp(p, task_pgrp_nr(current));
-				set_task_session(p, task_session_nr(current));
-				attach_pid(p, PIDTYPE_PGID,
-						task_pgrp(current));
-				attach_pid(p, PIDTYPE_SID,
-						task_session(current));
 			}
+			p->signal->tty = current->signal->tty;
+			set_task_pgrp(p, task_pgrp_nr(current));
+			set_task_session(p, task_session_nr(current));
+			attach_pid(p, PIDTYPE_PGID, task_pgrp(current));
+			attach_pid(p, PIDTYPE_SID, task_session(current));
 
 			list_add_tail_rcu(&p->tasks, &init_task.tasks);
 			__get_cpu_var(process_counts)++;
-- 
1.5.3.rc6.17.g1911
