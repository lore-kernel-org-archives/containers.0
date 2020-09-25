Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37DA0C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:27:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AC10320809
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:27:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PKiLyTOI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC10320809
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3B4C587545;
	Fri, 25 Sep 2020 01:27:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BdndUmpecEYr; Fri, 25 Sep 2020 01:27:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 938EA87541;
	Fri, 25 Sep 2020 01:27:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 83BBBC0890;
	Fri, 25 Sep 2020 01:27:53 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7B8F2C0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:27:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 6399986B04
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:27:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cVmdcrrhMNo7
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:27:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com
 [209.85.210.194])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A55A886AE5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:27:51 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id d9so1577698pfd.3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:27:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=WX2GerDQN/1DZwYhOgS9HfUlktjE9DG6T36wNYd6ERA=;
 b=PKiLyTOIgHLW+moRjohVGN3nBXtAMxY2kYeSeyQ+lEwxjVykj1TU2m/L4+JKoM4xJP
 ZD5NQacU8BFBKmyzQZHKsWN/98bPRw49TlHi9pKqHibcCLtAf1QS0VXLijE1Cs6czB3N
 3FV6Ph1hXkRMiZsuVZd/MWznqd7sOgwK+P+/mwrQIl6x2+Wewik48GDaSWMpCnMaLw/l
 2HUPAkCy6bvpxVpZvsvkJtXo8s30ovp8FcyPPFv7BMfv142P8Wh5DhEXpOdYiaEwF8JR
 k5lYb97ny5XkQfNh77xbpa2eGyzBKLqYNA2qMwCsBFfi1R8pmaM0ASTB0cNqrvjoK7Fk
 rr2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=WX2GerDQN/1DZwYhOgS9HfUlktjE9DG6T36wNYd6ERA=;
 b=nCpYXu0JABKu8pN0PeGqmozLP+5CeDnc215Qygw47ds0c2SuFixIzEZQuUG/ZUPERR
 OGwwjKLG3PAFk8HGVNmHpclbF4cqcw23nEqwjWbFrooZGun+mLUqdFP82SScire0BLxp
 WAyR5oV0TZc+iE0GAH2N4BA2uxOv0XkvuQil8raroTztrkQUnzCzf8kABIROeDdFE4lG
 dFPW6r4eErQSiHGJ5N0c7uF/tWwGpeXTpahmB1F/KwlCDqWYeVRX6Uh4AUr8W/gW8uRf
 YaH4XT6rvnCA+StlXbJPRyS4CSLzctlC/HiHnehkSn+ZEOWMGeEDZpywRyX5aCP3ZIZp
 wQMw==
X-Gm-Message-State: AOAM531WAbuYHlIYZbhBnKEdBeGUzfdMnz5Lhhev2jgBtwU62lG/w5Bo
 bcs67EztLroq/Vn2ZVGSUXBEAT4D4h5O8q3XWUs=
X-Google-Smtp-Source: ABdhPJySE+Qder4PaqnMJALNyB2UUS+F0xdqjGoIiv8n/RD6wdcY8DBlVZoIdbJGt48BGDMCA2TPysEzgBxUQCqP50s=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr1854155pfe.11.1600997271069; Thu, 24
 Sep 2020 18:27:51 -0700 (PDT)
MIME-Version: 1.0
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
In-Reply-To: <202009241658.A062D6AE@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 20:27:40 -0500
Message-ID: <CABqSeAQ=joheH+0LUZ201U-XwFFsHN3Ouo5FGoscUwn+itkL2w@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

[resending this too]

On Thu, Sep 24, 2020 at 6:01 PM Kees Cook <keescook@chromium.org> wrote:
> Disregarding the "how" of this, yeah, we'll certainly need something to
> tell seccomp about the arrangement of syscall tables and how to find
> them.
>
> However, I'd still prefer to do this on a per-arch basis, and include
> more detail, as I've got in my v1.
>
> Something missing from both styles, though, is a consolidation of
> values, where the AUDIT_ARCH* isn't reused in both the seccomp info and
> the syscall_get_arch() return. The problems here were two-fold:
>
> 1) putting this in syscall.h meant you do not have full NR_syscall*
>    visibility on some architectures (e.g. arm64 plays weird games with
>    header include order).

I don't get this one -- I'm not playing with NR_syscall here.

> 2) seccomp needs to handle "multiplexed" tables like x86_x32 (distros
>    haven't removed CONFIG_X86_X32 widely yet, so it is a reality that
>    it must be dealt with), which means seccomp's idea of the arch
>    "number" can't be the same as the AUDIT_ARCH.

Why so? Does anyone actually use x32 in a container? The memory cost
and analysis cost is on everyone. The worst case scenario if we don't
support it is that the syscall is not accelerated.

> So, likely a combo of approaches is needed: an array (or more likely,
> enum), declared in the per-arch seccomp.h file. And I don't see a way
> to solve #1 cleanly.
>
> Regardless, it needs to be split per architecture so that regressions
> can be bisected/reverted/isolated cleanly. And if we can't actually test
> it at runtime (or find someone who can) it's not a good idea to make the
> change. :)

You have a good point regarding tests. Don't see how it affects
regressions though. Only one file here is ever included per-build.

> > [...]
> > diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
> > index 7cbf733d11af..e13bb2a65b6f 100644
> > --- a/arch/x86/include/asm/syscall.h
> > +++ b/arch/x86/include/asm/syscall.h
> > @@ -97,6 +97,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
> >       memcpy(&regs->bx + i, args, n * sizeof(args[0]));
> >  }
> >
> > +static __maybe_unused const int syscall_arches[] = {
> > +     AUDIT_ARCH_I386
> > +};
> > +
> >  static inline int syscall_get_arch(struct task_struct *task)
> >  {
> >       return AUDIT_ARCH_I386;
> > @@ -152,6 +156,13 @@ static inline void syscall_set_arguments(struct task_struct *task,
> >       }
> >  }
> >
> > +static __maybe_unused const int syscall_arches[] = {
> > +     AUDIT_ARCH_X86_64,
> > +#ifdef CONFIG_IA32_EMULATION
> > +     AUDIT_ARCH_I386,
> > +#endif
> > +};
>
> I'm leaving this section quoted because I'll refer to it in a later
> patch review...
>
> --
> Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
