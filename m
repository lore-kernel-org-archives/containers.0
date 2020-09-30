Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96698C4727F
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1D634207C3
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h9ZjX4eG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D634207C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id CA62087222;
	Wed, 30 Sep 2020 15:20:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yAe55pSmWFO5; Wed, 30 Sep 2020 15:20:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B41F38721B;
	Wed, 30 Sep 2020 15:20:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A5424C0890;
	Wed, 30 Sep 2020 15:20:43 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 17951C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 06B0E22654
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xPoeAyQ-GZcu
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com
 [209.85.166.66])
 by silver.osuosl.org (Postfix) with ESMTPS id 94D672155B
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:39 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id k6so2210890ior.2
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 08:20:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=jREIpX4zm+bXQV4GY7erFrXt82ePUSIl6wMoQiJQey4=;
 b=h9ZjX4eGPqcJOpfWYc3rRkbc0/uIBIA0z208Muoytgd2Zkc4s/wN8o1um7Vh0YsWAR
 +2Y/YgZE292Y9q3TXdoGRaaHanr4WAnFP5uFMmQ+45q1ordQI0w/+irOShjPxp/4/V7/
 +XoFy0al9TGWw+kzoT352r4cmnvjksJMI83BvANTNQR0N8NkSTa41JWyylb5b7CtkpkA
 pJmWTT1mSTk5V/y7CyHIrkwOEXOqmuAVJphlBeMaBGYW5N09gtmFrw/ZI6MkLy8Dnvai
 YvrUK8uvDZiPouOAaZaO1FLE2/42ujQDkI4hfPyKpRRDUyD7Kz2MB2pvSHPudFbVWiHE
 ps6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=jREIpX4zm+bXQV4GY7erFrXt82ePUSIl6wMoQiJQey4=;
 b=j1s6JIWTjARciNXMidb9v+gyUF8yrZQl399SI8OQmqXeQLNt8rtHjgklT3Ux9D/OIg
 U2JGsJYPlRlxlfTSAFuIcGOq6s55dqzNh86D1V1s3NTlkcd6swWavL98CnI0RpFjAJE0
 sAHq3aZEXIhe2r7CDVG7yfYMRMGU0VMad0yfMzJyVD7vy5ntD+gIZEWuqsRIr5Sj0qfj
 ijS+AT/pYYMHWrwx38GDMv69XAwaQpF06b90Jq9ZPqapGJIy2KKRSql5aCu+cB2qD2Dn
 FEV2FKhEDzATPhYghqMeMh3xm+Zhzil8LF0jIRkgoXXoSotdHLwJcOHR6vw87Tx/ramf
 O55A==
X-Gm-Message-State: AOAM531znFvJ/WVt1tc1xJyVCT0CVh4aS7N20ZDfo7sh38WiM1KRPog6
 Ix5wu2NByLZ2t8spLQ2i4WCIPzXYzkIDxA==
X-Google-Smtp-Source: ABdhPJwUId5jwICkoihvxugKENCdWV2ugU3LmdKq2serskfp9gUu2bmLJhqPV/YGR57wE3HQ4IzBBw==
X-Received: by 2002:a5d:80d6:: with SMTP id h22mr2066435ior.154.1601479238534; 
 Wed, 30 Sep 2020 08:20:38 -0700 (PDT)
Received: from localhost.localdomain (ip-99-203-15-156.pools.cgn.spcsdns.net.
 [99.203.15.156])
 by smtp.gmail.com with ESMTPSA id t10sm770788iog.49.2020.09.30.08.20.35
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 08:20:37 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Date: Wed, 30 Sep 2020 10:19:16 -0500
Message-Id: <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1601478774.git.yifeifz2@illinois.edu>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
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

This file is guarded by CONFIG_DEBUG_SECCOMP_CACHE with a default
of N because I think certain users of seccomp might not want the
application to know which syscalls are definitely usable. For
the same reason, it is also guarded by CAP_SYS_ADMIN.

Suggested-by: Jann Horn <jannh@google.com>
Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig                   | 15 +++++++++++
 arch/x86/include/asm/seccomp.h |  3 +++
 fs/proc/base.c                 |  3 +++
 include/linux/seccomp.h        |  5 ++++
 kernel/seccomp.c               | 46 ++++++++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index ca867b2a5d71..b840cadcc882 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -478,6 +478,7 @@ config HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
 	  - all the requirements for HAVE_ARCH_SECCOMP_FILTER
 	  - SECCOMP_ARCH_DEFAULT
 	  - SECCOMP_ARCH_DEFAULT_NR
