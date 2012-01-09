From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [RESEND, PATCH 6/6] memcg: cleanup memcg_check_events()
Date: Mon, 9 Jan 2012 14:41:08 +0100
Message-ID: <20120109134108.GF3588__11750.5198847086$1326116498$gmane$org@cmpxchg.org>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
	<1325883472-5614-6-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1325883472-5614-6-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 06, 2012 at 10:57:52PM +0200, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> ---
>  mm/memcontrol.c |   42 ++++++++++++++++++++++++------------------
>  1 files changed, 24 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2eddcb5..0a13afa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -108,11 +108,12 @@ enum mem_cgroup_events_index {
>   * than using jiffies etc. to handle periodic memcg event.
>   */
>  enum mem_cgroup_events_target {
> -	MEM_CGROUP_TARGET_THRESH,
> -	MEM_CGROUP_TARGET_SOFTLIMIT,
> -	MEM_CGROUP_TARGET_NUMAINFO,
> -	MEM_CGROUP_NTARGETS,
> +	MEM_CGROUP_TARGET_THRESH	= BIT(1),
> +	MEM_CGROUP_TARGET_SOFTLIMIT	= BIT(2),
> +	MEM_CGROUP_TARGET_NUMAINFO	= BIT(3),
>  };
> +#define MEM_CGROUP_NTARGETS 3

That really asks for the next guy forgetting to increase the number
when adding another bit.

> @@ -734,7 +735,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
>  	return total;
>  }
>  
> -static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
> +static int mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
>  				       enum mem_cgroup_events_target target)
>  {
>  	unsigned long val, next;
> @@ -757,9 +758,9 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
>  			break;
>  		}
>  		__this_cpu_write(memcg->stat->targets[target], next);
> -		return true;
> +		return target;
>  	}
> -	return false;
> +	return 0;

Really weird interface - I'll return what you passed in, or zero...?

> @@ -768,29 +769,34 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
>   */
>  static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  {
> +	int flags;
> +
>  	preempt_disable();
> -	/* threshold event is triggered in finer grain than soft limit */
> -	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> -						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit, do_numainfo;
> +	flags = mem_cgroup_event_ratelimit(memcg, MEM_CGROUP_TARGET_THRESH);
>  
> -		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> +	/*
> +	 * Threshold event is triggered in finer grain than soft limit
> +	 * and numainfo
> +	 */
> +	if (unlikely(flags)) {
> +		flags |= mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_SOFTLIMIT);
>  #if MAX_NUMNODES > 1
> -		do_numainfo = mem_cgroup_event_ratelimit(memcg,
> +		flags |= mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_NUMAINFO);
>  #endif
> -		preempt_enable();
> +	}
> +	preempt_enable();
>  
> +	if (unlikely(flags)) {
>  		mem_cgroup_threshold(memcg);
> -		if (unlikely(do_softlimit))
> +		if (unlikely(flags & MEM_CGROUP_TARGET_SOFTLIMIT))
>  			mem_cgroup_update_tree(memcg, page);
>  #if MAX_NUMNODES > 1
> -		if (unlikely(do_numainfo))
> +		if (unlikely(flags & MEM_CGROUP_TARGET_NUMAINFO))
>  			atomic_inc(&memcg->numainfo_events);
>  #endif
> -	} else
> -		preempt_enable();
> +	}
>  }

I'm about to remove the soft limit part of this code, so we'll be able
to condense this back into a single #if block again, anyway.

I would much prefer having the extra #if in the code over this patch
just to silence the warning for now.
