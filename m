Return-Path: <SRS0=3V/s=HW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D67DDC433E0
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:13:26 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8146964ED6
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:13:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8146964ED6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 666B486CB5;
	Sat, 20 Feb 2021 09:13:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nW5_NS4G10Ix; Sat, 20 Feb 2021 09:13:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 94EFC86CAF;
	Sat, 20 Feb 2021 09:13:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7CBE9C000A;
	Sat, 20 Feb 2021 09:13:25 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 70EC7C0001
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:13:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 4A3B46F65F
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:13:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 4prL5yzVkCc7
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:13:23 +0000 (UTC)
Received: by smtp3.osuosl.org (Postfix, from userid 1001)
 id 697F86F637; Sat, 20 Feb 2021 09:13:23 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from mail-pg1-f179.google.com (mail-pg1-f179.google.com
 [209.85.215.179])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 172ED606B8
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:13:03 +0000 (UTC)
Received: by mail-pg1-f179.google.com with SMTP id t25so6928717pga.2
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 01:13:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=8uhnHjYHLCuhTU6M3tfoU1v40Q35VuY6aG3sX6eVDyc=;
 b=oINI3a66W+i5evnFiC1om4CrVR+l4Dpl+FfnJV+aaKdHq3y6KNMlz9d8BHcvismR1o
 TMdbrTK+OIStNUQmh34wgpmb5ZEytU6iiCHDxeYr4f7s5BNeVaTOhgnlSUpnQ8LhceEg
 1NPwYqN7MIAsH1qXtKrPrHXew0IfX4dO9qxL8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=8uhnHjYHLCuhTU6M3tfoU1v40Q35VuY6aG3sX6eVDyc=;
 b=k3hgb8Cmg6uOaTXxByCj8Oa+1eBKkqykjO9I3aNQdX+ntLchfkD5vVdIMLhWxfYTAq
 cdcu7KAgiOFsA5biWc8VhcRQPH5kkyCyPpEti3HfvIHj1+EcQpkLRIff9+rAG/1Bikpc
 8JAYqsvayX1swTP7hAdHWHMXEfQ4yQ6vCPxb+9gxaMZo60QM6o1onyDMQjS5q9IkQqac
 IyckD9/gI/0dJ0dMfCZMrA87JROTUMaPTTRFR272yy9/WgOiGa8zV+w3sWi1YW4JgElD
 JbCpQ+xEpCq1h41EFJP81cWb7tve450mdpNDgBmlYL3FdhO7jaUcKH4V0owxqDwE2R7W
 vQ4g==
X-Gm-Message-State: AOAM532P1NI47h/3xqMgDe/64H4naXvi32lwgy8E1guiQ9ClbW7gU5oo
 cAbnqAiLHQv8pHcY4rLgxsbV7lTXyCvdlVp1
X-Google-Smtp-Source: ABdhPJy7IJ3VExxrUSvVAdN94MbvRPMYPuPR64fdVczeGXWZEVGDUkRzOl/nwi6OdECSi4zyGTVDUw==
X-Received: by 2002:a62:342:0:b029:1ed:b5f:d075 with SMTP id
 63-20020a6203420000b02901ed0b5fd075mr5751870pfd.62.1613811909311; 
 Sat, 20 Feb 2021 01:05:09 -0800 (PST)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id g62sm12226727pgc.32.2021.02.20.01.05.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sat, 20 Feb 2021 01:05:09 -0800 (PST)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [RFC PATCH 3/3] selftests/seccomp: Add test for wait killable notifier
Date: Sat, 20 Feb 2021 01:05:02 -0800
Message-Id: <20210220090502.7202-4-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210220090502.7202-1-sargun@sargun.me>
References: <20210220090502.7202-1-sargun@sargun.me>
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
 tools/testing/selftests/seccomp/seccomp_bpf.c | 60 +++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 26c72f2b61b1..a8ef4558d673 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -4139,6 +4139,66 @@ TEST(user_notification_addfd_rlimit)
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
