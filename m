Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3402BC43463
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 05:35:47 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A69222075E
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 05:35:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b1vMaTMj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A69222075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1BC5A204E4;
	Mon, 21 Sep 2020 05:35:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XefkoQH4WoIE; Mon, 21 Sep 2020 05:35:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id EFDC0204DB;
	Mon, 21 Sep 2020 05:35:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C09A6C0859;
	Mon, 21 Sep 2020 05:35:42 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3FB58C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 00C988562D
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2ewyunMF3AgH
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:40 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com
 [209.85.166.65])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0E5DA8561D
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:40 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id r9so14171862ioa.2
 for <containers@lists.linux-foundation.org>;
 Sun, 20 Sep 2020 22:35:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=LkkNGOg6Wfx51qxpVQ0Q7bNOsLXnpcDTYAMaP869ejY=;
 b=b1vMaTMjETLIMlAcq8T0D5XHuAkym0hOm1M2MQ9ItbLsjPj+qeDQf/u3ZcDmxDuDm7
 n03sYOZL9KYiGj9uvRrZgX7dkw58a1KD23xmYyRJYnyqnse7+g3f9/0Af25+NJOGwC8H
 t86dDfrsh3RQIQ7y4YZE4AaBP1E59noeHjGNLOmuCMNX4MCyL30/6asc6rK/GtnMb99k
 FWQ7V0JSEm0f8gUXHnoInkBBRtiwS5MC1+IJF+qB2ckDtD4HhLfI9+BiPUBEbRLRMy/2
 nOE9VcG/RSE2YIwRPZBw4u1dbew6ULy9JJNtZJ08JTEb1Is2kERWHJF5uWfH6Cc2lGcT
 r5zA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=LkkNGOg6Wfx51qxpVQ0Q7bNOsLXnpcDTYAMaP869ejY=;
 b=IbZvxxAlXjbWsnilL/qJywHOrMrS3Hp9vTUhLdrEwosI4sG7dZRpgA4NREEV7Jmhwo
 k8q2qR6EiMy6jeoJYPNMHRNGhyVgHdjx5bN2zVlf8Z9R0z9MTyqgqIYX9RdwbavUMkDo
 j/f2K+ipUaqKlkBuJVXXcKNQxxRl82Kb94b8vKMLLonQKAggeXOZpTZFGXSVaJ3KqORr
 qFIrhjbV2S89SX3SOltf6BdV/EzugHzX306yb6a9jOnhRpXXI/JQ3X8TU9TSOcHLKOb2
 kp/A4D5U5c7T49z3P5ThbC+JiLorN8gcycMoWm02KAFvfCkoR57piCrDAG2EHNoBIKXk
 /LIQ==
X-Gm-Message-State: AOAM5313rTqSdjW9NGRu56DwivjDas3wpJmODz9+n+Y+HL1EJP+ZmdA9
 GYf617jJbN4LLaKkXySUvzSkCYFE2hYYFA==
X-Google-Smtp-Source: ABdhPJz+uSWfbpjoJhc4UfQrMMIG0oh9ZBikomG3W2B6uyOBCZ3p/Y920DR1cYH57ZlLDD2s6FuqJA==
X-Received: by 2002:a6b:610d:: with SMTP id v13mr34989417iob.189.1600666538970; 
 Sun, 20 Sep 2020 22:35:38 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id i9sm6644962ilj.71.2020.09.20.22.35.37
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 20 Sep 2020 22:35:38 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of arg-independent
 filter results that allow syscalls
Date: Mon, 21 Sep 2020 00:35:16 -0500
Message-Id: <cover.1600661418.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Valentin Rothberg <vrothber@redhat.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Josep Torrellas <torrella@illinois.edu>,
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

From: YiFei Zhu <yifeifz2@illinois.edu>

This series adds a bitmap to cache seccomp filter results if the
result permits a syscall and is indepenent of syscall arguments.
This visibly decreases seccomp overhead for most common seccomp
filters with very little memory footprint.

The overhead of running Seccomp filters has been part of some past
discussions [1][2][3]. Oftentimes, the filters have a large number
of instructions that check syscall numbers one by one and jump based
on that. Some users chain BPF filters which further enlarge the
overhead. A recent work [6] comprehensively measures the Seccomp
overhead and shows that the overhead is non-negligible and has a
non-trivial impact on application performance.

We propose SECCOMP_CACHE, a cache-based solution to minimize the
Seccomp overhead. The basic idea is to cache the result of each
syscall check to save the subsequent overhead of executing the
filters. This is feasible, because the check in Seccomp is stateless.
The checking results of the same syscall ID and argument remains
the same.

We observed some common filters, such as docker's [4] or
systemd's [5], will make most decisions based only on the syscall
numbers, and as past discussions considered, a bitmap where each bit
represents a syscall makes most sense for these filters.

In the past Kees proposed [2] to have an "add this syscall to the
reject bitmask". It is indeed much easier to securely make a reject
accelerator to pre-filter syscalls before passing to the BPF
filters, considering it could only strengthen the security provided
by the filter. However, ultimately, filter rejections are an
exceptional / rare case. Here, instead of accelerating what is
rejected, we accelerate what is allowed. In order not to compromise
the security rules the BPF filters defined, any accept-side
accelerator must complement the BPF filters rather than replacing them.

