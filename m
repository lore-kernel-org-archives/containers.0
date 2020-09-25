Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCC82C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:25:16 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F21C4238D6
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:25:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="f9l5Zd3/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F21C4238D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 7A56B20445;
	Fri, 25 Sep 2020 00:25:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bFm8+fH6bloC; Fri, 25 Sep 2020 00:25:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A3BEA203A9;
	Fri, 25 Sep 2020 00:25:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7A63AC0859;
	Fri, 25 Sep 2020 00:25:14 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 23269C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:25:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 0D6FC868E5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:25:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5bNpCAGqMaI3
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:25:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com
 [209.85.208.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 29BA08689B
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:25:12 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id l17so684120edq.12
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:25:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=Mb/Gyht1d42k5WLRRBLSKrU8LIj1ziyutaDcZAUiiDE=;
 b=f9l5Zd3/T/siD3esxvK9V7YnPdrOPwx1tq742hlnDqkxlWrK/d7wadfgenOzWaholI
 EGlI6+dTP7IK4eZMyXFvN1jy4A1imuSMp+jrckKEPcgsAaYu5gsSQMyHqqwQWJF0sDU1
 5xzCMwIddufxjAl9RoRLXKtXbm0VEXIvz+CyefndRGPpKrVrNRrKyvmhCstvSG054h75
 /w7FRLohxgg+mkAxbgF06fH0/b5lpv0lS7KnVnWwZp6JamH8ekmXkyRaA0ONHW7gNWSj
 /xKm2wzh4qshXB/KxxZX2DfEOV9720E9nsisCdV28VmRKFCNLHI2UDRDSoq28tGoscpp
 75SA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=Mb/Gyht1d42k5WLRRBLSKrU8LIj1ziyutaDcZAUiiDE=;
 b=BO/6gvm2nbkdAsCLgrbXFL7xQsX4kyOaI3Ed65eWdz8Gb+bxLXqMTbLKufqc+6cFUT
 XpHgYf/xKW+ct1cboUalSf8FF9YhwPJ0FWs/dK7RhHH3alvkbS7NWW8eT7FeL7gkh/l8
 fOKnL5aMkq+P/jKLDscJPCCVEpkB24X5W3kOwBIFwNF4WUHKsI1CECYprx/mRefnelM3
 xrY73xjqAlJR86YlJVA29PR/wQm2Br7QULBMpo0zGG76yNr7pg/Ggk8GE9wHg6Y2pNZ2
 ISTShOGDmBdzGATUOFqwMBly0rLotgoiNIYohOACIl689fWe//12UAFOWKIcO1EH4WWq
 5FpQ==
X-Gm-Message-State: AOAM533BVREYJeu7cGk/e5p4QG0DTyG6G3Ee7xIANwpbd6eyuS2cN+bO
 7VjVwNrJIAhf63dWYjO6plRCHT/dWqLwR4bTq8ib5A==
X-Google-Smtp-Source: ABdhPJyXMnD+DwkHGMzEgLFLrUX3vRxmEK0cIvo8M77oLrJDknVzbQ95k1e4VVTE9KNNBZHJjBqthcj+pzQZ1DxtQHI=
X-Received: by 2002:a50:ccd2:: with SMTP id b18mr1328552edj.51.1600993510229; 
 Thu, 24 Sep 2020 17:25:10 -0700 (PDT)
MIME-Version: 1.0
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
 <CAG48ez2R1fF2kAUc7vOOFgaE482jA94Lx+0oWiy6M5JeM2HtvA@mail.gmail.com>
 <20200925001803.GV3421308@ZenIV.linux.org.uk>
In-Reply-To: <20200925001803.GV3421308@ZenIV.linux.org.uk>
Date: Fri, 25 Sep 2020 02:24:43 +0200
Message-ID: <CAG48ez1VxTewE5AjStBjy_-YA9yV4P4svtm2ZzwG2dWugMU21A@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Sep 25, 2020 at 2:18 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Sep 25, 2020 at 02:15:50AM +0200, Jann Horn wrote:
> > On Fri, Sep 25, 2020 at 2:01 AM Kees Cook <keescook@chromium.org> wrote:
> > > 2) seccomp needs to handle "multiplexed" tables like x86_x32 (distros
> > >    haven't removed CONFIG_X86_X32 widely yet, so it is a reality that
> > >    it must be dealt with), which means seccomp's idea of the arch
> > >    "number" can't be the same as the AUDIT_ARCH.
> >
> > Sure, distros ship it; but basically nobody uses it, it doesn't have
> > to be fast. As long as we don't *break* it, everything's fine. And if
> > we ignore the existence of X32 in the fastpath, that'll just mean that
> > syscalls with the X32 marker bit always hit the seccomp slowpath
> > (because it'll look like the syscall number is out-of-bounds ) - no
> > problem.
>
> You do realize that X32 is amd64 counterpart of mips n32, right?  And that's
> not "basically nobody uses it"...

What makes X32 weird for seccomp is that it has the syscall tables for
X86-64 and X32 mushed together, using the single architecture
identifier AUDIT_ARCH_X86_64. I believe that's what Kees referred to
by "multiplexed tables".

As far as I can tell, MIPS is more well-behaved there and uses the
separate architecture identifiers
AUDIT_ARCH_MIPS|__AUDIT_ARCH_64BIT
and
AUDIT_ARCH_MIPS|__AUDIT_ARCH_64BIT|__AUDIT_ARCH_CONVENTION_MIPS64_N32.

(But no, I did not actually realize that that's what N32 is. Thanks
for the explanation, I was wondering why MIPS was the only
architecture with three architecture identifiers...)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
