Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23BC5C388F7
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 09:35:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 43DA324687
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 09:35:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="H5YOV56m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43DA324687
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B310885D44;
	Wed, 28 Oct 2020 09:35:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7HL-R7nWdbGz; Wed, 28 Oct 2020 09:35:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DB8EF85359;
	Wed, 28 Oct 2020 09:35:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BB259C0859;
	Wed, 28 Oct 2020 09:35:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D9142C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:35:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id BCFC320443
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:35:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ncL8RtwjHA6M
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:35:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f193.google.com (mail-lj1-f193.google.com
 [209.85.208.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 83C2520429
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:35:28 +0000 (UTC)
Received: by mail-lj1-f193.google.com with SMTP id m20so5308237ljj.5
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 02:35:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=3x1J6W9vn4AlBy0J+3iWpQphgvbJmpzzrQwvBAhJ5JY=;
 b=H5YOV56mWdrmRcNSYhYkyVGRVelyp884El1qTLvbyotZOVYWlE0S2TqMhOhjL6n2ch
 hYepJsMW6DoUzb8YXpj1/53uYmuxIxjFeb9UIPO7H847cY/zUd+B95xRYC8abTwVg5jm
 x2OvzSeLhg0cwBybfAOGOQkV9XsVK/EyXyPMIBLzpa7CriuNb4y/5MSTqXycJNEwyf7U
 SbmKYNolTVUxKScdyvBcdVUUEuvv0vjyYC0CvDhhixiiQpYS72LFuyPeH/5dmcXEJ31S
 EpjATCAZzGC6XhqWkunhwtYbRrPhe9P3g6+a2MtKcXcm0oRdVJAKptHqdy1+wmSA7WzC
 cmGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=3x1J6W9vn4AlBy0J+3iWpQphgvbJmpzzrQwvBAhJ5JY=;
 b=IUsxy802dGZ0iTE+HgEX8V2PUK2zTQldlbPafaS1yHKV7bmpD3YzU+23hf9MIVC5HF
 iNteMAH2tm/W/k0NHgDbs3S6Vp6odEdlGPv5kKDiUqZSmb0XyAxxG8nTJljMhjtNs54L
 k0xOtVNgAmOE8AhTdNc+T4Em7GAcOgSkS4CFc+Me4vBcSmry8+TJS4WkCYIXp30dDw6k
 BKLuw3JvJ2JpxkJ9DvNme5n/uvP95Cn5q3GFL4LCzjJWWMd3D7ftEpnOmvZTif4Vegu7
 /S4mWcpi3A+jxwx5zualeuI0N5E2ugEKzLOE7Yi1NzYTOakUmjNXeg7y+PTuXC4BUGkv
 Rwxw==
X-Gm-Message-State: AOAM530XFTdzrN6melO/WwSpoPjvK3ueJ6NE/O7rfr0DtCmPHY5mjB/3
 i+T4XRk6L58fJYWWKSu0KPUcu5zqyAgXGqnLh0Of0Q==
X-Google-Smtp-Source: ABdhPJzXyWf93KJh7MTLqIEgWm5WWtY3xIdQEISBeUAts5iSL2Ft2btJ2NGIV9KN2npe84xs50rLGPRWAR7QOM6SYJk=
X-Received: by 2002:a2e:9a17:: with SMTP id o23mr3146050lji.242.1603877726248; 
 Wed, 28 Oct 2020 02:35:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
 <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
 <202010271653.B6D7D6B@keescook>
 <CAMuHMdX-y+ButCt=CH+Ao=RtO_eGz0DaTJupwuHNa7=Xi_AGoQ@mail.gmail.com>
In-Reply-To: <CAMuHMdX-y+ButCt=CH+Ao=RtO_eGz0DaTJupwuHNa7=Xi_AGoQ@mail.gmail.com>
Date: Wed, 28 Oct 2020 10:34:59 +0100
Message-ID: <CAG48ez0+yqVg9mUu_ZnouxsdEHgKeMELyeHn2hbYHUNA=29O5A@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Wed, Oct 28, 2020 at 9:19 AM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Wed, Oct 28, 2020 at 1:06 AM Kees Cook <keescook@chromium.org> wrote:
> > On Tue, Oct 27, 2020 at 10:52:39AM +0100, Geert Uytterhoeven wrote:
> > > On Thu, Sep 24, 2020 at 2:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > > > From: YiFei Zhu <yifeifz2@illinois.edu>
> > > >
> > > > In order to make adding configurable features into seccomp
> > > > easier, it's better to have the options at one single location,
> > > > considering easpecially that the bulk of seccomp code is
> > > > arch-independent. An quick look also show that many SECCOMP
> > > > descriptions are outdated; they talk about /proc rather than
> > > > prctl.
> > > >
> > > > As a result of moving the config option and keeping it default
> > > > on, architectures arm, arm64, csky, riscv, sh, and xtensa
> > > > did not have SECCOMP on by default prior to this and SECCOMP will
> > > > be default in this change.
> > > >
> > > > Architectures microblaze, mips, powerpc, s390, sh, and sparc
> > > > have an outdated depend on PROC_FS and this dependency is removed
> > > > in this change.
> > > >
> > > > Suggested-by: Jann Horn <jannh@google.com>
> > > > Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
> > > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> > >
> > > Thanks for your patch. which is now commit 282a181b1a0d66de ("seccomp:
> > > Move config option SECCOMP to arch/Kconfig") in v5.10-rc1.
> > >
> > > > --- a/arch/Kconfig
> > > > +++ b/arch/Kconfig
> > > > @@ -458,6 +462,23 @@ config HAVE_ARCH_SECCOMP_FILTER
> > > >             results in the system call being skipped immediately.
> > > >           - seccomp syscall wired up
> > > >
> > > > +config SECCOMP
> > > > +       def_bool y
> > > > +       depends on HAVE_ARCH_SECCOMP
> > > > +       prompt "Enable seccomp to safely compute untrusted bytecode"
> > > > +       help
> > > > +         This kernel feature is useful for number crunching applications
> > > > +         that may need to compute untrusted bytecode during their
> > > > +         execution. By using pipes or other transports made available to
> > > > +         the process as file descriptors supporting the read/write
> > > > +         syscalls, it's possible to isolate those applications in
> > > > +         their own address space using seccomp. Once seccomp is
> > > > +         enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
> > > > +         and the task is only allowed to execute a few safe syscalls
> > > > +         defined by each seccomp mode.
> > > > +
> > > > +         If unsure, say Y. Only embedded should say N here.
> > > > +
> > >
> > > Please tell me why SECCOMP is special, and deserves to default to be
> > > enabled.  Is it really that critical, given only 13.5 (half of sparc
> > > ;-) out of 24
> > > architectures implement support for it?
> >
> > That's an excellent point; I missed this in my review as I saw several
> > Kconfig already marked "def_bool y" but failed to note it wasn't _all_
> > of them. Okay, checking before this patch, these had them effectively
> > enabled:
> >
> > via Kconfig:
> >
> > parisc
> > s390
> > um
> > x86
>
> Mostly "server" and "desktop" platforms.
>
> > via defconfig, roughly speaking:
> >
> > arm
> > arm64
> > sh
>
> Note that these defconfigs are example configs, not meant for production.
> E.g. arm/multi_v7_defconfig and arm64/defconfig enable about everything
> for compile coverage.
>
> > How about making the default depend on HAVE_ARCH_SECCOMP_FILTER?
> >
> > These have SECCOMP_FILTER support:
> >
> > arch/arm/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER if AEABI && !OABI_COMPAT
> > arch/arm64/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
> > arch/csky/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> > arch/mips/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> > arch/parisc/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER
> > arch/powerpc/Kconfig:   select HAVE_ARCH_SECCOMP_FILTER
> > arch/riscv/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
> > arch/s390/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
> > arch/sh/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
> > arch/um/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
> > arch/x86/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER
> > arch/xtensa/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER
> >
> > So the "new" promotions would be:
> >
> > csky
> > mips
> > powerpc
> > riscv
> > xtensa
> >
> > Which would leave only these two:
> >
> > arch/microblaze/Kconfig:        select HAVE_ARCH_SECCOMP
> > arch/sparc/Kconfig:     select HAVE_ARCH_SECCOMP if SPARC64
> >
> > At this point, given the ubiquity of seccomp usage (e.g. systemd), I
> > guess it's not unreasonable to make it def_bool y?
>
> Having support does not necessarily imply you want it enabled.
> If systemd needs it (does it? I have Debian nfsroots with systemd,
> without SECCOMP), you can enable it in the defconfig.
> "Default y" is for things you cannot do without, unless you know
> better.
>
> Bloat-o-meter says enabling SECCOMP consumes only ca. 8 KiB
> (on arm32), so perhaps "default y if !EXPERT"?

Gating a *default* on EXPERT seems weird to me. Isn't EXPERT normally
used to gate whether things are configurable at all (using "if
EXPERT")?

I think that at least on systems with MMU, SECCOMP should default to
y, independent of what EXPERT is set to. When SECCOMP is disabled,
various pieces of software will have to (potentially invisibly to the
user) degrade their belts-and-suspenders security measures. For
example, as far as I understand, systemd has support for using seccomp
to restrict what services can do (and uses that for some of its
built-in services), but skips those steps with a log message if you
don't have SECCOMP. Perhaps more importantly, the same thing happens
in OpenSSH's ssh_sandbox_child() function - it generates a debug
message, then continues on.

If someone does manage to find an OpenSSH pre-auth remote code
execution bug in a few years, I think we very much wouldn't want to be
in a situation where that can be used to compromise a bunch of routers
just because SECCOMP wasn't in the default config, or because it was
invisibly disabled when the router vendor enabled EXPERT so that they
can get rid of io_uring support.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
