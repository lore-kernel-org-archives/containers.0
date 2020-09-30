Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFBCCC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:21:34 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0F1DF2072E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:21:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="QL/8qtqD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1DF2072E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B487384F48;
	Wed, 30 Sep 2020 21:21:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YWhEGx2j66cO; Wed, 30 Sep 2020 21:21:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0228D84636;
	Wed, 30 Sep 2020 21:21:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E7F9BC0889;
	Wed, 30 Sep 2020 21:21:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 75199C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:21:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 5A9A4203A8
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:21:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id VqYOIgtlJkzy
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:21:29 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by silver.osuosl.org (Postfix) with ESMTPS id D84F9203A7
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:21:29 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 7so1948894pgm.11
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 14:21:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=lv/VYS6WVyLfsnzAOnjQJDHCItBTdggrCJvPM6RfMKw=;
 b=QL/8qtqD7TX6f+oI3k3pCSaenm7hpXhiJpS4nzuX8VywkpDdYkfvOqg4PD9ycAR8Ev
 rPaaYLRxcRrmugxIUbCZeftZ4UbLcYoi9ruaSYnn8Ngr3fbnc100I+htwT4EGuv009Xu
 jynYchzrT73iTHN2C6ClR8RO9m1+sNdO7EQeE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=lv/VYS6WVyLfsnzAOnjQJDHCItBTdggrCJvPM6RfMKw=;
 b=CyzKYd7c0PFMRUs3ITwJvqdvzerDxyZZWWb8+VX8OdeNfHBCSh5DiTeMiDvEjvt1k3
 JUBDACH7K4Lr5urWuxt992xCBmY640ci1Hyj8AEnnDCn/ryF+2QReREJk55tlD0bYFY8
 HkpaJwwI/wSllyY07K7qQccU5/UvEtu5DgAZ93JqOmYwjuId6QdKY69TxKG0VYi+OvrW
 ytQyBUBR3HvbHczGWwpflRaivYj0XdYL7FlRZCMmh2xZSA80P3qIG2546WTte+4YdVoS
 VVW+H2YNLd0gPOVeJ/SRd1YxU33EwzxmQWfu1SQi0+UOYYm4Mu1ELXiSyUDlddhMWv/L
 sVtA==
X-Gm-Message-State: AOAM531XD1Sa+2M0g1x+H4iRpPz1F/soGFw+UoWDlvoOhGs/WPkTxMll
 eoziHhCt87kbeSXIHIc3nfXVYg==
X-Google-Smtp-Source: ABdhPJyz5PkXKzzAFCYMVHQjc9sSnYWzqxDm1d9ol9v+cbqCMKYnjx9sn1stgq5ZDlNEJB0VqXgksg==
X-Received: by 2002:a17:902:b186:b029:d1:cc21:9a7d with SMTP id
 s6-20020a170902b186b02900d1cc219a7dmr4250435plr.8.1601500889449; 
 Wed, 30 Sep 2020 14:21:29 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id j6sm3440223pfi.129.2020.09.30.14.21.28
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 14:21:28 -0700 (PDT)
Date: Wed, 30 Sep 2020 14:21:27 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 1/5] x86: Enable seccomp architecture tracking
Message-ID: <202009301418.20BA0CE33@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
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

On Wed, Sep 30, 2020 at 10:19:12AM -0500, YiFei Zhu wrote:
> From: Kees Cook <keescook@chromium.org>
> 
> Provide seccomp internals with the details to calculate which syscall
> table the running kernel is expecting to deal with. This allows for
> efficient architecture pinning and paves the way for constant-action
> bitmaps.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> [YiFei: Removed x32, added macro for nr_syscalls]
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/x86/include/asm/seccomp.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> index 2bd1338de236..7b3a58271656 100644
> --- a/arch/x86/include/asm/seccomp.h
> +++ b/arch/x86/include/asm/seccomp.h
> @@ -16,6 +16,18 @@
>  #define __NR_seccomp_sigreturn_32	__NR_ia32_sigreturn
>  #endif
>  
> +#ifdef CONFIG_X86_64
> +# define SECCOMP_ARCH_DEFAULT			AUDIT_ARCH_X86_64
> +# define SECCOMP_ARCH_DEFAULT_NR		NR_syscalls

bikeshedding: let's call these SECCOMP_ARCH_NATIVE* -- I think it's more
descriptive.

> +# ifdef CONFIG_COMPAT
> +#  define SECCOMP_ARCH_COMPAT			AUDIT_ARCH_I386
> +#  define SECCOMP_ARCH_COMPAT_NR		IA32_NR_syscalls
> +# endif
> +#else /* !CONFIG_X86_64 */
> +# define SECCOMP_ARCH_DEFAULT		AUDIT_ARCH_I386
> +# define SECCOMP_ARCH_DEFAULT_NR	NR_syscalls
> +#endif
> +
>  #include <asm-generic/seccomp.h>
>  
>  #endif /* _ASM_X86_SECCOMP_H */
> -- 
> 2.28.0
> 

But otherwise, yes, looks good to me. For this patch, I think the S-o-b chain is probably more
accurately captured as:

Signed-off-by: Kees Cook <keescook@chromium.org>
Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>


-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
