From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Wed, 24 Sep 2008 10:52:02 -0400
Message-ID: <20080924145202.GC547__20387.2035992847$1222268383$gmane$org@redhat.com>
References: <20080919131019.GA3606@redhat.com>
	<20080922.183651.62951479.taka@valinux.co.jp>
	<20080922143042.GA19222@redhat.com>
	<20080924.191803.100102323.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080924.191803.100102323.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

On Wed, Sep 24, 2008 at 07:18:03PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > > > > > To avoid creation of stacking another device (dm-ioband) on top of every
> > > > > > device we want to subject to rules, I was thinking of maintaining an
> > > > > > rb-tree per request queue. Requests will first go into this rb-tree upon
> > > > > > __make_request() and then will filter down to elevator associated with the
> > > > > > queue (if there is one). This will provide us the control of releasing
> > > > > > bio's to elevaor based on policies (proportional weight, max bandwidth
> > > > > > etc) and no need of stacking additional block device.
> > > > > 
> > > > > I think it's a bit late to control I/O requests there, since process
> > > > > may be blocked in get_request_wait when the I/O load is high.
> > > > > Please imagine the situation that cgroups with low bandwidths are
> > > > > consuming most of "struct request"s while another cgroup with a high
> > > > > bandwidth is blocked and can't get enough "struct request"s.
> > > > > 
> > > > > It means cgroups that issues lot of I/O request can win the game.
> > > > > 
> > > > 
> > > > Ok, this is a good point. Because number of struct requests are limited
> > > > and they seem to be allocated on first come first serve basis, so if a
> > > > cgroup is generating lot of IO, then it might win.
> > > > 
> > > > But dm-ioband will face the same issue. 
> > > 
> > > Nope. Dm-ioband doesn't have this issue since it works before allocating
> > > the descriptors. Only I/O requests dm-ioband has passed can allocate its
> > > descriptor.
> > > 
> > 
> > Ok. Got it. dm-ioband does not block on allocation of request descriptors.
> > It does seem to be blocking in prevent_burst_bios() but that would be
> > per group so it should be fine.
> 
> Yes. There is also another little mechanism that prevent_burst_bios()
> tries not to block kernel threads if possible.
> 
> > That means for lower layers, one shall have to do request descritor
> > allocation as per the cgroup weight to make sure a cgroup with lower
> > weight does not get higher % of disk because it is generating more
> > requests.
> 
> Yes. But when cgroups with higher weight aren't issueing a lot of I/Os,
> even a cgroup with lower weight can allocate a lot of request descriptors.
> 

ok. Now with the new thought, I am completely deprecating the idea of
queuing the request descriptors. Now I am thinking of capturing the bios
and buffering these into the rb-tree as soon as these enter the request
queue using associated request function. All the request descriptor
allocation will come later when bios are actually release to elevator from
the rb-tree. That way we should be able to get rid of this issue. 

> > One additional issue with my scheme I just noticed is that I am putting
> > bio-cgroup in rb-tree. If there are stacked devices then bio/requests from
> > same cgroup can be at multiple levels of processing at same time. That
> > would mean that a single cgroup needs to be in multiple rb-trees at the
> > same time in various layers. So I might have to create a temporary object
> > which can associate with cgroup and get rid of that object once I don't
> > have the requests any more...
> 
> You mean each layer should have its rb-tree? Is it per device?
> One lvm logical volume may probably consist from several physical
> volumes, which will be shared with other logical volumes.
> And some layers may split one bio into several bios.
> I hardly can imagine how these structures will be.
> 

Yes, one rb-tree per device, be it physical device or logical device
(because there is one request queue associated per physical/logical block
device).

I was thinking of getting hold/hijack the bios as soon as they are
submitted to the device using associated request function. So if there
is a logical device built on top of two physical device, the associated
bio copy or other logic should not even see the bio the moment it is 
submitted to the deivce. It will see the bio only when it is released
from associated rb-tree to them. Do you think this will not work? To me
this is what dm-ioband is doing logically. The only difference is that it
does this with the help of a separate request queue. 

Thanks
Vivek
