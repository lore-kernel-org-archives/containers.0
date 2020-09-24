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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71998C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:44:49 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 098F5206D9
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GBAZLxP5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 098F5206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5EC0186C2E;
	Thu, 24 Sep 2020 12:44:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id D1VzaC9o75ZX; Thu, 24 Sep 2020 12:44:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 970D186A84;
	Thu, 24 Sep 2020 12:44:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 91825C0890;
	Thu, 24 Sep 2020 12:44:45 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 85488C0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 7465386AB5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pmShxwQdaw2I
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:43 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f193.google.com (mail-il1-f193.google.com
 [209.85.166.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 264D286A8C
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:43 +0000 (UTC)
Received: by mail-il1-f193.google.com with SMTP id f82so2949349ilh.8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:44:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=2RSGrlZ39dx9fbbfSmGna9gzY/hFO6HuX2v4KEa1nHI=;
 b=GBAZLxP5WwwFM0fNq+ZFT7MskxpVSWDuvAdFCKxl2KNETC/6bz15xg2RyM/MW8CoqZ
 15HkblnhkvdKPZF61y+38XFnBAX+CWPra91dh5EBYViEPR984nFFjmozJoAyJMiy8Lpu
 Hd8ElDE74f44qtwsD3/JbBIZJCHcAFw+cT7s8oNrOMGm/K4JKg5L37liATPhjZryyOnE
 7lyuUe6G/A+VXryIo5SLSPirTkhgipGnI6v+ivy0TeLG9ZKwx3B+C/lCfmns/rHCR35d
 W1+xffOFjTxlt1m0ix/aV2jrI0V4U9W6ytSLEelhkHl+4rFMpaj3JCc4uJLfJzLd8mht
 wQJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=2RSGrlZ39dx9fbbfSmGna9gzY/hFO6HuX2v4KEa1nHI=;
 b=HFJq97dkT2fahmQlH0fwemC3nsiPOdygEVj1VlMXd8X21Ps7UHd1rN0tjGGj4v4m3U
 O4jzrSFDDB1rvZ0nxLz/RpK1iToOXo8aYZMtaC47XFkuPYZLFQtzhICoDxEC8tgdExbG
 cF8b7InXDT/Rm6MduP1nVxfZ4LSOzCnUm0K3WJTK5HpZZNFOSxFVdmjNfSn9j3z03NCX
 /9r6FMV8cCNA2Zs12cmK6BPbKDIYPaeYTLzHSRGjCJd002tOxu9Tz+G/5EmULLQ5nObs
 J8tJLrLkkH/fltMd6oI0K3NQQU6E4pe1RcRviEqmBBa9YFhEJLgLY/j7rOZtqmyhKR3T
 f3iw==
X-Gm-Message-State: AOAM532JXM473xfxPsZyoE0d+mbMD2677U55JAVYrN14b/q69go+Jw5D
 hIbKgXhrJ5wAqZZ6qDwM153lkMB83hLiEw==
X-Google-Smtp-Source: ABdhPJwsnlCtRTwgvCl65RaMxVuVHWLSPLl4gO6FenYoEeCBzwaDOguanaq3vIJFFNko593mZkhNAw==
X-Received: by 2002:a92:3554:: with SMTP id c81mr3964705ila.265.1600951482078; 
 Thu, 24 Sep 2020 05:44:42 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id p5sm1575175ilg.32.2020.09.24.05.44.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:44:41 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
Date: Thu, 24 Sep 2020 07:44:17 -0500
Message-Id: <20bbc8ed4b9f2c83d0f67f37955eb2d789268525.1600951211.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1600951211.git.yifeifz2@illinois.edu>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
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

Seccomp cache emulator needs to know all the architecture numbers
that syscall_get_arch() could return for the kernel build in order
to generate a cache for all of them.

The array is declared in header as static __maybe_unused const
to maximize compiler optimiation opportunities such as loop
unrolling.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/alpha/include/asm/syscall.h      |  4 ++++
 arch/arc/include/asm/syscall.h        | 24 +++++++++++++++++++-----
 arch/arm/include/asm/syscall.h        |  4 ++++
 arch/arm64/include/asm/syscall.h      |  4 ++++
 arch/c6x/include/asm/syscall.h        | 13 +++++++++++--
 arch/csky/include/asm/syscall.h       |  4 ++++
 arch/h8300/include/asm/syscall.h      |  4 ++++
 arch/hexagon/include/asm/syscall.h    |  4 ++++
 arch/ia64/include/asm/syscall.h       |  4 ++++
 arch/m68k/include/asm/syscall.h       |  4 ++++
 arch/microblaze/include/asm/syscall.h |  4 ++++
 arch/mips/include/asm/syscall.h       | 16 ++++++++++++++++
 arch/nds32/include/asm/syscall.h      | 13 +++++++++++--
 arch/nios2/include/asm/syscall.h      |  4 ++++
 arch/openrisc/include/asm/syscall.h   |  4 ++++
 arch/parisc/include/asm/syscall.h     |  7 +++++++
 arch/powerpc/include/asm/syscall.h    | 14 ++++++++++++++
 arch/riscv/include/asm/syscall.h      | 14 ++++++++++----
 arch/s390/include/asm/syscall.h       |  7 +++++++
 arch/sh/include/asm/syscall_32.h      | 17 +++++++++++------
 arch/sparc/include/asm/syscall.h      |  9 +++++++++
 arch/x86/include/asm/syscall.h        | 11 +++++++++++
 arch/x86/um/asm/syscall.h             | 14 ++++++++++----
 arch/xtensa/include/asm/syscall.h     |  4 ++++
 24 files changed, 184 insertions(+), 23 deletions(-)

diff --git a/arch/alpha/include/asm/syscall.h b/arch/alpha/include/asm/syscall.h
index 11c688c1d7ec..625ac9b23f37 100644
--- a/arch/alpha/include/asm/syscall.h
+++ b/arch/alpha/include/asm/syscall.h
@@ -4,6 +4,10 @@
 
 #include <uapi/linux/audit.h>
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_ALPHA
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_ALPHA;
diff --git a/arch/arc/include/asm/syscall.h b/arch/arc/include/asm/syscall.h
index 94529e89dff0..899c13cbf5cc 100644
--- a/arch/arc/include/asm/syscall.h
+++ b/arch/arc/include/asm/syscall.h
@@ -65,14 +65,28 @@ syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
 	}
 }
 
