Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3162BC2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:06:40 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 56BF8221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:06:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="fdN4Y3Kn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56BF8221EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 9F7E02DE2A;
	Thu, 24 Sep 2020 14:06:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id l2I33gQSdIDi; Thu, 24 Sep 2020 14:06:35 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 1A18C204AA;
	Thu, 24 Sep 2020 14:06:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E8170C0889;
	Thu, 24 Sep 2020 14:06:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CC41AC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:06:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3FE6F81F33
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:06:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 6-GqRKcG4fVj
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:06:33 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f67.google.com (mail-ej1-f67.google.com
 [209.85.218.67])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A937D86F58
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:06:27 +0000 (UTC)
Received: by mail-ej1-f67.google.com with SMTP id nw23so4682308ejb.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:06:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=oTKhozomiksQmEwUGZ3qRDCL7Z7QGtyosMbot5Bgjyk=;
 b=fdN4Y3Kn7nTC3mmnwcEAVtvHKFTOVqvEfnnuyMGVG7zBy90zeoG1JAX+VL+L714dQX
 4KrJyZex66L5th/3yiM6GTAyUmHH7cIpCZf6bWWempwGqcsy0petGFjbk8SPWfYl/g6v
 nHTcr0Ht7tS8M141EgEoM2g1XzgVqh+VOUkcZ6nv2IZ7mZuVthmc+1Bo3AFfP4FIx1A9
 ZvzPoDNLA4JlU9mj23VSuTxWEyhzaDiRq3b1OFJbe9n5ugBclzEMAMgvwisDPjxbnCXy
 pMGse6Kh2JIdlYgRWxy8zxQ2lpyxHMdzFg4ook3wHyXs+AlV3e8mCP1SCiPb7ldjVNO4
 BlRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=oTKhozomiksQmEwUGZ3qRDCL7Z7QGtyosMbot5Bgjyk=;
 b=BS52t+3rfogCGzGvVUlVnbzJUAILZVGarncxzIAIgYx1c52cGTcEy2ZtGgJUopbB+w
 Q1xLpW+xSuh/kSLiHpQOlKs9Mwv3vkurT0FJpEd3NeXgz5slBceEg8Mfyl849yZfvim1
 rWxTU4MAM0sJne5IxAodCMta0ZQK/yDNVMkFdo6zE69XKwm6cpSYcHcN7/QfMEbPeQvR
 O6MLYwpakT1I1H4AEWuid7mLx4HYM39mQIw+T/HfvrmpfKxerK4VTj6AQwv7YkMczf8p
 fK4GaDjNKhSwtPibaxo6gQlUsqwfMCNz/Ox6+E+3AIoEJJJZbAobHadNmBecgn0aKStR
 cWVA==
X-Gm-Message-State: AOAM531bgVOQdSeDv7VmjZJh1ozDrznBR2H0hDCVzRRg33JFV5ULP4Vw
 V/XmUK+DxUcs7UuI8qSZpb2UcN1RBOd1myJk5n8vmQ==
X-Google-Smtp-Source: ABdhPJwwyHaADMpJhLyRUcgsXvG5IwoHzjYXcthXS5FPqRPTRojTWAbOTxrURqPaQIBCU/TwFEcT0uEP/6pO6oOXUGw=
X-Received: by 2002:a17:906:1f94:: with SMTP id t20mr4800ejr.493.1600956385788; 
 Thu, 24 Sep 2020 07:06:25 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
In-Reply-To: <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
Date: Thu, 24 Sep 2020 16:05:59 +0200
Message-ID: <CAG48ez3Z5Cxxc47x8gZiy9xgEVPL5gH-g0HNPNqndkAnJCbwKw@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 bpf <bpf@vger.kernel.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 3:40 PM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On 24/09/2020 01.29, Kees Cook wrote:
> > rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> > alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
> > v1:
> > - rebase to for-next/seccomp
> > - finish X86_X32 support for both pinning and bitmaps
> > - replace TLB magic with Jann's emulator
> > - add JSET insn
> >
> > TODO:
> > - add ALU|AND insn
> > - significantly more testing
> >
> > Hi,
> >
> > This is a refresh of my earlier constant action bitmap series. It looks
> > like the RFC was missed on the container list, so I've CCed it now. :)
> > I'd like to work from this series, as it handles the multi-architecture
> > stuff.
>
> So, I agree with Jann's point that the only thing that matters is that
> always-allowed syscalls are indeed allowed fast.
>
> But one thing I'm wondering about and I haven't seen addressed anywhere:
> Why build the bitmap on the kernel side (with all the complexity of
> having to emulate the filter for all syscalls)? Why can't userspace just
> hand the kernel "here's a new filter: the syscalls in this bitmap are
> always allowed noquestionsasked, for the rest, run this bpf". Sure, that
> might require a new syscall or extending seccomp(2) somewhat, but isn't
> that a _lot_ simpler? It would probably also mean that the bpf we do get
> handed is a lot smaller. Userspace might need to pass a couple of
> bitmaps, one for each relevant arch, but you get the overall idea.

It's not really a lot of logic though; and there are a bunch of
different things in userspace that talk to the seccomp() syscall that
would have to be updated if we made this part of the UAPI. libseccomp,
Chrome, Android, OpenSSH, bubblewrap, ... - overall, if we can make
the existing interface faster, it'll be less effort, and there will be
less code duplication (because otherwise every user of seccomp will
have to implement the same thing in userspace).

Doing this internally with the old UAPI also means that we're not
creating any additional commitments in terms of UAPI - if we come up
with something better in the future, we can just rip this stuff out.
If we created a new UAPI, we'd have to stay, in some form, compatible
with it forever.

> I'm also a bit worried about the performance of doing that emulation;
> that's constant extra overhead for, say, launching a docker container.
>
> Regardless of how the kernel's bitmap gets created, something like
>
> +       if (nr < NR_syscalls) {
> +               if (test_bit(nr, bitmaps->allow)) {
> +                       *filter_ret = SECCOMP_RET_ALLOW;
> +                       return true;
> +               }
>
> probably wants some nospec protection somewhere to avoid the irony of
> seccomp() being used actively by bad guys.

Good point...
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
