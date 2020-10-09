Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E871BC433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:30:50 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3AD0321D41
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="ZG7/cR3D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AD0321D41
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 00D1920437;
	Fri,  9 Oct 2020 21:30:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tSzrTCL0LRYA; Fri,  9 Oct 2020 21:30:49 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 2FFF820418;
	Fri,  9 Oct 2020 21:30:49 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0CED0C07FF;
	Fri,  9 Oct 2020 21:30:49 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BDA09C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id A45348786D
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pt1VrPTNxfDf
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:47 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B4EB087869
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:46 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id u8so15180893ejg.1
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 14:30:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=pbFcqf/DjvQ4JWXqdwx2qoDcjZm2i9Wcon6pZeNDz5o=;
 b=ZG7/cR3DKUuQ/RPLGoR9GRiVD5sFiQY9qmvwtKGyjQ7dUx6cRoXQxPJrsofVX4GvT8
 +bHrvlkc1QdE5fUuR+B4/jEqIhD96HiZRW7ovaFsuN3fEZ+QZA4WfW7Zoh4Ks3/JQ0EC
 foiF78nQ6mvg4w1M98iFAIEqKbJDxwbcU0l389avKqsHHsxkP1F73Y3V7TTlMKHaLOCS
 Dm4YqX7AZSogV5VQASZlZfU5CJKMZXVuwmHApTvWmqpz+YKzBi4/BWNPCESa5p7ZbAdQ
 xYthw3ucPw0eXtEwmhEb7cEy71fk2ZQJ7DXR2iGsteCPu+HY7ggdx/mX75DxDqxJz9QQ
 OIUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=pbFcqf/DjvQ4JWXqdwx2qoDcjZm2i9Wcon6pZeNDz5o=;
 b=GWUXGWBUa2liqfbP0GWqIwdFZcVmkF3Dk6Z16ZhHbpckMnqIspoFpBErTozmiHFGac
 GPHvc5gkk57SjXPq51/IubanI2Z/feZ/EqU6xmGSrf8fOUXcYEaWbXK1H/DL9+/esLoV
 HAGhsemffX9G5PrqMcpHaJn5B+ly5jAiBwu+hk00yFmZGrnZQrIMOyCOLrl81yKVePIO
 DmMeYd+t0p1TKXSBmE6FNfS6dG9LXFZQrL6n2yOv6VM755ls71D2qKCPARKMMNa64ALM
 722mdR/i8OGkEq0MkjhOCytIdFa4YCyY6NACm0+2fAFRUc1M2ARLNdhCfDYS3yEXJXBx
 R4WQ==
X-Gm-Message-State: AOAM531S0pRKoaxJv+/9lJVneApwKlutYzWHSI9KOVeDAYKax5ZIBB/6
 A/BfbQn9BwEVfVrAlY/32cD1aLIb6WZNreNWyfVn+w==
X-Google-Smtp-Source: ABdhPJyVuDxjo0a1CY6IfHFSG0IBKbx7nRGluOc+6dUadBRHkjJq4TYQS4jlWBBOaj1ul7WftAzGnhhHBZG2FVIDTO8=
X-Received: by 2002:a17:906:86c3:: with SMTP id
 j3mr16811843ejy.493.1602279044763; 
 Fri, 09 Oct 2020 14:30:44 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <1a40458d081ce0d5423eb0282210055496e28774.1602263422.git.yifeifz2@illinois.edu>
In-Reply-To: <1a40458d081ce0d5423eb0282210055496e28774.1602263422.git.yifeifz2@illinois.edu>
Date: Fri, 9 Oct 2020 23:30:18 +0200
Message-ID: <CAG48ez1eUfjNPVKeYbk28On9WOaDBysR-=7sYDM-Q=nCzwXcDA@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Fri, Oct 9, 2020 at 7:15 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
>
> From: YiFei Zhu <yifeifz2@illinois.edu>
>
> SECCOMP_CACHE will only operate on syscalls that do not access
> any syscall arguments or instruction pointer. To facilitate
> this we need a static analyser to know whether a filter will
> return allow regardless of syscall arguments for a given
> architecture number / syscall number pair. This is implemented
> here with a pseudo-emulator, and stored in a per-filter bitmap.
>
> In order to build this bitmap at filter attach time, each filter is
> emulated for every syscall (under each possible architecture), and
> checked for any accesses of struct seccomp_data that are not the "arch"
> nor "nr" (syscall) members. If only "arch" and "nr" are examined, and
> the program returns allow, then we can be sure that the filter must
> return allow independent from syscall arguments.
>
> Nearly all seccomp filters are built from these cBPF instructions:
>
> BPF_LD  | BPF_W    | BPF_ABS
> BPF_JMP | BPF_JEQ  | BPF_K
> BPF_JMP | BPF_JGE  | BPF_K
> BPF_JMP | BPF_JGT  | BPF_K
> BPF_JMP | BPF_JSET | BPF_K
> BPF_JMP | BPF_JA
> BPF_RET | BPF_K
> BPF_ALU | BPF_AND  | BPF_K
>
> Each of these instructions are emulated. Any weirdness or loading
> from a syscall argument will cause the emulator to bail.
>
> The emulation is also halted if it reaches a return. In that case,
> if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.
>
> Emulator structure and comments are from Kees [1] and Jann [2].
>
> Emulation is done at attach time. If a filter depends on more
> filters, and if the dependee does not guarantee to allow the
> syscall, then we skip the emulation of this syscall.
>
> [1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
> [2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
[...]
> @@ -682,6 +693,150 @@ seccomp_prepare_user_filter(const char __user *user_filter)
>         return filter;
>  }
>
> +#ifdef SECCOMP_ARCH_NATIVE
> +/**
> + * seccomp_is_const_allow - check if filter is constant allow with given data
> + * @fprog: The BPF programs
> + * @sd: The seccomp data to check against, only syscall number are arch
> + *      number are considered constant.

nit: s/syscall number are arch number/syscall number and arch number/

> + */
> +static bool seccomp_is_const_allow(struct sock_fprog_kern *fprog,
> +                                  struct seccomp_data *sd)
> +{
> +       unsigned int insns;
> +       unsigned int reg_value = 0;
> +       unsigned int pc;
> +       bool op_res;
> +
> +       if (WARN_ON_ONCE(!fprog))
> +               return false;
> +
> +       insns = bpf_classic_proglen(fprog);

bpf_classic_proglen() is defined as:

#define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))

so this is wrong - what you want is the number of instructions in the
program, what you actually have is the size of the program in bytes.
Please instead check for `pc < fprog->len` in the loop condition.

> +       for (pc = 0; pc < insns; pc++) {
> +               struct sock_filter *insn = &fprog->filter[pc];
> +               u16 code = insn->code;
> +               u32 k = insn->k;
[...]

> +       }
> +
> +       /* ran off the end of the filter?! */
> +       WARN_ON(1);
> +       return false;
> +}
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
