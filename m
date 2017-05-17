From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] pid namespace fixes for v4.12-rc2
Date: Wed, 17 May 2017 18:42:08 -0500
Message-ID: <87inkz82zz.fsf__41801.1701702655$1495064925$gmane$org@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Vovo Yang <vovoy-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 3fd37226216620c1a468afa999739d5016fbc349 pid_ns: Fix race between setns'ed fork() and zap_pid_ns_processes()


These are two bugs that turn out to have simple fixes that were reported
during the merge window.  Both of these issues have existed for a while
and it just happens that they both were reported at almost the same
time.

Eric W. Biederman (1):
      pid_ns: Sleep in TASK_INTERRUPTIBLE in zap_pid_ns_processes

Kirill Tkhai (1):
      pid_ns: Fix race between setns'ed fork() and zap_pid_ns_processes()

 kernel/fork.c          | 8 ++++++--
 kernel/pid_namespace.c | 2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 06d759ab4c62..aa1076c5e4a9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1845,11 +1845,13 @@ static __latent_entropy struct task_struct *copy_process(
 	*/
 	recalc_sigpending();
 	if (signal_pending(current)) {
-		spin_unlock(&current->sighand->siglock);
-		write_unlock_irq(&tasklist_lock);
 		retval = -ERESTARTNOINTR;
 		goto bad_fork_cancel_cgroup;
 	}
+	if (unlikely(!(ns_of_pid(pid)->nr_hashed & PIDNS_HASH_ADDING))) {
+		retval = -ENOMEM;
+		goto bad_fork_cancel_cgroup;
+	}
 
 	if (likely(p->pid)) {
 		ptrace_init_task(p, (clone_flags & CLONE_PTRACE) || trace);
@@ -1907,6 +1909,8 @@ static __latent_entropy struct task_struct *copy_process(
 	return p;
 
 bad_fork_cancel_cgroup:
+	spin_unlock(&current->sighand->siglock);
+	write_unlock_irq(&tasklist_lock);
 	cgroup_cancel_fork(p);
 bad_fork_free_pid:
 	cgroup_threadgroup_change_end(current);
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index d1f3e9f558b8..74a5a7255b4d 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -277,7 +277,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 	 * if reparented.
 	 */
 	for (;;) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
+		set_current_state(TASK_INTERRUPTIBLE);
 		if (pid_ns->nr_hashed == init_pids)
 			break;
 		schedule();


Eric
