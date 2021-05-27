Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D31E72FAD
	for <containers@lists.linux.dev>; Thu, 27 May 2021 03:29:51 +0000 (UTC)
Received: by mail-pj1-f41.google.com with SMTP id pi6-20020a17090b1e46b029015cec51d7cdso1539890pjb.5
        for <containers@lists.linux.dev>; Wed, 26 May 2021 20:29:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=wUSLATuxqwUSkm0n0L/pdOiJHV0rfqOrlM9K+8X4EsU=;
        b=K4cenW2uiZEnsKztxhSgzBxy882yyvg5X2eNPT41iOLyE/qd4b2J5QqsrkCSeKp3NC
         WiJvgVRbHi5ww8DElEaoBCSP8QheeqIEg22ZIc8jm6HyqwWQrsuJuoBqSMO+tSr9kCEj
         +bRF7YcSdweTjdFqVDh/1gFiVboqXZPMiEHgU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=wUSLATuxqwUSkm0n0L/pdOiJHV0rfqOrlM9K+8X4EsU=;
        b=m3ZdxqDYsvvgQfLnvPSv4KfDLoZCsx0zZn3V/+DlPXkla0EStgFfhaBLvKBVTW/aCP
         299XSq3NYwSrnWqfaVN7RkdJbYt15rut9sSZOfgo4dqu9NqVeJDnYuDK/dDh2n5rMeO8
         AZBv+O7bfpbJvYvVEiOnZtYvKqILgqhLfLaJiK0PfYrYMpv3n5Q2Jjn2Af8GT7p8Qo5h
         cPfF0qESdCpjw6UFvCnbYeib4n7aoowrYr531aPcMZVx/yNXe8bI/qmOgUe0UOVn8pmo
         GJVVdd+Y8hiVJMZ5zBLwwWga9o26J+JVHpQhJevF4p6EHYUKk7s2UFhAofF0tGaWZxhP
         uX7Q==
X-Gm-Message-State: AOAM532OnVHsbTFgKMo14rnRDcD7Rsf5xcyANRkSVPPEI4/vJNZLRCzC
	brDpBU+thWvxZQo7K1Gu0qw6RQ==
X-Google-Smtp-Source: ABdhPJy77wtQquBVeat3/kh1ClOh7dXn8rRbIhPAHzNHr+8iy2kccsIGfvH2rzaBOBpeoeo1o7VPhw==
X-Received: by 2002:a17:902:ec84:b029:fc:e490:ffa0 with SMTP id x4-20020a170902ec84b02900fce490ffa0mr1425048plg.63.1622086191460;
        Wed, 26 May 2021 20:29:51 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id y17sm512421pfb.183.2021.05.26.20.29.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 May 2021 20:29:50 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	containers@lists.linux.dev,
	Tycho Andersen <tycho@tycho.pizza>,
	"Rodrigo Campos" <rodrigo@kinvolk.io>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	"Giuseppe Scrivano" <gscrivan@redhat.com>,
	"Christian Brauner" <christian.brauner@ubuntu.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Will Drewry <wad@chromium.org>
