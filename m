From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: more safe tasklist locking in
	cgroup_attach_proc
Date: Fri, 2 Sep 2011 14:32:51 +0200
Message-ID: <20110902123251.GA26764__38970.5601883636$1314967048$gmane$org@redhat.com>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
	<20110728171345.67d3797d@notabene.brown>
	<20110729142842.GA8462@unix33.andrew.cmu.edu>
	<20110815184957.GA16588@redhat.com>
	<20110901214643.GD10401@unix33.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110901214643.GD10401-japSPQJXeIlCM1neWV3AGuCmf2DRS9x2@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/01, Ben Blum wrote:
>
> On Mon, Aug 15, 2011 at 08:49:57PM +0200, Oleg Nesterov wrote:
> >
> > But can't we avoid the global list? thread_group_leader() or not, we do
> > not really care. We only need to ensure we can safely find all threads.
> >
> > How about the patch below?
>
> I was content with the tasklist_lock because cgroup_attach_proc is
> already a pretty heavyweight operation, and probably pretty rare that a
> user would want to do multiple of them at once quickly.

Perhaps. But this is the global lock, no matter what. Why do you prefer
to take it instead of per-process ->siglock?

> I asked Andrew
> to take the simple tasklist_lock patch just now, since it does fix the
> bug at least.

I disagree.

> Anyway, looking at this, hmm. I am not sure if this protects adequately?
> In de_thread, the sighand lock is held only around the first half
> (around zap_other_threads),

We only need this lock to find all threads,

> and not around the following section where
> leadership is transferred (esp. around the list_replace calls).
> tasklist_lock is held here, though, so it seems like the right lock to
> hold.

This doesn't matter at all, I think. The code under while_each_thread()
doesn't need the stable ->group_leader, and it can be changed right after
you drop tasklist. list_replace() calls do not play with ->thread_group
list.

How can tasklist make any difference?

> > With or without this/your patch this leader can die right after we
> > drop the lock. ss->can_attach(leader) and ss->attach(leader) look
> > suspicious. If a sub-thread execs, this task_struct has nothing to
> > do with the threadgroup.
>
> hmm. I thought I had this case covered, but it's been so long since I
> actually wrote the code that if I did I can't remember how.

This all doesn't look right... Hopefully addressed by Tejun patches.

Oleg.
