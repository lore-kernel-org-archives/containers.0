From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 06/28] mm: new shrinker API
Date: Thu, 04 Apr 2013 18:09:55 -0700
Message-ID: <xr93k3ohkckc.fsf@gthelen.mtv.corp.google.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-7-git-send-email-glommer@parallels.com>
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
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 29 2013, Glauber Costa wrote:

> From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> The current shrinker callout API uses an a single shrinker call for
> multiple functions. To determine the function, a special magical
> value is passed in a parameter to change the behaviour. This
> complicates the implementation and return value specification for
> the different behaviours.
>
> Separate the two different behaviours into separate operations, one
> to return a count of freeable objects in the cache, and another to
> scan a certain number of objects in the cache for freeing. In
> defining these new operations, ensure the return values and
> resultant behaviours are clearly defined and documented.
>
> Modify shrink_slab() to use the new API and implement the callouts
> for all the existing shrinkers.
>
> Signed-off-by: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/shrinker.h | 37 +++++++++++++++++++++++++----------
>  mm/vmscan.c              | 51 +++++++++++++++++++++++++++++++-----------------
>  2 files changed, 60 insertions(+), 28 deletions(-)
>
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index ac6b8ee..4f59615 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -4,31 +4,47 @@
>  /*
>   * This struct is used to pass information from page reclaim to the shrinkers.
>   * We consolidate the values for easier extention later.
> + *
> + * The 'gfpmask' refers to the allocation we are currently trying to
> + * fulfil.
> + *
> + * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
> + * querying the cache size, so a fastpath for that case is appropriate.
>   */
>  struct shrink_control {
>  	gfp_t gfp_mask;
>  
>  	/* How many slab objects shrinker() should scan and try to reclaim */
> -	unsigned long nr_to_scan;
> +	long nr_to_scan;

Why convert from unsigned?  What's a poor shrinker to do with a negative
to-scan request?

[snip]
