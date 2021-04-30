Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3F8CC433ED
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8E17F6145A
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E17F6145A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 63C41418E5;
	Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NiLREPpPclce; Fri, 30 Apr 2021 20:49:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id C3C3D41936;
	Fri, 30 Apr 2021 20:49:52 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A2626C000E;
	Fri, 30 Apr 2021 20:49:52 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 305C8C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 1F44D41936
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 4dFqaflCqIo3
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:49 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qv1-xf2b.google.com (mail-qv1-xf2b.google.com
 [IPv6:2607:f8b0:4864:20::f2b])
 by smtp4.osuosl.org (Postfix) with ESMTPS id C76C8418E5
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:49 +0000 (UTC)
Received: by mail-qv1-xf2b.google.com with SMTP id j3so35107994qvs.1
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 13:49:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=f6hiECWGoT1hxWQM2wlygrLr/LE0MxB0mzr7hlbBbFU=;
 b=PQG24a2KhhYzIPqfLxueo+WQUJoCcfVq8tX75f6OIFsAbeI/ttxz7Gjx6gUlcPCO3H
 n8nREyH7O6gRcuUN7dOD8pD2eOshOiq2vHkSAo+r9qVaZZWkVXInFTDE0ICi0hI7b4eO
 f1tmVUzK9YnxI5HpA6adXPmP0b1kQOQJjOI4I=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=f6hiECWGoT1hxWQM2wlygrLr/LE0MxB0mzr7hlbBbFU=;
 b=gUrGiHR7Vq+KfJgnJbolYrs2AItyacdub13EfhkLEpJyl1gh0NXgvrl6/IiRn5jFAN
 99MczAgreouQlfU2AgNA93CxCeQFgab9p9kMMbzZCjboc6xy1XjoG+CB9Tpr8YdLZNNG
 zvMH0MJzU/jZt0I6+KhY0TtD+2dMW8T9Ah7E2k7mhsNRJf0OC1o22ATVv5f03xyZ96o7
 dMkOlmgiM7k61QBJhJjY0LZnk+gK/42FaSsVEMesE2j3Dmw2txQUnJ5j58ng4p6HMheb
 arPgBmmLAxI3LD7uHPOWQZuU8qzdbo3Hf0cop+VUJzZoos+Vt/oWxzoR8gim/4hqVr44
 hDGA==
X-Gm-Message-State: AOAM532eywC6M/dy/kQlAcZxK3uExqNlMKzOyc6q1ufeg9D2vnt/dR+m
 /HQNmQHrwSoYemQwcWa/Wjd4ZA==
X-Google-Smtp-Source: ABdhPJxar8jIOfuX8TkN2pgDfEPH5cW+9ONSiPXGrD24b6+sfEcFosfKRvdHzXdeovEYPwbhkIOIRQ==
X-Received: by 2002:a0c:a98d:: with SMTP id a13mr7591877qvb.39.1619815788383; 
 Fri, 30 Apr 2021 13:49:48 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id z17sm3161960qtf.10.2021.04.30.13.49.46
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 30 Apr 2021 13:49:47 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH v2 2/5] seccomp: Add wait_killable semantic to seccomp user
 notifier
Date: Fri, 30 Apr 2021 13:49:36 -0700
Message-Id: <20210430204939.5152-3-sargun@sargun.me>
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
 .../userspace-api/seccomp_filter.rst          | 22 +++---
 include/uapi/linux/seccomp.h                  |  2 +
 kernel/seccomp.c                              | 71 ++++++++++++++++++-
 3 files changed, 85 insertions(+), 10 deletions(-)

diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
index bd9165241b6c..6ba4d39baf2a 100644
--- a/Documentation/userspace-api/seccomp_filter.rst
+++ b/Documentation/userspace-api/seccomp_filter.rst
@@ -250,14 +250,20 @@ Users can read via ``ioctl(SECCOMP_IOCTL_NOTIF_RECV)``  (or ``poll()``) on a
 seccomp notification fd to receive a ``struct seccomp_notif``, which contains
 five members: the input length of the structure, a unique-per-filter ``id``,
 the ``pid`` of the task which triggered this request (which may be 0 if the
-task is in a pid ns not visible from the listener's pid namespace), a ``flags``
-member which for now only has ``SECCOMP_NOTIF_FLAG_SIGNALED``, representing
-whether or not the notification is a result of a non-fatal signal, and the
-``data`` passed to seccomp. Userspace can then make a decision based on this
-information about what to do, and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a
-response, indicating what should be returned to userspace. The ``id`` member of
-``struct seccomp_notif_resp`` should be the same ``id`` as in ``struct
-seccomp_notif``.
+task is in a pid ns not visible from the listener's pid namespace). The
+notification also contains the ``data`` passed to seccomp, and a currently
+unused filters flag.
+
+Upon receiving the notification ``ioctl(SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE)``
+can be used to make the notifying task only respond to fatal signals. Once the
+notification has been set as wait_killable, it cannot be unset. If the
+notification is already in the wait_killable state, EALREADY will be returned by
+the ioctl.
+
+Userspace can then make a decision based on this information about what to do,
+and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a response, indicating what should be
+returned to userspace. The ``id`` member of ``struct seccomp_notif_resp`` should
+be the same ``id`` as in ``struct seccomp_notif``.
 
 It is worth noting that ``struct seccomp_data`` contains the values of register
 arguments to the syscall, but does not contain pointers to memory. The task's
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 6ba18b82a02e..71dbc1f7889f 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -146,5 +146,7 @@ struct seccomp_notif_addfd {
 /* On success, the return value is the remote process's added fd number */
 #define SECCOMP_IOCTL_NOTIF_ADDFD	SECCOMP_IOW(3, \
 						struct seccomp_notif_addfd)
+/* Set flag to prevent non-fatal signal preemption */
+#define SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE	SECCOMP_IOW(4, __u64)
 
 #endif /* _UAPI_LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 93684cc63285..7ac1cea6e7f0 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -97,6 +97,8 @@ struct seccomp_knotif {
 
 	/* outstanding addfd requests */
 	struct list_head addfd;
+
+	bool wait_killable;
 };
 
 /**
@@ -1073,6 +1075,12 @@ static void seccomp_handle_addfd(struct seccomp_kaddfd *addfd)
 	complete(&addfd->completion);
 }
 
+/* Must be called with notify_lock held */
+static inline bool notification_wait_killable(struct seccomp_knotif *n)
+{
+	return n->state == SECCOMP_NOTIFY_SENT && n->wait_killable;
+}
+
 static int seccomp_do_user_notification(int this_syscall,
 					struct seccomp_filter *match,
 					const struct seccomp_data *sd)
@@ -1103,11 +1111,33 @@ static int seccomp_do_user_notification(int this_syscall,
 	 * This is where we wait for a reply from userspace.
 	 */
 	do {
+		int wait_killable = notification_wait_killable(&n);
+
 		mutex_unlock(&match->notify_lock);
-		err = wait_for_completion_interruptible(&n.ready);
+		if (wait_killable)
+			err = wait_for_completion_killable(&n.ready);
+		else
+			err = wait_for_completion_interruptible(&n.ready);
 		mutex_lock(&match->notify_lock);
-		if (err != 0)
+		if (err != 0) {
+			/*
+			 * If the SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE was
+			 * used to change the state of the handler to
+			 * wait_killable, but a non-fatal signal arrived
+			 * before we could complete the transition, we could
+			 * erroneously finish waiting early.
+			 *
+			 * If we were previously in not in the wait_killable
+			 * state and we've transitioned to the wait_killable
+			 * state, retry waiting. wait_for_completion_killable
+			 * will check again if there is a fatal signal waiting,
+			 * or another completion (addfd).
+			 */
+			if (!wait_killable && notification_wait_killable(&n))
+				continue;
+
 			goto interrupted;
+		}
 
 		addfd = list_first_entry_or_null(&n.addfd,
 						 struct seccomp_kaddfd, list);
@@ -1477,6 +1507,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 		if (knotif) {
 			knotif->state = SECCOMP_NOTIFY_INIT;
 			up(&filter->notif->request);
+
+			/* Wake the task to reset its state */
+			if (knotif->wait_killable) {
+				knotif->wait_killable = false;
+				complete(&knotif->ready);
+			}
 		}
 		mutex_unlock(&filter->notify_lock);
 	}
@@ -1648,6 +1684,35 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 	return ret;
 }
 
+static long seccomp_notify_set_wait_killable(struct seccomp_filter *filter,
+					     void __user *buf)
+{
+	struct seccomp_knotif *knotif;
+	u64 id;
+	long ret;
+
+	if (copy_from_user(&id, buf, sizeof(id)))
+		return -EFAULT;
+
+	ret = mutex_lock_interruptible(&filter->notify_lock);
+	if (ret < 0)
+		return ret;
+
+	knotif = find_notification(filter, id);
+	if (!knotif || knotif->state != SECCOMP_NOTIFY_SENT) {
+		ret = -ENOENT;
+	} else if (knotif->wait_killable) {
+		ret = -EALREADY;
+	} else {
+		ret = 0;
+		knotif->wait_killable = true;
+		complete(&knotif->ready);
+	}
+
+	mutex_unlock(&filter->notify_lock);
+	return ret;
+}
+
 static long seccomp_notify_ioctl(struct file *file, unsigned int cmd,
 				 unsigned long arg)
 {
@@ -1663,6 +1728,8 @@ static long seccomp_notify_ioctl(struct file *file, unsigned int cmd,
 	case SECCOMP_IOCTL_NOTIF_ID_VALID_WRONG_DIR:
 	case SECCOMP_IOCTL_NOTIF_ID_VALID:
 		return seccomp_notify_id_valid(filter, buf);
+	case SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE:
+		return seccomp_notify_set_wait_killable(filter, buf);
 	}
 
 	/* Extensible Argument ioctls */
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
