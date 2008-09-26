From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Fri, 26 Sep 2008 21:42:15 +0900 (JST)
Message-ID: <20080926.214215.45417575.taka__840.048693544482$1222433103$gmane$org@valinux.co.jp>
References: <20080922143042.GA19222@redhat.com>
	<20080924.191803.100102323.taka@valinux.co.jp>
	<20080924145202.GC547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080924145202.GC547-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

> > > One additional issue with my scheme I just noticed is that I am putting
> > > bio-cgroup in rb-tree. If there are stacked devices then bio/requests from
> > > same cgroup can be at multiple levels of processing at same time. That
> > > would mean that a single cgroup needs to be in multiple rb-trees at the
> > > same time in various layers. So I might have to create a temporary object
> > > which can associate with cgroup and get rid of that object once I don't
> > > have the requests any more...
> > 
> > You mean each layer should have its rb-tree? Is it per device?
> > One lvm logical volume may probably consist from several physical
> > volumes, which will be shared with other logical volumes.
> > And some layers may split one bio into several bios.
> > I hardly can imagine how these structures will be.
> > 
> 
> Yes, one rb-tree per device, be it physical device or logical device
> (because there is one request queue associated per physical/logical block
> device).

No, logical block devices doesn't have any request queues and
they essentially won't block any bios unless it is impossible to
handle them at the moment. Device-mappers never touch any request queues.

> I was thinking of getting hold/hijack the bios as soon as they are
> submitted to the device using associated request function. So if there
> is a logical device built on top of two physical device, the associated
> bio copy or other logic should not even see the bio the moment it is 
> submitted to the deivce. It will see the bio only when it is released
> from associated rb-tree to them. Do you think this will not work? To me
> this is what dm-ioband is doing logically. The only difference is that it
> does this with the help of a separate request queue. 

I think it's easy to just make all logical device --- device mapper
device  --- and all physical device have their own bandwidth control
mechanism.
But I'm not clear how your algorithm works to control the bandwidth.
At which level are you going to guarantee the bandwidth, at the logical
volumes layer such as lvm or at the physical device layer?

Thanks,
Hirokazu Takahashi.
