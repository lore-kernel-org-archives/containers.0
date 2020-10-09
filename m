Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7BC4C433E7
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:15:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7792722265
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 17:15:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R5vql2U5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7792722265
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4B0A48780E;
	Fri,  9 Oct 2020 17:15:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ic8w7na5zgRz; Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C4C3887815;
	Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B31ADC1AD7;
	Fri,  9 Oct 2020 17:15:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F40F9C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id E7826877C2
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id z9exERc5BN+V
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:36 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com
 [209.85.166.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5E7BA877C3
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 17:15:36 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id l8so10774027ioh.11
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 10:15:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=Fp+QEq+G0DYx9BDPqAT5zZ3rasyyVU93CxYOBQ8bLUE=;
 b=R5vql2U59tRFN4d+fxjJrLgN0misEj9IU0I2TB0d4lumPbih8wiSBKKkReYUOe+90G
 6s+NF/ruVpUNh2LoNUNQSxsfH1vCOUJDNeYLaFxVabGf+ZViaGgmmPFrDZHhJTUU8ShH
 bDqXcQ3nvPB6vv9Z+m9MTNoI1p+13d6MB2SuLeKshrG5sEJcAcQRuN2kDsTKgf7Klk7p
 fX3cp3qZz7Lkuh3FU3+PuqNjNF/7k8MTMb7liemu/a74ECvWC+LM/P9VIpvo+cH5Ho9x
 AAa5TixTVzHGbkdXkACCuJwWG9pyLRjyaqxWzVnTdeJbUcEEgd7vrf5PS+BmWTtgFIhC
 Y8dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=Fp+QEq+G0DYx9BDPqAT5zZ3rasyyVU93CxYOBQ8bLUE=;
 b=gWKUQCHFtSkExNijS6kEDbbjP7TJ26779aV7IWV0Fn8VtyKJKXfl2Fo6zDXZ27jD4j
 FMCjBdVpceP3exifjyQdxtFFXOD5DUQhN4YEYvopS7SweZJN1VDBCtovedEpe5EkC9K/
 NkHtBMwFgTI+TF4UKplDWgVgjMqfWY5URSN/e95dzyDUkAPQXdkZ0mkmh0gSFzzX2To6
 BKI46n4//wKhxwt3rWs8lFElMdhjGXLRlIm4yIKy8IafnJOJ9A9js6nZDt9GJxUGtATs
 125nWoRq6YkoltkgFKmtfUAsd7Q+5DSQ48cYEM22GVUzMHiLgGrGPcdHE5kUr4CnnXCO
 WoBw==
X-Gm-Message-State: AOAM531Tz3+KAqdJhz2m/fO0SHQvv3nyzjcv80Vrw6vbdIB+cPOuEuvW
 +iKotR0/ydp3lN2VR2oSz4mKhX6bNJ0t2w==
X-Google-Smtp-Source: ABdhPJyFXl7949q3WjGIDvlLpb40UMyHA6JkHLE9d3Pc8k7uvlkeD9TNUGcdS64Qhb2F9betrqU8Cw==
X-Received: by 2002:a5d:8755:: with SMTP id k21mr10360067iol.142.1602263735201; 
 Fri, 09 Oct 2020 10:15:35 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id c2sm3762830iot.52.2020.10.09.10.15.34
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 09 Oct 2020 10:15:34 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v4 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Date: Fri,  9 Oct 2020 12:14:30 -0500
Message-Id: <1a40458d081ce0d5423eb0282210055496e28774.1602263422.git.yifeifz2@illinois.edu>
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

From: YiFei Zhu <yifeifz2@illinois.edu>

SECCOMP_CACHE will only operate on syscalls that do not access
any syscall arguments or instruction pointer. To facilitate
this we need a static analyser to know whether a filter will
return allow regardless of syscall arguments for a given
architecture number / syscall number pair. This is implemented
here with a pseudo-emulator, and stored in a per-filter bitmap.

In order to build this bitmap at filter attach time, each filter is
emulated for every syscall (under each possible architecture), and
checked for any accesses of struct seccomp_data that are not the "arch"
nor "nr" (syscall) members. If only "arch" and "nr" are examined, and
the program returns allow, then we can be sure that the filter must
return allow independent from syscall arguments.

Nearly all seccomp filters are built from these cBPF instructions:

BPF_LD  | BPF_W    | BPF_ABS
BPF_JMP | BPF_JEQ  | BPF_K
BPF_JMP | BPF_JGE  | BPF_K
BPF_JMP | BPF_JGT  | BPF_K
BPF_JMP | BPF_JSET | BPF_K
BPF_JMP | BPF_JA
BPF_RET | BPF_K
BPF_ALU | BPF_AND  | BPF_K

Each of these instructions are emulated. Any weirdness or loading
from a syscall argument will cause the emulator to bail.

The emulation is also halted if it reaches a return. In that case,
if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.

Emulator structure and comments are from Kees [1] and Jann [2].

Emulation is done at attach time. If a filter depends on more
filters, and if the dependee does not guarantee to allow the
syscall, then we skip the emulation of this syscall.

[1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
[2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/

Suggested-by: Jann Horn <jannh@google.com>
Co-developed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 kernel/seccomp.c | 158 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 157 insertions(+), 1 deletion(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 73f6b6e9a3b0..51032b41fe59 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -169,6 +169,10 @@ static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilte
 {
 	return false;
 }
+
+static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
+{
+}
 #endif /* SECCOMP_ARCH_NATIVE */
 
 /**
@@ -187,6 +191,7 @@ static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilte
  *	   this filter after reaching 0. The @users count is always smaller
  *	   or equal to @refs. Hence, reaching 0 for @users does not mean
  *	   the filter can be freed.
+ * @cache: cache of arch/syscall mappings to actions
  * @log: true if all actions except for SECCOMP_RET_ALLOW should be logged
  * @prev: points to a previously installed, or inherited, filter
  * @prog: the BPF program to evaluate
@@ -208,6 +213,7 @@ struct seccomp_filter {
 	refcount_t refs;
 	refcount_t users;
 	bool log;
+	struct action_cache cache;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
 	struct notification *notif;
@@ -616,7 +622,12 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
-	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
+	const bool save_orig =
+#if defined(CONFIG_CHECKPOINT_RESTORE) || defined(SECCOMP_ARCH_NATIVE)
+		true;
+#else
+		false;
+#endif
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -682,6 +693,150 @@ seccomp_prepare_user_filter(const char __user *user_filter)
 	return filter;
 }
 
+#ifdef SECCOMP_ARCH_NATIVE
+/**
+ * seccomp_is_const_allow - check if filter is constant allow with given data
+ * @fprog: The BPF programs
+ * @sd: The seccomp data to check against, only syscall number are arch
+ *      number are considered constant.
+ */
+static bool seccomp_is_const_allow(struct sock_fprog_kern *fprog,
+				   struct seccomp_data *sd)
+{
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
+			/* reached return with constant values only, check allow */
+			return k == SECCOMP_RET_ALLOW;
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
+		case BPF_ALU | BPF_AND | BPF_K:
+			reg_value &= k;
+			break;
+		default:
+			/* can't optimize (unknown insn) */
+			return false;
+		}
+	}
+
+	/* ran off the end of the filter?! */
+	WARN_ON(1);
+	return false;
+}
+
+static void seccomp_cache_prepare_bitmap(struct seccomp_filter *sfilter,
+					 void *bitmap, const void *bitmap_prev,
+					 size_t bitmap_size, int arch)
+{
+	struct sock_fprog_kern *fprog = sfilter->prog->orig_prog;
+	struct seccomp_data sd;
+	int nr;
+
+	if (bitmap_prev) {
+		/* The new filter must be as restrictive as the last. */
+		bitmap_copy(bitmap, bitmap_prev, bitmap_size);
+	} else {
+		/* Before any filters, all syscalls are always allowed. */
+		bitmap_fill(bitmap, bitmap_size);
+	}
+
+	for (nr = 0; nr < bitmap_size; nr++) {
+		/* No bitmap change: not a cacheable action. */
+		if (!test_bit(nr, bitmap))
+			continue;
+
+		sd.nr = nr;
+		sd.arch = arch;
+
+		/* No bitmap change: continue to always allow. */
+		if (seccomp_is_const_allow(fprog, &sd))
+			continue;
+
+		/*
+		 * Not a cacheable action: always run filters.
+		 * atomic clear_bit() not needed, filter not visible yet.
+		 */
+		__clear_bit(nr, bitmap);
+	}
+}
+
+/**
+ * seccomp_cache_prepare - emulate the filter to find cachable syscalls
+ * @sfilter: The seccomp filter
+ *
+ * Returns 0 if successful or -errno if error occurred.
+ */
+static void seccomp_cache_prepare(struct seccomp_filter *sfilter)
+{
+	struct action_cache *cache = &sfilter->cache;
+	const struct action_cache *cache_prev =
+		sfilter->prev ? &sfilter->prev->cache : NULL;
+
+	seccomp_cache_prepare_bitmap(sfilter, cache->allow_native,
+				     cache_prev ? cache_prev->allow_native : NULL,
+				     SECCOMP_ARCH_NATIVE_NR,
+				     SECCOMP_ARCH_NATIVE);
+
+#ifdef SECCOMP_ARCH_COMPAT
+	seccomp_cache_prepare_bitmap(sfilter, cache->allow_compat,
+				     cache_prev ? cache_prev->allow_compat : NULL,
+				     SECCOMP_ARCH_COMPAT_NR,
+				     SECCOMP_ARCH_COMPAT);
+#endif /* SECCOMP_ARCH_COMPAT */
+}
+#endif /* SECCOMP_ARCH_NATIVE */
+
 /**
  * seccomp_attach_filter: validate and attach filter
  * @flags:  flags to change filter behavior
@@ -731,6 +886,7 @@ static long seccomp_attach_filter(unsigned int flags,
 	 * task reference.
 	 */
 	filter->prev = current->seccomp.filter;
+	seccomp_cache_prepare(filter);
 	current->seccomp.filter = filter;
 	atomic_inc(&current->seccomp.filter_count);
 
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
