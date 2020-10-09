Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D27DBC433E7
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 23:18:16 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3E03B206B2
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 23:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Lr1dfoHe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E03B206B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id A6AAB87205;
	Fri,  9 Oct 2020 23:18:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qg2vbZwxKU1y; Fri,  9 Oct 2020 23:18:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7BB06875D0;
	Fri,  9 Oct 2020 23:18:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6BEFAC07FF;
	Fri,  9 Oct 2020 23:18:14 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CD441C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:18:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A46702E334
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:18:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Pz4HTkkDo-zD
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:18:10 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com
 [209.85.210.194])
 by silver.osuosl.org (Postfix) with ESMTPS id D8783203A3
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 23:18:10 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id f19so8092580pfj.11
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 16:18:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=D744gDcHOWXajYrsEOce8eCK8+o4p+P+OG7A3xbJaOo=;
 b=Lr1dfoHemJlX/RIX2hvL2D/L44xa5PQeU7QnVLpPhzAzEOQAlmblx8B40RmQGL/07E
 VCSHsxo6VPYFWmSWRAxyjPtDbXNEFu1QxWriaykwo9hkwNCSPWr3lehsNnYMCBvsFPcq
 5ZaxgqdbhnQ+j6kvffD/AwvtU0IQXPPK+WzIw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=D744gDcHOWXajYrsEOce8eCK8+o4p+P+OG7A3xbJaOo=;
 b=htD6ljSqb97JNNVnCkhf3tavlW1B6QPYfCK+2cHAmg+qQEREsZYiBWXKuovW/Ko7tY
 qStRs9JVX0MlZ+6wHR8F1mVtQsIMfbEB/E8eQVY2kPjMfV6BmN0KDt4UL15mtpZm1UYk
 Fy0RwUFGCLePI8bjjNt7wHMgQEpjD8Qkq7FsFZCiTdD3WeeXYb9ViNScO7LENQ7RvlOt
 54gZAPkvBIC7e45JWrYggG9BXDG/lylMTzWxbafGJtDlW9MVfkPd0JiOVinaqV5E7SXh
 iGwFphqCfhtvuJUhAJm3yY7EIwgvDsRH3MvOxc6ou36hXsMnZxVDNG3o4Vm+JUZiIwkI
 22Uw==
X-Gm-Message-State: AOAM531DzcLJXKf9s6cfaY7tKhlFh0FpYIHZAPdtRsByGbQaG3GkD0a8
 ttKhr6tPqBJF4JdrBq6rgft54Q==
X-Google-Smtp-Source: ABdhPJx8ui/HzkhIAhu2rRwKn7Y9jfi9DolNG8cFk6RzmyJOjHiY9uQq6NzZY+18AB3NyWZTy5R5OQ==
X-Received: by 2002:a17:90a:3fcb:: with SMTP id
 u11mr6950918pjm.128.1602285490320; 
 Fri, 09 Oct 2020 16:18:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id 15sm11555731pgt.24.2020.10.09.16.18.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 09 Oct 2020 16:18:09 -0700 (PDT)
Date: Fri, 9 Oct 2020 16:18:08 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 1/5] seccomp/cache: Lookup syscall allowlist
 bitmap for fast path
Message-ID: <202010091614.8BB0EB64@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <896cd9de97318d20c25edb1297db8c65e1cfdf84.1602263422.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <896cd9de97318d20c25edb1297db8c65e1cfdf84.1602263422.git.yifeifz2@illinois.edu>
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