+	  - SECCOMP_ARCH_DEFAULT_NAME
 
 config SECCOMP
 	prompt "Enable seccomp to safely execute untrusted bytecode"
@@ -532,6 +533,20 @@ config SECCOMP_CACHE_NR_ONLY
 
 endchoice
 
+config DEBUG_SECCOMP_CACHE
+	bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
+	depends on SECCOMP_CACHE_NR_ONLY
+	depends on PROC_FS
+	help
+	  This is enables /proc/pid/seccomp_cache interface to monitor
+	  seccomp cache data. The file format is subject to change. Reading
+	  the file requires CAP_SYS_ADMIN.
+
+	  This option is for debugging only. Enabling present the risk that
+	  an adversary may be able to infer the seccomp filter logic.
+
+	  If unsure, say N.
+
 config HAVE_ARCH_STACKLEAK
 	bool
 	help
diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index 7b3a58271656..33ccc074be7a 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -19,13 +19,16 @@
 #ifdef CONFIG_X86_64
 # define SECCOMP_ARCH_DEFAULT			AUDIT_ARCH_X86_64
 # define SECCOMP_ARCH_DEFAULT_NR		NR_syscalls
+# define SECCOMP_ARCH_DEFAULT_NAME		"x86_64"
 # ifdef CONFIG_COMPAT
 #  define SECCOMP_ARCH_COMPAT			AUDIT_ARCH_I386
 #  define SECCOMP_ARCH_COMPAT_NR		IA32_NR_syscalls
+#  define SECCOMP_ARCH_COMPAT_NAME		"x86_32"
 # endif
 #else /* !CONFIG_X86_64 */
 # define SECCOMP_ARCH_DEFAULT		AUDIT_ARCH_I386
 # define SECCOMP_ARCH_DEFAULT_NR	NR_syscalls
+# define SECCOMP_ARCH_COMPAT_NAME		"x86_32"
 #endif
 
 #include <asm-generic/seccomp.h>
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 617db4e0faa0..c60c5fce70fa 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -3258,6 +3258,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_PROC_PID_ARCH_STATUS
 	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
 #endif
+#ifdef CONFIG_DEBUG_SECCOMP_CACHE
+	ONE("seccomp_cache", S_IRUSR, proc_pid_seccomp_cache),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 02aef2844c38..c35430f5f553 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -121,4 +121,9 @@ static inline long seccomp_get_metadata(struct task_struct *task,
 	return -EINVAL;
 }
 #endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
+
+#ifdef CONFIG_DEBUG_SECCOMP_CACHE
+int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
+			   struct pid *pid, struct task_struct *task);
+#endif
 #endif /* _LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index bed3b2a7f6c8..c5ca5e30281b 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -2297,3 +2297,49 @@ static int __init seccomp_sysctl_init(void)
 device_initcall(seccomp_sysctl_init)
 
 #endif /* CONFIG_SYSCTL */
+
+#ifdef CONFIG_DEBUG_SECCOMP_CACHE
+/* Currently CONFIG_DEBUG_SECCOMP_CACHE implies CONFIG_SECCOMP_CACHE_NR_ONLY */
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
+
+	/*
+	 * We don't want some sandboxed process know what their seccomp
+	 * filters consist of.
+	 */
+	if (!file_ns_capable(m->file, &init_user_ns, CAP_SYS_ADMIN))
+		return -EACCES;
+
+	f = READ_ONCE(task->seccomp.filter);
+	if (!f)
+		return 0;
+
+#ifdef SECCOMP_ARCH_DEFAULT
+	proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_DEFAULT_NAME,
+				    f->cache.syscall_allow_default,
+				    SECCOMP_ARCH_DEFAULT_NR);
+#endif /* SECCOMP_ARCH_DEFAULT */
+
+#ifdef SECCOMP_ARCH_COMPAT
+	proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_COMPAT_NAME,
+				    f->cache.syscall_allow_compat,
+				    SECCOMP_ARCH_COMPAT_NR);
+#endif /* SECCOMP_ARCH_COMPAT */
+	return 0;
+}
+#endif /* CONFIG_DEBUG_SECCOMP_CACHE */
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
