From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Thu, 5 Apr 2012 17:32:54 -0700
Message-ID: <20120406003254.GA15158__43170.0422931046$1333672693$gmane$org@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404175124.GA8931@localhost>
	<20120404183528.GJ12676@redhat.com>
	<20120404214228.GA6471@localhost>
	<20120405151026.GB23999@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120405151026.GB23999-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek,

I totally agree that direct IOs can be best handled in block/cfq layers.

On Thu, Apr 05, 2012 at 11:10:26AM -0400, Vivek Goyal wrote:
> On Wed, Apr 04, 2012 at 02:42:28PM -0700, Fengguang Wu wrote:
> > On Wed, Apr 04, 2012 at 02:35:29PM -0400, Vivek Goyal wrote:
> > > On Wed, Apr 04, 2012 at 10:51:24AM -0700, Fengguang Wu wrote:
> > > 
> > > [..]
> > > > The sweet split point would be for balance_dirty_pages() to do cgroup
> > > > aware buffered write throttling and leave other IOs to the current
> > > > blkcg. For this to work well as a total solution for end users, I hope
> > > > we can cooperate and figure out ways for the two throttling entities
> > > > to work well with each other.
> > > 
> > > Throttling read + direct IO, higher up has few issues too. Users will
> > 
> > Yeah I have a bit worry about high layer throttling, too.
> > Anyway here are the ideas.
> > 
> > > not like that a task got blocked as it tried to submit a read from a
> > > throttled group.
> > 
> > That's not the same issue I worried about :) Throttling is about
> > inserting small sleep/waits into selected points. For reads, the ideal
> > sleep point is immediately after readahead IO is summited, at the end
> > of __do_page_cache_readahead(). The same should be applicable to
> > direct IO.
> 
> But after a read the process might want to process the read data and
> do something else altogether. So throttling the process after completing
> the read is not the best thing.

__do_page_cache_readahead() returns immediately after queuing the read
IOs. It may block occasionally on metadata IO but not data IO.

> > > Current async behavior works well where we queue up the
> > > bio from the task in throttled group and let task do other things. Same
> > > is true for AIO where we would not like to block in bio submission.
> > 
> > For AIO, we'll need to delay the IO completion notification or status
> > update, which may involve computing some delay time and delay the
> > calls to io_complete() with the help of some delayed work queue. There
> > may be more issues to deal with as I didn't look into aio.c carefully.
> 
> I don't know but delaying compltion notifications sounds odd to me. So
> you don't throttle while submitting requests. That does not help with
> pressure on request queue as process can dump whole bunch of IO without
> waiting for completion?
> 
> What I like better that AIO is allowed to submit bunch of IO till it
> hits the nr_requests limit on request queue and then it is blocked as
> request queue is too busy and not enough request descriptors are free.

You are right. Throttling direct IO and AIO in high layer has the
problem of added delays and less queue fullness. I suspect it may also
lead to extra cfq anticipatory idling and disk idles. And it won't be
able to deal with ioprio. All in all there are lots of problems actually.

> > The thing worried me is that in the proportional throttling case, the
> > high level throttling works on the *estimated* task_ratelimit =
> > disk_bandwidth / N, where N is the number of read IO tasks. When N
> > suddenly changes from 2 to 1, it may take 1 second for the estimated
> > task_ratelimit to adapt from disk_bandwidth/2 up to disk_bandwidth,
> > during which time the disk won't get 100% utilized because of the
> > temporally over-throttling of the remaining IO task.
> 
> I thought we were only considering the case of absolute throttling in
> higher layers. Proportional IO will continue to be in CFQ. I don't think
> we need to push proportional IO in higher layers.

Agreed for direct IO.

As for buffered writes, I'm seriously considering the possibility of
doing proportional IO control in balance_dirty_pages().

I'd take this as the central problem of this thread. If the CFQ
proportional IO controller can do its work well for direct IOs and
leave the buffered writes to the balance_dirty_pages() proportional IO
controller, it would result in a simple and efficient "feedback" system
(comparing to the "push back" idea).

I don't really know about any real use cases. However it seems to me
(and perhaps Jan Kara) the most user friendly and manageable IO
controller interfaces would allow the user to divide disk time (no
matter it's used for reads or writes, direct or buffered IOs) among
the cgroups. Then allow each cgroup to further split up disk time (or
bps/iops) to different types of IO.

For simplicity, let's assume only direct/buffered writes are happening
and the user configures 3 blkio cgroups A, B, C with equal split of
disk time and equal direct:buffered splits inside each cgroup.

In the case of

        A:      1 direct write dd + 1 buffered write dd
        B:      1 direct write dd
        C:      1 buffered write dd

The dd tasks should ideally be throttled to

        A.direct:       1/6 disk time
        A.buffered:     1/6 disk time
        B.direct:       1/3 disk time
        C.buffered:     1/3 disk time

So is it possible for the proportional block IO controller to throttle
direct IOs to

        A.direct:       1/6 disk time
        B.direct:       1/3 disk time

and leave the remaining 1/2 disk time to buffered writes from the
flusher thread?

Then I promise that balance_dirty_pages() will be able to throttle the
buffered writes to:

        A.buffered:     1/6 disk time
        C.buffered:     1/3 disk time

thanks to the fact that the balance_dirty_pages() throttling algorithm
is pretty adaptive. It will be able to work well with the blkio
throttling to achieve the throttling goals.

In the above case,

        equal split of disk time == equal split of write bandwidth

since all cgroups run the same type of workload.
balance_dirty_pages() will be able to work in that
cooperative way after adding some direct IO rate accounting.

In order to deal with mixed random/sequential workloads,
balance_dirty_pages() will also need some disk time stats feedback.
It will then throttle the dirtiers so that the disk time goals are
matched in long run.

> > This is not a problem when throttling at the block/cfq layer, since it
> > has the full information of pending requests and should not depend on
> > such estimations.
> 
> CFQ does not even look at pending requests. It just maintains bunch
> of IO queues and selects one queue to dispatch IO from based on its
> weight. So proportional IO comes very naturally to CFQ.

Sure. Nice work!

> > 
> > The workaround I can think of, is to put the throttled task into a wait
> > queue, and let block layer wake up the waiters when the IO queue runs
> > empty. This should be able to avoid most disk idle time.
> 
> Again, I am not convinced that proportional IO should go in higher layers.
> 
> For fast devices we are already suffering from queue locking overhead and
> Jens seems to have patches for multi queue. Now by trying to implement
> something at higher layer, that locking overhead will show up there too
> and we will end up doing something similar to multi queue there and it
> is not desirable.

Sure, yeah it's a hack. I was not really happy with it.

Thanks,
Fengguang
