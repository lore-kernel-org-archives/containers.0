From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: more safe tasklist locking in
	cgroup_attach_proc
Date: Tue, 16 Aug 2011 00:50:06 +0200
Message-ID: <20110815225003.GB29942__17826.57237859$1313448723$gmane$org@somewhere>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
	<20110728171345.67d3797d@notabene.brown>
	<20110729142842.GA8462@unix33.andrew.cmu.edu>
	<20110815184957.GA16588@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110815184957.GA16588-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 15, 2011 at 08:49:57PM +0200, Oleg Nesterov wrote:
> On 07/29, Ben Blum wrote:
> >
> > According to this thread - https://lkml.org/lkml/2011/7/27/243 - RCU is
> > not sufficient to guarantee the tasklist is stable w.r.t. de_thread and
> > exit. Taking tasklist_lock for reading, instead of rcu_read_lock,
> > ensures proper exclusion.
> 
> Yes.
> 
> So far I still think we should fix while_each_thread() so that it works
> under rcu_read_lock() "as exepected", I'll try to think more.
> 
> But whatever we do with while_each_thread(), this can't help
> cgroup_attach_proc(), it needs the locking.
> 
> > -	rcu_read_lock();
> > +	read_lock(&tasklist_lock);
> >  	if (!thread_group_leader(leader)) {
> 
> Agreed, this should work.
> 
> But can't we avoid the global list? thread_group_leader() or not, we do
> not really care. We only need to ensure we can safely find all threads.
> 
> How about the patch below?
> 
> 
> With or without this/your patch this leader can die right after we
> drop the lock. ss->can_attach(leader) and ss->attach(leader) look
> suspicious. If a sub-thread execs, this task_struct has nothing to
> do with the threadgroup.
> 
> 
> 
> Also. This is off-topic, but... Why cgroup_attach_proc() and
> cgroup_attach_task() do ->attach_task() + cgroup_task_migrate()
> in the different order? cgroup_attach_proc() looks wrong even
> if currently doesn't matter.

Right. As we concluded in our off-list discussion, if there
is no strong reason for that, I'm going to fix that in my task
counter patchset because there it really matters. If we can't
migrate the thread because it has already exited, we really
don't want to call ->attach_task() but rather cancel_attach_task().

Thanks.
