Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22DDEC433ED
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:52 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BE4AF6145B
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE4AF6145B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 99F5F6F9DC;
	Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UrKn0S8JFVIP; Fri, 30 Apr 2021 20:49:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id AD9D86080F;
	Fri, 30 Apr 2021 20:49:50 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8E666C000E;
	Fri, 30 Apr 2021 20:49:50 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F09F2C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:48 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id CD475419E7
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BJBbEKPq6iGF
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:47 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qv1-xf36.google.com (mail-qv1-xf36.google.com
 [IPv6:2607:f8b0:4864:20::f36])
 by smtp4.osuosl.org (Postfix) with ESMTPS id A1867418E5
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:47 +0000 (UTC)
Received: by mail-qv1-xf36.google.com with SMTP id u7so226269qvv.12
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 13:49:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=vfAsECn/fzRz8G1nJMm0ods0ajgpdWjB1GxnEL0hfI8=;
 b=tBbq4HtjyvEahKkAMBaoBEwoyZPbBrrg3UmsWUO+c+Qq7ICQjcbVNB9vFrv/s14QNj
 j27Vgs4LxA9g40TLXRLaCDxLS9rgrFESOlF4ziTq/B/qAV27XQ8QwUoHUlPUPJRTAgaL
 ZzZcbjbYLBpeGYRSPigkvZRSopYnf0ffRdtBo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=vfAsECn/fzRz8G1nJMm0ods0ajgpdWjB1GxnEL0hfI8=;
 b=AHczNrQaOaOtIdVHr/kN/CLhDFfZ9A0DpAw+1lzMnzjjZzdWdjdnVDW1xmWPmJ/SxW
 86ExCUWhww/kjCPjJ+qndPTzYq8s6L9qtC3zvWBlt19GLm0zwV4OLdVhoI1WNGZ/CZRs
 j/NJvI0LhAcoMdxQBxXF7A5BmCBXvX5SkKDZRVBWyL+hejO4kPRutdMVep9ICI31/2gD
 Aw7gmFuOrYC352NMjwPFG2DZHpfHxsxTXAKdkzLYzq+ip7xWpBjtR0+gnpmQ1/Wmc5Xd
 93xvnx7blorGhomJcUoaP86/wcel5oDETaC2eCHVC+nbI2tSjaiJnGEUs35fazoFksrU
 YcAQ==
X-Gm-Message-State: AOAM533o9opWJ1HcR+zJo6t08a8EZkt3Jii8BZOMP+nk87RkITLpRPcQ
 FTgxmxiBVhVgacqZ4Kd9vqtHYg==
X-Google-Smtp-Source: ABdhPJw322k/IFXM9qiK9oswYTOjH5nXj+Lc8BRL3hVcRdzYjiMoVeqD7LN8zD6rHBzprEnx0KFjQA==
X-Received: by 2002:a0c:9e0f:: with SMTP id p15mr7500368qve.27.1619815786387; 
 Fri, 30 Apr 2021 13:49:46 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id z17sm3161960qtf.10.2021.04.30.13.49.44
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 30 Apr 2021 13:49:45 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH v2 1/5] seccomp: Refactor notification handler to prepare for
 new semantics
Date: Fri, 30 Apr 2021 13:49:35 -0700
Message-Id: <20210430204939.5152-2-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210430204939.5152-1-sargun@sargun.me>
References: <20210430204939.5152-1-sargun@sargun.me>
MIME-Version: 1.0
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

Rodrigo Campos also identified a bug that can result in addfd causing
an early return, when the supervisor didn't actually handle the syscall [1].

[1]: https://lore.kernel.org/lkml/20210413160151.3301-1-rodrigo@kinvolk.io/

Fixes: 7cf97b125455 ("seccomp: Introduce addfd ioctl to seccomp user notifier")
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
