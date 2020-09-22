Return-Path: <SRS0=1mNv=C7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 023F2C4727E
	for <containers@archiver.kernel.org>; Tue, 22 Sep 2020 00:26:19 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7587323A79
	for <containers@archiver.kernel.org>; Tue, 22 Sep 2020 00:26:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="k/z93i6O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7587323A79
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id F13CF8721A;
	Tue, 22 Sep 2020 00:26:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ddTJBULtj6EU; Tue, 22 Sep 2020 00:26:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 51B0F87218;
	Tue, 22 Sep 2020 00:26:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 346C6C0859;
	Tue, 22 Sep 2020 00:26:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 08FEDC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:26:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id E18AF20C92
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:26:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZqFla8WQAa2B
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:26:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com
 [209.85.208.67])
 by silver.osuosl.org (Postfix) with ESMTPS id 92C882079A
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:26:14 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id n13so14487655edo.10
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:26:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=G7Ck98WMie8De6O0pTDamAVkzQynN+XYnigX3qz8tH0=;
 b=k/z93i6OyQSEoXepask26HHwQk3IBf+bJK74Jop2UZRbnG76zfY4uGo4LrMenkM0zm
 vuXXzpu248e8WXJjF+yIbRf1oQSTDH/vH+HbRMObPEnr3axoMbxhiB3SAJgULvCCz79M
 uNljKMUaSbJyXYEa16ZHOYWCpO2wjYahMiL6kgPZqGlfMEGyMHCn1fyT9gqVquT2YY12
 BH5YyBtacnsqwewtapzcJe7jIZiqSkh3jfZWeeRpaGWM08VK1l+8loXjp+N671wTOw2N
 kMIsG4Ab98xHV23Gs1TY1e6EiYdOk4NEHCohbJKjOK2vT5lzDigPQznFKsKNjT39jRiy
 Z7VA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=G7Ck98WMie8De6O0pTDamAVkzQynN+XYnigX3qz8tH0=;
 b=HwJpFiNV/fwEf1WgPWXXSckNLw8CHF/RWK6ZvGCnUNTRZA0UroDa3/0w6QDMxpSdqX
 XGwVY6FL66zwKRcIZjzBrt8Ax8hFBkO2gxqZ1s+XHuzinLND7ippBucwkhWibvKU2IyE
 rzUrsn2m/+TGDmC4GdiQl7JsvbRghmGmVpyUz9LdS2NlLCkAwoY9WWyuQkh4pN5m8aUT
 bHDfvhpcjU5125zItCMNu2bWWWKXy4rOfxmbuezBUzDgKdrFniMjRk/MYIenaugxu1/K
 2ohKQOuhxqBXL2Y5afesITGfc6ijJpoEw+/R5oqn9pD5cmuYLHvuWJTqsg6TiEA+ftSo
 YPOg==
X-Gm-Message-State: AOAM532in2W96SsgoWzSj9whMDQKK4Qp04I0Ufn/n7ANq1HWfruVk+0G
 vROlhieBLurLYKNiHfuOFw3YhZU8ODX0DoWrw6I+Ag==
X-Google-Smtp-Source: ABdhPJyFQ1Gq/sHgfmYT/vq4s/qP10k5TYYWZoaOsilWoxhPoBnktNQHuIjFbeqYafUSymIhlYjKGFwLYz/eJFOUEeY=
X-Received: by 2002:a50:fe98:: with SMTP id d24mr1408695edt.223.1600734372652; 
 Mon, 21 Sep 2020 17:26:12 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
 <CABqSeAQhVFeG1Frvu60XfUnRQ78YRS2Uaw1EsBobKVku-vVoDQ@mail.gmail.com>
In-Reply-To: <CABqSeAQhVFeG1Frvu60XfUnRQ78YRS2Uaw1EsBobKVku-vVoDQ@mail.gmail.com>
Date: Tue, 22 Sep 2020 02:25:46 +0200
Message-ID: <CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: YiFei Zhu <zhuyifei1999@gmail.com>, Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Tue, Sep 22, 2020 at 1:44 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> On Mon, Sep 21, 2020 at 12:47 PM Jann Horn <jannh@google.com> wrote:
> > > +       depends on SECCOMP
> > > +       depends on SECCOMP_FILTER
> >
> > SECCOMP_FILTER already depends on SECCOMP, so the "depends on SECCOMP"
> > line is unnecessary.
>
> The reason that this is here is because of the looks in menuconfig.
> SECCOMP is the direct previous entry, so if this depends on SECCOMP
> then the config would be indented. Is this looks not worth keeping or
> is there some better way to do this?

Ah, I didn't realize this.

> > > +       help
> > > +         Seccomp filters can potentially incur large overhead for each
> > > +         system call. This can alleviate some of the overhead.
> > > +
> > > +         If in doubt, select 'none'.
> >
> > This should not be in arch/x86. Other architectures, such as arm64,
> > should also be able to use this without extra work.
>
> In the initial RFC patch I only added to x86. I could add it to any
> arch that has seccomp filters. Though, I'm wondering, why is SECCOMP
> in the arch-specific Kconfigs?

Ugh, yeah, the existing code is already bad... as far as I can tell,
SECCOMP shouldn't be there, and instead the arch-specific Kconfig
should define something like HAVE_ARCH_SECCOMP and then arch/Kconfig
would define SECCOMP and let it depend on HAVE_ARCH_SECCOMP. It's
really gross how the SECCOMP config description has been copypasted
into a dozen different Kconfig files; and looking around a bit, you
can actually see that e.g. s390 has an utterly outdated help text
which still claims that seccomp is controlled via the ancient
"/proc/<pid>/seccomp". I guess this very nicely illustrates why
putting such options into arch-specific Kconfig is a bad idea. :P
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
