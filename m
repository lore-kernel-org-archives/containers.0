From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/9] blkio-cgroup-v9: The new page_cgroup framework
Date: Wed, 22 Jul 2009 14:07:22 +0530
Message-ID: <20090722083722.GI24157__33783.6861647249$1248251886$gmane$org@balbir.in.ibm.com>
References: <20090721155636.GB25127@balbir.in.ibm.com>
	<20090722102058.c1cf731b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090722110739.e00c0f18.kamezawa.hiroyu@jp.fujitsu.com>
	<20090722.172843.193696974.ryov@valinux.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090722.172843.193696974.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

* Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> [2009-07-22 17:28:43]:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > > Index: linux-2.6.31-rc3/include/linux/page_cgroup.h
> > > > > ===================================================================
> > > > > --- linux-2.6.31-rc3.orig/include/linux/page_cgroup.h
> > > > > +++ linux-2.6.31-rc3/include/linux/page_cgroup.h
> > > > > @@ -1,7 +1,7 @@
> > > > >  #ifndef __LINUX_PAGE_CGROUP_H
> > > > >  #define __LINUX_PAGE_CGROUP_H
> > > > > 
> > > > > -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > > > > +#ifdef CONFIG_CGROUP_PAGE
> > > > >  #include <linux/bit_spinlock.h>
> > > > >  /*
> > > > >   * Page Cgroup can be considered as an extended mem_map.
> > > > > @@ -12,9 +12,11 @@
> > > > >   */
> > > > >  struct page_cgroup {
> > > > >  	unsigned long flags;
> > > > > -	struct mem_cgroup *mem_cgroup;
> > > > >  	struct page *page;
> > > > > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > > > > +	struct mem_cgroup *mem_cgroup;
> > > > >  	struct list_head lru;		/* per cgroup LRU list */
> > > > > +#endif
> > > > >  };
> > > > 
> > > > If CONFIG_CGROUP_MEM_RES_CTLR is not enabled and CGROUP_PAGE is
> > > > (assuming that the depends on below is refactored), what would this
> > > > change buy us? What is page_cgroup helping us track, the mem_cgroup is
> > > > factored out, so we are interested in the flags only?
> > > > 
> > > plz remove CONFIG. This jsut makes code complicated.
> > > or plz use your own infrastructure, not depends on page_cgroup.
> 
> Thanks for reviewing the patch.
> Do you mean that remove only CONFIG_CGROUP_MEM_RES_CTR in struct
> page_cgroup? Is it OK to define CONFIG_CGROUP_PAGE?
> 
> > BTW, you can't modify page_cgroup->flags bit without cmpxchg.
> > Then, patch [5/9] is completely broken, now because new bit is used
> > with atomic bit ops but without lock_page_cgroup(). (see mmotm)
> > 
> > Why struct page's flags bit can includes zone id etc...is just because
> > it's initalized before using. Anyway, this is "flags" bit. If you want
> > to modify multiple bit at once, plz use cmpxchg.
> > Then, I buy patch [8/9] and just skip this patch.
> 
> O.K. I'll use cmpxchg.
> 
> > But, following is more straightforward. (and what you do is not different
> > from this.)
> > ==
> > struct page {
> > 	.....
> > #ifdef CONFIG_BLOCKIO_CGROUP
> > 	void *blockio_cgroup;
> > #endif
> > }
> > ==
> 
> This increases the size of struct page. Could I get a consensus on
> this approach?
>


This defeats the entire purpose of page_cgroup, IMHO. You need to add
the cgroup pointer to page_cgroup or use css id's there.
 
> Thanks,
> Ryo Tsuruta
> 
> > Regards,
> > -Kame
> > 
> > 

-- 
	Balbir
