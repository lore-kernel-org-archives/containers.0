From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 01 Jun 2009 18:06:03 -0400
Message-ID: <1243893963.3966.325.camel__31758.5824094296$1243894145$gmane$org@dogo.mojatatu.com>
References: <1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090601204957.GA2760-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:

> 
> Actually, I'd insist with the old rock and handling that other rude
> u32 case, at least until it's fixed in place. So I attach my version
> of your patch (additionally I removed a pair of braces because of
> checkpatch warning).

Sure, it doesnt complicate anything - Minoru, this is the version to go
for.

> Alas, I still think we don't need to change so much in -stable to
> fix the cls_cgroup oops, so I attach a patch which I think is
> enough for -stable and probably -net too. It could be "reverted"
> in -net-next just after applying cls_api patch. Of course, treat
> it only as my humble proposal, and feel free to recommend to David
> your version, no problem (really).


My view is the same - that the second patch doesnt fix the root
cause; and it is not that complicated to fix the root cause. So I humbly
disagree with you.

The issue is that a classifer (cls_group in this example) is being
misconfigured. It rejects the config - but the tp has already been
added. 
It then tries to use the tp in the fast and fails. 

If you look as closely as you did with the patch i posted, youd find
ways to construct similar hostile misconfigs for other classifiers.
You just need to create the scenario where the attributes will fail to
validate. 

I actually suspect the most common scenario for such a failure is not
that head is null (I doubt in Minoru case that allocation will fail);
rather it is some reference to head->something.

cheers,
jamal
