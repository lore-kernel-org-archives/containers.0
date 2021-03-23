Return-Path: <SRS0=cSyT=IV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_RED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FD3EC433C1
	for <containers@archiver.kernel.org>; Tue, 23 Mar 2021 21:00:15 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2E9EE61994
	for <containers@archiver.kernel.org>; Tue, 23 Mar 2021 21:00:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E9EE61994
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 071FD40545;
	Tue, 23 Mar 2021 21:00:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id agem0Tuysxs3; Tue, 23 Mar 2021 21:00:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 4D7144053C;
	Tue, 23 Mar 2021 21:00:13 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 31A77C000F;
	Tue, 23 Mar 2021 21:00:13 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AFE51C000A
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 21:00:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 8CB9460840
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 21:00:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3GvgczEJZSzt
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 21:00:11 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp3.osuosl.org (Postfix) with ESMTP id B22A9606A0
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 21:00:10 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 5945640C92;
 Tue, 23 Mar 2021 21:00:09 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v9 3/8] Use atomic_t for ucounts reference counting
Date: Tue, 23 Mar 2021 21:59:12 +0100
Message-Id: <54956fd06ab4a9938421f345ecf2e1518161cb38.1616533074.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1616533074.git.gladkov.alexey@gmail.com>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [5.9.43.93]); Tue, 23 Mar 2021 21:00:09 +0000 (UTC)
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

The current implementation of the ucounts reference counter requires the
use of spin_lock. We're going to use get_ucounts() in more performance
critical areas like a handling of RLIMIT_SIGPENDING.

Now we need to use spin_lock only if we want to change the hashtable.

v9:
* Use a negative value to check that the ucounts->count is close to
  overflow.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
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
index 50cc1dfb7d28..7bac19bb3f1e 100644
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
+		atomic_dec(&ucounts->count);
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
