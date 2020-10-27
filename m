Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1ADAC55179
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:29 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 862322223C
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 862322223C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cyphar.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5D3AB87307;
	Tue, 27 Oct 2020 23:51:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FQs6nGlZMv6B; Tue, 27 Oct 2020 23:51:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C91C787332;
	Tue, 27 Oct 2020 23:51:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B772CC088B;
	Tue, 27 Oct 2020 23:51:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AC046C08A1
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 92DCC8694C
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id D5aY4EvST-L3
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mout-p-102.mailbox.org (mout-p-102.mailbox.org [80.241.56.152])
 by whitealder.osuosl.org (Postfix) with ESMTPS id EF510868E2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:26 +0000 (UTC)
Received: from smtp2.mailbox.org (smtp2.mailbox.org
 [IPv6:2001:67c:2050:105:465:1:2:0])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest
 SHA256) (No client certificate requested)
 by mout-p-102.mailbox.org (Postfix) with ESMTPS id 4CLT4Y2rdJzQlWr;
 Wed, 28 Oct 2020 00:51:25 +0100 (CET)
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
 by spamfilter04.heinlein-hosting.de (spamfilter04.heinlein-hosting.de
 [80.241.56.122]) (amavisd-new, port 10030)
 with ESMTP id 60Qvbb9mkz_u; Wed, 28 Oct 2020 00:51:22 +0100 (CET)
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Shuah Khan <shuah@kernel.org>
Subject: [PATCH v2 2/2] selftests: openat2: add RESOLVE_ conflict test
Date: Wed, 28 Oct 2020 10:50:44 +1100
Message-Id: <20201027235044.5240-3-cyphar@cyphar.com>
In-Reply-To: <20201027235044.5240-1-cyphar@cyphar.com>
References: <20201027235044.5240-1-cyphar@cyphar.com>
MIME-Version: 1.0
X-MBO-SPAM-Probability: 
X-Rspamd-Score: -5.09 / 15.00 / 15.00
X-Rspamd-Queue-Id: 8605D271
X-Rspamd-UID: 46e5ee
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-fsdevel@vger.kernel.org
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

Now that we reject conflicting RESOLVE_ flags, add a selftest to avoid
regressions.

Signed-off-by: Aleksa Sarai <cyphar@cyphar.com>
---
 tools/testing/selftests/openat2/openat2_test.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/openat2/openat2_test.c b/tools/testing/selftests/openat2/openat2_test.c
index b386367c606b..381d874cce99 100644
--- a/tools/testing/selftests/openat2/openat2_test.c
+++ b/tools/testing/selftests/openat2/openat2_test.c
@@ -155,7 +155,7 @@ struct flag_test {
 	int err;
 };
 
-#define NUM_OPENAT2_FLAG_TESTS 23
+#define NUM_OPENAT2_FLAG_TESTS 24
 
 void test_openat2_flags(void)
 {
@@ -210,6 +210,12 @@ void test_openat2_flags(void)
 		  .how.flags = O_TMPFILE | O_RDWR,
 		  .how.mode = 0x0000A00000000000ULL, .err = -EINVAL },
 
+		/* ->resolve flags must not conflict. */
+		{ .name = "incompatible resolve flags (BENEATH | IN_ROOT)",
+		  .how.flags = O_RDONLY,
+		  .how.resolve = RESOLVE_BENEATH | RESOLVE_IN_ROOT,
+		  .err = -EINVAL },
+
 		/* ->resolve must only contain RESOLVE_* flags. */
 		{ .name = "invalid how.resolve and O_RDONLY",
 		  .how.flags = O_RDONLY,
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
