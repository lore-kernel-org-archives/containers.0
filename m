From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Tue, 23 Mar 2010 14:28:34 -0700
Message-ID: <20100323212834.GH20796__7034.82156754962$1269379867$gmane$org@count0.beaverton.ibm.com>
References: <20100321195044.GA23757@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100321195044.GA23757-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Mar 21, 2010 at 08:50:44PM +0100, Grzegorz Nosek wrote:

<snip>

> 2. Weird strace behaviour across pidns boundary
> 
> When strace'ing (with -ff) lxc-start, I get a proper strace for the
> directly spawned process and the container init. However, any processes
> spawned by the container's init are not straced properly (I get two
> empty files, named <foo>.<pid-in-root-ns> and <foo>.2 -- presumably pid
> inside the container). The container also seems to malfunction under
> strace (looks like exec() failing as lxc-ps shows two "init" processes).
> 
> This is quite painful as it prevents strace'ing processes in containers
> even after startup. Here's a snippet of strace'ing a bash (pid 179
> inside, pid 2959 outside) trying to run 'ls'. The shell hangs until I
> kill the strace process.
> 
> pipe([3, 4])                            = 0
> clone(Process 197 attached
> child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7859708) = 197
> Process 2999 attached (waiting for parent)
> [pid  2959] setpgid(197, 197)           = 0
> [pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
> [pid  2959] close(3)                    = 0
> [pid  2959] close(4)                    = 0
> [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD TSTP TTIN TTOU], [CHLD], 8) = 0
> [pid  2959] ioctl(255, TIOCSPGRP, [197]) = 0
> [pid  2959] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
> [pid  2959] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> [pid  2959] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
> [pid  2959] waitpid(-1, Process 2959 suspended
> ^C <unfinished ...>
> Process 2959 detached
> Process 197 detached
> Process 2999 detached
> 
> 'strace ls' ran completely inside the container works as expected.

I'm suprised strace of ls works across pid namespaces. I've been looking
at strace and it seemed to me that one kernel change and a bunch of strace
changes are needed to make strace'ing in child pid namespaces work. Eric
Biederman's setns() patches also might help.

Can you get a little farther with the kernel fix below?

    Fix incorrect pid namespace used by ptrace during fork/vfork/clone
    
    pid namespaces are not used properly by ptrace in do_fork(). When tracing
    parent != real_parent because parent is the tracing task. Yet the pid in
    the real_parent's namespace is being used in do_fork():
    
    	nr = task_pid_vnr(p); /* uses real_parent's pid namespace */
    	if (clone_flags & CLONE_PARENT_SETTID)
    		put_user(nr, parent_tidptr); /* "real_parent_tidptr" */
    	...
    	tracehook_report_clone_complete(trace, regs,
    					clone_flags, nr, p); /* ptrace broken */
    
    	if (clone_flags & CLONE_VFORK) {
    		freezer_do_not_count();
    		wait_for_completion(&vfork);
    		freezer_count();
    		tracehook_report_vfork_done(p, nr); /* ptrace broken */
    
    In this case re-using the value in nr is wrong.
    
    This bug can be seen by attaching to an already-running task
    in a descendent namespace with strace -f. When the traced task forks
    strace won't attach to the new task properly because it sees the
    incorrect pid. For example, if root is running on two VTs and
    root@VTN# indicates switching to VT N:
    
    root@VT1# ns_exec -cp /bin/bash
    root@VT1# echo $$
    1
    root@VT2# strace -f -e fork,vfork,clone -p <pid of bash>
    Process 14518 attached - interrupt to quit
    root@VT1# /bin/bash
    <stops -- new bash shell does not respond to input>
    root@VT2#
    clone(Process 15 attached ... ) = 15
    Process 15044 attached (waiting for parent)
    Process 14518 suspended
    <no more output>
    <hit ctrl-c>
    root@VT1# echo $$
    15
    
    strace sees the pid of the new process to attach to as 15 when it should
    really be attaching to pid 15044. Interestingly enough, it does also
    attach to 15044 later but since the initial attach failed it does not
    properly resume the traced task.
    (I assume wait() helped here -- it reported 15044 and hence strace is aware
    that 15044 exists -- I haven't read the strace code to confirm this.)
    
    Miscellaneous Notes re: ptrace and pid namespaces (Documentation/* fodder?):
    
    Note that if the tracer detaches and a tracer from a different ancestor
    pid namespace attaches we'll have the wrong pid number again. The only
    way to fix that is to have ptrace hold a reference to a struct pid
    so long as it may be needed for PTRACE_GETEVENTMSG.
    
    The only way it's possible to ptrace a task outside the tracer's pid
    namespace is if the already-tracing task enters a new descendent pid
    namespace:
    
      tracer	     tracer does		 .
         \		=> clone(CLONE_NEWPID) =>	/ \
         tracee				  tracer   tracee
    
    In this case the pids returned by PTRACE_GETEVENTMSG will be 0.
    Since attaching to tasks that aren't in descendent namespaces is
    not possible, this is a very unlikely problem to encounter.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (MAINTAINERS: ptrace)
    Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (MAINTAINERS: ptrace)
    Cc: <utrace folks>
    Cc: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (pid ns)
    Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org (pid ns)
    Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

diff --git a/kernel/fork.c b/kernel/fork.c
index 3a65513..7946ea6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1404,6 +1404,7 @@ long do_fork(unsigned long clone_flags,
 	 */
 	if (!IS_ERR(p)) {
 		struct completion vfork;
+		int ptrace_pid_vnr;
 
 		trace_sched_process_fork(current, p);
 
@@ -1439,14 +1440,21 @@ long do_fork(unsigned long clone_flags,
 			wake_up_new_task(p, clone_flags);
 		}
 
+		ptrace_pid_vnr = nr;
+		if (unlikely(p->parent != p->real_parent)) {
+			rcu_read_lock();
+			ptrace_pid_vnr = task_pid_nr_ns(p, p->parent->nsproxy->pid_ns);
+			rcu_read_unlock();
+		}
 		tracehook_report_clone_complete(trace, regs,
-						clone_flags, nr, p);
+						clone_flags,
+						ptrace_pid_vnr, p);
 
 		if (clone_flags & CLONE_VFORK) {
 			freezer_do_not_count();
 			wait_for_completion(&vfork);
 			freezer_count();
-			tracehook_report_vfork_done(p, nr);
+			tracehook_report_vfork_done(p, ptrace_pid_vnr);
 		}
 	} else {
 		nr = PTR_ERR(p);
