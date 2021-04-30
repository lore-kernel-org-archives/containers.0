Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE43C433B4
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:50 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2909761409
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2909761409
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id DD75B419E7;
	Fri, 30 Apr 2021 20:49:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IcxiYRlX537O; Fri, 30 Apr 2021 20:49:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 8E432418E9;
	Fri, 30 Apr 2021 20:49:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6E7E7C000E;
	Fri, 30 Apr 2021 20:49:48 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1789BC0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id EC20E8468C
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Iuhw-cJ4CEnU
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:46 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qv1-xf34.google.com (mail-qv1-xf34.google.com
 [IPv6:2607:f8b0:4864:20::f34])
 by smtp1.osuosl.org (Postfix) with ESMTPS id E748084686
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:45 +0000 (UTC)
Received: by mail-qv1-xf34.google.com with SMTP id q5so1029080qvv.6
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 13:49:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=kzMcg0H4Ti3qN2qd0lkLHgOrmzJ5Bpqu38goX6MXEPc=;
 b=P5MfRrpnRYvIRyuPilC6J6+aHDkJA6ylxSNBLp+fGyYZgSIllWFqWTOFyX8h19DnJT
 lfhcS/FLCKltizJjkg/dyYnObCBXR8fSY6zlg0R0APfb2+i9NdKRbsvSh89PjIC2IHvK
 lqy9pCmAyDqmRBt+yxlGOSyL5Tmf24TNs4zaI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=kzMcg0H4Ti3qN2qd0lkLHgOrmzJ5Bpqu38goX6MXEPc=;
 b=l7XeXLek1MEQGx0+GrBwIIHRxpb84INmJeK2+ztUYiz22ObqQmzvqh5oVxh0gHUfZV
 N0aZFWQC+AXcLz26wE1jEqG9eDXy1Xlpv6XJpu/eq5dLUkuoOPXd4ETGDCda/qvyei2i
 XEolKsXaoFnQ1hrmLovXBN3WvJi4Zar+ShU5y3u8qL3camvVEDYNK5zXiUWoB5Lc5KN8
 iMuSjq6K5TSDNoQg6aYunCqRXA/gTZocAHgni8qXtk+7i51WNIjFlS6ijZ0q61jU3iCT
 bjDTo+nLzvvQCBvyjSQdhCpNsrkIYetpOnVy7cq9Jv+MeHVN2kRoEuhTauSbYMoFWD0w
 IvmQ==
X-Gm-Message-State: AOAM5325gB6yx5ihXIEDSxNpMf+fUF48zwThwP9A0oSNgzbpzHHkr2DH
 s40+UFoVgtxX+6/KQczqCTPABQ==
X-Google-Smtp-Source: ABdhPJzn7AeJ6ME302gS2sD5Ybn4x5HENWIFhTmfZzeYNLmYbnY7LeKn1P5OemsulHSsoDXUfZcz6w==
X-Received: by 2002:a0c:ebc9:: with SMTP id k9mr7342669qvq.32.1619815784502;
 Fri, 30 Apr 2021 13:49:44 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id z17sm3161960qtf.10.2021.04.30.13.49.42
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 30 Apr 2021 13:49:43 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH v2 0/5] Handle seccomp notification preemption
Date: Fri, 30 Apr 2021 13:49:34 -0700
Message-Id: <20210430204939.5152-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

Changes since v1:
  * Change from a flag, to an ioctl that explicitly sets the killable
    state after reading the notification.
  * Adds some more tests to make sure that fatal signals are handled.

Changes since RFC[1]:
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

 .../userspace-api/seccomp_filter.rst          |  22 +-
 include/uapi/linux/seccomp.h                  |   3 +
 kernel/seccomp.c                              | 146 ++++++++++++--
 tools/testing/selftests/seccomp/seccomp_bpf.c | 190 ++++++++++++++++++
 4 files changed, 335 insertions(+), 26 deletions(-)

-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
