Return-Path: <SRS0=u+zM=DS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 713DDC433DF
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 09B7F20757
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 15:48:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vQeTCR/F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09B7F20757
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B2909871F0;
	Sun, 11 Oct 2020 15:48:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id I3LxZKK13Tbi; Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id E427A871C0;
	Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D2079C07FF;
	Sun, 11 Oct 2020 15:48:07 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1FDE8C0051
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0AB53871C3
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Hcyhb1XorGmW
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:05 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f196.google.com (mail-il1-f196.google.com
 [209.85.166.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 3AAD7871C0
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 15:48:05 +0000 (UTC)
Received: by mail-il1-f196.google.com with SMTP id q1so13665288ilt.6
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 08:48:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=JJXbtpBvdkCCp5A/ckgjV4XfHoc3oDiUPRre1ETEuq0=;
 b=vQeTCR/FEokGwc7yJDwxzFwX1mCUpWIxAqsSYm5URyVMlV9DtNcR03zGsNI2oPi4lB
 HSMu0VVvVGR3stO4GcaF5eHtb2k3a7rmUJTijm58otgq3uE7opG6Sssy+uLcGALbOVSe
 bdjwAuT+/eIGbvM5T1saL2OI7bEHRXy65haV2RZCOO2Sh0oCpsO7JKTpPS4CfJBSZmcr
 /nwx6myGyQ3O/qLu4tUThklXz9OGrWajNqqniz24StEhwi96JbWG8V8pEzr/W9vQi7Us
 Rc0FHb20LJn6JLrz7hc+DoZ81mIa5aNyi/vXZVb096cCTtwNF7MmGRd1XyD3j177dyve
 plbQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=JJXbtpBvdkCCp5A/ckgjV4XfHoc3oDiUPRre1ETEuq0=;
 b=c0IFCWghaZRvcwhxArv7a3dr/R5DORRa0fHW01qmuzPQfiERI66RSieyWuRMzZe68Q
 JsZrw3jBz8bJEEsMQ2MeDsvLf3KWzSas6LYJg0SU1ANzeXVesbRxvIM2AMnygHxPcHmQ
 KrTlY1RCESoIzGbcagGrEYNoteSomc13n8MVj0AriOwjRx5TYGr70/7Pbpg1rRw3FhV2
 DCypwGhVq28iC7qTyxvxJnRbhiUAy4OALGNZcTosoMhgS7ZXapbra2pkGGGUA4HDVHhn
 +oib0nnNSCc0URzA+QTr/BMtMBYz/dcOUhQ9pCqBIMjK1XuA9GRIV2XYOTPi/NsjdsRl
 b04w==
X-Gm-Message-State: AOAM531D4AWvAzegNTtNK5PEOGhCmcHB6+ZO+qzHIapYxlQbXax3THod
 Q3MvEBRQi0OGYQp4sYrP5c6jQOtxWzBJ5g==
X-Google-Smtp-Source: ABdhPJz1eroFA985vUHFIDp1DHFJxtAl5saYvt2fXU/+A2P1U5lafH1RvMMk/WgTcVD9AgqoahJaIA==
X-Received: by 2002:a92:b109:: with SMTP id t9mr15251649ilh.191.1602431284312; 
 Sun, 11 Oct 2020 08:48:04 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id q16sm7502881ilj.71.2020.10.11.08.48.03
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 11 Oct 2020 08:48:03 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v5 seccomp 1/5] seccomp/cache: Lookup syscall allowlist bitmap
 for fast path
Date: Sun, 11 Oct 2020 10:47:42 -0500
Message-Id: <10f91a367ec4fcdea7fc3f086de3f5f13a4a7436.1602431034.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1602431034.git.yifeifz2@illinois.edu>
References: <cover.1602431034.git.yifeifz2@illinois.edu>
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

The overhead of running Seccomp filters has been part of some past
discussions [1][2][3]. Oftentimes, the filters have a large number
of instructions that check syscall numbers one by one and jump based
on that. Some users chain BPF filters which further enlarge the
overhead. A recent work [6] comprehensively measures the Seccomp
overhead and shows that the overhead is non-negligible and has a
non-trivial impact on application performance.

We observed some common filters, such as docker's [4] or
systemd's [5], will make most decisions based only on the syscall
numbers, and as past discussions considered, a bitmap where each bit
represents a syscall makes most sense for these filters.

The fast (common) path for seccomp should be that the filter permits
the syscall to pass through, and failing seccomp is expected to be
an exceptional case; it is not expected for userspace to call a
denylisted syscall over and over.

When it can be concluded that an allow must occur for the given
architecture and syscall pair (this determination is introduced in
the next commit), seccomp will immediately allow the syscall,
bypassing further BPF execution.

Each architecture number has its own bitmap. The architecture
number in seccomp_data is checked against the defined architecture
number constant before proceeding to test the bit against the
bitmap with the syscall number as the index of the bit in the
bitmap, and if the bit is set, seccomp returns allow. The bitmaps
are all clear in this patch and will be initialized in the next
commit.

When only one architecture exists, the check against architecture
number is skipped, suggested by Kees Cook [7].

[1] https://lore.kernel.org/linux-security-module/c22a6c3cefc2412cad00ae14c1371711@huawei.com/T/
[2] https://lore.kernel.org/lkml/202005181120.971232B7B@keescook/T/
[3] https://github.com/seccomp/libseccomp/issues/116
[4] https://github.com/moby/moby/blob/ae0ef82b90356ac613f329a8ef5ee42ca923417d/profiles/seccomp/default.json
[5] https://github.com/systemd/systemd/blob/6743a1caf4037f03dc51a1277855018e4ab61957/src/shared/seccomp-util.c#L270
[6] Draco: Architectural and Operating System Support for System Call Security
    https://tianyin.github.io/pub/draco.pdf, MICRO-53, Oct. 2020
[7] https://lore.kernel.org/bpf/202010091614.8BB0EB64@keescook/

Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 kernel/seccomp.c | 77 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index ae6b40cc39f4..d67a8b61f2bf 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -143,6 +143,34 @@ struct notification {
 	struct list_head notifications;
 };
 
+#ifdef SECCOMP_ARCH_NATIVE
+/**
+ * struct action_cache - per-filter cache of seccomp actions per
+ * arch/syscall pair
+ *
+ * @allow_native: A bitmap where each bit represents whether the
+ *		  filter will always allow the syscall, for the
+ *		  native architecture.
+ * @allow_compat: A bitmap where each bit represents whether the
+ *		  filter will always allow the syscall, for the
+ *		  compat architecture.
+ */
+struct action_cache {
+	DECLARE_BITMAP(allow_native, SECCOMP_ARCH_NATIVE_NR);
+#ifdef SECCOMP_ARCH_COMPAT
+	DECLARE_BITMAP(allow_compat, SECCOMP_ARCH_COMPAT_NR);
+#endif
+};
+#else
+struct action_cache { };
+
+static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilter,
+					     const struct seccomp_data *sd)
+{
+	return false;
+}
+#endif /* SECCOMP_ARCH_NATIVE */
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -298,6 +326,52 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
 	return 0;
 }
 
