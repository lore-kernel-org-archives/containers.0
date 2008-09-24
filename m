From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Wed, 24 Sep 2008 10:03:55 -0400
Message-ID: <20080924140355.GB547__48120.6027012833$1222265432$gmane$org@redhat.com>
References: <20080919131019.GA3606@redhat.com>
	<20080922.183651.62951479.taka@valinux.co.jp>
	<20080922143042.GA19222@redhat.com>
	<20080924.172937.72827863.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080924.172937.72827863.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 24, 2008 at 05:29:37PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > > > > > > I have got excellent results of dm-ioband, that controls the disk I/O
> > > > > > > bandwidth even when it accepts delayed write requests.
> > > > > > > 
> > > > > > > In this time, I ran some benchmarks with a high-end storage. The
> > > > > > > reason was to avoid a performance bottleneck due to mechanical factors
> > > > > > > such as seek time.
> > > > > > > 
> > > > > > > You can see the details of the benchmarks at:
> > > > > > > http://people.valinux.co.jp/~ryov/dm-ioband/hps/
> > > > > 
> > > > >   (snip)
> > > > > 
> > > > > > Secondly, why do we have to create an additional dm-ioband device for 
> > > > > > every device we want to control using rules. This looks little odd
> > > > > > atleast to me. Can't we keep it in line with rest of the controllers
> > > > > > where task grouping takes place using cgroup and rules are specified in
> > > > > > cgroup itself (The way Andrea Righi does for io-throttling patches)?
> > > > > 
> > > > > It isn't essential dm-band is implemented as one of the device-mappers.
> > > > > I've been also considering that this algorithm itself can be implemented
> > > > > in the block layer directly.
> > > > > 
> > > > > Although, the current implementation has merits. It is flexible.
> > > > >   - Dm-ioband can be place anywhere you like, which may be right before
> > > > >     the I/O schedulers or may be placed on top of LVM devices.
> > > > 
> > > > Hi,
> > > > 
> > > > An rb-tree per request queue also should be able to give us this
> > > > flexibility. Because logic is implemented per request queue, rules can be 
> > > > placed at any layer. Either at bottom most layer where requests are
> > > > passed to elevator or at higher layer where requests will be passed to 
> > > > lower level block devices in the stack. Just that we shall have to do
> > > > modifications to some of the higher level dm/md drivers to make use of
> > > > queuing cgroup requests and releasing cgroup requests to lower layers.
> > > 
> > > Request descriptors are allocated just right before passing I/O requests
> > > to the elevators. Even if you move the descriptor allocation point
> > > before calling the dm/md drivers, the drivers can't make use of them.
> > > 
> > 
> > You are right. request descriptors are currently allocated at bottom
> > most layer. Anyway, in the rb-tree, we put bio cgroups as logical elements
> > and every bio cgroup then contains the list of either bios or requeust
> > descriptors. So what kind of list bio-cgroup maintains can depend on
> > whether it is a higher layer driver (will maintain bios) or a lower layer
> > driver (will maintain list of request descriptors per bio-cgroup).
> 
> I'm getting confused about your idea.
> 
> I thought you wanted to make each cgroup have its own rb-tree,
> and wanted to make all the layers share the same rb-tree.
> If so, are you going to put different things into the same tree?
> Do you even want all the I/O schedlers use the same tree?
> 

Ok, I will give more details of the thought process.

I was thinking of maintaing an rb-tree per request queue and not an
rb-tree per cgroup. This tree can contain all the bios submitted to that
request queue through __make_request(). Every node in the tree will represent
one cgroup and will contain a list of bios issued from the tasks from that
cgroup.

Every bio entering the request queue through __make_request() function
first will be queued in one of the nodes in this rb-tree, depending on which
cgroup that bio belongs to.

Once the bios are buffered in rb-tree, we release these to underlying
elevator depending on the proportionate weight of the nodes/cgroups.

Some more details which I was trying to implement yesterday.

There will be one bio_cgroup object per cgroup. This object will contain
many bio_group objects. Each bio_group object will be created for each
request queue where a bio from bio_cgroup is queued. Essentially the idea
is that bios belonging to a cgroup can be on various request queues in the
system. So a single object can not serve the purpose as it can not be on
many rb-trees at the same time.  Hence create one sub object which will keep
track of bios belonging to one cgroup on a particular request queue.

Each bio_group will contain a list of bios and this bio_group object will
be a node in the rb-tree of request queue. For example. Lets say there are
two request queues in the system q1 and q2 (lets say they belong to /dev/sda
and /dev/sdb). Let say a task t1 in /cgroup/io/test1 is issueing io both
for /dev/sda and /dev/sdb.

bio_cgroup belonging to /cgroup/io/test1 will have two sub bio_group
objects, say bio_group1 and bio_group2. bio_group1 will be in q1's rb-tree
and bio_group2 will be in q2's rb-tree. bio_group1 will contain a list of
bios issued by task t1 for /dev/sda and bio_group2 will contain a list of
bios issued by task t1 for /dev/sdb. I thought the same can be extended
for stacked devices also.
  
I am still trying to implementing it and hopefully this is doable idea.
I think at the end of the day it will be something very close to dm-ioband
algorithm just that there will be no lvm driver and no notion of separate
dm-ioband device. 

> Are you going to block request descriptors in the tree?
> >From the view point of performance, all the request descriptors
> should be passed to the I/O schedulers, since the maximum number
> of request descriptors is limited. 
> 

In my initial implementation I was queuing the request descriptors. Then
you mentioned that it is not a good idea because potentially a cgroup
issuing more requests might win the race.

Yesterday night I thought, then why not start queuing the bios as they
are submitted to the request_queue, using __make_request() and then
release these to underlying elevator or underlying request queue (in case
of stacked device). This will remove few issues.

- All the layers can uniformly queue bios and no intermixing of queuing
 bios and request descriptors.

- Will get rid of issue of one cgroup winning the race because of limited
  number of request descriptors.

> And I still don't understand if you want to make your rb-tree
> work efficiently, you need to put a lot of bios or request descriptors
> into the tree. Is that what you are going to do?
> On the other hand, dm-ioband tries to minimize to have bios blocked.
> And I have a plan on reducing the maximum number that can be
> blocked there.
> 

Now I am planning to queue bios and probably there is no need to queue
request descriptors. I think that's what dm-ioband is doing. Queueing
bios for cgroups per io-band device.

Thinking more about it, In dm-ioband case, you seem to be buffering bios
from various cgroups on a separate request queue belonging to dm-ioband
device. I was thinking of moving all that buffering logic to existing
request queues instead of creating another request queue on top of request
queue I want to control (dm-ioband device).

> Sorry to bother you that I just don't understand the concept clearly.
> 
> > So basically mechanism of maintaining an rb-tree can be completely
> > ignorant of the fact whether a driver is keeping track of bios or keeping
> > track of requests per cgroup. 
> 
> I don't care whether the queue is implemented as a rb-tee or some
> kind of list because they are logically the same thing.

That's true. rb-tree or list is just data structure detail. It is not
important. The core thing I am trying to achive is that is there a way that
I can get rid of notion of creating a separate dm-ioband device for every
device I want to control.

Is it just me who finds creation of dm-ioband devices odd and difficult to
manage or there are other people who think that it would be nice if we can get
rid of it?

Thanks
Vivek
