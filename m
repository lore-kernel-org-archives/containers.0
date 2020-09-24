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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C39CAC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4CC7023772
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:07:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r9uakENV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC7023772
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id DC2062E11A;
	Thu, 24 Sep 2020 12:07:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aHgm80NfFXrt; Thu, 24 Sep 2020 12:07:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 1DC102E115;
	Thu, 24 Sep 2020 12:07:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 03F4EC0859;
	Thu, 24 Sep 2020 12:07:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6C480C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id BB0A62E114
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id i1d+Z5ThXagV
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:56 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com
 [209.85.166.67])
 by silver.osuosl.org (Postfix) with ESMTPS id CB3A92E115
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:06:55 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id d190so3032849iof.3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:06:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=SYKa1nrEaZaYwZ8wYDMo+wGBRjI8YKJTKmH+OljJTGg=;
 b=r9uakENVZx3FshPV+JWxKdMA/UFifGO75CEByTaA1MQ7piwbKpqOgJyuN5h4qIsH6L
 AR1TMSH0M8ESEauKZ3CoROg4wA1sf1sd65zjzUrwfDJ7He2gW2hVB4rAejjqRkA6LYLp
 w6VY7ZlVsvh62gvHCCFXKqbaaStiEFRe833jE4vIoCWo4m5BfG5KaYv/tYf0w5Fx/DIy
 +aLTs8HcBLgpgOrsxQf06H85GyUWAmColJpWEtJWGGBmAAbn/O30q8qTicZuL1wOdzAu
 6wEPp35ZnzzZuUrTP0Jc3oyGY5+G6nVAndZI1pdHL9xdP33v5cLnEOw4CghoeO7zZhq2
 4AIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=SYKa1nrEaZaYwZ8wYDMo+wGBRjI8YKJTKmH+OljJTGg=;
 b=SnqXZr8sbsx5cx9Rt+p5lhZ7XhyBX++1vTtEphu8Yc0iFG848HLhNMHk50hUwGqeUx
 SMhwygnaPX15CGrzCXzPq+CnhrD9gWEQVYZAl406t8cFOxYidQ5BJsAyl1heDj7xR28Y
 TUitymmRpcfKUBdivPUJbOxp6z4VdqEuvgL8UGtSeG8X4/ug7o0okDYVKGcTAE9sN5PW
 T4w8CMdY9XlBeaHNT4E1ArP5rIfebs0CKk+L/8abAVpaLpx8ayK2fcuGlUs5unt5deHT
 Kt2ztZpM2qS53aiN3dF6OkC6c3stFGc3gTriGJZw9+YwYCP1+Fk6s+ArLHXw38vxRAET
 0JxA==
X-Gm-Message-State: AOAM530y8m4wQ0uFXbSq/YuTkhAGro6dGGMpP7s6sHbnuOkfUFOjNQc6
 SPkSg0qiPELlY08g0f/dpqorDjvXrnbTPg==
X-Google-Smtp-Source: ABdhPJw93P0CEj705d5glXmkVMQsX8sYT2IX/Jed8l510hczs05iqHmTLAVyEZ8XcvX8Qih/ulIHbQ==
X-Received: by 2002:a6b:be44:: with SMTP id o65mr3036720iof.53.1600949214929; 
 Thu, 24 Sep 2020 05:06:54 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id a23sm1259435ioc.54.2020.09.24.05.06.53
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:06:54 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp 4/6] seccomp/cache: Lookup syscall allowlist for fast
 path
Date: Thu, 24 Sep 2020 07:06:44 -0500
Message-Id: <6c754a336aef916e3a69af8b8b47834317f4dc60.1600946701.git.yifeifz2@illinois.edu>
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

The fast (common) path for seccomp should be that the filter permits
the syscall to pass through, and failing seccomp is expected to be
an exceptional case; it is not expected for userspace to call a
denylisted syscall over and over.

This first finds the current allow bitmask by iterating through
syscall_arches[] array and comparing it to the one in struct
seccomp_data; this loop is expected to be unrolled. It then
does a test_bit against the bitmask. If the bit is set, then
there is no need to run the full filter; it returns
SECCOMP_RET_ALLOW immediately.

Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 kernel/seccomp.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 7c286d66f983..5b1bd8329e9c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -167,6 +167,12 @@ static inline void seccomp_cache_inherit(struct seccomp_filter *sfilter,
 					 const struct seccomp_filter *prev)
 {
 }
+
+static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,
+				       const struct seccomp_data *sd)
+{
+	return false;
+}
 #endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
 
 /**
@@ -321,6 +327,34 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
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
+	int syscall_nr = sd->nr;
+	int arch;
+
+	if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
+		return false;
+
+	for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
+		if (likely(syscall_arches[arch] == sd->arch))
+			return test_bit(syscall_nr,
+					sfilter->cache.syscall_ok[arch]);
+	}
+
+	WARN_ON_ONCE(true);
+	return false;
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_run_filters - evaluates all seccomp filters against @sd
  * @sd: optional seccomp data to be passed to filters
@@ -343,6 +377,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
 	if (WARN_ON(f == NULL))
 		return SECCOMP_RET_KILL_PROCESS;
 
+	if (seccomp_cache_check(f, sd))
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
