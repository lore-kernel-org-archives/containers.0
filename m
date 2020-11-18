Return-Path: <SRS0=nHAz=EY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1728C5519F
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:06 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F7DD22228
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="BWdd263o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F7DD22228
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id C85CF8677B;
	Wed, 18 Nov 2020 10:48:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bYuJUGz+TW3f; Wed, 18 Nov 2020 10:48:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 53D6B85B71;
	Wed, 18 Nov 2020 10:48:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4F68FC0800;
	Wed, 18 Nov 2020 10:48:05 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8C2CAC07FF
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7ACDC85B71
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id v8WJkRDHP4xB
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B36628677B
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1605696482;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=gm3OBX/9hJtnlJ3YS7mlFXt8HRp4QEhmJQZCJ3PsAxw=;
 b=BWdd263oFYXxf+q/aSW3o/kTah6qocM82CTp3KC3+itOGXyZIx14dfNFesFMzOfcOIIQ+W
 H/pf0uWPTCiaiIFx9BdCXvvu2NFjDsF6mtkXMFbJhIPmvFFDpq7yirT/xKl7n2gM1vQ6+A
 +bx5X2s/oYJzWBEhb+s5/7ZpxczmN7c=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-332-g-JpIBSuNo-C3Y6xwHJx0w-1; Wed, 18 Nov 2020 05:47:58 -0500
X-MC-Unique: g-JpIBSuNo-C3Y6xwHJx0w-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com
 [10.5.11.12])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 1FBC686ABD9;
 Wed, 18 Nov 2020 10:47:57 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-113-143.ams2.redhat.com
 [10.36.113.143])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 6503060C05;
 Wed, 18 Nov 2020 10:47:55 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org,
	christian.brauner@ubuntu.com
Subject: [PATCH v3 2/2] selftests: core: add tests for CLOSE_RANGE_CLOEXEC
Date: Wed, 18 Nov 2020 11:47:46 +0100
Message-Id: <20201118104746.873084-3-gscrivan@redhat.com>
In-Reply-To: <20201118104746.873084-1-gscrivan@redhat.com>
References: <20201118104746.873084-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
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

check that close_range(initial_fd, last_fd, CLOSE_RANGE_CLOEXEC)
correctly sets the close-on-exec bit for the specified file
descriptors.

Open 100 file descriptors and set the close-on-exec flag for a subset
of them first, then set it for every file descriptor above 2.  Make
sure RLIMIT_NOFILE doesn't affect the result.

Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
---
 .../testing/selftests/core/close_range_test.c | 74 +++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/tools/testing/selftests/core/close_range_test.c b/tools/testing/selftests/core/close_range_test.c
index c99b98b0d461..18992c383852 100644
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
+	ASSERT_EQ(0, getrlimit(RLIMIT_NOFILE, &rlimit));
+	rlimit.rlim_cur = 25;
+	ASSERT_EQ(0, setrlimit(RLIMIT_NOFILE, &rlimit));
+
+	/* Set close-on-exec for two ranges: [0-50] and [75-100].  */
+	ret = sys_close_range(open_fds[0], open_fds[50], CLOSE_RANGE_CLOEXEC);
+	ASSERT_EQ(0, ret);
+	ret = sys_close_range(open_fds[75], open_fds[100], CLOSE_RANGE_CLOEXEC);
+	ASSERT_EQ(0, ret);
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
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
