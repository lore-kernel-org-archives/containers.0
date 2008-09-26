From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Fri, 26 Sep 2008 22:04:18 +0900 (JST)
Message-ID: <20080926.220418.83079316.taka__44090.2659357109$1222434605$gmane$org@valinux.co.jp>
References: <20080922143042.GA19222@redhat.com>
	<20080924.193414.22923673.taka@valinux.co.jp>
	<20080924145331.GD547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080924145331.GD547-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

> > > > It's possible the algorithm of dm-ioband can be placed in the block layer
> > > > if it is really a big problem.
> > > > But I doubt it can control every control block I/O as we wish since
> > > > the interface the cgroup supports is quite poor.
> > > 
> > > Had a question regarding cgroup interface. I am assuming that in a system,
> > > one will be using other controllers as well apart from IO-controller.
> > > Other controllers will be using cgroup as a grouping mechanism.
> > > Now coming up with additional grouping mechanism for only io-controller seems
> > > little odd to me. It will make the job of higher level management software
> > > harder.
> > > 
> > > Looking at the dm-ioband grouping examples given in patches, I think cases
> > > of grouping based  in pid, pgrp, uid and kvm can be handled by creating right
> > > cgroup and making sure applications are launched/moved into right cgroup by
> > > user space tools. 
> > 
> > Grouping in pid, pgrp and uid is not the point, which I've been thinking
> > can be replaced with cgroup once the implementation of bio-cgroup is done.
> > 
> > I think problems of cgroup are that they can't support lots of storages
> > and hotplug devices, it just handle them as if they were just one resource.
> > I don't insist the interface of dm-ioband is the best. I just hope the
> > cgroup infrastructure support this kind of resources.
> > 
> 
> Sorry, I did not understand fully. Can you please explain in detail what
> kind of situation will not be covered by cgroup interface.

From the concept of the cgroup, if you want control several disks
independently, you should make each disk have its own cgroup subsystem,
which only can be defined when compiling the kernel. This is impossible
because every linux box has various number of disks.

So you think it may be possible to make each cgroup have lots of control
files for each device as a workaround. But it isn't allowed to add/remove
control files when some devices are hot-added or hot-removed.

Thanks,
Hirokazu Takahashi.
