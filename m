Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D35C9C2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:07 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4ACD823772
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ATR49onq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ACD823772
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id F0EAF86BEC;
	Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VW8tao-OlMiJ; Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2F12486BFF;
	Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1D0E5C0859;
	Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 806BEC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:07:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 692492E11F
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:07:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Zs3Tl0LE7rtD
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f193.google.com (mail-il1-f193.google.com
 [209.85.166.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 349EA2E11A
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:58 +0000 (UTC)
Received: by mail-il1-f193.google.com with SMTP id y2so2906573ila.0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:06:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=77aOM0dEGnPSSFeqHdvW9i0OufGkWG1x6ZJwSCuKRpU=;
 b=ATR49onqN+95MxJ40+wvBsqqkbmpyiOgoQ6j9JFFOKDH4W5b0sxW52ukXhJ4r3dcPV
 PL+8QtblR4qQannlwEjlNW27XIhGXCpHcRlcG36hjxzqvR27ofj0c6esrjc+4LPQDphP
 P2sXR8GElcazn9W5MDTRDQyO9B0z9IuGXrED1QWR6HyMo10FGLUoy0QdTQV+4pcF+uct
 Ob/PqVpAKCkUMKSkx7yIlwE0ZW2BqlwTtGwjJLGB3L0Mg2j6klgZ4dF4E3SLosBHf67h
 59qpRuFSp01A6pUFxd33CcJK7Px/TTtXdgP8tokovnCZbgIZlltw+USiZQdv/FtIWAT+
 geJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=77aOM0dEGnPSSFeqHdvW9i0OufGkWG1x6ZJwSCuKRpU=;
 b=A2YXolu/sCby+TJEI8JyIHXA1VxJPIv9ceRw904bUUm+iYVqT2cY250TE1ylpgnJM9
 vZvdErUKdrEC5gu4uNV2vSBkRLE8nDVHtZ4VkMsJN9Uq+RDZWUSu/kklb90IzloiD8OB
 7tDc7oSMtE47+fultmqwqJo3cf3lGHWentO59ltZ7ISDEJMgVm1x7E4h7ktSj5g/W0Dr
 d5g6biaJbuJwUWJTdAHmeIkVeQi9w9BIvt8SnT0ynnOKkCst3v5GPdIQFeiArjdPPGO9
 fIcTZqknDRvhpUFz8mn9bGV/heHZenYDNEAc6pSYMr/+J+gQCMfEgcyqRQTlzh9qUwxJ
 CXBQ==
X-Gm-Message-State: AOAM53126ihIyp/8DM65ARiuRVFDXXsLC91K7eVQJ8AgGE+6BlnKmMRC
 Bfc82cMITvAMvZAOZ8n5y9OX+TuhAQlmag==
X-Google-Smtp-Source: ABdhPJzEJ83GyLMjD3RB/741NrbDxkhsRIVB42PFUNQhJ3J8fKzwBhuulvzVuqU9o2EdCApr5X63Rw==
X-Received: by 2002:a92:9f91:: with SMTP id z17mr3547272ilk.36.1600949217203; 
 Thu, 24 Sep 2020 05:06:57 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id a23sm1259435ioc.54.2020.09.24.05.06.56
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:06:56 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 6/6] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Date: Thu, 24 Sep 2020 07:06:46 -0500
Message-Id: <163d194f6363a527568cd99c8cc1137498a16ce5.1600946701.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1600946701.git.yifeifz2@illinois.edu>
References: <cover.1600946701.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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
<hex arch number> <decimal syscall number> <ALLOW | FILTER>
where ALLOW means the cache is guaranteed to allow the syscall,
and filter means the cache will pass the syscall to the BPF filter.

For the docker default profile on x86_64 it looks like:
c000003e 0 ALLOW
c000003e 1 ALLOW
c000003e 2 ALLOW
c000003e 3 ALLOW
[...]
c000003e 132 ALLOW
c000003e 133 ALLOW
c000003e 134 FILTER
c000003e 135 FILTER
c000003e 136 FILTER
c000003e 137 ALLOW
c000003e 138 ALLOW
c000003e 139 FILTER
c000003e 140 ALLOW
c000003e 141 ALLOW
[...]

This file is guarded by CONFIG_PROC_SECCOMP_CACHE with a default
of N because I think certain users of seecomp might not want the
application to know which syscalls are definitely usable.

I'm not sure if adding all the "human readable names" is worthwhile,
considering it can be easily done in userspace.

Suggested-by: Jann Horn <jannh@google.com>
Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig            | 10 ++++++++++
 fs/proc/base.c          |  7 +++++--
 include/linux/seccomp.h |  5 +++++
 kernel/seccomp.c        | 26 ++++++++++++++++++++++++++
 4 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 8cc3dc87f253..dbfd897e5dc0 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -514,6 +514,16 @@ config SECCOMP_CACHE_NR_ONLY
 
 endchoice
 
+config PROC_SECCOMP_CACHE
+	bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
+	depends on SECCOMP_CACHE_NR_ONLY
+	depends on PROC_FS
+	help
+	  This is enables /proc/pid/seccomp_cache interface to monitor
+	  seccomp cache data. The file format is subject to change.
+
+	  If unsure, say N.
+
 config HAVE_ARCH_STACKLEAK
 	bool
 	help
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 617db4e0faa0..2af626f69fa1 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2615,7 +2615,7 @@ static struct dentry *proc_pident_instantiate(struct dentry *dentry,
 	return d_splice_alias(inode, dentry);
 }
 
-static struct dentry *proc_pident_lookup(struct inode *dir, 
+static struct dentry *proc_pident_lookup(struct inode *dir,
 					 struct dentry *dentry,
 					 const struct pid_entry *p,
 					 const struct pid_entry *end)
@@ -2815,7 +2815,7 @@ static const struct pid_entry attr_dir_stuff[] = {
 
 static int proc_attr_dir_readdir(struct file *file, struct dir_context *ctx)
 {
-	return proc_pident_readdir(file, ctx, 
+	return proc_pident_readdir(file, ctx,
 				   attr_dir_stuff, ARRAY_SIZE(attr_dir_stuff));
 }
 
@@ -3258,6 +3258,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_PROC_PID_ARCH_STATUS
 	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
 #endif
+#ifdef CONFIG_PROC_SECCOMP_CACHE
+	ONE("seccomp_cache", S_IRUSR, proc_pid_seccomp_cache),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 02aef2844c38..3cedec824365 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -121,4 +121,9 @@ static inline long seccomp_get_metadata(struct task_struct *task,
 	return -EINVAL;
 }
 #endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
+
+#ifdef CONFIG_PROC_SECCOMP_CACHE
+int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
+			   struct pid *pid, struct task_struct *task);
+#endif
 #endif /* _LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5b1bd8329e9c..c5697d9483ae 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -2295,3 +2295,29 @@ static int __init seccomp_sysctl_init(void)
 device_initcall(seccomp_sysctl_init)
 
 #endif /* CONFIG_SYSCTL */
+
+#ifdef CONFIG_PROC_SECCOMP_CACHE
+/* Currently CONFIG_PROC_SECCOMP_CACHE implies CONFIG_SECCOMP_CACHE_NR_ONLY */
+int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
+			   struct pid *pid, struct task_struct *task)
+{
+	struct seccomp_filter *f = READ_ONCE(task->seccomp.filter);
+	int arch, nr;
+
+	if (!f)
+		return 0;
+
+	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
+		for (nr = 0; nr < NR_syscalls; nr++) {
+			bool cached = test_bit(nr, f->cache.syscall_ok[arch]);
+			char *status = cached ? "ALLOW" : "FILTER";
+
+			seq_printf(m, "%08x %d %s\n", syscall_arches[arch],
+				   nr, status
+			);
+		}
+	}
+
+	return 0;
+}
+#endif /* CONFIG_PROC_SECCOMP_CACHE */
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