+#ifdef CONFIG_ISA_ARCOMPACT
+# ifdef CONFIG_CPU_BIG_ENDIAN
+#  define SYSCALL_ARCH AUDIT_ARCH_ARCOMPACTBE
+# else
+#  define SYSCALL_ARCH AUDIT_ARCH_ARCOMPACT
+# endif /* CONFIG_CPU_BIG_ENDIAN */
+#else
+# ifdef CONFIG_CPU_BIG_ENDIAN
+#  define SYSCALL_ARCH AUDIT_ARCH_ARCV2BE
+# else
+#  define SYSCALL_ARCH AUDIT_ARCH_ARCV2
+# endif /* CONFIG_CPU_BIG_ENDIAN */
+#endif /* CONFIG_ISA_ARCOMPACT */
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
 static inline int
 syscall_get_arch(struct task_struct *task)
 {
-	return IS_ENABLED(CONFIG_ISA_ARCOMPACT)
-		? (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
-			? AUDIT_ARCH_ARCOMPACTBE : AUDIT_ARCH_ARCOMPACT)
-		: (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
-			? AUDIT_ARCH_ARCV2BE : AUDIT_ARCH_ARCV2);
+	return SYSCALL_ARCH;
 }
 
 #endif
diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
index fd02761ba06c..33ade26e3956 100644
--- a/arch/arm/include/asm/syscall.h
+++ b/arch/arm/include/asm/syscall.h
@@ -73,6 +73,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->ARM_r0 + 1, args, 5 * sizeof(args[0]));
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_ARM
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	/* ARM tasks don't change audit architectures on the fly. */
diff --git a/arch/arm64/include/asm/syscall.h b/arch/arm64/include/asm/syscall.h
index cfc0672013f6..77f3d300e7a0 100644
--- a/arch/arm64/include/asm/syscall.h
+++ b/arch/arm64/include/asm/syscall.h
@@ -82,6 +82,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->regs[1], args, 5 * sizeof(args[0]));
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_ARM, AUDIT_ARCH_AARCH64
+};
+
 /*
  * We don't care about endianness (__AUDIT_ARCH_LE bit) here because
  * AArch64 has the same system calls both on little- and big- endian.
diff --git a/arch/c6x/include/asm/syscall.h b/arch/c6x/include/asm/syscall.h
index 38f3e2284ecd..0d78c67ee1fc 100644
--- a/arch/c6x/include/asm/syscall.h
+++ b/arch/c6x/include/asm/syscall.h
@@ -66,10 +66,19 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	regs->a9 = *args;
 }
 
+#ifdef CONFIG_CPU_BIG_ENDIAN
+#define SYSCALL_ARCH AUDIT_ARCH_C6XBE
+#else
+#define SYSCALL_ARCH AUDIT_ARCH_C6X
+#endif
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
-	return IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
-		? AUDIT_ARCH_C6XBE : AUDIT_ARCH_C6X;
+	return SYSCALL_ARCH;
 }
 
 #endif /* __ASM_C6X_SYSCALLS_H */
