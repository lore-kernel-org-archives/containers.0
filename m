From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/11] pidns: Consolidate initialzation of special init task
	state
Date: Fri, 16 Nov 2012 08:35:49 -0800
Message-ID: <1353083750-3621-10-git-send-email-ebiederm@xmission.com>
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

Instead of setting child_reaper and SIGNAL_UNKILLABLE one way
for the system init process, and another way for pid namespace
init processes test pid->nr == 1 and use the same code for both.

For the global init this results in SIGNAL_UNKILLABLE being set
much earlier in the initialization process.

This is a small cleanup and it paves the way for allowing unshare and
enter of the pid namespace as that path like our global init also will
not set CLONE_NEWPID.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/main.c   |    1 -
 kernel/fork.c |    6 +++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/init/main.c b/init/main.c
index 9cf77ab..317750a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -810,7 +810,6 @@ static int __ref kernel_init(void *unused)
 	system_state = SYSTEM_RUNNING;
 	numa_default_policy();
 
-	current->signal->flags |= SIGNAL_UNKILLABLE;
 	flush_delayed_fput();
 
 	if (ramdisk_execute_command) {
diff --git a/kernel/fork.c b/kernel/fork.c
index 666dc8b..0f2bbce 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1039,8 +1039,6 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	atomic_set(&sig->live, 1);
 	atomic_set(&sig->sigcnt, 1);
 	init_waitqueue_head(&sig->wait_chldexit);
-	if (clone_flags & CLONE_NEWPID)
-		sig->flags |= SIGNAL_UNKILLABLE;
 	sig->curr_target = tsk;
 	init_sigpending(&sig->shared_pending);
 	INIT_LIST_HEAD(&sig->posix_timers);
@@ -1441,8 +1439,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		ptrace_init_task(p, (clone_flags & CLONE_PTRACE) || trace);
 
 		if (thread_group_leader(p)) {
-			if (is_child_reaper(pid))
+			if (is_child_reaper(pid)) {
 				ns_of_pid(pid)->child_reaper = p;
+				p->signal->flags |= SIGNAL_UNKILLABLE;
+			}
 
 			p->signal->leader_pid = pid;
 			p->signal->tty = tty_kref_get(current->signal->tty);
-- 
1.7.5.4
