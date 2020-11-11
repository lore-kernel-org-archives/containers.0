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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78128C56201
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E53DD2074B
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CtuNdkss"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53DD2074B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A7AF587584;
	Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id S+qd0qIgMyi3; Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 40C398757D;
	Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2563AC1AD4;
	Wed, 11 Nov 2020 13:34:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4194DC016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 313612046D
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Nmj5S4c6RvaC
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:41 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com
 [209.85.222.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 5988E204D7
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:41 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id d28so1570299qka.11
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=+eMXBOnvKPM7N/Eu0cs4UA1I6FeurfdgB6uFLVTMPX8=;
 b=CtuNdkss3y7rgKc1l9KsIQZTv0LgZAhMRYi/6z6qZmeZkTtZ4x7E48r/LeELYZ06IN
 8cgqYZ8dHlw0uxtVdsPuGe5k/uNahk9dBk2utYsfhVEV4Ba/sogSqNiIxMOka14XZD8a
 eupUAgtHJBLzSWs9IfisbVC1mdakqgfudFjJHeYdfmpXX0W03tbjgHa1X2SdS54+cwbz
 4hcZkRNxXc8xWoaxyCLZaNV6QnzDrrzHDB6WZ3omhkvvhakq0V/TBs/W/M2pg4I58bEk
 U0Idcw73pn5TTYmrEG4CqfKVjhniq9pyecl8f2TP5P/XCIVnlIMOYfN29gQ3XF6HZQop
 jcCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=+eMXBOnvKPM7N/Eu0cs4UA1I6FeurfdgB6uFLVTMPX8=;
 b=TUibPscMLw9YmqFAoQ/8fJ5mdgvdvIzVIO7a+G2CJWIFbJEXnmVZVdY9/tbCvtVYcw
 8IPS4xMpIOrmn3M5bWxr3DM6vJ36nXyoBjB0d40lb9ewB4g5CzXUw1hef9ilRUX1Ojxg
 o+Cobhk6RldXdHAoTocy2vA651TUnrSfueJHDl/ArgyU+rErw9+9RbwLTxJhL+GPJd1S
 CZquTmNRewXuB1ElW+3JCIX58G9dA7/5brt5X+tC89nZlIeKMaLCHd/E1R6LlSMjIaDQ
 qOZn+kfwHZ5El5go4uTv/5kIxBODoHv8waLIUtxpNf0oa3yoXBGNqfkmWZoixlC2Qoq9
 a0RA==
X-Gm-Message-State: AOAM531VRZNkTuc9W4y9yp0lu29dVn83yNtNh+VKh3XYxvW4SxUwixJi
 jeQtpTJxbNdKpnFi2USWafH3HsbqAU7xCw==
X-Google-Smtp-Source: ABdhPJziT3nG/TSXJ4p+Pm6vLQUb4KIz+diKiufrVwDSoSwTeA58/VG9OWAb2+vs2wrY9VS5+FBB5A==
X-Received: by 2002:a37:7fc7:: with SMTP id
 a190mr24750394qkd.337.1605101680151; 
 Wed, 11 Nov 2020 05:34:40 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.38
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:39 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 5/8] s390: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:51 -0600
Message-Id: <a381b10aa2c5b1e583642f3cd46ced842d9d4ce5.1605101222.git.yifeifz2@illinois.edu>
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
