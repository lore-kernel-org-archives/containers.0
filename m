Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4EB4C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:31:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4B93321D41
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="HY0u+kX5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B93321D41
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id F0FB887870;
	Fri,  9 Oct 2020 21:30:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SzzYqObMS9Qn; Fri,  9 Oct 2020 21:30:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4AC1487869;
	Fri,  9 Oct 2020 21:30:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 30CCCC07FF;
	Fri,  9 Oct 2020 21:30:57 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 23768C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1F155871FC
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mPjjMocncHiC
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com
 [209.85.208.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 43538871E1
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:30:55 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id o18so10909367edq.4
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 14:30:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=CSRAHb/axz17M+0sWNwy+ixadRZAMXlB5z5CiZ4OuV8=;
 b=HY0u+kX5HLC2Qd/hrbktWnWpqOSCxBXT3upvUFDtjn+PQwxihMAxO7b17zrilGpniu
 Z/H4JmecauoImC4n6z/XuMGPe9m/fKvi3HUsIaSIN5Vh0h9oJizzFej6p8VupLfSBpv1
 1DxoGx28bnw9wjP3qaVpNc+QqlJxc/NVthbUpnHP6rzn4hxdW9x4BmvgBCkwRxaV4uG3
 TvIrmUEl3tqjzHanRb36NzEAD3F/TD94mNKCpByd9hMTqtXQEnSbVMIkAALhyvoRTHJD
 dVE++0gF0w5nI42UG8NH4b76H/O3FzWMQwcPWdDfcJxiVuoQxs7pfn6hdE4zvJQarNUM
 +JGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=CSRAHb/axz17M+0sWNwy+ixadRZAMXlB5z5CiZ4OuV8=;
 b=frjf6KO8xAn3jXHTOIeLxz/KEUCukchHWMd9JhXNf/fAFOjXpf+eOKnp/WT7kiQTxc
 Vw/7NYuvGauXT3GYRkjMzrz4LF6ooZ+oD/8xTVIYOtXIIgZMcYE+evuKuffOiPX85sSZ
 c+JfPxdkMbvfO8LMRS2HinfGmADEmalmIFGQ9JGO54nGDYFOtb+Z9G9j/GNkN4ZQubYQ
 aasmkqkJI0jyk4ZjzS2msLOtlcekMOqBnECtgCJS3EiYdLSX0oivQP/AEWgkL5h3uhf2
 hSJ1mIDM9hJoiYTKlm6zCS52tJHqYaaRdC4R21EzZv/Z+eN1iKkheBpvqUaaauSxiMA1
 ledg==
X-Gm-Message-State: AOAM533XxILj3k1ifCIoQqaIin7ZwH4vII6kz0+P4khoUJuJooY/8NiB
 +MnLM55WpYzpsdRhqJY1sHTCDUEPDmRnrcGjmfY8ag==
X-Google-Smtp-Source: ABdhPJwkUG0xCEADMm4ps+nqQrIgOFcSR9FQBEPfpbKQHQBKUjESr+d/BbjnWhkO3OcRNdTt+3fk/bliCilbZoaGIB8=
X-Received: by 2002:a05:6402:32f:: with SMTP id
 q15mr1339366edw.230.1602279053404; 
 Fri, 09 Oct 2020 14:30:53 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <896cd9de97318d20c25edb1297db8c65e1cfdf84.1602263422.git.yifeifz2@illinois.edu>
In-Reply-To: <896cd9de97318d20c25edb1297db8c65e1cfdf84.1602263422.git.yifeifz2@illinois.edu>
Date: Fri, 9 Oct 2020 23:30:27 +0200
Message-ID: <CAG48ez3KEp2BNcDatRu1V0G-H7hUCF66HJ0BPf0uqTnK3toY4Q@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 1/5] seccomp/cache: Lookup syscall allowlist
 bitmap for fast path
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Fri, Oct 9, 2020 at 7:15 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
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
[...]
> Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

Reviewed-by: Jann Horn <jannh@google.com>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
