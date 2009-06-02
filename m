From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 2 Jun 2009 17:29:32 +0900
Message-ID: <20090602172932.d8b0c72a.usui__16322.2707262777$1243931743$gmane$org@mxm.nes.nec.co.jp>
References: <1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
	<1243893963.3966.325.camel@dogo.mojatatu.com>
	<20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
	<20090602072436.GB4239@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090602072436.GB4239-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2 Jun 2009 07:24:36 +0000
Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Tue, Jun 02, 2009 at 03:59:19PM +0900, Minoru Usui wrote:
> > On Mon, 01 Jun 2009 18:06:03 -0400
> > jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
> > 
> > > On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:
> > > 
> > > > 
> > > > Actually, I'd insist with the old rock and handling that other rude
> > > > u32 case, at least until it's fixed in place. So I attach my version
> > > > of your patch (additionally I removed a pair of braces because of
> > > > checkpatch warning).
> > > 
> > > Sure, it doesnt complicate anything - Minoru, this is the version to go
> > > for.
> > 
> > I've tested Jarek's patch #1(for cls_api.c).
> > It works fine to me. Thanks Jarek.
> > 
> > 	Tested-by: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
> 
> Signed-off-by: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Actually, as far as I can remember, it's your patch with slight
> modifications by Jamal and me. So please Minoru, resend this patch
> as Jamal previously suggested: with your changelog and Jamal's,
> plus maybe mine (if you don't mind) signed-off-by's.
> 
> Thanks,
> Jarek P.

OK. Thank you for your advise.
I'll resend the patch as a new thread.
-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
