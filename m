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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFE6AC4727E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:35 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3C2C42071E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WAIVZfAy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C2C42071E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id EC80E871EC;
	Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2oQfMQmnRYxq; Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 696C187216;
	Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 55D32C0890;
	Wed, 30 Sep 2020 15:20:34 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8F150C1AD6
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 76F6D86199
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id RTe-Q1YliYOB
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:33 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com
 [209.85.166.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id DD41A852D5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:20:32 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id g7so2165517iov.13
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 08:20:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=AThlbV8qSIf//EFg3le7/Kv8iNlRjvJHI5D0t9AJZm8=;
 b=WAIVZfAyst0tKhF9rP+a6GZ+1JKCLVToxPDvriVX3CfSR+N3Xd6eMx+ty3tny7GcQX
 Ox0ZwqAzeN9LprFtrND1a43fsROAkb06iKQnUVhQ+6308rCs33JcrgNiXG2E4BXkGOW+
 Da5kBXuylCu+EJnHnu4DodHho0uQsQ7U2CXPjgtT8tRH6nLserbvWx/b7mH6EITU6xCw
 Lj/Unacm/R864IYgL21+F2Zxt4Hm2yc8eW7zsqUI8mj2aXsP0X5XaFl7CZSBcQv/UXDA
 CQmHuaXTcI2lVPGJ6g6+9M/ltyubt8DetU3jMrh1xULbP0DyAtxUbZVjajpdC/5bd7zp
 1EIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=AThlbV8qSIf//EFg3le7/Kv8iNlRjvJHI5D0t9AJZm8=;
 b=QjLOq08OhpuFtIhGGUkUbDbGvbpjJTue9sbh1vFPoIc2Oq5IoBrxWhS6g6oRrv0yBZ
 7uYFhGch1bSbsgPaVzS0pIaCM3dtMvzo5eAJWp2OVi+PtmeOV0dV/C73+9hhhJIEUCxC
 gRk7rbdHjFdm2BQGqa+pIkVohkdMN3OgFVF3NzpBIYdo7u5fWjx9+y82PKLsj0QQfIAu
 0Za1q9ES4O4ii7qQH+V9e9NhUDEhEx46tXdeCt7Ze3Z4UfqPmwM1S6hsHhDR0Qw7l6OI
 LVJS1/XAFJhgSGM6Atbe3eDLEW5ITYhY1sBd+oJ/drXNuh/CAWAOGFE6XY5tTnM9ymCH
 xHYg==
X-Gm-Message-State: AOAM5326xjUktbdl+YhxvRDALNH1nhnXTJPaf21MOauLLn3NzWzbD6rv
 EwE8zo5BMbUfCwUcasPrKzJFFa1yfV18sg==
X-Google-Smtp-Source: ABdhPJzWaCyTch/tKZaigzg6FeIVXvEYSGeGYLTEGOfVr8Nx/Z0PJIexqASFa5s5Jud5vcYxyB44VA==
X-Received: by 2002:a05:6638:da:: with SMTP id
 w26mr2363943jao.137.1601479231865; 
 Wed, 30 Sep 2020 08:20:31 -0700 (PDT)
Received: from localhost.localdomain (ip-99-203-15-156.pools.cgn.spcsdns.net.
 [99.203.15.156])
 by smtp.gmail.com with ESMTPSA id t10sm770788iog.49.2020.09.30.08.20.28
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 08:20:31 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v3 seccomp 3/5] seccomp/cache: Lookup syscall allowlist for
 fast path
Date: Wed, 30 Sep 2020 10:19:14 -0500
Message-Id: <83c72471f9f79fa982508bd4db472686a67b8320.1601478774.git.yifeifz2@illinois.edu>
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
 kernel/seccomp.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index f09c9e74ae05..bed3b2a7f6c8 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -172,6 +172,12 @@ struct seccomp_cache_filter_data { };
 static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
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
@@ -331,6 +337,49 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
 	return 0;
 }
 
+#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
+static bool seccomp_cache_check_bitmap(const void *bitmap, size_t bitmap_size,
+				       int syscall_nr)
+{
+	if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))
+		return false;
+	syscall_nr = array_index_nospec(syscall_nr, bitmap_size);
+
+	return test_bit(syscall_nr, bitmap);
+}
+
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
+	const struct seccomp_cache_filter_data *cache = &sfilter->cache;
+
+#ifdef SECCOMP_ARCH_DEFAULT
+	if (likely(sd->arch == SECCOMP_ARCH_DEFAULT))
+		return seccomp_cache_check_bitmap(cache->syscall_allow_default,
+						  SECCOMP_ARCH_DEFAULT_NR,
+						  syscall_nr);
+#endif /* SECCOMP_ARCH_DEFAULT */
+
+#ifdef SECCOMP_ARCH_COMPAT
+	if (likely(sd->arch == SECCOMP_ARCH_COMPAT))
+		return seccomp_cache_check_bitmap(cache->syscall_allow_compat,
+						  SECCOMP_ARCH_COMPAT_NR,
+						  syscall_nr);
+#endif /* SECCOMP_ARCH_COMPAT */
+
+	WARN_ON_ONCE(true);
+	return false;
+}
+#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
+
 /**
  * seccomp_run_filters - evaluates all seccomp filters against @sd
  * @sd: optional seccomp data to be passed to filters
@@ -353,6 +402,9 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
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
