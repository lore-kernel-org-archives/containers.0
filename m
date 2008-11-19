From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 19 Nov 2008 15:30:07 +0100
Message-ID: <20081119143006.GI26308__3234.69972140646$1227105429$gmane$org@kernel.dk>
References: <20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<20081118211442.GG15268@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081118211442.GG15268-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 18 2008, Fabio Checconi wrote:
> > From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > Date: Tue, Nov 18, 2008 08:12:08PM +0100
> >
> > On Tue, Nov 18 2008, Fabio Checconi wrote:
> > > BFQ started from CFQ, extending it in the way you correctly describe,
> > > so it is indeed very similar.  There are also some minor changes to
> > > locking, cic handling, hw_tag detection and to the CIC_SEEKY heuristic.
> > > 
> ...
> > My preferred approach here would be, in order or TODO:
> > 
> > - Create and test the smallish patches for seekiness, hw_tag checking,
> >   and so on for CFQ.
> > - Create and test a WF2Q+ service dispatching patch for CFQ.
> > 
> > and if there are leftovers after that, we could even conditionally
> > enable some of those if appropriate. I think the WF2Q+ is quite cool and
> > could be easily usable as the default, so it's definitely a viable
> > alternative.
> > 
> > My main goal here is basically avoiding addition of Yet Another IO
> > scheduler, especially one that is so closely tied to CFQ already.
> > 
> > I'll start things off by splitting cfq into a few files similar to what
> > bfq has done, as I think it makes a lot of sense. Fabio, if you could
> > create patches for the small behavioural changes you made, we can
> > discuss and hopefully merge those next.
> > 
> 
> Ok, I can do that, I need just a little bit of time to organize
> the work.
> 
> About these small (some of them are really small) changes, a mixed list
> of things that they will touch and/or things that I'd like to have clear
> before starting to write the patches (maybe we can start another thread
> for them):
> 
>   - In cfq_exit_single_io_context() and in changed_ioprio(), cic->key
>     is dereferenced without holding any lock.  As I reported in [1]
>     this seems to be a problem when an exit() races with a cfq_exit_queue()
>     and in a few other cases.  In BFQ we used a somehow involved
>     mechanism to avoid that, abusing rcu (of course we'll have to wait
>     the patch to talk about it :) ), but given my lack of understanding
>     of some parts of the block layer, I'd be interested in knowing if
>     the race is possible and/or if there is something more involved
>     going on that can cause the same effects.

OK, I'm assuming this is where Nikanth got his idea for the patch from?
It does seem racy in spots, we can definitely proceed on getting that
tightened up some more.

>   - set_task_ioprio() in fs/ioprio.c doesn't seem to have a write
>     memory barrier to pair with the dependent read one in
>     cfq_get_io_context().

Agree, that needs fixing.

>   - CFQ_MIN_TT is 2ms, this can result, depending on the value of
>     HZ in timeouts of one jiffy, that may expire too early, so we are
>     just wasting time and do not actually wait for the task to present
>     its new request.  Dealing with seeky traffic we've seen a lot of
>     early timeouts due to one jiffy timers expiring too early, is
>     it worth fixing or can we live with that?

We probably just need to enfore a '2 jiffies minimum' rule for that.

>   - To detect hw tagging in BFQ we consider a sample valid iff the
>     number of requests that the scheduler could have dispatched (given
>     by cfqd->rb_queued + cfqd->rq_in_driver, i.e., the ones still into
>     the scheduler plus the ones into the driver) is higher than the
>     CFQ_HW_QUEUE_MIN threshold.  This obviously caused no problems
>     during testing, but the way CFQ uses now seems a little bit
>     strange.

Not sure this matters a whole lot, but your approach makes sense. Have
you seen the later change to the CFQ logic from Aaron?

>   - Initially, cic->last_request_pos is zero, so the sdist charged
>     to a task for its first seek depends on the position on the disk
>     that is accessed first, independently from its seekiness.  Even
>     if there is a cap on that value, we choose to not charge the first
>     seek to processes; that resulted in less wrong predictions for
>     purely sequential loads.

Agreed, that's is definitely off.

>   - From my understanding, with shared I/O contexts, two different
>     tasks may concurrently lookup for a cfqd into the same ioc.
>     This may result in cfq_drop_dead_cic() being called two times
>     for the same cic.  Am I missing something that prevents that from
>     happening?

That also looks problematic. I guess we need to recheck that under the
lock when in cfq_drop_dead_cic().

> Regarding the code splitup, do you think you'll go for the CFS(BFQ) way,
> using a single compilation unit and including the .c files, or a layout
> with different compilation units (like the ll_rw_blk.c splitup)?

Different compilation units would be my preferred choice.

-- 
Jens Axboe
