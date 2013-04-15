From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 19/32] hugepage: convert huge zero page shrinker to new
	shrinker API
Date: Sun, 14 Apr 2013 22:38:37 -0700
Message-ID: <xr93y5ck73qa.fsf__27687.7082688317$1366004325$gmane$org@gthelen.mtv.corp.google.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<1365429659-22108-20-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 08 2013, Glauber Costa wrote:

> It consists of:
>
> * returning long instead of int
> * separating count from scan
> * returning the number of freed entities in scan
>
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Reviewed-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
>  mm/huge_memory.c | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e2f7f5aa..8bf43d3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -212,24 +212,30 @@ static void put_huge_zero_page(void)
>  	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
>  }
>  
> -static int shrink_huge_zero_page(struct shrinker *shrink,
> -		struct shrink_control *sc)
> +
> +static long shrink_huge_zero_page_count(struct shrinker *shrink,
> +					struct shrink_control *sc)
>  {
> -	if (!sc->nr_to_scan)
> -		/* we can free zero page only if last reference remains */
> -		return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
> +	/* we can free zero page only if last reference remains */
> +	return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
> +}
>  
> +static long shrink_huge_zero_page_scan(struct shrinker *shrink,
> +				       struct shrink_control *sc)
> +{
>  	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
>  		unsigned long zero_pfn = xchg(&huge_zero_pfn, 0);
>  		BUG_ON(zero_pfn == 0);
>  		__free_page(__pfn_to_page(zero_pfn));
> +		return HPAGE_PMD_NR;
>  	}
>  
>  	return 0;
>  }
>  
>  static struct shrinker huge_zero_page_shrinker = {
> -	.shrink = shrink_huge_zero_page,
> +	.scan_objects = shrink_huge_zero_page_scan,
> +	.count_objects = shrink_huge_zero_page_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
