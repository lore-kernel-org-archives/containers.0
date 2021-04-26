Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EFC8C433B4
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:22 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8A62761009
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A62761009
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 2DDFE833CE;
	Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id maLGHi8dDrzU; Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 302D1833A8;
	Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1AECBC0019;
	Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8675EC000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 7469160784
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id VlaR2ppR7hs3
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:16 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pj1-x1035.google.com (mail-pj1-x1035.google.com
 [IPv6:2607:f8b0:4864:20::1035])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 640B960665
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:16 +0000 (UTC)
Received: by mail-pj1-x1035.google.com with SMTP id
 gc22-20020a17090b3116b02901558435aec1so2038630pjb.4
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 11:06:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=yvvWfDpwWO3ix59OkIRp3h1Jl4vMPwqFCck+Jadu5y4=;
 b=DTKiwqgmSXVkLSB4mUHqG7bKxdVDlE9X6RM0AXRf3lPDkYbiDQlvBtxhU1MzIZ2yOR
 NzPrK1Ou0/OLl8XYcEiQ1GEN6YjxGKNR3ecMRTToV56L2XRTimm16m6uJrJWVJuf60Hn
 Z+jjJFQArDSaySvk+rWBfuYKI4fj56E13sfsI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=yvvWfDpwWO3ix59OkIRp3h1Jl4vMPwqFCck+Jadu5y4=;
 b=ku6LFWMNXLszIQSAlgjFMyHbPjiUVJIFnY+75N2s2PtWHZAnSUlMsy2apnbCNc950L
 WVJHhOBJy9PuU5oUsnymElexOssCnTQhbvhI22LlXkbJcp+I+CJOAPKDjLcOlSRxVREa
 4s/zq9+bhQCvNUw/q/8NldxnK5a6YjKdCfj57hpbrpaQ1GVwM7ULbNWgNC+HwG9bLK8S
 OP9fJanYHTnNz8NACd3Cw4IpVMXxlVr3ngc5SEYj2jtZBcfn9GuTmjhj9Ca2v4JoeWYl
 WuFzCtpsEv+wwRDBDwIdwhQAcc6qXzCnVnUJyUMMaRQu7008Mw+Eb4WXw0SoLEuAeylo
 LF0A==
X-Gm-Message-State: AOAM530v9HjMy0Ger33RTZBC78vQMSY9anV0cVv4SAWNh/ZNzCfT55wr
 /iDoQwT5xebGw5nmcV4JiTlp5w==
X-Google-Smtp-Source: ABdhPJzkd9NmqETqvyFyb8gmDUYMADNOsweB44ohK3fCHQERLhb4U1n/2bncb2/2smPep5BwqyvE/g==
X-Received: by 2002:a17:90a:7893:: with SMTP id
 x19mr23411762pjk.3.1619460375770; 
 Mon, 26 Apr 2021 11:06:15 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id j7sm326835pfd.129.2021.04.26.11.06.14
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 26 Apr 2021 11:06:15 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Rodrigo Campos <rodrigo@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
Subject: [PATCH RESEND 1/5] seccomp: Refactor notification handler to prepare
 for new semantics
Date: Mon, 26 Apr 2021 11:06:06 -0700
Message-Id: <20210426180610.2363-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210426180610.2363-1-sargun@sargun.me>
References: <20210426180610.2363-1-sargun@sargun.me>
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Andy Lutomirski <luto@amacapital.net>, Alban Crequy <alban@kinvolk.io>
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
index 1d60fc2c9987..93684cc63285 100644
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
