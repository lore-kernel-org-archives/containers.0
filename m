Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24FA8C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:32:54 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A616820739
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:32:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="KJ+eWGv9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A616820739
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 40E8A203B9;
	Wed, 30 Sep 2020 21:32:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id l5myoKcN0VIW; Wed, 30 Sep 2020 21:32:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 93C18203A7;
	Wed, 30 Sep 2020 21:32:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 743E3C0889;
	Wed, 30 Sep 2020 21:32:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AF522C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:32:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 9602684DB8
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:32:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zNIU7V4fAw6o
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:32:48 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BA3268496E
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:32:48 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id f18so2208106pfa.10
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 14:32:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=o420e7m3IZbrqieFDO0g3Vbb/K2chBl3Ks/YWgHiNOw=;
 b=KJ+eWGv91AIz2+/v9kMs/VQl1R9zZsmavTp7VpHUz2rt2f9L/NffkF/5WluUYnzSnj
 7sPW5vVGvMSfLA4aeQXS+W7lcReo95gKT2p3BfmU2AREeaIfQcUFRa04KlDcPT0npPYL
 2ykxJdLnXqzphZIpU6TUFo3ijdAv7ruc4KXsk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=o420e7m3IZbrqieFDO0g3Vbb/K2chBl3Ks/YWgHiNOw=;
 b=cc+thRy/tqZ11K0lEX1AN5MOBX2/V9PU0BxztXGwiRxIaGivax728o+zfHCxll5o3Q
 G8+wtfYMrvLsDzpk2J5XA9wceD8Zt0DLzzFoKkb+KvGfTogSTiwe4g5tKciSxXWyKTes
 HG0OTgOsyDAv0tiUTy4Fps4szJfMJ0UdVhB9YbnPwTv/S+KjCbUweRTzc59VKNE4v7bi
 kTK0LvAAofdizcAi0VhvXrZeEOiNziF+rovTAYQBgfEhYzpQpcD/dVPOusNtpcz4Jx7t
 xOUOsPYshCXBxycQ1h4rNutT8DZseaFsLJ4hDC8QyH9xutPmqY2iOeiIZmBWLb/kfro4
 e2Qg==
X-Gm-Message-State: AOAM533MeVks2Fr7k8YcmcWfmFcz/uYhS2tWcQiJGDndmvxqwlQvRp96
 TnmV6jBpMfvydQGMZTc3vgsRgQ==
X-Google-Smtp-Source: ABdhPJxFywfjRUgJLANfHOyPeH+0Smh8BUvdparFVzlNNYHCvLQNaP+SUaw0rvKQOr1CntN7Htfrkg==
X-Received: by 2002:a63:703:: with SMTP id 3mr3557549pgh.159.1601501568307;
 Wed, 30 Sep 2020 14:32:48 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id e17sm3658037pff.6.2020.09.30.14.32.47
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 14:32:47 -0700 (PDT)
Date: Wed, 30 Sep 2020 14:32:46 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 3/5] seccomp/cache: Lookup syscall allowlist
 for fast path
Message-ID: <202009301422.D9F6E6A@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <83c72471f9f79fa982508bd4db472686a67b8320.1601478774.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <83c72471f9f79fa982508bd4db472686a67b8320.1601478774.git.yifeifz2@illinois.edu>
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

On Wed, Sep 30, 2020 at 10:19:14AM -0500, YiFei Zhu wrote:
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

I'd like the content/ordering of this and the emulator patch to be reorganized a bit.
I'd like to see the infrastructure of the cache added first (along with
the "always allow" test logic in this patch), with the emulator missing:
i.e. the patch is a logical no-op: no behavior changes because nothing
ever changes the cache bits, but all the operational logic, structure
changes, etc, is in place. Then the next patch would be replacing the
no-op with the emulator.

> ---
>  kernel/seccomp.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 52 insertions(+)
> 
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index f09c9e74ae05..bed3b2a7f6c8 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -172,6 +172,12 @@ struct seccomp_cache_filter_data { };
>  static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
>  {
>  }
> +
> +static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,

bikeshedding: "cache check" doesn't tell me anything about what it's
actually checking for. How about calling this seccomp_is_constant_allow() or
something that reflects both the "bool" return ("is") and what that bool
means ("should always be allowed").

> +				       const struct seccomp_data *sd)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
>  
>  /**
> @@ -331,6 +337,49 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
> +static bool seccomp_cache_check_bitmap(const void *bitmap, size_t bitmap_size,

Please also mark as "inline".

> +				       int syscall_nr)
> +{
> +	if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))
> +		return false;
> +	syscall_nr = array_index_nospec(syscall_nr, bitmap_size);
> +
> +	return test_bit(syscall_nr, bitmap);
> +}
> +
> +/**
> + * seccomp_cache_check - lookup seccomp cache
> + * @sfilter: The seccomp filter
> + * @sd: The seccomp data to lookup the cache with
> + *
> + * Returns true if the seccomp_data is cached and allowed.
> + */
> +static bool seccomp_cache_check(const struct seccomp_filter *sfilter,

inline too.

> +				const struct seccomp_data *sd)
> +{
> +	int syscall_nr = sd->nr;
> +	const struct seccomp_cache_filter_data *cache = &sfilter->cache;
> +
> +#ifdef SECCOMP_ARCH_DEFAULT
> +	if (likely(sd->arch == SECCOMP_ARCH_DEFAULT))
> +		return seccomp_cache_check_bitmap(cache->syscall_allow_default,
> +						  SECCOMP_ARCH_DEFAULT_NR,
> +						  syscall_nr);
> +#endif /* SECCOMP_ARCH_DEFAULT */
> +
> +#ifdef SECCOMP_ARCH_COMPAT
> +	if (likely(sd->arch == SECCOMP_ARCH_COMPAT))
> +		return seccomp_cache_check_bitmap(cache->syscall_allow_compat,
> +						  SECCOMP_ARCH_COMPAT_NR,
> +						  syscall_nr);
> +#endif /* SECCOMP_ARCH_COMPAT */
> +
> +	WARN_ON_ONCE(true);
> +	return false;
> +}
> +#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
> +
>  /**
>   * seccomp_run_filters - evaluates all seccomp filters against @sd
>   * @sd: optional seccomp data to be passed to filters
> @@ -353,6 +402,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
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

Otherwise, yup, looks good.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
