Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAF58C433E0
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:50 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2081964E42
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2081964E42
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id D40D74ECB4;
	Thu, 18 Mar 2021 05:17:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5V3h9rOcutHo; Thu, 18 Mar 2021 05:17:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 8C4F54ECA1;
	Thu, 18 Mar 2021 05:17:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 751ECC000B;
	Thu, 18 Mar 2021 05:17:48 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 90CA6C0014
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:46 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 7145B60680
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WFKkNy-6FnSx
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:45 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qt1-x832.google.com (mail-qt1-x832.google.com
 [IPv6:2607:f8b0:4864:20::832])
 by smtp3.osuosl.org (Postfix) with ESMTPS id B2C3060663
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:45 +0000 (UTC)
Received: by mail-qt1-x832.google.com with SMTP id j7so3221322qtx.5
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Mar 2021 22:17:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=X0lenJHcLasaYBI5lFBTMBv4qon9BxbpynoG3q+hE3g=;
 b=oxJaPnYDKT+7znFR/6BDGPow/x9iKeGlhNvZeYxFyxCFPQZHXYPcDogLe+Rf9ciV9P
 Sald5NV+uvkJtJYGSuvVrB/YszxNzfV2gd3/lXKRkyQXfHjmxWkRHuJsFIFKX62wQJ3b
 2+lz0/J0T71MZzRSzeM3rr9GLPbwbO6aokGSI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=X0lenJHcLasaYBI5lFBTMBv4qon9BxbpynoG3q+hE3g=;
 b=Ki4rjQpr6SDOSIcMT7ZzTcD50AG3OnFxwT+4Zg7dwJsoEEPpiFYnkPfiXoWP2nnW5V
 KQeWRjV80wNcTMprL24HCSkIcD4retGGgruy0cUW0hUpyITHgZEZym6DPJ8e9/DyRZlu
 jp9AeKcbMDV2lclWMRLMIkWvioAB35It2UF8In46wY+0YlKnTl3A4f6utv6biGc5vkug
 crVHvY9/pWNB53kQjBxD5k57DzWYX+w7s3dHqjxY9XTYLThmcBzh4VYb7XCKpgV/Piye
 WYd70eH/nPJK/8w9aSm1GKU/TargYM6aD3/xfqhhNILVKLcz7LjPhwbhxmPIoZ3z3mEw
 mYOw==
X-Gm-Message-State: AOAM5317qmJQrsIEBkFu0O4sRrBIAmVx1h75pV2CLr9MIsKgCpQt2dHc
 QY70pPQMxoovmDaznjhvEX8oyA==
X-Google-Smtp-Source: ABdhPJwGYjEfrpQtVdRRxk7+sO+hOVsV94Gqlg+m+AVLeI8glz8fqp4QxrdN/ybmrfLUXJCg2NGhsA==
X-Received: by 2002:aed:29e5:: with SMTP id o92mr2186045qtd.29.1616044664409; 
 Wed, 17 Mar 2021 22:17:44 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id m16sm937852qkm.100.2021.03.17.22.17.42
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 17 Mar 2021 22:17:43 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH 3/5] selftests/seccomp: Add test for wait killable notifier
Date: Wed, 17 Mar 2021 22:17:31 -0700
Message-Id: <20210318051733.2544-4-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210318051733.2544-1-sargun@sargun.me>
References: <20210318051733.2544-1-sargun@sargun.me>
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

This adds a test for the positive case of the wait killable notifier,
in testing that when the feature is activated the process acts as
expected -- in not terminating on a non-fatal signal, and instead
queueing it up. There is already a test case for normal handlers
and preemption.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 64 +++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 26c72f2b61b1..48ad53030d5a 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -235,6 +235,10 @@ struct seccomp_notif_addfd {
 };
 #endif
 
+#ifndef SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE
+#define SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE	(1UL << 0) /* Prevent task from being interrupted */
+#endif
+
 struct seccomp_notif_addfd_small {
 	__u64 id;
 	char weird[4];
@@ -4139,6 +4143,66 @@ TEST(user_notification_addfd_rlimit)
 	close(memfd);
 }
 
+TEST(user_notification_signal_wait_killable)
+{
+	pid_t pid;
+	long ret;
+	int status, listener, sk_pair[2];
+	struct seccomp_notif req = {
+		.flags = SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE,
+	};
+	struct seccomp_notif_resp resp = {};
+	char c;
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	ASSERT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
+	ASSERT_EQ(fcntl(sk_pair[0], F_SETFL, O_NONBLOCK), 0);
+
+	listener = user_notif_syscall(__NR_gettid,
+				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
+	ASSERT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		close(sk_pair[0]);
+		handled = sk_pair[1];
+		if (signal(SIGUSR1, signal_handler) == SIG_ERR) {
+			perror("signal");
+			exit(1);
+		}
+
+		ret = syscall(__NR_gettid);
+		exit(!(ret == 42));
+	}
+	close(sk_pair[1]);
+
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+	EXPECT_EQ(kill(pid, SIGUSR1), 0);
+	/* Make sure we didn't get a signal */
+	EXPECT_EQ(read(sk_pair[0], &c, 1), -1);
+	/* Make sure the notification is still alive */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_ID_VALID, &req.id), 0);
+
+	resp.id = req.id;
+	resp.error = 0;
+	resp.val = 42;
+
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SEND, &resp), 0);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+	/* Check we eventually received the signal */
+	EXPECT_EQ(read(sk_pair[0], &c, 1), 1);
+}
+
+
 /*
  * TODO:
  * - expand NNP testing
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
