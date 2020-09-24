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
	by smtp.lore.kernel.org (Postfix) with ESMTP id CABCFC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:06:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 33F6520758
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t7yO5Fq9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33F6520758
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2C72A824DC;
	Thu, 24 Sep 2020 12:06:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hRpt9Ol2Pppq; Thu, 24 Sep 2020 12:06:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4DF3C86F5E;
	Thu, 24 Sep 2020 12:06:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3E3DBC0859;
	Thu, 24 Sep 2020 12:06:19 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6C155C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 47F0D2DE2A
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id eJ2-m3+1oGAv
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com
 [209.85.166.67])
 by silver.osuosl.org (Postfix) with ESMTPS id 77E81228B3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:15 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id q4so3018808iop.5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:06:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=vVtc8/AttZR1MSjVTJ8WZqoJcQR03mZ2toS3D2ZBVEk=;
 b=t7yO5Fq9yP3pn4VQW1fPfJ+R4hL3qeIuK0BE1AclJ3OsrcObGTY2v1uyTWqIflif/6
 BSQPup/qfz4pA1BvY+R4/7EzXnSuWiYily9W9H63sPAOPG21SAJVjwPy7nVzOkeesg22
 e8DoicOZgybtaJamuHVG7/6Hj1CjTDHxqK5h1wb5wiH16Xk4Nw7jh1rrzwl3HHMPtgxL
 Nm1AYCElIv7ht+nBCXverlSMjJDCjpgM4mxKmNT0RU4g3cxOTmKH4oN24G5qSjnZCclb
 Or97QEwIG5XrMA6FsRYK1b8EUtH6qCFoEL4nNYAym0DpWELVzb+8lcilyzNcQV/y5F7w
 Q74w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=vVtc8/AttZR1MSjVTJ8WZqoJcQR03mZ2toS3D2ZBVEk=;
 b=MJrH1M8O9T9uY15XpUpgUqT2AKmARJyonWFxl08+DmH0JWk0Io6XKZ9Qyw74uZa5X5
 WLG4kIO1IT3Vb1Jh2gDR7Q4iG3f27/UOQ3m2tHN5f8F/B7Rf00WDapTGNx5sOXW2i7lW
 olrH1B4WuGpXpc9Ehd5AuW4BqFvWpL/8Us7Az7x2vc1I+2pCWNsagDNH2oROswJjJzO/
 d4b6lhdJATcEwhjCskjCtGOVuQE5dQ3wxQKhQyeTgrL6RUdBTLcJxdEvTYWmRwI/1bvD
 0jLey0sgerjmPGwpIjh3ymArmKMf417lkHgUhl2QhKBNWEzmBOskdssclSngmoG9bcs7
 jZxA==
X-Gm-Message-State: AOAM530b51RfdJHqx5eUrJkHHJKqKKKHUFU+oxFM9GtsFB+AZeMSkK//
 RrlxzTL51dOnMayQ7Iv3e1KBNwRl2lBg9g==
X-Google-Smtp-Source: ABdhPJyhILKTel3UzQIfbg+8snqJfhv5D4QAfw2iJcGyqJHBzpAVIBd+C1yNTiyTkmBJgt7XCq6vCA==
X-Received: by 2002:a6b:2b07:: with SMTP id r7mr2955249ior.181.1600949173899; 
 Thu, 24 Sep 2020 05:06:13 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id 137sm1342369ioc.20.2020.09.24.05.06.12
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:06:13 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
Date: Thu, 24 Sep 2020 07:06:00 -0500
Message-Id: <9ede6ef35c847e58d61e476c6a39540520066613.1600946701.git.yifeifz2@illinois.edu>
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

In order to make adding configurable features into seccomp
easier, it's better to have the options at one single location,
considering easpecially that the bulk of seccomp code is
arch-independent. An quick look also show that many SECCOMP
descriptions are outdated; they talk about /proc rather than
prctl.

As a result of moving the config option and keeping it default
on, architectures arm, arm64, csky, riscv, sh, and xtensa
did not have SECCOMP on by default prior to this and SECCOMP will
be default in this change.

Architectures microblaze, mips, powerpc, s390, sh, and sparc
have an outdated depend on PROC_FS and this dependency is removed
in this change.

