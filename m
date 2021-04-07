Return-Path: <SRS0=LRkw=JE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62AA8C433ED
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 17:08:53 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 25D2161262
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 17:08:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25D2161262
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id F2DC940646;
	Wed,  7 Apr 2021 17:08:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hMp5iX2CAT_c; Wed,  7 Apr 2021 17:08:52 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 1031E4002B;
	Wed,  7 Apr 2021 17:08:52 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F15BEC000C;
	Wed,  7 Apr 2021 17:08:51 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 051BAC000A
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 3D71984C2F
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id l6vCZ-xn-CCk
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:38 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp1.osuosl.org (Postfix) with ESMTP id 64BFA84C54
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:38 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id AE99F417CD;
 Wed,  7 Apr 2021 17:08:37 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v10 9/9] ucounts: Set ucount_max to the largest positive value
 the type can hold
Date: Wed,  7 Apr 2021 19:08:14 +0200
Message-Id: <bb88ee1d7330370094c58f650020e537baf7eb40.1617814298.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1617814298.git.gladkov.alexey@gmail.com>
References: <cover.1617814298.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [5.9.43.93]); Wed, 07 Apr 2021 17:08:38 +0000 (UTC)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
 Oleg Nesterov <oleg@redhat.com>, "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>
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

The ns->ucount_max[] is signed long which is less than the rlimit size.
We have to protect ucount_max[] from overflow and only use the largest
value that we can hold.

On 32bit using "long" instead of "unsigned long" to hold the counts has
the downside that RLIMIT_MSGQUEUE and RLIMIT_MEMLOCK are limited to 2GiB
instead of 4GiB. I don't think anyone cares but it should be mentioned
in case someone does.

The RLIMIT_NPROC and RLIMIT_SIGPENDING used atomic_t so their maximum
hasn't changed.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 include/linux/user_namespace.h | 6 ++++++
 kernel/fork.c                  | 8 ++++----
 kernel/user_namespace.c        | 8 ++++----
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 82851fba7278..1c778182f5d5 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -123,6 +123,12 @@ bool inc_rlimit_ucounts_and_test(struct ucounts *ucounts, enum ucount_type type,
 void dec_rlimit_ucounts(struct ucounts *ucounts, enum ucount_type type, long v);
 bool is_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, unsigned long max);
 
+static inline void set_rlimit_ucount_max(struct user_namespace *ns,
+		enum ucount_type type, unsigned long max)
+{
+	ns->ucount_max[type] = max <= LONG_MAX ? max : LONG_MAX;
+}
+
 #ifdef CONFIG_USER_NS
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
diff --git a/kernel/fork.c b/kernel/fork.c
index a3a5e317c3c0..2cd01c443196 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -822,10 +822,10 @@ void __init fork_init(void)
 	for (i = 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++)
 		init_user_ns.ucount_max[i] = max_threads/2;
 
-	init_user_ns.ucount_max[UCOUNT_RLIMIT_NPROC] = task_rlimit(&init_task, RLIMIT_NPROC);
-	init_user_ns.ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = task_rlimit(&init_task, RLIMIT_MSGQUEUE);
-	init_user_ns.ucount_max[UCOUNT_RLIMIT_SIGPENDING] = task_rlimit(&init_task, RLIMIT_SIGPENDING);
-	init_user_ns.ucount_max[UCOUNT_RLIMIT_MEMLOCK] = task_rlimit(&init_task, RLIMIT_MEMLOCK);
+	set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_NPROC, task_rlimit(&init_task, RLIMIT_NPROC));
+	set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_MSGQUEUE, task_rlimit(&init_task, RLIMIT_MSGQUEUE));
+	set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_SIGPENDING, task_rlimit(&init_task, RLIMIT_SIGPENDING));
+	set_rlimit_ucount_max(&init_user_ns, UCOUNT_RLIMIT_MEMLOCK, task_rlimit(&init_task, RLIMIT_MEMLOCK));
 
 #ifdef CONFIG_VMAP_STACK
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 5ef0d4b182ba..df7651935fd5 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -121,10 +121,10 @@ int create_user_ns(struct cred *new)
 	for (i = 0; i < MAX_PER_NAMESPACE_UCOUNTS; i++) {
 		ns->ucount_max[i] = INT_MAX;
 	}
-	ns->ucount_max[UCOUNT_RLIMIT_NPROC] = rlimit(RLIMIT_NPROC);
-	ns->ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = rlimit(RLIMIT_MSGQUEUE);
-	ns->ucount_max[UCOUNT_RLIMIT_SIGPENDING] = rlimit(RLIMIT_SIGPENDING);
-	ns->ucount_max[UCOUNT_RLIMIT_MEMLOCK] = rlimit(RLIMIT_MEMLOCK);
+	set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC));
+	set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_MSGQUEUE, rlimit(RLIMIT_MSGQUEUE));
+	set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_SIGPENDING, rlimit(RLIMIT_SIGPENDING));
+	set_rlimit_ucount_max(ns, UCOUNT_RLIMIT_MEMLOCK, rlimit(RLIMIT_MEMLOCK));
 	ns->ucounts = ucounts;
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
