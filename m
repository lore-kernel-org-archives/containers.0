From: Minoru Usui <mi.usui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 1 Jun 2009 22:34:13 +0900
Message-ID: <b10243b50906010634r1df4ed71y904eb629c89a6f70__21334.2779585675$1243863311$gmane$org@mail.gmail.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243861410.3966.268.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>, Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

2009/6/1 jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>:
> On Mon, 2009-06-01 at 06:06 +0000, Jarek Poplawski wrote:
>
>>
>> But how about that (of course extremely rude) case "tc filter replace"
>> is run with a new prio?
>
>
> Jarek, sir, handyman extraordinaire, handsome devil, and lover of
> kittens I humbly opine that we need to handle that case.
> How about going back to your original idea of defining tp_created? With
> apologies to Minoru (he must be thinking we are lunatics by now), how
> does the attached changed patch look to you?

It looks good to me, because it's simple and really understandable.
I think below issue should separate from above patch, because it's
easy to come to understand a patch.

How about that?
If it's ok, I'll test it tomorrow.

> Before you throw another rock, there is another issue which will be
> caused by this rude misconfig:
> "replace" really means "get rid of the old and add this new one".
> But for the last 50 years we do not "get rid of the old". I cant think
> of a clean way to do it sans shaving one of the kittens. One simple
> thing to do is to printk a warning when detecting this error. I think
> one needs to draw a line where bad config affects your life - in this
> case i dont think it is worth big changes..
>
> cheers,
> jamal
>
