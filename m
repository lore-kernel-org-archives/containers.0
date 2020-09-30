Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5C4AC4727C
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:30 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 335912071E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="faLp8XRW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 335912071E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id AFAA185B8A;
	Wed, 30 Sep 2020 15:20:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a6qzpmLzysIF; Wed, 30 Sep 2020 15:20:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 25CC685F6D;
	Wed, 30 Sep 2020 15:20:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1321FC0890;
	Wed, 30 Sep 2020 15:20:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E1601C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id DD8F1860CE
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WqbtQ1WQrfUv
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:26 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com
 [209.85.166.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 1114285B7C
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:26 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id q4so2202332iop.5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 08:20:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=Mv4ii8zAP+OnnhUrvn84xAFhnizL7MtbdUx+GH7PQaM=;
 b=faLp8XRWWZBJTGcWmfT4Onxq+2qJR2ZNvRXCr5h8BPn4Uc5zUe5sKpa3bU2zZx/UoH
 oPN7V7n4HUbMwcESTej9CA3ep+EYCoXa2JynNjku8sN3Cv/DmbQWmdkkFnA5OLd9YJNp
 +pZnXwWT10vJsEK/RknN+QI7HU13OGEyKwR05Y5/7TLZpW7+f4EfzY5YQhGerKNUOCwq
 6h8vlrYz7QRAwC68dMtgihsPR8nnakqyn0u/6V5iLnsx0LNbddmPxxRuBnykd+7Y1K6Q
 cJ65cIAW1Q4d+xOQUqKCyCQVix4it5tExeZvGIsDatvLDDuKJ8MaA+ndRb8QVLO1yuCx
 NaMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=Mv4ii8zAP+OnnhUrvn84xAFhnizL7MtbdUx+GH7PQaM=;
 b=HIoqvRM6wDYVZmnhTJXEgbqD59Nbg9vaYWs+txA1j6Y7/UtmG7YdHtxddoUZM/Xkt/
 uF+1HJu3ReKk2tURaHNhPpCLg9EEtKeHllDonuZrYlXmQtZZB9RXSz/6iCk0J5JFsF7O
 3O4jXiT/V74lQRVtMpq4VahLo3vVh7VjnmJWw2g58rewY8BeKrfWCYjun7PbsLks00QS
 FsEut+PVpuldPSjw2J2/xpw17wsdDbMrb44LmYaSj4/6vxmQaYdT+MCZXDL/+9WQJjeF
 ra3T6m6FpJnkcNjiY8sz+0Vpqg+y7dC/Ws44xk2rcgKjvEBYlCaSW0wgo7QhQeyuRM+R
 DSjQ==
X-Gm-Message-State: AOAM531D2FwK4cRVkpOHo1VrbaWSzJINQpQtpj+ycP9BtDoZCZvnzMui
 AlIVibSxHG4fGjrpDQb7DZRWMQsNmk6uqA==
X-Google-Smtp-Source: ABdhPJwjIxz2zEuBhqj0fQKlXjCbvbF3OmJHQpSM1hO02ApFZSa4yKPPp5z7QVD9U1wWVPWWnSoEhA==
X-Received: by 2002:a5d:9693:: with SMTP id m19mr2082274ion.161.1601479224812; 
 Wed, 30 Sep 2020 08:20:24 -0700 (PDT)
Received: from localhost.localdomain (ip-99-203-15-156.pools.cgn.spcsdns.net.
 [99.203.15.156])
 by smtp.gmail.com with ESMTPSA id t10sm770788iog.49.2020.09.30.08.20.21
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 08:20:24 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v3 seccomp 1/5] x86: Enable seccomp architecture tracking
Date: Wed, 30 Sep 2020 10:19:12 -0500
Message-Id: <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1601478774.git.yifeifz2@illinois.edu>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
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
[YiFei: Removed x32, added macro for nr_syscalls]
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/x86/include/asm/seccomp.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
index 2bd1338de236..7b3a58271656 100644
--- a/arch/x86/include/asm/seccomp.h
+++ b/arch/x86/include/asm/seccomp.h
@@ -16,6 +16,18 @@
 #define __NR_seccomp_sigreturn_32	__NR_ia32_sigreturn
 #endif
 
+#ifdef CONFIG_X86_64
+# define SECCOMP_ARCH_DEFAULT			AUDIT_ARCH_X86_64
+# define SECCOMP_ARCH_DEFAULT_NR		NR_syscalls
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT			AUDIT_ARCH_I386
+#  define SECCOMP_ARCH_COMPAT_NR		IA32_NR_syscalls
+# endif
+#else /* !CONFIG_X86_64 */
+# define SECCOMP_ARCH_DEFAULT		AUDIT_ARCH_I386
+# define SECCOMP_ARCH_DEFAULT_NR	NR_syscalls
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
