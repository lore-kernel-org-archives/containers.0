Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82854C433ED
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:57 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 33A3261409
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 20:49:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33A3261409
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 0D894431DF;
	Fri, 30 Apr 2021 20:49:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oRPni8v2do9l; Fri, 30 Apr 2021 20:49:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id E8B7D40253;
	Fri, 30 Apr 2021 20:49:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E41C8C000E;
	Fri, 30 Apr 2021 20:49:55 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4E785C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 3D34F6F9E0
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id r9vJKKxReEPY
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:54 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-qk1-x733.google.com (mail-qk1-x733.google.com
 [IPv6:2607:f8b0:4864:20::733])
 by smtp3.osuosl.org (Postfix) with ESMTPS id D0A306080F
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 20:49:53 +0000 (UTC)
Received: by mail-qk1-x733.google.com with SMTP id o5so72148663qkb.0
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 13:49:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=oVd2WMDZlRcVHbWT2xgesmGD/N8sDYwKT+s1aPdX054=;
 b=ttm6ofaY0pxaGM3kpeUodAQJyrehN+55UB9ega22plk3/VUxcl1IDMhqdYnML2Rrk7
 5TBcy0RzwB9UfGXP8jzfdt17zH5YxEDmKaFcWDlBsuFVSAhEALdemlEjoRlEhKzXUUqK
 JAopPYaoqW8yg8vT59s19lnnTAufHseAvGpec=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=oVd2WMDZlRcVHbWT2xgesmGD/N8sDYwKT+s1aPdX054=;
 b=Fxd0+4dAk7y00TdLDw/fcjq3VLdisS0VijnVm8baJWc/m/6+aSJf6jewdqV3KXInMv
 OWaTMYgdHZpc5JbI3DwMm7NC9PzhmNIRI/bvDhr8PP1Ml1G1LGCLPkR+7Dd02YGkJ7dF
 JxvFAlOtv6s50bhV+jbevBmeZaJupe81K9Bo1Pf9ZhsZROw+r1qgxSZrlrOqkCAXZ8Yo
 VrYfB36NT3ylKzeCvM9Y0TTLQ6G6sGOUZ1YWp/rJENhUj7DMOiOJRFi8oiGVXrJ6YjM4
 99Xwa+e9CR629EV1zKoWItCPKdokrFgnRSDOCFdUXjk5Rzji76qih+iAR4MZECrh8OxR
 //nQ==
X-Gm-Message-State: AOAM531jY82GCMpF+n6/asLJhndqdb0fQTChDok2EDsDbitOctuiAGvv
 YKfFK3cxxAn5DQTDoU5O6P/Ezg==
X-Google-Smtp-Source: ABdhPJwuHHpvNmBnXGdJEx1RSG/4GMDue3kTjBZI0J4nYHYurPYyimJaPf4Z+J6AHpPy5VlBkqvA6A==
X-Received: by 2002:a37:7b41:: with SMTP id w62mr7434442qkc.256.1619815792499; 
 Fri, 30 Apr 2021 13:49:52 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net.
 [136.25.20.203])
 by smtp.gmail.com with ESMTPSA id z17sm3161960qtf.10.2021.04.30.13.49.50
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 30 Apr 2021 13:49:51 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>
Subject: [PATCH v2 4/5] seccomp: Support atomic "addfd + send reply"
Date: Fri, 30 Apr 2021 13:49:38 -0700
Message-Id: <20210430204939.5152-5-sargun@sargun.me>
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

From: Rodrigo Campos <rodrigo@kinvolk.io>

Alban Crequy reported a race condition userspace faces when we want to
add some fds and make the syscall return them[1] using seccomp notify.

The problem is that currently two different ioctl() calls are needed by
the process handling the syscalls (agent) for another userspace process
(target): SECCOMP_IOCTL_NOTIF_ADDFD to allocate the fd and
SECCOMP_IOCTL_NOTIF_SEND to return that value. Therefore, it is possible
for the agent to do the first ioctl to add a file descriptor but the
target is interrupted (EINTR) before the agent does the second ioctl()
call.

Other patches in this series add a way to block signals when a syscall
is put to wait by seccomp. However, that might be a big hammer for some
cases, as the golang runtime uses SIGURG to interrupt threads for GC
collection.  Sometimes we just don't want to interfere with the GC, for
example, and just either add the fd and return it or fail the syscall.
With no leaking fds added inadvertly to the target process.

This patch adds a flag to the ADDFD ioctl() so it adds the fd and
returns that value atomically to the target program, as suggested by
Kees Cook[2]. This is done by simply allowing
seccomp_do_user_notification() to add the fd and return it in this case.
Therefore, in this case the target wakes up from the wait in
seccomp_do_user_notification() either to interrupt the syscall or to add
the fd and return it.

This "allocate an fd and return" functionality is useful for syscalls
that return a file descriptor only, like connect(2). Other syscalls that
return a file descriptor but not as return value (or return more than
one fd), like socketpair(), pipe(), recvmsg with SCM_RIGHTs, will not
work with this flag. The way to go to emulate those in cases where a
signal might interrupt is to use the functionality to block signals.

