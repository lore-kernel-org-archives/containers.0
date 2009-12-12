From: Daisuke Nishimura <d-nishimura-1T/T2zRcyZr+G+EEi5ephHgSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH RFC v2 3/4] memcg: rework usage of stats by soft limit
Date: Sat, 12 Dec 2009 12:50:46 +0900
Message-ID: <20091212125046.14df3134.d-nishimura__43116.3713605658$1260589912$gmane$org@mtf.biglobe.ne.jp>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
Reply-To: nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Sorry, I disagree this change.

mem_cgroup_soft_limit_check() is used for checking how much current usage exceeds
the soft_limit_in_bytes and updating softlimit tree asynchronously, instead of
checking every charge/uncharge. What if you change the soft_limit_in_bytes,
but the number of charges and uncharges are very balanced afterwards ?
The softlimit tree will not be updated for a long time.

And IIUC, it's the same for your threshold feature, right ?
I think it would be better:

- discard this change.
- in 4/4, rename mem_cgroup_soft_limit_check to mem_cgroup_event_check,
  and instead of adding a new STAT counter, do like:

	if (mem_cgroup_event_check(mem)) {
		mem_cgroup_update_tree(mem, page);
		mem_cgroup_threshold(mem);
	}

Ah, yes. Current code doesn't call mem_cgroup_soft_limit_check() for root cgroup
in charge path as you said in http://marc.info/?l=linux-mm&m=126021128400687&w=2.
I think you can change there as you want, I can change my patch
(http://marc.info/?l=linux-mm&m=126023467303178&w=2, it has not yet sent to
Andrew anyway) to check mem_cgroup_is_root() in mem_cgroup_update_tree().

Thanks,
Daisuke Nishimura.

On Sat, 12 Dec 2009 00:59:18 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> Instead of incrementing counter on each page in/out and comparing it
> with constant, we set counter to constant, decrement counter on each
> page in/out and compare it with zero. We want to make comparing as fast
> as possible. On many RISC systems (probably not only RISC) comparing
> with zero is more effective than comparing with a constant, since not
> every constant can be immediate operand for compare instruction.
> 
> Also, I've renamed MEM_CGROUP_STAT_EVENTS to MEM_CGROUP_STAT_SOFTLIMIT,
> since really it's not a generic counter.
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> ---
>  mm/memcontrol.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0ff65ed..c6081cc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -69,8 +69,9 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_MAPPED_FILE,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> +					used by soft limit implementation */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -90,6 +91,13 @@ __mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
>  	stat->count[idx] = 0;
>  }
>  
> +static inline void
> +__mem_cgroup_stat_set(struct mem_cgroup_stat_cpu *stat,
> +		enum mem_cgroup_stat_index idx, s64 val)
> +{
> +	stat->count[idx] = val;
> +}
> +
>  static inline s64
>  __mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
>  				enum mem_cgroup_stat_index idx)
> @@ -374,9 +382,10 @@ static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
>  
>  	cpu = get_cpu();
>  	cpustat = &mem->stat.cpustat[cpu];
> -	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
> -	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
> -		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
> +	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
> +	if (unlikely(val < 0)) {
> +		__mem_cgroup_stat_set(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
> +				SOFTLIMIT_EVENTS_THRESH);
>  		ret = true;
>  	}
>  	put_cpu();
> @@ -509,7 +518,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  	else
>  		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
> -	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
>  	put_cpu();
>  }
>  
> -- 
> 1.6.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
