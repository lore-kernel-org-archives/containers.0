Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2BB8C2D0A8
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4AED820BED
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CK/yLRWK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AED820BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E7DF1844E4;
	Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xSescZb8iIda; Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5CCF0844AA;
	Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5178CC0889;
	Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D12C3C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id C0E9D84489
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id L8DVApNFioqn
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com
 [209.85.216.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 29226844AA
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:28 +0000 (UTC)
Received: by mail-pj1-f68.google.com with SMTP id u3so540018pjr.3
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:29:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=Sc3ebczz8rmNH2w8JraN/35ap0kTxnvAQhEv63luYfE=;
 b=CK/yLRWK/GnklstIhHZjn/0pYYnnQjH99MYWDkAXuYI9+NOqvUU0ANa6rBD+NsWFEz
 c7QexSPQWD74DI1zL2hhf0A48GuOV9gJ6xUM59jCUCjfUWNr9xxPmzGVjGXG9Ux5vdnC
 z4nOhOyvGdEr88w/pVmbgsicGvkUkxDZlRCWA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=Sc3ebczz8rmNH2w8JraN/35ap0kTxnvAQhEv63luYfE=;
 b=Yq2i6Rm7M9pCIil0q6W++8DwopVmcPvd0/EwGPXPwkLrBHgQfMbc0dXHKbvZp08+/w
 1CcJS9pF6cQIxAw40kXg2GBJsIDCHQdwmOEuifx14Xg+QaoiMPGICHgFjf40QzMoXNBJ
 wp0cNoZtZVWCpsnWwQbjiBsN8zjFqqHyu86OpcnDw9heB230udlAUPHK/tohewVRdbTF
 q5AWBh6SxVVJJdCJGgN7TyHqimz3x+cuZ6h+Ra3LuOy5pSfgYeAjRq+Mz/e/qt4fGsNf
 UM9+ytv6QloebJg7I1zrtSLkYta20SK0dVRLQvbwQRKhdFzKoTjRz+dA84c3/ga6zNWw
 KmAA==
X-Gm-Message-State: AOAM533v/55gHdybfU2ZlbETtACkljWzlN0qKlj3cVdKb3KDqMnDf7T4
 akhwo0G9SJdYXc/EPyZl3a6cLQ==
X-Google-Smtp-Source: ABdhPJyZ7o0DnR5kI8957XIopuSRrBSpPx9KS7ET42fO0J8UuNz+QkuV9tPkvD3v4Fah2MtxvVfhKg==
X-Received: by 2002:a17:90a:db05:: with SMTP id
 g5mr1549879pjv.22.1600903767757; 
 Wed, 23 Sep 2020 16:29:27 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id w185sm724485pfc.36.2020.09.23.16.29.26
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 16:29:26 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: [PATCH 4/6] seccomp: Emulate basic filters for constant action results
Date: Wed, 23 Sep 2020 16:29:21 -0700
Message-Id: <20200923232923.3142503-5-keescook@chromium.org>
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

This emulates absolutely the most basic seccomp filters to figure out
if they will always give the same results for a given arch/nr combo.

Nearly all seccomp filters are built from the following ops:

BPF_LD  | BPF_W    | BPF_ABS
BPF_JMP | BPF_JEQ  | BPF_K
BPF_JMP | BPF_JGE  | BPF_K
BPF_JMP | BPF_JGT  | BPF_K
BPF_JMP | BPF_JSET | BPF_K
BPF_JMP | BPF_JA
BPF_RET | BPF_K

These are now emulated to check for accesses beyond seccomp_data::arch
or unknown instructions.

Not yet implemented are:

BPF_ALU | BPF_AND (generated by libseccomp and Chrome)

Suggested-by: Jann Horn <jannh@google.com>
Link: https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 kernel/seccomp.c  | 82 ++++++++++++++++++++++++++++++++++++++++++++---
 net/core/filter.c |  3 +-
 2 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 111a238bc532..9921f6f39d12 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -610,7 +610,12 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
-	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
+	const bool save_orig =
+#if defined(CONFIG_CHECKPOINT_RESTORE) || defined(SECCOMP_ARCH)
+		true;
+#else
+		false;
+#endif
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -690,11 +695,78 @@ static inline bool sd_touched(pte_t *ptep)
  * This approach could also be used to test for access to sd->arch too,
  * if we wanted to warn about compat-unsafe filters.
  */
-static inline bool seccomp_filter_action_is_constant(struct bpf_prog *prog,
-						     struct seccomp_data *sd,
-						     u32 *action)
+static bool seccomp_filter_action_is_constant(struct bpf_prog *prog,
+					      struct seccomp_data *sd,
+					      u32 *action)
 {
-	/* No evaluation implementation yet. */
+	struct sock_fprog_kern *fprog = prog->orig_prog;
+	unsigned int insns;
+	unsigned int reg_value = 0;
+	unsigned int pc;
+	bool op_res;
+
+	if (WARN_ON_ONCE(!fprog))
+		return false;
+
+	insns = bpf_classic_proglen(fprog);
+	for (pc = 0; pc < insns; pc++) {
+		struct sock_filter *insn = &fprog->filter[pc];
+		u16 code = insn->code;
+		u32 k = insn->k;
+
+		switch (code) {
+		case BPF_LD | BPF_W | BPF_ABS:
+			switch (k) {
+			case offsetof(struct seccomp_data, nr):
+				reg_value = sd->nr;
+				break;
+			case offsetof(struct seccomp_data, arch):
+				reg_value = sd->arch;
+				break;
+			default:
+				/* can't optimize (non-constant value load) */
+				return false;
+			}
+			break;
+		case BPF_RET | BPF_K:
+			*action = insn->k;
+			/* success: reached return with constant values only */
+			return true;
+		case BPF_JMP | BPF_JA:
+			pc += insn->k;
+			break;
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JSET | BPF_K:
+			switch (BPF_OP(code)) {
+			case BPF_JEQ:
+				op_res = reg_value == k;
+				break;
+			case BPF_JGE:
+				op_res = reg_value >= k;
+				break;
+			case BPF_JGT:
+				op_res = reg_value > k;
+				break;
+			case BPF_JSET:
+				op_res = !!(reg_value & k);
+				break;
+			default:
+				/* can't optimize (unknown jump) */
+				return false;
+			}
+
+			pc += op_res ? insn->jt : insn->jf;
+			break;
+		default:
+			/* can't optimize (unknown insn) */
+			return false;
+		}
+	}
+
+	/* ran off the end of the filter?! */
+	WARN_ON(1);
 	return false;
 }
 
diff --git a/net/core/filter.c b/net/core/filter.c
index b2df52086445..cb1bdb0bfe87 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1145,7 +1145,7 @@ static int bpf_prog_store_orig_filter(struct bpf_prog *fp,
 	return 0;
 }
 
-static void bpf_release_orig_filter(struct bpf_prog *fp)
+void bpf_release_orig_filter(struct bpf_prog *fp)
 {
 	struct sock_fprog_kern *fprog = fp->orig_prog;
 
@@ -1154,6 +1154,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 		kfree(fprog);
 	}
 }
+EXPORT_SYMBOL_GPL(bpf_release_orig_filter);
 
 static void __bpf_prog_release(struct bpf_prog *prog)
 {
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
