From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Fri, 25 Feb 2011 11:01:32 -0800
Message-ID: <20110225190132.GA31300@us.ibm.com>
References: <20110225075552.GB24361@us.ibm.com>
	<20110225115507.GD3915@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110225115507.GD3915-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
| On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
| > 
| > diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
| > index b0ea8ec..8ecc052 100644
| > --- a/kernel/checkpoint/restart.c
| > +++ b/kernel/checkpoint/restart.c
| > @@ -972,6 +972,7 @@ static int do_ghost_task(void)
| >  	if (ret < 0)
| >  		ckpt_err(ctx, ret, "ghost restart failed\n");
| >  
| > +	current->exit_signal = -1;
| 
| Setting ->exit_signal outside of tasklist_lock makes me nervous. All other
| places that change ->exit_signal hold write_lock_irq(&tasklist_lock), and
| eligibile_child() (for an instance of a reader being another task) holds
| read_lock(&tasklist_lock). But maybe this does not matter for ghost tasks.
| 

Yes, an earlier version had the write_lock(&tasklist_lock). Will add it
back.

| >  	restore_debug_exit(ctx);
| >  	ckpt_ctx_put(ctx);
| >  	do_exit(0);
| > @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *tsk)
| >  	/* restarting zombies will activate next task in restart */
| >  	if (tsk->flags & PF_RESTARTING) {
| >  		BUG_ON(ctx->active_pid == -1);
| > +
| > +		/*
| > +		 * if we are a "ghost" task, that was terminated by the
| > +		 * container-init (from zap_pid_ns_processes()), we should
| > +		 * wake up the parent since we are now a detached process.
| > +		 */
| > +		read_lock_irq(&tasklist_lock);
| 
| read_lock() is enough. tasklist_lock is never taken for write from IRQs or
| softIRQs.
| 
| > +                if (tsk->exit_state == EXIT_DEAD && !tsk->parent->exit_state) {
| > +                        ckpt_debug("[%d, %s]: exit_checkpoint(): notifying "
| > +					"parent\n", tsk->pid, tsk->comm);
| > +                        __wake_up_parent(tsk, tsk->parent);
| > +                }
| > +		read_unlock_irq(&tasklist_lock);
| 
| Looking at this closer, I wonder if this wakeup logic should be called from
| do_ghost_task(), right after setting ->exit_signal. This way there would be no
| need for a tricky condition to recognize ghost tasks, and (I think) this is
| closer to the other cases changing ->exit_signal (reparent_leader() and
| exit_notify()).

Yes, we tried the following in the earlier version. 

void ghost_auto_reapable()
{
        write_lock(&tasklist_lock);
        current->exit_signal = -1;
        __wake_up_parent(current, current->parent);
        write_unlock(&tasklist_lock);
}

And called this from do_ghost_task(). But with this, the parent could
wake up, find that it still has an eligible child (the ghost) to wait 
for, and go back to waiting before the ghost enters the EXIT_DEAD state.
And so we would lose the wake up.

(zap_pid_ns_processes() passes the __WALL so the ghost would be considered
an eligible child).

Sukadev
