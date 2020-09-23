Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00A5DC4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A606620BED
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="TIMKD+uY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A606620BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5C87887423;
	Wed, 23 Sep 2020 23:29:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EUnTXjT7HKMn; Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A307A873CA;
	Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9127CC0889;
	Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 08ECDC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E8F1F86A5C
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tH5k5klFCQir
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com
 [209.85.214.193])
 by whitealder.osuosl.org (Postfix) with ESMTPS id D120786A4E
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:29 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id y17so578318plb.6
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:29:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=3tjQcJgxkky4Q5tL6fI5yShZ9VEKJUWBe4Oa7zhVXG8=;
 b=TIMKD+uYvr1YdPLTyJHHVcZYjQEqHy0tYbelapcjRZOHTZmAY0natT6ajDzivxjqj0
 d299ZNX8bo0prRnqHPaoQWmTB3QxOMSQUltgTLVgC9Q6lPVc3huZ3ArX+ynawPF0/Q14
 qzbrM9jQOYsMsxWgjCGVivEWrJHkrGpS1EtOY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=3tjQcJgxkky4Q5tL6fI5yShZ9VEKJUWBe4Oa7zhVXG8=;
 b=JB2oJvhCj7vH8TdAjXiqFPcIt5GqIlQQ2ZQ/Y03NT+zAjAW+/2dRj4QkWhoc1j23HY
 5PqC1w2HSZO7KLkqVeXxwaHFQ5U5igzl9e4jUylU6/UKpFSCcuMuf7I6ZTckoqeGpM5V
 iYZ6TfZauTUMLw/4Lf8v/L8VGvck3OwjYnA8eVPpu1rPsQ4o9EYeQEgn/LDtofkrIqe0
 dPzKt1xqL9+kkBpn7cirwtdGwCucuACN3caYeXFVt/rOLTo1OnmkQRUYtZrKCoRqNxmU
 EF6ptaOH8ybwqVhHj1fROVhQP6sJM0mmRKd/xQ0ROCiD9GRVk0ko2eJUeDz4lCc5EUMu
 uBBQ==
X-Gm-Message-State: AOAM530dJOn+Ie1gvQck1As1l2sDy3AC6U/axqqggRJs8A+TqM7H/jx9
 wFcBaVz7w0LL2D4qwaYpctNbmA==
X-Google-Smtp-Source: ABdhPJzLUGIsXfVbpAr9Ol7X8IFNcdiV/Cvmi2IKpWqmpxO2CSLDl74T/4D2rNKxV1OQwP7WhREFXQ==
X-Received: by 2002:a17:90a:6848:: with SMTP id
 e8mr1361792pjm.221.1600903769404; 
 Wed, 23 Sep 2020 16:29:29 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id j13sm492649pjn.14.2020.09.23.16.29.26
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 16:29:26 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: [PATCH 1/6] seccomp: Introduce SECCOMP_PIN_ARCHITECTURE
Date: Wed, 23 Sep 2020 16:29:18 -0700
Message-Id: <20200923232923.3142503-2-keescook@chromium.org>
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

For systems that provide multiple syscall maps based on audit
architectures (e.g. AUDIT_ARCH_X86_64 and AUDIT_ARCH_I386 via
CONFIG_COMPAT) or via syscall masks (e.g. x86_x32), allow a fast way
to pin the process to a specific syscall table, instead of needing
to generate all filters with an architecture check as the first filter
action.

This creates the internal representation that seccomp itself can use
(which is separate from the filters, which need to stay runtime
agnostic). Additionally paves the way for constant-action bitmaps.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/seccomp.h                       |  9 +++
 include/uapi/linux/seccomp.h                  |  1 +
 kernel/seccomp.c                              | 79 ++++++++++++++++++-
 tools/testing/selftests/seccomp/seccomp_bpf.c | 33 ++++++++
 4 files changed, 120 insertions(+), 2 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 02aef2844c38..0be20bc81ea9 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -20,12 +20,18 @@
 #include <linux/atomic.h>
 #include <asm/seccomp.h>
 
