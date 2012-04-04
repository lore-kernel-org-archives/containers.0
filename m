From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Wed, 4 Apr 2012 16:32:39 -0400
Message-ID: <20120404203239.GM12676__36391.3291869268$1333571584$gmane$org@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120404184909.GB29686-RcKxWJ4Cfj1J2suj2OqeGauc2jM2gXBXkQQo+JxHRPFibQn6LdNjmg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 04, 2012 at 11:49:09AM -0700, Tejun Heo wrote:

[..]

> Thirdly, I don't see how writeback can control all the IOs.  I mean,
> what about reads or direct IOs?  It's not like IO devices have
> separate channels for those different types of IOs.  They interact
> heavily.

> Let's say we have iops/bps limitation applied on top of proportional IO
> distribution

We already do that. First IO is subjected to throttling limit and only 
then it is passed to the elevator to do the proportional IO. So throttling
is already stacked on top of proportional IO. The only question is 
should it be pushed to even higher layers or not.


> or a device holds two partitions and one
> of them is being used for direct IO w/o filesystems.  How would that
> work?  I think the question goes even deeper, what do the separate
> limits even mean?

Separate limits for buffered writes are just filling the gap. Agreed it
is not a very neat solution.

>  Does the IO sched have to calculate allocation of
> IO resource to different types of IOs and then give a "number" to
> writeback which in turn enforces that limit?  How does the elevator
> know what number to give?  Is the number iops or bps or weight?

If we push up all the throttling somewhere in higher layer, say some
of kind of per bdi throttling interface, then elevator just have to
worry about doing proportional IO. No interaction with higher layers
regarding iops/bps etc. (Not that elevator worries about it today).

> If
> the iosched doesn't know how much write workload exists, how does it
> distribute the surplus buffered writeback resource across different
> cgroups?  If so, what makes the limit actualy enforceable (due to
> inaccuracies in estimation, fluctuation in workload, delay in
> enforcement in different layers and whatnot) except for block layer
> applying the limit *again* on the resulting stream of combined IOs?

So split model is definitely confusing. Anyway, block layer will not
apply the limits again as flusher IO will go in root cgroup which 
generally goes to root which is unthrottled generally. Or flusher
could mark the bios with a flag saying "do not throttle" bios again as
these have been throttled already. So throttling again is probably not
an issue. 

In summary, agreed that split is confusing and it fills a gap existing
today.

Thanks
Vivek
