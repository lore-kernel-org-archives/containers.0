From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Tue, 05 Aug 2008 15:28:16 +0900 (JST)
Message-ID: <20080805.152816.105502343.taka__40269.6498240859$1217917815$gmane$org@valinux.co.jp>
References: <1217876521.20260.123.camel@nimitz> <48976A2A.9060600@gmail.com>
	<1217883036.20260.137.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217883036.20260.137.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > >> But I'm not yet convinced that limiting the IO writes at the device
> > >> mapper layer is the best solution. IMHO it would be better to throttle
> > >> applications' writes when they're dirtying pages in the page cache (the
> > >> io-throttle way), because when the IO requests arrive to the device
> > >> mapper it's too late (we would only have a lot of dirty pages that are
> > >> waiting to be flushed to the limited block devices, and maybe this could
> > >> lead to OOM conditions). IOW dm-ioband is doing this at the wrong level
> > >> (at least for my requirements). Ryo, correct me if I'm wrong or if I've
> > >> not understood the dm-ioband approach.
> > > 
> > > The avoid-lots-of-page-dirtying problem sounds like a hard one.  But, if
> > > you look at this in combination with the memory controller, they would
> > > make a great team.
> > > 
> > > The memory controller keeps you from dirtying more than your limit of
> > > pages (and pinning too much memory) even if the dm layer is doing the
> > > throttling and itself can't throttle the memory usage.
> > 
> > mmh... but in this way we would just move the OOM inside the cgroup,
> > that is a nice improvement, but the main problem is not resolved...
> > 
> > A safer approach IMHO is to force the tasks to wait synchronously on
> > each operation that directly or indirectly generates i/o.
> 
> Fine in theory, hard in practice. :)
> 
> I think the best we can hope for is to keep parity with what happens in
> the rest of the kernel.  We already have a problem today with people
> mmap()'ing lots of memory and dirtying it all at once.  Adding a i/o
> bandwidth controller or a memory controller isn't really going to fix
> that.  I think it is outside the scope of the i/o (and memory)
> controllers until we solve it generically, first.

Yes, that's right. This should be solved.

But there is a good thing when you use a memory controller.
A problem occurred in a certain cgroup will be confined in its cgroup.
I think this is a great point, don't you think?

Thank you,
Hirokazu Takahashi.
