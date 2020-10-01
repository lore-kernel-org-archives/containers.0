Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F1BC4727C
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 11:53:06 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB0E521481
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 11:53:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Rm8sVxbE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB0E521481
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5C47886A50;
	Thu,  1 Oct 2020 11:53:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KYyMWFB3pQb6; Thu,  1 Oct 2020 11:53:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 88A4D869DA;
	Thu,  1 Oct 2020 11:53:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 82E28C016F;
	Thu,  1 Oct 2020 11:53:04 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 22AA5C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:53:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 0C7D987304
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:53:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id uicNSRRfLQLI
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:53:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by hemlock.osuosl.org (Postfix) with ESMTPS id C9888872C9
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:53:01 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 34so3834801pgo.13
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 04:53:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=Ew4VpFAID5/91wHSxcOL77yeQtHrkm/V+7lDob87O50=;
 b=Rm8sVxbEC6FnNBaWCS0c/8J0FWn/fO/biBVrxzj0ZxEuhtBeQ72F3kr5eghywKeDsJ
 zt6MOjNPJTG7QxzRCEh3yTBGBdPQEeOWTg/2GxfGCxVUk+/BAFCKiDVQ2U0q/ecMIJkW
 Z6c1RqbK4/PEE7ci2tU+2It6OFH/GXYjDXrV/mqDhVPuC3HCeA5iZ4+VRMdwqmoU9QhG
 g/r8pRkfNgfJrh8jG9WmFrzpYnEXR3jitLarnsv0wZb5gDA8K+Tn59r1vOmm8ymTuOts
 3bGr8I7n8OVTyy8lSrqM667WxT0+JXzWEXoIB2CNlhdu/LPkCSFMupe5KfZym/dvdDzK
 bggg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=Ew4VpFAID5/91wHSxcOL77yeQtHrkm/V+7lDob87O50=;
 b=awPn0/iCUYZDayPIqlxEJAcMvB/UZ8+c2VhdJNRls8Vtf/3nbpz+tha3Zj6ZCqCs/E
 LzJa42FbLD3UoyUxVqgTVH8O89iGrp5qedBoIHQ3iT7KzPyMtDe5/F+iXyTicxkDWEJm
 Qlk79d8+DuFtjKFSYc9EPUtPk4lErVG8rTyEq5BYJ+/dkPH6e/I09rds2SUK4/+7z02D
 6N81tF47Rr7ZF0bv8q9z3qkG8Dx8yZMkOqbRNU99tYIzinSCy//lhdMDrdfTtBOuOaDV
 FDAYRLxmVos1CIbJQWVxydzjMbmFMrxWkYxoK8Ki/ohZbwGPMTYNcdykELX5npDFsdc1
 iZNQ==
X-Gm-Message-State: AOAM5309YSNDBvI/Yv0NyLPv8gesdbm4y/TRUK7fo1+r4/L+Sp5Y7N2e
 Vje+pgg4Np/hHTzYlhomKIZWCEOLErxLzvD6eMc=
X-Google-Smtp-Source: ABdhPJyStB+vgk3YD1yY5mZQmL9Xp3Jb8gyCmADH8SYrhYoKtl75PkiUyvJnXc4nhxlGvoFoI7J+PufgaOmSsyXd0dU=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr2315007pfe.11.1601553181129; Thu, 01
 Oct 2020 04:53:01 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <202009301432.C862BBC4B@keescook>
In-Reply-To: <202009301432.C862BBC4B@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 1 Oct 2020 06:52:50 -0500
Message-ID: <CABqSeATqYuEAb=i1nxufbVQUWRw6FDbb9x0DYJz87U0RbQj14A@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Wed, Sep 30, 2020 at 5:40 PM Kees Cook <keescook@chromium.org> wrote:
> I don't want this config: there is only 1 caching mechanism happening
> in this series and I do not want to have it buildable as "off": it
> should be available for all supported architectures. When further caching
> methods happen, the config can be introduced then (though I'll likely
> argue it should then be a boot param to allow distro kernels to make it
> selectable).

Alright, we can think about configuration (or boot param) when more
methods happen then.

> The guiding principle with seccomp's designs is to always make things
> _more_ restrictive, never less. While we can never escape the
> consequences of having seccomp_is_const_allow() report the wrong
> answer, we can at least follow the basic principles, hopefully
> minimizing the impact.
>
> When the bitmap starts with "always allowed" and we only flip it towards
> "run full filters", we're only ever making things more restrictive. If
> we instead go from "run full filters" towards "always allowed", we run
> the risk of making things less restrictive. For example: a process that
> maliciously adds a filter that the emulator mistakenly evaluates to
> "always allow" doesn't suddenly cause all the prior filters to stop running.
> (i.e. this isolates the flaw outcome, and doesn't depend on the early
> "do not emulate if we already know we have to run filters" case before
> the emulation call: there is no code path that allows the cache to
> weaken: it can only maintain it being wrong).
>
> Without any seccomp filter installed, all syscalls are "always allowed"
> (from the perspective of the seccomp boundary), so the default of the
> cache needs to be "always allowed".

I cannot follow this. If a 'process that maliciously adds a filter
that the emulator mistakenly evaluates to "always allow" doesn't
suddenly cause all the prior filters to stop running', hence, you
want, by default, the cache to be as transparent as possible. You
would lift the restriction if and only if you are absolutely sure it
does not cause an impact.

In this patch, if there are prior filters, it goes through this logic:

        if (bitmap_prev && !test_bit(nr, bitmap_prev))
            continue;

Hence, if the malicious filter were to happen, and prior filters were
supposed to run, then seccomp_is_const_allow is simply not invoked --
what it returns cannot be used maliciously by an adversary.

>         if (bitmap_prev) {
>                 /* The new filter must be as restrictive as the last. */
>                 bitmap_copy(bitmap, bitmap_prev, bitmap_size);
>         } else {
>                 /* Before any filters, all syscalls are always allowed. */
>                 bitmap_fill(bitmap, bitmap_size);
>         }
>
>         for (nr = 0; nr < bitmap_size; nr++) {
>                 /* No bitmap change: not a cacheable action. */
>                 if (!test_bit(nr, bitmap_prev) ||
>                         continue;
>
>                 /* No bitmap change: continue to always allow. */
>                 if (seccomp_is_const_allow(fprog, &sd))
>                         continue;
>
>                 /* Not a cacheable action: always run filters. */
>                 clear_bit(nr, bitmap);

I'm not strongly against this logic. I just feel unconvinced that this
is any different with a slightly increased complexity.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
