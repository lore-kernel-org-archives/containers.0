From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/7] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Thu, 7 Aug 2008 17:21:13 +0900
Message-ID: <20080807172113.0788f800.kamezawa.hiroyu__49372.2174353481$1218097268$gmane$org@jp.fujitsu.com>
References: <20080804.175748.189722512.ryov@valinux.co.jp>
	<20080806165421.f76edd47.kamezawa.hiroyu@jp.fujitsu.com>
	<16255819.1218030343593.kamezawa.hiroyu@jp.fujitsu.com>
	<20080807.162512.22162413.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807.162512.22162413.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 07 Aug 2008 16:25:12 +0900 (JST)
Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> > >I've just noticed that most of overhead comes from the spin-locks
> > >when reclaiming the pages inside mem_cgroups and the spin-locks to
> > >protect the links between pages and page_cgroups.
> > Overhead between page <-> page_cgroup lock is cannot be catched by
> > lock_stat now.Do you have numbers ?
> > But ok, there are too many locks ;(
> 
> The problem is that every time the lock is held, the associated
> cache line is flushed.
I think "page" and "page_cgroup" is not so heavly shared object in fast path.
foot-print is also important here.
(anyway, I'd like to remove lock_page_cgroup() when I find a chance)

> 
> > >The latter overhead comes from the policy your team has chosen
> > >that page_cgroup structures are allocated on demand. I still feel
> > >this approach doesn't make any sense because linux kernel tries to
> > >make use of most of the pages as far as it can, so most of them
> > >have to be assigned its related page_cgroup. It would make us happy
> > >if page_cgroups are allocated at the booting time.
> > >
> > Now, multi-sizer-page-cache is discussed for a long time. If it's our
> > direction, on-demand page_cgroup make sense.
> 
> I don't think I can agree to this.
> When multi-sized-page-cache is introduced, some data structures will be
> allocated to manage multi-sized-pages. 
maybe no. it will be encoded into struct page.
> I think page_cgroups should be allocated at the same time.
> This approach will make things simple.
yes, of course.

> 
> It seems like the on-demand allocation approach leads not only
> overhead but complexity and a lot of race conditions.
> If you allocate page_cgroups when allocating page structures,
> You can get rid of most of the locks and you don't have to care about
> allocation error of page_cgroups anymore.
> 
> And it will also give us flexibility that memcg related data can be
> referred/updated inside critical sections.
> 
But it's not good for the systems with small "NORMAL" pages.
This discussion should be done again when more users of page_group appears and
it's overhead is obvious.

Thanks,
-Kame
