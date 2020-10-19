Return-Path: <SRS0=bTwc=D2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F04C433E7
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 10:27:22 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0CA3E206DD
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 10:27:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="SyMT/eFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CA3E206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id BFC8F875D9;
	Mon, 19 Oct 2020 10:27:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oXLJf36hepuI; Mon, 19 Oct 2020 10:27:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 55EA1871AC;
	Mon, 19 Oct 2020 10:27:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 43D0BC088B;
	Mon, 19 Oct 2020 10:27:21 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 08D90C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 10:27:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id EA79027261
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 10:27:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id km6daB0X0US3
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 10:27:18 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by silver.osuosl.org (Postfix) with ESMTPS id 8305D27233
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 10:27:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603103237;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=F+KU3D6CZGkwaGqgOEZ5SUeu//6q1wj8wVndMUn0nkY=;
 b=SyMT/eFAwfd44g+MBXPlq5nzG+aDEzpgnSPsqt7M0vF/nq/dD49APmkcJ9v8AhpftTE7fH
 QdhE20/fsPwueW1AYarmf9C2PkQ0STxyBeNXSQcgDpzbc/2UrdwqGGM1ZDW5uosakIxflv
 nkZcWFqb5TowSVkT35g4BGsB9gUzRUg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-89-_VUznokVMPeyyxFPWoKEuw-1; Mon, 19 Oct 2020 06:27:13 -0400
X-MC-Unique: _VUznokVMPeyyxFPWoKEuw-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com
 [10.5.11.11])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 5A90F10066FB;
 Mon, 19 Oct 2020 10:27:11 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-115-42.ams2.redhat.com [10.36.115.42])
 by smtp.corp.redhat.com (Postfix) with ESMTP id B0EEC50B44;
 Mon, 19 Oct 2020 10:27:09 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org
Subject: [PATCH v2 2/2] selftests: add tests for CLOSE_RANGE_CLOEXEC
Date: Mon, 19 Oct 2020 12:26:54 +0200
Message-Id: <20201019102654.16642-3-gscrivan@redhat.com>
In-Reply-To: <20201019102654.16642-1-gscrivan@redhat.com>
References: <20201019102654.16642-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, viro@zeniv.linux.org.uk
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

Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
---
 .../testing/selftests/core/close_range_test.c | 74 +++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/tools/testing/selftests/core/close_range_test.c b/tools/testing/selftests/core/close_range_test.c
index c99b98b0d461..c9db282158bb 100644
--- a/tools/testing/selftests/core/close_range_test.c
+++ b/tools/testing/selftests/core/close_range_test.c
@@ -11,6 +11,7 @@
 #include <string.h>
 #include <syscall.h>
 #include <unistd.h>
+#include <sys/resource.h>
 
 #include "../kselftest_harness.h"
 #include "../clone3/clone3_selftests.h"
@@ -23,6 +24,10 @@
 #define CLOSE_RANGE_UNSHARE	(1U << 1)
 #endif
 
+#ifndef CLOSE_RANGE_CLOEXEC
+#define CLOSE_RANGE_CLOEXEC	(1U << 2)
+#endif
+
 static inline int sys_close_range(unsigned int fd, unsigned int max_fd,
 				  unsigned int flags)
 {
@@ -224,4 +229,73 @@ TEST(close_range_unshare_capped)
 	EXPECT_EQ(0, WEXITSTATUS(status));
 }
 
+TEST(close_range_cloexec)
+{
+	int i, ret;
+	int open_fds[101];
+	struct rlimit rlimit;
+
+	for (i = 0; i < ARRAY_SIZE(open_fds); i++) {
+		int fd;
+
+		fd = open("/dev/null", O_RDONLY);
+		ASSERT_GE(fd, 0) {
+			if (errno == ENOENT)
+				XFAIL(return, "Skipping test since /dev/null does not exist");
+		}
+
+		open_fds[i] = fd;
+	}
+
+	ret = sys_close_range(1000, 1000, CLOSE_RANGE_CLOEXEC);
+	if (ret < 0) {
+		if (errno == ENOSYS)
+			XFAIL(return, "close_range() syscall not supported");
+		if (errno == EINVAL)
+			XFAIL(return, "close_range() doesn't support CLOSE_RANGE_CLOEXEC");
+	}
+
+	/* Ensure the FD_CLOEXEC bit is set also with a resource limit in place.  */
+	EXPECT_EQ(0, getrlimit(RLIMIT_NOFILE, &rlimit));
+	rlimit.rlim_cur = 25;
+	EXPECT_EQ(0, setrlimit(RLIMIT_NOFILE, &rlimit));
+
+	/* Set close-on-exec for two ranges: [0-50] and [75-100].  */
+	ret = sys_close_range(open_fds[0], open_fds[50], CLOSE_RANGE_CLOEXEC);
+	EXPECT_EQ(0, ret);
+	ret = sys_close_range(open_fds[75], open_fds[100], CLOSE_RANGE_CLOEXEC);
+	EXPECT_EQ(0, ret);
+
+	for (i = 0; i <= 50; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
+	}
+
+	for (i = 51; i <= 74; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, 0);
+	}
+
+	for (i = 75; i <= 100; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
+	}
+
+	/* Test a common pattern.  */
+	ret = sys_close_range(3, UINT_MAX, CLOSE_RANGE_CLOEXEC);
+	for (i = 0; i <= 100; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
+	}
+}
+
+
 TEST_HARNESS_MAIN
-- 
2.26.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
