Return-Path: <SRS0=9Lh8=ER=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E3E1C55ABD
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:50 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CF99C206D9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SiSS9BGt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF99C206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 90DF287583;
	Wed, 11 Nov 2020 13:34:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZFo6DDumdyPm; Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id D21458755E;
	Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B8BB5C1AD4;
	Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 014BDC016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B3F512DE2A
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id p1IRDZHAMSt3
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:46 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com
 [209.85.222.196])
 by silver.osuosl.org (Postfix) with ESMTPS id 42E1C2046D
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:46 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id q22so1600151qkq.6
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=es+7eu/1JIS0u6NUqnkeBJLaNZv/3XzsgPMcIjCfPvw=;
 b=SiSS9BGtwjPR7pjydIAWebSVTiMEer42LpN7EpvhCX58lUuaU+5VL/V+DDUEclGLtr
 EdcBEjukeRJlEPueY+LcsN/JpriAjIIsc9XUZ8HS2rH0qqJR20vP48D53z0KxGGFw6aI
 tlyC7/8tNSL95t5fvWWV8XPYP6g7ssIFLJknQViYrRiWAd2Q+Ry08GJAb8cTJHI8pCK9
 buTguV8FlprsoG+3jxCMVQxLj4MYGR2vub+bz/qGKFmULijoRwvTIkIDNrV7Wg0W21m6
 +w7ArHtUx7CSn0LOJewHqljJ3+K6Jej2SPqV7G9EAbyec7KPiSCxZa+a5LHijsgcUkh0
 +q8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=es+7eu/1JIS0u6NUqnkeBJLaNZv/3XzsgPMcIjCfPvw=;
 b=tm9IqZrXiGFsUU0soXK/JJHu03GJIHLFi9cTIXD2aLE271QGwwzpcqJTERAIkHmQea
 3iKyZlOYTQtG0RTSin7Ggnc0QPEj8pDaUrYccZE5Uh8oCSOQ3z/x8pa/6+2nz4so2rRj
 korejmRrcpf66qZ4LeMNcr6HnnrcLBV3d5wy3aH90VfnjegIxbGsITfdc2Wuiluw2A+D
 R8M3F87LTnbH8klm5l+/fhu4IOPVY0p6zBRZDRlxChHGFLAAQwQ/7KDemLyUqu/HBARn
 kT6PIiHjFP8OQ4IdXjQH7hLmQYm6fc1MEJf+NzznidU8AsIjAeBpIfeL0Sb16EdrPbNa
 CP8Q==
X-Gm-Message-State: AOAM530dM19YnGyCn3U6yoqQBWgj+PyggxF5ehi/4mxKUbDwiWmczni0
 LXsKSYditwwuqQeBUsj7qGZUTIrmqqH+eg==
X-Google-Smtp-Source: ABdhPJzgBhxY2MTCkcZ674AzY/SoPNRIS1xCW9A1AMfGp6inTU26zD1tI8MwT3wv66UQP/RzA1s2AA==
X-Received: by 2002:a37:64d4:: with SMTP id
 y203mr23844160qkb.150.1605101685029; 
 Wed, 11 Nov 2020 05:34:45 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.43
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:44 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 8/8] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Date: Wed, 11 Nov 2020 07:33:54 -0600
Message-Id: <94e663fa53136f5a11f432c661794d1ee7060779.1605101222.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1605101222.git.yifeifz2@illinois.edu>
References: <cover.1605101222.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: linux-sh@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 linux-riscv@lists.infradead.org, Andrea Arcangeli <aarcange@redhat.com>,
 linux-s390@vger.kernel.org, YiFei Zhu <yifeifz2@illinois.edu>,
 linux-csky@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>,
 linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Valentin Rothberg <vrothber@redhat.com>,
 Aleksa Sarai <cyphar@cyphar.com>, Josep Torrellas <torrella@illinois.edu>,
 Will Drewry <wad@chromium.org>, linux-parisc@vger.kernel.org,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, linuxppc-dev@lists.ozlabs.org
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

From: YiFei Zhu <yifeifz2@illinois.edu>

Currently the kernel does not provide an infrastructure to translate
architecture numbers to a human-readable name. Translating syscall
numbers to syscall names is possible through FTRACE_SYSCALL
infrastructure but it does not provide support for compat syscalls.

This will create a file for each PID as /proc/pid/seccomp_cache.
The file will be empty when no seccomp filters are loaded, or be
in the format of:
<arch name> <decimal syscall number> <ALLOW | FILTER>
where ALLOW means the cache is guaranteed to allow the syscall,
and filter means the cache will pass the syscall to the BPF filter.

For the docker default profile on x86_64 it looks like:
x86_64 0 ALLOW
x86_64 1 ALLOW
x86_64 2 ALLOW
x86_64 3 ALLOW
[...]
x86_64 132 ALLOW
x86_64 133 ALLOW
x86_64 134 FILTER
x86_64 135 FILTER
x86_64 136 FILTER
x86_64 137 ALLOW
x86_64 138 ALLOW
x86_64 139 FILTER
x86_64 140 ALLOW
x86_64 141 ALLOW
[...]

