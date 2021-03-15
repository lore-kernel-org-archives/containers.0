Return-Path: <SRS0=kdfE=IN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC0FC433E0
	for <containers@archiver.kernel.org>; Mon, 15 Mar 2021 22:03:05 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 81BDA64DF4
	for <containers@archiver.kernel.org>; Mon, 15 Mar 2021 22:03:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81BDA64DF4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 265AB42FF0;
	Mon, 15 Mar 2021 22:03:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J-zoYrzH6H3K; Mon, 15 Mar 2021 22:03:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 3116043155;
	Mon, 15 Mar 2021 22:03:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 04BF0C000C;
	Mon, 15 Mar 2021 22:03:03 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4658FC000A
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:03:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 1F5F183837
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:03:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=chromium.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id yFLzDcegd0lM
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:03:01 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pg1-x531.google.com (mail-pg1-x531.google.com
 [IPv6:2607:f8b0:4864:20::531])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 37BCD8382D
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:03:01 +0000 (UTC)
Received: by mail-pg1-x531.google.com with SMTP id l2so21292899pgb.1
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 15:03:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=pM/cP6/Lz3nYNB1A2BCPvDYZL5Nv+dU7p0YG5FmdOHs=;
 b=i+Pu5UNw/TgHu/fQEXmZOHFShdZNm0HYjuktOVvh43UQqWK9OXoxwTL0KfkLH1Lh3o
 Mkcv0D3zl4D39+93TZwtmfQnzTN3Fg40p8XufRexRcM6m8VQsn9YV4Kt6YovAUS/J0Qh
 oZNwlAoLttJ/w9GIdPY7BRwFC7DF52oYAgWR8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=pM/cP6/Lz3nYNB1A2BCPvDYZL5Nv+dU7p0YG5FmdOHs=;
 b=cJdq8rYTp+aCnsGMTBlT+TyAzOKyLAM/pY4SKOIl3Rr8s6oGOwBbJ/hSBjsdJhZ+pF
 iC1n1V8PecVa76OR2d2g52nB+9BaXlgDsVdkrBxoDP2iySaOirvRzS1lsKKGDek2FMFR
 MnRQJ1ODXTZGMfeAHmu/p5jmV/cAbq3P6pJL0oaCJ1QzIAJPKV4cAl/SgYASBXeOyS4n
 AQwgfUVRPe9IMO97bxK+TNCOh3LOiciGzyTOArhQpqxqJ2mFLc81NnPG+bnQ5lMPur/n
 k08dE++VQCOkJKH7yIkFcpUrXZXK8nt4ZQ+W5ReT3+e9xSURfQN2sRHQEXWB09cjoO7U
 qeKg==
X-Gm-Message-State: AOAM5335dVWQQxZ3V9SJ81pAujcx6yHlz5QfJ96og2Jl5Stt3MLKhl4i
 NdLg9anCCgaJX4Xi0GJUhZZTnA==
X-Google-Smtp-Source: ABdhPJy8q9F/S8HF2FiROpt7pJm13akaXdXmtXbP3bYKMQOOiCIYaDmmj4n4Edotx3q4QzWSMo2peA==
X-Received: by 2002:a63:f808:: with SMTP id n8mr995720pgh.115.1615845780563;
 Mon, 15 Mar 2021 15:03:00 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id h15sm14597755pfo.20.2021.03.15.15.02.59
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 15 Mar 2021 15:02:59 -0700 (PDT)
Date: Mon, 15 Mar 2021 15:02:58 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
Message-ID: <202103151426.ED27141@keescook>
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 io-uring@vger.kernel.org
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

On Wed, Mar 10, 2021 at 01:01:28PM +0100, Alexey Gladkov wrote:
> The current implementation of the ucounts reference counter requires the
> use of spin_lock. We're going to use get_ucounts() in more performance
> critical areas like a handling of RLIMIT_SIGPENDING.

This really looks like it should be refcount_t. I read the earlier
thread[1] on this, and it's not clear to me that this is a "normal"
condition. I think there was a bug in that version (This appeared
to *instantly* crash at boot with mnt_init() calling alloc_mnt_ns()
calling inc_ucount()). The current code looks like just a "regular"
reference counter of the allocated struct ucounts. Overflow should be
very unexpected, yes? And operating on a "0" ucounts should be a bug
too, right?

> [...]
> +/* 127: arbitrary random number, small enough to assemble well */
> +#define refcount_zero_or_close_to_overflow(ucounts) \
> +	((unsigned int) atomic_read(&ucounts->count) + 127u <= 127u)

Regardless, this should absolutely not have "refcount" as a prefix. I
realize it's only used here, but that's needlessly confusing with regard
to it being atomic_t not refcount_t.

> +struct ucounts *get_ucounts(struct ucounts *ucounts)
> +{
> +	if (ucounts) {
> +		if (refcount_zero_or_close_to_overflow(ucounts)) {
> +			WARN_ONCE(1, "ucounts: counter has reached its maximum value");
> +			return NULL;
> +		}
> +		atomic_inc(&ucounts->count);
> +	}
> +	return ucounts;
> +}

I feel like this should just be:

	refcount_inc_not_zero(&ucounts->count);

Or, to address Linus's comment in the v3 series, change get_ucounts to
not return NULL first -- I can't see why that can ever happen in v8.

-Kees

[1] https://lore.kernel.org/lkml/116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com/

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
