Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0407DC388F9
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 00:06:57 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6D05222281
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 00:06:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="jq2lkcWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D05222281
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 179522E15D;
	Wed, 28 Oct 2020 00:06:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7FB-jFbyorWv; Wed, 28 Oct 2020 00:06:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D61172E154;
	Wed, 28 Oct 2020 00:06:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CB663C088B;
	Wed, 28 Oct 2020 00:06:54 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7E9EDC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 00:06:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 621712E15C
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 00:06:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Eg0qz43VfvX6
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 00:06:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by silver.osuosl.org (Postfix) with ESMTPS id 03B9B2E154
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 00:06:52 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id b3so1882007pfo.2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 17:06:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=SkTc2vk73nmebVshjgjHKREV7i/15yy96aB46LsoBJM=;
 b=jq2lkcWdmOTv8Lyx6yvybZKderM4WXlS2x5SBBIvdhQC/Hadg0P/Asbj5KmjCOTFJW
 b/5r/M8+iPrJTWUBXb1TpZz1FSZE9Wh3YyzP9ty15mnJxMgQl+mm7WMRmhYiQZc1bFhD
 kE4RwvzkUp3hEXlMoBodJdAcAXdxgbK7pYOyo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=SkTc2vk73nmebVshjgjHKREV7i/15yy96aB46LsoBJM=;
 b=h0A4NgUhayItZ+tdEk62+3aWrTKnjfA5UmvAUdXhya6b0RIKEWtyhGGo93kUMWzRfc
 zFzxHxu2siZDhOsccX1rKQEISUQO2H/ljTP7UC+Yco70CVJmvXAt5TZvbdp9CYsjjxl5
 7ZUBxwmPkBbqK9Y70mOb8ttCWFPxkMUnGOHuDvQlCIKyq+msD73i8BoUnbrYJJqml0aH
 /6600NWAYvDILJiL58bB5id4+ynNuTtpqPxMhK+Hq9yJ+F20YZEzwIBEpo2ag65xTXIV
 Ho7PbPv7SKSRU7RsoTTMC13qJW9lhFCvzM794gNefS8+DwLSRBYhewz1tAu/TLQiOqMy
 KVbQ==
X-Gm-Message-State: AOAM530zHzkx4SyTNdSmV0dbyrQ+Kho3nK9DTVP4Nn4xGwrgnzym4QZS
 7oo0UF0bCeloFgSZvB533+mtAA==
X-Google-Smtp-Source: ABdhPJwkntKG+LnH43OBYo1mCeJ2Eb7oSC1DQiZMoYaqhPnztVbnQQPjzDgbtBZac+mXdy1h1HBdYQ==
X-Received: by 2002:aa7:9ad7:0:b029:160:948:44a6 with SMTP id
 x23-20020aa79ad70000b0290160094844a6mr4533190pfp.25.1603843611476; 
 Tue, 27 Oct 2020 17:06:51 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id 21sm3688285pfw.36.2020.10.27.17.06.49
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 27 Oct 2020 17:06:50 -0700 (PDT)
Date: Tue, 27 Oct 2020 17:06:49 -0700
From: Kees Cook <keescook@chromium.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
Message-ID: <202010271653.B6D7D6B@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
 <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
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

On Tue, Oct 27, 2020 at 10:52:39AM +0100, Geert Uytterhoeven wrote:
> Hi Yifei,
> 
> On Thu, Sep 24, 2020 at 2:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > From: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > In order to make adding configurable features into seccomp
> > easier, it's better to have the options at one single location,
> > considering easpecially that the bulk of seccomp code is
> > arch-independent. An quick look also show that many SECCOMP
> > descriptions are outdated; they talk about /proc rather than
> > prctl.
> >
> > As a result of moving the config option and keeping it default
> > on, architectures arm, arm64, csky, riscv, sh, and xtensa
> > did not have SECCOMP on by default prior to this and SECCOMP will
> > be default in this change.
> >
> > Architectures microblaze, mips, powerpc, s390, sh, and sparc
> > have an outdated depend on PROC_FS and this dependency is removed
> > in this change.
> >
> > Suggested-by: Jann Horn <jannh@google.com>
> > Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
> > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> 
> Thanks for your patch. which is now commit 282a181b1a0d66de ("seccomp:
> Move config option SECCOMP to arch/Kconfig") in v5.10-rc1.
> 
> > --- a/arch/Kconfig
> > +++ b/arch/Kconfig
> > @@ -458,6 +462,23 @@ config HAVE_ARCH_SECCOMP_FILTER
> >             results in the system call being skipped immediately.
> >           - seccomp syscall wired up
> >
> > +config SECCOMP
> > +       def_bool y
> > +       depends on HAVE_ARCH_SECCOMP
> > +       prompt "Enable seccomp to safely compute untrusted bytecode"
> > +       help
> > +         This kernel feature is useful for number crunching applications
> > +         that may need to compute untrusted bytecode during their
> > +         execution. By using pipes or other transports made available to
> > +         the process as file descriptors supporting the read/write
> > +         syscalls, it's possible to isolate those applications in
> > +         their own address space using seccomp. Once seccomp is
> > +         enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
> > +         and the task is only allowed to execute a few safe syscalls
> > +         defined by each seccomp mode.
> > +
> > +         If unsure, say Y. Only embedded should say N here.
> > +
> 
> Please tell me why SECCOMP is special, and deserves to default to be
> enabled.  Is it really that critical, given only 13.5 (half of sparc
> ;-) out of 24
> architectures implement support for it?

That's an excellent point; I missed this in my review as I saw several
Kconfig already marked "def_bool y" but failed to note it wasn't _all_
of them. Okay, checking before this patch, these had them effectively
enabled:

via Kconfig:

parisc
s390
um
x86

via defconfig, roughly speaking:

arm
arm64
sh

How about making the default depend on HAVE_ARCH_SECCOMP_FILTER?

These have SECCOMP_FILTER support:

arch/arm/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER if AEABI && !OABI_COMPAT
arch/arm64/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
arch/csky/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
arch/mips/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
arch/parisc/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER
arch/powerpc/Kconfig:   select HAVE_ARCH_SECCOMP_FILTER
arch/riscv/Kconfig:     select HAVE_ARCH_SECCOMP_FILTER
arch/s390/Kconfig:      select HAVE_ARCH_SECCOMP_FILTER
arch/sh/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
arch/um/Kconfig:        select HAVE_ARCH_SECCOMP_FILTER
arch/x86/Kconfig:       select HAVE_ARCH_SECCOMP_FILTER
arch/xtensa/Kconfig:    select HAVE_ARCH_SECCOMP_FILTER

So the "new" promotions would be:

csky
mips
powerpc
riscv
xtensa

Which would leave only these two:

arch/microblaze/Kconfig:        select HAVE_ARCH_SECCOMP
arch/sparc/Kconfig:     select HAVE_ARCH_SECCOMP if SPARC64

At this point, given the ubiquity of seccomp usage (e.g. systemd), I
guess it's not unreasonable to make it def_bool y?

I'm open to suggestions!

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
