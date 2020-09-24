Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4794FC4727D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:11 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CC04520758
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EwAW4TLX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC04520758
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 591E72E122;
	Thu, 24 Sep 2020 12:07:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qv940o8TbvIN; Thu, 24 Sep 2020 12:06:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 207FD2E11C;
	Thu, 24 Sep 2020 12:06:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E0D54C0859;
	Thu, 24 Sep 2020 12:06:58 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 15E6DC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 12BF086BE6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id H1bfeXXzRh5U
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com
 [209.85.166.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id EAB13866EA
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:54 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id g128so2963183iof.11
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:06:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=3VyyapxkY+Tlwjupvhv0a43QaNOs9RawkVhh8EcaIdE=;
 b=EwAW4TLXOcQtaR6Q2+Yfpt86JaQ8spvw+NYd/FUt8tpMRpClUjkKUg6wRTnfZqpqhX
 5aL+0RorrR1waLyV4YQwzC69ewokN4epM7nlSwFkLK7bx9UDvkMDn6cN/fFoPIWWHn6J
 Ebx9dStC2iwRo6TGaaLPQRH28NkhoxobI4RklmgwEFAtbYYlKUTTPBuZsva36AALd0zg
 9K1kpNiUwNSMUDMzFFJONqOWCWvDrfhximAhsOBVinrWQPtWAzWvFgDHoKEsB2T6caBL
 ThOlBasHKz77za60TUX/gdDvA6NwF1Oz/pGoTx2fbnSTEwFZLA/arDXu1YCrWCzq36sp
 dOpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=3VyyapxkY+Tlwjupvhv0a43QaNOs9RawkVhh8EcaIdE=;
 b=aA3NouWT9rqXfNoREfJ5AuQOgGh0O7e6O8OvFWdoRoOiALyzy9+NaCP6urKH0HQcoW
 ba/HLF4Sp3y+OKLXxFhPpn8BOZnicvh95cyC0uRRlNFQBT7HNdR+ZbvxdidmnmrUtFkZ
 sc3unrkV24zvz2H8xq6MPTYUau/6x+M3qg5W8mPI3ABDmKU3wybSfsg27V5w/MhOufn3
 J67sHyp0I8V5C0sMkPMHVOBUj8Mvp3K76LHaX5EfPc5OdsBHYjCdSTYoWavsAhuqXTJf
 qyCh1ZGTSn7fadI6tD3lRuc1TmZ/nm+21vfLeF4bM0OvhRDpuSJ/1bn2R3CAWOyl6qoe
 iN2g==
X-Gm-Message-State: AOAM532o4PIKL6rejlX7TLJgp6LblFndEehdRoNC2ml/GWTErWWgMoiA
 WkfzcQsFVBvX1Am+2dZ9oa0wXK+YImTHhg==
X-Google-Smtp-Source: ABdhPJypROaQ44+t7oSyyVI7CEwZApHerXUO9XK/Tosz7HLSn72Mp02rORpNMITvv9AnazNCcSHT4A==
X-Received: by 2002:a5d:9842:: with SMTP id p2mr3033488ios.113.1600949213831; 
 Thu, 24 Sep 2020 05:06:53 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id a23sm1259435ioc.54.2020.09.24.05.06.52
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:06:53 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 3/6] seccomp/cache: Add "emulator" to check if filter
 is arg-dependent
Date: Thu, 24 Sep 2020 07:06:43 -0500
Message-Id: <772912494e02e42acff4e4ef310bbda95c748704.1600946701.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1600946701.git.yifeifz2@illinois.edu>
References: <cover.1600946701.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

