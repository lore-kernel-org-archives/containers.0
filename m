Return-Path: <SRS0=nHAz=EY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 693A5C56202
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AEE66206A5
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="PjzuCyOa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEE66206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id DDCE420424;
	Wed, 18 Nov 2020 10:48:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id GnA1cCkK9q9x; Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 4DF70203D0;
	Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3B286C0800;
	Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2328EC07FF
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 11A7E87031
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id f6xxbKAVuiB9
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 68E06860FC
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1605696480;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=C8wAOglAL3fsqTpqfYjrg5+ouoD5MSyOi7eZ2Hc/xok=;
 b=PjzuCyOaL3JV/Feg8u3vzRtqymEbcnDRwCughg3QNe4QtzRVOOH0LV0ytt/m66Tb3L1qyl
 hto5UdDp8vLHYhuoHCz5kDLUOD03u6b2giRQCBRBgk971E1ld1PJ577GtkWNHa7FdPhwnc
 qEI2xVDokoP9/BgmwLsrK13Dw1nhRO8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-255-FinVNhLKN-O1q4oYrDtVqQ-1; Wed, 18 Nov 2020 05:47:56 -0500
X-MC-Unique: FinVNhLKN-O1q4oYrDtVqQ-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com
 [10.5.11.12])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 05B3F802B71;
 Wed, 18 Nov 2020 10:47:55 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-113-143.ams2.redhat.com
 [10.36.113.143])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 5E20360C43;
 Wed, 18 Nov 2020 10:47:53 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org,
	christian.brauner@ubuntu.com
Subject: [PATCH v3 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Date: Wed, 18 Nov 2020 11:47:45 +0100
Message-Id: <20201118104746.873084-2-gscrivan@redhat.com>
In-Reply-To: <20201118104746.873084-1-gscrivan@redhat.com>
References: <20201118104746.873084-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, viro@zeniv.linux.org.uk
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

When the flag CLOSE_RANGE_CLOEXEC is set, close_range doesn't
immediately close the files but it sets the close-on-exec bit.

It is useful for e.g. container runtimes that usually install a
seccomp profile "as late as possible" before execv'ing the container
process itself.  The container runtime could either do:
  1                                  2
- install_seccomp_profile();       - close_range(MIN_FD, MAX_INT, 0);
- close_range(MIN_FD, MAX_INT, 0); - install_seccomp_profile();
- execve(...);                     - execve(...);

Both alternative have some disadvantages.

In the first variant the seccomp_profile cannot block the close_range
syscall, as well as opendir/read/close/... for the fallback on older
kernels.
In the second variant, close_range() can be used only on the fds
that are not going to be needed by the runtime anymore, and it must be
potentially called multiple times to account for the different ranges
that must be closed.

Using close_range(..., ..., CLOSE_RANGE_CLOEXEC) solves these issues.
The runtime is able to use the existing open fds, the seccomp profile
can block close_range() and the syscalls used for its fallback.

Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
---
 fs/file.c                        | 44 ++++++++++++++++++++++++--------
 include/uapi/linux/close_range.h |  3 +++
 2 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index 21c0893f2f1d..69382580ae32 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -672,6 +672,35 @@ int __close_fd(struct files_struct *files, unsigned fd)
 }
 EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
 
+static inline void __range_cloexec(struct files_struct *cur_fds,
+				   unsigned int fd, unsigned int max_fd)
+{
+	struct fdtable *fdt;
+
+	if (fd > max_fd)
+		return;
+
+	spin_lock(&cur_fds->file_lock);
+	fdt = files_fdtable(cur_fds);
+	bitmap_set(fdt->close_on_exec, fd, max_fd - fd + 1);
+	spin_unlock(&cur_fds->file_lock);
+}
+
+static inline void __range_close(struct files_struct *cur_fds, unsigned int fd,
+				 unsigned int max_fd)
+{
+	while (fd <= max_fd) {
+		struct file *file;
+
+		file = pick_file(cur_fds, fd++);
+		if (!file)
+			continue;
+
+		filp_close(file, cur_fds);
+		cond_resched();
+	}
+}
+
 /**
  * __close_range() - Close all file descriptors in a given range.
  *
@@ -687,7 +716,7 @@ int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
 	struct task_struct *me = current;
 	struct files_struct *cur_fds = me->files, *fds = NULL;
 
-	if (flags & ~CLOSE_RANGE_UNSHARE)
+	if (flags & ~(CLOSE_RANGE_UNSHARE | CLOSE_RANGE_CLOEXEC))
 		return -EINVAL;
 
 	if (fd > max_fd)
@@ -725,16 +754,11 @@ int __close_range(unsigned fd, unsigned max_fd, unsigned int flags)
 	}
 
 	max_fd = min(max_fd, cur_max);
-	while (fd <= max_fd) {
-		struct file *file;
 
-		file = pick_file(cur_fds, fd++);
-		if (!file)
-			continue;
-
-		filp_close(file, cur_fds);
-		cond_resched();
-	}
+	if (flags & CLOSE_RANGE_CLOEXEC)
+		__range_cloexec(cur_fds, fd, max_fd);
+	else
+		__range_close(cur_fds, fd, max_fd);
 
 	if (fds) {
 		/*
diff --git a/include/uapi/linux/close_range.h b/include/uapi/linux/close_range.h
index 6928a9fdee3c..2d804281554c 100644
--- a/include/uapi/linux/close_range.h
+++ b/include/uapi/linux/close_range.h
@@ -5,5 +5,8 @@
 /* Unshare the file descriptor table before closing file descriptors. */
 #define CLOSE_RANGE_UNSHARE	(1U << 1)
 
+/* Set the FD_CLOEXEC bit instead of closing the file descriptor. */
+#define CLOSE_RANGE_CLOEXEC	(1U << 2)
+
 #endif /* _UAPI_LINUX_CLOSE_RANGE_H */
 
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
