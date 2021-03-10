Return-Path: <SRS0=WE+R=II=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F6AC433E9
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 18:20:26 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 676F164FB3
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 18:20:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 676F164FB3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 431C46F48C;
	Wed, 10 Mar 2021 18:20:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id X-DTQgAAL88f; Wed, 10 Mar 2021 18:20:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 5931E605B1;
	Wed, 10 Mar 2021 18:20:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BC241C0021;
	Wed, 10 Mar 2021 18:20:24 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 43A63C000A
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 333A9430E6
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id R7RADzS_kvGd
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:22 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp2.osuosl.org (Postfix) with ESMTP id 7256042FC6
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 18:20:22 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 6054641781;
 Wed, 10 Mar 2021 18:20:21 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v5 5/5] docs: proc: add documentation about relaxing
 visibility restrictions
Date: Wed, 10 Mar 2021 19:20:00 +0100
Message-Id: <ae5b7c21a54aee1f348f63679522aec2b5cc4b51.1615400395.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1615400395.git.gladkov.alexey@gmail.com>
References: <cover.1615400395.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [0.0.0.0]); Wed, 10 Mar 2021 18:20:21 +0000 (UTC)
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Kees Cook <keescook@chromium.org>
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

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 Documentation/filesystems/proc.rst | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/filesystems/proc.rst b/Documentation/filesystems/proc.rst
index 3daf0e7d1071..9d2985a7aad6 100644
--- a/Documentation/filesystems/proc.rst
+++ b/Documentation/filesystems/proc.rst
@@ -2190,6 +2190,8 @@ available to you and will not allow procfs to be mounted if:
   2. Mount is prohibited if a new mount overrides the readonly option or family
      of atime options.
   3. If any file or non-empty procfs directory is hidden by another filesystem.
+     You can still mount procfs even with overlapped directories if the
+     subset=pid option is used.
 
 Chapter 5: Filesystem behavior
 ==============================
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
