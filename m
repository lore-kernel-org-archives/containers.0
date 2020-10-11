Return-Path: <SRS0=u+zM=DS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01F3AC433E7
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 96EFC20757
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EqnDbMv2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96EFC20757
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2D8C4204F4;
	Sun, 11 Oct 2020 15:48:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OaR-ZrBmDsIM; Sun, 11 Oct 2020 15:48:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 1A05420113;
	Sun, 11 Oct 2020 15:48:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 01962C0893;
	Sun, 11 Oct 2020 15:48:10 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 066F3C0051
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id CE561203B8
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Bjq8DCUuFyvl
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f195.google.com (mail-il1-f195.google.com
 [209.85.166.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 2A5E620113
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
Received: by mail-il1-f195.google.com with SMTP id t12so13706355ilh.3
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 08:48:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=SiGgaoVfTiGKzLu8iQvphsAHQCnyBXcNFjoytO86qNs=;
 b=EqnDbMv2+QH/bUYXjHA4oEFiZK/SRlkK98epO2CpOCdeI35huS4KGSZHrIMOznMTkD
 FWi3vpmXZAXyc0BUsI7owhCPG2s2RNBLUbIFHiBlP88+c1FMPJxQGUzkrCiigh7o2ChL
 D3j8hXs6QJdJ9wb6VaDyAE7jnGzPgxEx70Jbm7FgUAYrx4yzY00uqs75PjUQNKcOtJCX
 H46fu2LSySIbNObwinw/JsvHKjMnd0pf725X8hPyY0ekpohIIia+uiiSOg2aZDKf/+Oi
 nq7r3NCLfyWCZ/Gej/QMixoUeWBHpFblB0xWi38uwQqamdnrO6ukjzrPaOJ3brK/204C
 6V3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=SiGgaoVfTiGKzLu8iQvphsAHQCnyBXcNFjoytO86qNs=;
 b=gq8evHEBRNa4fC+GTaNFp2JjbSoQuiD5NEfBeXSFjSWKU1MTzsoc44bYGZbfCiL8PR
 09XxVt2sUnwwyvGqD0DODZw7HEHTlFhAtEFG2w6+Mk4tQLaq4xtkezmUhvqPhTiMtxxd
 s0xh+RxCZKLIvcayE6GDkS8I5X85ANPWcyAePoKVzy4Y/WaDpUdQvG/ofNThyHpLicLN
 0qglB2ljyS8MvD40Ul9PFUsqCJqKvyRrt8ahziiKdjxMY3A9rFaWi1VtPmdPp93LdQaw
 lq6s8euAInoww0tEdxzFyL4PqkvPKMSlmhZcl0xoVREmHKrIQjZDrcn0h9amj2/xjlF5
 hj5Q==
X-Gm-Message-State: AOAM533WYQEQSaGzscU+zVnobH46FXH6tQLjx5UCnWArJbh+xPbP153v
 uWYvgtf8ZUAoKts5v0fV46r95U3TjwhDVQ==
X-Google-Smtp-Source: ABdhPJwsueePrWHqTFapaqqcMnwJ8FxqNGPbJVOHjC2fERfGsGcZc/BqHzeMuOdlOqW6gRg6DofM+g==
X-Received: by 2002:a92:6811:: with SMTP id d17mr16188550ilc.145.1602431286122; 
 Sun, 11 Oct 2020 08:48:06 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id q16sm7502881ilj.71.2020.10.11.08.48.05
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 11 Oct 2020 08:48:05 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v5 seccomp 3/5] x86: Enable seccomp architecture tracking
Date: Sun, 11 Oct 2020 10:47:44 -0500
Message-Id: <da58c3733d95c4f2115dd94225dfbe2573ba4d87.1602431034.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1602431034.git.yifeifz2@illinois.edu>
References: <cover.1602431034.git.yifeifz2@illinois.edu>
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

From: Kees Cook <keescook@chromium.org>

Provide seccomp internals with the details to calculate which syscall
table the running kernel is expecting to deal with. This allows for
efficient architecture pinning and paves the way for constant-action
bitmaps.

Signed-off-by: Kees Cook <keescook@chromium.org>
Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/x86/include/asm/seccomp.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index 2bd1338de236..b17d037c72ce 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -16,6 +16,23 @@
 #define __NR_seccomp_sigreturn_32	__NR_ia32_sigreturn
 #endif
 
+#ifdef CONFIG_X86_64
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_X86_64
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT		AUDIT_ARCH_I386
+#  define SECCOMP_ARCH_COMPAT_NR	IA32_NR_syscalls
+# endif
+/*
+ * x32 will have __X32_SYSCALL_BIT set in syscall number. We don't support
+ * caching them and they are treated as out of range syscalls, which will
+ * always pass through the BPF filter.
+ */
+#else /* !CONFIG_X86_64 */
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_I386
+# define SECCOMP_ARCH_NATIVE_NR	        NR_syscalls
+#endif
+
 #include <asm-generic/seccomp.h>
 
 #endif /* _ASM_X86_SECCOMP_H */
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
