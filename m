Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A172CC433B4
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:56 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3D4596145B
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D4596145B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 059ED84819;
	Fri, 30 Apr 2021 20:49:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NU77AoqoS8TM; Fri, 30 Apr 2021 20:49:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id E6604847BE;
	Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C5D53C000E;
	Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E4E6BC000E
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id C5F216F9E8
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id uNby1PJsBXvG
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qk1-x736.google.com (mail-qk1-x736.google.com
 [IPv6:2607:f8b0:4864:20::736])
 by smtp3.osuosl.org (Postfix) with ESMTPS id A4CF76080F
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
Received: by mail-qk1-x736.google.com with SMTP id k127so16535342qkc.6
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 13:49:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=9ZU5d3woFMizJa7hiEgUjcAVtlOmWstlkDGKvmjbXqM=;
 b=QPAms99dn45GAuRk046FFMVa45Tf8pkF5QIqjFZkhIrthvRkqRo91U2CwADexIeh5G
 wiAKOaOEOY3XTRs/DzIuVMhZAsi/ugSKtDwPcJmen2LQ3kz7O6DEex0lsM/5UAocqqUl
 BPgYUJIhaSyt5ab5zfn1Bdn/lZfpUo8UamGO0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=9ZU5d3woFMizJa7hiEgUjcAVtlOmWstlkDGKvmjbXqM=;
 b=Wdippl7vjO4bYK6WP1/bd+lO8pUaWUMSp1Yvq+FEkGMM6rJ+J2pPo7MQf9mPFZP0R1
 zqL56pVddBo58J4X7jrlUj2GerR0+AE6EZTj9YrYYucrWisjwegGuZ/KbyeBut6Gdi7X
 oNMAOUE2+xvARIt9OyCaFtCZn2FA9YYb+N9sCxMX3+yd/p8Q0exPZT6UBVgi4+9xrRxx
 NhENFq5oaTFjqnKAu7mtxv9R+4lpol94Cjpn29A4taz9nFingtPlnp6nq+ye/KNLupMB
 foqAxVANQg8eLGrN9WDiDNYpdnnTLmWIYRmQrYlvWQhumQYsYHYc4LHrZTQ5rweWhQA3
 0xNw==
X-Gm-Message-State: AOAM532qcf+DGlHS64I7pw8whWWzRgHo2HB9zdVnuu/4QUIhsjywqbjH
 UdX5wnKAZ3GcDAVvn6Ap8b98DA==
X-Google-Smtp-Source: ABdhPJxheZUFnAHw0netMHI17prQLKD/673UzLLY2CfWEKNMpE1TwDlxdL8wzG3jd7M2z7vwfg0aVg==
X-Received: by 2002:a37:4389:: with SMTP id q131mr7432209qka.255.1619815790404; 
 Fri, 30 Apr 2021 13:49:50 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id z17sm3161960qtf.10.2021.04.30.13.49.48
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 30 Apr 2021 13:49:49 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH v2 3/5] selftests/seccomp: Add test for wait killable notifier
Date: Fri, 30 Apr 2021 13:49:37 -0700
Message-Id: <20210430204939.5152-4-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210430204939.5152-1-sargun@sargun.me>
References: <20210430204939.5152-1-sargun@sargun.me>
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

This adds a test for the positive case of the wait killable notifier,
in testing that when the feature is activated the process acts as
expected -- in not terminating on a non-fatal signal, and instead
queueing it up. There is already a test case for normal handlers
and preemption.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 152 ++++++++++++++++++
 1 file changed, 152 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 98c3b647f54d..9a72ba8bb4f7 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -235,6 +235,11 @@ struct seccomp_notif_addfd {
 };
 #endif
 
+#ifndef SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE
+/* Set flag to prevent non-fatal signal preemption */
+#define SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE	SECCOMP_IOW(4, __u64)
+#endif
+
 struct seccomp_notif_addfd_small {
 	__u64 id;
 	char weird[4];
@@ -4135,6 +4140,153 @@ TEST(user_notification_addfd_rlimit)
 	close(memfd);
 }
 
+/* Parses /proc/$PID/status, and stores the state and shdpnd */
+static void parse_status(pid_t pid, char *state, long long *shdpnd)
+{
+	char *line = NULL;
+	char proc_path[100] = {0};
+	size_t len = 0;
+	FILE *f;
+
+	snprintf(proc_path, sizeof(proc_path), "/proc/%d/status", pid);
+	f = fopen(proc_path, "r");
+	if (f == NULL)
+		ksft_exit_fail_msg("%s - Could not open %s\n",
+				   strerror(errno), proc_path);
+
+	while (getline(&line, &len, f) != -1) {
+		if (strstr(line, "State")) {
+			if (sscanf(line, "State:\t%c", state) != 1)
+				ksft_exit_fail_msg("Couldn't parse state %s\n",
+						   line);
+		}
+
+		if (strstr(line, "ShdPnd")) {
+			if (sscanf(line, "ShdPnd:\t%llx", shdpnd) != 1)
+				ksft_exit_fail_msg("Couldn't parse shdpnd %s\n",
+						   line);
+		}
+	}
+
+	free(line);
+	fclose(f);
+}
+
+TEST(user_notification_signal_wait_killable)
+{
+	struct seccomp_notif_resp resp = {};
+	struct seccomp_notif req = {};
+	int status, listener;
+	long long sigpnd;
+	char state;
+	pid_t pid;
+	long ret;
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	listener = user_notif_syscall(__NR_gettid,
+				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
+	ASSERT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		sigset_t mask;
+
+		sigemptyset(&mask);
+		sigaddset(&mask, SIGUSR1);
+
+		EXPECT_EQ(sigprocmask(SIG_BLOCK, &mask, NULL), 0);
+
+		/* Check once for wait_killable */
+		if (syscall(__NR_gettid) != 42)
+			exit(1);
+
+		EXPECT_EQ(SIGUSR1, sigwaitinfo(&mask, NULL));
+
+		exit(42);
+	}
+
+	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+
+	/* Wait interruptible should be in sleep */
+	parse_status(pid, &state, &sigpnd);
+	ASSERT_EQ(state, 'S');
+
+	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE, &req.id), 0);
+	EXPECT_EQ(kill(pid, SIGUSR1), 0);
+
+	/* Check for transition to "disk sleep" -- async (or timeout) */
+	do {
+		usleep(100);
+		parse_status(pid, &state, &sigpnd);
+	} while (state != 'D');
+	EXPECT_EQ(sigpnd, (1 << (SIGUSR1 - 1)));
+
+	/* Make sure idempotency is handled correctly */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE, &req.id), -1);
+	EXPECT_EQ(errno, EALREADY);
+
+	resp.id = req.id;
+	resp.error = 0;
+	resp.val = 42;
+
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SEND, &resp), 0);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(42, WEXITSTATUS(status));
+}
+
+
+TEST(user_notification_signal_wait_killable_kill)
+{
+	struct seccomp_notif req = {};
+	int status, listener;
+	long long sigpnd;
+	char state;
+	pid_t pid;
+	long ret;
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	listener = user_notif_syscall(__NR_gettid,
+				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
+	ASSERT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		syscall(__NR_gettid);
+		exit(1);
+	}
+
+	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE, &req.id), 0);
+	do {
+		usleep(100);
+		parse_status(pid, &state, &sigpnd);
+	} while (state != 'D');
+
+	EXPECT_EQ(kill(pid, SIGKILL), 0);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFSIGNALED(status));
+	EXPECT_EQ(9, WTERMSIG(status));
+
+	/* Make sure the notification is invalidated properly */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_ID_VALID, &req.id), -1);
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
