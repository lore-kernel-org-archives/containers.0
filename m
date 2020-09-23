Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ABCBC4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:35 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 41AD120BED
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 23:29:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bfAu8zmg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41AD120BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 87ED786A63;
	Wed, 23 Sep 2020 23:29:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rG-Nv6NvbWfA; Wed, 23 Sep 2020 23:29:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id BB41686A6A;
	Wed, 23 Sep 2020 23:29:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A8D2BC0889;
	Wed, 23 Sep 2020 23:29:33 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 237C1C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 13C75844B2
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2dGA9S-UCAgx
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 7110B84489
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:29:31 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id s19so590472plp.3
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 16:29:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=ZE/79qG6H6lRxtOX3Wkl7bfi0pnZJM8pQYKGylI4ASw=;
 b=bfAu8zmgfDT6BYa5AFuGjf5HULT1RoGX5U1MHYBaJnsDPZIqHGceGVjIq0QrWYsXIN
 1nBIJcYwVXI/M/1TjzCxBqSwMVufR5fhXA7ESw3zg0MsBcR9YmbOnfl/dmqa5ZQdhGUH
 ueFBHPnxoz7qOSdPu1rvnb8vHu9CQAEMJn3Nk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=ZE/79qG6H6lRxtOX3Wkl7bfi0pnZJM8pQYKGylI4ASw=;
 b=c+oGZRk8SsrDg+fpx8fBRBe0F/kKZHkNU9ykerEqUTMejcMNM8ou1c0sodv0ne5vN3
 ZRV8j1L1kmh7GINZ+2sWJ7NdA/599jJ3aNTEX3lnY0+T0wN3hxm7KiqQZR5vi40jDZ6/
 gJo4DJsjR7LC/cfGdqJGHUyNzi3OEhHI+lNY7LaaEYhV95G1Kdd/v/YFc+09RLt/Pzn2
 AixcgjaclKdFkuj6BCCtPZk+piN6gHDcZGyuAolShvAYqHDe+41i+nFbysxD0AgQGgDa
 PWr7u1isil2KDgp6PW3WgeI/W/nmEkfFeg0I6QGDs4lRumC5k1/8xftZgJqIRWW5965L
 gYVw==
X-Gm-Message-State: AOAM532ytukhK82B3zLM7kQZDaG2OWuXAXKT3229YuQ9S2rtcQDqJ3fC
 q7NIvUNfmagZIoKbhYEuZTVq2w==
X-Google-Smtp-Source: ABdhPJwhKgUZq608+q5NwYON4+CAPcXtEBNdHupkMvWVr63aqwYCkQW/0sNAogHldmRsrQqXgPaIjA==
X-Received: by 2002:a17:902:c692:b029:d0:90a3:24f4 with SMTP id
 r18-20020a170902c692b02900d090a324f4mr1951226plx.12.1600903771027; 
 Wed, 23 Sep 2020 16:29:31 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id z1sm669570pfj.113.2020.09.23.16.29.27
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 16:29:30 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <yifeifz2@illinois.edu>
Subject: [PATCH 6/6] [DEBUG] seccomp: Report bitmap coverage ranges
Date: Wed, 23 Sep 2020 16:29:23 -0700
Message-Id: <20200923232923.3142503-7-keescook@chromium.org>
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

This is what I've been using to explore actual bitmap results for
real-world filters...

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 kernel/seccomp.c | 115 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 115 insertions(+)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 9921f6f39d12..1a0595d7f8ef 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -835,6 +835,85 @@ static void seccomp_update_bitmap(struct seccomp_filter *filter,
 	}
 }
 