+#ifdef SECCOMP_ARCH_NATIVE
+static inline bool seccomp_cache_check_allow_bitmap(const void *bitmap,
+						    size_t bitmap_size,
+						    int syscall_nr)
+{
+	if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))
+		return false;
+	syscall_nr = array_index_nospec(syscall_nr, bitmap_size);
+
+	return test_bit(syscall_nr, bitmap);
+}
+
+/**
+ * seccomp_cache_check_allow - lookup seccomp cache
+ * @sfilter: The seccomp filter
+ * @sd: The seccomp data to lookup the cache with
+ *
+ * Returns true if the seccomp_data is cached and allowed.
+ */
+static inline bool seccomp_cache_check_allow(const struct seccomp_filter *sfilter,
+					     const struct seccomp_data *sd)
+{
+	int syscall_nr = sd->nr;
+	const struct action_cache *cache = &sfilter->cache;
+
+#ifndef SECCOMP_ARCH_COMPAT
+	/* A native-only architecture doesn't need to check sd->arch. */
+	return seccomp_cache_check_allow_bitmap(cache->allow_native,
+						SECCOMP_ARCH_NATIVE_NR,
+						syscall_nr);
+#else
+	if (likely(sd->arch == SECCOMP_ARCH_NATIVE))
+		return seccomp_cache_check_allow_bitmap(cache->allow_native,
+							SECCOMP_ARCH_NATIVE_NR,
+							syscall_nr);
+	if (likely(sd->arch == SECCOMP_ARCH_COMPAT))
+		return seccomp_cache_check_allow_bitmap(cache->allow_compat,
+							SECCOMP_ARCH_COMPAT_NR,
+							syscall_nr);
+#endif /* SECCOMP_ARCH_COMPAT */
+
+	WARN_ON_ONCE(true);
+	return false;
+}
+#endif /* SECCOMP_ARCH_NATIVE */
+
 /**
  * seccomp_run_filters - evaluates all seccomp filters against @sd
  * @sd: optional seccomp data to be passed to filters
@@ -320,6 +394,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
 	if (WARN_ON(f == NULL))
 		return SECCOMP_RET_KILL_PROCESS;
 
+	if (seccomp_cache_check_allow(f, sd))
+		return SECCOMP_RET_ALLOW;
+
 	/*
 	 * All filters in the list are evaluated and the lowest BPF return
 	 * value always takes priority (ignoring the DATA).
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
