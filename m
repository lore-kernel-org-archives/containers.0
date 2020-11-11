Return-Path: <SRS0=9Lh8=ER=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 351C2C388F9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8E67B206D9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dNk+mHcn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E67B206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1A1F2867F3;
	Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LSgRva5CazFf; Wed, 11 Nov 2020 13:34:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id BFD3F8687B;
	Wed, 11 Nov 2020 13:34:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A7ED2C1AD6;
	Wed, 11 Nov 2020 13:34:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E87C2C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id D7EAF86226
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gj17Lyv15svL
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:36 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com
 [209.85.222.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6141D860B2
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:36 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id d9so1593017qke.8
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=LIHaRbcW33holGtLxAdu7MnC0XA7v48flZenL4Xa8vU=;
 b=dNk+mHcnxtrEMnoth+9YuSZp+YnaTGFIRKqb6ReOwm4fVp8t0mkh3bSdlUABRoAUlx
 tqquHCE17akyy8N/Nvpjg7Qp3AoZ+ubiA4cXGcr+8ulSr6YMzogVfYe8HW84FHb0lUm/
 /WtN9ZpC8VKXLz1L5tvxxFBda/OJbmO8xfmRMZm9yZjClDUw3ZscP+K5NBtyp4h7niez
 LHJ/nuWNzhr4vfD1yroJHXynte84EkEErCMxO2wU7yBLkN2zhT/krvfPoB2KZrvmREHc
 mmIHwwl9ZlD8hTh+jTTrb+HdoDQ4CsYqasWnyeceqpG0wekPMdPvQ3VXOB/H33Sm4FEB
 Rwzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=LIHaRbcW33holGtLxAdu7MnC0XA7v48flZenL4Xa8vU=;
 b=nN7XhbyQEGO934kF71RyJNZvIAy8p2AXRp/oSkKriNB4jjTpn6860Hl1hHAr8GYJC8
 n1UD3TRryzyoaO4t85Hh4CC9C/RbRgt+FcIezGE/vK0WMvOEeDpjBNqnPCLnPzqYK7fI
 3x7Z64KiaG32ZCZ1Hj+LLBCOdEbK2XUR3cczXncK/OsRdrTTYgWYGSExImcd7cAZ9ZJ7
 mPP1mPNNM7iyeGc8HtHDhzLXWBSCWs8VLhkYQWqtWbu7qMtxxoJgCVOnJ1EffmhB7f6d
 jmS0r+lmO7w0MvhoGSlM/oTrNXAN+l2ytQNUeoyDsm6+yjHs2/1mEVX8TTKu/SPebS3N
 CpBQ==
X-Gm-Message-State: AOAM532nEz7cgN+InSDN4iScecwVo1li1uJL/7fSD4Vgq9yEsw4TVqbM
 CQMCWdCymN+JdsIR1XOm1jgMRKx84eTnRw==
X-Google-Smtp-Source: ABdhPJwWi7mIj07jdzREPXg7rZ5J8YjabnB76CW+3UwHPeuu2d0EaLhFYKhjOvqP7+1Mxz1/dz90Iw==
X-Received: by 2002:a05:620a:142e:: with SMTP id
 k14mr24946158qkj.483.1605101675195; 
 Wed, 11 Nov 2020 05:34:35 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.33
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:34 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 2/8] parisc: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:48 -0600
Message-Id: <9bb86c546eda753adf5270425e7353202dbce87c.1605101222.git.yifeifz2@illinois.edu>
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

To enable seccomp constant action bitmaps, we need to have a static
mapping to the audit architecture and system call table size. Add these
for parisc.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/parisc/include/asm/Kbuild    |  1 -
 arch/parisc/include/asm/seccomp.h | 22 ++++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)
 create mode 100644 arch/parisc/include/asm/seccomp.h

diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index e3ee5c0bfe80..f16c4db80116 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -5,5 +5,4 @@ generated-y += syscall_table_c32.h
 generic-y += kvm_para.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
-generic-y += seccomp.h
 generic-y += user.h
diff --git a/arch/parisc/include/asm/seccomp.h b/arch/parisc/include/asm/seccomp.h
new file mode 100644
index 000000000000..b058b2220322
--- /dev/null
+++ b/arch/parisc/include/asm/seccomp.h
@@ -0,0 +1,22 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+#ifndef _ASM_SECCOMP_H
+#define _ASM_SECCOMP_H
+
+#include <asm-generic/seccomp.h>
+
+#ifdef CONFIG_64BIT
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_PARISC64
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"parisc64"
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT		AUDIT_ARCH_PARISC
+#  define SECCOMP_ARCH_COMPAT_NR	NR_syscalls
+#  define SECCOMP_ARCH_COMPAT_NAME	"parisc"
+# endif
+#else /* !CONFIG_64BIT */
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_PARISC
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"parisc"
+#endif
+
+#endif /* _ASM_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
