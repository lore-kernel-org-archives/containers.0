From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Wed, 24 Sep 2008 19:34:14 +0900 (JST)
Message-ID: <20080924.193414.22923673.taka__10573.8974911676$1222253215$gmane$org@valinux.co.jp>
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

> > It's possible the algorithm of dm-ioband can be placed in the block layer
> > if it is really a big problem.
> > But I doubt it can control every control block I/O as we wish since
> > the interface the cgroup supports is quite poor.
> 
> Had a question regarding cgroup interface. I am assuming that in a system,
> one will be using other controllers as well apart from IO-controller.
> Other controllers will be using cgroup as a grouping mechanism.
> Now coming up with additional grouping mechanism for only io-controller seems
> little odd to me. It will make the job of higher level management software
> harder.
> 
> Looking at the dm-ioband grouping examples given in patches, I think cases
> of grouping based  in pid, pgrp, uid and kvm can be handled by creating right
> cgroup and making sure applications are launched/moved into right cgroup by
> user space tools. 

Grouping in pid, pgrp and uid is not the point, which I've been thinking
can be replaced with cgroup once the implementation of bio-cgroup is done.

I think problems of cgroup are that they can't support lots of storages
and hotplug devices, it just handle them as if they were just one resource.
I don't insist the interface of dm-ioband is the best. I just hope the
cgroup infrastructure support this kind of resources.

> I think keeping grouping mechanism in line with rest of the controllers
> should help because a uniform grouping mechanism should make life simpler.
> 
> I am not very sure about moving dm-ioband algorithm in block layer. Looks
> like it will make life simpler at least in terms of configuration. 


Thanks,
Hirokazu Takahashi.
