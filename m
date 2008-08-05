From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Tue, 05 Aug 2008 19:01:13 +0900 (JST)
Message-ID: <20080805.190113.83913354.taka__2707.79707138917$1217930710$gmane$org@valinux.co.jp>
References: <48976A2A.9060600@gmail.com>
	<20080805.151642.31467169.taka@valinux.co.jp>
	<48981E03.5020406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48981E03.5020406-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > Hi, Andrea,
> > 
> > I'm working with Ryo on dm-ioband and other stuff.
> > 
> >>> On Mon, 2008-08-04 at 20:22 +0200, Andrea Righi wrote:
> >>>> But I'm not yet convinced that limiting the IO writes at the device
> >>>> mapper layer is the best solution. IMHO it would be better to throttle
> >>>> applications' writes when they're dirtying pages in the page cache (the
> >>>> io-throttle way), because when the IO requests arrive to the device
> >>>> mapper it's too late (we would only have a lot of dirty pages that are
> >>>> waiting to be flushed to the limited block devices, and maybe this could
> >>>> lead to OOM conditions). IOW dm-ioband is doing this at the wrong level
> >>>> (at least for my requirements). Ryo, correct me if I'm wrong or if I've
> >>>> not understood the dm-ioband approach.
> >>> The avoid-lots-of-page-dirtying problem sounds like a hard one.  But, if
> >>> you look at this in combination with the memory controller, they would
> >>> make a great team.
> >>>
> >>> The memory controller keeps you from dirtying more than your limit of
> >>> pages (and pinning too much memory) even if the dm layer is doing the
> >>> throttling and itself can't throttle the memory usage.
> >> mmh... but in this way we would just move the OOM inside the cgroup,
> >> that is a nice improvement, but the main problem is not resolved...
> > 
> > The concept of dm-ioband includes it should be used with cgroup memory
> > controller as well as the bio cgroup. The memory controller is supposed
> > to control memory allocation and dirty-page ratio inside each cgroup.
> > 
> > Some guys of cgroup memory controller team just started to implement
> > the latter mechanism. They try to make each cgroup have a threshold
> > to limit the number of dirty pages in the group.
> 
> Interesting, they also post a patch or RFC?

You can take a look at the thread start from
http://www.ussg.iu.edu/hypermail/linux/kernel/0807.1/0472.html,
whose subject is "[PATCH][RFC] dirty balancing for cgroups."

This project has just started, so it would be a good time to
discuss it with them.

Thanks,
Hirokazu Takahashi.