On Fri, Oct 09, 2020 at 12:14:29PM -0500, YiFei Zhu wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
> 
> The overhead of running Seccomp filters has been part of some past
> discussions [1][2][3]. Oftentimes, the filters have a large number
> of instructions that check syscall numbers one by one and jump based
> on that. Some users chain BPF filters which further enlarge the
> overhead. A recent work [6] comprehensively measures the Seccomp
> overhead and shows that the overhead is non-negligible and has a
> non-trivial impact on application performance.
> 
> We observed some common filters, such as docker's [4] or
> systemd's [5], will make most decisions based only on the syscall
> numbers, and as past discussions considered, a bitmap where each bit
> represents a syscall makes most sense for these filters.
> 
> The fast (common) path for seccomp should be that the filter permits
> the syscall to pass through, and failing seccomp is expected to be
> an exceptional case; it is not expected for userspace to call a
> denylisted syscall over and over.
> 
> When it can be concluded that an allow must occur for the given
> architecture and syscall pair (this determination is introduced in
> the next commit), seccomp will immediately allow the syscall,
> bypassing further BPF execution.
> 
> Each architecture number has its own bitmap. The architecture
> number in seccomp_data is checked against the defined architecture
> number constant before proceeding to test the bit against the
> bitmap with the syscall number as the index of the bit in the
> bitmap, and if the bit is set, seccomp returns allow. The bitmaps
> are all clear in this patch and will be initialized in the next
> commit.
> 
> [1] https://lore.kernel.org/linux-security-module/c22a6c3cefc2412cad00ae14c1371711@huawei.com/T/
> [2] https://lore.kernel.org/lkml/202005181120.971232B7B@keescook/T/
> [3] https://github.com/seccomp/libseccomp/issues/116
> [4] https://github.com/moby/moby/blob/ae0ef82b90356ac613f329a8ef5ee42ca923417d/profiles/seccomp/default.json
> [5] https://github.com/systemd/systemd/blob/6743a1caf4037f03dc51a1277855018e4ab61957/src/shared/seccomp-util.c#L270
> [6] Draco: Architectural and Operating System Support for System Call Security
>     https://tianyin.github.io/pub/draco.pdf, MICRO-53, Oct. 2020
> 
> Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  kernel/seccomp.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 72 insertions(+)
> 
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index ae6b40cc39f4..73f6b6e9a3b0 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -143,6 +143,34 @@ struct notification {
>  	struct list_head notifications;
>  };
>  
> +#ifdef SECCOMP_ARCH_NATIVE
> +/**
> + * struct action_cache - per-filter cache of seccomp actions per
> + * arch/syscall pair
> + *
> + * @allow_native: A bitmap where each bit represents whether the
> + *		  filter will always allow the syscall, for the
> + *		  native architecture.
> + * @allow_compat: A bitmap where each bit represents whether the
> + *		  filter will always allow the syscall, for the
> + *		  compat architecture.
> + */
> +struct action_cache {
> +	DECLARE_BITMAP(allow_native, SECCOMP_ARCH_NATIVE_NR);
> +#ifdef SECCOMP_ARCH_COMPAT
> +	DECLARE_BITMAP(allow_compat, SECCOMP_ARCH_COMPAT_NR);
> +#endif
> +};
> +#else
> +struct action_cache { };
> +
> +static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilter,
> +					     const struct seccomp_data *sd)
> +{
> +	return false;
> +}
> +#endif /* SECCOMP_ARCH_NATIVE */
> +
>  /**
>   * struct seccomp_filter - container for seccomp BPF programs
>   *
> @@ -298,6 +326,47 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
>  	return 0;
>  }
>  
> +#ifdef SECCOMP_ARCH_NATIVE
> +static inline bool seccomp_cache_check_allow_bitmap(const void *bitmap,
> +						    size_t bitmap_size,
> +						    int syscall_nr)
> +{
> +	if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))
> +		return false;
> +	syscall_nr = array_index_nospec(syscall_nr, bitmap_size);
> +
> +	return test_bit(syscall_nr, bitmap);
> +}
> +
> +/**
> + * seccomp_cache_check_allow - lookup seccomp cache
> + * @sfilter: The seccomp filter
> + * @sd: The seccomp data to lookup the cache with
> + *
> + * Returns true if the seccomp_data is cached and allowed.
> + */
> +static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilter,
> +					     const struct seccomp_data *sd)
> +{
> +	int syscall_nr = sd->nr;
> +	const struct action_cache *cache = &sfilter->cache;
> +
> +	if (likely(sd->arch == SECCOMP_ARCH_NATIVE))
> +		return seccomp_cache_check_allow_bitmap(cache->allow_native,
> +							SECCOMP_ARCH_NATIVE_NR,
> +							syscall_nr);
> +#ifdef SECCOMP_ARCH_COMPAT
> +	if (likely(sd->arch == SECCOMP_ARCH_COMPAT))
> +		return seccomp_cache_check_allow_bitmap(cache->allow_compat,
> +							SECCOMP_ARCH_COMPAT_NR,
> +							syscall_nr);
> +#endif /* SECCOMP_ARCH_COMPAT */
> +
> +	WARN_ON_ONCE(true);
> +	return false;
> +}
> +#endif /* SECCOMP_ARCH_NATIVE */

An small optimization for the non-compat case might be to do this to
avoid the sd->arch test (which should have no way to ever change in such
builds):

static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilter,
                                             const struct seccomp_data *sd)
{
        const struct action_cache *cache = &sfilter->cache;

#ifndef SECCOMP_ARCH_COMPAT
        /* A native-only architecture doesn't need to check sd->arch. */
        return seccomp_cache_check_allow_bitmap(cache->allow_native,
                                                SECCOMP_ARCH_NATIVE_NR,
                                                sd->nr);
#else /* SECCOMP_ARCH_COMPAT */
        if (likely(sd->arch == SECCOMP_ARCH_NATIVE))
                return seccomp_cache_check_allow_bitmap(cache->allow_native,
                                                        SECCOMP_ARCH_NATIVE_NR,
                                                        sd->nr);
        if (likely(sd->arch == SECCOMP_ARCH_COMPAT))
                return seccomp_cache_check_allow_bitmap(cache->allow_compat,
                                                        SECCOMP_ARCH_COMPAT_NR,
                                                        sd->nr);
#endif

        WARN_ON_ONCE(true);
        return false;
}

> +
>  /**
>   * seccomp_run_filters - evaluates all seccomp filters against @sd
>   * @sd: optional seccomp data to be passed to filters
> @@ -320,6 +389,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
>  	if (WARN_ON(f == NULL))
>  		return SECCOMP_RET_KILL_PROCESS;
>  
> +	if (seccomp_cache_check_allow(f, sd))
> +		return SECCOMP_RET_ALLOW;
> +
>  	/*
>  	 * All filters in the list are evaluated and the lowest BPF return
>  	 * value always takes priority (ignoring the DATA).
> -- 
> 2.28.0
> 

This is all looking good; thank you! I'm doing some test builds/runs
now. :)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