diff --git a/arch/csky/include/asm/syscall.h b/arch/csky/include/asm/syscall.h
index f624fa3bbc22..86242d2850d7 100644
--- a/arch/csky/include/asm/syscall.h
+++ b/arch/csky/include/asm/syscall.h
@@ -68,6 +68,10 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->a1, args, 5 * sizeof(regs->a1));
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_CSKY
+};
+
 static inline int
 syscall_get_arch(struct task_struct *task)
 {
diff --git a/arch/h8300/include/asm/syscall.h b/arch/h8300/include/asm/syscall.h
index 01666b8bb263..775f6ac8fde3 100644
--- a/arch/h8300/include/asm/syscall.h
+++ b/arch/h8300/include/asm/syscall.h
@@ -28,6 +28,10 @@ syscall_get_arguments(struct task_struct *task, struct pt_regs *regs,
 	*args   = regs->er6;
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_H8300
+};
+
 static inline int
 syscall_get_arch(struct task_struct *task)
 {
diff --git a/arch/hexagon/include/asm/syscall.h b/arch/hexagon/include/asm/syscall.h
index f6e454f18038..6ee21a76f6a3 100644
--- a/arch/hexagon/include/asm/syscall.h
+++ b/arch/hexagon/include/asm/syscall.h
@@ -45,6 +45,10 @@ static inline long syscall_get_return_value(struct task_struct *task,
 	return regs->r00;
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_HEXAGON
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_HEXAGON;
diff --git a/arch/ia64/include/asm/syscall.h b/arch/ia64/include/asm/syscall.h
index 6c6f16e409a8..19456125c89a 100644
--- a/arch/ia64/include/asm/syscall.h
+++ b/arch/ia64/include/asm/syscall.h
@@ -71,6 +71,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	ia64_syscall_get_set_arguments(task, regs, args, 1);
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_IA64
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_IA64;
diff --git a/arch/m68k/include/asm/syscall.h b/arch/m68k/include/asm/syscall.h
index 465ac039be09..031b051f9026 100644
--- a/arch/m68k/include/asm/syscall.h
+++ b/arch/m68k/include/asm/syscall.h
@@ -4,6 +4,10 @@
 
 #include <uapi/linux/audit.h>
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_M68K
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_M68K;
diff --git a/arch/microblaze/include/asm/syscall.h b/arch/microblaze/include/asm/syscall.h
index 3a6924f3cbde..28cde14056d1 100644
--- a/arch/microblaze/include/asm/syscall.h
+++ b/arch/microblaze/include/asm/syscall.h
@@ -105,6 +105,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 asmlinkage unsigned long do_syscall_trace_enter(struct pt_regs *regs);
 asmlinkage void do_syscall_trace_leave(struct pt_regs *regs);
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_MICROBLAZE
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_MICROBLAZE;
diff --git a/arch/mips/include/asm/syscall.h b/arch/mips/include/asm/syscall.h
index 25fa651c937d..29e4c1c47c54 100644
--- a/arch/mips/include/asm/syscall.h
+++ b/arch/mips/include/asm/syscall.h
@@ -140,6 +140,22 @@ extern const unsigned long sys_call_table[];
 extern const unsigned long sys32_call_table[];
 extern const unsigned long sysn32_call_table[];
 
+static __maybe_unused const int syscall_arches[] = {
+#ifdef __LITTLE_ENDIAN
+	AUDIT_ARCH_MIPSEL,
+# ifdef CONFIG_64BIT
+	AUDIT_ARCH_MIPSEL64,
+	AUDIT_ARCH_MIPSEL64N32,
+# endif /* CONFIG_64BIT */
+#else
+	AUDIT_ARCH_MIPS,
+# ifdef CONFIG_64BIT
+	AUDIT_ARCH_MIPS64,
+	AUDIT_ARCH_MIPS64N32,
+# endif /* CONFIG_64BIT */
+#endif /* __LITTLE_ENDIAN */
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_MIPS;
diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
index 7b5180d78e20..2dd5e33bcfcb 100644
--- a/arch/nds32/include/asm/syscall.h
+++ b/arch/nds32/include/asm/syscall.h
@@ -154,11 +154,20 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->uregs[0] + 1, args, 5 * sizeof(args[0]));
 }
 
+#ifdef CONFIG_CPU_BIG_ENDIAN
+#define SYSCALL_ARCH AUDIT_ARCH_NDS32BE
+#else
+#define SYSCALL_ARCH AUDIT_ARCH_NDS32
+#endif
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
 static inline int
 syscall_get_arch(struct task_struct *task)
 {
-	return IS_ENABLED(CONFIG_CPU_BIG_ENDIAN)
-		? AUDIT_ARCH_NDS32BE : AUDIT_ARCH_NDS32;
+	return SYSCALL_ARCH;
 }
 
 #endif /* _ASM_NDS32_SYSCALL_H */
diff --git a/arch/nios2/include/asm/syscall.h b/arch/nios2/include/asm/syscall.h
index 526449edd768..8fa2716cac5a 100644
--- a/arch/nios2/include/asm/syscall.h
+++ b/arch/nios2/include/asm/syscall.h
@@ -69,6 +69,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	regs->r9 = *args;
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_NIOS2
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_NIOS2;
diff --git a/arch/openrisc/include/asm/syscall.h b/arch/openrisc/include/asm/syscall.h
index e6383be2a195..4eb28ad08042 100644
--- a/arch/openrisc/include/asm/syscall.h
+++ b/arch/openrisc/include/asm/syscall.h
@@ -64,6 +64,10 @@ syscall_set_arguments(struct task_struct *task, struct pt_regs *regs,
 	memcpy(&regs->gpr[3], args, 6 * sizeof(args[0]));
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_OPENRISC
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_OPENRISC;
diff --git a/arch/parisc/include/asm/syscall.h b/arch/parisc/include/asm/syscall.h
index 00b127a5e09b..2915f140c9fd 100644
--- a/arch/parisc/include/asm/syscall.h
+++ b/arch/parisc/include/asm/syscall.h
@@ -55,6 +55,13 @@ static inline void syscall_rollback(struct task_struct *task,
 	/* do nothing */
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_PARISC,
+#ifdef CONFIG_64BIT
+	AUDIT_ARCH_PARISC64,
+#endif
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch = AUDIT_ARCH_PARISC;
diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/asm/syscall.h
index fd1b518eed17..781deb211e3d 100644
--- a/arch/powerpc/include/asm/syscall.h
+++ b/arch/powerpc/include/asm/syscall.h
@@ -104,6 +104,20 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	regs->orig_gpr3 = args[0];
 }
 
+static __maybe_unused const int syscall_arches[] = {
+#ifdef __LITTLE_ENDIAN__
+	AUDIT_ARCH_PPC | __AUDIT_ARCH_LE,
+# ifdef CONFIG_PPC64
+	AUDIT_ARCH_PPC64LE,
+# endif /* CONFIG_PPC64 */
+#else
+	AUDIT_ARCH_PPC,
+# ifdef CONFIG_PPC64
+	AUDIT_ARCH_PPC64,
+# endif /* CONFIG_PPC64 */
+#endif /* __LITTLE_ENDIAN__ */
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	int arch;
diff --git a/arch/riscv/include/asm/syscall.h b/arch/riscv/include/asm/syscall.h
index 49350c8bd7b0..4b36d358243e 100644
--- a/arch/riscv/include/asm/syscall.h
+++ b/arch/riscv/include/asm/syscall.h
@@ -73,13 +73,19 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->a1, args, 5 * sizeof(regs->a1));
 }
 
-static inline int syscall_get_arch(struct task_struct *task)
-{
 #ifdef CONFIG_64BIT
-	return AUDIT_ARCH_RISCV64;
+#define SYSCALL_ARCH AUDIT_ARCH_RISCV64
 #else
-	return AUDIT_ARCH_RISCV32;
+#define SYSCALL_ARCH AUDIT_ARCH_RISCV32
 #endif
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
+static inline int syscall_get_arch(struct task_struct *task)
+{
+	return SYSCALL_ARCH;
 }
 
 #endif	/* _ASM_RISCV_SYSCALL_H */
diff --git a/arch/s390/include/asm/syscall.h b/arch/s390/include/asm/syscall.h
index d9d5de0f67ff..4cb9da36610a 100644
--- a/arch/s390/include/asm/syscall.h
+++ b/arch/s390/include/asm/syscall.h
@@ -89,6 +89,13 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	regs->orig_gpr2 = args[0];
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_S390X,
+#ifdef CONFIG_COMPAT
+	AUDIT_ARCH_S390,
+#endif
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 #ifdef CONFIG_COMPAT
diff --git a/arch/sh/include/asm/syscall_32.h b/arch/sh/include/asm/syscall_32.h
index cb51a7528384..4780f2339c72 100644
--- a/arch/sh/include/asm/syscall_32.h
+++ b/arch/sh/include/asm/syscall_32.h
@@ -69,13 +69,18 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	regs->regs[4] = args[0];
 }
 
-static inline int syscall_get_arch(struct task_struct *task)
-{
-	int arch = AUDIT_ARCH_SH;
-
 #ifdef CONFIG_CPU_LITTLE_ENDIAN
-	arch |= __AUDIT_ARCH_LE;
+#define SYSCALL_ARCH AUDIT_ARCH_SHEL
+#else
+#define SYSCALL_ARCH AUDIT_ARCH_SH
 #endif
-	return arch;
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
+static inline int syscall_get_arch(struct task_struct *task)
+{
+	return SYSCALL_ARCH;
 }
 #endif /* __ASM_SH_SYSCALL_32_H */
diff --git a/arch/sparc/include/asm/syscall.h b/arch/sparc/include/asm/syscall.h
index 62a5a78804c4..a458992cdcfe 100644
--- a/arch/sparc/include/asm/syscall.h
+++ b/arch/sparc/include/asm/syscall.h
@@ -127,6 +127,15 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		regs->u_regs[UREG_I0 + i] = args[i];
 }
 
+static __maybe_unused const int syscall_arches[] = {
+#ifdef CONFIG_SPARC64
+	AUDIT_ARCH_SPARC64,
+#endif
+#if !defined(CONFIG_SPARC64) || defined(CONFIG_COMPAT)
+	AUDIT_ARCH_SPARC,
+#endif
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 #if defined(CONFIG_SPARC64) && defined(CONFIG_COMPAT)
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index 7cbf733d11af..e13bb2a65b6f 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -97,6 +97,10 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->bx + i, args, n * sizeof(args[0]));
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_I386
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_I386;
@@ -152,6 +156,13 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	}
 }
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_X86_64,
+#ifdef CONFIG_IA32_EMULATION
+	AUDIT_ARCH_I386,
+#endif
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	/* x32 tasks should be considered AUDIT_ARCH_X86_64. */
diff --git a/arch/x86/um/asm/syscall.h b/arch/x86/um/asm/syscall.h
index 56a2f0913e3c..590a31e22b99 100644
--- a/arch/x86/um/asm/syscall.h
+++ b/arch/x86/um/asm/syscall.h
@@ -9,13 +9,19 @@ typedef asmlinkage long (*sys_call_ptr_t)(unsigned long, unsigned long,
 					  unsigned long, unsigned long,
 					  unsigned long, unsigned long);
 
