From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 21:55:57 +0200
Message-ID: <20090531195557.GA2777__29046.5945880444$1243799839$gmane$org@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243776293.3966.241.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, May 31, 2009 at 09:24:53AM -0400, jamal wrote:
> On Sun, 2009-05-31 at 10:12 +0200, Jarek Poplawski wrote:
> 
> > If somebody runs tc add filter with a new priority but existing handle
> > a newly created (and not linked now) tc would be handled with goto
> > errout and would leak, I guess.
> 
> This would imply the classifier is buggy. I will stare at the different
> classifier - and if any exhibits such traits it needs to be fixed
> 
> > The change (in the two spots) is:
> > > +               if (n->nlmsg_type == RTM_NEWTFILTER &&
> > > +                   (n->nlmsg_flags&(NLM_F_CREATE|NLM_F_EXCL))) {
> > > 
> > 
> > Sorry, but I don't think this change is enough; tc filter replace
> > with only this (n->nlmsg_type == RTM_NEWTFILTER &&
> > (n->nlmsg_flags&(NLM_F_CREATE))) can get here with an "old" tp
> > and will relink it or destroy depending on the ->change() return.
> > 
> 
> Excellent point - there could be buggy user space apps that will do
> that. Minoru change the check to:
> 
> +               if (n->nlmsg_type == RTM_NEWTFILTER &&
> +                   (n->nlmsg_flags&NLM_F_CREATE &&
> +                    n->nlmsg_flags&NLM_F_EXCL)) {


But then, there could be "tc filter replace" with only this
(n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&(NLM_F_CREATE)))
which can't get here with a newly created tp, I guess.

Cheers,
Jarek P.
