Return-Path: <SRS0=O+XM=JK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B29C433ED
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:02:57 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4052660C40
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:02:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4052660C40
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 1427683DE4;
	Tue, 13 Apr 2021 16:02:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mRgqDmmtWXEW; Tue, 13 Apr 2021 16:02:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0768C83DBF;
	Tue, 13 Apr 2021 16:02:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E60B6C000B;
	Tue, 13 Apr 2021 16:02:55 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7DE47C000A
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 6476260C02
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id dJbftyBz1y6j
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:54 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-ed1-x52f.google.com (mail-ed1-x52f.google.com
 [IPv6:2a00:1450:4864:20::52f])
 by smtp3.osuosl.org (Postfix) with ESMTPS id ECBC360C00
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:53 +0000 (UTC)
Received: by mail-ed1-x52f.google.com with SMTP id f8so20009411edd.11
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 09:02:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=3FvqmXbTPGrExPdYFPrOm7MfDEznWQ3cYJunL5tX4XI=;
 b=QnUaa/ObnOTdkd9TXid6IcrAuQRmrpANhQd/Cl/ecdkS4vV8JdhUGaB3TX1BaZEkJl
 OLPkpNcWWih05sUoZGIts+wX+ho3yP3gfTX24SzZEnp3WBBUiOxgJ7OBlJeQTJ9vufc4
 EeDy1jwWolYm8HcDn75LtEXjHw3X39ADV84RU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=3FvqmXbTPGrExPdYFPrOm7MfDEznWQ3cYJunL5tX4XI=;
 b=VrVZ2/lMcI5dJjOa3hCg8Swp0Ijk97/XI0L9n5rSE5XhFodwDU6O/InHYanA2R9Zz6
 eULVzogZIz97631fIe5S4bO5bhL+s+FXDme/bvzU/yoLnvaGx4l49Mh/AWzthljJ4+qc
 K6biAcNZug0mWHq/j6yZJmjvfPWaf3BJ7ALNepCXvDBdxCXRZh3UxKWxtr0beHsLxWvp
 h77fSZdYvdAIF0CD6pe6Az0Hx0igvcQcHg/0uzlpVSgCxhODjpUkfNkN85Z4UUfCJumr
 rnowQGMCI+SEHmpvCwHr6ZTDXoWVC/1QUTBZ0z51jVp7FNB1zLkUcZ2ssuGWsFc+vnzy
 jaiA==
X-Gm-Message-State: AOAM532CfyemZ7tycVpdhYvtJC1yk624oO3JQlW8U4gmT6mmgIwbfNtq
 Nm+QRjST4F7u7hYwE7R2fOWWYw==
X-Google-Smtp-Source: ABdhPJxiZ+44bDa0LRDztD06kkg+VeqXHdVoBjsBPwk4/EjYsZpLyi+eafqUP7UkUkNMecAXtkdv2A==
X-Received: by 2002:a50:82e5:: with SMTP id 92mr263078edg.141.1618329772096;
 Tue, 13 Apr 2021 09:02:52 -0700 (PDT)
Received: from localhost.localdomain
 ([2a02:8109:9880:57f0:ba7c:cdd5:fff7:623c])
 by smtp.gmail.com with ESMTPSA id gb4sm8162852ejc.122.2021.04.13.09.02.50
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 13 Apr 2021 09:02:51 -0700 (PDT)
From: Rodrigo Campos <rodrigo@kinvolk.io>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>,
 Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
 containers@lists.linux-foundation.org
Subject: [PATCH 1/1] seccomp: Always "goto wait" if the list is empty
Date: Tue, 13 Apr 2021 18:01:51 +0200
Message-Id: <20210413160151.3301-2-rodrigo@kinvolk.io>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210413160151.3301-1-rodrigo@kinvolk.io>
References: <20210413160151.3301-1-rodrigo@kinvolk.io>
MIME-Version: 1.0
Cc: Alban Crequy <alban@kinvolk.io>, stable@vger.kernel.org
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

It is possible for the thread with the seccomp filter attached (target)
to be waken up by an addfd message, but the list be empty. This happens
when the addfd ioctl on the other side (seccomp agent) is interrupted by
a signal such as SIGURG. In that case, the target erroneously and
prematurely returns from the syscall to userspace even though the
seccomp agent didn't ask for it.

This happens in the following scenario:

seccomp_notify_addfd()                                           | seccomp_do_user_notification()
                                                                 |
                                                                 |  err = wait_for_completion_interruptible(&n.ready);
 complete(&knotif->ready);                                       |
 ret = wait_for_completion_interruptible(&kaddfd.completion);    |
 // interrupted                                                  |
                                                                 |
 mutex_lock(&filter->notify_lock);                               |
 list_del(&kaddfd.list);                                         |
 mutex_unlock(&filter->notify_lock);                             |
                                                                 |  mutex_lock(&match->notify_lock);
                                                                 |  // This is false, addfd is false
                                                                 |  if (addfd && n.state != SECCOMP_NOTIFY_REPLIED)
                                                                 |
                                                                 |  ret = n.val;
                                                                 |  err = n.error;
                                                                 |  flags = n.flags;

So, the process blocked in seccomp_do_user_notification() will see a
response. As n is 0 initialized and wasn't set, it will see a 0 as
return value from the syscall.

The seccomp agent, when retrying the interrupted syscall, will see an
ENOENT error as the notification no longer exists (it was already
answered by this bug).

This patch fixes the issue by splitting the if in two parts: if we were
woken up and the state is not replied, we will always do a "goto wait".
And if that happens and there is an addfd element on the list, we will
add the fd before "goto wait".

This issue is present since 5.9, when addfd was added.

Fixes: 7cf97b1254550
Cc: stable@vger.kernel.org # 5.9+
Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
---
 kernel/seccomp.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 63b40d12896b..1b34598f0e07 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1107,11 +1107,20 @@ static int seccomp_do_user_notification(int this_syscall,
 	err = wait_for_completion_interruptible(&n.ready);
 	mutex_lock(&match->notify_lock);
 	if (err == 0) {
-		/* Check if we were woken up by a addfd message */
-		addfd = list_first_entry_or_null(&n.addfd,
-						 struct seccomp_kaddfd, list);
-		if (addfd && n.state != SECCOMP_NOTIFY_REPLIED) {
-			seccomp_handle_addfd(addfd);
+
+		if (n.state != SECCOMP_NOTIFY_REPLIED) {
+			/*
+			 * It is possible to be waken-up by an addfd message but
+			 * the list be empty. This can happen if the addfd
+			 * ioctl() is interrupted, as it deletes the element.
+			 *
+			 * So, check if indeed there is an element in the list.
+			 */
+			addfd = list_first_entry_or_null(&n.addfd,
+							 struct seccomp_kaddfd, list);
+			if (addfd)
+				seccomp_handle_addfd(addfd);
+
 			mutex_unlock(&match->notify_lock);
 			goto wait;
 		}
-- 
2.30.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
