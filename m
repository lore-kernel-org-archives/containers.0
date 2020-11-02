Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15A01C00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:23 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7D8CF20786
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D8CF20786
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4004987309;
	Mon,  2 Nov 2020 17:01:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pzIuDTcFSUoN; Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A33B3872E5;
	Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 84AAAC088B;
	Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2FB21C0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 13AA286AB6
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id OY6sFRH41vvn
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:19 +0000 (UTC)
X-Greylist: delayed 00:08:47 by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by fraxinus.osuosl.org (Postfix) with ESMTP id C4C5E8688F
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 0DDD420A06;
 Mon,  2 Nov 2020 16:52:30 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v1 1/4] Increase size of ucounts to atomic_long_t
Date: Mon,  2 Nov 2020 17:50:30 +0100
Message-Id: <f3c95ffedbab07f05e0e6e4e5a8bdd6c358194e7.1604335819.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.25.4
In-Reply-To: <cover.1604335819.git.gladkov.alexey@gmail.com>
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 02 Nov 2020 16:52:30 +0000 (UTC)
Cc: Alexey Gladkov <legion@kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Christian Brauner <christian@brauner.io>, Kees Cook <keescook@chromium.org>
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

In order to be able to use ucounts for rlimits, the size must be increased.
For example user_struct.mq_bytes (RLIMIT_MSGQUEUE) is unsigned long.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 include/linux/user_namespace.h |  4 ++--
 kernel/ucount.c                | 14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 6ef1c7109fc4..fc75af812d73 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -86,7 +86,7 @@ struct user_namespace {
 	struct ctl_table_header *sysctls;
 #endif
 	struct ucounts		*ucounts;
-	int ucount_max[UCOUNT_COUNTS];
+	long ucount_max[UCOUNT_COUNTS];
 } __randomize_layout;
 
 struct ucounts {
@@ -94,7 +94,7 @@ struct ucounts {
 	struct user_namespace *ns;
 	kuid_t uid;
 	int count;
-	atomic_t ucount[UCOUNT_COUNTS];
+	atomic_long_t ucount[UCOUNT_COUNTS];
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 11b1596e2542..7b2bca8582ef 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -175,14 +175,14 @@ static void put_ucounts(struct ucounts *ucounts)
 	kfree(ucounts);
 }
 
-static inline bool atomic_inc_below(atomic_t *v, int u)
+static inline bool atomic_long_inc_below(atomic_long_t *v, int u)
 {
-	int c, old;
-	c = atomic_read(v);
+	long c, old;
+	c = atomic_long_read(v);
 	for (;;) {
 		if (unlikely(c >= u))
 			return false;
-		old = atomic_cmpxchg(v, c, c+1);
+		old = atomic_long_cmpxchg(v, c, c+1);
 		if (likely(old == c))
 			return true;
 		c = old;
@@ -199,14 +199,14 @@ struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid,
 		int max;
 		tns = iter->ns;
 		max = READ_ONCE(tns->ucount_max[type]);
-		if (!atomic_inc_below(&iter->ucount[type], max))
+		if (!atomic_long_inc_below(&iter->ucount[type], max))
 			goto fail;
 	}
 	return ucounts;
 fail:
 	bad = iter;
 	for (iter = ucounts; iter != bad; iter = iter->ns->ucounts)
-		atomic_dec(&iter->ucount[type]);
+		atomic_long_dec(&iter->ucount[type]);
 
 	put_ucounts(ucounts);
 	return NULL;
@@ -216,7 +216,7 @@ void dec_ucount(struct ucounts *ucounts, enum ucount_type type)
 {
 	struct ucounts *iter;
 	for (iter = ucounts; iter; iter = iter->ns->ucounts) {
-		int dec = atomic_dec_if_positive(&iter->ucount[type]);
+		int dec = atomic_long_dec_if_positive(&iter->ucount[type]);
 		WARN_ON_ONCE(dec < 0);
 	}
 	put_ucounts(ucounts);
-- 
2.25.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
