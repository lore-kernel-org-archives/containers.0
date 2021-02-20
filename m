Return-Path: <SRS0=3V/s=HW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6405C433DB
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:12:50 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6CE2E64ED6
	for <containers@archiver.kernel.org>; Sat, 20 Feb 2021 09:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CE2E64ED6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 483C487593;
	Sat, 20 Feb 2021 09:12:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VFjucC6QvykX; Sat, 20 Feb 2021 09:12:49 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 6E37687584;
	Sat, 20 Feb 2021 09:12:49 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4F1FBC000A;
	Sat, 20 Feb 2021 09:12:49 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 54971C0001
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:12:48 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 26D2A6F652
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:12:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wZVfh8ouF-6q
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:12:46 +0000 (UTC)
Received: by smtp3.osuosl.org (Postfix, from userid 1001)
 id 9C8646F65A; Sat, 20 Feb 2021 09:12:46 +0000 (UTC)
X-Greylist: delayed 00:07:10 by SQLgrey-1.8.0
Received: from mail-pg1-f181.google.com (mail-pg1-f181.google.com
 [209.85.215.181])
 by smtp3.osuosl.org (Postfix) with ESMTPS id BACFC6F5B5
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 09:12:19 +0000 (UTC)
Received: by mail-pg1-f181.google.com with SMTP id m2so6922147pgq.5
 for <containers@lists.linux-foundation.org>;
 Sat, 20 Feb 2021 01:12:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=gHoTVMZ1UCBwdJSMckbP0vCuuAUYGs3AMqboTTCk/6s=;
 b=M8jyYb1AfjIub5FpjkEgb8pECdA0sptmR8F+v8kGpyHkMkWx5xgrkrprMX0eQ6f6Kx
 zRWbb/N7GU9/p/7ZNcIWz4/OVtwc90PAhG2/IDuD5mBYpCeJ1f3YRr0JMA4OY3o9mkkD
 hjdn+8Q7mGF769MtadV1iLSubqEk6Umr2T82M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=gHoTVMZ1UCBwdJSMckbP0vCuuAUYGs3AMqboTTCk/6s=;
 b=IXfePn7HmHLMxW3gj0UnHYvPMZHvdQcn5aO6WhiFNA1F9vCi8tPib5fFF/bKoYTwVC
 9XU/WWH4wdMx0lzQLpRjg1BMZ87QoWRwPXJpX/yKJMtw/TBX82EOLNdLcnD46SFt+Bju
 37DokuPfj8JbbbBg6OIXoO968k++SsPV8yLqiJhgUq/Hwr7dEl5B+xEwuBlUgPh+Rfbu
 mgqXSV0A7mnErlXHHhafvzjmMVFexweqKpTQeFbuNPHL70jeEwe45X1zWAdaUmjOjFQh
 sSplVEmOAALdJZEHWXe75U9wR2VvHp94/qoLmMRppmjV9A7I298USknH9+X1alA7Vroc
 gxXQ==
X-Gm-Message-State: AOAM533n5uqjiAzj32TYIF2vgXGnP/6jRT4xcV+ITKw2IStUGYlPxYRa
 H9srUzDI6kA3aoaF+L6mz74a+kSMAJcNvnve
X-Google-Smtp-Source: ABdhPJzApZ6k0Y19OSx4K6RvG/WNKN9UmXIyC/kvlTGF5fypxNXvc2BsMrmCOODYnzulrL3w8peAhA==
X-Received: by 2002:a62:6346:0:b029:1db:a562:be79 with SMTP id
 x67-20020a6263460000b02901dba562be79mr5734559pfb.81.1613811908173; 
 Sat, 20 Feb 2021 01:05:08 -0800 (PST)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id g62sm12226727pgc.32.2021.02.20.01.05.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sat, 20 Feb 2021 01:05:07 -0800 (PST)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [RFC PATCH 2/3] seccomp: Add wait_killable semantic to seccomp user
 notifier
Date: Sat, 20 Feb 2021 01:05:01 -0800
Message-Id: <20210220090502.7202-3-sargun@sargun.me>
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

