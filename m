From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][ just for review] memory controller enhancements [4/5]
 statistics for memory cgroup
Date: Mon, 15 Oct 2007 15:37:01 +0900 (JST)
Message-ID: <20071015063702.163181BF45C@siro.lan>
References: <20071011185422.42ec01f0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Thu, 11 Oct 2007 18:54:22 +0900"
	<20071011185422.42ec01f0.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

>  - changed from u64 to s64

why?

> +/*
> + * For batching....mem_cgroup_charge_statistics()(see below).
> + */
> +static inline void mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
> +                enum mem_cgroup_stat_index idx, int val)
> +{
> +	int cpu = smp_processor_id();
> +	stat->cpustat[cpu].count[idx] += val;
> +}

i think the function name should be something which implies batching.

> @@ -207,8 +299,23 @@ clear_page_cgroup(struct page *page, str
>  }
>  
>  
> -static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
> +static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active,
> +				    struct mem_cgroup *mem)
>  {

can mem be different from pc->mem_cgroup here?

YAMAMOTO Takashi
