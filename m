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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16F59C388F9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7E8CF206D9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kqmci847"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E8CF206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id BD7A1204D7;
	Wed, 11 Nov 2020 13:34:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id c85EXpF7LF7P; Wed, 11 Nov 2020 13:34:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 08A56204AA;
	Wed, 11 Nov 2020 13:34:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E6D00C0889;
	Wed, 11 Nov 2020 13:34:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 618E7C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 44D918686D
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Y81TI5HstKa1
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qv1-f67.google.com (mail-qv1-f67.google.com
 [209.85.219.67])
 by whitealder.osuosl.org (Postfix) with ESMTPS id AA10D86885
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
Received: by mail-qv1-f67.google.com with SMTP id z17so838448qvy.11
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=do2IkGTsgJZMce9dLCi5y9V7vjNX63EvX8bAUDpEGLM=;
 b=kqmci8479r1GmpSX/CsPK24jcw4ackZR09/fqBvzcYwOBOneuWx5PFapDrNR/y91zk
 ExAMU598dyHT/RcJ0vEsvLy4Ops+sFNh3zgqOE4JArPSyF7W9sja/hApRc2rC1Nwm2hJ
 u50FMSKsKEcagX5U7XeUcBUJxC1PhPsCIK1LzOF+1qxQDwvzDgWYavL+OHfPE2kcPPFp
 EApyeIYNOUYqsqaYXaV0Ji65m4GhaGRycYlamUWs8R5m/Eh5ESQ0qNfQZrDakTPeWfnR
 dkjvod65hl/fav16KIifE1cRgTcdlFaQ87PvVYqF5inQSFpWoASygEZjooid8wnIuGLL
 DptQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=do2IkGTsgJZMce9dLCi5y9V7vjNX63EvX8bAUDpEGLM=;
 b=bbrTCA/rCvvIUN2jSw5fZjmtJsfLAow6wN9QEqD29vPzxrinyyfN119A682iB7LZIm
 jGUwRhXuCL10KRuO2I210r4+CbtiSSNTpcvfJs2GHx9Uaueqc1NHGGHE3ShawhfWu/s0
 VOjCJpZe2qAdEAcbafy+Iclh56hXnl3qku2FLPpb/6ixPFmARFqyxnSxS8FjVs8d+HdW
 9/7h70TM7XGSb4AnPXmm4AwlUUTD1Wadl7TsaQtqkY+IjicHHEpcELvl7fHI2LXN4Ep5
 eRdT2hwqRMsWJxSAhyE+uXbhJVosiyWZJ6q3jVDndfDxoO7zt0s4gzof6o+YWexLEpiC
 gvgg==
X-Gm-Message-State: AOAM532byaC6R3RKX3xDE5EIwfGHLoQOY2GLpm/JwZ/pPyCXz4Nqmlnl
 uuqX/nf9Iiu7ite3ux2jB4CFrGPzJGcpiQ==
X-Google-Smtp-Source: ABdhPJzFsUI0zV9/mJU71uSGXIEeuyYH9ZXGj+0WaVMtZXX0iy4+DwFsWuBQL0cgOtuNbH4AHKgOyQ==
X-Received: by 2002:a0c:e443:: with SMTP id d3mr13987966qvm.18.1605101678476; 
 Wed, 11 Nov 2020 05:34:38 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.37
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:37 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 4/8] riscv: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:50 -0600
Message-Id: <58ef925d00505cbb77478fa6bd2b48ab2d902460.1605101222.git.yifeifz2@illinois.edu>
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
for riscv.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/riscv/include/asm/seccomp.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/riscv/include/asm/seccomp.h b/arch/riscv/include/asm/seccomp.h
index bf7744ee3b3d..c7ee6a3507be 100644
--- a/arch/riscv/include/asm/seccomp.h
+++ b/arch/riscv/include/asm/seccomp.h
@@ -7,4 +7,14 @@
 
 #include <asm-generic/seccomp.h>
 
+#ifdef CONFIG_64BIT
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_RISCV64
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"riscv64"
+#else /* !CONFIG_64BIT */
+# define SECCOMP_ARCH_NATIVE		AUDIT_ARCH_RISCV32
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"riscv32"
+#endif
+
 #endif /* _ASM_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
