From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Thu, 21 Jan 2010 11:08:17 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1001211106160.10869@takamine.ncl.cs.columbia.edu>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-4-git-send-email-danms@us.ibm.com>
	<4B5781DF.6050106@hp.com> <87fx5zpiy7.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fx5zpiy7.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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

On Thu, 21 Jan 2010, Dan Smith wrote:

> BH> What about:
> 
> BH>     1. Multicast
> BH>     2. Device config info (ipv4_devconf)
> 
> <snip>
> 
> BH> What about addr->ifa_flags and all the other elements like
> BH> prefixlen, scope and label?
> 
> I thought I was covered by calling it "Basic support..." :)
> 
> I've added these to the list of TODOs and will cook those up once the
> basic bits are in.
> 
> >> +	if ((ret >= 0) && (ret != h->inet4_addrs)) {
> >> +		ret = -EBUSY;
> >> +		ckpt_err(ctx, ret,
> >> +			 "Addresses on interface %s changed\n", dev->name);
> >> +		goto out;
> >> +	}
> 
> BH> This isn't guaranteed to catch every change to the address list,
> BH> just that the number of addresses is the same, is there no way to
> BH> hold a lock the whole time?
> 
> Yeah, there probably is.  I'll take a look.

Qouting from your reply to my email:

> OL> Is there a reason not to collect all addresses into one buffer
> OL> (can there be more than a page worth of them ?) and write in one
> OL> go ?
>
> I don't really see anywhere that the list is bounded.  I'd say that in
> most cases each interface will only have one address anyway.

So collecting them in one buffer (if one page isn't enough then realloc
and retry) would solve this too.

Oren
