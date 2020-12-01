Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93727C64E7A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 12:41:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B5DFA20757
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 12:41:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5DFA20757
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 23C9188028;
	Tue,  1 Dec 2020 12:41:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XiCAeRzHPToV; Tue,  1 Dec 2020 12:41:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4919B87FFA;
	Tue,  1 Dec 2020 12:41:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2E447C1833;
	Tue,  1 Dec 2020 12:41:12 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D3A92C0859
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 12:41:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id C21D987585
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 12:41:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id DkNUX9U6deyn
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 12:41:08 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wout4-smtp.messagingengine.com (wout4-smtp.messagingengine.com
 [64.147.123.20])
 by hemlock.osuosl.org (Postfix) with ESMTPS id C397387574
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 12:41:08 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailout.west.internal (Postfix) with ESMTP id DA16248F;
 Tue,  1 Dec 2020 07:41:07 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Tue, 01 Dec 2020 07:41:08 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=R6fmSKML9KtTVBoh+tDAcNNZx9k
 zhrwiKD5SpJTg/LM=; b=E+hrFEK/2joQP5vI6qceFQl9vFdt04UZ7sVBRVrbUav
 gWWq2uJSDajxWFQkqzuFeGL39IwkCs/jTgHPK2Jc5EbpdgVQ96rki5U+Ef8b0Y4G
 MLRFpbcPqWAGodyMeviLHmKqK6JRvR4vCbjx3GoakhsLDIDWGYysabRpZfqv3DPo
 hT0SfYi8Fd4Q6Ovbgez1HB3KoqDiq81LKlGpebTC6O1aJjoe4a142uDhgHY8kRZR
 dF8zJZmjSjUjdKUjBvyj2POher4uC3pVX/usHC9+GNPUEf4M1WxGZZ8AOxHh1x+k
 Uz/I8h6nj53LO2HsgxReSSRdJzFlwy7uxEZm6SMqVdg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=R6fmSK
 ML9KtTVBoh+tDAcNNZx9kzhrwiKD5SpJTg/LM=; b=V3AZfWSUzMNTBrcHI06F9v
 QwEsJLv39B9047AsuXXTCFfxrbVxAhepKYxdGY9YMIXc+wQFTHV0iaYlZO6cUOM5
 IE1B0O+oKF2bTMQ6mj3t5iZKhB1L1On+llSGtv4thfp2/gAc6BgkUz3VqabsqW1x
 Ozkon0EqMhyaQEAQ9nYPUl6aueYfTx2Dxy6cHS3uZb8wM8ImJY/5lg6Z8yqkv1dI
 2NLikEv+llOpcPeuVEckOBwAKyHaiCoNMOdAhpB8IxKqZTnEg5l8YxVx18/vCP4L
 +cTUlnP5A15RlqpYZ10jwGy4IK9yAgieL+6a1aamThPfBOjHlJeu8hxCLLC6etIw
 ==
X-ME-Sender: <xms:4jnGXxEfg8ukKO2LUKknxF8HNsoQQfBzhe5TcXchPvvvgxYn1-4VfQ>
 <xme:4jnGX2WcXx4n2FfGkyIr8o7-sryVtj1idAlDMpBR_TDvcf1jqyoc907w40W7sLI81
 GfP4L46ME306EQH-dk>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrudeivddggeehucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepgeejrddvtddurdeghedrvddtvdenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:4jnGXzKttI9aOxYwfSJf7GLOUB9uBGFvv81_0-tHMp2PQ_WXC1Qo5w>
 <xmx:4jnGX3EWhM4y-UgCc2x9_dhoChzMPkStd-7yuwazySbTwgslFTlc8g>
 <xmx:4jnGX3XY1oRVTXdENi1h8YYjhEUqp_QWQB9gx2BwdZ0WZH-x4rKgdA>
 <xmx:4znGX0if1kD89z4om3QGmblNCfaJBU_kSrMzWhYgX8SRmNbRzv7uNQ>
Received: from cisco (unknown [47.201.45.202])
 by mail.messagingengine.com (Postfix) with ESMTPA id 2D1F1328005D;
 Tue,  1 Dec 2020 07:41:06 -0500 (EST)
Date: Tue, 1 Dec 2020 07:41:05 -0500
From: Tycho Andersen <tycho@tycho.pizza>
To: Alban Crequy <alban@kinvolk.io>
Subject: Re: SECCOMP_IOCTL_NOTIF_ADDFD race condition
Message-ID: <20201201124105.GB103125@cisco>
References: <CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com>
 <20201130232009.GC38675@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201130232009.GC38675@cisco>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>
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

On Mon, Nov 30, 2020 at 06:20:09PM -0500, Tycho Andersen wrote:
> Idea 1 sounds best to me, but maybe that's because it's the way I
> originally did the fd support that never landed :)
> 
> But here's an Idea 4: we add a way to remotely close an fd (I don't
> see that the current infra can do this, but perhaps I didn't look hard
> enough), and then when you get ENOENT you have to close the fd. Of
> course, this can't be via seccomp, so maybe it's even more racy.

Or better yet: what if the kernel closed everything it had added via
ADDFD if it didn't get a valid response from the supervisor? Then
everyone gets this bug fixed for free.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