The user notifier feature allows for filtering of seccomp notifications in
userspace. While the user notifier is handling the syscall, the notifying
process can be preempted, thus ending the notification. This has become a
growing problem, as Golang has adopted signal based async preemption[1]. In
this, it will preempt every 10ms, thus leaving the supervisor less than
10ms to respond to a given notification. If the syscall require I/O (mount,
connect) on behalf of the process, it can easily take 10ms.

This allows the supervisor to set a flag that moves the process into a
state where it is only killable by terminating signals as opposed to all
signals.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>

[1]: https://github.com/golang/go/issues/24543
---
 include/uapi/linux/seccomp.h | 10 ++++++++++
 kernel/seccomp.c             | 35 +++++++++++++++++++++++++++++------
 2 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 6ba18b82a02e..f9acdb58138b 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -70,6 +70,16 @@ struct seccomp_notif_sizes {
 	__u16 seccomp_data;
 };
 
+/*
+ * Valid flags for struct seccomp_notif
+ *
+ * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE
+ *
+ * Prevent the notifying process from being interrupted by non-fatal, unmasked
+ * signals.
+ */
+#define SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE (1UL << 0)
+
 struct seccomp_notif {
 	__u64 id;
 	__u32 pid;
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index b48fb0a29455..f8c6c47df5d8 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -97,6 +97,8 @@ struct seccomp_knotif {
 
 	/* outstanding addfd requests */
 	struct list_head addfd;
+
+	bool wait_killable;
 };
 
 /**
@@ -1082,6 +1084,7 @@ static int seccomp_do_user_notification(int this_syscall,
 	long ret = 0;
 	struct seccomp_knotif n = {};
 	struct seccomp_kaddfd *addfd, *tmp;
+	bool wait_killable = false;
 
 	mutex_lock(&match->notify_lock);
 	err = -ENOSYS;
@@ -1103,8 +1106,14 @@ static int seccomp_do_user_notification(int this_syscall,
 	 * This is where we wait for a reply from userspace.
 	 */
 	do {
+		wait_killable = n.state == SECCOMP_NOTIFY_SENT &&
+				n.wait_killable;
+
 		mutex_unlock(&match->notify_lock);
-		err = wait_for_completion_interruptible(&n.ready);
+		if (wait_killable)
+			err = wait_for_completion_killable(&n.ready);
+		else
+			err = wait_for_completion_interruptible(&n.ready);
 		mutex_lock(&match->notify_lock);
 		if (err != 0)
 			goto interrupted;
@@ -1420,14 +1429,16 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 	struct seccomp_notif unotif;
 	ssize_t ret;
 
+	ret = copy_from_user(&unotif, buf, sizeof(unotif));
+	if (ret)
+		return -EFAULT;
+
 	/* Verify that we're not given garbage to keep struct extensible. */
-	ret = check_zeroed_user(buf, sizeof(unotif));
-	if (ret < 0)
-		return ret;
-	if (!ret)
+	if (unotif.flags & ~(SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE))
 		return -EINVAL;
 
-	memset(&unotif, 0, sizeof(unotif));
+	if (unotif.id || unotif.pid)
+		return -EINVAL;
 
 	ret = down_interruptible(&filter->notif->request);
 	if (ret < 0)
@@ -1455,6 +1466,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 	unotif.pid = task_pid_vnr(knotif->task);
 	unotif.data = *(knotif->data);
 
+	if (unotif.flags & SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE) {
+		knotif->wait_killable = true;
+		complete(&knotif->ready);
+	}
+
+
 	knotif->state = SECCOMP_NOTIFY_SENT;
 	wake_up_poll(&filter->wqh, EPOLLOUT | EPOLLWRNORM);
 	ret = 0;
@@ -1473,6 +1490,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 		mutex_lock(&filter->notify_lock);
 		knotif = find_notification(filter, unotif.id);
 		if (knotif) {
+			/* Reset the waiting state */
+			if (knotif->wait_killable) {
+				knotif->wait_killable = false;
+				complete(&knotif->ready);
+			}
+
 			knotif->state = SECCOMP_NOTIFY_INIT;
 			up(&filter->notif->request);
 		}
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
