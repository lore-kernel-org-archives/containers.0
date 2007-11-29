From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [3/5] high/low watermark support in res_counter
Date: Thu, 29 Nov 2007 11:56:08 +0900 (JST)
Message-ID: <20071129025609.0B7111CFE7C@siro.lan>
References: <20071128175408.1ee479f3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Wed, 28 Nov 2007 17:54:08 +0900"
	<20071128175408.1ee479f3.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

> This patch adds high/low watermark parameter to res_counter.
> splitted out from YAMAMOTO's background page reclaim for memory cgroup set.

thanks.

> +	 * Watermarks
> +	 * Should be changed automatically when the limit is changed and
> +	 * keep low < high < limit.
> +	 */
> +	unsigned long long high_watermark;
> +	unsigned long long low_watermark;
> +	/*

do you have any specific reason not to allow low == high == limit?
if you want to ensure low < high < limit, it's better to make the
default values below meet the condition as well.
to me, it seems weird to prevent users from making these values back to
the default.

YAMAMOTO Takashi

> @@ -17,6 +17,9 @@
>  {
>  	spin_lock_init(&counter->lock);
>  	counter->limit = (unsigned long long)LLONG_MAX;
> +	counter->low_watermark = (unsigned long long)LLONG_MAX;
> +	counter->high_watermark = (unsigned long long)LLONG_MAX;
> +	counter->watermark_state = RES_WATERMARK_BELOW_LOW;
>  }
>  
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
