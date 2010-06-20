From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/6] pid:  Remove the child_reaper special case in
	init/main.c
Date: Sun, 20 Jun 2010 22:27:36 +0200
Message-ID: <20100620202736.GB6902@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <m1pqzmqema.fsf_-_@fess.ebiederm.org> <m1ljaaqejm.fsf_-_@fess.ebiederm.org> <20100620182948.GB3258@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100620182948.GB3258@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>, Roland McGrath <roland@redhat.com>
List-Id: containers.vger.kernel.org

On 06/20, Oleg Nesterov wrote:
>
> On 06/20, Eric W. Biederman wrote:
> >
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -1263,7 +1263,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
> >  		tracehook_finish_clone(p, clone_flags, trace);
> >
> >  		if (thread_group_leader(p)) {
> > -			if (clone_flags & CLONE_NEWPID)
> > +			if (pid->numbers[pid->level].nr == 1)
> >  				p->nsproxy->pid_ns->child_reaper = p;
>
> I must admit, personally I dislike this change. If it is needed for
> the next changes, please explain the need?
>
> Yes, it removes the line from __init function, but it complicates
> copy_process(), this doesn't look fair to me ;) I agree, the complication
> is minor, but still. And, in fact, to me this change hides CLONE_NEWPID
> from grep.
>
> In fact, I was looking at this code when I did 1/4. And I think it is
> better to move it (and perhaps another CLONE_NEWPID check in copy_signal)
> into copy_pid_ns() path.

OK, this is needed for 6/6. I still can't say I like this change (and
6/6 too ;), and it is not enough.

If we spawn the new init because we called sys_unshare(CLONE_NEWPID)
in the past (Eric, imho this can't be the really nice idea) we should
also set TASK_UNKILLABLE at least.

IOW. Not only this hides CLONE_NEWPID from grep, unshare() also hides
it from paths which should know about this flag.

I'd rather prefer the straightforward implementation of unshare(NEWPID)
which merely adds SIGNAL_THE_NEXT_FORK_SHOULD_USE_CLONE_NEWPID flag
to current->signal->flags. Yes, this is very ugly too.

Oleg.
