From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Date: Fri, 25 Feb 2011 01:54:28 +0100
Message-ID: <20110225005427.GB3044__21340.1114255705$1298595392$gmane$org@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<20110222193403.GG28269@redhat.com>
	<20110222224141.GA23723@linux.develer.com>
	<20110223000358.GM28269@redhat.com>
	<20110223083206.GA2174@linux.develer.com>
	<20110223152354.GA2526@redhat.com>
	<20110223231410.GB1744@linux.develer.com>
	<20110224001033.GF2526@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110224001033.GF2526-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 23, 2011 at 07:10:33PM -0500, Vivek Goyal wrote:
> On Thu, Feb 24, 2011 at 12:14:11AM +0100, Andrea Righi wrote:
> > On Wed, Feb 23, 2011 at 10:23:54AM -0500, Vivek Goyal wrote:
> > > > > Agreed. Granularity of per inode level might be accetable in many 
> > > > > cases. Again, I am worried faster group getting stuck behind slower
> > > > > group.
> > > > > 
> > > > > I am wondering if we are trying to solve the problem of ASYNC write throttling
> > > > > at wrong layer. Should ASYNC IO be throttled before we allow task to write to
> > > > > page cache. The way we throttle the process based on dirty ratio, can we
> > > > > just check for throttle limits also there or something like that.(I think
> > > > > that's what you had done in your initial throttling controller implementation?)
> > > > 
> > > > Right. This is exactly the same approach I've used in my old throttling
> > > > controller: throttle sync READs and WRITEs at the block layer and async
> > > > WRITEs when the task is dirtying memory pages.
> > > > 
> > > > This is probably the simplest way to resolve the problem of faster group
> > > > getting blocked by slower group, but the controller will be a little bit
> > > > more leaky, because the writeback IO will be never throttled and we'll
> > > > see some limited IO spikes during the writeback.
> > > 
> > > Yes writeback will not be throttled. Not sure how big a problem that is.
> > > 
> > > - We have controlled the input rate. So that should help a bit.
> > > - May be one can put some high limit on root cgroup to in blkio throttle
> > >   controller to limit overall WRITE rate of the system.
> > > - For SATA disks, try to use CFQ which can try to minimize the impact of
> > >   WRITE.
> > > 
> > > It will atleast provide consistent bandwindth experience to application.
> > 
> > Right.
> > 
> > > 
> > > >However, this is always
> > > > a better solution IMHO respect to the current implementation that is
> > > > affected by that kind of priority inversion problem.
> > > > 
> > > > I can try to add this logic to the current blk-throttle controller if
> > > > you think it is worth to test it.
> > > 
> > > At this point of time I have few concerns with this approach.
> > > 
> > > - Configuration issues. Asking user to plan for SYNC ans ASYNC IO
> > >   separately is inconvenient. One has to know the nature of workload.
> > > 
> > > - Most likely we will come up with global limits (atleast to begin with),
> > >   and not per device limit. That can lead to contention on one single
> > >   lock and scalability issues on big systems.
> > > 
> > > Having said that, this approach should reduce the kernel complexity a lot.
> > > So if we can do some intelligent locking to limit the overhead then it
> > > will boil down to reduced complexity in kernel vs ease of use to user. I 
> > > guess at this point of time I am inclined towards keeping it simple in
> > > kernel.
> > > 
> > 
> > BTW, with this approach probably we can even get rid of the page
> > tracking stuff for now.
> 
> Agreed.
> 
> > If we don't consider the swap IO, any other IO
> > operation from our point of view will happen directly from process
> > context (writes in memory + sync reads from the block device).
> 
> Why do we need to account for swap IO? Application never asked for swap
> IO. It is kernel's decision to move soem pages to swap to free up some
> memory. What's the point in charging those pages to application group
> and throttle accordingly?

OK, I think swap io control it's not a very important feature for now.

However without swap io control an application could always been able to
blow away any QoS provided by the blkio controller simply allocating a
lot of memory and waiting for the kernel to swap those memory pages.
Probably in that case it would be better to slow down the swap io and
wait for the oom-killer to kill the application, instead of aggressively
swap out pages.

> 
> > 
> > However, I'm sure we'll need the page tracking also for the blkio
> > controller soon or later. This is an important information and also the
> > proportional bandwidth controller can take advantage of it.
> 
> Yes page tracking will be needed for CFQ proportional bandwidth ASYNC
> write support. But until and unless we implement memory cgroup dirty
> ratio and figure a way out to make writeback logic cgroup aware, till
> then I think page tracking stuff is not really useful.

OK.

-Andrea
