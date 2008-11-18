From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Tue, 18 Nov 2008 14:47:01 -0500
Message-ID: <20081118194701.GC4283__4326.17129195041$1227037815$gmane$org@redhat.com>
References: <af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081118191208.GJ26308-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 18, 2008 at 08:12:08PM +0100, Jens Axboe wrote:
> On Tue, Nov 18 2008, Fabio Checconi wrote:
> > > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > Date: Tue, Nov 18, 2008 09:07:51AM -0500
> > >
> > > On Tue, Nov 18, 2008 at 01:05:08PM +0100, Fabio Checconi wrote:
> > ...
> > > > I have to think a little bit on how it would be possible to support
> > > > an option for time-only budgets, coexisting with the current behavior,
> > > > but I think it can be done.
> > > > 
> > > 
> > > IIUC, bfq and cfq are different in following manner.
> > > 
> > > a. BFQ employs WF2Q+ for fairness and CFQ employes weighted round robin.
> > > b. BFQ uses the budget (sector count) as notion of service and CFQ uses
> > >    time slices.
> > > c. BFQ supports hierarchical fair queuing and CFQ does not.  
> > > 
> > > We are looking forward for implementation of point C. Fabio seems to
> > > thinking of supporting time slice as a service (B). It seems like
> > > convergence of CFQ and BFQ except the point A (WF2Q+ vs weighted round
> > > robin). 
> > > 
> > > It looks like WF2Q+ provides tighter service bound and bfq guys mention
> > > that they have been able to ensure throughput while ensuring tighter 
> > > bounds. If that's the case, does that mean BFQ is a replacement for CFQ
> > > down the line?
> > >   
> > 
> > BFQ started from CFQ, extending it in the way you correctly describe,
> > so it is indeed very similar.  There are also some minor changes to
> > locking, cic handling, hw_tag detection and to the CIC_SEEKY heuristic.
> > 
> > The two schedulers share similar goals, and in my opinion BFQ can be
> > considered, in the long term, a CFQ replacement; *but* before talking
> > about replacing CFQ we have to consider that:
> > 
> >   - it *needs* review and testing; we've done our best, but for sure
> >     it's not enough; review and testing are never enough;
> >   - the service domain fairness, which was one of our objectives, requires
> >     some extra complexity; the mechanisms we used and the design choices
> >     we've made may not fit all the needs, or may not be as generic as the
> >     simpler CFQ's ones;
> >   - CFQ has years of history behind and has been tuned for a wider
> >     variety of environments than the ones we've been able to test.
> > 
> > If time-based fairness is considered more robust and the loss of
> > service-domain fairness is not a problem, then the two schedulers can
> > be made even more similar.
> 
> My preferred approach here would be, in order or TODO:
> 
> - Create and test the smallish patches for seekiness, hw_tag checking,
>   and so on for CFQ.
> - Create and test a WF2Q+ service dispatching patch for CFQ.
> 

Hi Jens,

What do you think about "hierarchical" and cgroup part of BFQ patch? Do 
you intend to incorporate/include that piece also or do you think that's
not the way to go for IO controller stuff.

Thanks
Vivek

> and if there are leftovers after that, we could even conditionally
> enable some of those if appropriate. I think the WF2Q+ is quite cool and
> could be easily usable as the default, so it's definitely a viable
> alternative.
> 
> My main goal here is basically avoiding addition of Yet Another IO
> scheduler, especially one that is so closely tied to CFQ already.
> 
> I'll start things off by splitting cfq into a few files similar to what
> bfq has done, as I think it makes a lot of sense. Fabio, if you could
> create patches for the small behavioural changes you made, we can
> discuss and hopefully merge those next.
> 
> -- 
> Jens Axboe
