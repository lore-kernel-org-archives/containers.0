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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C444AC2D0A3
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:16 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5060921534
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l1UUt3QN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5060921534
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id E7E5886CAE;
	Tue,  3 Nov 2020 13:45:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ygFCWU+ZHgVq; Tue,  3 Nov 2020 13:45:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id BFCEA86A35;
	Tue,  3 Nov 2020 13:45:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BB15FC088B;
	Tue,  3 Nov 2020 13:45:14 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 61803C0051
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 46791203F0
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WZbzEy688c33
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:13 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com
 [209.85.222.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 4AA912043C
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:13 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id k9so14611570qki.6
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 05:45:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=PCRJp91/82MIer7BGmfwt2GKdylAg2x5Gxk5MeSJA78=;
 b=l1UUt3QNH+lFGhcDNXPtNMRtkqffL4tl2O3N54zCmMcpor3j0kMgvLUkphpicH1DmA
 e9gal6RMIMfV24ZCzIyXif3axp17c+gJqxlt5Z8rdoWW187/XRB5yRLtrmSF3fnFNRa5
 Gz4l7hh+A/kcwK1wh/9J1YbL45kF8pUgj+gZr8qTNoaduXm4U4vFw5nLxuqYxEhO9TH3
 1FHIRwqPxk86OlrRsKwElUT5rJ7lTXmfKiLIj6+R7Jj+iIsstunlj+07tab+NwEeiDOI
 amlsHmXjmNf1MAZl7gdBl94TpeXtOXHhLIlLKkgT/Dq+j3UvNDfH9rBNln7RpPwBLiU5
 Oklg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=PCRJp91/82MIer7BGmfwt2GKdylAg2x5Gxk5MeSJA78=;
 b=rZCIgO+61K3q5I9DYAP5HrJB7WKUHXXiFdOvM8563X+gbmO7yM8kpBuDLmkLCNYRyb
 u83VuUCitGX4yByydUxi2wcVPVfFl6EEGKXBFz5nJRhHLF/wpD8ev7OnQ9sEpSD8DJMy
 Xg/2YZ5upfbt9PifSWFHKhaR44jvKCvJ/c5FEXeWeWLerMfhjuiP/7vmnGnf+x6KVTTp
 6l11729RXjbXBtaNOtsM5lzEXCRzgeOnwGavvv4exlcaNoRK/QYPzMETMI3+6J39PPg8
 myLzKkVAsiUCUebPQS348fC6UhIbxyxU96d5SZBzwvGr4JzHIHcbptfT/UUYxGxsHoKz
 X0SA==
X-Gm-Message-State: AOAM532ghtpk6q4KfQZONli/qFEJnXRBKMy0Ua5EGGBvhNIwOnBBc3Q6
 a4wb/DQYexjqRzz45XmDZlc02zLTjSwV8w==
X-Google-Smtp-Source: ABdhPJwgqNLGy3G4kA2qMjuDmEfZ5jUgJ9Zn9b3TaNLMbOixzf8zLW3HI6CuhjtCYkEAnJi3PUqQiw==
X-Received: by 2002:a37:5002:: with SMTP id e2mr19533167qkb.453.1604411112117; 
 Tue, 03 Nov 2020 05:45:12 -0800 (PST)
Received: from zhuyifei1999-ThinkPad-T480.gw.illinois.edu
 ([2620:0:e00:400f::31])
 by smtp.gmail.com with ESMTPSA id a206sm7356568qkb.64.2020.11.03.05.45.10
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 03 Nov 2020 05:45:11 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 3/8] powerpc: Enable seccomp architecture tracking
Date: Tue,  3 Nov 2020 07:42:59 -0600
Message-Id: <4ec2970fcc819eb4d5dac2bd35233ccdadfda845.1604410035.git.yifeifz2@illinois.edu>
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
for powerpc.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/powerpc/include/asm/seccomp.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/powerpc/include/asm/seccomp.h b/arch/powerpc/include/asm/seccomp.h
index 51209f6071c5..3efcc83e9cc6 100644
--- a/arch/powerpc/include/asm/seccomp.h
+++ b/arch/powerpc/include/asm/seccomp.h
@@ -8,4 +8,25 @@
 
 #include <asm-generic/seccomp.h>
 
+#ifdef __LITTLE_ENDIAN__
+#define __SECCOMP_ARCH_LE_BIT		__AUDIT_ARCH_LE
+#else
+#define __SECCOMP_ARCH_LE_BIT		0
+#endif
+
+#ifdef CONFIG_PPC64
+# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC64 | __SECCOMP_ARCH_LE)
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"ppc64"
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
+#  define SECCOMP_ARCH_COMPAT_NR	NR_syscalls
+#  define SECCOMP_ARCH_COMPAT_NAME	"powerpc"
+# endif
+#else /* !CONFIG_PPC64 */
+# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"powerpc"
+#endif
+
 #endif	/* _ASM_POWERPC_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
