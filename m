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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 818D4C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:44:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0F3D5206D9
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:44:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="do2eV7gu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F3D5206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id BBEA886A81;
	Thu, 24 Sep 2020 12:44:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oYpZkQ5w7Z3h; Thu, 24 Sep 2020 12:44:49 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id EB13C86B07;
	Thu, 24 Sep 2020 12:44:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D9429C0890;
	Thu, 24 Sep 2020 12:44:48 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 25F6FC0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id E9EB687494
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XSl4Dzk5SpgS
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:45 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f195.google.com (mail-il1-f195.google.com
 [209.85.166.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3742386A9B
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:44:45 +0000 (UTC)
Received: by mail-il1-f195.google.com with SMTP id q4so2981276ils.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:44:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=l5sZSI+cLE2joNnPykw3MJU/gzivLj0GX9Q9hGA5pVs=;
 b=do2eV7guKNVRVckBf3Qfgxpk/b3ON9tjlGe5E57+r1XmL7t/D5Kw5KdZ5uZbhjS1Ff
 QN0OB9vDaxjoBHoNISHtwjZkYjJhcOvuwq7phhDPiFl0X78WFGCOASDBa5khLnQZYNPm
 UiLhV9gs9CCVHZg9bYlt+/5X8Y6AEGDJNTCrkyszULDF1aC+PIjShWf3ODB/iyVwQMtu
 24alqEDxI6BWef3lFhd6g7eQdorBv7AUCIEMY8KsgHMB6dhVngX/5p2+hVZ4MQE2Bmp2
 QylQd+CTvWFDivAicsUJD9I76oXNjqgJzciXs+NXTr1SVYHKYHsW3d4YEtEbl8YvwW7k
 fFlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=l5sZSI+cLE2joNnPykw3MJU/gzivLj0GX9Q9hGA5pVs=;
 b=G5wByt2mVogpgWOTO25eN4BOzdfHjdBF9JOFbxNY/DQOrODPF8iAsauJbaXBKYANjC
 ivK+Qcf1tQPYhK0sCIbVHYXHrhh8F3da3ENoKFv6xMrlAmCSnTMauS4GJgbV8Rgy4Tda
 nliGny6hql+0woYq7wew2GUxsa62l8ls1zEpTCVK6dqhU1kV1IPfzlMLTDmckt/0AF9d
 xYfdGup0uI8qywmduizP0UDtVNH9XdWPZXQ2kc542pQVuXwapZY1NRVla8Z4hz7xkqY4
 EPmT2DBe8lCefnKGC7VRA0n1Ml0F6Panp3F6EAAGKAHURfjo5g0Ye7afEQoeuIYXYh7x
 P4Ug==
X-Gm-Message-State: AOAM532P7NCFjsq+Srm0LuEqHUGS3BstIdjHc7wXTNCqAxgrfAbNFWi5
 +HNr6BL3GICGhFUf6/zy/y8ytKpLp1olwA==
X-Google-Smtp-Source: ABdhPJxpBnD87qzZx6pccGeAQzN1T2pWR8/PeSQiL6zBbati5Zbhu9BAc67rqhD1Wk2L+0muJEHyqg==
X-Received: by 2002:a05:6e02:f48:: with SMTP id
 y8mr3911683ilj.103.1600951484344; 
 Thu, 24 Sep 2020 05:44:44 -0700 (PDT)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id p5sm1575175ilg.32.2020.09.24.05.44.43
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 05:44:43 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH v2 seccomp 4/6] seccomp/cache: Lookup syscall allowlist for
 fast path
Date: Thu, 24 Sep 2020 07:44:19 -0500
Message-Id: <64052a5b81d5dacd63efb577c1d99e6f98e69702.1600951211.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <cover.1600951211.git.yifeifz2@illinois.edu>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
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
index 20d33378a092..ac0266b6d18a 100644
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
