Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE64FC4741F
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 10:22:43 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2178B223AB
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 10:22:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ellerman.id.au header.i=@ellerman.id.au header.b="oDkd83Ut"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2178B223AB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 820C620C41;
	Wed,  4 Nov 2020 10:22:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p5ZuwgA0OYMI; Wed,  4 Nov 2020 10:22:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0E6FF2049E;
	Wed,  4 Nov 2020 10:22:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D97C6C088B;
	Wed,  4 Nov 2020 10:22:40 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0CE81C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 10:22:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id EEBA78691C
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 10:22:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BrEpMXR9YuhK
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 10:22:37 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from ozlabs.org (bilbo.ozlabs.org [203.11.71.1])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B5AA586903
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 10:22:37 +0000 (UTC)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest
 SHA256) (No client certificate requested)
 by mail.ozlabs.org (Postfix) with ESMTPSA id 4CR2lS6ZW8z9sTL;
 Wed,  4 Nov 2020 21:22:28 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ellerman.id.au;
 s=201909; t=1604485355;
 bh=L70AG7tzTd7Z55u+Fj8DTKuCWP9ecgUCCOxcamNMHIs=;
 h=From:To:Cc:Subject:In-Reply-To:References:Date:From;
 b=oDkd83UtH0Srm5gou9o8FbK7V4IaynA9LCA2YJKhl+5lUnI+xkZjuVD5VI7pJ+a2M
 HfsMI0MoloEkD3kwT+0vUtyCVb5PM2a9WPF6rkPmZB+9idXkIb7EMvyH3VOFzyp/Ps
 68txSVLNJRowCRuykY+i+5Ewg7c/SwxbVOrNc5RWW00H/82L7EDvL4Qy2KV2oBLDUb
 2yVheHA/7sjVh0E3O3cAIx/q6Zcp5FGUuuzsq1Mfee0O7JtPXB0z7fnfD69DrTlxhD
 Ug36BFsOA8q9k55mb81BwQUF1fU4SM3xLLRlc5FTkEqiwDPXMtmP7ZL6xkIZIdCtj0
 qdybn2J+0q8JQ==
From: Michael Ellerman <mpe@ellerman.id.au>
To: YiFei Zhu <zhuyifei1999@gmail.com>, containers@lists.linux-foundation.org
Subject: Re: [PATCH seccomp 3/8] powerpc: Enable seccomp architecture tracking
In-Reply-To: <4ec2970fcc819eb4d5dac2bd35233ccdadfda845.1604410035.git.yifeifz2@illinois.edu>
References: <cover.1604410035.git.yifeifz2@illinois.edu>
 <4ec2970fcc819eb4d5dac2bd35233ccdadfda845.1604410035.git.yifeifz2@illinois.edu>
Date: Wed, 04 Nov 2020 21:22:28 +1100
Message-ID: <87wnz1to9n.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Cc: linux-sh@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 linux-riscv@lists.infradead.org, Andrea Arcangeli <aarcange@redhat.com>,
 linux-s390@vger.kernel.org, YiFei Zhu <yifeifz2@illinois.edu>,
 linux-csky@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>,
 linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Valentin Rothberg <vrothber@redhat.com>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, linuxppc-dev@lists.ozlabs.org
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

YiFei Zhu <zhuyifei1999@gmail.com> writes:
> From: YiFei Zhu <yifeifz2@illinois.edu>
>
> To enable seccomp constant action bitmaps, we need to have a static
> mapping to the audit architecture and system call table size. Add these
> for powerpc.
>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/powerpc/include/asm/seccomp.h | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/seccomp.h b/arch/powerpc/include/asm/seccomp.h
> index 51209f6071c5..3efcc83e9cc6 100644
> --- a/arch/powerpc/include/asm/seccomp.h
> +++ b/arch/powerpc/include/asm/seccomp.h
> @@ -8,4 +8,25 @@
>  
>  #include <asm-generic/seccomp.h>
>  
> +#ifdef __LITTLE_ENDIAN__

As Kees mentioned this should (must?!) match the configured endian.

But I think it would still be better to use the CONFIG symbol, which is
CONFIG_CPU_LITTLE_ENDIAN.

> +#define __SECCOMP_ARCH_LE_BIT		__AUDIT_ARCH_LE
> +#else
> +#define __SECCOMP_ARCH_LE_BIT		0
> +#endif
> +
> +#ifdef CONFIG_PPC64
> +# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC64 | __SECCOMP_ARCH_LE)

You use __SECCOMP_ARCH_LE there, but previously you only defined
__SECCOMP_ARCH_LE_BIT.

Is there some magic somewhere that defines __SECCOMP_ARCH_LE based on
__SECCOMP_ARCH_LE_BIT ?

> +# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
> +# define SECCOMP_ARCH_NATIVE_NAME	"ppc64"

What's the name used for?

Usually we use "ppc64" for 64-bit big endian and "ppc64le" for 64-bit
little endian.

> +# ifdef CONFIG_COMPAT
> +#  define SECCOMP_ARCH_COMPAT		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
> +#  define SECCOMP_ARCH_COMPAT_NR	NR_syscalls
> +#  define SECCOMP_ARCH_COMPAT_NAME	"powerpc"

And usually we use "ppc" for 32-bit.

> +# endif
> +#else /* !CONFIG_PPC64 */
> +# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
> +# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
> +# define SECCOMP_ARCH_NATIVE_NAME	"powerpc"
> +#endif
> +
>  #endif	/* _ASM_POWERPC_SECCOMP_H */
> -- 
> 2.29.2


cheers
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
