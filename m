Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBFA4C2D0A8
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 19:26:25 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3BE152145D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 19:26:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Hdm+Z0AQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BE152145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id B35CA86CAC;
	Wed, 23 Sep 2020 19:26:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d3jrTNYxsl6i; Wed, 23 Sep 2020 19:26:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id DDBF886C7A;
	Wed, 23 Sep 2020 19:26:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C0908C0889;
	Wed, 23 Sep 2020 19:26:23 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 62B5EC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 19:26:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 1D8D9271D7
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 19:26:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id diZJ0XijcXYy
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 19:26:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 5285720437
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 19:26:19 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id l71so315835pge.4
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 12:26:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=nXAM48zLIdF0YA6ut5vJsreIXLyrnpqRvhnrLrqXYJc=;
 b=Hdm+Z0AQ2YfXEdqTM/jmmXNuadizpSWELj7b/lSwr3w3mZLQny01AXlIxmcvmz89JX
 TZ/2xB2j92zPNFDUwR8fZharEUzCJmtl46sYIkw4JWRgQ4ltt1xFIh9QyH7PNQtmowfu
 yVycTgKDm02BteKPPlI+QSaXmN/Z6gtg/ww+A=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=nXAM48zLIdF0YA6ut5vJsreIXLyrnpqRvhnrLrqXYJc=;
 b=tIxB7yHVggHeBBVosI0uzma2PwUHxqDjmQNW9oD65C34Dbae3eWrKds2X6r+EQnzmT
 sgaAty9XSeCVI/N1flNhL9fjbr+EYNxP5mMTZ3L0v5XIfGR00RreRnjluQx8CaZ9HwZF
 9NeoSYYdQg8kD27wn/d2DpuPiH0igS8+7x3OfJ23jeghLxyatj6+Lpl3kqunUGOIOTP8
 9xuxgWHfZyYK85f/3M17e6m8sWVKbXji2K6VBsWn6Oi6CqMr62Ih8oGyqIwuhRjWqyiH
 A7xSVoMj3vryermIdZsr+6HRfSfZggnpLhvWUPCUOpjx1+9u99A+YRfvBVjP0eDiTVHg
 X50Q==
X-Gm-Message-State: AOAM531SpcCOgdvCfDbb+/mGv9px1KFJmAsMHDoNfySh1wGqVZeMI0Ku
 NnUw0ZdubVXx24dbqgL5z2qb8A==
X-Google-Smtp-Source: ABdhPJyM7dxxYK6y0p1u34cW0GjWXGoONrvCkA8LAJVejzdmZSSDiKSh4T1QlGwsBRZsNpPsK+DKQw==
X-Received: by 2002:a65:5786:: with SMTP id b6mr1062182pgr.114.1600889178892; 
 Wed, 23 Sep 2020 12:26:18 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id f4sm576348pgk.19.2020.09.23.12.26.17
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 12:26:17 -0700 (PDT)
Date: Wed, 23 Sep 2020 12:26:17 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
Message-ID: <202009231224.21BCB3BC6@keescook>
References: <cover.1600661418.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <cover.1600661418.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 12:35:16AM -0500, YiFei Zhu wrote:
> In the past Kees proposed [2] to have an "add this syscall to the
> reject bitmask". It is indeed much easier to securely make a reject
> accelerator to pre-filter syscalls before passing to the BPF
> filters, considering it could only strengthen the security provided
> by the filter. However, ultimately, filter rejections are an
> exceptional / rare case. Here, instead of accelerating what is
> rejected, we accelerate what is allowed. In order not to compromise
> the security rules the BPF filters defined, any accept-side
> accelerator must complement the BPF filters rather than replacing them.

Did you see the RFC series for this?

https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/

> Without cache, seccomp_benchmark:
>   Current BPF sysctl settings:
>   net.core.bpf_jit_enable = 1
>   net.core.bpf_jit_harden = 0
>   Calibrating sample size for 15 seconds worth of syscalls ...
>   Benchmarking 23486415 syscalls...
>   16.079642020 - 1.013345439 = 15066296581 (15.1s)
>   getpid native: 641 ns
>   32.080237410 - 16.080763500 = 15999473910 (16.0s)
>   getpid RET_ALLOW 1 filter: 681 ns
>   48.609461618 - 32.081296173 = 16528165445 (16.5s)
>   getpid RET_ALLOW 2 filters: 703 ns
>   Estimated total seccomp overhead for 1 filter: 40 ns
>   Estimated total seccomp overhead for 2 filters: 62 ns
>   Estimated seccomp per-filter overhead: 22 ns
>   Estimated seccomp entry overhead: 18 ns
> 
> With cache:
>   Current BPF sysctl settings:
>   net.core.bpf_jit_enable = 1
>   net.core.bpf_jit_harden = 0
>   Calibrating sample size for 15 seconds worth of syscalls ...
>   Benchmarking 23486415 syscalls...
>   16.059512499 - 1.014108434 = 15045404065 (15.0s)
>   getpid native: 640 ns
>   31.651075934 - 16.060637323 = 15590438611 (15.6s)
>   getpid RET_ALLOW 1 filter: 663 ns
>   47.367316169 - 31.652302661 = 15715013508 (15.7s)
>   getpid RET_ALLOW 2 filters: 669 ns
>   Estimated total seccomp overhead for 1 filter: 23 ns
>   Estimated total seccomp overhead for 2 filters: 29 ns
>   Estimated seccomp per-filter overhead: 6 ns
>   Estimated seccomp entry overhead: 17 ns
> 
> Depending on the run estimated seccomp overhead for 2 filters can be
> less than seccomp overhead for 1 filter, resulting in underflow to
> estimated seccomp per-filter overhead:
>   Estimated total seccomp overhead for 1 filter: 27 ns
>   Estimated total seccomp overhead for 2 filters: 21 ns
>   Estimated seccomp per-filter overhead: 18446744073709551610 ns
>   Estimated seccomp entry overhead: 33 ns

Which also includes updated benchmarking:

https://lore.kernel.org/lkml/20200616074934.1600036-6-keescook@chromium.org/

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
