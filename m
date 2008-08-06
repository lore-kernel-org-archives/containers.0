From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Wed, 06 Aug 2008 15:48:21 +0900 (JST)
Message-ID: <20080806.154821.119848423.taka__2810.2443008267$1218005522$gmane$org@valinux.co.jp>
References: <48981D3B.2020701@gmail.com> <1217953218.10907.25.camel@nimitz>
	<20080806114425.c0e9b24f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080806114425.c0e9b24f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, 

> > > > Buffered write I/O is also related with cache system.
> > > > We must consider this problem as I/O control.
> > > 
> > > Agree. At least, maybe we should consider if an IO controller could be
> > > a valid solution also for these problems.
> > 
> > Isn't this one of the core points that we keep going back and forth
> > over?  It seems like people are arguing in circles over this:
> > 
> > Do we:
> > 	1. control potential memory usage by throttling I/O
> > or
> > 	2. Throttle I/O when memory is full
> > 
> > I might lean toward (1) if we didn't already have a memory controller.
> > But, we have one, and it works.  Also, we *already* do (2) in the
> > kernel, so it would seem to graft well onto existing mechanisms that we
> > have.
> > 
> > I/O controllers should not worry about memory.  
> I agree here ;)
> 
> >They're going to have a hard enough time getting the I/O part right. :)
> > 
> memcg have more problems now ;( 
> 
> Only a difficult thing to limit dirty-ratio in memcg is how-to-count dirty
> pages. If I/O controller's hook helps, it's good.
> 
> My small concern is "What happens if we throttole I/O bandwidth too small
> under some memcg." In such cgroup, we may see more OOMs because I/O will
> not finish in time.

I/O controllers are just supposed to emulate slow device from the point
of view of the processes in a certain cgroup or something. I think
the memory management layer and the memory controller are the ones
which should be able to handle these, which might be as slow as
floppy disks though.

> A system admin have to find some way to avoid this.
> 
> But please do I/O control first. Dirty-page control is related but different
> layer's problem, I think.

Yup.

Thanks,
Hirokazu Takahashi.
