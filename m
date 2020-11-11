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
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9061C388F9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:46 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5A74A2074B
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AiHrWEt1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A74A2074B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id AFE938638E;
	Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qaUvGVaW1xY5; Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 58D0386226;
	Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4921EC0889;
	Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F3BB6C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D2A918757D
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id qCzarZcQMC1e
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:43 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com
 [209.85.160.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3824087570
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:43 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id i12so1261451qtj.0
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=Z8BEo0x7DBxygVu3ezyut+Q+/5lHQFyLMFsea6yH4dY=;
 b=AiHrWEt19R14SjvDJPKLr7v7i72FmAs7tKIcKGMSWFQwQ/DIoBrkASCkncBIALbImW
 ovXjCz0vPL0IwyG05D0ScobV3buaYwTntzRWG4DvErPgobGS3lP6aF57Y5z/ROppbM15
 U5alV4hGDTuqamCbUCRSnEElgLlyHQqyfApA9IFdiByMiEgJ9T5aChZZ8FuOLffq7taE
 8RCryXNGD6+QzxN4QWCFwCmheQXdMAr5LaXXLZuZJoit1BPXhkYBBltSg8ODItIgxHp4
 ULkURkvuGrMOziExOLhaMa/N/5bMiNtXHKjvWx5fTW5xKcw7pTxjO4xz/fvpWPD8dS5Q
 jWQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=Z8BEo0x7DBxygVu3ezyut+Q+/5lHQFyLMFsea6yH4dY=;
 b=h2n84F5gT/7MnYeKNursgkTYgSWnZdLIGi4nFpsjKOYF1p41Wd48+c6Om0fx6AToYO
 IgQH/3DoovF8zzRKAncCbEp244ez7AWFbqYqUDE/r810IBu0zVfWinkLcdc/M4k62KKN
 aourx/kcrgJqh+Jd0iSHV6sMBbNY5cXYiqMvpTCcKEk1qVpqaoMoyPbTw6AmWQZ7JGHl
 1g9UOexcjfMY4CfIaIUjIKKm9wNwSVjT3g5v59U0kLyo9p3dIcRsrvhztzkPzeAW58tq
 3KRoB6AjIQpxWVzF5WgaMptEsQBDUNeAHe2UduMsMPRet2HqKSbOBUcRUB4FAQo14axN
 CeWA==
X-Gm-Message-State: AOAM530eewDg1fntJSmyqTtdxKIRF7fbPx+bDWwn9fvjF4GxlCzoMH+o
 XtI1ysSogMPwxHz1T0emjqDbGnxVz94QnA==
X-Google-Smtp-Source: ABdhPJyZWAhNIXxg3LfT4oElO/X43US70dnQmIy4NoyGeM0Dg949Sb1UtyuDuo3lMLZdX0WTBziFrQ==
X-Received: by 2002:aed:2744:: with SMTP id n62mr24170273qtd.67.1605101681720; 
 Wed, 11 Nov 2020 05:34:41 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:41 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 6/8] sh: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:52 -0600
Message-Id: <61ae084cd4783b9b50860d9dedb4a348cf1b7b6f.1605101222.git.yifeifz2@illinois.edu>
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
for sh.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/sh/include/asm/seccomp.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/sh/include/asm/seccomp.h b/arch/sh/include/asm/seccomp.h
index 54111e4d32b8..d4578395fd66 100644
--- a/arch/sh/include/asm/seccomp.h
+++ b/arch/sh/include/asm/seccomp.h
@@ -8,4 +8,14 @@
 #define __NR_seccomp_exit __NR_exit
 #define __NR_seccomp_sigreturn __NR_rt_sigreturn
 
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+#define __SECCOMP_ARCH_LE		__AUDIT_ARCH_LE
+#else
+#define __SECCOMP_ARCH_LE		0
+#endif
+
+#define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_SH | __SECCOMP_ARCH_LE)
+#define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+#define SECCOMP_ARCH_NATIVE_NAME	"sh"
+
 #endif /* __ASM_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
