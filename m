From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 25 Sep 2009 18:07:24 +0900 (JST)
Message-ID: <20090925.180724.104041942.ryov__17239.1594191597$1253869801$gmane$org@valinux.co.jp>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
	<20090925050429.GB12555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090925050429.GB12555-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Higher level solutions are not keeping track of time slices. Time slices will
> be allocated by CFQ which does not have any idea about grouping. Higher
> level controller just keeps track of size of IO done at group level and
> then run either a leaky bucket or token bucket algorithm.
> 
> IO throttling is a max BW controller, so it will not even care about what is
> happening in other group. It will just be concerned with rate of IO in one
> particular group and if we exceed specified limit, throttle it. So until and
> unless sequential reader group hits it max bw limit, it will keep sending
> reads down to CFQ, and CFQ will happily assign 100ms slices to readers.
> 
> dm-ioband will not try to choke the high throughput sequential reader group
> for the slow random reader group because that would just kill the throughput
> of rotational media. Every sequential reader will run for few ms and then 
> be throttled and this goes on. Disk will soon be seek bound.

Because dm-ioband provides faireness in terms of how many IO requests
are issued or how many bytes are transferred, so this behaviour is to
be expected. Do you think fairness in terms of IO requests and size is
not fair?

> > >   Buffering at higher layer can delay read requests for more than slice idle
> > >   period of CFQ (default 8 ms). That means, it is possible that we are waiting
> > >   for a request from the queue but it is buffered at higher layer and then idle
> > >   timer will fire. It means that queue will losse its share at the same time
> > >   overall throughput will be impacted as we lost those 8 ms.
> > 
> > That sounds like a bug.
> > 
> 
> Actually this probably is a limitation of higher level controller. It most
> likely is sitting so high in IO stack that it has no idea what underlying
> IO scheduler is and what are IO scheduler's policies. So it can't keep up
> with IO scheduler's policies. Secondly, it might be a low weight group and
> tokens might not be available fast enough to release the request.
>
> > >   Read Vs Write
> > >   -------------
> > >   Writes can overwhelm readers hence second level controller FIFO release
> > >   will run into issue here. If there is a single queue maintained then reads
> > >   will suffer large latencies. If there separate queues for reads and writes
> > >   then it will be hard to decide in what ratio to dispatch reads and writes as
> > >   it is IO scheduler's decision to decide when and how much read/write to
> > >   dispatch. This is another place where higher level controller will not be in
> > >   sync with lower level io scheduler and can change the effective policies of
> > >   underlying io scheduler.
> > 
> > The IO schedulers already take care of read-vs-write and already take
> > care of preventing large writes-starve-reads latencies (or at least,
> > they're supposed to).
> 
> True. Actually this is a limitation of higher level controller. A higher
> level controller will most likely implement some of kind of queuing/buffering
> mechanism where it will buffer requeuests when it decides to throttle the
> group. Now once a fair number read and requests are buffered, and if
> controller is ready to dispatch some requests from the group, which
> requests/bio should it dispatch? reads first or writes first or reads and
> writes in certain ratio?

The write-starve-reads on dm-ioband, that you pointed out before, was
not caused by FIFO release, it was caused by IO flow control in
dm-ioband. When I turned off the flow control, then the read
throughput was quite improved.

Now I'm considering separating dm-ioband's internal queue into sync
and async and giving a certain priority of dispatch to async IOs.

Thanks,
Ryo Tsuruta
