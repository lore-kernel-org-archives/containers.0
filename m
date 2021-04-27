Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE747C433B4
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 13:56:11 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1ABD06101E
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 13:56:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ABD06101E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id AA633405A9;
	Tue, 27 Apr 2021 13:56:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UwksCwrqKoAe; Tue, 27 Apr 2021 13:56:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 6B8BF405BE;
	Tue, 27 Apr 2021 13:56:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 465DBC000F;
	Tue, 27 Apr 2021 13:56:09 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AC0F0C000B
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 13:56:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 98BE940173
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 13:56:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="6uwTs8Qi";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="IPF6WClQ"
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Wc6deUBHq48c
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 13:56:06 +0000 (UTC)
X-Greylist: delayed 00:07:06 by SQLgrey-1.8.0
Received: from wnew3-smtp.messagingengine.com (wnew3-smtp.messagingengine.com
 [64.147.123.17])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 772F9401F0
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 13:56:06 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.west.internal (Postfix) with ESMTP id 60E3DFB2;
 Tue, 27 Apr 2021 09:48:56 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute4.internal (MEProxy); Tue, 27 Apr 2021 09:48:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=b5wS/V0vTP6vNmB11i0KyHFvJOb
 Cf57C/oZYcJ4cqJY=; b=6uwTs8Qi5kJXxXKXrFMn5xsdAhX/28iA7BjY1nWjh3X
 N7QyolRzmcnM+72P/VJrYNyhtcitbMd6vWVf2sImQytOpPFTDZMAEJux9luWrVUW
 KoY0evfCjktmUonK4MD14B/xU28NNHzdRd3oNm6ztZzxU/locgTuvHLo10/luUCe
 epi1B54FOsg6OY8SMNZ3w8kvvqMShvcJ1eZ2j2Cvvj059s9o97a2cD+raXl+qB9K
 Paya/cx2XL4Ne1O25FjqX3x+nMlFiz2kAiTcGDaBePd9pG8g66APxDTsXvcygl1b
 OkEZuHtQPbcls74/A/Qk2cwyYwcFMrMplyuUpWyOghg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=b5wS/V
 0vTP6vNmB11i0KyHFvJObCf57C/oZYcJ4cqJY=; b=IPF6WClQh8pi/fB3lqyG6O
 pf3x0MZLcYoRl5jA2IZ634Nq5s3nowBpbxHCG5tUCm1Xbx9c355FLViHPR1UWffQ
 wS0wA+I//PuZSPdiFF3bhpUBhGd2w3VU2RKYR03QFIyu4kX4spZMc6uCXH+SUVgQ
 RXus1g3eGipu+jnfweW3fwAdbfjD4xIOp9urMfejIegRllirUUlq9anpnM/plSnR
 NV27SOrjpGqAg996hl8bhWKFPi4Ohs+ojEiVcDz5D3D4Ai4I62ijHhK0/qsusnv8
 S9Y9E6JbAZShDHctPbmbz9e7w1dWnoLN4IyoqxgyGscxPdeh6vssuL42fcSs8gKQ
 ==
X-ME-Sender: <xms:RxaIYJe2VLf1gCBY4S6AdgH59EY1iR3RhUVDVVSpaRXk21b8UB_bIQ>
 <xme:RxaIYHOER7hHTg9ITcFXskbtqITetLAvfVtBjX8bfLgFeUgET1wR5bR3dtesjpbyH
 fwatrDNnynK52glgnw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddvtddgjedtucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepudejfedrfeekrdduudejrdejjeenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:RxaIYCgP14I1mxqOOiPpg1rpkIqo3qYDuPwAdxg-K8qr4Id28JLP7g>
 <xmx:RxaIYC_Q8trqgZcrx0a1_DeFYILij634rc1Bbom9BHDd8sAcLfqRcg>
 <xmx:RxaIYFuiBEpmN1RB77LECZr2iib60sAWrP-td03_pxfuvFnXg2JRnw>
 <xmx:SBaIYLARiPyU9I4CHZZA4F5PTHzFPR7vPbA3_qqzsZuww5Ut18iksmtGcco>
Received: from cisco (unknown [173.38.117.77])
 by mail.messagingengine.com (Postfix) with ESMTPA;
 Tue, 27 Apr 2021 09:48:54 -0400 (EDT)
Date: Tue, 27 Apr 2021 07:48:53 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210427134853.GA1746081@cisco>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Alban Crequy <alban@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> On Mon, Apr 26, 2021 at 01:02:29PM -0600, Tycho Andersen wrote:
> > On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> > > @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
> > >  	 * This is where we wait for a reply from userspace.
> > >  	 */
> > >  	do {
> > > +		interruptible = notification_interruptible(&n);
> > > +
> > >  		mutex_unlock(&match->notify_lock);
> > > -		err = wait_for_completion_interruptible(&n.ready);
> > > +		if (interruptible)
> > > +			err = wait_for_completion_interruptible(&n.ready);
> > > +		else
> > > +			err = wait_for_completion_killable(&n.ready);
> > >  		mutex_lock(&match->notify_lock);
> > > -		if (err != 0)
> > > +
> > > +		if (err != 0) {
> > > +			/*
> > > +			 * There is a race condition here where if the
> > > +			 * notification was received with the
> > > +			 * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> > > +			 * non-fatal signal was received before we could
> > > +			 * transition we could erroneously end our wait early.
> > > +			 *
> > > +			 * The next wait for completion will ensure the signal
> > > +			 * was not fatal.
> > > +			 */
> > > +			if (interruptible && !notification_interruptible(&n))
> > > +				continue;
> > 
> > I'm trying to understand how one would hit this race,
> > 
> 
> I'm thinking:
> P: Process that "generates" notification
> S: Supervisor
> U: User
> 
> P: Generated notification
> S: ioctl(RECV...) // With wait_killable flag.
> ...complete is called in the supervisor, but the P may not be woken up...
> U: kill -SIGTERM $P
> ...signal gets delivered to p and causes wakeup and
> wait_for_completion_interruptible returns 1...
> 
> Then you need to check the race

I see, thanks. This seems like a consequence of having the flag be
per-RECV-call vs. per-filter. Seems like it might be simpler to have
it be per-filter?

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
