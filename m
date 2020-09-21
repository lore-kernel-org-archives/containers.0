Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CA56C47095
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:16:38 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A8212216C4
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 19:16:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="tewFT15A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8212216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2627D2034C;
	Mon, 21 Sep 2020 19:16:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8EFg9+W81V+9; Mon, 21 Sep 2020 19:16:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D978820134;
	Mon, 21 Sep 2020 19:16:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C9C4CC0889;
	Mon, 21 Sep 2020 19:16:35 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A5EE8C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:16:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8E0468708A
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:16:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ngV+PqBRR7+N
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:16:33 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ua1-f66.google.com (mail-ua1-f66.google.com
 [209.85.222.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 9383F87084
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 19:16:33 +0000 (UTC)
Received: by mail-ua1-f66.google.com with SMTP id d18so4688131uav.4
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 12:16:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=ZCDaY+bkm/0dH12hWKBLXs8sFNuKqvKh9NzTaSkJTSw=;
 b=tewFT15AsEzpuKyvlpTu5R3peD/3EkklLECjakR0tkxwO97yjiKdU4IH4tHN3hhyD3
 8El1/BBXDcgFynjD5Kh8iAEB+581gGhRIWK6+0fU9rr/PSBeEehjECcdkFZ+PIDmLLYl
 rEsk22wPgoyg7d/rLBTu5OZbJ+83zzMdRdOkhV5mdx6yiZ6RDpgvtKkDbn27HzYH4KX6
 WHeM7BWTRstoznGogcI9Q3044Bc3qApw7s01eS9aSlWrxMQbYQvx7kZA3i3rBQVc7Gzd
 Mb9X9iaZrpufnlQbS5KEFq1UjzhfD9zw9kXXRe9/6Pl6JUGHl0QpX6fnPrFE3jRHwtNl
 0cUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=ZCDaY+bkm/0dH12hWKBLXs8sFNuKqvKh9NzTaSkJTSw=;
 b=I1QWq4nOyvsFhl3fYiX4x1HCntlcGh5LldVgnmJdQrSKAqsp6VzAa+sq7IbRsAr6Nt
 o9hl0pJ7531yWex6O0emTtssqF+MkytprGfps1cmL2QbrgL+YrDX73Fbatkdz+0hUiAH
 izE8h24bV4NIOIqnrAlgvBnaFJu/sXNTnxBMpNF32aKVTSkYk4kazRlzmdc5NTjephBu
 GX6m/nFSRfp2s561I++3VkXoBENGjtJSOd2ZSMQbJ3ld6lEQ/sC5HBPHzuCfysL2H0Uf
 TIyluUsDTv0GU0+Zja3yf1lcfOVYmea61tai00Dj35KuY9fW78ikzZgo3ti22O5eaOqL
 Hz2Q==
X-Gm-Message-State: AOAM531lMy3qmNPQVD7FbO7BNuBkYDuHHZtdJ1Zp7IVGdeOiv3QELebE
 w3H0nBBBxjbulpJtSvZelOzcqsTqOpgGfQ8Hll8XIg==
X-Google-Smtp-Source: ABdhPJwRXYKVMGaY5ggPVk6CztjQIvkE7mOrDoQPqHVdweEFScrXaPDOm3pNYCPRx6yJ5PkBeUlVbM6Ka8GeQRpYGt0=
X-Received: by 2002:ab0:1e84:: with SMTP id o4mr1209850uak.74.1600715792227;
 Mon, 21 Sep 2020 12:16:32 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
In-Reply-To: <cover.1600661418.git.yifeifz2@illinois.edu>
Date: Mon, 21 Sep 2020 21:16:06 +0200
Message-ID: <CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
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
> This series adds a bitmap to cache seccomp filter results if the
> result permits a syscall and is indepenent of syscall arguments.
> This visibly decreases seccomp overhead for most common seccomp
> filters with very little memory footprint.

It would be really nice if, based on this, we could have a new entry
in procfs that has one line per entry in each syscall table. Maybe
something that looks vaguely like:

X86_64 0 (read): ALLOW
X86_64 1 (write): ALLOW
X86_64 2 (open): ERRNO -1
X86_64 3 (close): ALLOW
X86_64 4 (stat): <argument-dependent>
[...]
I386 0 (restart_syscall): ALLOW
I386 1 (exit): ALLOW
I386 2 (fork): KILL
[...]

This would be useful both for inspectability (at the moment it's
pretty hard to figure out what seccomp rules really apply to a given
task) and for testing (so that we could easily write unit tests to
verify that the bitmap calculation works as expected).

But if you don't want to implement that right now, we can do that at a
later point - while it would be nice for making it easier to write
tests for this functionality, I don't see it as a blocker.


> The overhead of running Seccomp filters has been part of some past
> discussions [1][2][3]. Oftentimes, the filters have a large number
> of instructions that check syscall numbers one by one and jump based
> on that. Some users chain BPF filters which further enlarge the
> overhead. A recent work [6] comprehensively measures the Seccomp
> overhead and shows that the overhead is non-negligible and has a
> non-trivial impact on application performance.
>
> We propose SECCOMP_CACHE, a cache-based solution to minimize the
> Seccomp overhead. The basic idea is to cache the result of each
> syscall check to save the subsequent overhead of executing the
> filters. This is feasible, because the check in Seccomp is stateless.
> The checking results of the same syscall ID and argument remains
> the same.
>
> We observed some common filters, such as docker's [4] or
> systemd's [5], will make most decisions based only on the syscall
> numbers, and as past discussions considered, a bitmap where each bit
> represents a syscall makes most sense for these filters.
[...]
> Statically analyzing BPF bytecode to see if each syscall is going to
> always land in allow or reject is more of a rabbit hole, especially
> there is no current in-kernel infrastructure to enumerate all the
> possible architecture numbers for a given machine.

You could add that though. Or if you think that that's too much work,
you could just do it for x86 and arm64 and then use a Kconfig
dependency to limit this to those architectures for now.

> So rather than
> doing that, we propose to cache the results after the BPF filters are
> run.

Please don't add extra complexity just to work around a limitation in
existing code if you could instead remove that limitation in existing
code. Otherwise, code will become unnecessarily hard to understand and
inefficient.

You could let struct seccomp_filter contain three bitmasks - one for
the "native" architecture and up to two for "compat" architectures
(gated on some Kconfig flag).

alpha has 1 architecture numbers, arc has 1 (per build config), arm
has 1, arm64 has 2, c6x has 1 (per build config), csky has 1, h8300
has 1, hexagon has 1, ia64 has 1, m68k has 1, microblaze has 1, mips
has 3 (per build config), nds32 has 1 (per build config), nios2 has 1,
openrisc has 1, parisc has 2, powerpc has 2 (per build config), riscv
has 1 (per build config), s390 has 2, sh has 1 (per build config),
sparc has 2, x86 has 2, xtensa has 1.

> And since there are filters like docker's who will check
> arguments of some syscalls, but not all or none of the syscalls, when
> a filter is loaded we analyze it to find whether each syscall is
> cacheable (does not access syscall argument or instruction pointer) by
> following its control flow graph, and store the result for each filter
> in a bitmap. Changes to architecture number or the filter are expected
> to be rare and simply cause the cache to be cleared. This solution
> shall be fully transparent to userspace.

Caching whether a given syscall number has fixed per-architecture
results across all architectures is a pretty gross hack, please don't.



> Ongoing work is to further support arguments with fast hash table
> lookups. We are investigating the performance of doing so [6], and how
> to best integrate with the existing seccomp infrastructure.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
