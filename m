Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F48C2D0A3
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:37:23 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3665720678
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:37:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="Kg4bwx/s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3665720678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8F9C1872D4;
	Mon,  2 Nov 2020 20:37:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UpGNow794c+9; Mon,  2 Nov 2020 20:37:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C6DC3872A0;
	Mon,  2 Nov 2020 20:37:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B50F7C088B;
	Mon,  2 Nov 2020 20:37:20 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1357EC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 0D79E204D9
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HvAuKhoTmko0
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:18 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com
 [209.85.221.65])
 by silver.osuosl.org (Postfix) with ESMTPS id AEBF2204DA
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:37:17 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id x7so16147515wrl.3
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 12:37:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=JBSfbnkhy+SsCVKkabq4UeCi4FqgMT/EvHEBqUnCapA=;
 b=Kg4bwx/sQs8JYty7zroxHEawKP1El2jW02Um3Sfv9bGyiGWG8YbN9CauDSqN5FkhxY
 nhfpd+zruvLLRbEPcL6eYE16YI5q1dGfTb8p1dHixaGUrTNx8NR4C5RQrtygIs0kpL5d
 TqFgf+jE49EEQMH+1T8yyprghAwa+hpZhPTZULo8hggpvsf5e6JFwOPcDfkQ3O2k23D2
 J2CQ8MjkQ2y+DPHvHcSOPlwpwvPDaeS6+7Vwa3Vct2GED6P2s5+pY1BdpDM1K4yrK5X6
 Pt0PfSR/b2AJ1/YGGQZEXgQGqBiABrOsFe8grGoPRZ2NyOEEbz2zldRwuyM0BRGLJaAG
 1lGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=JBSfbnkhy+SsCVKkabq4UeCi4FqgMT/EvHEBqUnCapA=;
 b=RGjER8roQlw3eTOwgXJ/EQuV1uGCZfYD7uPz0qZvWf3aCDIZoa212HOUs+5mGyjeqY
 Nbjm88txpID0IrXbwZJvSScEy/Xy5ttSAjxTXUqGDTkTblT/mOHyRiLDLDDF6qnfGBqe
 2jBoPjM8N77zExOBNq06NSh3w+6zTkG0TgyYEU3+LcolLZQMcnY+8l9cj/s7bSJ1JTVM
 K8uMbR0IqK9gmrcR5mcWwj5WndkKQZS9b0+fAev0C7BtSWcPAnVpNSuRLNMGp5zf0oy1
 7HG2XE0NI4kjNLM20NSY0L1DT31WtfAkqFp2lqgfYRhWtjaEvedAtX4+daaA9r+m6yLH
 WuPQ==
X-Gm-Message-State: AOAM530zyRLDrwzLdkEEGUV6xJ44TqF5gLRkZRh3nX1YlCI2nfyz7z+O
 Gjc9xni2ImgyJscSDFoOFANyTA==
X-Google-Smtp-Source: ABdhPJyoNAtXjaC3Q8PAYFP3AKOrj9IA4iQDVef24ZBSQtp1ky5buQ3/i3Q7qSEGrKZhi7HSLdveOQ==
X-Received: by 2002:adf:f3d2:: with SMTP id g18mr22110924wrp.367.1604349436086; 
 Mon, 02 Nov 2020 12:37:16 -0800 (PST)
Received: from localhost ([2a02:168:96c5:1:55ed:514f:6ad7:5bcc])
 by smtp.gmail.com with ESMTPSA id d2sm23823258wrq.34.2020.11.02.12.37.15
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 02 Nov 2020 12:37:15 -0800 (PST)
To: Kees Cook <keescook@chromium.org>
Subject: [PATCH 3/3] selftests/seccomp: Test NOTIF_RECV empty/dead errors
Date: Mon,  2 Nov 2020 21:37:06 +0100
Message-Id: <20201102203706.827510-3-jannh@google.com>
X-Mailer: git-send-email 2.29.1.341.ge80a0c044ae-goog
In-Reply-To: <20201102203706.827510-1-jannh@google.com>
References: <20201102203706.827510-1-jannh@google.com>
MIME-Version: 1.0
Cc: Giuseppe Scrivano <giuseppe@scrivano.org>, Will Drewry <wad@chromium.org>,
 Paul Moore <paul@paul-moore.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian.brauner@canonical.com>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
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

Test that SECCOMP_IOCTL_NOTIF_RECV on a seccomp fd with zero users returns
-ENOTCONN, both in blocking and in non-blocking mode.
Also test that SECCOMP_IOCTL_NOTIF_RECV on a seccomp fd with no active
notifications returns -ENOENT in non-blocking mode.

