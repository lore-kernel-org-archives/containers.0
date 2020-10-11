Return-Path: <SRS0=u+zM=DS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1622C433DF
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 43D1320757
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nn6i2S86"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43D1320757
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 41FF687100;
	Sun, 11 Oct 2020 15:48:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LhZxbQBgsRkH; Sun, 11 Oct 2020 15:48:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 72290870E0;
	Sun, 11 Oct 2020 15:48:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5FBFFC07FF;
	Sun, 11 Oct 2020 15:48:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E8B3CC0051
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D7E1D87098
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GGS2Rkl6uo5H
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com
 [209.85.166.67])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 0C81B87083
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:09 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id y20so11025834iod.5
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 08:48:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=bh/bxp4LmmGqgKt2aJUxspVEN/p8NkyKCwPTxJ39i3g=;
 b=nn6i2S86exOVIWwpvj7rLIawGNqAZX0I4JwIYwZak9/dhhrsY6xAwMFdDkchUB4bE7
 Ywg3TeyWPargf8GlktVVwyPat1G+AY8cO3VlhHtiaLHGlZ9a992KBgV5Wsau8t4HODHO
 3PX+c8OCjMMg14shIPGolf6EYtq5Xigy3PBK8DkVyNxjuan5wnqd4ucJWiN4i5i6BhZD
 oU+4/RlHKPFHTPTnwgtvhGCLAVbLG4X6doOhCDfm2fW6CO+9i3Pnawp4JAjEI7xFr/Ol
 PUiOZwDuQ1znUK/ct+63lngEzDpgCFeomnyhPD1a5a7/qY3cY1gaqQqSquM0AZo46/Sa
 kGOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=bh/bxp4LmmGqgKt2aJUxspVEN/p8NkyKCwPTxJ39i3g=;
 b=WIV7lhDRVekyXsfwQ+d6S32Y5i8aOEz2/uOjfdu5Y8iFylBIP00qklsXlU3QCwpS2+
 rfajQWrAyzgmCAVSQeaQDoij9k8zM5TfV4UKU0q1ysstshA4lQJaLef08dHnwv7M6wWB
 yxPZxreUZD3VlvkyEryQZ08l9a0Twyy4Pbzi61jzwIlJoFmdXezwQWJI9ebZ3QpmwtWa
 9sU6QQxtr11JvfbIk+KuCaG1dbQiXJ5766NkCuXhwLUHPQvrS4PtjoYGy0MUTyvUMV0P
 qNtg1VwSY+MOctzbT4+LhJi8rmhA/GVizUOOBDycuq00cyIaqi1xV8WJtVSiFwcLx4UD
 lrGA==
X-Gm-Message-State: AOAM532LRhsuwJC0S+IVn2hDUWjyb2WKeYRmISVE+3HltLfENrVHRaQP
 /LSzYp1YHO0idWzJ3uR1DUqHPeqhyfwySA==
X-Google-Smtp-Source: ABdhPJz57j/FGm60z5PstmX6+BrS09JBgBdJz3s3uARY/zSkjrW9ISSGYmGFrPk2trFEI/6YDnamyg==
X-Received: by 2002:a05:6638:240f:: with SMTP id
 z15mr6120836jat.38.1602431288078; 
 Sun, 11 Oct 2020 08:48:08 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id q16sm7502881ilj.71.2020.10.11.08.48.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 11 Oct 2020 08:48:07 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v5 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Date: Sun, 11 Oct 2020 10:47:46 -0500
Message-Id: <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1602431034.git.yifeifz2@illinois.edu>
References: <cover.1602431034.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>
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
 arch/Kconfig                   | 24 ++++++++++++++
 arch/x86/Kconfig               |  1 +
 arch/x86/include/asm/seccomp.h |  3 ++
 fs/proc/base.c                 |  6 ++++
 include/linux/seccomp.h        |  7 ++++
 kernel/seccomp.c               | 59 ++++++++++++++++++++++++++++++++++
 6 files changed, 100 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 21a3675a7a3a..6157c3ce0662 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -471,6 +471,15 @@ config HAVE_ARCH_SECCOMP_FILTER
 	    results in the system call being skipped immediately.
 	  - seccomp syscall wired up
 
+config HAVE_ARCH_SECCOMP_CACHE
+	bool
+	help
+	  An arch should select this symbol if it provides all of these things:
+	  - all the requirements for HAVE_ARCH_SECCOMP_FILTER
+	  - SECCOMP_ARCH_NATIVE
+	  - SECCOMP_ARCH_NATIVE_NR
+	  - SECCOMP_ARCH_NATIVE_NAME
+
 config SECCOMP
 	prompt "Enable seccomp to safely execute untrusted bytecode"
 	def_bool y
@@ -498,6 +507,21 @@ config SECCOMP_FILTER
 
 	  See Documentation/userspace-api/seccomp_filter.rst for details.
 
+config SECCOMP_CACHE_DEBUG
+	bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
+	depends on SECCOMP
+	depends on SECCOMP_FILTER && HAVE_ARCH_SECCOMP_CACHE
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
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 1ab22869a765..1a807f89ac77 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -150,6 +150,7 @@ config X86
 	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_PREL32_RELOCATIONS
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_SECCOMP_CACHE
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_STACKLEAK
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index b17d037c72ce..fef16e398161 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -19,9 +19,11 @@
 #ifdef CONFIG_X86_64
 # define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_X86_64
 # define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"x86_64"
 # ifdef CONFIG_COMPAT
 #  define SECCOMP_ARCH_COMPAT		AUDIT_ARCH_I386
 #  define SECCOMP_ARCH_COMPAT_NR	IA32_NR_syscalls
+#  define SECCOMP_ARCH_COMPAT_NAME	"ia32"
 # endif
 /*
  * x32 will have __X32_SYSCALL_BIT set in syscall number. We don't support
@@ -31,6 +33,7 @@
 #else /* !CONFIG_X86_64 */
 # define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_I386
 # define SECCOMP_ARCH_NATIVE_NR	        NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"ia32"
 #endif
 
 #include <asm-generic/seccomp.h>
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 617db4e0faa0..a4990410ff05 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -3258,6 +3258,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_PROC_PID_ARCH_STATUS
 	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
 #endif
+#ifdef CONFIG_SECCOMP_CACHE_DEBUG
+	ONE("seccomp_cache", S_IRUSR, proc_pid_seccomp_cache),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
@@ -3587,6 +3590,9 @@ static const struct pid_entry tid_base_stuff[] = {
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
index 236e7b367d4e..1df2fac281da 100644
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
@@ -2311,3 +2314,59 @@ static int __init seccomp_sysctl_init(void)
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
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
