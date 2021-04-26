Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B1D2C433B4
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 632A7613BC
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 632A7613BC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 0306B40160;
	Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id REN1G613sNjA; Mon, 26 Apr 2021 18:06:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 281B7400C7;
	Mon, 26 Apr 2021 18:06:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 01571C000E;
	Mon, 26 Apr 2021 18:06:18 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BE7E8C000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 9F3F840407
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NvfusM4oE8Sk
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:15 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pl1-x62c.google.com (mail-pl1-x62c.google.com
 [IPv6:2607:f8b0:4864:20::62c])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 40844403ED
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:14 +0000 (UTC)
Received: by mail-pl1-x62c.google.com with SMTP id s20so13534984plr.13
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 11:06:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=crrXl04Pmuu3hnq0cq7H9ljH1hJvjphFD3Ivc9bSiG0=;
 b=KkujWiFEtrvDAwAIA9yFog0WvpXFYbxTqf2G6PUO4jUn/BaScPI3Tya5PV1L/3Cphv
 X1quUztMcdUAqr1aNZoIlFF8shCRsL5iSXKoT8rL4PBYQhGnkwuUnww3FRvMfW4iIBNf
 yqRb+3jdPBjRhm2gSJJjyoJKi8vUJjO8Jgrn8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=crrXl04Pmuu3hnq0cq7H9ljH1hJvjphFD3Ivc9bSiG0=;
 b=uAVNJpIRWMbSy/5Xt93AfKN3sjRqh/OwlCOTaz78x3O8tGu8pK3Nu27YqAztLs8NvS
 HuVff2+eulKvDcTx0MuVuJYRYhT9tPRNfrKhX62LRgFhHWaSMXF/pj64GOgbcN4G4fLc
 bTQ/ZGvcCi/mJ6cfTNfqWfD3bMlL4MvfuyJca3B3O85LN6WqPA230BzdlkSReJyq5lPM
 l38hNbeIwusGvzf9YJT9XKYi5tcQtf53ArrRVyjTUhWlJCKvFWUVeBENLjmfb1J0yHa4
 e4y6rO6qxShky8bFjFsWLeFyF9tD+3mAcg0xlZTox0mbWssCe+XWI1tC6ePvPawRIKfx
 mllA==
X-Gm-Message-State: AOAM5304ZUj1pC6gRtCc6+8b4tlTEc2jXJwGqgQAjlxDIYp+v0bgS5s1
 P1jot+uTPxWS3a4Yn3hN0itFrg==
X-Google-Smtp-Source: ABdhPJy/Na1du6oypewjuRbextqXDjv9/n/HngVaKUqVIV9ZTBLt/a/dxAeeBWwA43q5YE2/pPc8cg==
X-Received: by 2002:a17:90b:3754:: with SMTP id
 ne20mr4999359pjb.39.1619460374084; 
 Mon, 26 Apr 2021 11:06:14 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id j7sm326835pfd.129.2021.04.26.11.06.12
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 26 Apr 2021 11:06:13 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Rodrigo Campos <rodrigo@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
Subject: [PATCH RESEND 0/5] Handle seccomp notification preemption
Date: Mon, 26 Apr 2021 11:06:05 -0700
Message-Id: <20210426180610.2363-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Andy Lutomirski <luto@amacapital.net>, Alban Crequy <alban@kinvolk.io>
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

This patchset addresses a race condition we've dealt with recently with
seccomp. Specifically programs interrupting syscalls while they're in
progress. This was exacerbated by Golang's recent adoption of "async
preemption", in which they try to interrupt any syscall that's been
running for more than 10ms during GC. During certain syscalls, it's
non-trivial to write them in a reetrant manner in userspace (mount).

This has a couple semantic changes, and relaxes a check on seccomp_data, and
changes the semantics with ordering of how addfd and notification replies
in the supervisor are handled.

I'm resending after rebasing and testing on v5.12. It turns out this change
also fixed a bug Rodrigo found that could occur with addfd around certain
race conditions[2].

It also follows up on the original proposal from Tycho[3] to allow
for adding an FD and returning that value atomically.

Changes since v1[1]:
 * Fix some documentation
 * Add Rata's patches to allow for direct return from addfd

[1]: https://lore.kernel.org/lkml/20210220090502.7202-1-sargun@sargun.me/
[2]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/
[3]: https://lore.kernel.org/lkml/202012011322.26DCBC64F2@keescook/


Rodrigo Campos (2):
  seccomp: Support atomic "addfd + send reply"
  selftests/seccomp: Add test for atomic addfd+send

Sargun Dhillon (3):
  seccomp: Refactor notification handler to prepare for new semantics
  seccomp: Add wait_killable semantic to seccomp user notifier
  selftests/seccomp: Add test for wait killable notifier

 .../userspace-api/seccomp_filter.rst          |  15 +-
 include/uapi/linux/seccomp.h                  |   4 +
 kernel/seccomp.c                              | 129 ++++++++++++++----
 tools/testing/selftests/seccomp/seccomp_bpf.c | 102 ++++++++++++++
 4 files changed, 220 insertions(+), 30 deletions(-)


base-commit: 9f4ad9e425a1d3b6a34617b8ea226d56a119a717
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
