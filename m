Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1807BC433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:15:41 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A729322258
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:15:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OvglK0ql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A729322258
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 46109877C3;
	Fri,  9 Oct 2020 17:15:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PdjdidAxroLe; Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A60C4877C2;
	Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9F6DAC07FF;
	Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 54CB5C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 415988715C
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 19m3EcI1b0fK
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:37 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com
 [209.85.166.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 2C57387160
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:37 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id y20so6657673iod.5
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 10:15:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=6QWwJmFq8+B51i1Dnz1FEveL5hiUIq3knnDImjqdYNQ=;
 b=OvglK0ql2T5Rj2i89d2RG31J78gpJ11Kt+B8r5vsiTrs+HEDZgIUJGR2hEDVJ9czqq
 AsrD9LLA31F/wV30sQ22To8RML0HHtbcU3W/qrggGVSqI7sjxvzkJfgkwNoKUftieHZT
 e7onGJZm3lTHaEtUNcjUePx0wrarPZMx/aTfNeS/Rg/VzUJH++9s6FSuySVjLYGEz71P
 jtDJ+s2JYvwqsBhW0FY46isRatRVLjmQi4ZokfWKagzVeNSkAmREQy1UwutWhkvZPhxU
 2NIq2fE4uCBQxYJL0d0sJkT1n08/0tmul2VeF92SVDtXGybyRgk7mcYeeldfQy8VfdP8
 aYlQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=6QWwJmFq8+B51i1Dnz1FEveL5hiUIq3knnDImjqdYNQ=;
 b=HX7bu9cibhhhJbnASHQHrgrDdfzYkkHTN6RQh+Npz9ghV6jDnlzVFDbHVvWQKTXtpy
 0TAXTPrGZPUUrOoKR1GDtdwbDHdk9AH+jMQKvhXtnZny20YJiSzxo/CkF3jOzScFunB+
 DpDQYZdK+pEfOOQboo5tkC0GXgEr6MqXo8LF1antxGZ1UPoxRsqPKRKbAlslL1oNtzE4
 Bxx+xz80YlwGCyRYKI6A33jDcRnzL40xRbYVKso7mcqxwFXQ6J1cpAkaFEZp/oRFqNXW
 26hPQUSK1VIDCW4EH6MM0L8NyIMrpBzt0WcRzD0Cwkbpa0Cvzhm54AudqEekNelKpc+U
 ih0w==
X-Gm-Message-State: AOAM530m8CTTWrw0hGHeRusOpbTkbzT6X4X1+FqsNu/86FV/yRc+oEiX
 /mbun6cutQiURLuVp/0ASJv346Gj/P26sQ==
X-Google-Smtp-Source: ABdhPJxoslx7HpNUVVcX2E2QarHbz/ANgA1kszpMKfOEp/x3H7i7qPRq/i/SzlUct3hiYaLvVG3nMw==
X-Received: by 2002:a02:c611:: with SMTP id i17mr11902592jan.28.1602263736233; 
 Fri, 09 Oct 2020 10:15:36 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id c2sm3762830iot.52.2020.10.09.10.15.35
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 09 Oct 2020 10:15:35 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v4 seccomp 3/5] x86: Enable seccomp architecture tracking
Date: Fri,  9 Oct 2020 12:14:31 -0500
Message-Id: <122e3e70cf775e461ebdfadb5fbb4b6813cca3dd.1602263422.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1602263422.git.yifeifz2@illinois.edu>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
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
 arch/x86/include/asm/seccomp.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index 2bd1338de236..03365af6165d 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -16,6 +16,18 @@
 #define __NR_seccomp_sigreturn_32	__NR_ia32_sigreturn
 #endif
 
+#ifdef CONFIG_X86_64
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_X86_64
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT		AUDIT_ARCH_I386
+#  define SECCOMP_ARCH_COMPAT_NR	IA32_NR_syscalls
+# endif
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
