Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47B9AC43464
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 05:35:47 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D0C34207BC
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 05:35:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rIA83MLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0C34207BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 166C1864EF;
	Mon, 21 Sep 2020 05:35:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QVr9fafRppoE; Mon, 21 Sep 2020 05:35:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1AE7D8717D;
	Mon, 21 Sep 2020 05:35:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0764EC1AD4;
	Mon, 21 Sep 2020 05:35:44 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0621AC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E74F886687
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HPnJYQ+vcIRn
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com
 [209.85.166.67])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 04EC08669D
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 05:35:42 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id y13so14126654iow.4
 for <containers@lists.linux-foundation.org>;
 Sun, 20 Sep 2020 22:35:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=8VPHhySLJY4akJNqfsKiqAyrK1Vi8OEV4lKjXg8TGxs=;
 b=rIA83MLLMjSD3P4IpS79plW3Jo6Kkw4wDHgJeH7wrLJ2sfCjol5XlmVd0az6hdpuIS
 hLYdY9LpLUq0tQxeDxOB/yBD6fBpFnwL/xMsp5vzLrnni+Y9oj7skvLdD9PX6imX+cNP
 oyxX77BaU+uhmgedGDuleuPTOSXtSXU3bmBzFCSbJVDhVxBZHVqTD0jLjgiCrGeHia49
 yG6WJe3iQ74+MsW0JYGkJhHUTB6PfVWiDnkxcotlcUIMIO5rSoc+naflSQ6EBAw5OQKj
 6ZSn0Tmy7HcElQs2HKA77benLzT3SwtWhKML0bNCnlTkDDMlRep9FEXWn7WCB42hoOt+
 kibA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=8VPHhySLJY4akJNqfsKiqAyrK1Vi8OEV4lKjXg8TGxs=;
 b=rRSKyXkqQsWzR+PsrhLWIz/a0w9yc+gF8HGy9E5/XDX5hjwGFg98YPUksnwSvDVNbx
 jE5Nryq/bWIb8ZkzRMYwZ8SW/HmkYuMdLZRf8e5O6UJtVvfZtnHgYkFn+sHEEpNmTNJ6
 XqQOED6Dg81OWYplaEDRbdt4U4zMQutwzwfsykMvsy2LpKsyhyImOBCYgkaflmpQsgOb
 zVhx3vFcrfMiaQ9m1rhovNDWp1OzpEAHoRc+FMakfysCwxxmM8RKzZ2FHxc3ip65zESd
 u/BoWddXsb7ciPUT+8e/ESUVWc/esX+Xekmzxzvon3TQvHjqiTZ1M6dkr1u1pgbhbCJ/
 M6Zw==
X-Gm-Message-State: AOAM531BO7QXEv+MvnfqZJH7Ir42P2xidPkDtRp8WzN3yIJXm0wklW+Q
 osv/KgaxWWjg8579hlnlZ7Fy0lQg5il7wg==
X-Google-Smtp-Source: ABdhPJy8Gq+pvY1l8PbrdToIHwyZwbLr46c7qWzPrm1/CrIB8CZNck3xd04aYX5yCim97inSBNp9dA==
X-Received: by 2002:a5e:9b11:: with SMTP id j17mr2806234iok.176.1600666541022; 
 Sun, 20 Sep 2020 22:35:41 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id i9sm6644962ilj.71.2020.09.20.22.35.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 20 Sep 2020 22:35:40 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [RFC PATCH seccomp 2/2] seccomp/cache: Cache filter results that
 allow syscalls
Date: Mon, 21 Sep 2020 00:35:18 -0500
Message-Id: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1600661418.git.yifeifz2@illinois.edu>
References: <cover.1600661418.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Valentin Rothberg <vrothber@redhat.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Josep Torrellas <torrella@illinois.edu>,
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

The fast (common) path for seccomp should be that the filter permits
the syscall to pass through, and failing seccomp is expected to be
an exceptional case; it is not expected for userspace to call a
denylisted syscall over and over.

We do this by creating a per-task bitmap of permitted syscalls.
If seccomp filter is invoked we check if it is cached and if so
directly return allow. Else we call into the cBPF filter, and if
the result is an allow then we cache the results.

The cache is per-task to minimize thread-synchronization issues in
the hot path of cache lookup, and to avoid different architecture
numbers sharing the same cache.

To account for one thread changing the filter for another thread of
the same process, the per-task struct also contains a pointer to
the filter the cache is built on. When the cache lookup uses a
different filter then the last lookup, the per-task cache bitmap is
cleared.

Architecture number changes also invokes a clear of the per-task
cache, since it should be very unlikely for a given thread to change
its architecture.

Benchmark results, on qemu-kvm x86_64 VM, on Intel(R) Core(TM)
i5-8250U CPU @ 1.60GHz, with seccomp_benchmark:

With SECCOMP_CACHE_NONE:
  Current BPF sysctl settings:
  net.core.bpf_jit_enable = 1
  net.core.bpf_jit_harden = 0
  Calibrating sample size for 15 seconds worth of syscalls ...
  Benchmarking 23486415 syscalls...
  16.079642020 - 1.013345439 = 15066296581 (15.1s)
  getpid native: 641 ns
  32.080237410 - 16.080763500 = 15999473910 (16.0s)
  getpid RET_ALLOW 1 filter: 681 ns
  48.609461618 - 32.081296173 = 16528165445 (16.5s)
  getpid RET_ALLOW 2 filters: 703 ns
  Estimated total seccomp overhead for 1 filter: 40 ns
  Estimated total seccomp overhead for 2 filters: 62 ns
  Estimated seccomp per-filter overhead: 22 ns
  Estimated seccomp entry overhead: 18 ns

