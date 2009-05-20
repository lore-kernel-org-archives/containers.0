From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: bugs with ckpt-v15-dev
Date: Wed, 20 May 2009 08:14:57 -0500
Message-ID: <20090520131457.GB25989@us.ibm.com>
References: <m3my9amczw.fsf@pobox.com> <20090518211041.GA20781@us.ibm.com>
	<m3y6suhz5g.fsf@pobox.com> <20090518225100.GC28083@us.ibm.com>
	<m3zldagfpp.fsf@pobox.com> <20090519010911.GD28083@us.ibm.com>
	<4A13955E.2040301@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A13955E.2040301-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Matt Helsley wrote:
> > On Mon, May 18, 2009 at 06:21:22PM -0500, Nathan Lynch wrote:
> >> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> >>
> >>> On Mon, May 18, 2009 at 04:36:11PM -0500, Nathan Lynch wrote:
> >>>> [1] Should CONFIG_CHECKPOINT depend on CONFIG_CGROUPS and/or
> >>>> CONFIG_CGROUPS_FREEZER?  We require tasks to be put in frozen state
> >>>> before checkpoint, is there any mechanism apart from
> >>>> cgroup/freezer.state to do this?
> >>> Have you tried sending all of the tasks SIGSTOP? It won't 100% freeze
> >>> the tasks -- they'd still be capable of responding to some signals
> >>> (CONT, TERM..). Also they'd presumably be placed in the stopped state
> >>> upon restart so a SIGCONT will be needed. In the case of bash, at
> >>> least, that will technically change what happens upon restart. My
> >>> guess is that in many cases it won't matter but there are some where
> >>> it will.
> >> Hmm, I'm having trouble understanding your suggestion.  The current
> >> checkpoint implementation requires non-self tasks to be frozen (p->flags
> >> & PF_FROZEN), which is not equivalent to stopped state (task->state &
> >> __TASK_STOPPED).  That is, it would refuse to checkpoint tasks in
> >> stopped state.  See may_checkpoint_task().
> > 
> > Oops. You're right. That would require changing may_checkpoint_task() to include
> > __TASK_STOPPED -- not something we'd want in the final code. I had assumed
> > you wanted to try a different mechanism for debugging purposes.
> > 
> 
> Allowing checkpoint of stopped tasks is actually not such a bad
> idea, IMHO.

Well, it might be bad for the same reason that Matt is pursuing the
CHECKPOINTING freezer state:  the task might get kicked alive in
the middle of the checkpoint.

So it might be ok so long as we still move the task to CHECKPOINTING
state.  But I'm just not sure it's worth worrying about.

-serge
