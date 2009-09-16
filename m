From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr tag, cr-base-v13, created. v2.6.28-14-g3c1b190
Date: Wed, 16 Sep 2009 14:36:25 -0400
Message-ID: <200909161836.n8GIaPNb000831@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The tag, cr-base-v13 has been created
        at  3c1b1900f92ed12f5020a7b566065bffda2908d8 (commit)

- Log -----------------------------------------------------------------
commit 3c1b1900f92ed12f5020a7b566065bffda2908d8
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Jan 27 11:04:04 2009 -0500

    Restart multiple processes
    
    Restarting of multiple processes expects all restarting tasks to call
    sys_restart(). Once inside the system call, each task will restart
    itself at the same order that they were saved. The internals of the
    syscall will take care of in-kernel synchronization bewteen tasks.
    
    This patch does _not_ create the task tree in the kernel. Instead it
    assumes that all tasks are created in some way and then invoke the
    restart syscall. You can use the userspace mktree.c program to do
    that.
    
    The init task (*) has a special role: it allocates the restart context
    (ctx), and coordinates the operation. In particular, it first waits
    until all participating tasks enter the kernel, and provides them the
    common restart context. Once everyone in ready, it begins to restart
    itself.
    
    In contrast, the other tasks enter the kernel, locate the init task (*)
    and grab its restart context, and then wait for their turn to restore.
    
    When a task (init or not) completes its restart, it hands the control
    over to the next in line, by waking that task.
    
    An array of pids (the one saved during the checkpoint) is used to
    synchronize the operation. The first task in the array is the init
    task (*). The restart context (ctx) maintain a "current position" in
    the array, which indicates which task is currently active. Once the
    currently active task completes its own restart, it increments that
    position and wakes up the next task.
    
    Restart assumes that userspace provides meaningful data, otherwise
    it's garbage-in-garbage-out. In this case, the syscall may block
    indefinitely, but in TASK_INTERRUPTIBLE, so the user can ctrl-c or
    otherwise kill the stray restarting tasks.
    
    In terms of security, restart runs as the user the invokes it, so it
    will not allow a user to do more than is otherwise permitted by the
    usual system semantics and policy.
    
    Currently we ignore threads and zombies, as well as session ids.
    Add support for multiple processes
    
    (*) For containers, restart should be called inside a fresh container
    by the init task of that container. However, it is also possible to
    restart applications not necessarily inside a container, and without
    restoring the original pids of the processes (that is, provided that
    the application can tolerate such behavior). This is useful to allow
    multi-process restart of tasks not isolated inside a container, and
    also for debugging.
    
    Changelog[v13]:
      - Clear root_task->checkpoint_ctx regardless of error condition
      - Remove unused argument 'ctx' from do_restart_task() prototype
      - Remove unused member 'pids_err' from 'struct cr_ctx'
    
    Changelog[v12]:
      - Replace obsolete cr_debug() with pr_debug()
    
    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
    Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr
