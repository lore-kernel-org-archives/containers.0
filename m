From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] pidns: Fix wait for zombies to be reaped in zap_pid_ns_processes
Date: Mon, 12 Jul 2010 11:09:47 -0700
Message-ID: <m1tyo4shas.fsf_-_@fess.ebiederm.org>
References: <20100625192945.GA25532@redhat.com>
	<20100625212618.GA11917@us.ibm.com>
	<20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
	<m1lj9k4xfx.fsf@fess.ebiederm.org>
	<20100709141324.GC18586@hawkmoon.kerlabs.com>
	<m1aaq04ph2.fsf_-_@fess.ebiederm.org>
	<20100711141406.GD18586@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100711141406.GD18586@hawkmoon.kerlabs.com> (Louis Rilling's message of "Sun\, 11 Jul 2010 16\:14\:07 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "Serge E. Hallyn" <serge@hallyn.com>
List-Id: containers.vger.kernel.org


Fix zap_pid_ns_processes so that it successfully waits for all of
the tasks in the pid namespace to be reaped, even if called for a
non-leader task of the init process.  This guarantees that no task
can escpae the pid namespace, and that it is safe for proc_flush_task
to put the proc_mnt of the dead pid_namespace when pid 1 of the
pid namespace calls proc_flush_task.

Before zap_pid_ns_processes was fixed to wait for all zombies
in the pid namespace to be reaped the easiest way to generate
a zombie that would escape the pid namespace would be to attach
a debugger to a process inside a pidnamespace from outside the
pid namespace and then exit the pid namespace.

In the process of trying to fix this bug I have looked at a lot
of different options and a lot of different directions we can
go.  There are several limiting factors.

- We need to guarantee that the init process of a pid namespace
  is not reaped before every other task in the pid namespace is
  reaped.  Wait succeeding on the init process of a pid namespace
  gives the guarantee that all processes in the pid namespace
  are dead and gone.  Or more succinctly it is not possible to
  escape from a pid namespace.

  The previous behaviour where some zombies could escape the pid
  namespace violates the assumption made by some reapers of a pid
  namespace init that all of the pid namespace cleanup has completed
  by the time that init is reaped.

- proc_flush_task needs to be called after each task is reaped.
  Tasks are volatile and applications like top and ps frequently
  touch every thread group directory in /proc which triggers dcache
  entries to be created.  If we don't remove those dcache entries
  when tasks are reaped we can get a large build up of useless
  inodes and dentries.  Shrink_slab is designed to flush out useful
  cache entries not useless ones so while in the big picture it doesn't
  hurt if we leak a few if we leak a lot of dentries we put unnatural
  pressure on the kernels memory managment.

  I sat down and attempted to measure the cost of calling
  proc_flush_task with lat_tcp (from lmbench) and I get the same
  range of latency readings wether or not proc_flush_task is
  called.  Which tells me the runtime cost of the existing
  proc_flush_task is in the noise.

  By running find /proc/ > /dev/null with proc_flush_task
  disabled and then examining the counts in the slabcache
  I managed to see us growing about 84 proc_inodes per
  iteration, which is pretty horrific.  With proc_flush_task
  enabled I don't see steady growth in any of the slab caches.

- Mounts of the /proc need a referenece to the pid namespace
  that doesn't go away until /proc is unmounted.  Without
  holding a reference to the pid namespace that lasts until
  a /proc is unmounted it just isn't safe to lookup and display
  pids in a particular pid_namespace.

- The pid_namespace needs to be able to access proc_mnt until
  the at least the last call of proc_flush_task, for a
  pid_namespace.

  Currently there is a the circular reference between proc_mnt
  and the pid_namespace that we break very carefully through
  an interaction of zap_pid_ns_processes, and proc_flush_task.
  That clever interaction going wrong is what caused oopses
  that led us to realize we have a problem.

  Even if we fix the pid_namespace and the proc_mnt to have
  conjoined lifetimes and the oopses are fixed we still have
  the problem that zombie processes can escape the pid namespace.
  Which appears to be a problem for people using pid_namespaces
  as inescapable process containers.

- fork/exec/waitpid is a common kernel path and as such we need
  to keep the runtime costs down.  Which means as much as possible
  we want to keep from adding code (especially expensive code)
  into the fork/exec/waitpid code path.

  Changing zap_pid_ns_processes to fix the problem instead of
  changing the code elsewhere is one of the few solutions I have
  seen that does not increase the cost of the lat_proc test from
  lmbench.

Reported-by: Louis Rilling <Louis.Rilling@kerlabs.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 kernel/pid_namespace.c |   50 ++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index a5aff94..aaf2ab0 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -139,16 +139,20 @@ void free_pid_ns(struct kref *kref)
 
 void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 {
+	struct task_struct *me = current;
 	int nr;
 	int rc;
 	struct task_struct *task;
 
 	/*
-	 * The last thread in the cgroup-init thread group is terminating.
-	 * Find remaining pid_ts in the namespace, signal and wait for them
-	 * to exit.
+	 * The last task in the pid namespace-init threa group is terminating.
+	 * Find remaining pids in the namespace, signal and wait for them
+	 * to to be reaped.
 	 *
-	 * Note:  This signals each threads in the namespace - even those that
+	 * By waiting for all of the tasks to be reaped before init is reaped
+	 * we provide the invariant that no task can escape the pid namespace.
+	 *
+	 * Note:  This signals each task in the namespace - even those that
 	 * 	  belong to the same thread group, To avoid this, we would have
 	 * 	  to walk the entire tasklist looking a processes in this
 	 * 	  namespace, but that could be unnecessarily expensive if the
@@ -157,28 +161,50 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 	 *
 	 */
 	read_lock(&tasklist_lock);
-	nr = next_pidmap(pid_ns, 1);
-	while (nr > 0) {
-		rcu_read_lock();
+	for (nr = next_pidmap(pid_ns, 0); nr > 0; nr = next_pidmap(pid_ns, nr)) {
 
 		/*
 		 * Any nested-container's init processes won't ignore the
 		 * SEND_SIG_NOINFO signal, see send_signal()->si_fromuser().
 		 */
-		task = pid_task(find_vpid(nr), PIDTYPE_PID);
-		if (task)
+		rcu_read_lock();
+		task = pid_task(find_pid_ns(nr, pid_ns), PIDTYPE_PID);
+		if (task && !same_thread_group(task, me))
 			send_sig_info(SIGKILL, SEND_SIG_NOINFO, task);
-
 		rcu_read_unlock();
-
-		nr = next_pidmap(pid_ns, nr);
 	}
 	read_unlock(&tasklist_lock);
 
+	/* Nicely reap all of the remaining children in the namespac */
 	do {
 		clear_thread_flag(TIF_SIGPENDING);
 		rc = sys_wait4(-1, NULL, __WALL, NULL);
 	} while (rc != -ECHILD);
+       
+
+repeat:
+	/* Brute force wait for any remaining tasks to pass unhash_process
+	 * in release_task.  Once a task has passed unhash_process there
+	 * is no pid_namespace state left and they can be safely ignored.
+	 */
+	for (nr = next_pidmap(pid_ns, 1); nr > 0; nr = next_pidmap(pid_ns, nr)) {
+
+		/* Are there any tasks alive in this pid namespace */
+		rcu_read_lock();
+		task = pid_task(find_pid_ns(nr, pid_ns), PIDTYPE_PID);
+		rcu_read_unlock();
+		if (task && !same_thread_group(task, me)) {
+			clear_thread_flag(TIF_SIGPENDING);
+			schedule_timeout_interruptible(HZ/10);
+			goto repeat;
+		}
+	}
+	/* At this point there are at most two tasks in the pid namespace.
+	 * These tasks are our current task, and if we aren't pid 1 the zombie
+	 * of pid 1. In either case pid 1 will be the final task reaped in this
+	 * pid namespace, as non-leader threads are self reaping and leaders
+	 * cannot be reaped until all of their siblings have been reaped.
+	 */
 
 	acct_exit_ns(pid_ns);
 	return;
-- 
1.6.5.2.143.g8cc62
