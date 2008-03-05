From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Date: Thu, 06 Mar 2008 06:51:53 +0900 (JST)
Message-ID: <20080306.065153.22592867.taka@valinux.co.jp>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
	<20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080305155329.60e02f48.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> >  #ifdef CONFIG_CGROUP_MEM_CONT
> > +/*
> > + * A page_cgroup page is associated with every page descriptor. The
> > + * page_cgroup helps us identify information about the cgroup
> > + */
> > +struct page_cgroup {
> > +	struct list_head lru;		/* per cgroup LRU list */
> > +	struct page *page;
> > +	struct mem_cgroup *mem_cgroup;
> > +#ifdef CONFIG_CGROUP_SWAP_LIMIT
> > +	struct mm_struct *pc_mm;
> > +#endif
> > +	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
> > +					/* mapped and cached states     */
> > +	int	 flags;
> > +};
> >  
> As first impression, I don't like to increase size of this...but have no alternative
> idea.

If you really want to make the swap space subsystem and the memory subsystem
work independently each other, you can possibly introduce a new data
structure that binds pages in the swapcache and swap_cgroup.
It would be enough since only a small part of the pages are in the swapcache.

Thanks,
Hirokazu Takahashi.
