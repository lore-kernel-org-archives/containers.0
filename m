From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Mon, 28 Feb 2011 09:43:37 -0500
Message-ID: <4D6BB499.7050602@cs.columbia.edu>
References: <20110225075552.GB24361@us.ibm.com>
	<20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
	<20110226135431.GA3251@kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110226135431.GA3251-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



On 02/26/2011 08:54 AM, Louis Rilling wrote:
> On Fri, Feb 25, 2011 at 11:01:32AM -0800, Sukadev Bhattiprolu wrote:
>> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
>> | On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
>> | > 
>> | > diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
>> | > index b0ea8ec..8ecc052 100644
>> | > --- a/kernel/checkpoint/restart.c
>> | > +++ b/kernel/checkpoint/restart.c
>> | > @@ -972,6 +972,7 @@ static int do_ghost_task(void)
>> | >  	if (ret < 0)
>> | >  		ckpt_err(ctx, ret, "ghost restart failed\n");
>> | >  
>> | > +	current->exit_signal = -1;
>> | 
>> | Setting ->exit_signal outside of tasklist_lock makes me nervous. All other
>> | places that change ->exit_signal hold write_lock_irq(&tasklist_lock), and
>> | eligibile_child() (for an instance of a reader being another task) holds
>> | read_lock(&tasklist_lock). But maybe this does not matter for ghost tasks.
>> | 
>>
>> Yes, an earlier version had the write_lock(&tasklist_lock). Will add it
>> back.
>>
>> | >  	restore_debug_exit(ctx);
>> | >  	ckpt_ctx_put(ctx);
>> | >  	do_exit(0);
>> | > @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *tsk)
>> | >  	/* restarting zombies will activate next task in restart */
>> | >  	if (tsk->flags & PF_RESTARTING) {
>> | >  		BUG_ON(ctx->active_pid == -1);
>> | > +
>> | > +		/*
>> | > +		 * if we are a "ghost" task, that was terminated by the
>> | > +		 * container-init (from zap_pid_ns_processes()), we should
>> | > +		 * wake up the parent since we are now a detached process.
>> | > +		 */
>> | > +		read_lock_irq(&tasklist_lock);
>> | 
>> | read_lock() is enough. tasklist_lock is never taken for write from IRQs or
>> | softIRQs.
>> | 
>> | > +                if (tsk->exit_state == EXIT_DEAD && !tsk->parent->exit_state) {
>> | > +                        ckpt_debug("[%d, %s]: exit_checkpoint(): notifying "
>> | > +					"parent\n", tsk->pid, tsk->comm);
>> | > +                        __wake_up_parent(tsk, tsk->parent);
>> | > +                }
>> | > +		read_unlock_irq(&tasklist_lock);
>> | 
>> | Looking at this closer, I wonder if this wakeup logic should be called from
>> | do_ghost_task(), right after setting ->exit_signal. This way there would be no
>> | need for a tricky condition to recognize ghost tasks, and (I think) this is
>> | closer to the other cases changing ->exit_signal (reparent_leader() and
>> | exit_notify()).
>>
>> Yes, we tried the following in the earlier version. 
>>
>> void ghost_auto_reapable()
>> {
>>         write_lock(&tasklist_lock);
>>         current->exit_signal = -1;
>>         __wake_up_parent(current, current->parent);
>>         write_unlock(&tasklist_lock);
>> }
>>
>> And called this from do_ghost_task(). But with this, the parent could
>> wake up, find that it still has an eligible child (the ghost) to wait 
>> for, and go back to waiting before the ghost enters the EXIT_DEAD state.
>> And so we would lose the wake up.
>>
>> (zap_pid_ns_processes() passes the __WALL so the ghost would be considered
>> an eligible child).
> 
> I think I see now. The point is that ->exit_signal = -1 is only meant to work
> correctly for sub-threads, which the parent does not need to wait for. IOW, the
> notion of detached task is only implemented for sub-threads.
> 
> IIUC, setting ->exit_signal to -1 is only used here to let exit_notify() set
> ->exit_state to EXIT_DEAD, right? Otherwise, setting ->exit_signal to 0 and
> letting do_notify_parent() proceed for ghost tasks would have be sufficient I
> guess (provided that the confusion between ghost tasks and zombies could be
> easily avoided in do_notify_parent()).
> 
> Then I agree that the proposed patch looks like a reasonably simple approach.
> 
> Thanks for the explanation,
> 

Louis, Suka:

One subtlety with the method is that if a process get reparented
(for whatever reason) then the ->exit_signal field is reset to 
SIGCHLD. Fortunately, that should not affect us because our ghost
tasks never become orphaned.

However, I can't avoid thinking that maybe there is a better way 
to do this altogether ?

The requirement is simple: ghost tasks are temporary tasks whose
role is to keep certain pid's alive for the duration of the restart
and then exit without a trace before the restarted tasks resume
execution.

The reason I opted for the ->exit_signal = -1 is because it makes
sure that the parent need not explicitly collect the child ghost.

If I had set it to 0, then it would not send a signal, but still
would require a wait() to collect it (right ?).

Can you think of a way to achieve this functionality without the 
subtleties that we have observed so far ?  even at the cost of a 
minor change to, say, wait() logic or what not ?

Thanks,

Oren.
