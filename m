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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F284C5517A
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A44C6206D9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vNGoRE4T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A44C6206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 521568756A;
	Wed, 11 Nov 2020 13:34:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Hpl8r9FQ8lO2; Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id E18B787370;
	Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CFCBBC0889;
	Wed, 11 Nov 2020 13:34:40 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ACA31C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 974798688B
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZWYSeoP012Yj
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:38 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com
 [209.85.160.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 1BE408688A
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:38 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id 3so1249149qtx.3
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=p4ug0/ujexdr5eX2KHZwXV+5OEEE0LQ6CHuZfwOYci4=;
 b=vNGoRE4T2vueWtMyfIqsMJnHQf5sexlSfNm5+JYWvZrbhr28FRAtAv3lFmTY0+4W0Y
 WcYZoYHknNJQqlmA5lKA2IjQ5N2wYEjtpuzYl7OO06EsiIGv6XJZ3Kb9UjRl3/b7/1X8
 XfCjrkryG0QaqerFaC1fcQ9Tr2HyAB4KKtxuVtQp0xutUOI57AMaDr4CA2MgmoE4mjCv
 KB12O8KYoI95e70wD3aaXcRNbfK6zccMr68ebqQN7E8uk7S2TR1coNLaubqwUvBts/Lv
 zorqhisqngJ2ZuCEG1/njxhxTc7yrzx1m99VyQR+bb/RgHndyJV5i+iGi1vdeZUV7FdW
 piDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=p4ug0/ujexdr5eX2KHZwXV+5OEEE0LQ6CHuZfwOYci4=;
 b=nANs+V+I3+RSeUGxqC3VZtOEvYMtpRYGO6WFvIlDam9n/bW9AeudX9tCQBR+gWCT43
 6k0WbST73vAMvkuRpJrLt3UvJKpWnS0g6656dyxSJmUc7tzbj2SHEEg8TtRl/GwOLGtv
 ajurCPQ8QjXxFkideWsTUcLgXgEXJSDXo9secragic4A7WnkBoja7kCkwycSc6rYpzVe
 LKqD+2VKN3BgL7Z0DOfA8lh97ATTyfJN4PFmHV5fPbWRBujVkZpSsxZw9RjXTjJK57qA
 xfT5k6BJ+8CrFO4FLFISEGswxiMkJG6IGivwahsGR8Tn+yYJZfhha5R4cX25x3DFfMWm
 ++2A==
X-Gm-Message-State: AOAM531gXAg8tOJZv32j7jltWcQHhJ1+iLKUZp5cWXCV1m4rRj9X4pns
 Voc2jSYWIAF6MmQXI77WN5SeiGysWzqDpg==
X-Google-Smtp-Source: ABdhPJyVXjxkJWplKVPB4NFyM0YLYj5IP428vFSUkWNwwyzA8cf7e/mXCgVyvFukKTHkEaORyR7aHQ==
X-Received: by 2002:aed:39c2:: with SMTP id m60mr12461442qte.206.1605101676823; 
 Wed, 11 Nov 2020 05:34:36 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.35
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:36 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 3/8] powerpc: Enable seccomp architecture tracking
Date: Wed, 11 Nov 2020 07:33:49 -0600
Message-Id: <0b64925362671cdaa26d01bfe50b3ba5e164adfd.1605101222.git.yifeifz2@illinois.edu>
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
for powerpc.

__LITTLE_ENDIAN__ is used here instead of CONFIG_CPU_LITTLE_ENDIAN
to keep it consistent with asm/syscall.h.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/powerpc/include/asm/seccomp.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/powerpc/include/asm/seccomp.h b/arch/powerpc/include/asm/seccomp.h
index 51209f6071c5..ac2033f134f0 100644
--- a/arch/powerpc/include/asm/seccomp.h
+++ b/arch/powerpc/include/asm/seccomp.h
@@ -8,4 +8,27 @@
 
 #include <asm-generic/seccomp.h>
 
+#ifdef __LITTLE_ENDIAN__
+#define __SECCOMP_ARCH_LE		__AUDIT_ARCH_LE
+#define __SECCOMP_ARCH_LE_NAME		"le"
+#else
+#define __SECCOMP_ARCH_LE		0
+#define __SECCOMP_ARCH_LE_NAME
+#endif
+
+#ifdef CONFIG_PPC64
+# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC64 | __SECCOMP_ARCH_LE)
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"ppc64" __SECCOMP_ARCH_LE_NAME
+# ifdef CONFIG_COMPAT
+#  define SECCOMP_ARCH_COMPAT		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
+#  define SECCOMP_ARCH_COMPAT_NR	NR_syscalls
+#  define SECCOMP_ARCH_COMPAT_NAME	"ppc" __SECCOMP_ARCH_LE_NAME
+# endif
+#else /* !CONFIG_PPC64 */
+# define SECCOMP_ARCH_NATIVE		(AUDIT_ARCH_PPC | __SECCOMP_ARCH_LE)
+# define SECCOMP_ARCH_NATIVE_NR		NR_syscalls
+# define SECCOMP_ARCH_NATIVE_NAME	"ppc" __SECCOMP_ARCH_LE_NAME
+#endif
+
 #endif	/* _ASM_POWERPC_SECCOMP_H */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
