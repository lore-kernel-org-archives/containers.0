From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [4/5] high/low watermark for memory controller
Date: Thu, 29 Nov 2007 10:20:44 +0900
Message-ID: <20071129102044.8087386c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071128175607.37df2187.kamezawa.hiroyu@jp.fujitsu.com>
	<474D5D1A.4070409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474D5D1A.4070409-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

On Wed, 28 Nov 2007 15:20:42 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > +	mem = mem_cgroup_from_cont(cont);
> > +	spin_lock_irqsave(&mem->res.lock, flags);
> > +	val = res_counter_get(&mem->res, RES_LIMIT);
> > +	if (val == (unsigned long long) LLONG_MAX) {
> > +		low = (unsigned long long) LLONG_MAX;
> > +		high = (unsigned long long) LLONG_MAX;
> > +	} else {
> > +		low = val * DEFAULT_WATERMARK_PERCENT_LOW / 100ULL;
> > +		high = val * DEFAULT_WATERMARK_PERCENT_HIGH / 100ULL;
> 
> BTW, I tried to compile such a code:
> 
> unsigned long long x, y;
> y = ...;
> x = y / 100ULL;
> 
> (similar to yours) and that's what I got:
> 
> kernel/built-in.o: In function `xxx':
> : undefined reference to `__udivdi3'
> 
> It looks like i386 doesn't have any support for ULL divisions.
> It doesn't have it in CPU, and I thought that it was some-how 
> emulated, but it is not...
> 
> Did I miss something?
> 
Ah, I didn't try i386...
But I'll drop this automatic watermark adjustment part.

Thanks,
-Kame
