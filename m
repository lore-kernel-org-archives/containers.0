From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 4/7] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Thu, 07 Aug 2008 16:25:12 +0900 (JST)
Message-ID: <20080807.162512.22162413.taka__17558.8940307081$1218094046$gmane$org@valinux.co.jp>
References: <20080804.175748.189722512.ryov@valinux.co.jp>
	<20080806165421.f76edd47.kamezawa.hiroyu@jp.fujitsu.com>
	<16255819.1218030343593.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <16255819.1218030343593.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

> >> > This patch splits the cgroup memory subsystem into two parts.
> >> > One is for tracking pages to find out the owners. The other is
> >> > for controlling how much amount of memory should be assigned to
> >> > each cgroup.
> >> > 
> >> > With this patch, you can use the page tracking mechanism even if
> >> > the memory subsystem is off.
> >> > 
> >> > Based on 2.6.27-rc1-mm1
> >> > Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> >> > Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> >> > 
> >> 
> >> Plese CC me or Balbir or Pavel (See Maintainer list) when you try this ;)
> >> 
> >> After this patch, the total structure is
> >> 
> >>  page <-> page_cgroup <-> bio_cgroup.
> >>  (multiple bio_cgroup can be attached to page_cgroup)
> >>
> >> Does this pointer chain will add
> >>   - significant performance regression or
> >>   - new race condtions 
> >> ?
> >
> >I don't think it will cause significant performance loss, because
> >the link between a page and a page_cgroup has already existed, which
> >the memory resource controller prepared. Bio_cgroup uses this as it is,
> >and does nothing about this.
> >
> >And the link between page_cgroup and bio_cgroup isn't protected
> >by any additional spin-locks, since the associated bio_cgroup is
> >guaranteed to exist as long as the bio_cgroup owns pages.
> >
> Hmm, I think page_cgroup's cost is visible when
> 1. a page is changed to be in-use state. (fault or radixt-tree-insert)
> 2. a page is changed to be out-of-use state (fault or radixt-tree-removal)
> 3. memcg hit its limit or global LRU reclaim runs.
> "1" and "2" can be catched as 5% loss of exec throuput. 
> "3" is not measured (because LRU walk itself is heavy.)
> 
> What new chances to access page_cgroup you'll add ?
> I'll have to take into account them.

I haven't add any at this moment, but I thinks some people may want
to move some pages in page-cache from one cgroup to another cgroup.
When that time comes, I'll try to make the cost minimized that
I will probably only update the link between a page_cgroup and
a bio_cgroup and leave the others untouched.

> >I've just noticed that most of overhead comes from the spin-locks
> >when reclaiming the pages inside mem_cgroups and the spin-locks to
> >protect the links between pages and page_cgroups.
> Overhead between page <-> page_cgroup lock is cannot be catched by
> lock_stat now.Do you have numbers ?
> But ok, there are too many locks ;(

The problem is that every time the lock is held, the associated
cache line is flushed.

> >The latter overhead comes from the policy your team has chosen
> >that page_cgroup structures are allocated on demand. I still feel
> >this approach doesn't make any sense because linux kernel tries to
> >make use of most of the pages as far as it can, so most of them
> >have to be assigned its related page_cgroup. It would make us happy
> >if page_cgroups are allocated at the booting time.
> >
> Now, multi-sizer-page-cache is discussed for a long time. If it's our
> direction, on-demand page_cgroup make sense.

I don't think I can agree to this.
When multi-sized-page-cache is introduced, some data structures will be
allocated to manage multi-sized-pages. I think page_cgroups should be
allocated at the same time. This approach will make things simple.

It seems like the on-demand allocation approach leads not only
overhead but complexity and a lot of race conditions.
If you allocate page_cgroups when allocating page structures,
You can get rid of most of the locks and you don't have to care about
allocation error of page_cgroups anymore.

And it will also give us flexibility that memcg related data can be
referred/updated inside critical sections.

> >> For example, adding a simple function.
> >> ==
> >> int get_page_io_id(struct page *)
> >>  - returns a I/O cgroup ID for this page. If ID is not found, -1 is returne
> d.
> >>    ID is not guaranteed to be valid value. (ID can be obsolete)
> >> ==
> >> And just storing cgroup ID to page_cgroup at page allocation.
> >> Then, making bio_cgroup independent from page_cgroup and 
> >> get ID if avialble and avoid too much pointer walking.
> >
> >I don't think there are any diffrences between a poiter and ID.
> >I think this ID is just a encoded version of the pointer.
> >
> ID can be obsolete, pointer is not. memory cgroup has to take care of
> bio cgroup's race condition ? (About race conditions, it's already complicated
> enough)

Bio-cgroup just expects that the call-backs bio-cgroup prepares are called
when the status of a page_cgroup get changed.

> To be honest, I think adding a new (4 or 8 bytes) page struct and record infor
> mation of bio-control is more straightforward approach. Buy as you might
> think, "there is no room"

But only if everyone allows me to add some new members into "struct page."
I think the same thing goes with memcg you're working on.


Thank you,
Hirokazu Takahashi.