The struct seccomp_notif_resp, used when doing SECCOMP_IOCTL_NOTIF_SEND
ioctl() to send a response to the target, has three more fields that we
don't allow to set when doing the addfd ioctl() to also return. The
reasons to disallow each field are:
 * val: This will be set to the new allocated fd. No point taking it
   from userspace in this case.
 * error: If this is non-zero, the value is ignored. Therefore,
   it is pointless in this case as we want to return the value.
 * flags: The only flag is to let userspace continue to execute the
   syscall. This seems pointless, as we want the syscall to return the
   allocated fd.

This is why those fields are not possible to set when using this new
flag.

[1]: https://lore.kernel.org/lkml/CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com/
[2]: https://lore.kernel.org/lkml/202012011322.26DCBC64F2@keescook/

Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 include/uapi/linux/seccomp.h |  1 +
 kernel/seccomp.c             | 49 +++++++++++++++++++++++++++++++++---
 2 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 71dbc1f7889f..6a14c39a6e05 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -115,6 +115,7 @@ struct seccomp_notif_resp {
 
 /* valid flags for seccomp_notif_addfd */
 #define SECCOMP_ADDFD_FLAG_SETFD	(1UL << 0) /* Specify remote fd */
+#define SECCOMP_ADDFD_FLAG_SEND		(1UL << 1) /* Addfd and return it, atomically */
 
 /**
  * struct seccomp_notif_addfd
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 7ac1cea6e7f0..eed3294f3df8 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -109,6 +109,7 @@ struct seccomp_knotif {
  *      installing process should allocate the fd as normal.
  * @flags: The flags for the new file descriptor. At the moment, only O_CLOEXEC
  *         is allowed.
+ * @ioctl_flags: The flags used for the seccomp_addfd ioctl.
  * @ret: The return value of the installing process. It is set to the fd num
  *       upon success (>= 0).
  * @completion: Indicates that the installing process has completed fd
@@ -120,6 +121,7 @@ struct seccomp_kaddfd {
 	struct file *file;
 	int fd;
 	unsigned int flags;
+	__u32 ioctl_flags;
 
 	/* To only be set on reply */
 	int ret;
@@ -1064,14 +1066,35 @@ static u64 seccomp_next_notify_id(struct seccomp_filter *filter)
 	return filter->notif->next_id++;
 }
 
-static void seccomp_handle_addfd(struct seccomp_kaddfd *addfd)
+static void seccomp_handle_addfd(struct seccomp_kaddfd *addfd, struct seccomp_knotif *n)
 {
+	int fd;
+
 	/*
 	 * Remove the notification, and reset the list pointers, indicating
 	 * that it has been handled.
 	 */
 	list_del_init(&addfd->list);
-	addfd->ret = receive_fd_replace(addfd->fd, addfd->file, addfd->flags);
+	fd = receive_fd_replace(addfd->fd, addfd->file, addfd->flags);
+
+	addfd->ret = fd;
+
+	if (addfd->ioctl_flags & SECCOMP_ADDFD_FLAG_SEND) {
+		/* If we fail reset and return an error to the notifier */
+		if (fd < 0) {
+			n->state = SECCOMP_NOTIFY_SENT;
+		} else {
+			/* Return the FD we just added */
+			n->flags = 0;
+			n->error = 0;
+			n->val = fd;
+		}
+	}
+
+	/*
+	 * Mark the notification as completed. From this point, addfd mem
+	 * might be invalidated and we can't safely read it anymore.
+	 */
 	complete(&addfd->completion);
 }
 
@@ -1143,7 +1166,7 @@ static int seccomp_do_user_notification(int this_syscall,
 						 struct seccomp_kaddfd, list);
 		/* Check if we were woken up by a addfd message */
 		if (addfd)
-			seccomp_handle_addfd(addfd);
+			seccomp_handle_addfd(addfd, &n);
 
 	}  while (n.state != SECCOMP_NOTIFY_REPLIED);
 
@@ -1610,7 +1633,7 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 	if (addfd.newfd_flags & ~O_CLOEXEC)
 		return -EINVAL;
 
-	if (addfd.flags & ~SECCOMP_ADDFD_FLAG_SETFD)
+	if (addfd.flags & ~(SECCOMP_ADDFD_FLAG_SETFD | SECCOMP_ADDFD_FLAG_SEND))
 		return -EINVAL;
 
 	if (addfd.newfd && !(addfd.flags & SECCOMP_ADDFD_FLAG_SETFD))
@@ -1620,6 +1643,7 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 	if (!kaddfd.file)
 		return -EBADF;
 
+	kaddfd.ioctl_flags = addfd.flags;
 	kaddfd.flags = addfd.newfd_flags;
 	kaddfd.fd = (addfd.flags & SECCOMP_ADDFD_FLAG_SETFD) ?
 		    addfd.newfd : -1;
@@ -1645,6 +1669,23 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 		goto out_unlock;
 	}
 
+	if (addfd.flags & SECCOMP_ADDFD_FLAG_SEND) {
+		/*
+		 * Disallow queuing an atomic addfd + send reply while there are
+		 * some addfd requests still to process.
+		 *
+		 * There is no clear reason to support it and allows us to keep
+		 * the loop on the other side straight-forward.
+		 */
+		if (!list_empty(&knotif->addfd)) {
+			ret = -EBUSY;
+			goto out_unlock;
+		}
+
+		/* Allow exactly only one reply */
+		knotif->state = SECCOMP_NOTIFY_REPLIED;
+	}
+
 	list_add(&kaddfd.list, &knotif->addfd);
 	complete(&knotif->ready);
 	mutex_unlock(&filter->notify_lock);
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