+static void __report_bitmap(const char *arch, u32 ret, int start, int finish)
+{
+	int gap;
+	char *name;
+
+	if (finish == -1)
+		return;
+
+	switch (ret) {
+	case UINT_MAX:
+		name = "filter";
+		break;
+	case SECCOMP_RET_ALLOW:
+		name = "SECCOMP_RET_ALLOW";
+		break;
+	case SECCOMP_RET_KILL_PROCESS:
+		name = "SECCOMP_RET_KILL_PROCESS";
+		break;
+	case SECCOMP_RET_KILL_THREAD:
+		name = "SECCOMP_RET_KILL_THREAD";
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		name = "unknown";
+		break;
+	}
+
+	gap = 0;
+	if (start < 100)
+		gap++;
+	if (start < 10)
+		gap++;
+	if (finish < 100)
+		gap++;
+	if (finish < 10)
+		gap++;
+
+	if (start == finish)
+		pr_info("%s     %3d: %s\n", arch, start, name);
+	else if (start + 1 == finish)
+		pr_info("%s %*s%d,%d: %s\n", arch, gap, "", start, finish, name);
+	else
+		pr_info("%s %*s%d-%d: %s\n", arch, gap, "", start, finish, name);
+}
+
+static void report_bitmap(struct seccomp_bitmaps *bitmaps, const char *arch)
+{
+	u32 nr;
+	int start = 0, finish = -1;
+	u32 ret = UINT_MAX;
+	struct report_states {
+		unsigned long *bitmap;
+		u32 ret;
+	} states[] = {
+		{ .bitmap = bitmaps->allow,	   .ret = SECCOMP_RET_ALLOW, },
+		{ .bitmap = bitmaps->kill_process, .ret = SECCOMP_RET_KILL_PROCESS, },
+		{ .bitmap = bitmaps->kill_thread,  .ret = SECCOMP_RET_KILL_THREAD, },
+		{ .bitmap = NULL,		   .ret = UINT_MAX, },
+	};
+
+	for (nr = 0; nr < NR_syscalls; nr++) {
+		int i;
+
+		for (i = 0; i < ARRAY_SIZE(states); i++) {
+			if (!states[i].bitmap || test_bit(nr, states[i].bitmap)) {
+				if (ret != states[i].ret) {
+					__report_bitmap(arch, ret, start, finish);
+					ret = states[i].ret;
+					start = nr;
+				}
+				finish = nr;
+				break;
+			}
+		}
+	}
+	if (start != nr)
+		__report_bitmap(arch, ret, start, finish);
+}
+
 static void seccomp_update_bitmaps(struct seccomp_filter *filter,
 				   void *pagepair)
 {
@@ -849,6 +928,23 @@ static void seccomp_update_bitmaps(struct seccomp_filter *filter,
 			      SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK,
 			      &current->seccomp.multiplex);
 #endif
+	if (strncmp(current->comm, "test-", 5) == 0 ||
+	    strcmp(current->comm, "seccomp_bpf") == 0 ||
+	    /*
+	     * Why are systemd's process names head-truncated to 8 bytes
+	     * and wrapped in parens!?
+	     */
+	    (current->comm[0] == '(' && strrchr(current->comm, ')') != NULL)) {
+		pr_info("reporting syscall bitmap usage for %d (%s):\n",
+			task_pid_nr(current), current->comm);
+		report_bitmap(&current->seccomp.native, "native");
+#ifdef CONFIG_COMPAT
+		report_bitmap(&current->seccomp.compat, "compat");
+#endif
+#ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
+		report_bitmap(&current->seccomp.multiplex, "multiplex");
+#endif
+	}
 }
 #else
 static void seccomp_update_bitmaps(struct seccomp_filter *filter,
@@ -908,6 +1004,10 @@ static long seccomp_attach_filter(unsigned int flags,
 	filter->prev = current->seccomp.filter;
 	current->seccomp.filter = filter;
 	atomic_inc(&current->seccomp.filter_count);
+	if (atomic_read(&current->seccomp.filter_count) > 10)
+		pr_info("%d filters: %d (%s)\n",
+			atomic_read(&current->seccomp.filter_count),
+			task_pid_nr(current), current->comm);
 
 	/* Evaluate filter for new known-outcome syscalls */
 	seccomp_update_bitmaps(filter, pagepair);
@@ -2419,6 +2519,21 @@ static int __init seccomp_sysctl_init(void)
 		pr_warn("sysctl registration failed\n");
 	else
 		kmemleak_not_leak(hdr);
+#ifndef SECCOMP_ARCH
+	pr_info("arch lacks support for constant action bitmaps\n");
+#else
+	pr_info("NR_syscalls: %d\n", NR_syscalls);
+	pr_info("arch: 0x%x\n", SECCOMP_ARCH);
+#ifdef CONFIG_COMPAT
+	pr_info("compat arch: 0x%x\n", SECCOMP_ARCH_COMPAT);
+#endif
+#ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
+	pr_info("multiplex arch: 0x%x (mask: 0x%x)\n",
+		SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH,
+		SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK);
+#endif
+#endif
+	pr_info("sizeof(struct seccomp_bitmaps): %zu\n", sizeof(struct seccomp_bitmaps));
 
 	return 0;
 }
-- 
2.25.1

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
