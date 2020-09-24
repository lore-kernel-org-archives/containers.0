Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A7CC2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:22:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AF0FB221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:22:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HipLz25I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0FB221EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3045D874BF;
	Thu, 24 Sep 2020 08:22:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7NgJ7TqqstvC; Thu, 24 Sep 2020 08:22:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id ADCD887497;
	Thu, 24 Sep 2020 08:22:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9B1BEC0889;
	Thu, 24 Sep 2020 08:22:43 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E9143C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:22:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E2A2086B52
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:22:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 6HJPKrlha1Rl
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:22:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 7A32886B15
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:22:42 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id f18so1426170pfa.10
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 01:22:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=VffSKFOKcNEqzHH96dUPgeCMOjgSgi5QH+6TbDKTeEM=;
 b=HipLz25IFRXLxQfyxq4wFJF7SpeY50MTG/68Rn/bZPdFoaCB5RgVZiDO4bHvmNvvZ4
 p6sy/hJUOSKo+2YZx+a56N8Jo1WSofPDYjUzrdr0Y9+lMc/FYU6gFdDq++W+y6HTyIKr
 6mX4yJsgG5TwesHDZi2GvGeqpZfz7eeXMfifbLMX3X53uJX3I7PNLjiYgbYEiM3GObBZ
 dHckkMr2aM7gdOwFHBRH+P5Nt7EophqGBog+xZTERCxnN0mRajqsDE4Hzhxfbw75pTON
 f/koI/Lz+OIUxDB7Lc9S4XTXrzH4IG0HToeF13Cq1r6oyNExplV1dMJJ5LN2muREHtWZ
 2Wgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=VffSKFOKcNEqzHH96dUPgeCMOjgSgi5QH+6TbDKTeEM=;
 b=q3hz/FW7xLQH9HVbU5m31gZB3W6OWAKBq07r4+ITx/dSybJjv6vWfYCQGuBUJFUeJa
 QTWjqkQmcqU0dD1gwbEqVW5y+KbhNice+JI8GhnY8bK2WKoXUZbwutIdoXPa5iHMUmKJ
 uUr0DkHu6P3uojtpdII3BII/R9DqbwBr8dd9UwyHfrok0x19U2UUKf549lXBMAfyHAwp
 AwVR1x2TjYOQC/WpqwlUEcHZXQdp0w2ilzr6zRuwAOuFu6cQmCt+sJzAfeNyDyTwpSl9
 y8DD/Tj6N1mpQDdZVMfo5miuVEljhqH0LF1CNQpSY6kpYddh/JQp6iUr0x/dUDwitBES
 fSgg==
X-Gm-Message-State: AOAM532Edz0ZJekXKKmXbvPGC/LrfpF1J/TBBc6idQSMqF0HbLNy88Yg
 6AT6l56JBD0NBOmYtz+lNmfCcFki8iHSwnI81kU=
X-Google-Smtp-Source: ABdhPJyN6S3PvfBf/m7CmcAzF+8SBUXc1APBXPdomlmhd7pAkzxdoiweeazvaxZ3itj9ZG2VZdsL6HkmkZuhi7/iYzU=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr3496844pfe.11.1600935761975; Thu, 24
 Sep 2020 01:22:41 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
 <202009240018.A4D8274F@keescook>
 <CABqSeARV4prXOWf9qOBnm5Mm_aAdjwquqFFLQSuL0EegqeWEkA@mail.gmail.com>
 <202009240112.C48EF38EC2@keescook>
In-Reply-To: <202009240112.C48EF38EC2@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 03:22:31 -0500
Message-ID: <CABqSeAR+DO3=Gt1KAAYKTJd7k07sH+aQCkofXxm7nX2TXh=w6A@mail.gmail.com>
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

On Thu, Sep 24, 2020 at 3:15 AM Kees Cook <keescook@chromium.org> wrote:
> I was trying to be helpful: you hadn't seen the RFC, and it was missing
> the emulator piece, which I wanted to be small, so I put got it out the
> door today. I didn't want you to think you needed to port the larger
> emulator over, for example.

There's no architecture-dependent code in the emulator. It just has to
iterate through all the arch numbers. So I don't know what you are
referring to by "port ... over".
The logic is simple. If the emulator determines the filter must be an
allow for a given arch / syscall pair, then it is "cached by bitmap".

> I'm open to ideas, but I want to have a non-optional performance
> improvement as the first step. :)

How about "performance improvement by default"? It's not like most end
users / distros would turn off something that's enabled by default
when they upgrade to a new kernel.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
