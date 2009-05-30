From: Minoru Usui <mi.usui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 07:22:37 +0900
Message-ID: <b10243b50905301522t42aafaffxbf5934388af3df93__49539.6551130854$1243722205$gmane$org@mail.gmail.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	<20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
	<20090530120750.GB3166@ami.dom.local>
	<1243686683.3966.117.camel@dogo.mojatatu.com>
	<20090530124554.GC3166@ami.dom.local>
	<1243688628.3966.126.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243688628.3966.126.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
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

Hi, jamal

2009/5/30 jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
>
> On Sat, 2009-05-30 at 14:45 +0200, Jarek Poplawski wrote:
> > On Sat, May 30, 2009 at 08:31:23AM -0400, jamal wrote:
>
> > > Remeber, you could have NLM_F_EXCL|NLM_F_CREATE to indicate "create t=
his
> > > thing if it doesnt exist; if it exists =A0it is an error"
> > > If it doesnt exist we will enter that (tp =3D=3D NULL) path
> > > also fh will be 0 =3D=3D> So you will never enter the code
> > > path you are refering to.
> > > If it exists (i.e you found it) and you enter the code path you refer
> > > to, then you surely dont want to destroy it if NLM_F_EXCL is set.
> >
> > I mean we don't want to link it again or destroy after ->change() err
> > if we run replace (n->nlmsg_type =3D=3D RTM_NEWTFILTER &&
> > (n->nlmsg_flags&NLM_F_CREATE)).
>
> excellent point: an additional flag is needed then
> n->nlmsg_flags& (NLM_F_CREATE|NLM_F_EXCL).
> Minoru, please add this change in the patch before testing...

OK.
I'll do it after understanding above code.