Each common BPF instruction (stolen from Kees's list [1]) are
emulated. Any weirdness or loading from a syscall argument will
cause the emulator to bail.

The emulation is also halted if it reaches a return. In that case,
if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.

Filter dependency is resolved at attach time. If a filter depends
on more filters, then we perform an and on its bitmask against its
dependee; if the dependee does not guarantee to allow the syscall,
then the depender is also marked not to guarantee to allow the
syscall.

[1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 arch/Kconfig     |  25 ++++++
 kernel/seccomp.c | 196 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 220 insertions(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 6dfc5673215d..8cc3dc87f253 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -489,6 +489,31 @@ config SECCOMP_FILTER
 
 	  See Documentation/userspace-api/seccomp_filter.rst for details.
 
+choice
+	prompt "Seccomp filter cache"
+	default SECCOMP_CACHE_NONE
+	depends on SECCOMP_FILTER
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
+	depends on !HAVE_SPARSE_SYSCALL_NR
+	help
+	  For each syscall number, if the seccomp filter has a fixed
+	  result, store that result in a bitmap to speed up system calls.
+
+endchoice
+
 config HAVE_ARCH_STACKLEAK
 	bool
 	help
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 3ee59ce0a323..7c286d66f983 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -143,6 +143,32 @@ struct notification {
 	struct list_head notifications;
 };
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * struct seccomp_cache_filter_data - container for cache's per-filter data
+ *
+ * @syscall_ok: A bitmap for each architecture number, where each bit
+ *		represents whether the filter will always allow the syscall.
+ */
+struct seccomp_cache_filter_data {
+	DECLARE_BITMAP(syscall_ok[ARRAY_SIZE(syscall_arches)], NR_syscalls);
+};
+
+#define SECCOMP_EMU_MAX_PENDING_STATES 64
+#else
+struct seccomp_cache_filter_data { };
+
+static inline int seccomp_cache_prepare(struct seccomp_filter *sfilter)
+{
+	return 0;
+}
+
+static inline void seccomp_cache_inherit(struct seccomp_filter *sfilter,
+					 const struct seccomp_filter *prev)
+{
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -185,6 +211,7 @@ struct seccomp_filter {
 	struct notification *notif;
 	struct mutex notify_lock;
 	wait_queue_head_t wqh;
+	struct seccomp_cache_filter_data cache;
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
@@ -530,6 +557,139 @@ static inline void seccomp_sync_threads(unsigned long flags)
 	}
 }
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * struct seccomp_emu_env - container for seccomp emulator environment
+ *
+ * @filter: The cBPF filter instructions.
+ * @nr: The syscall number we are emulating.
+ * @arch: The architecture number we are emulating.
+ * @syscall_ok: Emulation result, whether it is okay for seccomp to cache the
+ *		syscall.
+ */
+struct seccomp_emu_env {
+	struct sock_filter *filter;
+	int arch;
+	int nr;
+	bool syscall_ok;
+};
+
+/**
+ * struct seccomp_emu_state - container for seccomp emulator state
+ *
+ * @next: The next pending state. This structure is a linked list.
+ * @pc: The current program counter.
+ * @areg: the value of that A register.
+ */
+struct seccomp_emu_state {
+	struct seccomp_emu_state *next;
+	int pc;
+	u32 areg;
+};
+
+/**
+ * seccomp_emu_step - step one instruction in the emulator
+ * @env: The emulator environment
+ * @state: The emulator state
+ *
+ * Returns 1 to halt emulation, 0 to continue, or -errno if error occurred.
+ */
+static int seccomp_emu_step(struct seccomp_emu_env *env,
+			    struct seccomp_emu_state *state)
+{
+	struct sock_filter *ftest = &env->filter[state->pc++];
+	u16 code = ftest->code;
+	u32 k = ftest->k;
+	bool compare;
+
+	switch (code) {
+	case BPF_LD | BPF_W | BPF_ABS:
+		if (k == offsetof(struct seccomp_data, nr))
+			state->areg = env->nr;
+		else if (k == offsetof(struct seccomp_data, arch))
+			state->areg = env->arch;
+		else
+			return 1;
+
+		return 0;
+	case BPF_JMP | BPF_JA:
+		state->pc += k;
+		return 0;
+	case BPF_JMP | BPF_JEQ | BPF_K:
+	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JSET | BPF_K:
+		switch (BPF_OP(code)) {
+		case BPF_JEQ:
+			compare = state->areg == k;
+			break;
+		case BPF_JGT:
+			compare = state->areg > k;
+			break;
+		case BPF_JGE:
+			compare = state->areg >= k;
+			break;
+		case BPF_JSET:
+			compare = state->areg & k;
+			break;
+		default:
+			WARN_ON(true);
+			return -EINVAL;
+		}
+
+		state->pc += compare ? ftest->jt : ftest->jf;
+		return 0;
+	case BPF_ALU | BPF_AND | BPF_K:
+		state->areg &= k;
+		return 0;
+	case BPF_RET | BPF_K:
+		env->syscall_ok = k == SECCOMP_RET_ALLOW;
+		return 1;
+	default:
+		return 1;
+	}
+}
+
+/**
+ * seccomp_cache_prepare - emulate the filter to find cachable syscalls
+ * @sfilter: The seccomp filter
+ *
+ * Returns 0 if successful or -errno if error occurred.
+ */
+int seccomp_cache_prepare(struct seccomp_filter *sfilter)
+{
+	struct sock_fprog_kern *fprog = sfilter->prog->orig_prog;
+	struct sock_filter *filter = fprog->filter;
+	int arch, nr, res = 0;
+
+	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
+		for (nr = 0; nr < NR_syscalls; nr++) {
+			struct seccomp_emu_env env = {0};
+			struct seccomp_emu_state state = {0};
+
+			env.filter = filter;
+			env.arch = syscall_arches[arch];
+			env.nr = nr;
+
+			while (true) {
+				res = seccomp_emu_step(&env, &state);
+				if (res)
+					break;
+			}
+
+			if (res < 0)
+				goto out;
+
+			if (env.syscall_ok)
+				set_bit(nr, sfilter->cache.syscall_ok[arch]);
+		}
+	}
+
+out:
+	return res;
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_prepare_filter: Prepares a seccomp filter for use.
  * @fprog: BPF program to install
@@ -540,7 +700,8 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
-	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
+	const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) ||
+			       IS_ENABLED(CONFIG_SECCOMP_CACHE_NR_ONLY);
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -571,6 +732,13 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 		return ERR_PTR(ret);
 	}
 
+	ret = seccomp_cache_prepare(sfilter);
+	if (ret < 0) {
+		bpf_prog_destroy(sfilter->prog);
+		kfree(sfilter);
+		return ERR_PTR(ret);
+	}
+
 	refcount_set(&sfilter->refs, 1);
 	refcount_set(&sfilter->users, 1);
 	init_waitqueue_head(&sfilter->wqh);
@@ -606,6 +774,31 @@ seccomp_prepare_user_filter(const char __user *user_filter)
 	return filter;
 }
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * seccomp_cache_inherit - lookup seccomp cache
+ * @sfilter: The seccomp filter
+ * @sd: The seccomp data to lookup the cache with
+ *
+ * Returns true if the seccomp_data is cached and allowed.
+ */
+static void seccomp_cache_inherit(struct seccomp_filter *sfilter,
+				  const struct seccomp_filter *prev)
+{
+	int arch;
+
+	if (!prev)
+		return;
+
+	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
+		bitmap_and(sfilter->cache.syscall_ok[arch],
+			   sfilter->cache.syscall_ok[arch],
+			   prev->cache.syscall_ok[arch],
+			   NR_syscalls);
+	}
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_attach_filter: validate and attach filter
  * @flags:  flags to change filter behavior
@@ -655,6 +848,7 @@ static long seccomp_attach_filter(unsigned int flags,
 	 * task reference.
 	 */
 	filter->prev = current->seccomp.filter;
+	seccomp_cache_inherit(filter, filter->prev);
 	current->seccomp.filter = filter;
 	atomic_inc(&current->seccomp.filter_count);
 
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