Suggested-by: Jann Horn <jannh@google.com>
Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig            | 21 +++++++++++++++++++++
 arch/arm/Kconfig        | 15 +--------------
 arch/arm64/Kconfig      | 13 -------------
 arch/csky/Kconfig       | 13 -------------
 arch/microblaze/Kconfig | 18 +-----------------
 arch/mips/Kconfig       | 17 -----------------
 arch/parisc/Kconfig     | 16 ----------------
 arch/powerpc/Kconfig    | 17 -----------------
 arch/riscv/Kconfig      | 13 -------------
 arch/s390/Kconfig       | 17 -----------------
 arch/sh/Kconfig         | 16 ----------------
 arch/sparc/Kconfig      | 18 +-----------------
 arch/um/Kconfig         | 16 ----------------
 arch/x86/Kconfig        | 16 ----------------
 arch/xtensa/Kconfig     | 14 --------------
 15 files changed, 24 insertions(+), 216 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index af14a567b493..6dfc5673215d 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -444,8 +444,12 @@ config ARCH_WANT_OLD_COMPAT_IPC
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
 	bool
 
+config HAVE_ARCH_SECCOMP
+	bool
+
 config HAVE_ARCH_SECCOMP_FILTER
 	bool
+	select HAVE_ARCH_SECCOMP
 	help
 	  An arch should select this symbol if it provides all of these things:
 	  - syscall_get_arch()
@@ -458,6 +462,23 @@ config HAVE_ARCH_SECCOMP_FILTER
 	    results in the system call being skipped immediately.
 	  - seccomp syscall wired up
 
+config SECCOMP
+	def_bool y
+	depends on HAVE_ARCH_SECCOMP
+	prompt "Enable seccomp to safely compute untrusted bytecode"
+	help
+	  This kernel feature is useful for number crunching applications
+	  that may need to compute untrusted bytecode during their
+	  execution. By using pipes or other transports made available to
+	  the process as file descriptors supporting the read/write
+	  syscalls, it's possible to isolate those applications in
+	  their own address space using seccomp. Once seccomp is
+	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
+	  and the task is only allowed to execute a few safe syscalls
+	  defined by each seccomp mode.
+
+	  If unsure, say Y. Only embedded should say N here.
+
 config SECCOMP_FILTER
 	def_bool y
 	depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP && NET
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index e00d94b16658..e26c19a16284 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -67,6 +67,7 @@ config ARM
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_MMAP_RND_BITS if MMU
+	select HAVE_ARCH_SECCOMP
 	select HAVE_ARCH_SECCOMP_FILTER if AEABI && !OABI_COMPAT
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_TRACEHOOK
@@ -1617,20 +1618,6 @@ config UACCESS_WITH_MEMCPY
 	  However, if the CPU data cache is using a write-allocate mode,
 	  this option is unlikely to provide any performance gain.
 
-config SECCOMP
-	bool
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
 config PARAVIRT
 	bool "Enable paravirtualization code"
 	help
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6d232837cbee..98c4e34cbec1 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1033,19 +1033,6 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config CC_HAVE_SHADOW_CALL_STACK
 	def_bool $(cc-option, -fsanitize=shadow-call-stack -ffixed-x18)
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
 config PARAVIRT
 	bool "Enable paravirtualization code"
 	help
diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
index 3d5afb5f5685..7f424c85772c 100644
--- a/arch/csky/Kconfig
+++ b/arch/csky/Kconfig
@@ -309,16 +309,3 @@ endmenu
 source "arch/csky/Kconfig.platforms"
 
 source "kernel/Kconfig.hz"
-
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
index d262ac0c8714..37bd6a5f38fb 100644
--- a/arch/microblaze/Kconfig
+++ b/arch/microblaze/Kconfig
@@ -26,6 +26,7 @@ config MICROBLAZE
 	select GENERIC_SCHED_CLOCK
 	select HAVE_ARCH_HASH
 	select HAVE_ARCH_KGDB
+	select HAVE_ARCH_SECCOMP
 	select HAVE_DEBUG_KMEMLEAK
 	select HAVE_DMA_CONTIGUOUS
 	select HAVE_DYNAMIC_FTRACE
