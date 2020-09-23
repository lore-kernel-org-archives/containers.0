Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B738C4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AEB3320BED
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="d23i7lGk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEB3320BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 6BD7327A6E;
	Wed, 23 Sep 2020 23:29:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p7UTwtEjjuQh; Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 8C19C275A6;
	Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 76B5EC0889;
	Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 19C13C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 0F32E873CA
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vjKxpdvUDnSQ
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com
 [209.85.214.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 308AF84E27
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id bb1so595231plb.2
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:29:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=KnYowXpX9ek9m66e/Htp70CeCYZxw6hk1IiAy6Kl5rQ=;
 b=d23i7lGk81zKYyusnqeg3ju3nwOqSpKeXXqEXfHcMkudEXxh6GYe4vsSAUdXG2Kmda
 6xUIDq6pAnsBhq4Uwb61Qv+JVTAqLdlu5ggSiDwArbU7/fQlOyXMiVKgIeSUdEW9+pdY
 Yl9rNSLOlhuM/5SpwR5+gAAFa1s7kNPrF+Xkg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=KnYowXpX9ek9m66e/Htp70CeCYZxw6hk1IiAy6Kl5rQ=;
 b=uVKdyMb6MeHoxGX/7H419mQr503sRPGLjDKap0AssHfODwVorDsjVXpmsfrV5+wpOC
 nWP/jx+sKGBafjJTUsLBluhRTQNzYVw0ux6LArfuWEEvS5O1GLApOC20msz1zmfeh0F5
 OcaYNfYLzntqnSX5zG4DWEOTPEkwpnTvmHpWCIb362RVp1yYQfn5pvOgEVLWOEwUaw//
 1K305NsVEBz87S8v7tLXxvcVfg2R99svRucek3E/80ham+5P9c2EN8E2XcrHBidaA+9F
 OsPAX6wgNdPEuEOu6fu3YFUmoD7f+rVsPRX+5xeU771qDypSU5IiIXEqbud/ykr47WEK
 Ncjg==
X-Gm-Message-State: AOAM532EtV8hbC4w2y9Ucea6zn/kgiu/ALdxk1WjHb5IqWitUYHNxOip
 dPKGx0kAPlUhXmPBiwFU/urQuw==
X-Google-Smtp-Source: ABdhPJyayNyPvuS62S2fNWA1VUxrMaI1OAUF1FMKlIQFQYU1vC9AcNWm/orb6K3zoxr7u7I4hLjRvQ==
X-Received: by 2002:a17:902:8689:b029:d1:9bf7:230a with SMTP id
 g9-20020a1709028689b02900d19bf7230amr2038591plo.22.1600903768727; 
 Wed, 23 Sep 2020 16:29:28 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id y1sm836499pgy.0.2020.09.23.16.29.26
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 16:29:26 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
Date: Wed, 23 Sep 2020 16:29:17 -0700
Message-Id: <20200923232923.3142503-1-keescook@chromium.org>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 linux-api@vger.kernel.org, containers@lists.linux-foundation.org,
 bpf@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 linux-kernel@vger.kernel.org
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

rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
v1:
- rebase to for-next/seccomp
- finish X86_X32 support for both pinning and bitmaps
- replace TLB magic with Jann's emulator
- add JSET insn

TODO:
- add ALU|AND insn
- significantly more testing

Hi,

This is a refresh of my earlier constant action bitmap series. It looks
like the RFC was missed on the container list, so I've CCed it now. :)
I'd like to work from this series, as it handles the multi-architecture
stuff.

Repeating the commit log from patch 3:

    seccomp: Implement constant action bitmaps
    
    One of the most common pain points with seccomp filters has been dealing
    with the overhead of processing the filters, especially for "always allow"
    or "always reject" cases. While BPF is extremely fast[1], it will always
    have overhead associated with it. Additionally, due to seccomp's design,
    filters are layered, which means processing time goes up as the number
    of filters attached goes up.
    
    In the past, efforts have been focused on making filter execution complete
    in a shorter amount of time. For example, filters were rewritten from
    using linear if/then/else syscall search to using balanced binary trees,
    or moving tests for syscalls common to the process's workload to the
    front of the filter. However, there are limits to this, especially when
    some processes are dealing with tens of filters[2], or when some
    architectures have a less efficient BPF engine[3].
    
    The most common use of seccomp, constructing syscall block/allow-lists,
    where syscalls that are always allowed or always rejected (without regard
    to any arguments), also tends to produce the most pathological runtime
    problems, in that a large number of syscall checks in the filter need
    to be performed to come to a determination.
    
    In order to optimize these cases from O(n) to O(1), seccomp can
    use bitmaps to immediately determine the desired action. A critical
    observation in the prior paragraph bears repeating: the common case for
    syscall tests do not check arguments. For any given filter, there is a
    constant mapping from the combination of architecture and syscall to the
    seccomp action result. (For kernels/architectures without CONFIG_COMPAT,
    there is a single architecture.). As such, it is possible to construct
    a mapping of arch/syscall to action, which can be updated as new filters
    are attached to a process.
    
    In order to build this mapping at filter attach time, each filter is
    executed for every syscall (under each possible architecture), and
    checked for any accesses of struct seccomp_data that are not the "arch"
    nor "nr" (syscall) members. If only "arch" and "nr" are examined, then
    there is a constant mapping for that syscall, and bitmaps can be updated
    accordingly. If any accesses happen outside of those struct members,
    seccomp must not bypass filter execution for that syscall, since program
    state will be used to determine filter action result. (This logic comes
    in the next patch.)
    
    [1] https://lore.kernel.org/bpf/20200531171915.wsxvdjeetmhpsdv2@ast-mbp.dhcp.thefacebook.com/
    [2] https://lore.kernel.org/bpf/20200601101137.GA121847@gardel-login/
    [3] https://lore.kernel.org/bpf/717a06e7f35740ccb4c70470ec70fb2f@huawei.com/


Thanks!

-Kees


Kees Cook (6):
  seccomp: Introduce SECCOMP_PIN_ARCHITECTURE
  x86: Enable seccomp architecture tracking
  seccomp: Implement constant action bitmaps
  seccomp: Emulate basic filters for constant action results
  selftests/seccomp: Compare bitmap vs filter overhead
  [DEBUG] seccomp: Report bitmap coverage ranges

 arch/x86/include/asm/seccomp.h                |  14 +
 include/linux/seccomp.h                       |  27 +
 include/uapi/linux/seccomp.h                  |   1 +
 kernel/seccomp.c                              | 473 +++++++++++++++++-
 net/core/filter.c                             |   3 +-
 .../selftests/seccomp/seccomp_benchmark.c     | 151 +++++-
 tools/testing/selftests/seccomp/seccomp_bpf.c |  33 ++
 tools/testing/selftests/seccomp/settings      |   2 +-
 8 files changed, 674 insertions(+), 30 deletions(-)

-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