Signed-off-by: Jann Horn <jannh@google.com>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 127 ++++++++++++++++++
 1 file changed, 127 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 5318f9cb1aec..8214c431ad4b 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -28,6 +28,7 @@
 #include <linux/prctl.h>
 #include <linux/ptrace.h>
 #include <linux/seccomp.h>
+#include <linux/futex.h>
 #include <pthread.h>
 #include <semaphore.h>
 #include <signal.h>
@@ -315,6 +316,35 @@ static int __filecmp(pid_t pid1, pid_t pid2, int fd1, int fd2)
 	}						\
 	_ret; })
 
+static void store_and_wake(int *ptr, int value)
+{
+	__atomic_store(ptr, &value, __ATOMIC_RELEASE);
+	if (syscall(__NR_futex, ptr, FUTEX_WAKE, INT_MAX, NULL, NULL, 0) == -1) {
+		perror("FUTEX_WAKE failed unexpectedly");
+		exit(EXIT_FAILURE);
+	}
+}
+
+static int wait_and_load(int *ptr, int placeholder)
+{
+	int futex_ret;
+	int value;
+
+retry:
+	futex_ret = syscall(__NR_futex, ptr, FUTEX_WAIT, placeholder, NULL,
+			    NULL, 0);
+	if (futex_ret == -1 && errno != EAGAIN) {
+		if (errno == EINTR)
+			goto retry;
+		perror("FUTEX_WAIT failed unexpectedly");
+		exit(EXIT_FAILURE);
+	}
+	value = __atomic_load_n(ptr, __ATOMIC_ACQUIRE);
+	if (value == placeholder)
+		goto retry;
+	return value;
+}
+
 TEST(kcmp)
 {
 	int ret;
@@ -4160,6 +4190,103 @@ TEST(user_notification_addfd_rlimit)
 	close(memfd);
 }
 
+TEST(user_notification_recv_dead)
+{
+	pid_t pid;
+	int status;
+	struct __clone_args args = {
+		.flags = CLONE_FILES,
+		.exit_signal = SIGCHLD,
+	};
+	struct seccomp_notif notif = {};
+	struct shared_data {
+		int notif_fd;
+	} *shared_data;
+
+	shared_data = mmap(NULL, sizeof(struct shared_data),
+			   PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED,
+			   -1, 0);
+	ASSERT_NE(NULL, shared_data);
+	ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	pid = sys_clone3(&args, sizeof(args));
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		shared_data->notif_fd = user_notif_syscall(
+				__NR_mknodat, SECCOMP_FILTER_FLAG_NEW_LISTENER);
+		if (shared_data->notif_fd < 0)
+			_exit(EXIT_FAILURE);
+
+		_exit(EXIT_SUCCESS);
+	}
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+
+	/* non-blocking recv */
+	EXPECT_EQ(-1, ioctl(shared_data->notif_fd, SECCOMP_IOCTL_NOTIF_RECV, &notif));
+	EXPECT_EQ(ENOTCONN, errno);
+
+	/* blocking recv */
+	set_blocking(shared_data->notif_fd);
+	EXPECT_EQ(-1, ioctl(shared_data->notif_fd, SECCOMP_IOCTL_NOTIF_RECV, &notif));
+	EXPECT_EQ(ENOTCONN, errno);
+}
+
+TEST(user_notification_recv_nonblock)
+{
+	pid_t pid;
+	struct __clone_args args = {
+		.flags = CLONE_FILES,
+		.exit_signal = SIGCHLD,
+	};
+	struct seccomp_notif notif = {};
+	struct shared_data {
+		int notif_fd;
+	} *shared_data;
+
+	shared_data = mmap(NULL, sizeof(struct shared_data),
+			   PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_SHARED,
+			   -1, 0);
+	ASSERT_NE(NULL, shared_data);
+	shared_data->notif_fd = -1;
+
+	ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	pid = sys_clone3(&args, sizeof(args));
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		int fd;
+
+		fd = user_notif_syscall(__NR_mknodat,
+					SECCOMP_FILTER_FLAG_NEW_LISTENER);
+		if (fd < 0) {
+			store_and_wake(&shared_data->notif_fd, -2);
+			_exit(EXIT_FAILURE);
+		}
+		store_and_wake(&shared_data->notif_fd, fd);
+
+		while (1)
+			pause();
+	}
+
+	wait_and_load(&shared_data->notif_fd, -1);
+
+	/* non-blocking recv */
+	EXPECT_EQ(-1, ioctl(shared_data->notif_fd, SECCOMP_IOCTL_NOTIF_RECV,
+			    &notif));
+	EXPECT_EQ(ENOENT, errno);
+
+	kill(pid, SIGKILL);
+}
+
 /*
  * TODO:
  * - expand NNP testing
-- 
2.29.1.341.ge80a0c044ae-goog

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
