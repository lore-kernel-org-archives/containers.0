Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92400C4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2353520BED
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="YImT8s0t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2353520BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C034027A5C;
	Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9knFbEgPOPy9; Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 56A7F233B0;
	Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3138DC0889;
	Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6E353C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 569E6844B2
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id T3J_lQzr01r8
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id B927A84489
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:27 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id d19so599928pld.0
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:29:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=dRM2RxYevz4ZLx42XYlJ4AIQPGby+e+r+LDyrwiMJmY=;
 b=YImT8s0t4ro5HLSsWUw0wPm9p8M2rMPRr1XMLfBu5tvvY24Y3b7+SScvQCxYa+mKnA
 hgoYM5/ccPMAXnlw70N83Y9+Cl38QLui9PJIpibXpOgNKL6n5KQ4soHzwx2kGWb3WXCm
 Jnq0DOeHpwfCyW/oH3OOX/dvAtuDKFlbXMpdQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=dRM2RxYevz4ZLx42XYlJ4AIQPGby+e+r+LDyrwiMJmY=;
 b=ZsV54NML1IzJ+T9pRaiCbswMdizbrAHLOAPG0l+4EHSfjZZ98B291OAL21j0D4qdSX
 X4wrtaYztFEn97LCtzrnL7W1EVJKDCVgGhHlXUirkxm3L/pEKxbAbhCEBADOxX9wpkLz
 z08P6eTtQ2CjP7UqVcDsCO1D7GLX0wfn8JhwrGI4K/YUXO4M6RYkYshR8fR+UG0hjzZQ
 kc1MRmj2Z7jlmS8HqeSFTb9T9JEYVlkAzMn/Bqz3ykyG3k5gliEGxcUZ0iPXm5HGJNT+
 nhKaYTkHvvNDZjR9+B8rbtDAazzUXAymXQdS/qXRjZ8ZvDnu7U6tugzPkYXod1NCISuv
 lnKA==
X-Gm-Message-State: AOAM530A6qQTKBCiVWCKqTJhzVte/UoS7p7b7Z7/0wTlhXPHLNOStEIr
 nMolu9EI6Se5EMBAOnZQcAMFMg==
X-Google-Smtp-Source: ABdhPJxLRLuysYMwMBl98TDjJXH+A1GJK5BYJ/9bxber4JuLQfhK8FiL18o08N5dn4Gk6n7figNXTQ==
X-Received: by 2002:a17:90a:4046:: with SMTP id
 k6mr1441778pjg.11.1600903767231; 
 Wed, 23 Sep 2020 16:29:27 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id c186sm828427pga.61.2020.09.23.16.29.26
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 16:29:26 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: [PATCH 2/6] x86: Enable seccomp architecture tracking
Date: Wed, 23 Sep 2020 16:29:19 -0700
Message-Id: <20200923232923.3142503-3-keescook@chromium.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200923232923.3142503-1-keescook@chromium.org>
References: <20200923232923.3142503-1-keescook@chromium.org>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 linux-api@vger.kernel.org, containers@lists.linux-foundation.org,
 bpf@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 linux-kernel@vger.kernel.org
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

Provide seccomp internals with the details to calculate which syscall
table the running kernel is expecting to deal with. This allows for
efficient architecture pinning and paves the way for constant-action
bitmaps.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/x86/include/asm/seccomp.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index 2bd1338de236..38181e20e1d3 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -16,6 +16,20 @@
 #define __NR_seccomp_sigreturn_32	__NR_ia32_sigreturn
 #endif
 
+#ifdef CONFIG_X86_64
+# define SECCOMP_ARCH					AUDIT_ARCH_X86_64
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT				AUDIT_ARCH_I386
+# endif
+# ifdef CONFIG_X86_X32_ABI
+#  define SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH	AUDIT_ARCH_X86_64
+#  define SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK	__X32_SYSCALL_BIT
+#  define SECCOMP_MULTIPLEXED_SYSCALL_TABLE_SHIFT	29
+#endif
+#else /* !CONFIG_X86_64 */
+# define SECCOMP_ARCH					AUDIT_ARCH_I386
+#endif
+
 #include <asm-generic/seccomp.h>
 
 #endif /* _ASM_X86_SECCOMP_H */
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
