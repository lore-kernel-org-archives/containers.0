From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Mon, 22 Sep 2008 18:36:51 +0900 (JST)
Message-ID: <20080922.183651.62951479.taka__38753.4925634556$1222076463$gmane$org@valinux.co.jp>
References: <20080918131554.GB20640@redhat.com>
	<20080919.202031.86647893.taka@valinux.co.jp>
	<20080919131019.GA3606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080919131019.GA3606-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > > > I have got excellent results of dm-ioband, that controls the disk I/O
> > > > bandwidth even when it accepts delayed write requests.
> > > > 
> > > > In this time, I ran some benchmarks with a high-end storage. The
> > > > reason was to avoid a performance bottleneck due to mechanical factors
> > > > such as seek time.
> > > > 
> > > > You can see the details of the benchmarks at:
> > > > http://people.valinux.co.jp/~ryov/dm-ioband/hps/
> > 
> >   (snip)
> > 
> > > Secondly, why do we have to create an additional dm-ioband device for 
> > > every device we want to control using rules. This looks little odd
> > > atleast to me. Can't we keep it in line with rest of the controllers
> > > where task grouping takes place using cgroup and rules are specified in
> > > cgroup itself (The way Andrea Righi does for io-throttling patches)?
> > 
> > It isn't essential dm-band is implemented as one of the device-mappers.
> > I've been also considering that this algorithm itself can be implemented
> > in the block layer directly.
> > 
> > Although, the current implementation has merits. It is flexible.
> >   - Dm-ioband can be place anywhere you like, which may be right before
> >     the I/O schedulers or may be placed on top of LVM devices.
> 
> Hi,
> 
> An rb-tree per request queue also should be able to give us this
> flexibility. Because logic is implemented per request queue, rules can be 
> placed at any layer. Either at bottom most layer where requests are
> passed to elevator or at higher layer where requests will be passed to 
> lower level block devices in the stack. Just that we shall have to do
> modifications to some of the higher level dm/md drivers to make use of
> queuing cgroup requests and releasing cgroup requests to lower layers.

Request descriptors are allocated just right before passing I/O requests
to the elevators. Even if you move the descriptor allocation point
before calling the dm/md drivers, the drivers can't make use of them.

When one of the dm drivers accepts a I/O request, the request
won't have either a real device number or a real sector number.
The request will be re-mapped to another sector of another device
in every dm drivers. The request may even be replicated there.
So it is really hard to find the right request queue to put
the request into and sort them on the queue.

> >   - It supports partition based bandwidth control which can work without
> >     cgroups, which is quite easy to use of.
> 
> >   - It is independent to any I/O schedulers including ones which will
> >     be introduced in the future.
> 
> This scheme should also be independent of any of the IO schedulers. We
> might have to do small changes in IO-schedulers to decouple the things
> from __make_request() a bit to insert rb-tree in between __make_request()
> and IO-scheduler. Otherwise fundamentally, this approach should not
> require any major modifications to IO-schedulers. 
> 
> > 
> > I also understand it's will be hard to set up without some tools
> > such as lvm commands.
> > 
> 
> That's something I wish to avoid. If we can keep it simple by doing
> grouping using cgroup and allow one line rules in cgroup it would be nice.

It's possible the algorithm of dm-ioband can be placed in the block layer
if it is really a big problem.
But I doubt it can control every control block I/O as we wish since
the interface the cgroup supports is quite poor.

> > > To avoid creation of stacking another device (dm-ioband) on top of every
> > > device we want to subject to rules, I was thinking of maintaining an
> > > rb-tree per request queue. Requests will first go into this rb-tree upon
> > > __make_request() and then will filter down to elevator associated with the
> > > queue (if there is one). This will provide us the control of releasing
> > > bio's to elevaor based on policies (proportional weight, max bandwidth
> > > etc) and no need of stacking additional block device.
> > 
> > I think it's a bit late to control I/O requests there, since process
> > may be blocked in get_request_wait when the I/O load is high.
> > Please imagine the situation that cgroups with low bandwidths are
> > consuming most of "struct request"s while another cgroup with a high
> > bandwidth is blocked and can't get enough "struct request"s.
> > 
> > It means cgroups that issues lot of I/O request can win the game.
> > 
> 
> Ok, this is a good point. Because number of struct requests are limited
> and they seem to be allocated on first come first serve basis, so if a
> cgroup is generating lot of IO, then it might win.
> 
> But dm-ioband will face the same issue. 

Nope. Dm-ioband doesn't have this issue since it works before allocating
the descriptors. Only I/O requests dm-ioband has passed can allocate its
descriptor.

> Essentially it is also a request
> queue and it will have limited number of request descriptors. Have you 
> modified the logic somewhere for allocation of request descriptors to the
> waiting processes based on their weights? If yes, the logic probably can
> be implemented here too.

I feel this is almost what dm-ioband is doing.

> Thanks
> Vivek
