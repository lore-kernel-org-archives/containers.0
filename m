Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF036C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:59:44 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2D36D2072E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:59:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RvEzwWeJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D36D2072E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A22CE87234;
	Wed, 30 Sep 2020 22:59:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id v7rCHzm7PLPI; Wed, 30 Sep 2020 22:59:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 06C1F86408;
	Wed, 30 Sep 2020 22:59:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E1C18C016F;
	Wed, 30 Sep 2020 22:59:42 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 417E7C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:59:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 2E85D85475
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:59:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id YjOpz5cJvk24
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:59:40 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f67.google.com (mail-pj1-f67.google.com
 [209.85.216.67])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 762B183641
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:59:40 +0000 (UTC)
Received: by mail-pj1-f67.google.com with SMTP id kk9so726799pjb.2
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:59:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=mA4RbbGe3ZFZ8RcnTkMkNKoVYtjAYSExGb4WNfYO9TM=;
 b=RvEzwWeJN2a6gRlpZth2o25ndD+auCau4MS6DEJl7FxRP73WxgWlIWhGFYT4nMj4ax
 rwqmJHWUhezeYTftYK3nZPt4GWWUr4r0+VwQ5Mo0/P62KBQLjDwPqasCuvps4S30EzsK
 sQi5G0JVL9ITJDfSI/8aqYEeY5u3nyKSGfggs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=mA4RbbGe3ZFZ8RcnTkMkNKoVYtjAYSExGb4WNfYO9TM=;
 b=ASNAMguSZ28EYTV1D4mgIGKq8Y1X9oCaH6oaUngB4T4ZwLaWfySgjguyrWzmKfMIxU
 lVIwH+66H8vZZhtWCuwmQ8xG96QrcGm6VSVOGfKdgbeyzOCpdDPkkXU2IbpHJc0aizT7
 48BxPLJyHVlTI3Z1/2TTbXgp38MPlPZ0sjV/D3fc4XvhkNWG5mCCfEVHXNwrNnqmhN5v
 SIEqhLb9s6h58GgHxyyrNpAAUARw0F/gS00g35BoXD5Ipz97lcIDQjOEsIuuV3kiocDt
 40k8fxaeeGhWqccvE1SgDEN4PgGLU+hqqh9zhSGqGchO4eoq99/u1vw35BVej3mAtOdX
 UNsA==
X-Gm-Message-State: AOAM530or4N1rPgfGjWWm/eNu+r0REaAxHy9K5pxeqQbRsAahlzS52Jx
 xcRpduFQg7Td7M5/RH1YIM3mTA==
X-Google-Smtp-Source: ABdhPJz64CmLzcbic8Oz26Aoz/WnP6GPlfiVb7QsHaknqk8NVQHnMJKg1SPPBWVyqQNBYFHVFM/jpw==
X-Received: by 2002:a17:90b:1083:: with SMTP id
 gj3mr4559450pjb.126.1601506780048; 
 Wed, 30 Sep 2020 15:59:40 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id b20sm3775348pfb.198.2020.09.30.15.59.37
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 15:59:38 -0700 (PDT)
Date: Wed, 30 Sep 2020 15:59:37 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202009301554.590642EBE@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
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

On Wed, Sep 30, 2020 at 10:19:16AM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> Currently the kernel does not provide an infrastructure to translate
> architecture numbers to a human-readable name. Translating syscall
> numbers to syscall names is possible through FTRACE_SYSCALL
> infrastructure but it does not provide support for compat syscalls.
> 
> This will create a file for each PID as /proc/pid/seccomp_cache.
> The file will be empty when no seccomp filters are loaded, or be
> in the format of:
> <arch name> <decimal syscall number> <ALLOW | FILTER>
> where ALLOW means the cache is guaranteed to allow the syscall,
> and filter means the cache will pass the syscall to the BPF filter.
> 
> For the docker default profile on x86_64 it looks like:
> x86_64 0 ALLOW
> x86_64 1 ALLOW
> x86_64 2 ALLOW
> x86_64 3 ALLOW
> [...]
> x86_64 132 ALLOW
> x86_64 133 ALLOW
> x86_64 134 FILTER
> x86_64 135 FILTER
> x86_64 136 FILTER
> x86_64 137 ALLOW
> x86_64 138 ALLOW
> x86_64 139 FILTER
> x86_64 140 ALLOW
> x86_64 141 ALLOW
> [...]
> 
> This file is guarded by CONFIG_DEBUG_SECCOMP_CACHE with a default
> of N because I think certain users of seccomp might not want the
> application to know which syscalls are definitely usable. For
> the same reason, it is also guarded by CAP_SYS_ADMIN.
> 
> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/Kconfig                   | 15 +++++++++++
>  arch/x86/include/asm/seccomp.h |  3 +++
>  fs/proc/base.c                 |  3 +++
>  include/linux/seccomp.h        |  5 ++++
>  kernel/seccomp.c               | 46 ++++++++++++++++++++++++++++++++++
>  5 files changed, 72 insertions(+)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index ca867b2a5d71..b840cadcc882 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -478,6 +478,7 @@ config HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
>  	  - all the requirements for HAVE_ARCH_SECCOMP_FILTER
>  	  - SECCOMP_ARCH_DEFAULT
>  	  - SECCOMP_ARCH_DEFAULT_NR
> +	  - SECCOMP_ARCH_DEFAULT_NAME
>  
>  config SECCOMP
>  	prompt "Enable seccomp to safely execute untrusted bytecode"
> @@ -532,6 +533,20 @@ config SECCOMP_CACHE_NR_ONLY
>  
>  endchoice
>  
> +config DEBUG_SECCOMP_CACHE

naming nit: I prefer where what how order, so SECCOMP_CACHE_DEBUG.

> +	bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
> +	depends on SECCOMP_CACHE_NR_ONLY
> +	depends on PROC_FS
> +	help
> +	  This is enables /proc/pid/seccomp_cache interface to monitor
> +	  seccomp cache data. The file format is subject to change. Reading
> +	  the file requires CAP_SYS_ADMIN.
> +
> +	  This option is for debugging only. Enabling present the risk that
> +	  an adversary may be able to infer the seccomp filter logic.
> +
> +	  If unsure, say N.
> +
>  config HAVE_ARCH_STACKLEAK
>  	bool
>  	help
> diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> index 7b3a58271656..33ccc074be7a 100644
> --- a/arch/x86/include/asm/seccomp.h
> +++ b/arch/x86/include/asm/seccomp.h
> @@ -19,13 +19,16 @@
>  #ifdef CONFIG_X86_64
>  # define SECCOMP_ARCH_DEFAULT			AUDIT_ARCH_X86_64
>  # define SECCOMP_ARCH_DEFAULT_NR		NR_syscalls
> +# define SECCOMP_ARCH_DEFAULT_NAME		"x86_64"
>  # ifdef CONFIG_COMPAT
>  #  define SECCOMP_ARCH_COMPAT			AUDIT_ARCH_I386
>  #  define SECCOMP_ARCH_COMPAT_NR		IA32_NR_syscalls
> +#  define SECCOMP_ARCH_COMPAT_NAME		"x86_32"

I think this should be "ia32"? Is there a good definitive guide on this
naming convention?

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
