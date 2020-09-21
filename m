Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D559CC4363A
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 18:09:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3FDB8206FB
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 18:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="V2T3MJ1W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FDB8206FB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B3EAC8660D;
	Mon, 21 Sep 2020 18:09:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Zb6+GTShpnqi; Mon, 21 Sep 2020 18:09:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8FCD284FA4;
	Mon, 21 Sep 2020 18:09:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8274CC0859;
	Mon, 21 Sep 2020 18:09:25 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1F270C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:09:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id F04F62041C
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:09:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 6Bg7vJhGhtJM
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:09:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com
 [209.85.208.67])
 by silver.osuosl.org (Postfix) with ESMTPS id C244E2033E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:09:22 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id w1so13765725edr.3
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 11:09:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=U2gRVRvTDWwfATk5t7wFIm55wjeGEEthD9jAmx8WrwQ=;
 b=V2T3MJ1WcOFZii4NxoAWnxNlQBSG9qyAOklIbpUH+vhVdFe3M9VI02LT3Cvam9WpPI
 UuT21fUhJvYgQPyLacXu9q5TrAknbhiJ6cmqm0QDdwSNyU1saUwJf45JRhkBwG6/kknw
 eFi97FQTDbWXRtlGpvqo5R1PcAdBSFObnBCFBfxZchUMz3Wm/rAlQcQXukGXh02ZkdQR
 Tjx5XwLp5sFAEwJjpAbIssiDdnrUMhvgsKzYKfXV07QmVxc7nUNWEwzX7Ut+2Tb6m3Dh
 ejZs+LcYMZLrVAyupT44BI22vllUq2EpmffRZO2ZrPRMzVLGpLLNMwqw+dqFNdTwe2fx
 oS2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=U2gRVRvTDWwfATk5t7wFIm55wjeGEEthD9jAmx8WrwQ=;
 b=mInaMzyM8/ZKck3QxU38LxbfXf/y51YQJ6/odFOohTjRwZ/OzrZ0thCOF3Q2YslqPi
 2x2OJDOvpJSDl/6s9Fo9XVdSb175CRfQ+FKjjZDPL+gNxGRvy3L3wgecZm+3q0IPht8v
 fH7y5XVrwSMBK+hEBmlbQOG9UHtJsQ/roRRh03k1zGqTb+J/JdmlKx2OO1O0MTeOJhcK
 eiZZSbzFCUdrSbUrB2rQZmKmmt27XAZhP4JRnyV3gijQTYVAkhHa16kVQZSWCjF2SSJF
 VXvGPG/Fe74AzoAA0lo8cFrFiXjRYG21IgqQzqDajGzqEGVHOZmteWrAwardEKyG3uXe
 sKsA==
X-Gm-Message-State: AOAM5335UMYCYtE7iaycG8g77Ih+/4EzcRMCUjq6LHtGKfRSaEp23uKO
 CTT0qBU+wgvGNdCt1on9RY+/pkHsfk2NkZzPqqAEKQ==
X-Google-Smtp-Source: ABdhPJxzS1PvJpZ0m2Z/pTgp6nyi4eUGvBkhh/prcxCQ3x14BnnFzuu2H8xHujssxKMeV+RGxPHlRe66XeYpkaMAD90=
X-Received: by 2002:a05:6402:cba:: with SMTP id
 cn26mr173873edb.230.1600711760904; 
 Mon, 21 Sep 2020 11:09:20 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
In-Reply-To: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
Date: Mon, 21 Sep 2020 20:08:54 +0200
Message-ID: <CAG48ez3k0_7Vev_O=uV_WVuUGK6BPA0RyrYXMYSDV4DTMMe26g@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 2/2] seccomp/cache: Cache filter results that
 allow syscalls
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
[...]
> We do this by creating a per-task bitmap of permitted syscalls.
> If seccomp filter is invoked we check if it is cached and if so
> directly return allow. Else we call into the cBPF filter, and if
> the result is an allow then we cache the results.

What? Why? We already have code to statically evaluate the filter for
all syscall numbers. We should be using the results of that instead of
re-running the filter and separately caching the results.

> The cache is per-task

Please don't. The static results are per-filter, so the bitmask(s)
should also be per-filter and immutable.

> minimize thread-synchronization issues in
> the hot path of cache lookup

There should be no need for synchronization because those bitmasks
should be immutable.

> and to avoid different architecture
> numbers sharing the same cache.

There should be separate caches for separate architectures, and we
should precompute the results for all architectures. (We only have
around 2 different architectures max, so it's completely reasonable to
precompute and store all that.)

> To account for one thread changing the filter for another thread of
> the same process, the per-task struct also contains a pointer to
> the filter the cache is built on. When the cache lookup uses a
> different filter then the last lookup, the per-task cache bitmap is
> cleared.

Unnecessary complexity, we don't need that if we make the bitmasks immutable.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
