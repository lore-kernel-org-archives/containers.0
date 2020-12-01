Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51E4AC64E7A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 13:13:48 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 653FE20637
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 13:13:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 653FE20637
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id CB51F871BC;
	Tue,  1 Dec 2020 13:13:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ILEP7mBQqOJ5; Tue,  1 Dec 2020 13:13:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 358EB8716C;
	Tue,  1 Dec 2020 13:13:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1A451C163C;
	Tue,  1 Dec 2020 13:13:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 07E99C0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:13:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id EAA1E86B0A
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:13:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IFu-fVwhZNYk
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:13:41 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wout4-smtp.messagingengine.com (wout4-smtp.messagingengine.com
 [64.147.123.20])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B0282869EF
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:13:41 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailout.west.internal (Postfix) with ESMTP id 8C1F4466;
 Tue,  1 Dec 2020 08:13:40 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Tue, 01 Dec 2020 08:13:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=5
 wevszoWbraFHBZPlr9a9uI0gzKRk5nxLinjk7RXHx4=; b=F2J0aIU7XVYAwiTzG
 GP5lE7bmcRVrsDTJFm9QJzuLpStllydLzycotPMocXjO6fLnuR0STLT52meZAoe9
 S71So2GS4vPppVfjRrWPWn2U9ypUWyF69qYkMwX+CLkXKEGAvvp1J7AB7LehDgMx
 oEJv1P/bTFjLmdNK6kGuuant4PqKostrDe7ZgosOnSx/HFfd9MQsiCvUcayvZS7b
 GBcDF0SMF4Ojv8mz64PJ4+aleM0LYwDl+tI7PlqJ3vbhGO5SGHvynsN4ayY3M+Bf
 twczPstzT53MozpidFvLfkGOMz+Dx+RuwFzKrQW9d2Kl9Tq/bWh1YqbVoMK8WA8Y
 56AKw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm1; bh=5wevszoWbraFHBZPlr9a9uI0gzKRk5nxLinjk7RXH
 x4=; b=j9Z/gH7afMxzhh0sAmF7HUw1GI+M8YznzxJ7sn19aCNlGH16pZPwRVhVN
 dJbXfv9wf+I23YdcZBm+QcafwpFm4ZgBrSbAuyDqoXn5+kHSh8xApbPAFmLzpQnD
 9V597u27q/xT46KO6dRiMiaIMaZFnYiLVQMrOeWgV9ywZ2UPZU2Dy5+xYCWluyfF
 Cmw8uP46OT0dgnqIe21BVaiOZm+wr9DOY9IoW0CLQ+K+t3JsHdAETczVbpNY53Bk
 EhYWn7O7uPqJIgau0qfF2HMLCoEud4N9iCvbz/8SDbCmXzLIMj3IFZhojx8gkEOy
 y7VDOWpV4STNGn/D7xqxb56YcWEiA==
X-ME-Sender: <xms:g0HGX2xGgpp-wAX_WyGdz8mzNzdAKtz-0q8TarSSvHdYcBHC3aHQ-w>
 <xme:g0HGXyQgQ7DHvBN2Chy_JzJGGK_bofOhnMZnwBJZdVSRHrgMoigHzQvoyFokCFmlx
 yI1wiZy8YZtBOFqak0>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrudeivddgheduucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtugfgjgesthekredttddtudenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhepieefuddtueegudehleetfeefieefhfdvudejgeekieetudefheetffev
 vdduudetnecuffhomhgrihhnpehlihhnuhigfhhouhhnuggrthhiohhnrdhorhhgnecukf
 hppeduvdekrddutdejrddvgedurddukedtnecuvehluhhsthgvrhfuihiivgeptdenucfr
 rghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:g0HGX4VfBSxR7YZrGuMO12ItNqNa-n-4421mZ8hoIAmlpKotd5CyAA>
 <xmx:g0HGX8iVmjs-mlcmvSqduIjlmjWX-YzBjccnbnpB4-npGB6lWd0BdA>
 <xmx:g0HGX4A6BwRnTs0aXsfvFHfN9jjlyL7ZP1Xl5B8C2pDjH1yaNv-e3g>
 <xmx:hEHGX7PyOiUMvWS1FV_eT23MSVVj32Flz68CQN5NuuHHvIA2aw_h7w>
Received: from cisco (unknown [128.107.241.180])
 by mail.messagingengine.com (Postfix) with ESMTPA id 5B51F1080057;
 Tue,  1 Dec 2020 08:13:37 -0500 (EST)
Date: Tue, 1 Dec 2020 08:13:34 -0500
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: SECCOMP_IOCTL_NOTIF_ADDFD race condition
Message-ID: <20201201131334.GC103125@cisco>
References: <CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com>
 <20201130232009.GC38675@cisco> <20201201124105.GB103125@cisco>
 <20201201130824.GA27822@ircssh-2.c.rugged-nimbus-611.internal>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201201130824.GA27822@ircssh-2.c.rugged-nimbus-611.internal>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alban Crequy <alban@kinvolk.io>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Tue, Dec 01, 2020 at 01:08:25PM +0000, Sargun Dhillon wrote:
> On Tue, Dec 01, 2020 at 07:41:05AM -0500, Tycho Andersen wrote:
> > On Mon, Nov 30, 2020 at 06:20:09PM -0500, Tycho Andersen wrote:
> > > Idea 1 sounds best to me, but maybe that's because it's the way I
> > > originally did the fd support that never landed :)
> > > =

> > > But here's an Idea 4: we add a way to remotely close an fd (I don't
> > > see that the current infra can do this, but perhaps I didn't look hard
> > > enough), and then when you get ENOENT you have to close the fd. Of
> > > course, this can't be via seccomp, so maybe it's even more racy.
> > =

> > Or better yet: what if the kernel closed everything it had added via
> > ADDFD if it didn't get a valid response from the supervisor? Then
> > everyone gets this bug fixed for free.
> > =

> > Tycho
> > _______________________________________________
> > Containers mailing list
> > Containers@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/containers
> =

> This doesn't solve=A0the problem universally because of the (Go) preempti=
on =

> problem. Unless we can guarantee that the supervisor can always handle th=
e =

> request in fewer than 10ms, or if it implements resumption behaviour. I k=
now =

> that resumption behaviour is a requirement no matter what, but the easier=
 we can =

> make it to implement resumption, the better chance we are giving users to=
 get =

> this right.

Doesn't automatic cleanup of fds make things easier? I'm not sure I
understand the argument.

I agree it doesn't fix the problem of uncooperative userspace.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
