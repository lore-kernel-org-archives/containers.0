Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BD19C388F9
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:23 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CDB1A207C4
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDB1A207C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cyphar.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 833BD8671E;
	Tue, 27 Oct 2020 23:51:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pKpcO1sJxVnZ; Tue, 27 Oct 2020 23:51:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8C7568647F;
	Tue, 27 Oct 2020 23:51:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 615B3C088B;
	Tue, 27 Oct 2020 23:51:21 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1DEBEC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 021908691A
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id SvBJFCL5Jy5U
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:18 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mout-p-201.mailbox.org (mout-p-201.mailbox.org [80.241.56.171])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A6CE0868E2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:51:18 +0000 (UTC)
Received: from smtp2.mailbox.org (smtp2.mailbox.org [80.241.60.241])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest
 SHA256) (No client certificate requested)
 by mout-p-201.mailbox.org (Postfix) with ESMTPS id 4CLT4N1t5QzQkSN;
 Wed, 28 Oct 2020 00:51:16 +0100 (CET)
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp2.mailbox.org ([80.241.60.241])
 by spamfilter04.heinlein-hosting.de (spamfilter04.heinlein-hosting.de
 [80.241.56.122]) (amavisd-new, port 10030)
 with ESMTP id TjTUU3fiCzt5; Wed, 28 Oct 2020 00:51:12 +0100 (CET)
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Shuah Khan <shuah@kernel.org>
Subject: [PATCH v2 0/2] openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
Date: Wed, 28 Oct 2020 10:50:42 +1100
Message-Id: <20201027235044.5240-1-cyphar@cyphar.com>
MIME-Version: 1.0
X-MBO-SPAM-Probability: 
X-Rspamd-Score: -5.33 / 15.00 / 15.00
X-Rspamd-Queue-Id: 07D78108B
X-Rspamd-UID: dcad69
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

This was an oversight in the original implementation, as it makes no
sense to specify both scoping flags to the same openat2(2) invocation
(before this patch, the result of such an invocation was equivalent to
RESOLVE_IN_ROOT being ignored).

This is a userspace-visible ABI change, but the only user of openat2(2)
at the moment is LXC which doesn't specify both flags and so no
userspace programs will break as a result.

Changelog:
  v2: Split patch so as to separate selftest changes. [Shuah Khan]
  v1: <https://lore.kernel.org/lkml/20201007103608.17349-1-cyphar@cyphar.com/>

Aleksa Sarai (2):
  openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
  selftests: openat2: add RESOLVE_ conflict test

 fs/open.c                                      | 4 ++++
 tools/testing/selftests/openat2/openat2_test.c | 8 +++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
