Received: from mail-qk1-f173.google.com (mail-qk1-f173.google.com [209.85.222.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A714670
	for <containers@lists.linux.dev>; Sun,  2 May 2021 00:19:12 +0000 (UTC)
Received: by mail-qk1-f173.google.com with SMTP id 76so68447qkn.13
        for <containers@lists.linux.dev>; Sat, 01 May 2021 17:19:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RenBvbpfFr/kRPp45Jw3e1BFxN3W9C6W8BvA+1szCJ4=;
        b=k0JngHraxHhpy9SHVmY5NgjGWMTt6GpcaYj8LhoXOJGOvx0vkvgaaK5/rBxYEQHRv9
         iWtmpQW5AXXzqZmPsMQdHGK2ZWHJsY7xVwNLUjDiqBGiMrgVfhehNbbglMGIuUpOcecO
         XjFhn+pl4E46hXlryTFwSuU3Zqi3/pXf9f4ps=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RenBvbpfFr/kRPp45Jw3e1BFxN3W9C6W8BvA+1szCJ4=;
        b=BbgAGbAbq5bM/KPJ80PqITxK6RQ1cO/CHisFEasjqKzJaxulKmiOdha77WK7fLlbWK
         Is9LI8cwC4xle8pgKFgLf2Kfw42exoD2xMsd9GVMas87RQ/SKtzHfkgncCrIO64t+mIJ
         MqM1sEpzCqBdagCAiWEQP+T+hPW4LMjpa/ZwsJWd6rGm5hSZsvYFBkKhjRH1edXO3fA2
         A3VNj50nKPNsUi82pP0cujb34SL6IK5V+qk/7oZFAT/U9bUbpOGBfJOYrO8hpIDts6gW
         3Hw2q/IPDNIY6HC5WjmwiIoZ552mxT5jvKWspTdP5Zh7SuMrPMDB/p8x8FAePGYl7Ecr
         qk7Q==
X-Gm-Message-State: AOAM533dXmIoXaPm2lHJy2BIyYG8LN7JNSthIAcABOjc0atkSrc7bnhq
	os9RNmpp9a30AkbjbJjOa/mbhQ==
X-Google-Smtp-Source: ABdhPJwQ0+S8q+qdRC3etHaemPYe4pog1qTFjsPkf2vMtfU20qOnSfC1JkFksanuj8fmcrJxaZeYWA==
X-Received: by 2002:a37:de16:: with SMTP id h22mr12497135qkj.351.1619914751704;
        Sat, 01 May 2021 17:19:11 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id p5sm5146067qkh.135.2021.05.01.17.19.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 17:19:10 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>
Cc: Rodrigo Campos <rodrigo@kinvolk.io>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>,
	Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH 4/4] selftests/seccomp: Add test for atomic addfd+send
Date: Sat,  1 May 2021 17:18:51 -0700
Message-Id: <20210502001851.3346-5-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210502001851.3346-1-sargun@sargun.me>
References: <20210502001851.3346-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Rodrigo Campos <rodrigo@kinvolk.io>

This just adds a test to verify that when using the new introduced flag
to ADDFD, a valid fd is added and returned as the syscall result.

Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 38 +++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 98c3b647f54d..e2ba7adc2694 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -235,6 +235,10 @@ struct seccomp_notif_addfd {
 };
 #endif
 
+#ifndef SECCOMP_ADDFD_FLAG_SEND
+#define SECCOMP_ADDFD_FLAG_SEND	(1UL << 1) /* Addfd and return it, atomically */
+#endif
+
 struct seccomp_notif_addfd_small {
 	__u64 id;
 	char weird[4];
@@ -3976,8 +3980,14 @@ TEST(user_notification_addfd)
 	ASSERT_GE(pid, 0);
 
 	if (pid == 0) {
+		/* fds will be added and this value is expected */
 		if (syscall(__NR_getppid) != USER_NOTIF_MAGIC)
 			exit(1);
+
+		/* Atomic addfd+send is received here. Check it is a valid fd */
+		if (fcntl(syscall(__NR_getppid), F_GETFD) == -1)
+			exit(1);
+
 		exit(syscall(__NR_getppid) != USER_NOTIF_MAGIC);
 	}
 
@@ -4056,6 +4066,30 @@ TEST(user_notification_addfd)
 	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
 	ASSERT_EQ(addfd.id, req.id);
 
+	/* Verify we can do an atomic addfd and send */
+	addfd.newfd = 0;
+	addfd.flags = SECCOMP_ADDFD_FLAG_SEND;
+	fd = ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd);
+
+	/* Child has fds 0-6 and 42 used, we expect the lower fd available: 7 */
+	EXPECT_EQ(fd, 7);
+	EXPECT_EQ(filecmp(getpid(), pid, memfd, fd), 0);
+
+	/*
+	 * This sets the ID of the ADD FD to the last request plus 1. The
+	 * notification ID increments 1 per notification.
+	 */
+	addfd.id = req.id + 1;
+
+	/* This spins until the underlying notification is generated */
+	while (ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd) != -1 &&
+	       errno != -EINPROGRESS)
+		nanosleep(&delay, NULL);
+
+	memset(&req, 0, sizeof(req));
+	ASSERT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, &req), 0);
+	ASSERT_EQ(addfd.id, req.id);
+
 	resp.id = req.id;
 	resp.error = 0;
 	resp.val = USER_NOTIF_MAGIC;
@@ -4116,6 +4150,10 @@ TEST(user_notification_addfd_rlimit)
 	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd), -1);
 	EXPECT_EQ(errno, EMFILE);
 
+	addfd.flags = SECCOMP_ADDFD_FLAG_SEND;
+	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd), -1);
+	EXPECT_EQ(errno, EMFILE);
+
 	addfd.newfd = 100;
 	addfd.flags = SECCOMP_ADDFD_FLAG_SETFD;
 	EXPECT_EQ(ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd), -1);
-- 
2.25.1

