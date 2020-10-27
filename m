Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA803C388F9
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:29 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 578B62145D
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 578B62145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cyphar.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id ECD2487342;
	Tue, 27 Oct 2020 23:51:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id h1XGcQnn6jS2; Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8ED9087307;
	Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8A12CC088B;
	Tue, 27 Oct 2020 23:51:27 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C1ED5C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id BE5E38694C
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mwPFGi2+cG2i
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:24 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mout-p-102.mailbox.org (mout-p-102.mailbox.org [80.241.56.152])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C42AB868E2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:24 +0000 (UTC)
Received: from smtp2.mailbox.org (smtp2.mailbox.org [80.241.60.241])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest
 SHA256) (No client certificate requested)
 by mout-p-102.mailbox.org (Postfix) with ESMTPS id 4CLT4V52DvzQlWp;
 Wed, 28 Oct 2020 00:51:22 +0100 (CET)
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
 by spamfilter03.heinlein-hosting.de (spamfilter03.heinlein-hosting.de
 [80.241.56.117]) (amavisd-new, port 10030)
 with ESMTP id keLXn8Ok8xxy; Wed, 28 Oct 2020 00:51:17 +0100 (CET)
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Shuah Khan <shuah@kernel.org>
Subject: [PATCH v2 1/2] openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
Date: Wed, 28 Oct 2020 10:50:43 +1100
Message-Id: <20201027235044.5240-2-cyphar@cyphar.com>
In-Reply-To: <20201027235044.5240-1-cyphar@cyphar.com>
References: <20201027235044.5240-1-cyphar@cyphar.com>
MIME-Version: 1.0
X-MBO-SPAM-Probability: 
X-Rspamd-Score: -7.39 / 15.00 / 15.00
X-Rspamd-Queue-Id: E14781706
X-Rspamd-UID: 6ece5a
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-fsdevel@vger.kernel.org
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

This was an oversight in the original implementation, as it makes no
sense to specify both scoping flags to the same openat2(2) invocation
(before this patch, the result of such an invocation was equivalent to
RESOLVE_IN_ROOT being ignored).

This is a userspace-visible ABI change, but the only user of openat2(2)
at the moment is LXC which doesn't specify both flags and so no
userspace programs will break as a result.

Cc: <stable@vger.kernel.org> # v5.6+
Fixes: fddb5d430ad9 ("open: introduce openat2(2) syscall")
Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
Signed-off-by: Aleksa Sarai <cyphar@cyphar.com>
---
 fs/open.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/open.c b/fs/open.c
index 9af548fb841b..4d7537ae59df 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1010,6 +1010,10 @@ inline int build_open_flags(const struct open_how *how, struct open_flags *op)
 	if (how->resolve & ~VALID_RESOLVE_FLAGS)
 		return -EINVAL;
 
+	/* Scoping flags are mutually exclusive. */
+	if ((how->resolve & RESOLVE_BENEATH) && (how->resolve & RESOLVE_IN_ROOT))
+		return -EINVAL;
+
 	/* Deal with the mode. */
 	if (WILL_CREATE(flags)) {
 		if (how->mode & ~S_IALLUGO)
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
