Return-Path: <SRS0=3V/s=HW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 309E1C433DB
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:32:15 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8B03364DEC
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:32:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B03364DEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 517C283083
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:32:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d2ZEHvrexNNS for <containers@archiver.kernel.org>;
	Sat, 20 Feb 2021 09:32:13 +0000 (UTC)
Received: by smtp1.osuosl.org (Postfix, from userid 1001)
	id 23CE582611; Sat, 20 Feb 2021 09:32:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6E73283005;
	Sat, 20 Feb 2021 09:32:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 459EEC000A;
	Sat, 20 Feb 2021 09:32:11 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 52296C0001
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:32:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 3DDB0819F6
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:32:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id v3gsOC1wwe3R
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:32:09 +0000 (UTC)
Received: by smtp1.osuosl.org (Postfix, from userid 1001)
 id 6528E83005; Sat, 20 Feb 2021 09:32:09 +0000 (UTC)
X-Greylist: delayed 00:19:49 by SQLgrey-1.8.0
Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com
 [209.85.167.169])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 21EB5819F6
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:32:07 +0000 (UTC)
Received: by mail-oi1-f169.google.com with SMTP id l133so387597oib.4
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 01:32:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=tjrc14KmBB1hkBJdqFGZfVa5j4ziojEzWH0yoigYsOQ=;
 b=VrmIW4+UneAFMDsqqeTSeilJ1bQ+cHdOwjwUqt/cKvsegQ8I0zT+sJyX7gTuRxJu+w
 eVe0IEEI8CST+5I3eVOuQYNIxWkwBRN9S/G67l3kbrbRf5DZVqhKG92F1er9hT+YOW7f
 KBEjh5Fo8NGNzaCImKL02HfC/OjpH3f7I/rdY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=tjrc14KmBB1hkBJdqFGZfVa5j4ziojEzWH0yoigYsOQ=;
 b=HKvpBd/l4RVYh6rua3mjfTnr7esqROwY/GykzUf9iCdmMDY60Y1zJTref5UuJcsg4e
 R9JnjE3r73iNghleWZU6khjvkwOm/7/IUA7KF2Vei839MEzByXDxf1mMBKtK9OjmONuU
 45267FuADJGqEjZcFWihcJQitZei99Kw9FARzXGp3FLlrKOjlm7zxjXweu7UebLIwj6S
 WBIdsyx8OUZDtfHYMVW2LgWkblNmmNKgvj6sybt7Tmfrt2CcDQkjujGb3INHtItCjUFH
 d1sdpQhj6LUsCPoFuoG8kf+/5tdJN5paHgTpy64NcdGGgKpQQ2H+dzNY/mc1Xz59mb7p
 3W8Q==
X-Gm-Message-State: AOAM532vAkGWqoYxji0RrF1aG9A3rOZ0x4uNJ8mjvIAEcSNqsz2CZn7N
 73bigoELu0h8L8C46qEjOj2iWtNmEPh+JLxi
X-Google-Smtp-Source: ABdhPJz094JJ3xmfNfxZv/GeQsB+caBUOMeT6Va+aC9jLEd0bc46PTH++lh23Bl+esNQq6LVFOJcCQ==
X-Received: by 2002:a17:90a:1a0b:: with SMTP id
 11mr12819117pjk.58.1613811907058; 
 Sat, 20 Feb 2021 01:05:07 -0800 (PST)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id g62sm12226727pgc.32.2021.02.20.01.05.06
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sat, 20 Feb 2021 01:05:06 -0800 (PST)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [RFC PATCH 1/3] seccomp: Refactor notification handler to prepare for
 new semantics
Date: Sat, 20 Feb 2021 01:05:00 -0800
Message-Id: <20210220090502.7202-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210220090502.7202-1-sargun@sargun.me>
References: <20210220090502.7202-1-sargun@sargun.me>
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
