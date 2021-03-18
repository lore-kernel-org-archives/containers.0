Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B9B6C433DB
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:45 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B31D764E42
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 05:17:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B31D764E42
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 7818C60667;
	Thu, 18 Mar 2021 05:17:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sCpa6q78E6bm; Thu, 18 Mar 2021 05:17:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 6BC696063C;
	Thu, 18 Mar 2021 05:17:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4BF3DC000B;
	Thu, 18 Mar 2021 05:17:43 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D39A8C0001
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id B36E143090
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XDqXZT-o7RfA
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:41 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qk1-x734.google.com (mail-qk1-x734.google.com
 [IPv6:2607:f8b0:4864:20::734])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 0CBC141566
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 05:17:40 +0000 (UTC)
Received: by mail-qk1-x734.google.com with SMTP id l132so878368qke.7
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Mar 2021 22:17:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=tjrc14KmBB1hkBJdqFGZfVa5j4ziojEzWH0yoigYsOQ=;
 b=BNDcO1YQkqtwOJ5vW/Mrq2utCF9JzSRrfjmYKYU69Hp/kEYiCaBycCDBwmV5BuoMQO
 rKRJCrd4qQnCF4qTntd9IrMJb+Vl9OuODGVDBmsZspBIHhOsyobRMpkoy+CBIpu/dTlg
 YBr1i0jPuGK01INjVtNtbWBSYC3gti7EPy6ng=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=tjrc14KmBB1hkBJdqFGZfVa5j4ziojEzWH0yoigYsOQ=;
 b=nwu1K9XWRzZN/KQ1RC6/vuUl50YdVoYKVjfeuCiddaDt3LR8fFlyDytvqi2MwQqvFb
 DvALzwjQN6bXi8fJueLW+eNNAxI3bm0js+oLOt95R4/bZanByKj6lNWoH7iPDVICvgoo
 zgCh49uwmxyjDgxsdq8U8H7XOQ/VP4iDMZlT24J34Dd+PZyk/ndlwX6btz1FxnoV1rYO
 dXgrDkCAh0MSEJFNpihCe1D35mwQPj9Qxyue4oljpZswBabajXLCR+7Pc3BRJLZ2bbye
 atw/f7auRopEDG30IL7H2gpOoyqtCAJo9dp4m5Ayb5Wkxv8CAC0MTfh+run7TfZWg4mx
 zDsw==
X-Gm-Message-State: AOAM531nfPDSOKPAAQVAi3TQ17kLGNvuH0mkBUbuGC0q33FzhiyObWbh
 asDvjLQ2jQSHSWnuKUScpqE7hQ==
X-Google-Smtp-Source: ABdhPJy1MFxgXQBRX0shqkm/qaDX7yKageM7zHeBypvJ6vyFd/8W9qhypZNWkvCYpxOy65V5W+P/VQ==
X-Received: by 2002:a37:a8cc:: with SMTP id r195mr2754430qke.86.1616044659537; 
 Wed, 17 Mar 2021 22:17:39 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id m16sm937852qkm.100.2021.03.17.22.17.37
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 17 Mar 2021 22:17:38 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH 1/5] seccomp: Refactor notification handler to prepare for new
 semantics
Date: Wed, 17 Mar 2021 22:17:29 -0700
Message-Id: <20210318051733.2544-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210318051733.2544-1-sargun@sargun.me>
References: <20210318051733.2544-1-sargun@sargun.me>
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>
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

This refactors the user notification code to have a do / while loop around
the completion condition. This has a small change in semantic, in that
previously we ignored addfd calls upon wakeup if the notification had been
responded to, but instead with the new change we check for an outstanding
addfd calls prior to returning to userspace.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 kernel/seccomp.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 952dc1c90229..b48fb0a29455 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1098,28 +1098,30 @@ static int seccomp_do_user_notification(int this_syscall,
 
 	up(&match->notif->request);
 	wake_up_poll(&match->wqh, EPOLLIN | EPOLLRDNORM);
-	mutex_unlock(&match->notify_lock);
 
 	/*
 	 * This is where we wait for a reply from userspace.
 	 */
-wait:
-	err = wait_for_completion_interruptible(&n.ready);
-	mutex_lock(&match->notify_lock);
-	if (err == 0) {
-		/* Check if we were woken up by a addfd message */
+	do {
+		mutex_unlock(&match->notify_lock);
+		err = wait_for_completion_interruptible(&n.ready);
+		mutex_lock(&match->notify_lock);
+		if (err != 0)
+			goto interrupted;
+
 		addfd = list_first_entry_or_null(&n.addfd,
 						 struct seccomp_kaddfd, list);
-		if (addfd && n.state != SECCOMP_NOTIFY_REPLIED) {
+		/* Check if we were woken up by a addfd message */
+		if (addfd)
 			seccomp_handle_addfd(addfd);
-			mutex_unlock(&match->notify_lock);
-			goto wait;
-		}
-		ret = n.val;
-		err = n.error;
-		flags = n.flags;
-	}
 
+	}  while (n.state != SECCOMP_NOTIFY_REPLIED);
+
+	ret = n.val;
+	err = n.error;
+	flags = n.flags;
+
+interrupted:
 	/* If there were any pending addfd calls, clear them out */
 	list_for_each_entry_safe(addfd, tmp, &n.addfd, list) {
 		/* The process went away before we got a chance to handle it */
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
