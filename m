Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F725C4363A
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 08:19:10 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 876C62220B
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 08:19:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 876C62220B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C6B5B203F9;
	Wed, 28 Oct 2020 08:19:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rn8H5bqrHUzP; Wed, 28 Oct 2020 08:19:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 184342010E;
	Wed, 28 Oct 2020 08:19:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F2167C088B;
	Wed, 28 Oct 2020 08:19:06 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 36D4FC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 08:19:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 2375286813
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 08:19:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id da98IAMDaKVq
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 08:19:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com
 [209.85.167.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id F29CB86783
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 08:19:03 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id f7so4148529oib.4
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 01:19:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=XH5fEY967sQGo5TmBvXohkmKAaL8RC4qbRi4BtBMuM0=;
 b=GWyel+r7xYz6slGTShK7v3dCcJ6H6EFp14wzBIlLdayNsDzmiFH6xKzpcaiBSupcxB
 j7c1OJ7R/a3GwWF7++Z0bIp2sxoCeMsARGmtsIXEG31TTpTH2A9U8HI0hAy83kS8cEQ3
 rHUe2rouCeHsnC7oZFlR3OZvNF64INbqwdT9gf5kyHNUxX4DpKrw9ijj1d0cBwmNKuz/
 qQgM9Sy7YoWEKxMBdkpfCuacPLDURAhBBctb44fmM9FzyI63LR6vizQqs8TbWvJGpt0e
 zAsHxl/9+40qnRgOoJsWO4NUITICkZjxVqND7ywHwO1Q2SkJ7/FZfZryo7JCnO6Y25lB
 /oBw==
X-Gm-Message-State: AOAM533BGLafEApQIE69N0I0/DE67vtiHpZIBV8uAZew6XX675c7NrKE
 5DGP9YT2DJGQZPOoSBkqNzI+jgakHJyeKK6d4LY=
X-Google-Smtp-Source: ABdhPJw6WDLyOvB0+BhHMeuPy0t7zaAp6XH9HiAYir4ZWG1UgoaiE5jfBGmT2ghntDdAX5N6W7oM8IuIZYfj5F/E2yQ=
X-Received: by 2002:aca:f40c:: with SMTP id s12mr4164246oih.153.1603873143175; 
 Wed, 28 Oct 2020 01:19:03 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
 <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
 <202010271653.B6D7D6B@keescook>
In-Reply-To: <202010271653.B6D7D6B@keescook>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 28 Oct 2020 09:18:51 +0100
Message-ID: <CAMuHMdX-y+ButCt=CH+Ao=RtO_eGz0DaTJupwuHNa7=Xi_AGoQ@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
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

Hi Kees,

On Wed, Oct 28, 2020 at 1:06 AM Kees Cook <keescook@chromium.org> wrote:
> On Tue, Oct 27, 2020 at 10:52:39AM +0100, Geert Uytterhoeven wrote:
> > On Thu, Sep 24, 2020 at 2:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > > From: YiFei Zhu <yifeifz2@illinois.edu>
> > >
> > > In order to make adding configurable features into seccomp
> > > easier, it's better to have the options at one single location,
> > > considering easpecially that the bulk of seccomp code is
> > > arch-independent. An quick look also show that many SECCOMP
> > > descriptions are outdated; they talk about /proc rather than
> > > prctl.
> > >
> > > As a result of moving the config option and keeping it default
> > > on, architectures arm, arm64, csky, riscv, sh, and xtensa
> > > did not have SECCOMP on by default prior to this and SECCOMP will
> > > be default in this change.
> > >
> > > Architectures microblaze, mips, powerpc, s390, sh, and sparc
> > > have an outdated depend on PROC_FS and this dependency is removed
> > > in this change.
> > >
> > > Suggested-by: Jann Horn <jannh@google.com>
> > > Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
> > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > Thanks for your patch. which is now commit 282a181b1a0d66de ("seccomp:
> > Move config option SECCOMP to arch/Kconfig") in v5.10-rc1.
> >
> > > --- a/arch/Kconfig
> > > +++ b/arch/Kconfig
> > > @@ -458,6 +462,23 @@ config HAVE_ARCH_SECCOMP_FILTER
> > >             results in the system call being skipped immediately.
> > >           - seccomp syscall wired up
> > >
> > > +config SECCOMP
> > > +       def_bool y
> > > +       depends on HAVE_ARCH_SECCOMP
> > > +       prompt "Enable seccomp to safely compute untrusted bytecode"
> > > +       help
> > > +         This kernel feature is useful for number crunching applications
> > > +         that may need to compute untrusted bytecode during their
> > > +         execution. By using pipes or other transports made available to
> > > +         the process as file descriptors supporting the read/write
> > > +         syscalls, it's possible to isolate those applications in
> > > +         their own address space using seccomp. Once seccomp is
> > > +         enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
> > > +         and the task is only allowed to execute a few safe syscalls
> > > +         defined by each seccomp mode.
> > > +
> > > +         If unsure, say Y. Only embedded should say N here.
> > > +
> >
> > Please tell me why SECCOMP is special, and deserves to default to be
> > enabled.  Is it really that critical, given only 13.5 (half of sparc
> > ;-) out of 24
> > architectures implement support for it?
>
> That's an excellent point; I missed this in my review as I saw several
> Kconfig already marked "def_bool y" but failed to note it wasn't _all_
> of them. Okay, checking before this patch, these had them effectively
> enabled:
>
> via Kconfig:
>
> parisc
> s390
> um
> x86

Mostly "server" and "desktop" platforms.

> via defconfig, roughly speaking:
>
> arm
> arm64
> sh

Note that these defconfigs are example configs, not meant for production.
E.g. arm/multi_v7_defconfig and arm64/defconfig enable about everything
for compile coverage.

> How about making the default depend on HAVE_ARCH_SECCOMP_FILTER?
>
> These have SECCOMP_FILTER support:
>
> arch/arm/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER if AEABI && !OABI_COMPAT
> arch/arm64/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
> arch/csky/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> arch/mips/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> arch/parisc/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER
> arch/powerpc/Kconfig:   select HAVE_ARCH_SECCOMP_FILTER
> arch/riscv/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
> arch/s390/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> arch/sh/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
> arch/um/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
> arch/x86/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER
> arch/xtensa/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER
>
> So the "new" promotions would be:
>
> csky
> mips
> powerpc
> riscv
> xtensa
>
> Which would leave only these two:
>
> arch/microblaze/Kconfig:        select HAVE_ARCH_SECCOMP
> arch/sparc/Kconfig:     select HAVE_ARCH_SECCOMP if SPARC64
>
> At this point, given the ubiquity of seccomp usage (e.g. systemd), I
> guess it's not unreasonable to make it def_bool y?

Having support does not necessarily imply you want it enabled.
If systemd needs it (does it? I have Debian nfsroots with systemd,
without SECCOMP), you can enable it in the defconfig.
"Default y" is for things you cannot do without, unless you know
better.

Bloat-o-meter says enabling SECCOMP consumes only ca. 8 KiB
(on arm32), so perhaps "default y if !EXPERT"?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
