Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05A36C433B4
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:24 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4255361009
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 18:06:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4255361009
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id D3BA94041B;
	Mon, 26 Apr 2021 18:06:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sr70-o_JBOcB; Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 55BA540441;
	Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 33AFEC000E;
	Mon, 26 Apr 2021 18:06:21 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 06DE5C000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id E987D400D5
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id I7gZ2GAa4zfw
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:18 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pl1-x62d.google.com (mail-pl1-x62d.google.com
 [IPv6:2607:f8b0:4864:20::62d])
 by smtp2.osuosl.org (Postfix) with ESMTPS id C1706400CE
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 18:06:18 +0000 (UTC)
Received: by mail-pl1-x62d.google.com with SMTP id h7so811802plt.1
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 11:06:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=XrSljs9p2akWCSedVPpNDBp3AdI7AQvDDvYRJ1g+BNw=;
 b=hX1O4cmxzHz/96wKySXNVSy1o/tuOKNg/8w3w5HOz3YzxjR6S9pGew+OWoSnJQlFgQ
 gnR+juglV+HGK3xVfQdnNeSyRhxGBEo3bgXf53IqqBNBiA7Fy1BJvRt3dU0/vz2fjWuS
 45OHIPX6jweV+kHhQCnBZN+APHzihpt0M34v8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=XrSljs9p2akWCSedVPpNDBp3AdI7AQvDDvYRJ1g+BNw=;
 b=GIa5A6JL4D2dIQeF+ps5I28fEL4NxE7xngwuAESNRopwvTIx+ryLYCLOqGjTrPTkEa
 3TroPzbr+MsAB/6NtAJDVQLniG6Yt6rIZAZVadij3kMyt303IoXqD4QIsmGjYGxckwF9
 EtnVAvFvTZAz2Cjir0cj2gel5/fb/dvSM0CUdE9lbVSbbvWVE1A26JysD4hIOh8eDe8h
 8mB39IRzQyrUP4ITnyctx3if+6jNvS9obvv8T2MyNcp8rtSOrPw+FhM3iltIJGg0ae/D
 vcz0BInXjVjJRS6xR77y1xh1O2jE7DxuOMu53ZET3kmUko5krhs0/oTMmfrTgw7JiPIA
 BJQQ==
X-Gm-Message-State: AOAM530x+laaFnnxEmCLTbJwCQ6cNdiriLvsxBPVPDpzK8aZ2dsieZzS
 4D/jizifwzqlbREce2uaNLQvrw==
X-Google-Smtp-Source: ABdhPJz/Jxxy2ss20n/gYw5KrTowBECBp8mQNBFk6Vd+p+7JDws2uMYJI83Ssqwz3dgPHNb0PmJE8w==
X-Received: by 2002:a17:90a:ea11:: with SMTP id w17mr365736pjy.6.1619460377881; 
 Mon, 26 Apr 2021 11:06:17 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id j7sm326835pfd.129.2021.04.26.11.06.15
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 26 Apr 2021 11:06:17 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Rodrigo Campos <rodrigo@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
Subject: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
Date: Mon, 26 Apr 2021 11:06:07 -0700
Message-Id: <20210426180610.2363-3-sargun@sargun.me>
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

The user notifier feature allows for filtering of seccomp notifications in
userspace. While the user notifier is handling the syscall, the notifying
process can be preempted, thus ending the notification. This has become a
growing problem, as Golang has adopted signal based async preemption[1]. In
this, it will preempt every 10ms, thus leaving the supervisor less than
10ms to respond to a given notification. If the syscall require I/O (mount,
connect) on behalf of the process, it can easily take 10ms.

This allows the supervisor to set a flag that moves the process into a
state where it is only killable by terminating signals as opposed to all
signals. The process can still be terminated before the supervisor receives
the notification.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>

[1]: https://github.com/golang/go/issues/24543
---
 .../userspace-api/seccomp_filter.rst          | 15 +++---
 include/uapi/linux/seccomp.h                  |  3 ++
 kernel/seccomp.c                              | 54 ++++++++++++++++---
 3 files changed, 58 insertions(+), 14 deletions(-)

diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
index bd9165241b6c..75de9400d56a 100644
--- a/Documentation/userspace-api/seccomp_filter.rst
+++ b/Documentation/userspace-api/seccomp_filter.rst
@@ -251,13 +251,14 @@ seccomp notification fd to receive a ``struct seccomp_notif``, which contains
 five members: the input length of the structure, a unique-per-filter ``id``,
 the ``pid`` of the task which triggered this request (which may be 0 if the
 task is in a pid ns not visible from the listener's pid namespace), a ``flags``
-member which for now only has ``SECCOMP_NOTIF_FLAG_SIGNALED``, representing
-whether or not the notification is a result of a non-fatal signal, and the
-``data`` passed to seccomp. Userspace can then make a decision based on this
-information about what to do, and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a
-response, indicating what should be returned to userspace. The ``id`` member of
-``struct seccomp_notif_resp`` should be the same ``id`` as in ``struct
-seccomp_notif``.
+member and the ``data`` passed to seccomp. Upon receiving the notification,
+the ``SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE`` flag may be set, which will
+try to put the task into a state where it will only respond to fatal signals.
+
+Userspace can then make a decision based on this information about what to do,
+and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a response, indicating what should be
+returned to userspace. The ``id`` member of ``struct seccomp_notif_resp`` should
+be the same ``id`` as in ``struct seccomp_notif``.
 
 It is worth noting that ``struct seccomp_data`` contains the values of register
 arguments to the syscall, but does not contain pointers to memory. The task's
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 6ba18b82a02e..bc7fc8b04749 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -70,6 +70,9 @@ struct seccomp_notif_sizes {
 	__u16 seccomp_data;
 };
 
+/* Valid flags for struct seccomp_notif */
+#define SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE	(1UL << 0) /* Prevent task from being interrupted */
+
 struct seccomp_notif {
 	__u64 id;
 	__u32 pid;
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 93684cc63285..b852e8617004 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -97,6 +97,8 @@ struct seccomp_knotif {
 
 	/* outstanding addfd requests */
 	struct list_head addfd;
+
+	bool wait_killable;
 };
 
 /**
@@ -1073,6 +1075,11 @@ static void seccomp_handle_addfd(struct seccomp_kaddfd *addfd)
 	complete(&addfd->completion);
 }
 
+static bool notification_interruptible(struct seccomp_knotif *n)
+{
+	return !(n->state == SECCOMP_NOTIFY_SENT && n->wait_killable);
+}
+
 static int seccomp_do_user_notification(int this_syscall,
 					struct seccomp_filter *match,
 					const struct seccomp_data *sd)
@@ -1082,6 +1089,7 @@ static int seccomp_do_user_notification(int this_syscall,
 	long ret = 0;
 	struct seccomp_knotif n = {};
 	struct seccomp_kaddfd *addfd, *tmp;
+	bool interruptible = true;
 
 	mutex_lock(&match->notify_lock);
 	err = -ENOSYS;
@@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
 	 * This is where we wait for a reply from userspace.
 	 */
 	do {
+		interruptible = notification_interruptible(&n);
+
 		mutex_unlock(&match->notify_lock);
-		err = wait_for_completion_interruptible(&n.ready);
+		if (interruptible)
+			err = wait_for_completion_interruptible(&n.ready);
+		else
+			err = wait_for_completion_killable(&n.ready);
 		mutex_lock(&match->notify_lock);
-		if (err != 0)
+
+		if (err != 0) {
+			/*
+			 * There is a race condition here where if the
+			 * notification was received with the
+			 * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
+			 * non-fatal signal was received before we could
+			 * transition we could erroneously end our wait early.
+			 *
+			 * The next wait for completion will ensure the signal
+			 * was not fatal.
+			 */
+			if (interruptible && !notification_interruptible(&n))
+				continue;
+
 			goto interrupted;
+		}
 
 		addfd = list_first_entry_or_null(&n.addfd,
 						 struct seccomp_kaddfd, list);
@@ -1422,14 +1450,16 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
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
@@ -1457,6 +1487,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
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
@@ -1477,6 +1513,10 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 		if (knotif) {
 			knotif->state = SECCOMP_NOTIFY_INIT;
 			up(&filter->notif->request);
+
+			/* Wake the task to reset its state */
+			if (knotif->wait_killable)
+				complete(&knotif->ready);
 		}
 		mutex_unlock(&filter->notify_lock);
 	}
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
