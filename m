From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [3/5] high/low watermark support in res_counter
Date: Thu, 29 Nov 2007 10:18:23 +0900
Message-ID: <20071129101823.8290693a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071128175408.1ee479f3.kamezawa.hiroyu@jp.fujitsu.com>
	<474D4D35.9060603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474D4D35.9060603-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 28 Nov 2007 14:12:53 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> >  /*
> > @@ -73,6 +88,8 @@
> >  	RES_USAGE,
> >  	RES_LIMIT,
> >  	RES_FAILCNT,
> > +	RES_HIGH_WATERMARK,
> > +	RES_LOW_WATERMARK,
> 
> I'd prefer some shorter names. Like RES_HWMARK and RES_LWMARK.
> 
Hmm, ok.


> >  	counter->usage += val;
> > +
> > +	if (counter->usage > counter->high_watermark) {
> > +		counter->watermark_state = RES_WATERMARK_ABOVE_HIGH;
> > +		return 0;
> > +	}
> 
> "else" would look much better here :)
I agree and will fix. thanks.

> 
> > +	if (counter->usage > counter->low_watermark)
> > +		counter->watermark_state = RES_WATERMARK_ABOVE_LOW;
> > +
> >  	return 0;
> >  }
> >  
> > @@ -47,6 +59,13 @@
> >  		val = counter->usage;
> >  
> >  	counter->usage -= val;
> > +
> > +	if (counter->usage < counter->low_watermark) {
> > +		counter->watermark_state = RES_WATERMARK_BELOW_LOW;
> > +		return;
> > +	}
> 
> and here
> 
here, too.

> > +	if (counter->usage < counter->high_watermark)
> > +		counter->watermark_state = RES_WATERMARK_ABOVE_LOW;
> >  }
> >  
> >  void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > @@ -69,6 +88,10 @@
> >  		return &counter->limit;
> >  	case RES_FAILCNT:
> >  		return &counter->failcnt;
> > +	case RES_HIGH_WATERMARK:
> > +		return &counter->high_watermark;
> > +	case RES_LOW_WATERMARK:
> > +		return &counter->low_watermark;
> >  	};
> >  
> >  	BUG();
> > @@ -117,7 +140,7 @@
> >  {
> >  	int ret;
> >  	char *buf, *end;
> > -	unsigned long long flags, tmp, *val;
> > +	unsigned long long flags, tmp, *val, limit, low, high;
> >  
> >  	buf = kmalloc(nbytes + 1, GFP_KERNEL);
> >  	ret = -ENOMEM;
> > @@ -141,6 +164,26 @@
> >  			goto out_free;
> >  	}
> >  	spin_lock_irqsave(&counter->lock, flags);
> > +	/*
> > +	 * High/Low watermark should be changed automatically AMAP.
> > +	 */
> > +	switch (member) {
> > +		case RES_HIGH_WATERMARK:
> > +			limit = res_counter_get(counter, RES_LIMIT);
> > +			if (tmp > limit)
> > +				goto out_free;
> > +			low = res_counter_get(counter, RES_LOW_WATERMARK);
> > +			if (tmp <= low)
> > +				goto out_free;
> > +			break;
> > +		case RES_LOW_WATERMARK:
> > +			high= res_counter_get(counter, RES_HIGH_WATERMARK);
> > +			if (tmp >= high)
> > +				goto out_free;
> > +			break;
> 
> Why there's no checks for limit? Smth like
> 
> case RES_LIMIT:
> 	high = res_counter_get(counter, RES_HIGH_WATERMARK);
> 	if (tmp < high)
> 		goto out_free;
> 
Ok, I'll drop automatic adjustment patch and add check for LIMIT.

Thanks,
-Kame
