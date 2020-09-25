Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98AE8C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:55:18 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0D6292085B
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EaJ7/a4c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D6292085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8116C869EB;
	Fri, 25 Sep 2020 01:55:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HgwN8f9zWRHy; Fri, 25 Sep 2020 01:55:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id EDBA3854B4;
	Fri, 25 Sep 2020 01:55:16 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BE2CCC0890;
	Fri, 25 Sep 2020 01:55:16 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F1E1FC0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:55:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id E7199869D2
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:55:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3QceXPtYk6_o
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:55:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6A42D854B4
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:55:14 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id y14so1176339pgf.12
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:55:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=pmx4C1dtZyNzbTWCnrUjbiV406vdOj+1T8GPghm2QwE=;
 b=EaJ7/a4c9WtkliGh/DYbqOiH80G4RWNyo2KqWBHF0u1jetk6xKJXfcrYWFUGdwGk9N
 cko/6jOLwFKwJOAD9xtOFOubNsleb4AEbwj/GwcJrca5RA1dBVr64JyqQTnQmI2m2h73
 o2PCzDXhPuV7i20KVacKica5fsdMyP2fe7GIcNoogYDeAcHyqUZn5UVqpZt5TQhvxvmS
 UZMuhIR80F2ucDe5XnG7Hasm6aOv93CFFxxzuiKA26UqDj/34S5t9bTmCKtFA7wTLtRI
 4cPdoyx46+T1Aa0c5N5TvODHar29fZ+mDfAb23T+yk7ya5HL93xcS0TUqJQCedGFdDxw
 s5fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=pmx4C1dtZyNzbTWCnrUjbiV406vdOj+1T8GPghm2QwE=;
 b=pWFVwSEUpu2FxnBzA1oxrCVEscD7nZpT/Ad0e/mkjMd5CETVNRnvnYYPU5ndgDMmky
 n97ob/9nxqxLk8mqYJdITMjwiUyszBelXvhOeYu23HGdbAanC+ebhqCo2mz2rv/m/Ogq
 d/5MdAvb5p3OPKh/X/qhCYlH5rWGFcesD39sDvuv5pwKO+HCmdorKSCd6qn789Kh0lTO
 KfFGXGQkCHuW1efRMzikI6AGOvmdt6EHbsKzr7spWrIv5E76stjTOm5UOqByf29UZReg
 v3zd5aK53l62hG+GrJyB6aftv0UaL7hGH3azQL3b7Ues1ImBiJc53hjYnPZ2rDUp+Rtd
 d8Jg==
X-Gm-Message-State: AOAM532vJA9wyCQHUyFSkPrU9t0ZTbsfSHDsZSOPO1/0A8hLEAIDfcNA
 A0TdDqKW0qxjCfV0uYka3I7/y1tDEWCH8QblMkY=
X-Google-Smtp-Source: ABdhPJx3ucWbmrm7/0i2a6Fm4liKGVkgl0Fvznjg5vw5jSbIBsA3/utS5x5k2GxvLbWKtN2O/YrGlJU0pZ3jmX+pLCk=
X-Received: by 2002:a63:511d:: with SMTP id f29mr1603013pgb.11.1600998913975; 
 Thu, 24 Sep 2020 18:55:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <64052a5b81d5dacd63efb577c1d99e6f98e69702.1600951211.git.yifeifz2@illinois.edu>
 <202009241640.7E3C54CF@keescook>
In-Reply-To: <202009241640.7E3C54CF@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 20:55:03 -0500
Message-ID: <CABqSeAS1wmCL8gRW+atNO0ZBe0JTzUcbQAR6n461AwhCotNVZg@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 4/6] seccomp/cache: Lookup syscall allowlist
 for fast path
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

On Thu, Sep 24, 2020 at 6:46 PM Kees Cook <keescook@chromium.org> wrote:
> This protects us from x32 (i.e. syscall_nr will have 0x40000000 bit
> set), but given the effort needed to support compat, I think supporting
> x32 isn't much more. (Though again, I note that NR_syscalls differs in
> size, so this test needs to be per-arch and obviously after
> arch-discovery.)
>
> That said, if it really does turn out that x32 is literally the only
> architecture doing these shenanigans (and I suspect not, given the MIPS
> case), okay, fine, I'll give in. :) You and Jann both seem to think this
> isn't worth it.

MIPS has the sparse syscall shenanigans... idek how that works. Maybe
someone can clarify?

> I think this linear search for the matching arch can be made O(1) (this
> is what I was trying to do in v1: we can map all possible combos to a
> distinct bitmap, so there is just math and lookup rather than a linear
> compare search. In the one-arch case, it can also be easily collapsed
> into a no-op (though my v1 didn't do this correctly).

I remember yours was:

static inline u8 seccomp_get_arch(u32 syscall_arch, u32 syscall_nr)
{
[...]
        switch (syscall_arch) {
        case SECCOMP_ARCH:
                seccomp_arch = SECCOMP_ARCH_IS_NATIVE;
                break;
#ifdef CONFIG_COMPAT
        case SECCOMP_ARCH_COMPAT:
                seccomp_arch = SECCOMP_ARCH_IS_COMPAT;
                break;
#endif
        default:
                seccomp_arch = SECCOMP_ARCH_IS_UNKNOWN;
        }

What I'm relying on here is that the compiler will unroll the loop.
How does the compiler perform switch statements? I was imagining it
would be similar, with "case" corresponding to a compare on the
immediate, and the assign as a move to a register, and break
corresponding to a jump. this would also be O(n) to the number of
arches. Yes, compilers can also do an O(1) table lookup, but that is
nonsensical here -- the arch numbers occupy the MSBs.

That said, does O(1) or O(n) matter here? Given that n is at most 3
you might as well consider it a constant.

Also, does "collapse in one arch case" actually worth it? Given that
there's a likely(), and the other side is a WARN_ON_ONCE(), the
compiler will layout the likely path in the fast path and branch
prediction will be in our favor, right?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
