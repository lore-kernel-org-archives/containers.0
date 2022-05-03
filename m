Received: from mail-pj1-f53.google.com (mail-pj1-f53.google.com [209.85.216.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40D6217F8
	for <containers@lists.linux.dev>; Tue,  3 May 2022 08:11:16 +0000 (UTC)
Received: by mail-pj1-f53.google.com with SMTP id l11-20020a17090a49cb00b001d923a9ca99so1400041pjm.1
        for <containers@lists.linux.dev>; Tue, 03 May 2022 01:11:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EfFREWnAIM+KTJeyLZzl+cb5YVjXhixI113UYmPJpgU=;
        b=FE6dQqFeF2gZTY/fxJTPWB3JdPTQhHX+9r8wlI0aSYk1X28Lk4ag3mMWRwbcnLEiWN
         eB0SrZqDCP3BCsGQt44MKK+8nZO1F1m6JJdh2+FbMYZ2sF29Gw99iSzDCRYwlu9Yujqi
         am+KW546ZhUumHB97jtnLW/ZHYMw0feUmFArg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=EfFREWnAIM+KTJeyLZzl+cb5YVjXhixI113UYmPJpgU=;
        b=BTibTb40UnTqlRfuM8VmlXqCdQmhQXTJy4TlLkh1dp5dW4WDGICSwYx1iM1bCYc2Pi
         epLrR3arZS9XyLYIcY/nly+ta2TvnNfTbFARp1vHfckNTx87M4qEQq0g+9R6TY/VHmIQ
         jLroX6x/+E45oqRyHv0dwqP293+h1slf8tkXnEg2/BXC1eDTGo7IfCpcWSUJ9CcW1UN3
         rmN7WA+a3NHDudc2i5Lv++uOnun4KT/QhahiXQeLQ9+COH+fDehiYrvdmqiol6IJ77xx
         +7dZDtZr731sIJkrqLl+DwuuFpW0eqJfzL3F497Gg2B8nDOL/SLaTSh7KH4vdGpqoUd3
         2TVg==
X-Gm-Message-State: AOAM530wid4Dr/ej6B6QCju61jidk74XTfs63cnt9E/FJGbjWl4mxnro
	Y2hxsBf5I96/uTCo0yOouzFfPA==
X-Google-Smtp-Source: ABdhPJwUAUSc2oe4DDeYjw+beDozzp9WC2zMm02uf1xyn/WtkL4Wnigmo1IqSAiyaqB+NGf5Cgvidw==
X-Received: by 2002:a17:902:8f94:b0:14f:d9b3:52c2 with SMTP id z20-20020a1709028f9400b0014fd9b352c2mr15224110plo.103.1651565475377;
        Tue, 03 May 2022 01:11:15 -0700 (PDT)
Received: from localhost.localdomain (99-0-82-137.lightspeed.sntcca.sbcglobal.net. [99.0.82.137])
        by smtp.gmail.com with ESMTPSA id h2-20020aa786c2000000b0050dc762815dsm5821069pfo.55.2022.05.03.01.11.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 May 2022 01:11:14 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Sargun Dhillon <sargun@sargun.me>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Will Drewry <wad@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Tycho Andersen <tycho@tycho.pizza>,
	Alban Crequy <alban@kinvolk.io>
Subject: [PATCH v4 3/3] selftests/seccomp: Add test for wait killable notifier
Date: Tue,  3 May 2022 01:09:58 -0700
Message-Id: <20220503080958.20220-4-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20220503080958.20220-1-sargun@sargun.me>
References: <20220503080958.20220-1-sargun@sargun.me>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This verifies that if a filter is set up with the wait killable feature
that it obeys the semantics that non-fatal signals are ignored during
a notification after the notification is received.

Cases tested:
 * Non-fatal signal prior to receive
 * Non-fatal signal during receive
 * Fatal signal after receive

The normal signal handling is tested in user_notification_signal. That
behaviour remains unchanged.

On an unsupported kernel, these tests will immediately bail as it relies
on a new seccomp flag.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 228 ++++++++++++++++++
 1 file changed, 228 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 4fb5eda89223..931dd1b6d385 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -59,6 +59,8 @@
 #define SKIP(s, ...)	XFAIL(s, ##__VA_ARGS__)
 #endif
 
+#define MIN(X, Y) ((X) < (Y) ? (X) : (Y))
+
 #ifndef PR_SET_PTRACER
 # define PR_SET_PTRACER 0x59616d61
 #endif
@@ -268,6 +270,10 @@ struct seccomp_notif_addfd_big {
 #define SECCOMP_FILTER_FLAG_TSYNC_ESRCH (1UL << 4)
 #endif
 
+#ifndef SECCOMP_FILTER_FLAG_WAIT_KILLABLE_RECV
+#define SECCOMP_FILTER_FLAG_WAIT_KILLABLE_RECV (1UL << 5)
+#endif
+
 #ifndef seccomp
 int seccomp(unsigned int op, unsigned int flags, void *args)
 {
@@ -4362,6 +4368,228 @@ TEST(user_notification_fifo)
 	}
 }
 
+/* get_proc_syscall - Get the syscall in progress for a given pid
+ *
+ * Returns the current syscall number for a given process
+ * Returns -1 if not in syscall (running or blocked)
+ */
+static long get_proc_syscall(struct __test_metadata *_metadata, int pid)
+{
+	char proc_path[100] = {0};
+	long ret = -1;
+	ssize_t nread;
+	char *line;
+
+	snprintf(proc_path, sizeof(proc_path), "/proc/%d/syscall", pid);
+	nread = get_nth(_metadata, proc_path, 1, &line);
+	ASSERT_GT(nread, 0);
+
+	if (!strncmp("running", line, MIN(7, nread)))
+		ret = strtol(line, NULL, 16);
+
+	free(line);
+	return ret;
+}
+
+/* Ensure non-fatal signals prior to receive are unmodified */
+TEST(user_notification_wait_killable_pre_notification)
+{
+	struct sigaction new_action = {
+		.sa_handler = signal_handler,
+	};
+	int listener, status, sk_pair[2];
+	pid_t pid;
+	long ret;
+	char c;
+	/* 100 ms */
+	struct timespec delay = { .tv_nsec = 100000000 };
+
+	ASSERT_EQ(sigemptyset(&new_action.sa_mask), 0);
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret)
+	{
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	ASSERT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
+
+	listener = user_notif_syscall(
+		__NR_getppid, SECCOMP_FILTER_FLAG_NEW_LISTENER |
+				      SECCOMP_FILTER_FLAG_WAIT_KILLABLE_RECV);
+	ASSERT_GE(listener, 0);
+
+	/*
+	 * Check that we can kill the process with SIGUSR1 prior to receiving
+	 * the notification. SIGUSR1 is wired up to a custom signal handler,
+	 * and make sure it gets called.
+	 */
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		close(sk_pair[0]);
+		handled = sk_pair[1];
+
+		/* Setup the non-fatal sigaction without SA_RESTART */
+		if (sigaction(SIGUSR1, &new_action, NULL)) {
+			perror("sigaction");
+			exit(1);
+		}
+
+		ret = syscall(__NR_getppid);
+		/* Make sure we got a return from a signal interruption */
+		exit(ret != -1 || errno != EINTR);
+	}
+
+	/*
+	 * Make sure we've gotten to the seccomp user notification wait
+	 * from getppid prior to sending any signals
+	 */
+	while (get_proc_syscall(_metadata, pid) != __NR_getppid &&
+	       get_proc_stat(_metadata, pid) != 'S')
+		nanosleep(&delay, NULL);
+
+	/* Send non-fatal kill signal */
+	EXPECT_EQ(kill(pid, SIGUSR1), 0);
+
+	/* wait for process to exit (exit checks for EINTR) */
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+
+	EXPECT_EQ(read(sk_pair[0], &c, 1), 1);
+}
+
+/* Ensure non-fatal signals after receive are blocked */
+TEST(user_notification_wait_killable)
+{
+	struct sigaction new_action = {
+		.sa_handler = signal_handler,
+	};
+	struct seccomp_notif_resp resp = {};
+	struct seccomp_notif req = {};
+	int listener, status, sk_pair[2];
+	pid_t pid;
+	long ret;
+	char c;
+	/* 100 ms */
+	struct timespec delay = { .tv_nsec = 100000000 };
+
+	ASSERT_EQ(sigemptyset(&new_action.sa_mask), 0);
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret)
+	{
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	ASSERT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
+
+	listener = user_notif_syscall(
+		__NR_getppid, SECCOMP_FILTER_FLAG_NEW_LISTENER |
+				      SECCOMP_FILTER_FLAG_WAIT_KILLABLE_RECV);
+	ASSERT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		close(sk_pair[0]);
+		handled = sk_pair[1];
+
+		/* Setup the sigaction without SA_RESTART */
+		if (sigaction(SIGUSR1, &new_action, NULL)) {
+			perror("sigaction");
+			exit(1);
+		}
+
+		/* Make sure that the syscall is completed (no EINTR) */
+		ret = syscall(__NR_getppid);
+		exit(ret != USER_NOTIF_MAGIC);
+	}
+
+	/*
+	 * Get the notification, to make move the notifying process into a
+	 * non-preemptible (TASK_KILLABLE) state.
+	 */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+	/* Send non-fatal kill signal */
+	EXPECT_EQ(kill(pid, SIGUSR1), 0);
+
+	/*
+	 * Make sure the task enters moves to TASK_KILLABLE by waiting for
+	 * D (Disk Sleep) state after receiving non-fatal signal.
+	 */
+	while (get_proc_stat(_metadata, pid) != 'D')
+		nanosleep(&delay, NULL);
+
+	resp.id = req.id;
+	resp.val = USER_NOTIF_MAGIC;
+	/* Make sure the notification is found and able to be replied to */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_SEND, &resp), 0);
+
+	/*
+	 * Make sure that the signal handler does get called once we're back in
+	 * userspace.
+	 */
+	EXPECT_EQ(read(sk_pair[0], &c, 1), 1);
+	/* wait for process to exit (exit checks for USER_NOTIF_MAGIC) */
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+/* Ensure fatal signals after receive are not blocked */
+TEST(user_notification_wait_killable_fatal)
+{
+	struct seccomp_notif req = {};
+	int listener, status;
+	pid_t pid;
+	long ret;
+	/* 100 ms */
+	struct timespec delay = { .tv_nsec = 100000000 };
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
+	ASSERT_EQ(0, ret)
+	{
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
+	}
+
+	listener = user_notif_syscall(
+		__NR_getppid, SECCOMP_FILTER_FLAG_NEW_LISTENER |
+				      SECCOMP_FILTER_FLAG_WAIT_KILLABLE_RECV);
+	ASSERT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		/* This should never complete as it should get a SIGTERM */
+		syscall(__NR_getppid);
+		exit(1);
+	}
+
+	while (get_proc_stat(_metadata, pid) != 'S')
+		nanosleep(&delay, NULL);
+
+	/*
+	 * Get the notification, to make move the notifying process into a
+	 * non-preemptible (TASK_KILLABLE) state.
+	 */
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+	/* Kill the process with a fatal signal */
+	EXPECT_EQ(kill(pid, SIGTERM), 0);
+
+	/*
+	 * Wait for the process to exit, and make sure the process terminated
+	 * due to the SIGTERM signal.
+	 */
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFSIGNALED(status));
+	EXPECT_EQ(SIGTERM, WTERMSIG(status));
+}
+
 /*
  * TODO:
  * - expand NNP testing
-- 
2.25.1

