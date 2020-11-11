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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFC1C388F9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:49 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B61C72074B
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F8D/Y+HZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B61C72074B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5057C868AD;
	Wed, 11 Nov 2020 13:34:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MB9uVsdaZePl; Wed, 11 Nov 2020 13:34:47 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 936E88686D;
	Wed, 11 Nov 2020 13:34:47 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 87887C1AD4;
	Wed, 11 Nov 2020 13:34:47 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9F02CC016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 7DEC3204AA
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 52rsMiGWfo6X
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com
 [209.85.222.193])
 by silver.osuosl.org (Postfix) with ESMTPS id A4DEC2DE2A
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 199so1580724qkg.9
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=KyUFBIsp7WG/ZlJY7JJxE8NR9eUIpLAxO9Zr6R0PBAI=;
 b=F8D/Y+HZfrpZoxY1WSpU1XD08FGxbbmSRvBeCuS4pVYlmDmDfHK+86TEUz2GSieEB6
 /G826gCZaufPpqw9yqU3gNUSRCTgM9O12K4UhmNyeNdIkVTjqwPtJI9Lf+tvkb9Fg8+c
 qRpmL5clJ5CA1S+ea2Ab7oCBQhLxWEhivtggHkttRUxU6H+6bwKCbKQw40vyQeowP2ps
 XMXoUoPJxCmgod7Htt5aWIQRnBxAeBFeM00worN++PmF2dIyJGX4tB4Z/JpSdxEQSkmp
 0SlWBQ6C7R2fx7uyThUkfX85xTr/0pRg1d8IYFbC/KQ5PAYWXyryWS92ixdQ2PxoggBD
 zMoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=KyUFBIsp7WG/ZlJY7JJxE8NR9eUIpLAxO9Zr6R0PBAI=;
 b=qxx5qBfON5cH+vDwrcVWww3+LYzAFgb/rtVQqiIkoNVAGnqfTYFPoIrSnXSVYS0Tdx
 q+u0624x42FPq5VDctgdKMtqfEdjDXQzFq+F0DMaz9DSzEVT3kmwXzdjEzizzRx94gE5
 i5tEWZ0q5muzZrVN4DFTTjHwq5E1L0APqU171SlWJZDLJ3Cog8lCliJc4KI8i8U2PuV6
 Cjkj03doqbVAxECTh6SXSzhAjzyBBfNGCPd8lzCEpyBGDlJ2H8vL2JP6OiN65YPuTcqR
 gs7eJJIzFhAwPeM9ACyMcDaegRMZ6GA+j92v1kUruol7ggWw/Zo9O0l24lr0M4LIZbHD
 TGfg==
X-Gm-Message-State: AOAM533GZWyhqviS6BD5iMm23oqJ4cJl7rqERdydio2x9zYLh4GQi+06
 1LkzbbkQYvwcXH/1gkOG1coFsBxPpGHsCA==
X-Google-Smtp-Source: ABdhPJz84XkbzmcCHTc2+SdZFUqORQfeEggNtVRT4ylMevKQ8zIMjt4i44s0v7vCLpX1u6c6tS/Tlw==
X-Received: by 2002:a37:4145:: with SMTP id o66mr19607495qka.426.1605101683404; 
 Wed, 11 Nov 2020 05:34:43 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.41
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:42 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 7/8] xtensa: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:53 -0600
Message-Id: <79669648ba167d668ea6ffb4884250abcd5ed254.1605101222.git.yifeifz2@illinois.edu>
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
for xtensa.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/xtensa/include/asm/Kbuild    |  1 -
 arch/xtensa/include/asm/seccomp.h | 11 +++++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)
 create mode 100644 arch/xtensa/include/asm/seccomp.h

diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index c59c42a1221a..9718e9593564 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -7,5 +7,4 @@ generic-y += mcs_spinlock.h
 generic-y += param.h
 generic-y += qrwlock.h
 generic-y += qspinlock.h
-generic-y += seccomp.h
 generic-y += user.h
diff --git a/arch/xtensa/include/asm/seccomp.h b/arch/xtensa/include/asm/seccomp.h
new file mode 100644
index 000000000000..f1cb6b0a9e1f
--- /dev/null
+++ b/arch/xtensa/include/asm/seccomp.h
@@ -0,0 +1,11 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+#ifndef _ASM_SECCOMP_H
+#define _ASM_SECCOMP_H
+
+#include <asm-generic/seccomp.h>
+
+#define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_XTENSA
+#define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+#define SECCOMP_ARCH_NATIVE_NAME	"xtensa"
+
+#endif /* _ASM_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
