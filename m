From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] memory controller : backgorund reclaim and avoid
	excessive locking [1/5] high-low watermark
Date: Thu, 14 Feb 2008 18:12:05 +0900
Message-ID: <20080214181205.094d3569.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080214172148.bfd564d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080214172801.b1c35067.kamezawa.hiroyu@jp.fujitsu.com>
	<47B40061.20200@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B40061.20200-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 14 Feb 2008 14:18:33 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > If I have to check under lock, please teach me.
> > 
> 
> If there are several processes running in parallel in the same cgroup, the end
> result might not be so nice, specially if the usage is close to the watermarks.
> I suspect that we should  be OK for now, but might be worth keeping in mind.
> 
I'll add text somewhere.

> > -	counter->usage += val;
> > +        if (newval > counter->hwmark) {
> > +		counter->wmark_state = RES_WMARK_ABOVE_HIGH;
> > +		smp_wmb();
> 
> Do we need a barrier here? I suspect not, could you please document as to why a
> barrier is needed?
> 

just chainging value with smp_wmb() and read value after smp_rmb().
By this, I think we can expect we can read snapshot value of wmark_state at
smp_rmb().
......I misunderstand that spin_unlock() has no barrier().
ok, I'll remove smp_wmb() here.

Thanks,
-Kame
