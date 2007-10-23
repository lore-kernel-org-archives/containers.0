From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Mon, 22 Oct 2007 23:06:54 -0700
Message-ID: <6599ad830710222306m6a3e3f52k4daf501836c05274__1137.33698749474$1193119793$gmane$org@mail.gmail.com>
References: <471D4523.4040509@google.com>
	<20071023024036.GC3324@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071023024036.GC3324-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/22/07, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> On Mon, Oct 22, 2007 at 05:49:39PM -0700, Paul Menage wrote:
> > +static u64 cpu_usage_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +     struct task_group *tg = cgroup_tg(cgrp);
> > +     int i;
> > +     u64 res = 0;
> > +     for_each_possible_cpu(i) {
> > +             unsigned long flags;
> > +             spin_lock_irqsave(&tg->cfs_rq[i]->rq->lock, flags);
>
> Is the lock absolutely required here?

I'm not sure, I was hoping you or Ingo could comment on this. But some
kind of locking seems to required at least on 32-bit platforms, since
sum_exec_runtime is a 64-bit number.

>
> Hmm .. I hope the cgroup code prevents a task group from being destroyed while
> we are still reading a task group's cpu usage. Is that so?

Good point - cgroups certainly prevents a cgroup itself from being
freed while a control file is being read in an RCU section, and
prevents a task group from being destroyed when that task group has
been read via a task's cgroups pointer and the reader is still in an
RCU section, but we need a generic protection for subsystem state
objects being accessed via control files too.

Using cgroup_mutex is certainly possible for now, although more
heavy-weight than I'd like long term. Using css_get isn't the right
approach, I think - we shouldn't be able to cause an rmdir to fail due
to a concurrent read.

Paul
