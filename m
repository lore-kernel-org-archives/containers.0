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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E1C0C2D0A3
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:19 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 985A621D91
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WQlGQ9Jd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 985A621D91
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 593758615D;
	Tue,  3 Nov 2020 13:45:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id GdbKSlKioAWc; Tue,  3 Nov 2020 13:45:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id EF6C385DF5;
	Tue,  3 Nov 2020 13:45:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EA904C088B;
	Tue,  3 Nov 2020 13:45:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 712B5C0051
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 5488D2051F
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cHz-LmyIoaoK
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com
 [209.85.222.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 9F3B12043C
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:16 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id 140so14628752qko.2
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 05:45:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=+eMXBOnvKPM7N/Eu0cs4UA1I6FeurfdgB6uFLVTMPX8=;
 b=WQlGQ9Jd6IJQey7nb9UMUDYsL+DEjmMTVkMHPOOrYSdV926tvA93ywvzKvPW9EdJzQ
 xWYruju83XXsh1i6XxcvxRg6hDqU6tq8BaNfGIDHsg2pgJYtsAkvynEeGwGPRGe+ZPsx
 biGcniO7POm0x08s1Iwq88HHNGiqadVQYcORh5b/WkN2ytRV8n2H7zXHbG9CyN36/TNs
 CvFVpr4PvgANBbzTT2RtpSiuCEWpI/CT6RmO+Fk+zaNRO64hUzWUoNMlpPKDi4ZwlNos
 6rRlllg7BYoJdX53s9pkkLBvkmTEqozVXkK0+PARPMrbpsjLaiSLI/uef0UWqLlg9En5
 LfmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=+eMXBOnvKPM7N/Eu0cs4UA1I6FeurfdgB6uFLVTMPX8=;
 b=QTjnRn9fYRWLb8+AuM1mPla3OGdndci9j+y4D5ISl27LMwRDZKsjnM3K8OeyECePf5
 T2Jr0rle1jmeu5fTQId6YqdocfAdylmTppxj8K3WX1NPiHEl5eIjz5zHr13MO68gaWgq
 bw4DknFFnMkplK1ypX3wGaFraxD81DHzhia/r1bMRoSxvh1DvE+uU0ZO1ktf60dJSnAT
 k6C7kFiPNY+a2d8+UHKEI0XWPR/6DqcRn7E0rD+Ih9NnCFwpEvEA6WuPFwT/a4I9wwcp
 iUq6hEvzF774SnA2CvkWhCEckavAg45EVoUrtr2jxQ/nQkoao7Q67NEyvOI1PjABxy7t
 xJSA==
X-Gm-Message-State: AOAM5307BkVxsau06kWaTTs4ec7fxsibzODpTAb0EULzsI+dvU0+rPmd
 N++5WuJL5yj4WoLvEp3O0EFMQrtHlFcYzw==
X-Google-Smtp-Source: ABdhPJwPGCoGB0mzNqbRbE7eqaQrs2dVEZ+ysMN9iFWpphI5Jv582QKy4aIVAjZqImUIW48ZcJyckw==
X-Received: by 2002:a37:6187:: with SMTP id v129mr8374191qkb.31.1604411115473; 
 Tue, 03 Nov 2020 05:45:15 -0800 (PST)
Received: from zhuyifei1999-ThinkPad-T480.gw.illinois.edu
 ([2620:0:e00:400f::31])
 by smtp.gmail.com with ESMTPSA id a206sm7356568qkb.64.2020.11.03.05.45.14
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 03 Nov 2020 05:45:14 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 5/8] s390: Enable seccomp architecture tracking
Date: Tue,  3 Nov 2020 07:43:01 -0600
Message-Id: <0fbe0c14d598e18effad3b648ab4808f9cd95eba.1604410035.git.yifeifz2@illinois.edu>
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
for s390.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/s390/include/asm/seccomp.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/s390/include/asm/seccomp.h b/arch/s390/include/asm/seccomp.h
index 795bbe0d7ca6..71d46f0ba97b 100644
--- a/arch/s390/include/asm/seccomp.h
+++ b/arch/s390/include/asm/seccomp.h
@@ -16,4 +16,13 @@
 
 #include <asm-generic/seccomp.h>
 
+#define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_S390X
+#define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+#define SECCOMP_ARCH_NATIVE_NAME	"s390x"
+#ifdef CONFIG_COMPAT
+# define SECCOMP_ARCH_COMPAT		AUDIT_ARCH_S390
+# define SECCOMP_ARCH_COMPAT_NR		NR_syscalls
+# define SECCOMP_ARCH_COMPAT_NAME	"s390"
+#endif
+
 #endif	/* _ASM_S390_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
