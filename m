From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC 2/4] memcg: high-low watermark
Date: Tue, 27 May 2008 14:30:27 +0900 (JST)
Message-ID: <20080527053027.E554A5A0A@siro.lan>
References: <20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Tue, 27 May 2008 14:07:03 +0900"
	<20080527140703.97b69ed3.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> +enum res_state res_counter_state(struct res_counter *counter)
> +{
> +	unsigned long flags;
> +	enum res_state ret = RES_BELOW_LIMIT;
> +
> +	spin_lock_irqsave(&counter->lock, flags);
> +	if (counter->use_watermark) {
> +		if (counter->usage <= counter->lwmark)
> +			ret = RES_BELOW_LOW;
> +		else if (counter->usage <= counter->hwmark)
> +			ret = RES_BELOW_HIGH;
> +	}
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +	return ret;
> +}

can't it be RES_OVER_LIMIT?
eg. when you lower the limit.

YAMAMOTO Takashi
