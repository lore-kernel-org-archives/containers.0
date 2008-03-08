From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] Add the max_usage member on the res_counter
Date: Sat, 8 Mar 2008 13:33:07 +0900
Message-ID: <20080308133307.a2e02402.kamezawa.hiroyu@jp.fujitsu.com>
References: <47D15FAF.3000204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D15FAF.3000204-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 07 Mar 2008 18:30:55 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:

> This is a very usefull feature. E.g. one may set the
> limit to "unlimited" value and check for the memory
> requirements of a new container.
> 
Hm, I like this. Could you add a method to reset this counter ?

Thanks,
-Kame


> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> ---
>  include/linux/res_counter.h |    5 +++++
>  kernel/res_counter.c        |    4 ++++
>  mm/memcontrol.c             |    5 +++++
>  3 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 8cb1ecd..2c4deb5 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -25,6 +25,10 @@ struct res_counter {
>  	 */
>  	unsigned long long usage;
>  	/*
> +	 * the maximal value of the usage from the counter creation
> +	 */
> +	unsigned long long max_usage;
> +	/*
>  	 * the limit that usage cannot exceed
>  	 */
>  	unsigned long long limit;
> @@ -67,6 +71,7 @@ ssize_t res_counter_write(struct res_counter *counter, int member,
>  
>  enum {
>  	RES_USAGE,
> +	RES_MAX_USAGE,
>  	RES_LIMIT,
>  	RES_FAILCNT,
>  };
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 791ff2b..f1f20c2 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -27,6 +27,8 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  	}
>  
>  	counter->usage += val;
> +	if (counter->usage > counter->max_usage)
> +		counter->max_usage = counter->usage;
>  	return 0;
>  }
>  
> @@ -65,6 +67,8 @@ res_counter_member(struct res_counter *counter, int member)
>  	switch (member) {
>  	case RES_USAGE:
>  		return &counter->usage;
> +	case RES_MAX_USAGE:
> +		return &counter->max_usage;
>  	case RES_LIMIT:
>  		return &counter->limit;
>  	case RES_FAILCNT:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2d59163..e5c741a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -911,6 +911,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_read,
>  	},
>  	{
> +		.name = "max_usage_in_bytes",
> +		.private = RES_MAX_USAGE,
> +		.read_u64 = mem_cgroup_read,
> +	},
> +	{
>  		.name = "limit_in_bytes",
>  		.private = RES_LIMIT,
>  		.write = mem_cgroup_write,
> -- 
> 1.5.3.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
