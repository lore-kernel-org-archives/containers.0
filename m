Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBDF3C4727E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3DB9D2071E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e51pN1L8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DB9D2071E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id EA1348684F;
	Wed, 30 Sep 2020 15:20:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MULYf8-zFJWD; Wed, 30 Sep 2020 15:20:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 34B86867A7;
	Wed, 30 Sep 2020 15:20:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2F8D6C0890;
	Wed, 30 Sep 2020 15:20:32 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BC852C0890
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 70DAF85DDB
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Tr5mAR9GVmpr
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:29 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f193.google.com (mail-il1-f193.google.com
 [209.85.166.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 814C6852D5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:29 +0000 (UTC)
Received: by mail-il1-f193.google.com with SMTP id z5so2056388ilq.5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 08:20:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=hYUJTNyuZKx7323reM1G24J+fKq7O2/Mzw5J9lqQY70=;
 b=e51pN1L8+paKoCv7+p4JqO2pXYH+VKoz7CIJBuiphVR3caLailgxgi0tItgMfXxW/r
 +GStvQ7rE0rldtpKQ9W/sC2tQ49VffAJTd06+Kw3Ge5QW1wCk8zKiGs0T4vPkdA5OvOb
 pFFT44YI6ObbrkoGuMNPdKgcVqQl5aLu0RyNeSpF5aRZ2bovaboRkxv45Rz/jkzqlFHG
 UMSkblDoFQ4d0zkqneV5m4sz3iB43ZSgzVjYpdjk08lCbaKntAsNYBtK3CLvxqu8tjBT
 C+cPw7XPacoBwVUSAnnR0qyTnCdRpu8tgoRKEG58af4qL0eg2qH60s1OMnyPL3Rx/JUo
 NxjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=hYUJTNyuZKx7323reM1G24J+fKq7O2/Mzw5J9lqQY70=;
 b=AwaR+cIKdSGhBGap1eoj+xZTuj86f10NyIEUNZ8xUoDIF4JRkEiLyVrUD1okphkVUU
 0VU9NRoekvCfy3t18tHmC89ZG4t7KDK0+eAiQuQ/BP0/v9xcz/7ZdQZXS40sDs8Hx1fF
 EdoCn1bbRdD6pxtvxX8dNB/thG09iUQXYHJVhsq0EbyXPwPlxXymkMB8p2u7cP1Nphts
 0sa+g2MugDjI2GZ5JPCTK8Jr8enk9Z3NqtKyw8WgUWbbZ+Hm5ROT9MvwLHubTujoiy5C
 uYIO4wEbdFmIHRDLx5fvBH/EJ/hERUgUzPzRKXUb8enTBs89M4ImkxS88mZ8B4pzGjrY
 Xpkg==
X-Gm-Message-State: AOAM5335hjGSZKzYeWcW14QFeEI4JOXpWAjHALyLuhZRx5Aa6mEDGCwA
 cCtc2HFVpX0fg3pnvNeiHQNi5MtTL+cvfA==
X-Google-Smtp-Source: ABdhPJy1DzpCglh2ifXStoYVzKUDINbDv8p9VTC1kvYdyF9HZJheV703bxFS8sr3L7mbWHIjq8KF7w==
X-Received: by 2002:a05:6e02:4cc:: with SMTP id
 f12mr2483926ils.28.1601479228424; 
 Wed, 30 Sep 2020 08:20:28 -0700 (PDT)
Received: from localhost.localdomain (ip-99-203-15-156.pools.cgn.spcsdns.net.
 [99.203.15.156])
 by smtp.gmail.com with ESMTPSA id t10sm770788iog.49.2020.09.30.08.20.25
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 08:20:27 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Date: Wed, 30 Sep 2020 10:19:13 -0500
Message-Id: <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
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

From: YiFei Zhu <yifeifz2@illinois.edu>

SECCOMP_CACHE_NR_ONLY will only operate on syscalls that do not
access any syscall arguments or instruction pointer. To facilitate
this we need a static analyser to know whether a filter will
return allow regardless of syscall arguments for a given
architecture number / syscall number pair. This is implemented
here with a pseudo-emulator, and stored in a per-filter bitmap.

Each common BPF instruction are emulated. Any weirdness or loading
from a syscall argument will cause the emulator to bail.

The emulation is also halted if it reaches a return. In that case,
if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.

Emulator structure and comments are from Kees [1] and Jann [2].

Emulation is done at attach time. If a filter depends on more
filters, and if the dependee does not guarantee to allow the
syscall, then we skip the emulation of this syscall.

[1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
[2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig     |  34 ++++++++++
 arch/x86/Kconfig |   1 +
 kernel/seccomp.c | 167 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 201 insertions(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 21a3675a7a3a..ca867b2a5d71 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -471,6 +471,14 @@ config HAVE_ARCH_SECCOMP_FILTER
 	    results in the system call being skipped immediately.
 	  - seccomp syscall wired up
 
+config HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
+	bool
+	help
+	  An arch should select this symbol if it provides all of these things:
+	  - all the requirements for HAVE_ARCH_SECCOMP_FILTER
+	  - SECCOMP_ARCH_DEFAULT
+	  - SECCOMP_ARCH_DEFAULT_NR
+
 config SECCOMP
 	prompt "Enable seccomp to safely execute untrusted bytecode"
 	def_bool y
@@ -498,6 +506,32 @@ config SECCOMP_FILTER
 
 	  See Documentation/userspace-api/seccomp_filter.rst for details.
 
+choice
+	prompt "Seccomp filter cache"
+	default SECCOMP_CACHE_NONE
+	depends on SECCOMP_FILTER
+	depends on HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
+	help
+	  Seccomp filters can potentially incur large overhead for each
+	  system call. This can alleviate some of the overhead.
+
+	  If in doubt, select 'syscall numbers only'.
+
+config SECCOMP_CACHE_NONE
+	bool "None"
+	help
+	  No caching is done. Seccomp filters will be called each time
+	  a system call occurs in a seccomp-guarded task.
+
+config SECCOMP_CACHE_NR_ONLY
+	bool "Syscall number only"
+	depends on HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
+	help
+	  For each syscall number, if the seccomp filter has a fixed
+	  result, store that result in a bitmap to speed up system calls.
+
+endchoice
+
 config HAVE_ARCH_STACKLEAK
 	bool
 	help
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 1ab22869a765..ff5289228ea5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -150,6 +150,7 @@ config X86
 	select HAVE_ARCH_COMPAT_MMAP_BASES	if MMU && COMPAT
 	select HAVE_ARCH_PREL32_RELOCATIONS
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
 	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
 	select HAVE_ARCH_STACKLEAK
 	select HAVE_ARCH_TRACEHOOK
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index ae6b40cc39f4..f09c9e74ae05 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -143,6 +143,37 @@ struct notification {
 	struct list_head notifications;
 };
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * struct seccomp_cache_filter_data - container for cache's per-filter data
+ *
+ * Tis struct is ordered to minimize padding holes.
+ *
+ * @syscall_allow_default: A bitmap where each bit represents whether the
+ *			   filter willalways allow the syscall, for the
+ *			   default architecture.
+ * @syscall_allow_compat: A bitmap where each bit represents whether the
+ *		          filter will always allow the syscall, for the
+ *			  compat architecture.
+ */
+struct seccomp_cache_filter_data {
+#ifdef SECCOMP_ARCH_DEFAULT
+	DECLARE_BITMAP(syscall_allow_default, SECCOMP_ARCH_DEFAULT_NR);
+#endif
+#ifdef SECCOMP_ARCH_COMPAT
+	DECLARE_BITMAP(syscall_allow_compat, SECCOMP_ARCH_COMPAT_NR);
+#endif
+};
+
+#define SECCOMP_EMU_MAX_PENDING_STATES 64
+#else
+struct seccomp_cache_filter_data { };
+
+static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
+{
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -159,6 +190,7 @@ struct notification {
  *	   this filter after reaching 0. The @users count is always smaller
  *	   or equal to @refs. Hence, reaching 0 for @users does not mean
  *	   the filter can be freed.
+ * @cache: container for cache-related data.
  * @log: true if all actions except for SECCOMP_RET_ALLOW should be logged
  * @prev: points to a previously installed, or inherited, filter
  * @prog: the BPF program to evaluate
@@ -180,6 +212,7 @@ struct seccomp_filter {
 	refcount_t refs;
 	refcount_t users;
 	bool log;
+	struct seccomp_cache_filter_data cache;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
 	struct notification *notif;
@@ -544,7 +577,8 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
-	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
+	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) ||
+			       IS_ENABLED(CONFIG_SECCOMP_CACHE_NR_ONLY);
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -610,6 +644,136 @@ seccomp_prepare_user_filter(const char __user *user_filter)
 	return filter;
 }
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * seccomp_emu_is_const_allow - check if filter is constant allow with given data
+ * @fprog: The BPF programs
+ * @sd: The seccomp data to check against, only syscall number are arch
+ *      number are considered constant.
+ */
+static bool seccomp_emu_is_const_allow(struct sock_fprog_kern *fprog,
+				       struct seccomp_data *sd)
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
+	for (nr = 0; nr < bitmap_size; nr++) {
+		if (bitmap_prev && !test_bit(nr, bitmap_prev))
+			continue;
+
+		sd.nr = nr;
+		sd.arch = arch;
+
+		if (seccomp_emu_is_const_allow(fprog, &sd))
+			set_bit(nr, bitmap);
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
+	struct seccomp_cache_filter_data *cache = &sfilter->cache;
+	const struct seccomp_cache_filter_data *cache_prev =
+		sfilter->prev ? &sfilter->prev->cache : NULL;
+
+#ifdef SECCOMP_ARCH_DEFAULT
+	seccomp_cache_prepare_bitmap(sfilter, cache->syscall_allow_default,
+				     cache_prev ? cache_prev->syscall_allow_default : NULL,
+				     SECCOMP_ARCH_DEFAULT_NR,
+				     SECCOMP_ARCH_DEFAULT);
+#endif /* SECCOMP_ARCH_DEFAULT */
+
+#ifdef SECCOMP_ARCH_COMPAT
+	seccomp_cache_prepare_bitmap(sfilter, cache->syscall_allow_compat,
+				     cache_prev ? cache_prev->syscall_allow_compat : NULL,
+				     SECCOMP_ARCH_COMPAT_NR,
+				     SECCOMP_ARCH_COMPAT);
+#endif /* SECCOMP_ARCH_COMPAT */
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_attach_filter: validate and attach filter
  * @flags:  flags to change filter behavior
@@ -659,6 +823,7 @@ static long seccomp_attach_filter(unsigned int flags,
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
