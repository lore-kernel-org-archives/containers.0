From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/7] [PATCH] Factor out code to allocate pidmap page
Date: Wed, 27 May 2009 10:26:05 -0700
Message-ID: <1243445165.8071.50.camel@nimitz>
References: <20090527154212.GA3107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090527154212.GA3107-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-05-27 at 08:42 -0700, Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 4 May 2009 01:17:39 -0700
> Subject: [PATCH 1/7] [PATCH] Factor out code to allocate pidmap page
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

-ENOMEM, please

Otherwise looks fine.  Please at least add some minimal patch
description about what you're doing and why, though.

-- Dave
