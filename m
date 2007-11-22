From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [4/10]
 calculate mapped ratio for memory cgroup
Date: Thu, 22 Nov 2007 17:46:47 +0900 (JST)
Message-ID: <20071122084647.485981CEE98@siro.lan>
References: <20071122174015.c5ef61ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Thu, 22 Nov 2007 17:40:15 +0900"
	<20071122174015.c5ef61ae.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> On Thu, 22 Nov 2007 17:34:20 +0900 (JST)
> yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:
> 
> > > > > +	/* usage is recorded in bytes */
> > > > > +	total = mem->res.usage >> PAGE_SHIFT;
> > > > > +	rss = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> > > > > +	return (rss * 100) / total;
> > > > 
> > > > Never tried 64 bit division on a 32 bit system. I hope we don't
> > > > have to resort to do_div() sort of functionality.
> > > > 
> > > Hmm, maybe it's better to make these numebrs be just "long".
> > > I'll try to change per-cpu-counter implementation.
> > > 
> > > Thanks,
> > > -Kame
> > 
> > besides that, i think 'total' can be zero here.
> > 
> Ah, This is what I do now.
> ==
> +/*
> + * Calculate mapped_ratio under memory controller. This will be used in
> + * vmscan.c for deteremining we have to reclaim mapped pages.
> + */
> +int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
> +{
> +       long total, rss;
> +
> +       /*
> +        * usage is recorded in bytes. But, here, we assume the number of
> +        * physical pages can be represented by "long" on any arch.
> +        */
> +       total = (long) (mem->res.usage >> PAGE_SHIFT);
> +       rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
> +       return (int)((rss * 100L) / total);
> +}
> ==
> 
> maybe works well.
> 
> -Kame

i meant that "/ total" can cause a division-by-zero exception.

YAMAMOTO Takashi