This file is guarded by CONFIG_SECCOMP_CACHE_DEBUG with a default
of N because I think certain users of seccomp might not want the
application to know which syscalls are definitely usable. For
the same reason, it is also guarded by CAP_SYS_ADMIN.

Suggested-by: Jann Horn <jannh@google.com>
Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig            | 15 +++++++++++
 fs/proc/base.c          |  6 +++++
 include/linux/seccomp.h |  7 +++++
 kernel/seccomp.c        | 59 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 87 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 56b6ccc0e32d..6e2eb7171da0 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -514,6 +514,21 @@ config SECCOMP_FILTER
 
 	  See Documentation/userspace-api/seccomp_filter.rst for details.
 
+config SECCOMP_CACHE_DEBUG
+	bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
+	depends on SECCOMP
+	depends on SECCOMP_FILTER && !HAVE_SPARSE_SYSCALL_NR
+	depends on PROC_FS
+	help
+	  This enables the /proc/pid/seccomp_cache interface to monitor
+	  seccomp cache data. The file format is subject to change. Reading
+	  the file requires CAP_SYS_ADMIN.
+
+	  This option is for debugging only. Enabling presents the risk that
+	  an adversary may be able to infer the seccomp filter logic.
+
+	  If unsure, say N.
+
 config HAVE_ARCH_STACKLEAK
 	bool
 	help
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 0f707003dda5..d652f9dbaecc 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -3261,6 +3261,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_PROC_PID_ARCH_STATUS
 	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
 #endif
+#ifdef CONFIG_SECCOMP_CACHE_DEBUG
+	ONE("seccomp_cache", S_IRUSR, proc_pid_seccomp_cache),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
@@ -3590,6 +3593,9 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_PROC_PID_ARCH_STATUS
 	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
 #endif
+#ifdef CONFIG_SECCOMP_CACHE_DEBUG
+	ONE("seccomp_cache", S_IRUSR, proc_pid_seccomp_cache),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 02aef2844c38..76963ec4641a 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -121,4 +121,11 @@ static inline long seccomp_get_metadata(struct task_struct *task,
 	return -EINVAL;
 }
 #endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
+
+#ifdef CONFIG_SECCOMP_CACHE_DEBUG
+struct seq_file;
+
+int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
+			   struct pid *pid, struct task_struct *task);
+#endif
 #endif /* _LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index d8cf468dbe1e..76f524e320b1 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -553,6 +553,9 @@ void seccomp_filter_release(struct task_struct *tsk)
 {
 	struct seccomp_filter *orig = tsk->seccomp.filter;
 
+	/* We are effectively holding the siglock by not having any sighand. */
+	WARN_ON(tsk->sighand != NULL);
+
 	/* Detach task from its filter tree. */
 	tsk->seccomp.filter = NULL;
 	__seccomp_filter_release(orig);
@@ -2335,3 +2338,59 @@ static int __init seccomp_sysctl_init(void)
 device_initcall(seccomp_sysctl_init)
 
 #endif /* CONFIG_SYSCTL */
+
+#ifdef CONFIG_SECCOMP_CACHE_DEBUG
+/* Currently CONFIG_SECCOMP_CACHE_DEBUG implies SECCOMP_ARCH_NATIVE */
+static void proc_pid_seccomp_cache_arch(struct seq_file *m, const char *name,
+					const void *bitmap, size_t bitmap_size)
+{
+	int nr;
+
+	for (nr = 0; nr < bitmap_size; nr++) {
+		bool cached = test_bit(nr, bitmap);
+		char *status = cached ? "ALLOW" : "FILTER";
+
+		seq_printf(m, "%s %d %s\n", name, nr, status);
+	}
+}
+
+int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
+			   struct pid *pid, struct task_struct *task)
+{
+	struct seccomp_filter *f;
+	unsigned long flags;
+
+	/*
+	 * We don't want some sandboxed process to know what their seccomp
+	 * filters consist of.
+	 */
+	if (!file_ns_capable(m->file, &init_user_ns, CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (!lock_task_sighand(task, &flags))
+		return -ESRCH;
+
+	f = READ_ONCE(task->seccomp.filter);
+	if (!f) {
+		unlock_task_sighand(task, &flags);
+		return 0;
+	}
+
+	/* prevent filter from being freed while we are printing it */
+	__get_seccomp_filter(f);
+	unlock_task_sighand(task, &flags);
+
+	proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_NATIVE_NAME,
+				    f->cache.allow_native,
+				    SECCOMP_ARCH_NATIVE_NR);
+
+#ifdef SECCOMP_ARCH_COMPAT
+	proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_COMPAT_NAME,
+				    f->cache.allow_compat,
+				    SECCOMP_ARCH_COMPAT_NR);
+#endif /* SECCOMP_ARCH_COMPAT */
+
+	__put_seccomp_filter(f);
+	return 0;
+}
+#endif /* CONFIG_SECCOMP_CACHE_DEBUG */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
