From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 8 Mar 2010 10:56:41 +0900
Message-ID: <20100308105641.e2e714f4.kamezawa.hiroyu__22399.6854074814$1268013705$gmane$org@jp.fujitsu.com>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100308104447.c124c1ff.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Peter-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 8 Mar 2010 10:44:47 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> > +/*
> > + * mem_cgroup_update_page_stat_locked() - update memcg file cache's accounting
> > + * @page:	the page involved in a file cache operation.
> > + * @idx:	the particular file cache statistic.
> > + * @charge:	true to increment, false to decrement the statistic specified
> > + *		by @idx.
> > + *
> > + * Update memory cgroup file cache's accounting from a locked context.
> > + *
> > + * NOTE: must be called with mapping->tree_lock held.
> > + */
> > +void mem_cgroup_update_page_stat_locked(struct page *page,
> > +			enum mem_cgroup_write_page_stat_item idx, bool charge)
> > +{
> > +	struct address_space *mapping = page_mapping(page);
> > +	struct page_cgroup *pc;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return;
> > +	WARN_ON_ONCE(!irqs_disabled());
> > +	WARN_ON_ONCE(mapping && !spin_is_locked(&mapping->tree_lock));
> > +
> I think this is a wrong place to insert assertion.
> The problem about page cgroup lock is that it can be interrupted in current implementation.
> So,
> 
> a) it must not be aquired under another lock which can be aquired in interrupt context,
>    such as mapping->tree_lock, to avoid:
> 
> 		context1			context2
> 					lock_page_cgroup(pcA)
> 	spin_lock_irq(&tree_lock)
> 		lock_page_cgroup(pcA)		<interrupted>
> 		=>fail				spin_lock_irqsave(&tree_lock)
> 						=>fail
> 
> b) it must not be aquired in interrupt context to avoid:
> 
> 	lock_page_cgroup(pcA)
> 		<interrupted>
> 		lock_page_cgroup(pcA)
> 		=>fail
> 
> I think something like this would be better:
> 
> @@ -83,8 +83,14 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
>         return page_zonenum(pc->page);
>  }
> 
> +#include <linux/irqflags.h>
> +#include <linux/hardirq.h>
>  static inline void lock_page_cgroup(struct page_cgroup *pc)
>  {
> +#ifdef CONFIG_DEBUG_VM
> +       WARN_ON_ONCE(irqs_disabled());
> +       WARN_ON_ONCE(in_interrupt());
> +#endif
>         bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
> 
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> > +		return;
> > +	mem_cgroup_update_page_stat(pc, idx, charge);
> > +}
> > +EXPORT_SYMBOL_GPL(mem_cgroup_update_page_stat_locked);
> > +
> > +/*
> > + * mem_cgroup_update_page_stat_unlocked() - update memcg file cache's accounting
> > + * @page:	the page involved in a file cache operation.
> > + * @idx:	the particular file cache statistic.
> > + * @charge:	true to increment, false to decrement the statistic specified
> > + *		by @idx.
> > + *
> > + * Update memory cgroup file cache's accounting from an unlocked context.
> > + */
> > +void mem_cgroup_update_page_stat_unlocked(struct page *page,
> > +			enum mem_cgroup_write_page_stat_item idx, bool charge)
> > +{
> > +	struct page_cgroup *pc;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return;
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc) || !PageCgroupUsed(pc))
> > +		return;
> > +	lock_page_cgroup(pc);
> > +	mem_cgroup_update_page_stat(pc, idx, charge);
> >  	unlock_page_cgroup(pc);
> >  }
> > +EXPORT_SYMBOL_GPL(mem_cgroup_update_page_stat_unlocked);
> >  
> IIUC, test_clear_page_writeback(at least) can be called under interrupt context.
> This means lock_page_cgroup() is called under interrupt context, that is,
> the case b) above can happen.
> hmm... I don't have any good idea for now except disabling irq around page cgroup lock
> to avoid all of these mess things.
> 

Hmm...simply IRQ-off for all updates ?
But IIRC, clear_writeback is done under treelock.... No ?

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 
