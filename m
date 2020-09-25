Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55373C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:01:08 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 96DEA23A1E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:01:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="DtM19Zce"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96DEA23A1E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 158EF869A5;
	Fri, 25 Sep 2020 00:01:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RXu1_aFNjl0k; Fri, 25 Sep 2020 00:01:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8A3988698F;
	Fri, 25 Sep 2020 00:01:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6E570C0889;
	Fri, 25 Sep 2020 00:01:06 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E6994C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:01:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id D4536869A5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:01:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id c2VoKM6J0cpf
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:01:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 3DE1D8698F
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:01:04 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id g29so925723pgl.2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:01:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:mime-version:content-disposition
 :in-reply-to; bh=/OTxLvYfK8xiR41MGEfuvkgKyuS84smKQAqFrQ02ILY=;
 b=DtM19Zce3SGpX2cE2G7n4o55fRUBl0rHICjJ75Y7xKtq2kBxVGsVg9S2nGRZtPunUf
 L8zI2GaelK5W3oPAZqUnfZ1IuQkpnWFxdLBw1kcVvgMXeTe48FdAhKcGxvwmjrrjEBfc
 LUvZyp28iYLW68aNMVZC8eLcA3LBVnx6n0y+g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
 :content-disposition:in-reply-to;
 bh=/OTxLvYfK8xiR41MGEfuvkgKyuS84smKQAqFrQ02ILY=;
 b=pufurKWd7szIqHHvz1EMeKtpGqUMg+6/nOoh5Ln+Kj8KeqlWM+p+eSqFd81iNWkqL1
 TGFyy0FTd32z4sGoTxZVUqU5zys/yixlZ4WrvkVkfWAjfk6S22rZDNubTfDct1uQDx8U
 IGBAbKZo8F1zdGAdKu5QVNubkqus+EheudXcENa1wzWT4GZq6McKegZnsDQQoODLoV4M
 ssw29N6wr5M3gaDtDnHJ2CrmoL/+9WT51omVumuRQxOW0lQJPCbNn1lUrEKNMsV8Pqjc
 O05qZ76wSZLg7Y16vw5NBmFZ8X9I1ykHUzOKzLFhuuwLTP0yHenzk0341tu9rnogVk52
 zWbQ==
X-Gm-Message-State: AOAM532/pSUjuHZXVCs3eZ0kJk5zqGQQ/ank/cjftctUw+ksvQ6sJoSI
 oesjh0JQunXSdUOOvQmBt7c4qQ==
X-Google-Smtp-Source: ABdhPJzFgb+I/zUJIdM3HtyobzSa8FdBgx88dp5VT/DNVzwJHBDqG5NLMOsVAnQdibYUioz9uKHzRw==
X-Received: by 2002:a17:902:8bca:b029:d2:42fe:20a8 with SMTP id
 r10-20020a1709028bcab02900d242fe20a8mr1633137plo.47.1600992063785; 
 Thu, 24 Sep 2020 17:01:03 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id y1sm423332pgr.3.2020.09.24.17.01.02
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 17:01:02 -0700 (PDT)
Date: Thu, 24 Sep 2020 17:01:01 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
Message-ID: <202009241658.A062D6AE@keescook>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>
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

[resend, argh, I didn't reply-all, sorry for the noise]

On Thu, Sep 24, 2020 at 07:44:17AM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> Seccomp cache emulator needs to know all the architecture numbers
> that syscall_get_arch() could return for the kernel build in order
> to generate a cache for all of them.
> 
> The array is declared in header as static __maybe_unused const
> to maximize compiler optimiation opportunities such as loop
> unrolling.

Disregarding the "how" of this, yeah, we'll certainly need something to
tell seccomp about the arrangement of syscall tables and how to find
them.

However, I'd still prefer to do this on a per-arch basis, and include
more detail, as I've got in my v1.

Something missing from both styles, though, is a consolidation of
values, where the AUDIT_ARCH* isn't reused in both the seccomp info and
the syscall_get_arch() return. The problems here were two-fold:

1) putting this in syscall.h meant you do not have full NR_syscall*
   visibility on some architectures (e.g. arm64 plays weird games with
   header include order).

2) seccomp needs to handle "multiplexed" tables like x86_x32 (distros
   haven't removed CONFIG_X86_X32 widely yet, so it is a reality that
   it must be dealt with), which means seccomp's idea of the arch
   "number" can't be the same as the AUDIT_ARCH.

So, likely a combo of approaches is needed: an array (or more likely,
enum), declared in the per-arch seccomp.h file. And I don't see a way
to solve #1 cleanly.

Regardless, it needs to be split per architecture so that regressions
can be bisected/reverted/isolated cleanly. And if we can't actually test
it at runtime (or find someone who can) it's not a good idea to make the
change. :)

> [...]
> diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
> index 7cbf733d11af..e13bb2a65b6f 100644
> --- a/arch/x86/include/asm/syscall.h
> +++ b/arch/x86/include/asm/syscall.h
> @@ -97,6 +97,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
>  	memcpy(&regs->bx + i, args, n * sizeof(args[0]));
>  }
>  
> +static __maybe_unused const int syscall_arches[] = {
> +	AUDIT_ARCH_I386
> +};
> +
>  static inline int syscall_get_arch(struct task_struct *task)
>  {
>  	return AUDIT_ARCH_I386;
> @@ -152,6 +156,13 @@ static inline void syscall_set_arguments(struct task_struct *task,
>  	}
>  }
>  
> +static __maybe_unused const int syscall_arches[] = {
> +	AUDIT_ARCH_X86_64,
> +#ifdef CONFIG_IA32_EMULATION
> +	AUDIT_ARCH_I386,
> +#endif
> +};

I'm leaving this section quoted because I'll refer to it in a later
patch review...

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
