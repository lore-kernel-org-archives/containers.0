Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFD26C43457
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 14:06:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 57FCC247C6
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 14:06:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="P4FirxbJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57FCC247C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B3C20873FB;
	Tue, 13 Oct 2020 14:06:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id faKma1tUD68Q; Tue, 13 Oct 2020 14:06:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 540F2871CE;
	Tue, 13 Oct 2020 14:06:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 412F8C07FF;
	Tue, 13 Oct 2020 14:06:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 35B10C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 821D381514
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cBiFdKD4yI9L
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A6E3687478
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1602597987;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=s2c0z0nnK5G/Cjc6T69QlHdgqzKaRCEYH2YcGXaZfvs=;
 b=P4FirxbJIc9tN/z5XTum55FtDyvH/H098hpw1W3TAhbZ4IhJJWnqLpqaFiv+Ts8Ecv5NI2
 jPX4F0VzHPYqjs9dWGLgY2/E/BMtHGW+1WlvihbhpmK94k/9MzgOpzbMeTPIr/mjO1h3IB
 uOQsomr4oEOWrCZzvIpiWQWGo3a7tYM=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-358-BqIk-o_9Ps67-_bglI0HLw-1; Tue, 13 Oct 2020 10:06:25 -0400
X-MC-Unique: BqIk-o_9Ps67-_bglI0HLw-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com
 [10.5.11.16])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id CC27E1020905;
 Tue, 13 Oct 2020 14:06:23 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-112-43.ams2.redhat.com [10.36.112.43])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 6B9655C1C2;
 Tue, 13 Oct 2020 14:06:22 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] selftests: add tests for CLOSE_RANGE_CLOEXEC
Date: Tue, 13 Oct 2020 16:06:09 +0200
Message-Id: <20201013140609.2269319-3-gscrivan@redhat.com>
In-Reply-To: <20201013140609.2269319-1-gscrivan@redhat.com>
References: <20201013140609.2269319-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 viro@zeniv.linux.org.uk
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
 .../testing/selftests/core/close_range_test.c | 44 +++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/tools/testing/selftests/core/close_range_test.c b/tools/testing/selftests/core/close_range_test.c
index c99b98b0d461..b8789262cd7d 100644
--- a/tools/testing/selftests/core/close_range_test.c
+++ b/tools/testing/selftests/core/close_range_test.c
@@ -23,6 +23,10 @@
 #define CLOSE_RANGE_UNSHARE	(1U << 1)
 #endif
 
+#ifndef CLOSE_RANGE_CLOEXEC
+#define CLOSE_RANGE_CLOEXEC	(1U << 2)
+#endif
+
 static inline int sys_close_range(unsigned int fd, unsigned int max_fd,
 				  unsigned int flags)
 {
@@ -224,4 +228,44 @@ TEST(close_range_unshare_capped)
 	EXPECT_EQ(0, WEXITSTATUS(status));
 }
 
+TEST(close_range_cloexec)
+{
+	int i, ret;
+	int open_fds[101];
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
+	EXPECT_EQ(-1, sys_close_range(open_fds[0], open_fds[100], -1)) {
+		if (errno == ENOSYS)
+			XFAIL(return, "close_range() syscall not supported");
+	}
+
+	EXPECT_EQ(0, sys_close_range(open_fds[0], open_fds[50], CLOSE_RANGE_CLOEXEC));
+
+	for (i = 0; i <= 50; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
+	}
+
+	for (i = 51; i <= 100; i++) {
+		int flags = fcntl(open_fds[i], F_GETFD);
+
+		EXPECT_GT(flags, -1);
+		EXPECT_EQ(flags & FD_CLOEXEC, 0);
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
