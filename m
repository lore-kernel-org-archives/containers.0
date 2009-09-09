From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 25/23] io-controller: fix queue vs group fairness
Date: Wed, 9 Sep 2009 04:03:45 +0200
Message-ID: <20090909020345.GL17468__49739.4016165801$1252461749$gmane$org@gandalf.sssup.it>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<20090908222827.GC3558@redhat.com>
	<20090908231334.GJ17468@gandalf.sssup.it>
	<20090909013205.GB3594@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090909013205.GB3594-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, Sep 08, 2009 09:32:05PM -0400
>
> On Wed, Sep 09, 2009 at 01:13:34AM +0200, Fabio Checconi wrote:
> > Hi,
> > 
> > > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > Date: Tue, Sep 08, 2009 06:28:27PM -0400
> > >
> > > 
> > > o I found an issue during test and that is if there is a mix of queue and group
> > ...
> > >  So we need to keep track of process io queue's vdisktime, even it after got
> > >  deleted from io scheduler's service tree and use that same vdisktime if that
> > >  queue gets backlogged again. But trusting a ioq's vdisktime is bad because
> > >  it can lead to issues if a service tree min_vtime wrap around takes place 
> > >  between two requests of the queue. (Agreed that it can be not that easy to
> > >  hit but it is possible).
> > > 
> > >  Hence, keep a cache of io queues serviced recently and when a queue gets
> > >  backlogged, if it is found in cache, use that vdisktime otherwise assign
> > >  a new vdisktime. This cache of io queues (idle tree), is basically the idea
> > >  implemented by BFQ guys. I had gotten rid of idle trees in V9 and now I am
> > >  bringing it back. (Now I understand it better. :-)).
> > > 
> > >  There is one good side affect of keeping the cache of recently service io
> > >  queues. Now CFQ can differentiate between streaming readers and new processes
> > >  doing IO. Now for a new queue (which is not in the cache), we can assign a
> > >  lower vdisktime and for a streaming reader, we assign vdisktime based on disk
> > >  time used. This way small file readers or the processes doing small amount
> > >  of IO will have reduced latencies at the cost of little reduced throughput of
> > >  streaming readers.
> > > 
> > 
> >   just a little note: this patch seems to introduce a special case for
> > vdisktime = 0, assigning it the meaning of "bad timestamp," but the virtual
> > time space wraps, so 0 is a perfectly legal value, which can be reached by
> > service.  I have no idea if it can produce visible effects, but it doesn't
> > seem to be correct.
> > 
> > 
> 
> Hi Fabio,
> 
> You are right that technically during wrap arounds one can hit value 0 as
> legal value. But I think it is hard to hit at the same time, the only side
> affect of it will be that a queue will be either placed favorably (in case of
> sync queues) or at the end of tree (if it is async queue).
> 
> Async queues anyway go at the end after every dispatch round. So only side
> affect is that once during wrap around cycle a sync queue will be placed
> favorably and can gain share once in a dispatch round.
> 
> I think it is not a big issue at this point of time. But if it becomes
> significant, I can introduce a new variable or start passing function
> parameter to denote whether we found the queue in cache or not.
> 
> But if you think that it is absolutely no no, let me know....
> 

I don't think it's an issue at all, just wanted to make sure it gets
noticed, because timestamping bugs may be hard to hit but often are
hard to debug.  Maybe it deserves a line of comment...
