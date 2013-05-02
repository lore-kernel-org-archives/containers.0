From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Thu, 2 May 2013 14:59:52 -0400
Message-ID: <20130502185952.GJ30020__3957.5980547399$1367521209$gmane$org@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<20130502173428.GA4771@redhat.com>
	<20130502180815.GG30020@redhat.com>
	<20130502184426.GO19814@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130502184426.GO19814-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 02, 2013 at 11:44:26AM -0700, Tejun Heo wrote:

[..]
> Also, if you're actually thinking about reimplementing blk-throttle,
> please do consider the followings.
> 
> * Currently, blk-throttle doesn't throttle the number of bios being
>   queued.  Note that this breaks the basic back-pressure mechanism
>   where IO pressure is propagated back to the issuer by throttling the
>   issuing task.  blk-throttle breaks that link and converts it to a
>   memory pressure.

Agreed. Implementing something along the lines of per group nr_requests
is needed.

> 
> * It's almost inherently unscalable with highops devices.  Given that
>   IO limiting doesn't require very fine granularity, I think doing
>   this per-cpu shouldn't be too hard.  e.g. build a per-cpu token
>   distributing hierarchy with rebalancing across CPUs happening
>   periodically.

Interesting. I thought for highops devices we will these multi queue
patches from jens and there we can probably implement per queue tokens
and rebalance tokens across queues periodically.

> 
> In short, right now, the goal is getting the hierarchy support
> acceptably working ASAP and yeap we wanna get the nested limits and at
> least certain level of fairness, but let's please implement something
> simple for now and strive for sophistification later because it's
> holding back everyone else.

I am fine with this. Having some hierarchical algorithm and not blocking
full hierarchical support for cgroup is better than not having any
hierachical support and wait for better implementation.

Thanks
Vivek