-static inline int syscall_get_arch(struct task_struct *task)
-{
 #ifdef CONFIG_X86_32
-	return AUDIT_ARCH_I386;
+#define SYSCALL_ARCH AUDIT_ARCH_I386
 #else
-	return AUDIT_ARCH_X86_64;
+#define SYSCALL_ARCH AUDIT_ARCH_X86_64
 #endif
+
+static __maybe_unused const int syscall_arches[] = {
+	SYSCALL_ARCH
+};
+
+static inline int syscall_get_arch(struct task_struct *task)
+{
+	return SYSCALL_ARCH;
 }
 
 #endif /* __UM_ASM_SYSCALL_H */
diff --git a/arch/xtensa/include/asm/syscall.h b/arch/xtensa/include/asm/syscall.h
index f9a671cbf933..3d334fb0d329 100644
--- a/arch/xtensa/include/asm/syscall.h
+++ b/arch/xtensa/include/asm/syscall.h
@@ -14,6 +14,10 @@
 #include <asm/ptrace.h>
 #include <uapi/linux/audit.h>
 
+static __maybe_unused const int syscall_arches[] = {
+	AUDIT_ARCH_XTENSA
+};
+
 static inline int syscall_get_arch(struct task_struct *task)
 {
 	return AUDIT_ARCH_XTENSA;
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
