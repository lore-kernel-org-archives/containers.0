Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68677C4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:46:13 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C2BAA2399A
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:46:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="nZU0Gox+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2BAA2399A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 64FB72041A;
	Thu, 24 Sep 2020 23:46:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ftLvnUMabzZX; Thu, 24 Sep 2020 23:46:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 550CF2000D;
	Thu, 24 Sep 2020 23:46:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2CA7BC0889;
	Thu, 24 Sep 2020 23:46:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D8ACDC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:46:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id C309B86F77
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:46:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ObQD2w9tG3K5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:46:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 123A686DAD
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:46:09 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id md22so489608pjb.0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:46:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=9ENj7PY9iJR1aaISufa4dEvKLBt90CYksr2n88AjVwM=;
 b=nZU0Gox+BoWWtqzE5vCBMv3HolbRvoED55Q9kq1zlE9AgPIMSWyOPXXyjplO8BeIlL
 ZSXjTV7lL/CyldFXjcec/BmUnEUL00XZD2TAYIeVMcTdf2RbZxfhaLyoCVgJwmqEbEjS
 VTcmrBIBnJ6elvXh1lBKjh9rUMcDeUSbulZts=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=9ENj7PY9iJR1aaISufa4dEvKLBt90CYksr2n88AjVwM=;
 b=WJNETscmz7Y9RzCw2Y52T6VbaYXJckXm1iRgBMuSqrp5nl2L4MnSJGviMcDwK9ypNM
 NAO60ar2zDsb2ntMjX5SCvHeS8B2Zmhf0UtzGnBMuLuzeSlZ6E2dEP9+lkADyBjgqpGc
 L/j2c17YI6OK/kMdYA8qU/MoDePCoDoImp+IgJsvyetJ4ZlDIZDQVObu3sYxIFKaiT2b
 Ek5jUSma8ptQHu6tWnOwkT6JB4gvZHJZOObAG2dictt+0T1sfsx/prAMecZXmY+iLWwR
 5dDF/FGC92lFJMDg5rG4XBH2Gipd5g7Yk3jrk4oUk0w7DxZqCSgMIWe23VRoEBz0/FiI
 yYmQ==
X-Gm-Message-State: AOAM532ynG/9vU8g+AiFItidZI+n3+igWcZNUf+HriiNWYsr46ITxHgM
 9NLahcJYW9L6mSqbwPpy1lQ58g==
X-Google-Smtp-Source: ABdhPJxec1KyHWgGfvd89Lelsy+1DeBi80BXPrruoAVIIOR9PLwUTmv1+bZnwlF0lZrfREhV1FhV8g==
X-Received: by 2002:a17:90b:100e:: with SMTP id
 gm14mr78123pjb.200.1600991168576; 
 Thu, 24 Sep 2020 16:46:08 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id f28sm525791pfq.191.2020.09.24.16.46.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 16:46:07 -0700 (PDT)
Date: Thu, 24 Sep 2020 16:46:06 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 4/6] seccomp/cache: Lookup syscall allowlist
 for fast path
Message-ID: <202009241640.7E3C54CF@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <64052a5b81d5dacd63efb577c1d99e6f98e69702.1600951211.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <64052a5b81d5dacd63efb577c1d99e6f98e69702.1600951211.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Thu, Sep 24, 2020 at 07:44:19AM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> The fast (common) path for seccomp should be that the filter permits
> the syscall to pass through, and failing seccomp is expected to be
> an exceptional case; it is not expected for userspace to call a
> denylisted syscall over and over.
> 
> This first finds the current allow bitmask by iterating through
> syscall_arches[] array and comparing it to the one in struct
> seccomp_data; this loop is expected to be unrolled. It then
> does a test_bit against the bitmask. If the bit is set, then
> there is no need to run the full filter; it returns
> SECCOMP_RET_ALLOW immediately.
> 
> Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  kernel/seccomp.c | 37 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 37 insertions(+)
> 
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 20d33378a092..ac0266b6d18a 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -167,6 +167,12 @@ static inline void seccomp_cache_inherit(struct seccomp_filter *sfilter,
>  					 const struct seccomp_filter *prev)
>  {
>  }
> +
> +static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,
> +				       const struct seccomp_data *sd)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
>  
>  /**
> @@ -321,6 +327,34 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
> +/**
> + * seccomp_cache_check - lookup seccomp cache
> + * @sfilter: The seccomp filter
> + * @sd: The seccomp data to lookup the cache with
> + *
> + * Returns true if the seccomp_data is cached and allowed.
> + */
> +static bool seccomp_cache_check(const struct seccomp_filter *sfilter,
> +				const struct seccomp_data *sd)
> +{
> +	int syscall_nr = sd->nr;
> +	int arch;
> +
> +	if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
> +		return false;

This protects us from x32 (i.e. syscall_nr will have 0x40000000 bit
set), but given the effort needed to support compat, I think supporting
x32 isn't much more. (Though again, I note that NR_syscalls differs in
size, so this test needs to be per-arch and obviously after
arch-discovery.)

That said, if it really does turn out that x32 is literally the only
architecture doing these shenanigans (and I suspect not, given the MIPS
case), okay, fine, I'll give in. :) You and Jann both seem to think this
isn't worth it.

> +
> +	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
> +		if (likely(syscall_arches[arch] == sd->arch))

I think this linear search for the matching arch can be made O(1) (this
is what I was trying to do in v1: we can map all possible combos to a
distinct bitmap, so there is just math and lookup rather than a linear
compare search. In the one-arch case, it can also be easily collapsed
into a no-op (though my v1 didn't do this correctly).

> +			return test_bit(syscall_nr,
> +					sfilter->cache.syscall_ok[arch]);
> +	}
> +
> +	WARN_ON_ONCE(true);
> +	return false;
> +}
> +#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
> +
>  /**
>   * seccomp_run_filters - evaluates all seccomp filters against @sd
>   * @sd: optional seccomp data to be passed to filters
> @@ -343,6 +377,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
>  	if (WARN_ON(f == NULL))
>  		return SECCOMP_RET_KILL_PROCESS;
>  
> +	if (seccomp_cache_check(f, sd))
> +		return SECCOMP_RET_ALLOW;
> +
>  	/*
>  	 * All filters in the list are evaluated and the lowest BPF return
>  	 * value always takes priority (ignoring the DATA).
> -- 
> 2.28.0
> 

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
