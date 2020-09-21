Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D9BFC43469
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 16:39:27 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6843623998
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 16:39:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6843623998
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 026D185E93;
	Mon, 21 Sep 2020 16:39:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4zwY6vcgV8mA; Mon, 21 Sep 2020 16:39:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 3AE3285E91;
	Mon, 21 Sep 2020 16:39:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0FE08C0859;
	Mon, 21 Sep 2020 16:39:25 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A7FCCC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:39:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 80BCA866AC
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:39:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QItA0qQtPLYy
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:39:22 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com
 [66.111.4.224])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 9696786124
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:39:22 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.nyi.internal (Postfix) with ESMTP id 8E7DD580469;
 Mon, 21 Sep 2020 12:39:21 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute4.internal (MEProxy); Mon, 21 Sep 2020 12:39:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=FAKxtc4axvdMTVdc4bHyXqp9LAt
 vMDocxRFYXXZfBzg=; b=JdtF40ifOvS2VufC+D4Y/DgzsfP5T/+lwIbYsgExRNF
 uFZygQ712+2ZJOKGfZY9sOf7vGXOEiaMNuVScexUD0xE40TMAXMbhyrI15xSaIU9
 3uaYTOXwJTdUlG2E14/ixYUwdx/6hIpxvB3NkysGMM0sBFeJgmTMjh+BAi1v8Sqf
 24+7SHEJGaDQjntE1s5t3FJCUX3ZWgkcAUu8pqh6RlAxYFJEUR0aS7k+PLmQlcms
 KIKA/wEgA1hvgj1zJ+vPOHs9fEB/LWzmFtYOMjvdmSskCLdtARn/rqGTNF/eOj/t
 8Z8hF6RoXKEeQgmOB4ZX3H+fMzdALRBkInUTkGSJgOg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=FAKxtc
 4axvdMTVdc4bHyXqp9LAtvMDocxRFYXXZfBzg=; b=tbW6ec3zQjwQulgCq04Nbf
 ODrBjrjXS5VYBZKvtCZBwUYNWCnyz7wHa6Qf+X/SaEIKXF1it/gQp3XVEHjbO8DB
 CJFLnJVxcy9qbpKTgVHnpJKuLi+0ll8AZZ4N4PsVUxo6Tf7Mqo83D/+3ZU09pgFz
 vV+xNPW5g4qpOos3aZ3aAGX6RPxDN1aB3fO3LhZ1AFxOs82rBlSthYrd/heyhpTc
 5ho4ZS9v9HyMyu/OlAjyLcqhbKpeBvNMEEUB9zAev7flgyZmtIP11g1uExippFxa
 2br3iqth9LbwWMelJpi0m1sbT4gZy9wa750I/HArpGlLFxf93RHmCnRi450tFqmw
 ==
X-ME-Sender: <xms:ONdoX_JsuNaWZ-HcFgI6irtOtMH7gFRBCeU6hq0DEwJg_tGEx67FZQ>
 <xme:ONdoXzLrdbEG1m-JBpplH72_4KvcjbZmbAyQCtOqU2sY-O7PIGOuHXhBeeaRptV0R
 -YTyU2ll9iSxagRiI8>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedruddvgddutdehucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepudekgedrudeijedrvddtrdduvdejnecuvehluhhsthgvrhfuihiivg
 eptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiii
 rg
X-ME-Proxy: <xmx:ONdoX3to_KWRqqEpc-ZzpoHbdspcoQabxqO7Wt1QzCcfoDDztDDB_A>
 <xmx:ONdoX4ZqnrIAlm4MlRZoMU60ouhY41zDStNVOcJOR3mRb4ZZTGLG_g>
 <xmx:ONdoX2aD8wSBec4xA9KKgITKAMpVWUwr5uV7NRVnKowq7BI08_4dHQ>
 <xmx:OddoX2KlqNhBuhFhdi3uBfLjQ_jvhsND10mqcK-u2yDzqTkWpJAPshiGxwuWEei_>
Received: from cisco (184-167-020-127.res.spectrum.com [184.167.20.127])
 by mail.messagingengine.com (Postfix) with ESMTPA id 594E43280067;
 Mon, 21 Sep 2020 12:39:18 -0400 (EDT)
Date: Mon, 21 Sep 2020 10:39:16 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
Message-ID: <20200921163916.GE3794348@cisco>
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <20200921135115.GC3794348@cisco>
 <CABqSeASEw=Qr2CroKEpTyWMRXQkamKVUzXiEe2UsoQTCcv_99A@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASEw=Qr2CroKEpTyWMRXQkamKVUzXiEe2UsoQTCcv_99A@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-kernel@vger.kernel.org,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 10:27:56AM -0500, YiFei Zhu wrote:
> On Mon, Sep 21, 2020 at 8:51 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > One problem with a kernel config setting is that it's for all tasks.
> > While docker and systemd may make decsisions based on syscall number,
> > other applications may have more nuanced filters, and this cache would
> > yield incorrect results.
> >
> > You could work around this by making this a filter flag instead;
> > filter authors would generally know whether their filter results can
> > be cached and probably be motivated to opt in if their users are
> > complaining about slow syscall execution.
> >
> > Tycho
> 
> Yielding incorrect results should not be possible. The purpose of the
> "emulator" (for the lack of a better term) is to determine whether the
> filter reads any syscall arguments. A read from a syscall argument
> must go through the BPF_LD | BPF_ABS instruction, where the 32 bit
> multiuse field "k" is an offset to struct seccomp_data.

I see, I missed this somehow. So is there a reason to hide this behind
a config option? Isn't it just always better?

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
