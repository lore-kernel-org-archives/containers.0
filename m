Return-Path: <SRS0=9Mj4=GN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FB7BC433DB
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:50 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2D5E62242A
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D5E62242A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B7475867F0;
	Sun, 10 Jan 2021 17:42:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19S5RL-+gkjZ; Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 6689F8676E;
	Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 62D1BC088B;
	Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 28656C013A
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1754185D50
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BgZGi_igKnS0
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:46 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 9971985F94
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:46 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 4B958209FA;
 Sun, 10 Jan 2021 17:34:51 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v2 1/8] Use atomic type for ucounts reference counting
Date: Sun, 10 Jan 2021 18:33:40 +0100
Message-Id: <447547b12bba1894d3f1f79d6408dfc60b219b0c.1610299857.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1610299857.git.gladkov.alexey@gmail.com>
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Sun, 10 Jan 2021 17:34:51 +0000 (UTC)
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>,
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

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 include/linux/user_namespace.h |  2 +-
 kernel/ucount.c                | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 64cf8ebdc4ec..84fefa9247c4 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -92,7 +92,7 @@ struct ucounts {
 	struct hlist_node node;
 	struct user_namespace *ns;
 	kuid_t uid;
-	int count;
+	atomic_t count;
 	atomic_t ucount[UCOUNT_COUNTS];
 };
 
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 11b1596e2542..0f2c7c11df19 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -141,7 +141,8 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
 
 		new->ns = ns;
 		new->uid = uid;
-		new->count = 0;
+
+		atomic_set(&new->count, 0);
 
 		spin_lock_irq(&ucounts_lock);
 		ucounts = find_ucounts(ns, uid, hashent);
@@ -152,10 +153,10 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
 			ucounts = new;
 		}
 	}
-	if (ucounts->count == INT_MAX)
+	if (atomic_read(&ucounts->count) == INT_MAX)
 		ucounts = NULL;
 	else
-		ucounts->count += 1;
+		atomic_inc(&ucounts->count);
 	spin_unlock_irq(&ucounts_lock);
 	return ucounts;
 }
@@ -165,8 +166,7 @@ static void put_ucounts(struct ucounts *ucounts)
 	unsigned long flags;
 
 	spin_lock_irqsave(&ucounts_lock, flags);
-	ucounts->count -= 1;
-	if (!ucounts->count)
+	if (atomic_dec_and_test(&ucounts->count))
 		hlist_del_init(&ucounts->node);
 	else
 		ucounts = NULL;
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