+#define SECCOMP_ARCH_IS_NATIVE		1
+#define SECCOMP_ARCH_IS_COMPAT		2
+#define SECCOMP_ARCH_IS_MULTIPLEX	3
+#define SECCOMP_ARCH_IS_UNKNOWN		0xff
+
 struct seccomp_filter;
 /**
  * struct seccomp - the state of a seccomp'ed process
  *
  * @mode:  indicates one of the valid values above for controlled
  *         system calls available to a process.
+ * @arch: seccomp's internal architecture identifier (not seccomp_data->arch)
  * @filter: must always point to a valid seccomp-filter or NULL as it is
  *          accessed without locking during system call entry.
  *
@@ -34,6 +40,9 @@ struct seccomp_filter;
  */
 struct seccomp {
 	int mode;
+#ifdef SECCOMP_ARCH
+	u8 arch;
+#endif
 	atomic_t filter_count;
 	struct seccomp_filter *filter;
 };
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 6ba18b82a02e..f4d134ebfa7e 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -16,6 +16,7 @@
 #define SECCOMP_SET_MODE_FILTER		1
 #define SECCOMP_GET_ACTION_AVAIL	2
 #define SECCOMP_GET_NOTIF_SIZES		3
+#define SECCOMP_PIN_ARCHITECTURE	4
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC		(1UL << 0)
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index ae6b40cc39f4..0a3ff8eb8aea 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -298,6 +298,47 @@ static int seccomp_check_filter(struct sock_filter *filter, unsigned int flen)
 	return 0;
 }
 
+#ifdef SECCOMP_ARCH
+static inline u8 seccomp_get_arch(u32 syscall_arch, u32 syscall_nr)
+{
+	u8 seccomp_arch;
+
+	switch (syscall_arch) {
+	case SECCOMP_ARCH:
+		seccomp_arch = SECCOMP_ARCH_IS_NATIVE;
+		break;
+#ifdef CONFIG_COMPAT
+	case SECCOMP_ARCH_COMPAT:
+		seccomp_arch = SECCOMP_ARCH_IS_COMPAT;
+		break;
+#endif
+	default:
+		seccomp_arch = SECCOMP_ARCH_IS_UNKNOWN;
+	}
+
+#ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
+	if (syscall_arch == SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH) {
+		seccomp_arch |= (sd->nr & SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK) >>
+				SECCOMP_MULTIPLEXED_SYSCALL_TABLE_SHIFT;
+	}
+#endif
+
+	return seccomp_arch;
+}
+#endif
+
+static inline bool seccomp_arch_mismatch(struct seccomp *seccomp,
+					 const struct seccomp_data *sd)
+{
+#ifdef SECCOMP_ARCH
+	/* Block mismatched architectures. */
+	if (seccomp->arch && seccomp->arch != seccomp_get_arch(sd->arch, sd->nr))
+		return true;
+#endif
+
+	return false;
+}
+
 /**
  * seccomp_run_filters - evaluates all seccomp filters against @sd
  * @sd: optional seccomp data to be passed to filters
@@ -312,9 +353,14 @@ static u32 seccomp_run_filters(const struct seccomp_data *sd,
 			       struct seccomp_filter **match)
 {
 	u32 ret = SECCOMP_RET_ALLOW;
+	struct seccomp_filter *f;
+	struct seccomp *seccomp = &current->seccomp;
+
+	if (seccomp_arch_mismatch(seccomp, sd))
+		return SECCOMP_RET_KILL_PROCESS;
+
 	/* Make sure cross-thread synced filter points somewhere sane. */
-	struct seccomp_filter *f =
-			READ_ONCE(current->seccomp.filter);
+	f = READ_ONCE(seccomp->filter);
 
 	/* Ensure unexpected behavior doesn't result in failing open. */
 	if (WARN_ON(f == NULL))
