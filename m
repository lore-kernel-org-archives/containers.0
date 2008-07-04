From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH -mm 4/5] swapcgroup (v3): modify vm_swap_full()
Date: Fri, 4 Jul 2008 19:40:59 +0900
Message-ID: <20080704194059.efa7d0ed.nishimura@mxp.nes.nec.co.jp>
References: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
	<20080704152244.7fc2ccd1.nishimura@mxp.nes.nec.co.jp>
	<20080704185845.0baaca76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080704185845.0baaca76.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn-VXdhtT5mjnY@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, Kamezawa-san.

On Fri, 4 Jul 2008 18:58:45 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Fri, 4 Jul 2008 15:22:44 +0900
> Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> 
> >  /* Swap 50% full? Release swapcache more aggressively.. */
> > -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> > +#define vm_swap_full(memcg) ((nr_swap_pages*2 < total_swap_pages) \
> > +				|| swap_cgroup_vm_swap_full(memcg))
> > +
> >  
> Maybe nitpick but I like 
> ==
>   vm_swap_full(page)	((nr_swap_pages *2 < total_swap_pages)
> 				|| swap_cgroup_vm_swap_full_page(page))
> ==
> rather than vm_swap_full(memcg)
> 
Well, I used "page" in v2, but Kosaki-san said vm_swap_full()
is not page-granularity operation so it should be changed.
 
And more,

> > @@ -1317,7 +1317,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> >  			pgmoved = 0;
> >  			spin_unlock_irq(&zone->lru_lock);
> > -			if (vm_swap_full())
> > +			if (vm_swap_full(sc->mem_cgroup))
> >  				pagevec_swap_free(&pvec);
> >  			__pagevec_release(&pvec);
> >  			spin_lock_irq(&zone->lru_lock);
> > @@ -1328,7 +1328,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> >  	__count_vm_events(PGDEACTIVATE, pgdeactivate);
> >  	spin_unlock_irq(&zone->lru_lock);
> > -	if (vm_swap_full())
> > +	if (vm_swap_full(sc->mem_cgroup))
> >  		pagevec_swap_free(&pvec);
> >  
> >  	pagevec_release(&pvec);

"page" cannot be determined in those places.
I don't want to change pagevec_swap_free(), so I changed
the argument of vm_swap_full().

> And could you change this to inline funcition ?
> 
Of course.
I think it would be better.


Thanks,
Daisuke Nishimura.
