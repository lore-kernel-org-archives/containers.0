From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Wed, 24 Sep 2008 17:29:37 +0900 (JST)
Message-ID: <20080924.172937.72827863.taka__36328.0508238406$1222245232$gmane$org@valinux.co.jp>
References: <20080919131019.GA3606@redhat.com>
	<20080922.183651.62951479.taka@valinux.co.jp>
	<20080922143042.GA19222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080922143042.GA19222-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

> > > > > > I have got excellent results of dm-ioband, that controls the disk I/O
> > > > > > bandwidth even when it accepts delayed write requests.
> > > > > > 
> > > > > > In this time, I ran some benchmarks with a high-end storage. The
> > > > > > reason was to avoid a performance bottleneck due to mechanical factors
> > > > > > such as seek time.
> > > > > > 
> > > > > > You can see the details of the benchmarks at:
> > > > > > http://people.valinux.co.jp/~ryov/dm-ioband/hps/
> > > > 
> > > >   (snip)
> > > > 
> > > > > Secondly, why do we have to create an additional dm-ioband device for 
> > > > > every device we want to control using rules. This looks little odd
> > > > > atleast to me. Can't we keep it in line with rest of the controllers
> > > > > where task grouping takes place using cgroup and rules are specified in
> > > > > cgroup itself (The way Andrea Righi does for io-throttling patches)?
> > > > 
> > > > It isn't essential dm-band is implemented as one of the device-mappers.
> > > > I've been also considering that this algorithm itself can be implemented
> > > > in the block layer directly.
> > > > 
> > > > Although, the current implementation has merits. It is flexible.
> > > >   - Dm-ioband can be place anywhere you like, which may be right before
> > > >     the I/O schedulers or may be placed on top of LVM devices.
> > > 
> > > Hi,
> > > 
> > > An rb-tree per request queue also should be able to give us this
> > > flexibility. Because logic is implemented per request queue, rules can be 
> > > placed at any layer. Either at bottom most layer where requests are
> > > passed to elevator or at higher layer where requests will be passed to 
> > > lower level block devices in the stack. Just that we shall have to do
> > > modifications to some of the higher level dm/md drivers to make use of
> > > queuing cgroup requests and releasing cgroup requests to lower layers.
> > 
> > Request descriptors are allocated just right before passing I/O requests
> > to the elevators. Even if you move the descriptor allocation point
> > before calling the dm/md drivers, the drivers can't make use of them.
> > 
> 
> You are right. request descriptors are currently allocated at bottom
> most layer. Anyway, in the rb-tree, we put bio cgroups as logical elements
> and every bio cgroup then contains the list of either bios or requeust
> descriptors. So what kind of list bio-cgroup maintains can depend on
> whether it is a higher layer driver (will maintain bios) or a lower layer
> driver (will maintain list of request descriptors per bio-cgroup).

I'm getting confused about your idea.

I thought you wanted to make each cgroup have its own rb-tree,
and wanted to make all the layers share the same rb-tree.
If so, are you going to put different things into the same tree?
Do you even want all the I/O schedlers use the same tree?

Are you going to block request descriptors in the tree?
From the view point of performance, all the request descriptors
should be passed to the I/O schedulers, since the maximum number
of request descriptors is limited. 

And I still don't understand if you want to make your rb-tree
work efficiently, you need to put a lot of bios or request descriptors
into the tree. Is that what you are going to do?
On the other hand, dm-ioband tries to minimize to have bios blocked.
And I have a plan on reducing the maximum number that can be
blocked there.

Sorry to bother you that I just don't understand the concept clearly.

> So basically mechanism of maintaining an rb-tree can be completely
> ignorant of the fact whether a driver is keeping track of bios or keeping
> track of requests per cgroup. 

I don't care whether the queue is implemented as a rb-tee or some
kind of list because they are logically the same thing.

> > When one of the dm drivers accepts a I/O request, the request
> > won't have either a real device number or a real sector number.
> > The request will be re-mapped to another sector of another device
> > in every dm drivers. The request may even be replicated there.
> > So it is really hard to find the right request queue to put
> > the request into and sort them on the queue.
> 
> Hmm.., I thought that all the incoming requests to dm/md driver will
> remain in a single queue maintained by that drvier (irrespective of the
> fact in which request queue these requests go in lower layers after
> replication or other operation). I am not very familiar with dm/md
> implementation. I will read more about it....

They never look into the queues maintained in drivers.
Some of them have its own little queue and others don't.
Some may just modify the sector numbers of I/O requests or may
create a new I/O request themselves. Others such as md-raid5
have their own queues to control I/Os, where A write request may
cause several read requests and have to wait for their completions
before the actual write starts.


Thanks,
Hirokazu Takahashi.