@@ -522,6 +568,11 @@ static inline void seccomp_sync_threads(unsigned long flags)
 		if (task_no_new_privs(caller))
 			task_set_no_new_privs(thread);
 
+#ifdef SECCOMP_ARCH
+		/* Copy any pinned architecture. */
+		thread->seccomp.arch = caller->seccomp.arch;
+#endif
+
 		/*
 		 * Opt the other thread into seccomp if needed.
 		 * As threads are considered to be trust-realm
@@ -1652,6 +1703,23 @@ static long seccomp_get_notif_sizes(void __user *usizes)
 	return 0;
 }
 
+static long seccomp_pin_architecture(void)
+{
+#ifdef SECCOMP_ARCH
+	struct task_struct *task = current;
+
+	u8 arch = seccomp_get_arch(syscall_get_arch(task),
+				   syscall_get_nr(task, task_pt_regs(task)));
+
+	/* How did you even get here? */
+	if (task->seccomp.arch && task->seccomp.arch != arch)
+		return -EBUSY;
+
+	task->seccomp.arch = arch;
+#endif
+	return 0;
+}
+
 /* Common entry point for both prctl and syscall. */
 static long do_seccomp(unsigned int op, unsigned int flags,
 		       void __user *uargs)
@@ -1673,6 +1741,13 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 			return -EINVAL;
 
 		return seccomp_get_notif_sizes(uargs);
+	case SECCOMP_PIN_ARCHITECTURE:
+		if (flags != 0)
+			return -EINVAL;
+		if (uargs != NULL)
+			return -EINVAL;
+
+		return seccomp_pin_architecture();
 	default:
 		return -EINVAL;
 	}
diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 9c398768553b..d90551e0385e 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -157,6 +157,10 @@ struct seccomp_data {
 #define SECCOMP_GET_NOTIF_SIZES 3
 #endif
 
+#ifndef SECCOMP_PIN_ARCHITECTURE
+#define SECCOMP_PIN_ARCHITECTURE 4
+#endif
+
 #ifndef SECCOMP_FILTER_FLAG_TSYNC
 #define SECCOMP_FILTER_FLAG_TSYNC (1UL << 0)
 #endif
@@ -2221,6 +2225,35 @@ TEST_F_SIGNAL(TRACE_syscall, kill_after, SIGSYS)
 	EXPECT_NE(self->mypid, syscall(__NR_getpid));
 }
 
+TEST(seccomp_architecture_pin)
+{
+	long ret;
+
+	ret = seccomp(SECCOMP_PIN_ARCHITECTURE, 0, NULL);
+	ASSERT_EQ(0, ret) {
+		TH_LOG("Kernel does not support SECCOMP_PIN_ARCHITECTURE!");
+	}
+
+	/* Make sure unexpected arguments are rejected. */
+	ret = seccomp(SECCOMP_PIN_ARCHITECTURE, 1, NULL);
+	ASSERT_EQ(-1, ret);
+	EXPECT_EQ(EINVAL, errno) {
+		TH_LOG("Did not reject SECCOMP_PIN_ARCHITECTURE with flags!");
+	}
+
+	ret = seccomp(SECCOMP_PIN_ARCHITECTURE, 0, &ret);
+	ASSERT_EQ(-1, ret);
+	EXPECT_EQ(EINVAL, errno) {
+		TH_LOG("Did not reject SECCOMP_PIN_ARCHITECTURE with address!");
+	}
+
+	ret = seccomp(SECCOMP_PIN_ARCHITECTURE, 1, &ret);
+	ASSERT_EQ(-1, ret);
+	EXPECT_EQ(EINVAL, errno) {
+		TH_LOG("Did not reject SECCOMP_PIN_ARCHITECTURE with flags and address!");
+	}
+}
+
 TEST(seccomp_syscall)
 {
 	struct sock_filter filter[] = {
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