Statically analyzing BPF bytecode to see if each syscall is going to
always land in allow or reject is more of a rabbit hole, especially
there is no current in-kernel infrastructure to enumerate all the
possible architecture numbers for a given machine. So rather than
doing that, we propose to cache the results after the BPF filters are
run. And since there are filters like docker's who will check
arguments of some syscalls, but not all or none of the syscalls, when
a filter is loaded we analyze it to find whether each syscall is
cacheable (does not access syscall argument or instruction pointer) by
following its control flow graph, and store the result for each filter
in a bitmap. Changes to architecture number or the filter are expected
to be rare and simply cause the cache to be cleared. This solution
shall be fully transparent to userspace.

Ongoing work is to further support arguments with fast hash table
lookups. We are investigating the performance of doing so [6], and how
to best integrate with the existing seccomp infrastructure.

We have done some benchmarks with patch applied against bpf-next
commit 2e80be60c465 ("libbpf: Fix compilation warnings for 64-bit printf args").

Me, in qemu-kvm x86_64 VM, on Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz,
average results:

Without cache, seccomp_benchmark:
  Current BPF sysctl settings:
  net.core.bpf_jit_enable = 1
  net.core.bpf_jit_harden = 0
  Calibrating sample size for 15 seconds worth of syscalls ...
  Benchmarking 23486415 syscalls...
  16.079642020 - 1.013345439 = 15066296581 (15.1s)
  getpid native: 641 ns
  32.080237410 - 16.080763500 = 15999473910 (16.0s)
  getpid RET_ALLOW 1 filter: 681 ns
  48.609461618 - 32.081296173 = 16528165445 (16.5s)
  getpid RET_ALLOW 2 filters: 703 ns
  Estimated total seccomp overhead for 1 filter: 40 ns
  Estimated total seccomp overhead for 2 filters: 62 ns
  Estimated seccomp per-filter overhead: 22 ns
  Estimated seccomp entry overhead: 18 ns

With cache:
  Current BPF sysctl settings:
  net.core.bpf_jit_enable = 1
  net.core.bpf_jit_harden = 0
  Calibrating sample size for 15 seconds worth of syscalls ...
  Benchmarking 23486415 syscalls...
  16.059512499 - 1.014108434 = 15045404065 (15.0s)
  getpid native: 640 ns
  31.651075934 - 16.060637323 = 15590438611 (15.6s)
  getpid RET_ALLOW 1 filter: 663 ns
  47.367316169 - 31.652302661 = 15715013508 (15.7s)
  getpid RET_ALLOW 2 filters: 669 ns
  Estimated total seccomp overhead for 1 filter: 23 ns
  Estimated total seccomp overhead for 2 filters: 29 ns
  Estimated seccomp per-filter overhead: 6 ns
  Estimated seccomp entry overhead: 17 ns

Depending on the run estimated seccomp overhead for 2 filters can be
less than seccomp overhead for 1 filter, resulting in underflow to
estimated seccomp per-filter overhead:
  Estimated total seccomp overhead for 1 filter: 27 ns
  Estimated total seccomp overhead for 2 filters: 21 ns
  Estimated seccomp per-filter overhead: 18446744073709551610 ns
  Estimated seccomp entry overhead: 33 ns

Jack Chen has also run some benchmarks on a bare metal
Intel(R) Xeon(R) CPU E3-1240 v3 @ 3.40GHz, with side channel
mitigations off (spec_store_bypass_disable=off spectre_v2=off mds=off
pti=off l1tf=off), with BPF JIT on and docker default profile,
and reported:

  unixbench syscall mix (https://github.com/kdlucas/byte-unixbench)
  unconfined:      33295685
  docker default:         20661056  60%
  docker default + cache: 25719937  30%

Patch 1 introduces the static analyzer to check for a given filter,
whether the CFG loads the syscall arguments for each syscall number.

Patch 2 implements the bitmap cache.

[1] https://lore.kernel.org/linux-security-module/c22a6c3cefc2412cad00ae14c1371711@huawei.com/T/
[2] https://lore.kernel.org/lkml/202005181120.971232B7B@keescook/T/
[3] https://github.com/seccomp/libseccomp/issues/116
[4] https://github.com/moby/moby/blob/ae0ef82b90356ac613f329a8ef5ee42ca923417d/profiles/seccomp/default.json
[5] https://github.com/systemd/systemd/blob/6743a1caf4037f03dc51a1277855018e4ab61957/src/shared/seccomp-util.c#L270
[6] Draco: Architectural and Operating System Support for System Call Security
    https://tianyin.github.io/pub/draco.pdf, MICRO-53, Oct. 2020

YiFei Zhu (2):
  seccomp/cache: Add "emulator" to check if filter is arg-dependent
  seccomp/cache: Cache filter results that allow syscalls

 arch/x86/Kconfig        |  27 +++
 include/linux/seccomp.h |  22 +++
 kernel/seccomp.c        | 400 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 446 insertions(+), 3 deletions(-)

--
2.28.0
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
