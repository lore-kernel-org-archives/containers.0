Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C95DCC433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 23:14:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2507D222EB
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 23:14:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="iKYPQpxj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2507D222EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A659687886;
	Fri,  9 Oct 2020 23:14:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Sj3+-B6xGa8d; Fri,  9 Oct 2020 23:14:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1368387821;
	Fri,  9 Oct 2020 23:14:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EBFA4C07FF;
	Fri,  9 Oct 2020 23:14:53 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A95E4C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:14:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 87E6C2E334
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:14:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id fb7rerk-KzXz
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:14:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com
 [209.85.214.194])
 by silver.osuosl.org (Postfix) with ESMTPS id 0D8002E32A
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:14:51 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id c6so5196786plr.9
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 16:14:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=n8tMNPlt+WgOGWxVqUdEpRLjgaATmbfqGWdnlUKGm2w=;
 b=iKYPQpxjWQDkWz+DPQGsFwsINVhn1zUNJnEVfUJUHTj6OrT2UeyVf1jFWu2VGG0Sd/
 Q6eQgdzwWjj1nWOw0JUlCIXxYd/FtVriQRsOUwCsaFdBcNkPKi+2pbMPFtUj75Sr/tRe
 8j88AH6f6bdBDPc15Bfpy6/ADirbyIrXuuiWY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=n8tMNPlt+WgOGWxVqUdEpRLjgaATmbfqGWdnlUKGm2w=;
 b=fthVJH/eEqFf3DoG0NrHG8uIprSwgaVyMQSZ8pxcFrRvTLOAmKLba+m5MQSRSw3oAQ
 i8QmmBcn6IBSnpF2lucVxszDYlRnZi5quSB4TCiLPST7nbUSP+8MZUjC2XywQZzFqE/m
 wFezWYJ3AAweoElELkx1kBb7JmX4uYE7eVZdIriTSkectoeBjjl618EyCMflt94zK37G
 kaerL69onoHUgpE455OXNyntagLYrsJkqmC/LFnUR0NDYx6a+sE/Yob/GwzTnf1vCEWg
 q+RdYldld8T4EqvBjNo54s/8VsqsuCjL6qTF2SflggRs1RPb1PvQzxL6lS0H8zUgN35g
 DhiQ==
X-Gm-Message-State: AOAM531CgiZNrf4pe/fzVSwAS7iuWnwZga+7fvVPLPuPBMY6CPmcQfyM
 zIDvJrG5NDASDDqbroU7OZ9l1Q==
X-Google-Smtp-Source: ABdhPJwNBafddDMTu9v6aB/SdriCWv98crtqxIV19v6tjDbA0QjDMDvn6HIEfpx597XYVrlGXc/Prw==
X-Received: by 2002:a17:902:8bc4:b029:d2:8cec:1fae with SMTP id
 r4-20020a1709028bc4b02900d28cec1faemr14566468plo.23.1602285290468; 
 Fri, 09 Oct 2020 16:14:50 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id g4sm12323939pgh.65.2020.10.09.16.14.49
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 09 Oct 2020 16:14:49 -0700 (PDT)
Date: Fri, 9 Oct 2020 16:14:48 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202010091613.B671C86@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
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

On Fri, Oct 09, 2020 at 12:14:33PM -0500, YiFei Zhu wrote:
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
> This file is guarded by CONFIG_SECCOMP_CACHE_DEBUG with a default
> of N because I think certain users of seccomp might not want the
> application to know which syscalls are definitely usable. For
> the same reason, it is also guarded by CAP_SYS_ADMIN.
> 
> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/Kconfig                   | 24 ++++++++++++++
>  arch/x86/Kconfig               |  1 +
>  arch/x86/include/asm/seccomp.h |  3 ++
>  fs/proc/base.c                 |  6 ++++
>  include/linux/seccomp.h        |  5 +++
>  kernel/seccomp.c               | 59 ++++++++++++++++++++++++++++++++++
>  6 files changed, 98 insertions(+)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 21a3675a7a3a..85239a974f04 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -471,6 +471,15 @@ config HAVE_ARCH_SECCOMP_FILTER
>  	    results in the system call being skipped immediately.
>  	  - seccomp syscall wired up
>  
> +config HAVE_ARCH_SECCOMP_CACHE
> +	bool
> +	help
> +	  An arch should select this symbol if it provides all of these things:
> +	  - all the requirements for HAVE_ARCH_SECCOMP_FILTER
> +	  - SECCOMP_ARCH_NATIVE
> +	  - SECCOMP_ARCH_NATIVE_NR
> +	  - SECCOMP_ARCH_NATIVE_NAME
> +
> [...]
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 1ab22869a765..1a807f89ac77 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -150,6 +150,7 @@ config X86
>  	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
>  	select HAVE_ARCH_PREL32_RELOCATIONS
>  	select HAVE_ARCH_SECCOMP_FILTER
> +	select HAVE_ARCH_SECCOMP_CACHE
>  	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
>  	select HAVE_ARCH_STACKLEAK
>  	select HAVE_ARCH_TRACEHOOK

HAVE_ARCH_SECCOMP_CACHE isn't used any more. I think this was left over
from before.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
