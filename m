Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E7C9C43466
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 14:01:00 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 96D2820756
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 14:00:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D2820756
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3C5408727E;
	Mon, 21 Sep 2020 14:00:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CLU-nEwawcor; Mon, 21 Sep 2020 14:00:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 6469C87275;
	Mon, 21 Sep 2020 14:00:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4DAB4C0889;
	Mon, 21 Sep 2020 14:00:58 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E7CEFC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 14:00:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D5851867A7
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 14:00:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7CWJgdWuaY+H
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 14:00:54 +0000 (UTC)
X-Greylist: delayed 00:09:30 by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by whitealder.osuosl.org (Postfix) with ESMTPS id E3886866D4
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 14:00:53 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.nyi.internal (Postfix) with ESMTP id 4CCC1580162;
 Mon, 21 Sep 2020 09:51:20 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute4.internal (MEProxy); Mon, 21 Sep 2020 09:51:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=dWd0niNZDjpYo32pOopMGeREprt
 2/3h+qgIOqXS/juY=; b=fPvsQh/bd0gMppgV4N6rzmzKwWuua0QzVWZDHjZDm0s
 tbm/dxUSQnLrcKMii5Btstj4o5WNZs1Y6QkjDwUk8G2a8C7s5w2PNZxOA7tSwNDC
 9BYU4XihaS1PXe0n4XbFW/JNcBXO8F130+scOu/r7M7CtNHRX0KU2XZ3fsHVlow4
 S1YJrV53NV3zunvrd3c42nh8sPRh3wokIeo9L4st23MssfQgsdWwksDh4zSA9+uK
 fxqUBXTGN47xjYvYKmrx+ZWbPoFQjbhbhcXL/nV3+JdbNYMN+gI8kqYyJlpgR8My
 GUg3xSnixdwH4Ikh62u+7Qwz8PSXPeWTrpcGknZQynw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=dWd0ni
 NZDjpYo32pOopMGeREprt2/3h+qgIOqXS/juY=; b=ThvVPqfCZjBTAjTh1baPMw
 z/TELvGKt7Wa6YJnLQludZkgxzkKQMnsHbvIGvgyi3mPkDl8ru1sVD3znNHkI+7c
 ttTYSQqgqFrgs+iCBYWr1qGOwAbu5u/TvdlTL3xvJfz4dgM+bmfjvU5Nv1ww4Y1K
 f+9ZzXedHHjTkTS4r9vT2J/DTVAsqq2Qq3euDmITMuJFFa3wX7Gfvui+sFTfS1lu
 fOz+ktHdf25I6K4OhWg0GmSe0mS0KajX3uEE/qKYU5/FduxAjy5yK4IQt9IyZ+DO
 bzPRYYTVidOeHKiv8/dJLK4wTUCd0Np9feRK/PjOVu35FHhk3BDWYK3BzWOGLQYQ
 ==
X-ME-Sender: <xms:169oX4KjM2_NopyDj0NS4Hm1E0Pf_oMFRaGBy7sIh4RgOsTgAb8zwA>
 <xme:169oX4KGsX3pe7MQpMfe0jeCKNL8mJ9c-J19FQLDUFtbMlOBU3h7sicBluWRtpPTB
 pRZ6Jcb9AJc2n_hNRM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedruddvgdejvdcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieefvdfg
 tefhnecukfhppedukeegrdduieejrddvtddruddvjeenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:169oX4tpp7ZJv7yfyNXFgZ5p2LwxnLir-KegInw48t00O6EE9vIfSQ>
 <xmx:169oX1Y-IkkqouO-5d6SqtOEb7cePfvwZWNYyEe78rlnrrV2KNDJHQ>
 <xmx:169oX_aSIS9IllCnoKZBjL4tXGw8Z2LKaVsueqzWLWeAjsWjsSacYw>
 <xmx:2K9oX9ApDLQN1H_zZTrhwzIpK0147OTiA4mui2yEtmfWhpfKyt6IfDLLXJAltL6y>
Received: from cisco (184-167-020-127.res.spectrum.com [184.167.20.127])
 by mail.messagingengine.com (Postfix) with ESMTPA id A99CF3280064;
 Mon, 21 Sep 2020 09:51:17 -0400 (EDT)
Date: Mon, 21 Sep 2020 07:51:15 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
Message-ID: <20200921135115.GC3794348@cisco>
References: <cover.1600661418.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <cover.1600661418.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Valentin Rothberg <vrothber@redhat.com>,
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

On Mon, Sep 21, 2020 at 12:35:16AM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> This series adds a bitmap to cache seccomp filter results if the
> result permits a syscall and is indepenent of syscall arguments.
> This visibly decreases seccomp overhead for most common seccomp
> filters with very little memory footprint.
> 
> The overhead of running Seccomp filters has been part of some past
> discussions [1][2][3]. Oftentimes, the filters have a large number
> of instructions that check syscall numbers one by one and jump based
> on that. Some users chain BPF filters which further enlarge the
> overhead. A recent work [6] comprehensively measures the Seccomp
> overhead and shows that the overhead is non-negligible and has a
> non-trivial impact on application performance.
> 
> We propose SECCOMP_CACHE, a cache-based solution to minimize the
> Seccomp overhead. The basic idea is to cache the result of each
> syscall check to save the subsequent overhead of executing the
> filters. This is feasible, because the check in Seccomp is stateless.
> The checking results of the same syscall ID and argument remains
> the same.
> 
> We observed some common filters, such as docker's [4] or
> systemd's [5], will make most decisions based only on the syscall
> numbers, and as past discussions considered, a bitmap where each bit
> represents a syscall makes most sense for these filters.

One problem with a kernel config setting is that it's for all tasks.
While docker and systemd may make decsisions based on syscall number,
other applications may have more nuanced filters, and this cache would
yield incorrect results.

You could work around this by making this a filter flag instead;
filter authors would generally know whether their filter results can
be cached and probably be motivated to opt in if their users are
complaining about slow syscall execution.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
