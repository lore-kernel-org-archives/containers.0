From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/4] Modularize the handling of netdev address c/r
Date: Mon, 26 Apr 2010 12:05:59 -0400
Message-ID: <4BD5B9E7.9060806@cs.columbia.edu>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>	<1270748932-26745-2-git-send-email-danms@us.ibm.com>	<4BD4AE6D.2070507@cs.columbia.edu>
	<874oiyfdv1.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874oiyfdv1.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> OL> Does this test-and-set need locking ?
> 
> No, I was just planning on getting lucky each time.  Er, okay, yes :)
> 
>>> +	if (try_module_get(h->owner))
>>> +		return h;
>>> +	else
>>> +		return ERR_PTR(-EBUSY);
> 
> OL> Maybe some ckpt_err() here ?  I can feel the frustration of trying
> OL> to figure out where _this_ came from !
> 
> I'd prefer not to do that this deep.  I think the varying depth at
> which we call ckpt_err() starts to get confusing.  Regardless, the

True.

I was just thinking about a user seeing EBUSY and a message about
the netdev addr, and how he/she would reason that this is because
a module is missing ...

On the other hand, we could keep the scheme you have now, and then
document this possibility in a FAQ, readme, manual etc.

> call of this function is checked and reported, which I think will make
> tracking down an error result rather easy:
> 
>   h = get_addr_handler(i);
>   if (!h)
>   	continue;
>   else if (IS_ERR(h)) {
>   	addrs = PTR_ERR(h);
>   	ckpt_err(ctx, addrs,
>   		 "Unable to handle netdev addr type %s\n",
>   		 addr_modules[i]);
>   	break;
>   }
> 
> no?

Sure.

Oren.
