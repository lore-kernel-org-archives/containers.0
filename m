Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFB81C433E0
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:42 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8B40F64E61
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B40F64E61
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 3D47D41566;
	Thu, 18 Mar 2021 05:17:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9KPbZDUkvuXQ; Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 4BCF64308E;
	Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 300D0C000B;
	Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DE57FC0001
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id D59786065F
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cNdKKMy6bpzs
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:39 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qt1-x82b.google.com (mail-qt1-x82b.google.com
 [IPv6:2607:f8b0:4864:20::82b])
 by smtp3.osuosl.org (Postfix) with ESMTPS id F21B66063C
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:38 +0000 (UTC)
Received: by mail-qt1-x82b.google.com with SMTP id m7so3195127qtq.11
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Mar 2021 22:17:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=dvne1Wiq64R4j+AonMhFQvYnH0536sN6z3oij4WU7oI=;
 b=BoUqbf3cZLg3qFUwWWqEUwJVuQOHaZQ7m0KpH72xR4G9zVv6ZTGyXH/5BAO5o/PNx4
 ujzaI6M7W0Ro92j3FgNhqeqKpgu9IKTEzLYeb6owKJxDs1hAw1pYiVAzOUG4acdrS6dq
 GK3pZumXBKM72LJ+iA54H6g8QJo3yKkXDVI7I=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=dvne1Wiq64R4j+AonMhFQvYnH0536sN6z3oij4WU7oI=;
 b=VxZizEnFrZEF6RrJZjv0NSs3svVHkctKJdl+ECf3vCYR4t8NK/UqOuTLaGqAJtFyiI
 9KUQgIF4X7DRwga0jD/fH+TuoNs+iC8cUw9VZcK6oUChVmujS1EPRaCnaFz+atxER1xC
 1w5BMyeyjjEHk2aV1RAfZuughoAuGnUAaMcivyFn90xlRHl5Vx0BZmQkCNGPW57mQbor
 m5N/GBV2BisvLOQnOI+779REZGKVKVDAymQi/+Q3GcoBy+tlgc4GFXS3c+b5RLMxzPrj
 XTxyNtRCVYGhQm+fcv2RSwDlRIHhjr44dj2hyobDrX2LKI+K/ueHacHRoVRSgSNFXCMG
 3vNg==
X-Gm-Message-State: AOAM533cQhE2P8xjIXf8fqCMrz0H/cnuKmmVFSPb/wjajW9Z2PqYY49K
 qLK3+7HwdRf4Q8ZBxPk5ZXwYGw==
X-Google-Smtp-Source: ABdhPJwytlGS/bDJZFsU53lfvc4ZqkgTL2PoYKatFygd5a8aIbB0TnGDRoS71WcXBoF7akK9D6rtnQ==
X-Received: by 2002:ac8:3a42:: with SMTP id w60mr2244046qte.307.1616044657380; 
 Wed, 17 Mar 2021 22:17:37 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id m16sm937852qkm.100.2021.03.17.22.17.35
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 17 Mar 2021 22:17:36 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH 0/5] Handle seccomp notification preemption
Date: Wed, 17 Mar 2021 22:17:28 -0700
Message-Id: <20210318051733.2544-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>
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

It also follows up on the original proposal from Tycho[2] to allow
for adding an FD and returning that value atomically.

Changes since v1[1]:
 * Fix some documentation
 * Add Rata's patches to allow for direct return from addfd

[1]: https://lore.kernel.org/lkml/20210220090502.7202-1-sargun@sargun.me/
[2]: https://lore.kernel.org/lkml/202012011322.26DCBC64F2@keescook/

Rodrigo Campos (1):
  seccomp: Support atomic "addfd + send reply"

Sargun Dhillon (4):
  seccomp: Refactor notification handler to prepare for new semantics
  seccomp: Add wait_killable semantic to seccomp user notifier
  selftests/seccomp: Add test for wait killable notifier
  selftests/seccomp: Add test for atomic addfd+send

 .../userspace-api/seccomp_filter.rst          |  15 +-
 include/uapi/linux/seccomp.h                  |   4 +
 kernel/seccomp.c                              | 129 ++++++++++++++----
 tools/testing/selftests/seccomp/seccomp_bpf.c | 102 ++++++++++++++
 4 files changed, 220 insertions(+), 30 deletions(-)

-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
