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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E75C2D0A3
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:23 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 75E172224E
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:45:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PMy31dQJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75E172224E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1A4A52052C;
	Tue,  3 Nov 2020 13:45:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id R0DD-oBNp6V7; Tue,  3 Nov 2020 13:45:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 20AEA2043C;
	Tue,  3 Nov 2020 13:45:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0D487C088B;
	Tue,  3 Nov 2020 13:45:21 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 214EDC088B
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id F3DD72052E
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vXGCObugd3hz
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:18 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com
 [209.85.160.194])
 by silver.osuosl.org (Postfix) with ESMTPS id 997622051F
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:45:18 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id p12so4238029qtp.7
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 05:45:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=9/hEAP0td3DKDEonOQx/BrDGR67nDcwn+HdeFH8wdFU=;
 b=PMy31dQJueagbOReuh4TyHKDHnWAkQvYrpAxEIErX4xPuMN4MlNB2tU7IkrAnlx5qR
 uhiVg0r41UxTv/gr4jsg2Wl8FCoeHTXIjjT8/6kSbvOBLPV4TYfJCrk8J0g2rFJRrlKD
 1hx2REJtkovGnmyDSF4OhzIchxZlhVI33gOeYruCrarfFMdqwMbuze+ne7D3usBg1+Vq
 DnVMU0VjWHDphquu2ZmwzzqKtLL7eO8+3YSpHLjN+/oLDv2OFzem5txt9rfYq8LN1OI+
 2+w6DzMI4hNFhProTsfpRsIxSVaEXoTrzgUyJ2J91ehNlbAFEuRmMAY+8h22ZlecP47B
 /smQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=9/hEAP0td3DKDEonOQx/BrDGR67nDcwn+HdeFH8wdFU=;
 b=qgVEvk00gEcIU1IMaskocT+YVvfJIpHR+zSMtVqzjt2PqjERqAoZ58MtEteHfrTaCQ
 dnsEAv10Y5daRMyLTAH34wXM06yoRBPwBco2ZGxzJsIJE8dSK1ErhXR5qqk4Oe1Ip5PV
 IDvdCCkQJqduj1zNq+ws/XJ47RyqAlpk00fSuTiWx5Q5NLM3+DA63ru2EPoZCfKB+VFZ
 vSGfVaSpDYxV44hrNiN2/etev3DOC+psQgeql30+927afAdrWSBQQ4I9RfxD1k5L2z2d
 2c/wACmcPXnVl3w4fIHHjbiHCI9r4paARV/sLklPzFQxRvrF+77y6jgYn51XqiAzhhTR
 /zCQ==
X-Gm-Message-State: AOAM530QqqezoquhqVUQ4LlI2Y7JoKTyCd0bPmctyQJuVDiwZTbLWnzn
 4lUiQOeaYanlz0RtG/BxAXyZpgutJEi2UA==
X-Google-Smtp-Source: ABdhPJxZpuM+FL2rdeo54BZFwmZgnUAh5zGzhGJrI7NUoaE9OPGoZYZ+/yTeLM9bmqKuOcXR8gpKgw==
X-Received: by 2002:aed:2064:: with SMTP id 91mr19450606qta.383.1604411117345; 
 Tue, 03 Nov 2020 05:45:17 -0800 (PST)
Received: from zhuyifei1999-ThinkPad-T480.gw.illinois.edu
 ([2620:0:e00:400f::31])
 by smtp.gmail.com with ESMTPSA id a206sm7356568qkb.64.2020.11.03.05.45.15
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 03 Nov 2020 05:45:16 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 6/8] sh: Enable seccomp architecture tracking
Date: Tue,  3 Nov 2020 07:43:02 -0600
Message-Id: <46d7f8d02bdaadf364a59db2d60f43466227b3af.1604410035.git.yifeifz2@illinois.edu>
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
for sh.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/sh/include/asm/seccomp.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/sh/include/asm/seccomp.h b/arch/sh/include/asm/seccomp.h
index 54111e4d32b8..b8d169292a34 100644
--- a/arch/sh/include/asm/seccomp.h
+++ b/arch/sh/include/asm/seccomp.h
@@ -8,4 +8,14 @@
 #define __NR_seccomp_exit __NR_exit
 #define __NR_seccomp_sigreturn __NR_rt_sigreturn
 
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+#define __SECCOMP_ARCH_LE_BIT		__AUDIT_ARCH_LE
+#else
+#define __SECCOMP_ARCH_LE_BIT		0
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
