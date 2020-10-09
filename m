Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18C98C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:48:17 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9929022284
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:48:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="creOSRKT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9929022284
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4D85887221;
	Fri,  9 Oct 2020 17:48:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DkP1QUt2h-+8; Fri,  9 Oct 2020 17:48:15 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id D21318720C;
	Fri,  9 Oct 2020 17:48:15 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BF851C07FF;
	Fri,  9 Oct 2020 17:48:15 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F1AC4C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:48:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id E64A9203A3
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:48:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nUW8jdyJw9RT
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:48:14 +0000 (UTC)
X-Greylist: delayed 00:17:49 by SQLgrey-1.7.6
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com
 [209.85.167.67])
 by silver.osuosl.org (Postfix) with ESMTPS id E2EAD1FE2F
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:48:13 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id a9so11549377lfc.7
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 10:48:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=218xaHs2rZNa9jTYJXmDVRRaape+5jpCuo1cSZDE68Y=;
 b=creOSRKTUeYhh/6OYZA4joo2NuLZpIGt9Kw1OHbgUY8hTfB7xaWX0/NbfNllme2edb
 dgib8pb5T89oPSoxmq9gfSlt0+qO3IE44aMVJy+zAByETZ3fwQ9450NdqyJ5xFO85rZc
 gIrHGYk3HhI/emo4vCgsDyZi4yXDNglUqAmKNk5MSc3PO+YSsTfiCWDckdbwGUgpXpaT
 kRsCyo/cWSpbCUtgrFJDj5IWoTjTpPx7kXn8M4kazm1lbgPWj0UNidKVnWwEATuk1x+7
 kqKBRLlcnmIaUKKlfA9GtaA3AIRxvIHfJ/U8AbBe5EzlvroiSp3xB1UUS3Pblb5hnqB7
 j4gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=218xaHs2rZNa9jTYJXmDVRRaape+5jpCuo1cSZDE68Y=;
 b=NEsfEDEGYEurGfYyd6RKOZTy01fHi08jSLCvP6clszKlyK19kpYj3A87euHpWp7IEE
 X0irMLhAPIVO2lItDlbqmv3EwvYVzHeOVp57TuyG6bsafbjhbuIAhpkYwBRkm6LY8+mC
 YzLEwRn0T2GOGna7UBMszO7Vhv9Lrj7scrCnrDn4CdCvbBDlbYQkKTKf6XwHE9TS7SDw
 mjv6xVygj9mOL1ZcgVP31qbXWXfcuP2VTGtBzWE131UZUY7uZhYyMPWwHJWR/DGnxNWn
 jCnyOqgbxKlXkt6V0jPa476hGuIozHqMEr5j219Hj5lNkUpbGjmgS3REvSNv9+gyE4M2
 1xFw==
X-Gm-Message-State: AOAM533E9m2aDm3lKipDO99/Ykh8m1sTsIBEnmNYGGIiSIasbZP2ya1D
 IJRYLqkAquXoo9DwsEHViv1aoqGIJJ9/UXYrs9oKAigjyC4=
X-Google-Smtp-Source: ABdhPJw8wFSMxS4yjlgkAhvA1enAoa/MDoiy6oG3g4JoOICMO5+l65LTJwkqsXFSbFkPwPeX5NdjEccKlSXmutiQx/U=
X-Received: by 2002:a5d:6744:: with SMTP id l4mr16465051wrw.18.1602264312119; 
 Fri, 09 Oct 2020 10:25:12 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <122e3e70cf775e461ebdfadb5fbb4b6813cca3dd.1602263422.git.yifeifz2@illinois.edu>
In-Reply-To: <122e3e70cf775e461ebdfadb5fbb4b6813cca3dd.1602263422.git.yifeifz2@illinois.edu>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 9 Oct 2020 10:25:00 -0700
Message-ID: <CALCETrUD7z3-zL_rATzTyDUzgerOzXJHdn-hntNMG=vnX8ZF2w@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 3/5] x86: Enable seccomp architecture tracking
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, LKML <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, David Laight <David.Laight@aculab.com>,
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

On Fri, Oct 9, 2020 at 10:15 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
>
> From: Kees Cook <keescook@chromium.org>
>
> Provide seccomp internals with the details to calculate which syscall
> table the running kernel is expecting to deal with. This allows for
> efficient architecture pinning and paves the way for constant-action
> bitmaps.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/x86/include/asm/seccomp.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> index 2bd1338de236..03365af6165d 100644
> --- a/arch/x86/include/asm/seccomp.h
> +++ b/arch/x86/include/asm/seccomp.h
> @@ -16,6 +16,18 @@
>  #define __NR_seccomp_sigreturn_32      __NR_ia32_sigreturn
>  #endif
>
> +#ifdef CONFIG_X86_64
> +# define SECCOMP_ARCH_NATIVE           AUDIT_ARCH_X86_64
> +# define SECCOMP_ARCH_NATIVE_NR                NR_syscalls
> +# ifdef CONFIG_COMPAT
> +#  define SECCOMP_ARCH_COMPAT          AUDIT_ARCH_I386
> +#  define SECCOMP_ARCH_COMPAT_NR       IA32_NR_syscalls
> +# endif
> +#else /* !CONFIG_X86_64 */
> +# define SECCOMP_ARCH_NATIVE           AUDIT_ARCH_I386
> +# define SECCOMP_ARCH_NATIVE_NR                NR_syscalls
> +#endif

Is the idea that any syscall that's out of range for this (e.g. all of
the x32 syscalls) is unoptimized?  I'm okay with this, but I think it
could use a comment.

> +
>  #include <asm-generic/seccomp.h>
>
>  #endif /* _ASM_X86_SECCOMP_H */
> --
> 2.28.0
>


-- 
Andy Lutomirski
AMA Capital Management, LLC
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
