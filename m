Return-Path: <SRS0=6hu2=EJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48AA7C2D0A3
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:13 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C4CFA21534
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HUmeo8PK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4CFA21534
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9BA8E85DF8;
	Tue,  3 Nov 2020 13:45:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FiE5SSIWu4AK; Tue,  3 Nov 2020 13:45:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 89D8585DDC;
	Tue,  3 Nov 2020 13:45:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 85A46C088B;
	Tue,  3 Nov 2020 13:45:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E3EF3C0051
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D015A8723C
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wDBxy2GBDs18
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com
 [209.85.222.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3EF9387232
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:09 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id r7so14640662qkf.3
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 05:45:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=/wWgXpwOKfWu89zfH4z55YdVS4FoKgsyU3KjhUPw2Xk=;
 b=HUmeo8PKFkCINZljvfRc+P6j2X0+0GOhvVUFZGwDVi5RBcL6yCRRP7JuB0zv9c9+Po
 E3+9kj9NX57UzwwDZNGdD8iaYBGU9wXX967tHeoCgvkJm1CovDmhTO1emhffrLi5usDF
 0oEzRtLhoIuA39ggcO6eQcTv/OGvRmPgCQX4sTZrzio50ODOqs0YICXq0MgBjQAfHPdz
 xl7tXTacq4qNhz9LC51MS1M++unu3TcfcbkGRzSQxWGdRezIwQbhQELfkQD+RH+S21A/
 sax7yhctLMgZTMGgygja3clLmsRRE7W8PkbbGI7EUIeZ8EaqV18ap7HIw7j/Z7WF3HJx
 8pfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=/wWgXpwOKfWu89zfH4z55YdVS4FoKgsyU3KjhUPw2Xk=;
 b=Ep0ZxlFJ0L55m1nslTVslpMAeFyAIMVYTJ+bQ8tgmbP5ajIKv6hqG6Pwq+19M9wB7f
 O4ffA+M3eDY68cSWfoVdbxl3LZIG13tylemT2gJdlTQh58RzK9FZ1bhKv7K5dsOq1U93
 E8ss9QVW7DLcGT7zmZ7oAXjFqZ279VIcxNviSAa1kGScjD+BHqBaUGLZvfVLxjLtwpKT
 8vCZA/JkLWrCK/55RdXjFvyINxGC2lEer4DLicDoFas4SN5qblSG6eXXzCMcOYTY+4UQ
 EAxu9rLysvAY7t0xndWUko46MpZbnv3e8Y3qRN2z2GdoME+WQGvq8Sa5jhIptbdCeVr2
 mlpg==
X-Gm-Message-State: AOAM532eg0G87CaOcz/Jf2y+3lmQ5hDNCgwf3VJ2Lorw5mXDjFiOnHoO
 WnRDuIvz5teGSC9+/OjSk9gGuBo6XhscGw==
X-Google-Smtp-Source: ABdhPJyHAHCGbEEm09WION+/UIzzZ/lrqbH487CGEGOVROPc59579zIEupD9GaMmhFNRyF9+2N11RQ==
X-Received: by 2002:ae9:dec5:: with SMTP id
 s188mr20227157qkf.250.1604411107951; 
 Tue, 03 Nov 2020 05:45:07 -0800 (PST)
Received: from zhuyifei1999-ThinkPad-T480.gw.illinois.edu
 ([2620:0:e00:400f::31])
 by smtp.gmail.com with ESMTPSA id a206sm7356568qkb.64.2020.11.03.05.45.06
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 03 Nov 2020 05:45:07 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 1/8] csky: Enable seccomp architecture tracking
Date: Tue,  3 Nov 2020 07:42:57 -0600
Message-Id: <f9219026d4803b22f3e57e3768b4e42e004ef236.1604410035.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1604410035.git.yifeifz2@illinois.edu>
References: <cover.1604410035.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: linux-sh@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 linux-riscv@lists.infradead.org, Andrea Arcangeli <aarcange@redhat.com>,
 linux-s390@vger.kernel.org, YiFei Zhu <yifeifz2@illinois.edu>,
 linux-csky@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>,
 linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Valentin Rothberg <vrothber@redhat.com>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>,
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
for csky.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/csky/include/asm/Kbuild    |  1 -
 arch/csky/include/asm/seccomp.h | 11 +++++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)
 create mode 100644 arch/csky/include/asm/seccomp.h

diff --git a/arch/csky/include/asm/Kbuild b/arch/csky/include/asm/Kbuild
index 64876e59e2ef..93372255984d 100644
--- a/arch/csky/include/asm/Kbuild
+++ b/arch/csky/include/asm/Kbuild
@@ -4,6 +4,5 @@ generic-y += gpio.h
 generic-y += kvm_para.h
 generic-y += local64.h
 generic-y += qrwlock.h
-generic-y += seccomp.h
 generic-y += user.h
 generic-y += vmlinux.lds.h
diff --git a/arch/csky/include/asm/seccomp.h b/arch/csky/include/asm/seccomp.h
new file mode 100644
index 000000000000..d33e758126fb
--- /dev/null
+++ b/arch/csky/include/asm/seccomp.h
@@ -0,0 +1,11 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+#ifndef _ASM_SECCOMP_H
+#define _ASM_SECCOMP_H
+
+#include <asm-generic/seccomp.h>
+
+#define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_CSKY
+#define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+#define SECCOMP_ARCH_NATIVE_NAME	"csky"
+
+#endif /* _ASM_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
