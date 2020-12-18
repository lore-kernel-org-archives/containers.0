Return-Path: <SRS0=rW3o=FW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E50DAC4361B
	for <containers@archiver.kernel.org>; Fri, 18 Dec 2020 12:35:38 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 449ED235FA
	for <containers@archiver.kernel.org>; Fri, 18 Dec 2020 12:35:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 449ED235FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id DD66787A98;
	Fri, 18 Dec 2020 12:35:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MDM2VcsU-wZr; Fri, 18 Dec 2020 12:35:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 42E7F87A84;
	Fri, 18 Dec 2020 12:35:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2CF8CC1787;
	Fri, 18 Dec 2020 12:35:37 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7B4B1C0893
 for <containers@lists.linux-foundation.org>;
 Fri, 18 Dec 2020 12:35:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 6C9E987A90
 for <containers@lists.linux-foundation.org>;
 Fri, 18 Dec 2020 12:35:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id aECSoE4gjPLl
 for <containers@lists.linux-foundation.org>;
 Fri, 18 Dec 2020 12:35:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com
 [209.85.210.53])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A65AB87A84
 for <containers@lists.linux-foundation.org>;
 Fri, 18 Dec 2020 12:35:34 +0000 (UTC)
Received: by mail-ot1-f53.google.com with SMTP id f16so1716461otl.11
 for <containers@lists.linux-foundation.org>;
 Fri, 18 Dec 2020 04:35:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=6DkNUPLV4pty/yUPNr3zH12sGf0mqEAZH7OQh5zf4K8=;
 b=Dq30SxPGeR5qen9VnPZPR3mVCIOPtHUUu6SW/cbD1hGmm4KHtlZ4Fa+sr4pxAhJ+qZ
 S4DBRFc4SF6h4fp0Jv59pzuKZv847IF5C/uKxvPr91F9BzrEJfdNBO7A6X25a0BZvowu
 Hms2kQVnEjBQBeypWPVNBScmOIY+6tJ5P1j1v57g9jLt5w0HwB6ePht/Gahepay37ZEQ
 v3K7S0PdOhZ5dlMVnmsZ+Nz4r/u/jJAFeZ8mPntHKnrayPYdWeYQ1ebZCLnLJlQt7dmc
 iApdYakTvAc92YQG58LX6+eG6E28lLkeqBBmc/suR2vHiWzw7Xjd0AHgsByz08GhYLXs
 53rw==
X-Gm-Message-State: AOAM530pKpd9CU30ozeJMvExqyGUdq4V3BhxieqIvQKavCqCbhY6E9Sx
 7VswgNACZ+m/cfutPn+5HSgnfE+Gh1AESAd2cL4=
X-Google-Smtp-Source: ABdhPJxfxl8yKvwDyX+PZdHV9q/oXdW8TwcExmFO7cyFXUgs7tlC+yddRm9fZPOke+BiKpjClwWCzDNXD7sWbAFO+/Y=
X-Received: by 2002:a05:6830:210a:: with SMTP id
 i10mr2604996otc.145.1608294933980; 
 Fri, 18 Dec 2020 04:35:33 -0800 (PST)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
 <CAMuHMdVU1BhmwMiHKDYmnyRHtQfeMtwtwkFLQwinfBPto-rtOQ@mail.gmail.com>
 <CABqSeARw2tcxEPiU4peuURZybVsFo5K+OkAK0ojADUEENMoKuA@mail.gmail.com>
In-Reply-To: <CABqSeARw2tcxEPiU4peuURZybVsFo5K+OkAK0ojADUEENMoKuA@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 18 Dec 2020 13:35:21 +0100
Message-ID: <CAMuHMdVYLZ3t6yieKVG7fbn1+YMQN26jZnxQ1Jo38LiSm_Eh5A@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Aleksa Sarai <cyphar@cyphar.com>, David Laight <David.Laight@aculab.com>,
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

Hi YiFei,

On Thu, Dec 17, 2020 at 7:34 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> On Thu, Dec 17, 2020 at 6:14 AM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > Should there be a dependency on SECCOMP_ARCH_NATIVE?
> > Should all architectures that implement seccomp have this?
> >
> > E.g. mips does select HAVE_ARCH_SECCOMP_FILTER, but doesn't
> > have SECCOMP_ARCH_NATIVE?
> >
> > (noticed with preliminary out-of-tree seccomp implementation for m68k,
> >  which doesn't have SECCOMP_ARCH_NATIVE
>
> You are correct. This specific patch in this series was not applied,
> and this was addressed in a follow up patch series [1]. MIPS does not
> define SECCOMP_ARCH_NATIVE because the bitmap expects syscall numbers
> to start from 0, whereas MIPS does not (defines
> CONFIG_HAVE_SPARSE_SYSCALL_NR). The follow up patch makes it so that
> any arch with HAVE_SPARSE_SYSCALL_NR (currently just MIPS) cannot have
> CONFIG_SECCOMP_CACHE_DEBUG on, by the depend on clause.
>
> I see that you are doing an out of tree seccomp implementation for
> m68k. Assuming unchanged arch/xtensa/include/asm/syscall.h, something
> like this to arch/m68k/include/asm/seccomp.h should make it work:
>
> #define SECCOMP_ARCH_NATIVE        AUDIT_ARCH_M68K
> #define SECCOMP_ARCH_NATIVE_NR        NR_syscalls
> #define SECCOMP_ARCH_NATIVE_NAME    "m68k"
>
> If the file does not exist already, arch/xtensa/include/asm/seccomp.h
> is a good example of how the file should look like, and remember to
> remove `generic-y += seccomp.h` from arch/m68k/include/asm/Kbuild.
>
> [1] https://lore.kernel.org/lkml/cover.1605101222.git.yifeifz2@illinois.edu/T/

Thank you for your extensive explanation.

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
