Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5242DC4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:55:05 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CCEAA2063A
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:55:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="HDDz0mvq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCEAA2063A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7E5ED86A6D;
	Wed, 23 Sep 2020 23:55:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tEONtlS6-deQ; Wed, 23 Sep 2020 23:55:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id E124886A6A;
	Wed, 23 Sep 2020 23:55:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CD5E9C0889;
	Wed, 23 Sep 2020 23:55:03 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B6215C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:55:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id AABEF87434
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:55:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IJj8zlL28C5J
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:55:02 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com
 [209.85.167.67])
 by hemlock.osuosl.org (Postfix) with ESMTPS id DEB1187439
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:55:01 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id y2so1773043lfy.10
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:55:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=39UUQGQGuW0pJ99c+3XIOwje30cjhE1B1JoOVCrOppE=;
 b=HDDz0mvq7a3RG21pW1YeQt8LuyT+FQycHVtfHpuOxU6Biqeaq27Gw7cP0U+Spr7uTp
 Nfq1GselwDFRfr9FK3059LriMRW5TYJYcX4A3//RneCtrNUpPDWnkxJMQiwtFIpc+xw1
 TrsSkUpUgbQzzNtMrHzq4TS+NTY69w1m+cz1jSf5lzvMoJsoiRFI4xUrHsuNE58iigSY
 dsycOzIWKTJ/5jb7J3PeM5sJ+YXGWe5SKxbRup2+kxQQThT5O52j2q8aOVj3NI/LcdsV
 4K4MJstPwqmiwhW2iAm2V8jx4jj4lNPMoabpg7l5YPdv92Pf0rDC2GeoWWIt7WxkjGvU
 abwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=39UUQGQGuW0pJ99c+3XIOwje30cjhE1B1JoOVCrOppE=;
 b=SFKKmGULJs/et2WdmpW5tGhwFw9Bpzj+Tfxkt6I7AOKQGa860H7h2ITl4yp5BGwjEA
 9pIE9DfLZZHtwEiQC6UekVp2tm2uXB0ygYk6ccnDED/pHvdx37G6DLXN0U6IiKxkX2gv
 1gEf87PLzHtl/c4FDGVpfnvl3rTUn2hdwlwJidsd/pOhA5AVQ9ykrM0c9nnnd/hEQyHo
 VL+YDrFTKvEzJrJw+xIg79CvsBXX7YkDnsR2fWfDEegyf7RtGMEgnD0zyLeQZ6M6VAAo
 voVd3R4arlKru3F2W3QG79U3Cu9F9tPgk7CWhCpYGLrD8mr2HffvxvMUVgv3XQC1dAcV
 JecQ==
X-Gm-Message-State: AOAM530gHcPRzM5fMyc5PhG9bPeYp7ZUPAli5MfoQRj+EqQX7QpP6+tg
 8t7Lv6lyjw3FFmuGjb05hGxEgFT8C8EI12hU4ovYVaP6Q6PyMQ==
X-Google-Smtp-Source: ABdhPJztAHF67qXzKrzzYSP3nT64vv5jq7HwOELGrmAfvL52R7Pr4wN/V46V4Apb43rLzuJU3SZ/sIdez/zch09EI8g=
X-Received: by 2002:a17:907:64d:: with SMTP id
 wq13mr1931271ejb.513.1600904893980; 
 Wed, 23 Sep 2020 16:48:13 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-5-keescook@chromium.org>
In-Reply-To: <20200923232923.3142503-5-keescook@chromium.org>
Date: Thu, 24 Sep 2020 01:47:47 +0200
Message-ID: <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
Subject: Re: [PATCH 4/6] seccomp: Emulate basic filters for constant action
 results
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
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

On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> This emulates absolutely the most basic seccomp filters to figure out
> if they will always give the same results for a given arch/nr combo.
>
> Nearly all seccomp filters are built from the following ops:
>
> BPF_LD  | BPF_W    | BPF_ABS
> BPF_JMP | BPF_JEQ  | BPF_K
> BPF_JMP | BPF_JGE  | BPF_K
> BPF_JMP | BPF_JGT  | BPF_K
> BPF_JMP | BPF_JSET | BPF_K
> BPF_JMP | BPF_JA
> BPF_RET | BPF_K
>
> These are now emulated to check for accesses beyond seccomp_data::arch
> or unknown instructions.
>
> Not yet implemented are:
>
> BPF_ALU | BPF_AND (generated by libseccomp and Chrome)

BPF_AND is normally only used on syscall arguments, not on the syscall
number or the architecture, right? And when a syscall argument is
loaded, we abort execution anyway. So I think there is no need to
implement those?

> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  kernel/seccomp.c  | 82 ++++++++++++++++++++++++++++++++++++++++++++---
>  net/core/filter.c |  3 +-
>  2 files changed, 79 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 111a238bc532..9921f6f39d12 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -610,7 +610,12 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
>  {
>         struct seccomp_filter *sfilter;
>         int ret;
> -       const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
> +       const bool save_orig =
> +#if defined(CONFIG_CHECKPOINT_RESTORE) || defined(SECCOMP_ARCH)
> +               true;
> +#else
> +               false;
> +#endif

You could probably write this as something like:

const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) ||
__is_defined(SECCOMP_ARCH);

[...]
> diff --git a/net/core/filter.c b/net/core/filter.c
[...]
> -static void bpf_release_orig_filter(struct bpf_prog *fp)
> +void bpf_release_orig_filter(struct bpf_prog *fp)
>  {
>         struct sock_fprog_kern *fprog = fp->orig_prog;
>
> @@ -1154,6 +1154,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
>                 kfree(fprog);
>         }
>  }
> +EXPORT_SYMBOL_GPL(bpf_release_orig_filter);

If this change really belongs into this patch (which I don't think it
does), please describe why in the commit message.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
