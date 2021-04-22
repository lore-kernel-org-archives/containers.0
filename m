Return-Path: <SRS0=hmK5=JT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39CF8C433ED
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 12:27:46 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB1D061467
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 12:27:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB1D061467
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 4D6BC606F7;
	Thu, 22 Apr 2021 12:27:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mbByi_nxP3Fk; Thu, 22 Apr 2021 12:27:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 2978D606BA;
	Thu, 22 Apr 2021 12:27:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0A68AC000F;
	Thu, 22 Apr 2021 12:27:44 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 84D3CC000B
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 746BC83CB6
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=kernel.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Sk68_pwCjttC
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:41 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp1.osuosl.org (Postfix) with ESMTPS id D56B683CB2
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:41 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id CC4D361164;
 Thu, 22 Apr 2021 12:27:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619094461;
 bh=ZxDzUmCaPFarls0Ci9yMZk7qkp2yroU/HJfRz/kxUTg=;
 h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
 b=N4CXRVTKKwlPu+wA5xxyn54vCVFUw/FM7WL/Z+652Dvw7j9CCR6T1RsF8SO5IycoT
 H4VMNdUmY3Y9txN1wg1EY7duGwGMjJ+L9j02XSvJEQWTO2EKO8wJv3PcR4Tbxvgk6E
 1dmAfuZLbpBu3XFyVNfuDfjdKrxT6yz06T/8CNwIm9ft7OeuA7oPIEieLjXpTsqvh9
 uqmYX9xwKD8dFZUvmGuUdIvQ0ZX6LajE1tBJ8P7sbFj6Ukt31aPFbQKRCpShlsvXdm
 xZ79auF9sPe2fOqFCG/5QwzQYFIfy5qcal8oH0k49BU5Yv2Aaa9XiLrhEXKedy4JQL
 hNiy+X30aL6Ww==
From: legion@kernel.org
To: LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v11 3/9] Use atomic_t for ucounts reference counting
Date: Thu, 22 Apr 2021 14:27:10 +0200
Message-Id: <94d1dbecab060a6b116b0a2d1accd8ca1bbb4f5f.1619094428.git.legion@kernel.org>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1619094428.git.legion@kernel.org>
References: <cover.1619094428.git.legion@kernel.org>
MIME-Version: 1.0
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
 Oleg Nesterov <oleg@redhat.com>, "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

From: Alexey Gladkov <legion@kernel.org>

The current implementation of the ucounts reference counter requires the
use of spin_lock. We're going to use get_ucounts() in more performance
critical areas like a handling of RLIMIT_SIGPENDING.

Now we need to use spin_lock only if we want to change the hashtable.

v10:
* Always try to put ucounts in case we cannot increase ucounts->count.
  This will allow to cover the case when all consumers will return
  ucounts at once.

v9:
* Use a negative value to check that the ucounts->count is close to
  overflow.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 include/linux/user_namespace.h |  4 +--
 kernel/ucount.c                | 53 ++++++++++++----------------------
 2 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index f71b5a4a3e74..d84cc2c0b443 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -92,7 +92,7 @@ struct ucounts {
 	struct hlist_node node;
 	struct user_namespace *ns;
 	kuid_t uid;
-	int count;
+	atomic_t count;
 	atomic_long_t ucount[UCOUNT_COUNTS];
 };
 
@@ -104,7 +104,7 @@ void retire_userns_sysctls(struct user_namespace *ns);
 struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
 void dec_ucount(struct ucounts *ucounts, enum ucount_type type);
 struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid);
-struct ucounts *get_ucounts(struct ucounts *ucounts);
+struct ucounts * __must_check get_ucounts(struct ucounts *ucounts);
 void put_ucounts(struct ucounts *ucounts);
 
 #ifdef CONFIG_USER_NS
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 50cc1dfb7d28..365865f368ec 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -11,7 +11,7 @@
 struct ucounts init_ucounts = {
 	.ns    = &init_user_ns,
 	.uid   = GLOBAL_ROOT_UID,
-	.count = 1,
+	.count = ATOMIC_INIT(1),
 };
 
 #define UCOUNTS_HASHTABLE_BITS 10
@@ -139,6 +139,15 @@ static void hlist_add_ucounts(struct ucounts *ucounts)
 	spin_unlock_irq(&ucounts_lock);
 }
 
+struct ucounts *get_ucounts(struct ucounts *ucounts)
+{
+	if (ucounts && atomic_add_negative(1, &ucounts->count)) {
+		put_ucounts(ucounts);
+		ucounts = NULL;
+	}
+	return ucounts;
+}
+
 struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
 {
 	struct hlist_head *hashent = ucounts_hashentry(ns, uid);
@@ -155,7 +164,7 @@ struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
 
 		new->ns = ns;
 		new->uid = uid;
-		new->count = 0;
+		atomic_set(&new->count, 1);
 
 		spin_lock_irq(&ucounts_lock);
 		ucounts = find_ucounts(ns, uid, hashent);
@@ -163,33 +172,12 @@ struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
 			kfree(new);
 		} else {
 			hlist_add_head(&new->node, hashent);
-			ucounts = new;
+			spin_unlock_irq(&ucounts_lock);
+			return new;
 		}
 	}
-	if (ucounts->count == INT_MAX)
-		ucounts = NULL;
-	else
-		ucounts->count += 1;
 	spin_unlock_irq(&ucounts_lock);
-	return ucounts;
-}
-
-struct ucounts *get_ucounts(struct ucounts *ucounts)
-{
-	unsigned long flags;
-
-	if (!ucounts)
-		return NULL;
-
-	spin_lock_irqsave(&ucounts_lock, flags);
-	if (ucounts->count == INT_MAX) {
-		WARN_ONCE(1, "ucounts: counter has reached its maximum value");
-		ucounts = NULL;
-	} else {
-		ucounts->count += 1;
-	}
-	spin_unlock_irqrestore(&ucounts_lock, flags);
-
+	ucounts = get_ucounts(ucounts);
 	return ucounts;
 }
 
@@ -197,15 +185,12 @@ void put_ucounts(struct ucounts *ucounts)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&ucounts_lock, flags);
-	ucounts->count -= 1;
-	if (!ucounts->count)
+	if (atomic_dec_and_test(&ucounts->count)) {
+		spin_lock_irqsave(&ucounts_lock, flags);
 		hlist_del_init(&ucounts->node);
-	else
-		ucounts = NULL;
-	spin_unlock_irqrestore(&ucounts_lock, flags);
-
-	kfree(ucounts);
+		spin_unlock_irqrestore(&ucounts_lock, flags);
+		kfree(ucounts);
+	}
 }
 
 static inline bool atomic_long_inc_below(atomic_long_t *v, int u)
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
