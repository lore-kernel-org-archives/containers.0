From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][ for -mm] memory cgroup enhancements take3 [9/9] per zone
 stat
Date: Tue, 30 Oct 2007 21:32:59 +0900 (JST)
Message-ID: <20071030123259.3CF2D1C5BD5@siro.lan>
References: <20071030202332.ee86df03.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Tue, 30 Oct 2007 20:23:32 +0900"
	<20071030202332.ee86df03.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> +
> +/*
> + * Per-zone statistics.
> + * Please be carefull. The array can be very big on envrionments whic has
> + * very big MAX_NUMNODES . Adding new stat member to this will eat much memory.
> + * Only Active/Inactive may be sutiable.

s/whic/&h/
s/sutiable/suitable/

> +static inline void __mem_cgroup_zonesta_dec(struct mem_cgroup_zonestat *zstat,

s/zonesta/&t/

> @@ -293,6 +369,23 @@ clear_page_cgroup(struct page *page, str
>  
>  static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
>  {
> +	int direction = 0;
> +
> +	if (active && !(pc->flags & PAGE_CGROUP_FLAG_ACTIVE))
> +		direction = 1; /*from inactive to acvive */
> +	if (!active && (pc->flags & PAGE_CGROUP_FLAG_ACTIVE))
> +		direction = -1;
> +
> +	if (direction) {
> +		struct mem_cgroup_zonestat *zstat = &pc->mem_cgroup->zonestat;
> +		int index = page_cgroup_to_zonestat_index(pc);
> +		preempt_disable();
> +		__mem_cgroup_zonestat_add(zstat, MEM_CGROUP_ZONESTAT_ACTIVE,
> +			direction, index);
> +		__mem_cgroup_zonestat_add(zstat, MEM_CGROUP_ZONESTAT_INACTIVE,
> +			direction, index);

dec?

YAMAMOTO Takashi