@@ -120,23 +121,6 @@ config CMDLINE_FORCE
 	  Set this to have arguments from the default kernel command string
 	  override those passed by the boot loader.
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	depends on PROC_FS
-	default y
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via /proc/<pid>/seccomp, it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
-
 endmenu
 
 menu "Kernel features"
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index c95fa3a2484c..5f88a8fc11fc 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -3004,23 +3004,6 @@ config PHYSICAL_START
 	  specified in the "crashkernel=YM@XM" command line boot parameter
 	  passed to the panic-ed kernel).
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	depends on PROC_FS
-	default y
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via /proc/<pid>/seccomp, it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
-
 config MIPS_O32_FP64_SUPPORT
 	bool "Support for O32 binaries using 64-bit FP" if !CPU_MIPSR6
 	depends on 32BIT || MIPS32_O32
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 3b0f53dd70bc..cd4afe1e7a6c 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -378,19 +378,3 @@ endmenu
 
 
 source "drivers/parisc/Kconfig"
-
-config SECCOMP
-	def_bool y
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 1f48bbfb3ce9..136fe860caef 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -934,23 +934,6 @@ config ARCH_WANTS_FREEZER_CONTROL
 
 source "kernel/power/Kconfig"
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	depends on PROC_FS
-	default y
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via /proc/<pid>/seccomp, it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
-
 config PPC_MEM_KEYS
 	prompt "PowerPC Memory Protection Keys"
 	def_bool y
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index df18372861d8..c456b558fab9 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -333,19 +333,6 @@ menu "Kernel features"
 
 source "kernel/Kconfig.hz"
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
 config RISCV_SBI_V01
 	bool "SBI v0.1 support"
 	default y
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 3d86e12e8e3c..7f7b40ec699e 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -791,23 +791,6 @@ config CRASH_DUMP
 
 endmenu
 
-config SECCOMP
-	def_bool y
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	depends on PROC_FS
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via /proc/<pid>/seccomp, it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y.
-
 config CCW
 	def_bool y
 
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index d20927128fce..18278152c91c 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -600,22 +600,6 @@ config PHYSICAL_START
 	  where the fail safe kernel needs to run at a different address
 	  than the panic-ed kernel.
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	depends on PROC_FS
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl, it cannot be disabled and the task is only
-	  allowed to execute a few safe syscalls defined by each seccomp
-	  mode.
-
-	  If unsure, say N.
-
 config SMP
 	bool "Symmetric multi-processing support"
 	depends on SYS_SUPPORTS_SMP
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index efeff2c896a5..d62ce83cf009 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -23,6 +23,7 @@ config SPARC
 	select HAVE_OPROFILE
 	select HAVE_ARCH_KGDB if !SMP || SPARC64
 	select HAVE_ARCH_TRACEHOOK
+	select HAVE_ARCH_SECCOMP if SPARC64
 	select HAVE_EXIT_THREAD
 	select HAVE_PCI
 	select SYSCTL_EXCEPTION_TRACE
@@ -226,23 +227,6 @@ config EARLYFB
 	help
 	  Say Y here to enable a faster early framebuffer boot console.
 
-config SECCOMP
-	bool "Enable seccomp to safely compute untrusted bytecode"
-	depends on SPARC64 && PROC_FS
-	default y
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via /proc/<pid>/seccomp, it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
-
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs"
 	depends on SPARC64 && SMP
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index eb51fec75948..d49f471b02e3 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -173,22 +173,6 @@ config PGTABLE_LEVELS
 	default 3 if 3_LEVEL_PGTABLES
 	default 2
 
-config SECCOMP
-	def_bool y
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y.
-
 config UML_TIME_TRAVEL_SUPPORT
 	bool
 	prompt "Support time-travel mode (e.g. for test execution)"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7101ac64bb20..1ab22869a765 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1968,22 +1968,6 @@ config EFI_MIXED
 
 	   If unsure, say N.
 
-config SECCOMP
-	def_bool y
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
-	  If unsure, say Y. Only embedded should say N here.
-
 source "kernel/Kconfig.hz"
 
 config KEXEC
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index e997e0119c02..d8a29dc5a284 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -217,20 +217,6 @@ config HOTPLUG_CPU
 
 	  Say N if you want to disable CPU hotplug.
 
-config SECCOMP
-	bool
-	prompt "Enable seccomp to safely compute untrusted bytecode"
-	help
-	  This kernel feature is useful for number crunching applications
-	  that may need to compute untrusted bytecode during their
-	  execution. By using pipes or other transports made available to
-	  the process as file descriptors supporting the read/write
-	  syscalls, it's possible to isolate those applications in
-	  their own address space using seccomp. Once seccomp is
-	  enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
-	  and the task is only allowed to execute a few safe syscalls
-	  defined by each seccomp mode.
-
 config FAST_SYSCALL_XTENSA
 	bool "Enable fast atomic syscalls"
 	default n
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
