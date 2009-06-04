From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Thu, 4 Jun 2009 06:34:45 +0000
Message-ID: <20090604063445.GA2683__27900.1898401932$1244097341$gmane$org@ff.dom.local>
References: <1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
	<1243893963.3966.325.camel@dogo.mojatatu.com>
	<20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
	<1243948765.3966.397.camel@dogo.mojatatu.com>
	<20090604134133.dde9ddc6.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604134133.dde9ddc6.usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 04, 2009 at 01:41:33PM +0900, Minoru Usui wrote:
> On Tue, 02 Jun 2009 09:19:25 -0400
> jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
> 
> > On Tue, 2009-06-02 at 15:59 +0900, Minoru Usui wrote:
> > 
> > > If we have to test Jarek's patch #2, I'll test it tomorrow.
> > > What do you think Jamal?
> > 
> > Yes please - even if it is for reasons of givein Jarek some peace of
> > mind;->
> > If something goes seriously wrong with other classifiers because of the
> > patch, and Jareks patch works, we can back out the current patch and fix
> > it with that approach.
> 
> I've tested Jarek's patch #2 without patch #1.
> It works fine, too. Thanks Jarek.
> 
> 	Tested-by: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>

Thank you very much. So, as Jamal wrote, let's wait - hoping it won't
be needed...

Jarek P.

Btw., it seems your box needs time update:

Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Thu, 4 Jun 2009 13:41:33 +0900
...
Original-Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv.nec.co.jp (8.13.8/8.13.4) with ESMTP id n5455gP4006057;
	Thu, 4 Jun 2009 14:06:27 +0900 (JST)
