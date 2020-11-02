Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3910C4742C
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:44:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 45365206E5
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:44:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="QDe9svMN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45365206E5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id AE18486582;
	Mon,  2 Nov 2020 20:44:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id i3gYYwJKqkM3; Mon,  2 Nov 2020 20:44:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B64048626F;
	Mon,  2 Nov 2020 20:44:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 88F24C088B;
	Mon,  2 Nov 2020 20:44:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E554EC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:44:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id CF351872F8
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:44:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nFbxB38tVm2F
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:44:11 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f65.google.com (mail-wm1-f65.google.com
 [209.85.128.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5D428872F1
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:44:11 +0000 (UTC)
Received: by mail-wm1-f65.google.com with SMTP id 23so1807933wmg.1
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 12:44:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=N2dn8fgFe5fRxczNSmFQS7yw8JTISYS7N2i9J5NtZuc=;
 b=QDe9svMNReBcHzh2bCvPKSu/QFJXB2Da1D4w8n1UGX3qDCBdfJ8457hcPvaCE6xqGW
 p/7CL1/MoaR/a90xZw9q07qi4m1ZbBHX5FBs9SkH9opMih0rKfszGdK91Q7mI5ZVMMXg
 FyVwusLUbRlbIZ+uqgm+Opeen/TdZbhige8XanW0c7R3YSqAkDZ3G91Q9Xfr2J0sjh1U
 93jcBzaF3rq4sDpvHPGFpuYw9pEZrhZnNU6BJ6dEm682hnXbHFVt5shX0ogTW5E28w97
 M6FvWqLBCSg5yGD4GoXEEzmIcCg6f9MHwhcfmPaKV49THbYz8JNVuIArO1x+cmC9D6UP
 pvrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=N2dn8fgFe5fRxczNSmFQS7yw8JTISYS7N2i9J5NtZuc=;
 b=GfJbYppn32FhJiqWQ5t933cwgyVEHklAEtOje2HqztYgmlmOfnUtAIWPvgzu1GjYtj
 a0UmQCA7GvTzzkGGJmpwlKx/sCmqWLoM1rCt+w1KLaXRfK6nki7J5f4o5S9wl6sbLOwX
 kJVSP2riPajbu8lmNKAQMRexhs16jLBq5GaXk20tWDXjjBTZyjygItvqnYm1RZCytr+j
 iJPMQTH9A7UZX/9DEthIMmmdnLEM2Vxfdv9Lhs8dmSyO1aTOPLR3Ki7ynbMm+NplFJQV
 ju9x9rl3uMBB20F95SK0GvuUb5T+iCuikvhXmsuJOZJ6fNHbKDdsVGrsTBPVTbQHaLY9
 u41g==
X-Gm-Message-State: AOAM532/c8edjswHnMNuCrsOtWlyzXOZar6jqarorr9ji37a+vm4ZTXC
 p43K5dfwvfN8pwJbadH1FMO3nI9wsw8z5w==
X-Google-Smtp-Source: ABdhPJw8+3fvYFDi3rynz2JkkQCX3sLLczVqwfJ/Uai+aDj2g6EeGdsuCJUArn9o8YfGWhtzJULdkw==
X-Received: by 2002:a05:600c:219a:: with SMTP id
 e26mr20840243wme.168.1604349433481; 
 Mon, 02 Nov 2020 12:37:13 -0800 (PST)
Received: from localhost ([2a02:168:96c5:1:55ed:514f:6ad7:5bcc])
 by smtp.gmail.com with ESMTPSA id h4sm23387742wrp.52.2020.11.02.12.37.12
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 02 Nov 2020 12:37:12 -0800 (PST)
To: Kees Cook <keescook@chromium.org>
Subject: [PATCH 1/3] seccomp: Return from SECCOMP_IOCTL_NOTIF_RECV when
 children are gone
Date: Mon,  2 Nov 2020 21:37:04 +0100
Message-Id: <20201102203706.827510-1-jannh@google.com>
X-Mailer: git-send-email 2.29.1.341.ge80a0c044ae-goog
MIME-Version: 1.0
Cc: Giuseppe Scrivano <giuseppe@scrivano.org>, Will Drewry <wad@chromium.org>,
 Paul Moore <paul@paul-moore.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian.brauner@canonical.com>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

At the moment, the seccomp notifier API is hard to use without combining
it with APIs like poll() or epoll(); if all target processes have gone
away, the polling APIs will raise an error indication on the file
descriptor, but SECCOMP_IOCTL_NOTIF_RECV will keep blocking indefinitely.

This usability problem was discovered when Michael Kerrisk wrote a
manpage for this API.

To fix it, get rid of the semaphore logic and let SECCOMP_IOCTL_NOTIF_RECV
behave as follows:

If O_NONBLOCK is set, SECCOMP_IOCTL_NOTIF_RECV always returns
immediately, no matter whether a notification is available or not.

If O_NONBLOCK is unset, SECCOMP_IOCTL_NOTIF_RECV blocks until either a
notification is delivered to userspace or all users of the filter have
gone away.

To avoid subtle breakage from eventloop-style code that doesn't set
O_NONBLOCK, set O_NONBLOCK by default - userspace can clear it if it
wants blocking behavior, and if blocking-style code forgets to do so,
that will be much more obvious than the breakage we'd get the other way
around.
This also means that UAPI breakage from this change should be limited to
blocking users of the API, of which, to my knowledge, there are none so far
(outside of in-tree sample and selftest code, which this patch adjusts - in
particular the code in samples/ has to change a bunch).

This should be backported because future userspace code might otherwise not
work properly on old kernels.

Cc: stable@vger.kernel.org
Reported-by: Michael Kerrisk <mtk.manpages@gmail.com>
Signed-off-by: Jann Horn <jannh@google.com>
---
 kernel/seccomp.c                              | 62 +++++++++++++------
 samples/seccomp/user-trap.c                   | 16 +++++
 tools/testing/selftests/seccomp/seccomp_bpf.c | 21 +++++++
 3 files changed, 79 insertions(+), 20 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 8ad7a293255a..b3730740515f 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -43,6 +43,7 @@
 #include <linux/uaccess.h>
 #include <linux/anon_inodes.h>
 #include <linux/lockdep.h>
+#include <linux/freezer.h>
 
 /*
  * When SECCOMP_IOCTL_NOTIF_ID_VALID was first introduced, it had the
@@ -138,7 +139,6 @@ struct seccomp_kaddfd {
  * @notifications: A list of struct seccomp_knotif elements.
  */
 struct notification {
-	struct semaphore request;
 	u64 next_id;
 	struct list_head notifications;
 };
@@ -863,7 +863,6 @@ static int seccomp_do_user_notification(int this_syscall,
 	list_add(&n.list, &match->notif->notifications);
 	INIT_LIST_HEAD(&n.addfd);
 
-	up(&match->notif->request);
 	wake_up_poll(&match->wqh, EPOLLIN | EPOLLRDNORM);
 	mutex_unlock(&match->notify_lock);
 
@@ -1179,9 +1178,10 @@ find_notification(struct seccomp_filter *filter, u64 id)
 
 
 static long seccomp_notify_recv(struct seccomp_filter *filter,
-				void __user *buf)
+				void __user *buf, bool blocking)
 {
 	struct seccomp_knotif *knotif = NULL, *cur;
+	DEFINE_WAIT(wait);
 	struct seccomp_notif unotif;
 	ssize_t ret;
 
@@ -1194,11 +1194,9 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 
 	memset(&unotif, 0, sizeof(unotif));
 
-	ret = down_interruptible(&filter->notif->request);
-	if (ret < 0)
-		return ret;
-
 	mutex_lock(&filter->notify_lock);
+
+retry:
 	list_for_each_entry(cur, &filter->notif->notifications, list) {
 		if (cur->state == SECCOMP_NOTIFY_INIT) {
 			knotif = cur;
@@ -1206,14 +1204,40 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 		}
 	}
 
-	/*
-	 * If we didn't find a notification, it could be that the task was
-	 * interrupted by a fatal signal between the time we were woken and
-	 * when we were able to acquire the rw lock.
-	 */
 	if (!knotif) {
-		ret = -ENOENT;
-		goto out;
+		if (!blocking) {
+			if (refcount_read(&filter->users) == 0)
+				ret = -ENOTCONN;
+			else
+				ret = -ENOENT;
+			goto out;
+		}
+
+		/* This has to happen before checking &filter->users. */
+		prepare_to_wait(&filter->wqh, &wait, TASK_INTERRUPTIBLE);
+
+		/*
+		 * If all users of the filter are gone, throw an error
+		 * instead of pointlessly continuing to block.
+		 */
+		if (refcount_read(&filter->users) == 0) {
+			finish_wait(&filter->wqh, &wait);
+			ret = -ENOTCONN;
+			goto out;
+		}
+
+		/* No notifications - wait for one... */
+		mutex_unlock(&filter->notify_lock);
+		freezable_schedule();
+		finish_wait(&filter->wqh, &wait);
+
+		/* ... and retry */
+		mutex_lock(&filter->notify_lock);
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			goto out;
+		}
+		goto retry;
 	}
 
 	unotif.id = knotif->id;
@@ -1237,10 +1261,8 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
 		 */
 		mutex_lock(&filter->notify_lock);
 		knotif = find_notification(filter, unotif.id);
-		if (knotif) {
+		if (knotif)
 			knotif->state = SECCOMP_NOTIFY_INIT;
-			up(&filter->notif->request);
-		}
 		mutex_unlock(&filter->notify_lock);
 	}
 
@@ -1416,11 +1438,12 @@ static long seccomp_notify_ioctl(struct file *file, unsigned int cmd,
 {
 	struct seccomp_filter *filter = file->private_data;
 	void __user *buf = (void __user *)arg;
+	bool blocking = !(file->f_flags & O_NONBLOCK);
 
 	/* Fixed-size ioctls */
 	switch (cmd) {
 	case SECCOMP_IOCTL_NOTIF_RECV:
-		return seccomp_notify_recv(filter, buf);
+		return seccomp_notify_recv(filter, buf, blocking);
 	case SECCOMP_IOCTL_NOTIF_SEND:
 		return seccomp_notify_send(filter, buf);
 	case SECCOMP_IOCTL_NOTIF_ID_VALID_WRONG_DIR:
@@ -1483,12 +1506,11 @@ static struct file *init_listener(struct seccomp_filter *filter)
 	if (!filter->notif)
 		goto out;
 
-	sema_init(&filter->notif->request, 0);
 	filter->notif->next_id = get_random_u64();
 	INIT_LIST_HEAD(&filter->notif->notifications);
 
 	ret = anon_inode_getfile("seccomp notify", &seccomp_notify_ops,
-				 filter, O_RDWR);
+				 filter, O_RDWR|O_NONBLOCK);
 	if (IS_ERR(ret))
 		goto out_notif;
 
diff --git a/samples/seccomp/user-trap.c b/samples/seccomp/user-trap.c
index 20291ec6489f..b9e666f15998 100644
--- a/samples/seccomp/user-trap.c
+++ b/samples/seccomp/user-trap.c
@@ -198,6 +198,17 @@ static int handle_req(struct seccomp_notif *req,
 	return ret;
 }
 
+static void set_blocking(int fd)
+{
+	int file_status_flags = fcntl(fd, F_GETFL);
+
+	file_status_flags &= ~O_NONBLOCK;
+	if (fcntl(fd, F_SETFL, file_status_flags)) {
+		perror("F_SETFL");
+		exit(1);
+	}
+}
+
 int main(void)
 {
 	int sk_pair[2], ret = 1, status, listener;
@@ -274,6 +285,8 @@ int main(void)
 	if (listener < 0)
 		goto out_kill;
 
+	set_blocking(listener);
+
 	/*
 	 * Fork a task to handle the requests. This isn't strictly necessary,
 	 * but it makes the particular writing of this sample easier, since we
@@ -307,6 +320,9 @@ int main(void)
 		while (1) {
 			memset(req, 0, sizes.seccomp_notif);
 			if (ioctl(listener, SECCOMP_IOCTL_NOTIF_RECV, req)) {
+				if (errno == ENOTCONN)
+					exit(0);
+
 				perror("ioctl recv");
 				goto out_resp;
 			}
diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 4a180439ee9e..5318f9cb1aec 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -295,6 +295,13 @@ static int __filecmp(pid_t pid1, pid_t pid2, int fd1, int fd2)
 #endif
 }
 
+#define set_blocking(fd) ({					\
+	int file_status_flags;					\
+	file_status_flags = fcntl(fd, F_GETFL);			\
+	file_status_flags &= ~O_NONBLOCK;			\
+	ASSERT_EQ(fcntl(fd, F_SETFL, file_status_flags), 0);	\
+})
+
 /* Have TH_LOG report actual location filecmp() is used. */
 #define filecmp(pid1, pid2, fd1, fd2)	({		\
 	int _ret;					\
@@ -3422,6 +3429,8 @@ TEST(user_notification_kill_in_middle)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	/*
 	 * Check that nothing bad happens when we kill the task in the middle
 	 * of a syscall.
@@ -3476,6 +3485,8 @@ TEST(user_notification_signal)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 
@@ -3583,6 +3594,8 @@ TEST(user_notification_child_pid_ns)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 
@@ -3623,6 +3636,8 @@ TEST(user_notification_sibling_pid_ns)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 
@@ -3691,6 +3706,8 @@ TEST(user_notification_fault_recv)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 
@@ -3972,6 +3989,8 @@ TEST(user_notification_addfd)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 
@@ -4099,6 +4118,8 @@ TEST(user_notification_addfd_rlimit)
 				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
 	ASSERT_GE(listener, 0);
 
+	set_blocking(listener);
+
 	pid = fork();
 	ASSERT_GE(pid, 0);
 

base-commit: 4525c8781ec0701ce824e8bd379ae1b129e26568
-- 
2.29.1.341.ge80a0c044ae-goog

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
