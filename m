Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E10CC433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:43:25 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A38CF206FB
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="liJEn3P8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A38CF206FB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 5577420773;
	Mon, 12 Oct 2020 06:43:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BOS1UHpXs+EL; Mon, 12 Oct 2020 06:43:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 9834420555;
	Mon, 12 Oct 2020 06:43:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8727DC0052;
	Mon, 12 Oct 2020 06:43:21 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 38F7DC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:43:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 2521B87277
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:43:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Nu7hp6HU8DmG
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:43:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 2806987265
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:43:19 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id u8so21655472ejg.1
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 23:43:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=8L82QjxMFG+r7QSsdjzTxfz9BqpiVnaUpK+324xJ45o=;
 b=liJEn3P8GhTC9buz4u9pgXW2jZr7I9OZqGoH9rI6dOu/SvvD+mgE2tMDI/XC8+UyEa
 hkRR2uD0cJ3mxMZQwctrmWg6mIC/iBQIHjYQkAe/7TE3UoNtaU9H280J2Jlc1756UknI
 6CrZmT9ZxNGkPJncUXIO0tIyvokI7yydua6P/beBqwQ2PddwXuLQnhJ0g5sNDtEwrz94
 4vlCC4C0QnujNTx1CIx8/jDcfCZyohwTZePfYMDYQpSCyOKl12t3iOAnIHnMmOU9Muz8
 HmeEpOwTDkslb4i6FqVRfZZ0Yp9vKV+KTVJTsqEwFCvDWpg5M/taMPJ1xppOvFG87pH7
 MFAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=8L82QjxMFG+r7QSsdjzTxfz9BqpiVnaUpK+324xJ45o=;
 b=KOjvXg6mZ51Kh8x+1e7LYEgpgR1dpZxx28FYZIum4IYfMUmicu2d991TDwAGZfBZ/q
 9wXI0gT1/TuOdP9GjEGZyHorm4ld1B5UG82Yckb7sRVUwA6pxPEGwVY9yBpQy517QQhM
 4UvObn7z4GWh8AEcBxJ93Pji62X0XazGpZlJPm0+xybA825g1G7mAhaQYqipMVnMxAFl
 uwyZT+puCYDIqBRlPwjlnsoVKF58MkwzpmWs+iCKN9o5gcwHlRpDv0gP43ll1zNkypHQ
 LyKiKlYoM75f1RrVMCGKeaxtbhZ2HZeJxktzFo1rL/WL+bNstT3sl+Te15fB6DmiYb4S
 fWtA==
X-Gm-Message-State: AOAM530nhKeSru92I181cHYdunaRNZQa5/FMs4aR841UQTEx19FQC0V1
 R6azWBqrCpGJItYXMhEf8tYNRRS03PhrccDu03E0Jg==
X-Google-Smtp-Source: ABdhPJx1VUYEvitmxLWOydKL99dOpXcnBPMRcX+FVk/fF9o/nqN8xeAbbK0V+dWHQlFYCOYOHNrS5SDijBDnSR1H8x4=
X-Received: by 2002:a17:906:86c3:: with SMTP id
 j3mr27448642ejy.493.1602484997186; 
 Sun, 11 Oct 2020 23:43:17 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <10f91a367ec4fcdea7fc3f086de3f5f13a4a7436.1602431034.git.yifeifz2@illinois.edu>
In-Reply-To: <10f91a367ec4fcdea7fc3f086de3f5f13a4a7436.1602431034.git.yifeifz2@illinois.edu>
Date: Mon, 12 Oct 2020 08:42:50 +0200
Message-ID: <CAG48ez0fcG=+tpzqNNKvK=+NS25z4zTN55sUhECRGAfBrjhuQQ@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 1/5] seccomp/cache: Lookup syscall allowlist
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

On Sun, Oct 11, 2020 at 5:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
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
> When only one architecture exists, the check against architecture
> number is skipped, suggested by Kees Cook [7].
>
> [1] https://lore.kernel.org/linux-security-module/c22a6c3cefc2412cad00ae14c1371711@huawei.com/T/
> [2] https://lore.kernel.org/lkml/202005181120.971232B7B@keescook/T/
> [3] https://github.com/seccomp/libseccomp/issues/116
> [4] https://github.com/moby/moby/blob/ae0ef82b90356ac613f329a8ef5ee42ca923417d/profiles/seccomp/default.json
> [5] https://github.com/systemd/systemd/blob/6743a1caf4037f03dc51a1277855018e4ab61957/src/shared/seccomp-util.c#L270
> [6] Draco: Architectural and Operating System Support for System Call Security
>     https://tianyin.github.io/pub/draco.pdf, MICRO-53, Oct. 2020
> [7] https://lore.kernel.org/bpf/202010091614.8BB0EB64@keescook/
>
> Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

Reviewed-by: Jann Horn <jannh@google.com>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
