Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F2B5C4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 13:54:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8DE5A22242
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 13:54:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DE5A22242
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 09E772E0EF;
	Mon, 26 Oct 2020 13:54:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UPRAtOwz6ecB; Mon, 26 Oct 2020 13:54:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0977320337;
	Mon, 26 Oct 2020 13:54:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EA9E3C088B;
	Mon, 26 Oct 2020 13:54:29 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CDD4FC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 13:54:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id BC3F08574A
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 13:54:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ySSOc8jpcYd5
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 13:54:27 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 4D99C85644
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 13:54:27 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id 426435803A5;
 Mon, 26 Oct 2020 09:54:26 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Mon, 26 Oct 2020 09:54:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=kSlmCz4sMFUpsf1HbCzP26yHEmE
 YsedB9bo55NEitI0=; b=N4fIzdPOUD1FSZrnwa2E7VEULe6OJqrA2CsQZlPvzjn
 A4K4V8+EJas1kemxLgNUuhsVKO0VEtLEQHUwL0qNs9wjnkW18+qh9UPQzw+DcKo8
 rYniR/ZEdcoE5geH4YpVShEPL0jnKr4U9YNmZgduQ2laP7uftOMUHNUypMzpqiYL
 zsGqBH8gZR6iIJ9p3Auas3F1spAE58zuLCGS3ghT54lKR+L1OJqDcofB7ZHQ0A1k
 N0SHC6wpJvnC1xofdLgwGAjTCHyO+8pPqwYfT8SPTaVGY3OqmKA/XQKRSaTzg6HN
 umdfBxJwIaQld1u/QhCxRIWhgWaRu+g9VD43Re0c9Ng==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=kSlmCz
 4sMFUpsf1HbCzP26yHEmEYsedB9bo55NEitI0=; b=YuQfMmAWddZ6lzY9qWi8De
 EevwqyqTBdJRixuGyQIT6/ZmQFtn9T4cRS7b7P+UeP+zQ/mDkA3y0ORseuhX/i1b
 MuUulsY7k7lSpnVuD7fljwxY9AEpjYGoLgay7pe8T12QH8E3sRoVLcfcGHlmIjog
 6JVamt9TXagKIBNFIJr620UlxSLgoaCqv3jWQoDC2VrOVpX3wOmLtot4HGPCo7v+
 REgLdwBAMbl/4sAXoDvJ5yv8EbevdsT7K3CU5/H15r0iC+Zof5ikWozdr3c228uP
 wzogu2ZY1Q2Fd+/s//ek2xKslyKmTgNG02Xvz/viuOD9RG6p9RlP6hYO71AC5shg
 ==
X-ME-Sender: <xms:EdWWX5VaK4tBn26X7NRJAKNR621-QVwQ6-3Jj6tLOaxVMKa3NWS2oA>
 <xme:EdWWX5mLKTTvbV7HVXTcnZ_mJwqu0kbBRieTjN6T1UlmI2--M-3PXEE_hDSCXDfB5
 H-HU4goxbfazN2Q28I>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrkeejgddvtdcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffeukeekudejfefhjeevgeejgffhkefhffetleduvddufeekteelkeekhfef
 udejnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepuddvkedruddtjedrvd
 eguddrudejgeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhr
 ohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:EdWWX1Y-iN_dPhavTsiWDhW8O14gI07LeLWCiMZcd-nvUA0pTi8Lag>
 <xmx:EdWWX8U6L-Vgl4RDX8wGC_x1DdmA6O2Zm44U4ZRWolHfVPh-Q0qqJA>
 <xmx:EdWWXznIyENZ5PuS1xp4fHcM5gl2Kp9-xEqU1FVGQLgiwOuLn0oFbg>
 <xmx:EtWWX48Duu-mXEqntjuYz12lM5eQhpxwIb5Ar9N9tnpiIz_u6v0_NA>
Received: from cisco (unknown [128.107.241.174])
 by mail.messagingengine.com (Postfix) with ESMTPA id 555F5306467E;
 Mon, 26 Oct 2020 09:54:21 -0400 (EDT)
Date: Mon, 26 Oct 2020 07:54:18 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
Message-ID: <20201026135418.GN1884107@cisco>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
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

On Mon, Oct 26, 2020 at 10:55:04AM +0100, Michael Kerrisk (man-pages) wrote:
> Hi all (and especially Tycho and Sargun),
> 
> Following review comments on the first draft (thanks to Jann, Kees,
> Christian and Tycho), I've made a lot of changes to this page.
> I've also added a few FIXMEs relating to outstanding API issues.
> I'd like a second pass review of the page before I release it.
> But also, this mail serves as a way of noting the outstanding API
> issues.
> 
> Tycho: I still have an outstanding question for you at [2].
> [2] https://lore.kernel.org/linux-man/8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com/

I don't have that thread in my inbox any more, but I can reply here:
no, I don't know any users of this info, but I also don't anticipate
knowing how people will all use this feature :)

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