Subject: [PATCH] selftests/seccomp: More closely track fds being assigned
Date: Wed, 26 May 2021 20:29:48 -0700
Message-Id: <20210527032948.3730953-1-keescook@chromium.org>
X-Mailer: git-send-email 2.25.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; g=7afcc5fc33dccc110e627e132fe64664e55dcb29; i=PALtmrbA7QkmXrXcpfM46QoGaA1mIVejaurYGuKYKo8=; m=3hqOsFdiMQcNDUxhvpqgKs5YrZM13Cs9hPxopbXCKYg=; p=BJHnadUHWUYcvHacF23OIMxXn3NG2MSYsF/ScRDBebA=
X-Patch-Sig: m=pgp; i=keescook@chromium.org; s=0x0x8972F4DFDC6DC026; b=iQIzBAABCgAdFiEEpcP2jyKd1g9yPm4TiXL039xtwCYFAmCvEisACgkQiXL039xtwCaz3Q/8CmB g7jGmUsnWFX0K/gyget7x9xeVWr+t7XfkDFgRKv9AxgzrYwJD8Xr1dGBCKNVNGhVqS3lKCRXAr+d/ IKTvXMlio2g/Uy4yMjCAX9HuARA/zwXNCUhCnaFtNKHCcAwXCPuqo72Sw5GJcPY3A44coxYsUfnyE 0Nfh1pFW1fL9g8I2KwW6yasvhAhwbTd4Gn+dktvMCh9a1kzABmFfGKy78shAh3g9PUnVaQnJmhg3R Pdo4DHOu+MxpGLnPGFrRc59tFzcg8Ol4rrMWMlaqOcxtubuqRs12VNFmiZxWgjiAyTTr9mMDmgNDl oRCuuCNpUL5hLeyoP7qzJ7BIpC8sUW/XLuDFEm7iyZGU26F9WFPl/C3PP1FPoh0/cWe/ghrppl2rI HhtybP/HeujA/jG5yL1P1JYix3Ww4F8wC+Yjaw8uLx20qMKeevzpC1jJb8Nwwvh8Bbveh2vvw/+DC W5vSA+nr5BlxecUHdiEj2OCZPq3WYuRVVDePERpyB2Dj21AYU8bJBxGHoFbpDRZq8NqB5e5FgHEJK kPU+lGO0sLmz4fFix8L8Hh59RGAHHzmtzBVVHt/vBwsrX8O5Z82KygelBXE0a0f8TgbfWsNtunw7X YzCchxJBzeMdAN5bRtF8/MyvWDJZMlUkTF4gvHlqN01S4gl51PktqBBPN6R/9C3g=
Content-Transfer-Encoding: 8bit

Since the open fds might not always start at "4" (especially when
running under kselftest, etc), start counting from the first assigned
fd, rather than using the more permissive EXPECT_GE(fd, 0).

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 tools/testing/selftests/seccomp/seccomp_bpf.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index e2ba7adc2694..03b37e660965 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -3954,7 +3954,7 @@ TEST(user_notification_addfd)
 {
 	pid_t pid;
 	long ret;
-	int status, listener, memfd, fd;
+	int status, listener, memfd, fd, nextfd;
 	struct seccomp_notif_addfd addfd = {};
 	struct seccomp_notif_addfd_small small = {};
 	struct seccomp_notif_addfd_big big = {};
@@ -3963,18 +3963,21 @@ TEST(user_notification_addfd)
 	/* 100 ms */
 	struct timespec delay = { .tv_nsec = 100000000 };
 
+	/* There may be arbitrary already-open fds at test start. */
 	memfd = memfd_create("test", 0);
 	ASSERT_GE(memfd, 0);
+	nextfd = memfd + 1;
 
 	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
 	ASSERT_EQ(0, ret) {
 		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
 	}
 
+	/* fd: 4 */
 	/* Check that the basic notification machinery works */
 	listener = user_notif_syscall(__NR_getppid,
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
-	ASSERT_GE(listener, 0);
+	ASSERT_EQ(listener, nextfd++);
 
 	pid = fork();
 	ASSERT_GE(pid, 0);
@@ -4029,14 +4032,14 @@ TEST(user_notification_addfd)
 
 	/* Verify we can set an arbitrary remote fd */
 	fd = ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd);
-	EXPECT_GE(fd, 0);
+	EXPECT_EQ(fd, nextfd++);
 	EXPECT_EQ(filecmp(getpid(), pid, memfd, fd), 0);
 
 	/* Verify we can set an arbitrary remote fd with large size */
 	memset(&big, 0x0, sizeof(big));
 	big.addfd = addfd;
 	fd = ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD_BIG, &big);
-	EXPECT_GE(fd, 0);
+	EXPECT_EQ(fd, nextfd++);
 
 	/* Verify we can set a specific remote fd */
 	addfd.newfd = 42;
@@ -4070,9 +4073,11 @@ TEST(user_notification_addfd)
 	addfd.newfd = 0;
 	addfd.flags = SECCOMP_ADDFD_FLAG_SEND;
 	fd = ioctl(listener, SECCOMP_IOCTL_NOTIF_ADDFD, &addfd);
-
-	/* Child has fds 0-6 and 42 used, we expect the lower fd available: 7 */
-	EXPECT_EQ(fd, 7);
+	/*
+	 * Child has earlier "low" fds and now 42, so we expect the next
+	 * lowest available fd to be assigned here.
+	 */
+	EXPECT_EQ(fd, nextfd++);
 	EXPECT_EQ(filecmp(getpid(), pid, memfd, fd), 0);
 
 	/*
-- 
2.25.1

