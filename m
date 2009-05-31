From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 22:33:27 +0200
Message-ID: <20090531203327.GB2777__24134.352306328$1243802146$gmane$org@ami.dom.local>
References: <20090530120750.GB3166@ami.dom.local>
	<1243686683.3966.117.camel@dogo.mojatatu.com>
	<20090530124554.GC3166@ami.dom.local>
	<1243688628.3966.126.camel@dogo.mojatatu.com>
	<20090530132047.GD3166@ami.dom.local>
	<1243690297.3966.135.camel@dogo.mojatatu.com>
	<20090530140006.GE3166@ami.dom.local>
	<1243724933.3966.158.camel@dogo.mojatatu.com>
	<20090531075528.GA2756@ami.dom.local>
	<1243775830.3966.231.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243775830.3966.231.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, May 31, 2009 at 09:17:10AM -0400, jamal wrote:
> On Sun, 2009-05-31 at 09:55 +0200, Jarek Poplawski wrote:
> 
> > Sure, after fixing it properly we should get rid of unneeded checks.
> 
> > > > Anyway, it's worked for other classifiers like this for some time...
> > > 
> > > Would you agree that it is/was a bandaid?
> > > Or maybe you have some other fear that this may break something else and
> > > prefer the workaround instead?
> > 
> > If somebody decided to do it this way instead of the "proper" fix then
> > it looks to me more like a bandaid "by design". 
> 
> I think your and my definition of "proper" are at odds here ;->
> My logic says there's a causality effect and you always fix the cause
> in such a situation. 
> Here's the anology of our conversation (some captured above) as i see it
> centred around a bug of leaky pipe which just messed up the carpet
> overnight in some room:
>  
> handyman Jamal: fix the pipe so it doesnt leak.
> handyman Jarek: put a little bucket below the dripping spot
> handyman Jamal: fixing this pipe is cheap - it is on warranty too
> handyman Jarek: I fixed two other rooms by putting buckets
> handyman Jamal: Proper: fix the pipe - you dont need the buckets forever
> handyman Jarek: Proper fix is to put the bucket below any drip
> 
> Of course i am exagerating to make a point on our logical approaches:
> leaking pipes dont quiet match software bugs i.e.
> a dripping pipe will have the short term sense of emergency of needing
> buckets but in this case the cost of the damage and time is the same
> if you put a bucket or fixed the pipe.

Yes, you're exagerating; my point is:
handyman Jarek: Proper fix is to fix the pipe, but since this hole
is so old and there were other handymans who couldn't miss this let's
do it with caution (2 way).

> 
> > And, yes, I have some
> > fear we could break some strange configs, which could depend on this
> > wrong but working design.
> 
> To continue our discussion
> handyman Jamal: What is your fear about fixing the pipe?
> handyman Jarek: Someone may have plants which depend on the drips;
> so if you fix it his plants wont get water anymore.
> 
> I hope the above doesnt offend you - it is meant in good spirit.

No, dead plants don't offend me. But, if there is any kitten harmed -
better beware! ;-)

Cheers,
Jarek P.
