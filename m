Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C171C433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 14:08:29 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8BF1061407
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 14:08:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BF1061407
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 2199840E69;
	Wed, 28 Apr 2021 14:08:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0kh-keLvMc2e; Wed, 28 Apr 2021 14:08:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id CF2864068F;
	Wed, 28 Apr 2021 14:08:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A790EC0022;
	Wed, 28 Apr 2021 14:08:26 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1B67FC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:08:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 099DE404DD
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:08:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="sV37b5AM";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="cq50BgRK"
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MV3_CcDrJh_i
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:08:24 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 38C3C400D6
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:08:24 +0000 (UTC)
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
 by mailnew.nyi.internal (Postfix) with ESMTP id 2A6BF580C4D;
 Wed, 28 Apr 2021 10:08:21 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute1.internal (MEProxy); Wed, 28 Apr 2021 10:08:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=czH9iPt1oe0ViL1vs30hEmtJagL
 Us283mfCg69IYZBo=; b=sV37b5AMGuS8AbmPmPqEKPlRIcvXb/683GEBq7Nir8C
 74JEYwMMAbb4dG+AipiUxpBo9LBvuhGoxxXVzIFWqSMqQYInAlyyjUxBT1Dmfs9S
 GeJ5gsmdNiKis5/wJLzmx116mWJ6LADTthp7PhyQ5QFj4c0iHFWRI7GYPb8bCOUL
 krEKJp5j/bZQhquctNbCAeRZ7lHBiOYmrT1o8mD2gFD4uhB6v7wTfFtxUNYgkTiJ
 b0w8ZHwpDpnV9QQeOIB6hkin3csqb5HqPqgr7k3DmjK+v6ImZ7bPQBkH0ATIEYJL
 mSV6CdIZh0iiICiG8L0uor9ZGY2ldnK8VBfdp4PpQEg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=czH9iP
 t1oe0ViL1vs30hEmtJagLUs283mfCg69IYZBo=; b=cq50BgRKSbQFNnrGYCfYqR
 064ASNkT+tPvwaclIkVfcO/waNEDb0wf/5yGQNYAmsozPlHevmZR+9b3QeWyNtHp
 DwtM4uzqYAEmlag1FMKkloJhveMJyFeleWtw6zOR66XpgH66KjHwxLS7M/qdKjvW
 OeOnmsswXsnspLQHj+m1b5G7nGa6vzEYRpZm8r/3rzR/W8H8/nIZWb8/IrJT6uAZ
 zjXWq5c6T5XmgeP3r2oaqXWYV6r6SHLGGXHfyaHeK6S3xuvpVcXmyAn+lCGljeGx
 W5dht0KuvUNQPJaQlDnfkahu/bCeah1WRSVu2QrnUHec7Xgkfx3lyvJKBiQP6rvg
 ==
X-ME-Sender: <xms:VGyJYI39SGoygyXlI-eIgCC9mA8BogknYoWNtjDW5Bd_dH34LDbFIg>
 <xme:VGyJYDG_0iA_BK_pk55WUHvk2NevFRnkvaVAi3fzoGLyVO0EUJb19r5K_3i7Twmdk
 LEF217wD-PEQbQZskw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddvvddggeekucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepudejgedrhedurdduvddrkedunecuvehluhhsthgvrhfuihiivgeptd
 enucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:VGyJYA7GDQhuf34xMi9TYjsbyGirlznnG4eP3XbDnanWP9il7c0yVA>
 <xmx:VGyJYB1Umcu1sY8A2o1V95AfFP7Ha8kfAzAQtkrjZ_CVQU8sokAOKg>
 <xmx:VGyJYLGi2l4ICXfRfI2Pp1hJe6m9QUHPKU6RjYNhJVYf-tvdDaC2yA>
 <xmx:VWyJYBZOEl1Th3qUy3CNlJ3cPdMUSnCNx4j5GtnyOfV-wCt8fBuEXg>
Received: from cisco (c-174-51-12-81.hsd1.co.comcast.net [174.51.12.81])
 by mail.messagingengine.com (Postfix) with ESMTPA;
 Wed, 28 Apr 2021 10:08:19 -0400 (EDT)
Date: Wed, 28 Apr 2021 08:08:17 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Rodrigo Campos <rodrigo@kinvolk.io>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210428140817.GA1965193@cisco>
References: <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
 <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
 <20210428002215.GB1786245@cisco>
 <CACaBj2ZchRGzHpGn5TD2FE=yKWZotVRNZ7M78TmvGfM9BoHF4g@mail.gmail.com>
 <CACaBj2aSnzQnbZG0sMM2Vae_yWGzxKWrGUz9xJVL_7akF8DvNA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CACaBj2aSnzQnbZG0sMM2Vae_yWGzxKWrGUz9xJVL_7akF8DvNA@mail.gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>,
 Andy Lutomirski <luto@kernel.org>,
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

On Wed, Apr 28, 2021 at 03:20:02PM +0200, Rodrigo Campos wrote:
> On Wed, Apr 28, 2021 at 1:10 PM Rodrigo Campos <rodrigo@kinvolk.io> wrote:
> >
> > On Wed, Apr 28, 2021 at 2:22 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > >
> > > On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> > > > User notifiers should allow correct emulation.  Right now, it doesn't,
> > > > but there is no reason it can't.
> > >
> > > Thanks for the explanation.
> > >
> > > Consider fsmount, which has a,
> > >
> > >         ret = mutex_lock_interruptible(&fc->uapi_mutex);
> > >         if (ret < 0)
> > >                 goto err_fsfd;
> > >
> > > If a regular task is interrupted during that wait, it return -EINTR
> > > or whatever back to userspace.
> > >
> > > Suppose that we intercept fsmount. The supervisor decides the mount is
> > > OK, does the fsmount, injects the mount fd into the container, and
> > > then the tracee receives a signal. At this point, the mount fd is
> > > visible inside the container. The supervisor gets a notification about
> > > the signal and revokes the mount fd, but there was some time where it
> > > was exposed in the container, whereas with the interrupt in the native
> > > syscall there was never any exposure.
> >
> > IIUC, this is solved by my patch, patch 4 of the series. The
> > supervisor should do the addfd with the flag added in that patch
> > (SECCOMP_ADDFD_FLAG_SEND) for an atomic "addfd + send".
> 
> Well, under Andy's proposal handling that is even simpler. If the
> signal is delivered after we added the fd (note that the container
> syscall does not return when the signal arrives, as it happens today,
> it just signals the notifier and continues to wait), we can just
> ignore the signal and return that (if that is the appropriate thing
> for that syscall, but I guess after adding an fd there isn't any other
> reasonable thing to do).

Yes, agreed. After thinking about this more, my example is bogus: the
kernel doesn't sleep after it installs the fd, so it would ignore any
signals too.

Even if the kernel *did* sleep after installing the fd, it would still
be correct emulation to install it and then do whatever the kernel did
during that sleep. So I withdraw my objection :)

Thanks,

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
