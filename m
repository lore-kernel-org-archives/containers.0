From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v7 2/3] cgroups: add atomic-context per-thread
	subsystem callbacks
Date: Mon, 24 Jan 2011 10:32:28 -0500
Message-ID: <20110124153228.GB24303__40371.7728252106$1295883218$gmane$org@ghc17.ghc.andrew.cmu.edu>
References: <20101224082226.GA13872@ghc17.ghc.andrew.cmu.edu>
	<20101226120919.GA28529@ghc17.ghc.andrew.cmu.edu>
	<20101226121100.GC28529@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimytfrDnr_5SzBUFQu0SaGdAWDC0p38hiFiHrtU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimytfrDnr_5SzBUFQu0SaGdAWDC0p38hiFiHrtU-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 24, 2011 at 12:38:06AM -0800, Paul Menage wrote:
> Hi Ben,
> 
> Finally finding a moment to actually look at these patches. Sorry it's
> been a while. Can you send the patches inline rather than as
> attachments in future?

Whoops, sure thing.

> 
> Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> This patch looks fine, although I think that freezer_can_attach_task()
> could be simplified to:
> 
> static int freezer_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> {
>   if (__cgroup_freezing_or_frozen(tsk))
>     return -EBUSY;
>   return 0;
> }
> 
> since we guarantee that rcu_read_lock() is held across this call.

I put a note there that "rcu_read_lock allows recursive locking", to
denote that it's okay to double-lock when it's called from
cgroup_attach_proc. I guess this isn't very clear: the reason the lock
is there is because in cgroup_attach_task, I call it without
rcu_read_lock (not necessary in most cases), but freezer needs RCU there
in either case. I wrote in the documentation: "This may run in
rcu_read-side", which I guess isn't very clear either.

> 
> There appears to be a tiny bit of rot in kernel/cpu.c (due to the
> addition of the exit() callback) and memcontrol.c (due to some changes
> at the start of mem_cgroup_move_task()) but neither impact actual
> code.
> 
> I think that before actually pushing to mainline, we'll need to sort
> out the cpuset mempolicy yielding issue, since that could be a
> user-visible API change.
> 
> 
> Paul

Hmm. The quirks caused by this are specific to using cgroup.procs, and
since cgroup.procs is new, I wouldn't say this is an API "change"?

Thanks,
Ben
