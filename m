Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A998170
	for <containers@lists.linux.dev>; Sun,  2 May 2021 00:19:10 +0000 (UTC)
Received: by mail-qk1-f182.google.com with SMTP id o27so1883915qkj.9
        for <containers@lists.linux.dev>; Sat, 01 May 2021 17:19:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dLHYNoMNSLuOBDeAeGfg1x0cR67YCr3NrbPwWmJrvJU=;
        b=ZOglfZJszb6bLMNFLgbvhux5br1KclRSO1ZMabBD2PD/pr7ewqdVKmNdq/iVkk9d6d
         UM+HW66sCrnplwfWFQK+f3YJGWwI6z2zw7ikxrEFezE2jJXtwzQJOYIrlwnOJphD/hcG
         pAfY/PeNwsCr7pc3+e9PxsLfE46BbllIGwgkQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=dLHYNoMNSLuOBDeAeGfg1x0cR67YCr3NrbPwWmJrvJU=;
        b=ELwhLGXtd1N6ReQtjdV0pyIFh9LaT2hcPP+zFaMoQCC5XO6yczP7QQVF+40qfX8g26
         NqQ0L1fc+bRhRiN9GUJt5HWOWHfng3YocEtCv2BErfCPaTDeJ/gRl59aaPlP873wsjNQ
         DTy7i4N7pg6P0wNKFWmNrLjhBsQZ2Fj5ecdmX84I5V5R+EL07eXG4ZNpAxNqRD43bMNi
         erWk4VADLfdk+heZG+os8IMblUC88P+SJu9qUiXZgTfaywERPQeHP1z1hDojR7AaxIY5
         2G8Op5CjM+2Niw5XZZt9gEiKpHMkyhZNL4t+/ATU3Xu1XXRN2LAE67M6h2uxwgMuK8gF
         7GNA==
X-Gm-Message-State: AOAM5306dHlSodZMRkEhYdp2R8U6OYk7g/7Fjs9nBVcq3PKoXZopfGBA
	pzcHZSqQbFwtbMfVc7UorciKIg==
X-Google-Smtp-Source: ABdhPJxBx013wNdaWrAPBO0712wSIOjtyajiE0bqM/5ZlQ3+1tVoUyVcFoec1lpvaiIL7QhAKylFEw==
X-Received: by 2002:a05:620a:8c8:: with SMTP id z8mr12570360qkz.32.1619914749469;
        Sat, 01 May 2021 17:19:09 -0700 (PDT)
Received: from ubuntu.netflix.com (136-25-20-203.cab.webpass.net. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id p5sm5146067qkh.135.2021.05.01.17.19.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 17:19:08 -0700 (PDT)
From: Sargun Dhillon <sargun@sargun.me>
To: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>
Cc: Rodrigo Campos <rodrigo@kinvolk.io>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@linux.microsoft.com>,
	Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH 3/4] seccomp: Support atomic "addfd + send reply"
Date: Sat,  1 May 2021 17:18:50 -0700
Message-Id: <20210502001851.3346-4-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20210502001851.3346-1-sargun@sargun.me>
References: <20210502001851.3346-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

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
 .../userspace-api/seccomp_filter.rst          | 12 +++++
 include/uapi/linux/seccomp.h                  |  1 +
 kernel/seccomp.c                              | 49 +++++++++++++++++--
 3 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/Documentation/userspace-api/seccomp_filter.rst b/Documentation/userspace-api/seccomp_filter.rst
index 6efb41cc8072..d61219889e49 100644
--- a/Documentation/userspace-api/seccomp_filter.rst
+++ b/Documentation/userspace-api/seccomp_filter.rst
@@ -259,6 +259,18 @@ and ``ioctl(SECCOMP_IOCTL_NOTIF_SEND)`` a response, indicating what should be
 returned to userspace. The ``id`` member of ``struct seccomp_notif_resp`` should
 be the same ``id`` as in ``struct seccomp_notif``.
 
+Userspace can also add file descriptors to the notifying process via
+``ioctl(SECCOMP_IOCTL_NOTIF_ADDFD)``. The ``id`` member of
+``struct seccomp_notif_addfd`` should be the same ``id`` as in
+``struct seccomp_notif``. The ``newfd_flags`` flag may be used to set flags
+like O_EXEC on the file descriptor in the notifying process. If the supervisor
+wants to inject the file descriptor with a specific number, the
+``SECCOMP_ADDFD_FLAG_SETFD`` flag can be used, and set the ``newfd`` member to
+the specific number to use. If that file descriptor is already open in the
+notifying process it will be replaced. The supervisor can also add an FD, and
+respond atomically by using the ``SECCOMP_ADDFD_FLAG_SEND`` flag and the return
+value will be the injected file descriptor number.
+
 It is worth noting that ``struct seccomp_data`` contains the values of register
 arguments to the syscall, but does not contain pointers to memory. The task's
 memory is accessible to suitably privileged traces via ``ptrace()`` or
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 6ba18b82a02e..78074254ab98 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -115,6 +115,7 @@ struct seccomp_notif_resp {
 
 /* valid flags for seccomp_notif_addfd */
 #define SECCOMP_ADDFD_FLAG_SETFD	(1UL << 0) /* Specify remote fd */
+#define SECCOMP_ADDFD_FLAG_SEND		(1UL << 1) /* Addfd and return it, atomically */
 
 /**
  * struct seccomp_notif_addfd
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 93684cc63285..3636f9584991 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -107,6 +107,7 @@ struct seccomp_knotif {
  *      installing process should allocate the fd as normal.
  * @flags: The flags for the new file descriptor. At the moment, only O_CLOEXEC
  *         is allowed.
+ * @ioctl_flags: The flags used for the seccomp_addfd ioctl.
  * @ret: The return value of the installing process. It is set to the fd num
  *       upon success (>= 0).
  * @completion: Indicates that the installing process has completed fd
@@ -118,6 +119,7 @@ struct seccomp_kaddfd {
 	struct file *file;
 	int fd;
 	unsigned int flags;
+	__u32 ioctl_flags;
 
 	/* To only be set on reply */
 	int ret;
@@ -1062,14 +1064,35 @@ static u64 seccomp_next_notify_id(struct seccomp_filter *filter)
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
 
@@ -1113,7 +1136,7 @@ static int seccomp_do_user_notification(int this_syscall,
 						 struct seccomp_kaddfd, list);
 		/* Check if we were woken up by a addfd message */
 		if (addfd)
-			seccomp_handle_addfd(addfd);
+			seccomp_handle_addfd(addfd, &n);
 
 	}  while (n.state != SECCOMP_NOTIFY_REPLIED);
 
@@ -1574,7 +1597,7 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 	if (addfd.newfd_flags & ~O_CLOEXEC)
 		return -EINVAL;
 
-	if (addfd.flags & ~SECCOMP_ADDFD_FLAG_SETFD)
+	if (addfd.flags & ~(SECCOMP_ADDFD_FLAG_SETFD | SECCOMP_ADDFD_FLAG_SEND))
 		return -EINVAL;
 
 	if (addfd.newfd && !(addfd.flags & SECCOMP_ADDFD_FLAG_SETFD))
@@ -1584,6 +1607,7 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
 	if (!kaddfd.file)
 		return -EBADF;
 
+	kaddfd.ioctl_flags = addfd.flags;
 	kaddfd.flags = addfd.newfd_flags;
 	kaddfd.fd = (addfd.flags & SECCOMP_ADDFD_FLAG_SETFD) ?
 		    addfd.newfd : -1;
@@ -1609,6 +1633,23 @@ static long seccomp_notify_addfd(struct seccomp_filter *filter,
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

