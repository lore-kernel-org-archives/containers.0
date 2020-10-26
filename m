Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA3A5C4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 14:32:25 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2918920757
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 14:32:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2918920757
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id F191486818;
	Mon, 26 Oct 2020 14:32:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1lpYsqwXpxDI; Mon, 26 Oct 2020 14:32:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5BCBD86503;
	Mon, 26 Oct 2020 14:32:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 42936C0859;
	Mon, 26 Oct 2020 14:32:24 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AAC05C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:32:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 9970985F98
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:32:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IYbaiIv_Q13E
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:32:22 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0F84D85F81
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:32:21 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id 2244A580146;
 Mon, 26 Oct 2020 10:32:21 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Mon, 26 Oct 2020 10:32:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=64+TAaOwh1IPJrs0ew/aA4+odj3
 25YN8/5rfD/oYrDM=; b=LT8cpr5Kh6K0Ro6/cKplrnfXH3isKEpTudX+6zrtaMH
 rLT6ENT8D6m5Ls3tAEPHkIGxwjzxn+c6bOsRXMcUR1Zn867zOOI1EG22nItmsh1J
 8t6NamCrambbUlKLR+xYCCHHeIVfz6FBhleOZgrp5FiDxjn+ogGl+3lPVOs4SSqC
 f+uiWMyXYlmuFtaYnTUIOLYITt1twmTNLJZ+jDoobhr0H4jKXL8llE57tYGQltqK
 umeGNV2KvX/WGZ1IBRKhHIQDX7/IyKKARLOV8/AZtmBnkatzOKo/ZZliu0jFhlFH
 ArQH7A7KodlOewJHxRul/sx1zmvT3frTgVE9/iNB5gw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=64+TAa
 Owh1IPJrs0ew/aA4+odj325YN8/5rfD/oYrDM=; b=NEUcPj6XHhh3kOzAu3ag/s
 nPNkkMGeXt5W27d2BLHGXr0MkuBotIoRp1sLCzdvw/bjOTkUeVcwV0J1LVyYpaAa
 Rc98WepKd+XaG2XU9w3WumMNLY7FnqmY7J0O2Xx1vKKODqNnDh3VTP/UU2HDRotL
 9Nr8mSDPj5pFccM2hXmj8JDYqANVK9V3ck4o9yPTAzKx3ZCcHTxFgy7qGnpd3BJs
 LRZouGJw9Y642r/7eMLyLcECaAD7MipxSQeqQT5rJIhcopR33yLDXW3BzsiZ6u95
 vPi1pU4En6jkV37PXHo1Rg190XEL0Mr0f4sooFBeK2zBnrTxs0+ePt0vKu/UKuaw
 ==
X-ME-Sender: <xms:9N2WX6PPOt4w9dmLyTrvwF431bcJjjboqsm_d0A8rZOhAeDwE4EzWQ>
 <xme:9N2WX4_20IFlSXcU4GQ8wn_pxGBjObeQ_MG5CKK3i-Hoj6Cs_cFczo5vZo95ZH3pE
 o-j-jBUU_z1D7Zxn-U>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrkeejgddvlecutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffeukeekudejfefhjeevgeejgffhkefhffetleduvddufeekteelkeekhfef
 udejnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepuddvkedruddtjedrvd
 eguddrudejgeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhr
 ohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:9N2WXxTNsUh_shhWVhMb0akcOziwH4cOttFK5z3kgrEWKdw11el7iQ>
 <xmx:9N2WX6u1R11wX9PMoWrNC21SQLxb16_y0XwsjRlRkBF-1uE_QHMqcg>
 <xmx:9N2WXyfApyQJzyOKT-d13Wos4LwRv33_wyIAQ9YMAGwCpxZi571hVw>
 <xmx:9d2WX92bTXYLWO2P8bM6B32xPbmcdZJ4_nmk59JpTQc7lEF42DYGrw>
Received: from cisco (unknown [128.107.241.174])
 by mail.messagingengine.com (Postfix) with ESMTPA id 129D53064684;
 Mon, 26 Oct 2020 10:32:15 -0400 (EDT)
Date: Mon, 26 Oct 2020 08:32:13 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
Message-ID: <20201026143213.GO1884107@cisco>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201026135418.GN1884107@cisco>
 <CAKgNAkgbvuEJ0rkLrZGgCf0OTC8YH2vxemNic8SsDxjh=Z22uw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAKgNAkgbvuEJ0rkLrZGgCf0OTC8YH2vxemNic8SsDxjh=Z22uw@mail.gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, lkml <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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

On Mon, Oct 26, 2020 at 03:30:29PM +0100, Michael Kerrisk (man-pages) wrote:
> Hi Tycho,
> 
> Thanks for getting back to me.
> 
> On Mon, 26 Oct 2020 at 14:54, Tycho Andersen <tycho@tycho.pizza> wrote:
> >
> > On Mon, Oct 26, 2020 at 10:55:04AM +0100, Michael Kerrisk (man-pages) wrote:
> > > Hi all (and especially Tycho and Sargun),
> > >
> > > Following review comments on the first draft (thanks to Jann, Kees,
> > > Christian and Tycho), I've made a lot of changes to this page.
> > > I've also added a few FIXMEs relating to outstanding API issues.
> > > I'd like a second pass review of the page before I release it.
> > > But also, this mail serves as a way of noting the outstanding API
> > > issues.
> > >
> > > Tycho: I still have an outstanding question for you at [2].
> > > [2] https://lore.kernel.org/linux-man/8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com/
> >
> > I don't have that thread in my inbox any more, but I can reply here:
> > no, I don't know any users of this info, but I also don't anticipate
> > knowing how people will all use this feature :)
> 
> Yes, but my questions were:
> 
> [[
> [1] So, I think maybe I now understand what you intended with setting
> POLLOUT: the notification has been received ("read") and now the
> FD can be used to NOTIFY_SEND ("write") a response. Right?
> 
> [2] If that's correct, I don't have a problem with it. I just wonder:
> is it useful? IOW: are there situations where the process doing the
> NOTIFY_SEND might want to test for POLLOUT because the it doesn't
> know whether a NOTIFY_RECV has occurred?
> ]]
> 
> So, do I understand right in [1]? (The implication from your reply is
> yes, but I want to be sure...)

Yes.

> For [2], my question was not about users, but *use cases*. The
> question I asked myself is: why does the feature exist? Hence my
> question [2] reworded: "when you designed this, did you have in mind
> scenarios here the process doing the NOTIFY_SEND might need to test
> for POLLOUT because it doesn't know whether a NOTIFY_RECV has
> occurred?"

I did not.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
