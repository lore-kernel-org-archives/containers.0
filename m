From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] memory cgroup enhancements take 4 [5/8] add status
 accounting function for memory cgroup
Date: Wed, 31 Oct 2007 15:12:34 -0700
Message-ID: <20071031151234.4fcb42b2.akpm@linux-foundation.org>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
	<20071031193046.a58f2ef0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071031193046.a58f2ef0.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 31 Oct 2007 19:30:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:

> Add statistics account infrastructure for memory controller.
> All account information is stored per-cpu and caller will not have
> to take lock or use atomic ops.
> This will be used by memory.stat file later.
> 
> CACHE includes swapcache now. I'd like to divide it to
> PAGECACHE and SWAPCACHE later.
> 
> ...
>
> --- devel-2.6.23-mm1.orig/mm/memcontrol.c
> +++ devel-2.6.23-mm1/mm/memcontrol.c
> @@ -35,6 +35,59 @@ struct cgroup_subsys mem_cgroup_subsys;
>  static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
>  
>  /*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> +
> +	MEM_CGROUP_STAT_NSTATS,
> +};
> +
> +struct mem_cgroup_stat_cpu {
> +	s64 count[MEM_CGROUP_STAT_NSTATS];
> +} ____cacheline_aligned_in_smp;
> +
> +struct mem_cgroup_stat {
> +	struct mem_cgroup_stat_cpu cpustat[NR_CPUS];
> +};
> +
> +/*
> + * modifies value with disabling preempt.
> + */
> +static inline void __mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
> +                enum mem_cgroup_stat_index idx, int val)
> +{
> +	int cpu = smp_processor_id();
> +	preempt_disable();
> +	stat->cpustat[cpu].count[idx] += val;
> +	preempt_enable();
> +}

This is clearly doing smp_processor_id() in preemptible code.  (or the
preempt_disable() just isn't needed).  I fixed it up.

Please ensure that you test with all runtime debugging options enabled -
you should have seen a warning here.

> +/*
> + * For accounting under irq disable, no need for increment preempt count.
> + */
> +static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
> +		enum mem_cgroup_stat_index idx, int val)
> +{
> +	int cpu = smp_processor_id();
> +	stat->cpustat[cpu].count[idx] += val;
> +}

There's a wild amount of inlining in that file.  Please, just don't do it -
inline is a highly specialised thing and is rarely needed.

When I removed the obviously-wrong inline statements, the size of
mm/memcontrol.o went from 3823 bytes down to 3495.

It also caused this:

mm/memcontrol.c:65: warning: '__mem_cgroup_stat_add' defined but not used

so I guess I'll just remove that.
