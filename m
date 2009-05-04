From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/7] Factor out code to allocate pidmap page
Date: Mon, 4 May 2009 11:20:59 -0700
Message-ID: <20090504182059.GN11734@us.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <12414250653025-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 04, 2009 at 01:17:39AM -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  kernel/pid.c |   43 ++++++++++++++++++++++++++++---------------
>  1 files changed, 28 insertions(+), 15 deletions(-)
> 
> diff --git a/kernel/pid.c b/kernel/pid.c
> index b2e5f78..c0aaebe 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -122,6 +122,31 @@ static void free_pidmap(struct upid *upid)
>  	atomic_inc(&map->nr_free);
>  }
> 
> +static int alloc_pidmap_page(struct pidmap *map)
> +{
> +	void *page;
> +
> +	if (likely(map->page))
> +		return 0;
> +
> +	page = kzalloc(PAGE_SIZE, GFP_KERNEL);
> +
> +	/*
> +	 * Free the page if someone raced with us installing it:
> +	 */
> +	spin_lock_irq(&pidmap_lock);
> +	if (map->page)
> +		kfree(page);
> +	else
> +		map->page = page;
> +	spin_unlock_irq(&pidmap_lock);
> +
> +	if (unlikely(!map->page))
> +		return -1;
> +
> +	return 0;
> +}
> +
>  static int alloc_pidmap(struct pid_namespace *pid_ns)
>  {
>  	int i, offset, max_scan, pid, last = pid_ns->last_pid;
> @@ -134,21 +159,9 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
>  	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
>  	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
>  	for (i = 0; i <= max_scan; ++i) {
> -		if (unlikely(!map->page)) {
> -			void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
> -			/*
> -			 * Free the page if someone raced with us
> -			 * installing it:
> -			 */
> -			spin_lock_irq(&pidmap_lock);
> -			if (map->page)
> -				kfree(page);
> -			else
> -				map->page = page;
> -			spin_unlock_irq(&pidmap_lock);
> -			if (unlikely(!map->page))
> -				break;

OK, I'm having trouble not with your patch but the original code. This
test of map->page outside the spinlock looks like an incorrect fix to a
race. If map->page can be NULL right after we release the lock then it
can become NULL after this test just as easily.

> -		}
> +		if (alloc_pidmap_page(map))
> +			break;
> +
>  		if (likely(atomic_read(&map->nr_free))) {
>  			do {
>  				if (!test_and_set_bit(offset, map->page)) {

				kaboom??

Perhaps I'm just not familiar enough with the code and I'm just seeing
races where there are none... in which case perhaps a comment hinting at
the answers would be good.

Cheers,
	-Matt Helsley