With SECCOMP_CACHE_NR_ONLY:
  Current BPF sysctl settings:
  net.core.bpf_jit_enable = 1
  net.core.bpf_jit_harden = 0
  Calibrating sample size for 15 seconds worth of syscalls ...
  Benchmarking 23486415 syscalls...
  16.059512499 - 1.014108434 = 15045404065 (15.0s)
  getpid native: 640 ns
  31.651075934 - 16.060637323 = 15590438611 (15.6s)
  getpid RET_ALLOW 1 filter: 663 ns
  47.367316169 - 31.652302661 = 15715013508 (15.7s)
  getpid RET_ALLOW 2 filters: 669 ns
  Estimated total seccomp overhead for 1 filter: 23 ns
  Estimated total seccomp overhead for 2 filters: 29 ns
  Estimated seccomp per-filter overhead: 6 ns
  Estimated seccomp entry overhead: 17 ns

Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 include/linux/seccomp.h | 22 ++++++++++++
 kernel/seccomp.c        | 77 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 97 insertions(+), 2 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 02aef2844c38..08ec8b90c99d 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -21,6 +21,27 @@
 #include <asm/seccomp.h>
 
 struct seccomp_filter;
+
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * struct seccomp_cache_task_data - container for seccomp cache's per-task data
+ *
+ * @syscall_ok: A bitmap where each bit represents whether the syscall is cached
+ *		and that the filter allowed it.
+ * @last_filter: If the next cache lookup uses a different filter, the lookup
+ *		 will clear cache.
+ * @last_arch: If the next cache lookup uses a different arch number, the
+ *	       lookup will clear cache.
+ */
+struct seccomp_cache_task_data {
+	DECLARE_BITMAP(syscall_ok, NR_syscalls);
+	const struct seccomp_filter *last_filter;
+	u32 last_arch;
+};
+#else
+struct seccomp_cache_task_data { };
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * struct seccomp - the state of a seccomp'ed process
  *
@@ -36,6 +57,7 @@ struct seccomp {
 	int mode;
 	atomic_t filter_count;
 	struct seccomp_filter *filter;
+	struct seccomp_cache_task_data cache;
 };
 
 #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index d8c30901face..7096f8c86f71 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -162,6 +162,17 @@ static inline int seccomp_cache_prepare(struct seccomp_filter *sfilter)
 {
 	return 0;
 }
+
+static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,
+				       const struct seccomp_data *sd)
+{
+	return 0;
+}
+
+static inline void seccomp_cache_insert(const struct seccomp_filter *sfilter,
+					const struct seccomp_data *sd)
+{
+}
 #endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
 
 /**
@@ -316,6 +327,59 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
 	return 0;
 }
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+/**
+ * seccomp_cache_check - lookup seccomp cache
+ * @sfilter: The seccomp filter
+ * @sd: The seccomp data to lookup the cache with
+ *
+ * Returns true if the seccomp_data is cached and allowed.
+ */
+static bool seccomp_cache_check(const struct seccomp_filter *sfilter,
+				const struct seccomp_data *sd)
+{
+	struct seccomp_cache_task_data *thread_data;
+	int syscall_nr = sd->nr;
+
+	if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
+		return false;
+
+	thread_data = &current->seccomp.cache;
+	if (unlikely(thread_data->last_filter != sfilter ||
+		     thread_data->last_arch != sd->arch)) {
+		thread_data->last_filter = sfilter;
+		thread_data->last_arch = sd->arch;
+
+		bitmap_zero(thread_data->syscall_ok, NR_syscalls);
+		return false;
+	}
+
+	return test_bit(syscall_nr, thread_data->syscall_ok);
+}
+
+/**
+ * seccomp_cache_insert - insert into seccomp cache
+ * @sfilter: The seccomp filter
+ * @sd: The seccomp data to insert into the cache
+ */
+static void seccomp_cache_insert(const struct seccomp_filter *sfilter,
+				 const struct seccomp_data *sd)
+{
+	struct seccomp_cache_task_data *thread_data;
+	int syscall_nr = sd->nr;
+
+	if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
+		return;
+
+	thread_data = &current->seccomp.cache;
+
+	if (!test_bit(syscall_nr, sfilter->cache.syscall_ok))
+		return;
+
+	set_bit(syscall_nr, thread_data->syscall_ok);
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_run_filters - evaluates all seccomp filters against @sd
  * @sd: optional seccomp data to be passed to filters
@@ -331,13 +395,18 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
 {
 	u32 ret = SECCOMP_RET_ALLOW;
 	/* Make sure cross-thread synced filter points somewhere sane. */
-	struct seccomp_filter *f =
-			READ_ONCE(current->seccomp.filter);
+	struct seccomp_filter *f, *f_head;
+
+	f = READ_ONCE(current->seccomp.filter);
+	f_head = f;
 
 	/* Ensure unexpected behavior doesn't result in failing open. */
 	if (WARN_ON(f == NULL))
 		return SECCOMP_RET_KILL_PROCESS;
 
+	if (seccomp_cache_check(f_head, sd))
+		return SECCOMP_RET_ALLOW;
+
 	/*
 	 * All filters in the list are evaluated and the lowest BPF return
 	 * value always takes priority (ignoring the DATA).
@@ -350,6 +419,10 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
 			*match = f;
 		}
 	}
+
+	if (ret == SECCOMP_RET_ALLOW)
+		seccomp_cache_insert(f_head, sd);
+
 	return ret;
 }
 #endif /* CONFIG_SECCOMP_FILTER */
-- 
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
