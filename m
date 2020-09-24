Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E77C4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:07:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C55DC212CC
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:07:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mnc+BC6F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C55DC212CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3EF2E874CD;
	Thu, 24 Sep 2020 08:07:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w-K3A7ZVwDzX; Thu, 24 Sep 2020 08:07:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id BFBF0874BF;
	Thu, 24 Sep 2020 08:07:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A4614C0859;
	Thu, 24 Sep 2020 08:07:37 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2B552C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:07:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1A0FA874C2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:07:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ocwYr73mHeJU
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:07:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by hemlock.osuosl.org (Postfix) with ESMTPS id F3BDE874BF
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:07:34 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id u24so1448559pgi.1
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 01:07:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=SREJUM/2T/IFvbNUgYQe7MPC6WtRuEMBlyz8JPh0RI8=;
 b=Mnc+BC6FoAz03iKMGZfNCLiJ0hcECAQItB8p3zC7NQkU7aOIjVnu4MQQApiKu8VkdD
 IIbfAI5fACDSFTmNXSY2BP5jYZTYoh+H7Nufn+A/Eyf9JUSMarPYRHf0WfKR6PV9VVKx
 4eVOTx0SJ6tbgYYR8LShT3V6LZo3FywyOvm6gyFSVnHQXucycp1xLdlmQpVE+xxeTpDI
 Vn4OIg5eRiA6sxRTLhmf2rbLQeB8aQS/1mJhff2kWLWxUhDHJToSjCqq8EMjfoFMr/cA
 pRF9+pdALsdYgc/ACOpNS3ZybtsRlnTTs9QRWEoaTCYfEbpqMxB6oCMFuSCQzDotR+Pr
 kI4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=SREJUM/2T/IFvbNUgYQe7MPC6WtRuEMBlyz8JPh0RI8=;
 b=TQXTEjgfJelHGPpfxZSfwCQPo8n3yfdM7i/ZqPap8bSKSRI+SiQHbRIukJxeBcZ92i
 87+U3OfO0i6KeIA3LEu5B0wD8Yl+Ss5xDqt9fL0g70LUk3O/KJP1cXyT7Xz63HMQAdT4
 0xtz58kXfgL3ShEqUb1JWOKC5flvEQHVu0d/5hYi8zWHeJN562APGKUMAjhTSapMUDn6
 vkzWvWrwiKA9sroD15dAxyxV9jasP1I3b9Zo/3vJ+LSmNMVgmVXUyqcljAJNuG/+nszY
 yyuolocXJoFh0O15YXxOOGZruc9JP72Lk2HNBRVXJ97UmMtZF6wP8Zw08OM3ZHAa++8I
 GGwg==
X-Gm-Message-State: AOAM5300DMnPlhkYEKEM8La4otu0yLZ4hWpAvLCa6cSx3HGS3YYMN4zW
 5hoAJw2kjqZ8aOVlji75zt4wW60oP2A2L9wFmZg=
X-Google-Smtp-Source: ABdhPJzZ3GxH/oMcyPcHsQNCDSKN+Hop/BoyiHOBELjZoiXsEPwNcDL/lPsrx3FEqSA+3lQeJ3rj/jYXD7zR6Yfvz7k=
X-Received: by 2002:aa7:8645:0:b029:13c:de96:6fde with SMTP id
 a5-20020aa786450000b029013cde966fdemr3426229pfo.14.1600934854466; Thu, 24 Sep
 2020 01:07:34 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
 <202009240018.A4D8274F@keescook>
In-Reply-To: <202009240018.A4D8274F@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 03:07:23 -0500
Message-ID: <CABqSeARV4prXOWf9qOBnm5Mm_aAdjwquqFFLQSuL0EegqeWEkA@mail.gmail.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 2:37 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > This belongs over into patch 1.
>
> Thanks! I was rushing to get this posted so YiFei Zhu wouldn't spend
> time fighting with arch and Kconfig stuff. :) I'll clean this (and the
> other random cruft) up.

Wait, what? I'm sorry. We have already begun fixing the mentioned
issues (mostly the split bitmaps for different arches). Although yes
it's nice to have another implementation to refer to so we get the
best of both worlds (and yes I'm already copying some of the code I
think are better here over there), don't you think it's not nice to
say "Hey I've worked on this in June, it needed rework but I didn't
send the newer version. Now you sent yours so I'll rush mine so your
work is redundant."?

That said, I do think this should be configurable. Users would be free
to experiment with the bitmap on or off, just like users may turn
seccomp off entirely. A choice also allows users to select different
implementations, a few whom I work with have ideas on how to
accelerate / cache argument dependent syscalls, for example.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
