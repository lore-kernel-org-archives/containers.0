Return-Path: <SRS0=3V/s=HW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A858C433E0
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:34:47 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 69C1D64DEC
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:34:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69C1D64DEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 234D8834E8
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:34:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5_Z0GdRCICL0 for <containers@archiver.kernel.org>;
	Sat, 20 Feb 2021 09:34:44 +0000 (UTC)
Received: by smtp1.osuosl.org (Postfix, from userid 1001)
	id B48DC8354D; Sat, 20 Feb 2021 09:34:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 2098682FD7;
	Sat, 20 Feb 2021 09:34:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D8415C000A;
	Sat, 20 Feb 2021 09:34:42 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C4887C0001
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:34:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id BCBA982BED
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:34:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id puzMT9TPJz22
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:34:40 +0000 (UTC)
Received: by smtp1.osuosl.org (Postfix, from userid 1001)
 id 0008E8333E; Sat, 20 Feb 2021 09:34:39 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com
 [209.85.167.175])
 by smtp1.osuosl.org (Postfix) with ESMTPS id B282B82BED
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:34:38 +0000 (UTC)
Received: by mail-oi1-f175.google.com with SMTP id j5so8700249oie.1
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 01:34:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=Ndod0SKs53DoouSdXHyF0CmTt+j+rMCAZ9tnPJESopM=;
 b=QjB1Nxc4ywJRLTx9HaVrpbljgBRGmnEsfaNukEUqOHjHViUDS2tM3XzMVRJHY7Oe4E
 o5pVmVpAuJUXZT5miqEw6XxVoPPcMfznVLtA5iN/ibuzFLyw45x5zIpqTVaAX27xgodG
 KM+sEifyExnfEF4mzJIlS4kSONlE1hHHtxsK8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=Ndod0SKs53DoouSdXHyF0CmTt+j+rMCAZ9tnPJESopM=;
 b=sv1ndEDgvUDXpbA6HtJfg4m/4sCB/PVx2ew2C/tSYtG8ut87q6nHYh+CtPlQ3B89PK
 W3xNx0t0pgzbf7xy5BAZju7Rto4ZeEo2hLl6J/qrXkrXFQas0ns2fEVl/X6HlIQx7tym
 EAYrCbot89BBUahRAm1FazuXMRwNzCIyRvDKfdRyOo21XKbHSavy0lc+5kSjsQ/rC15T
 eafpvaxxyb7BFk1lJxGJUXvjEsyF7dqAA8ecEJ1SqDUEsjKQCutJZ3d7iZXd2rx20NuE
 MPIZPPLEKVv5sePF9EaCjGjDtrHzjOel6vspcuWq/kjoFeyE4sp2ICS28ePwTlb5zyU8
 XQvg==
X-Gm-Message-State: AOAM5328tbabR/P34jHFL2Zso+7HdgtJMIH+yqm6EQjduQGFXl7Cr6Oc
 V/mxXcDR1siHoiZdtLHVmiSXkfQcOTEIZy0p
X-Google-Smtp-Source: ABdhPJw4zQv/KdqhfaP8jiaNEc7ce9WHZ6hI4p2HSr3DJWVeW1Kxjfa49GF4nYmsLq3DtCJB0mlpbQ==
X-Received: by 2002:a17:90a:2848:: with SMTP id
 p8mr13172691pjf.55.1613811905938; 
 Sat, 20 Feb 2021 01:05:05 -0800 (PST)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id g62sm12226727pgc.32.2021.02.20.01.05.05
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sat, 20 Feb 2021 01:05:05 -0800 (PST)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [RFC PATCH 0/3] Seccomp non-preemptible notifier
Date: Sat, 20 Feb 2021 01:04:59 -0800
Message-Id: <20210220090502.7202-1-sargun@sargun.me>
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

This has a couple semantic changes, and relaxes a check on seccomp_data.
I can deal with these, but this was a first cut. I also expect that the
patch would be squashed down, but it's split out for easier review.

Sargun Dhillon (3):
  seccomp: Refactor notification handler to prepare for new semantics
  seccomp: Add wait_killable semantic to seccomp user notifier
  selftests/seccomp: Add test for wait killable notifier

 include/uapi/linux/seccomp.h                  | 10 +++
 kernel/seccomp.c                              | 63 +++++++++++++------
 tools/testing/selftests/seccomp/seccomp_bpf.c | 60 ++++++++++++++++++
 3 files changed, 114 insertions(+), 19 deletions(-)

-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
