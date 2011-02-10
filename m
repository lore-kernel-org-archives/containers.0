From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Wed, 9 Feb 2011 18:44:30 -0800
Message-ID: <20110210024430.GA23167@us.ibm.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D520B78.9020300-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| 
| > But if that is true, I need to investigate why Louis Rilling was getting
| > the crash in Jun 2010 - which he tried to fix here:
| > 
| > 	http://lkml.org/lkml/2010/6/16/295
| 
| I see. So basically there is a kerenl bug that can be potentially
| exposed by the c/r code. Therefore, we need to fix the kernel bug...
| (and until such a fix makes it to mainline, we'll add it as part of
| the linux-cr patchset).

Yes, but there is more than one problem (at least in our C/R kernel).

There is the bug that Louis Rilling reported and Eric has a fix for.
Even if we apply Eric's fix to the C/R kernel, we still will have
another problem if do_ghost_task() sets ->exit_signal to -1.

Consider this in 2.6.37:

Container-init:					Ghost child of container-init

							do_ghost_task()
zap_pid_ns..()
  Send SIGKILL

  do_wait()
    - adds self to ->wait_chldexit queue
    - goes through do_wait_thread() - finds that
      it has at least one child  (on tsk->children),
      but it has not yet exited
    - so waits for the child to exit
  							wakes up for SIGKILL
							->exit_signal = -1
							do_exit()

Note that exit_notify() does not notify parent when the ghost process
exits, because ->exit_signal is -1.

So you may ask how did the container-init have a ghost child. That was
due to a bug in usercr :-). 

But my point is such a userspace bug can leave the above container init
unkillable.

Note that this does not happen with normal threads which set ->exit_signal
to -1 . That is because of the following two pieces of code in copy_process():

       /* ok, now we should be set up.. */
        p->exit_signal = (clone_flags & CLONE_THREAD) ? -1 : (clone_flags & CSIGNAL);

and 

        /* CLONE_PARENT re-uses the old parent */
        if (clone_flags & (CLONE_PARENT|CLONE_THREAD)) {
                p->real_parent = current->real_parent;
                p->parent_exec_id = current->parent_exec_id;

With this our container-init above will not have any children to wait
for in do_wait_thread().

Sukadev
