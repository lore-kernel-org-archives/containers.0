Return-Path: <SRS0=Tc9O=GZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20EB0C433E6
	for <containers@archiver.kernel.org>; Fri, 22 Jan 2021 13:01:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A90F9235F7
	for <containers@archiver.kernel.org>; Fri, 22 Jan 2021 13:01:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A90F9235F7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 42B71870AC;
	Fri, 22 Jan 2021 13:01:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3Rv4PFlZupRm; Fri, 22 Jan 2021 13:00:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id B2DC187092;
	Fri, 22 Jan 2021 13:00:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 980D6C1DA7;
	Fri, 22 Jan 2021 13:00:58 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3D7B4C088B
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 13:00:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 170B12E0F4
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 13:00:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hgR8gU6fiKzB
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 13:00:55 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by silver.osuosl.org (Postfix) with ESMTP id 464DE2E0F2
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 13:00:55 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-112-41-137.net.upcbroadband.cz [94.112.41.137])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 3500920A1D;
 Fri, 22 Jan 2021 13:00:54 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>, io-uring@vger.kernel.org,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v4 6/7] Move RLIMIT_NPROC check to the place where we
 increment the counter
Date: Fri, 22 Jan 2021 14:00:15 +0100
Message-Id: <f3d4035b4aee52ece0e90606bcb8243a1646c03b.1611320161.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1611320161.git.gladkov.alexey@gmail.com>
References: <cover.1611320161.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Fri, 22 Jan 2021 13:00:54 +0000 (UTC)
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

After calling set_user(), we always have to call commit_creds() to apply
new credentials upon the current task. There is no need to separate
limit check and counter incrementing.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 kernel/cred.c | 22 +++++++++++++++++-----
 kernel/sys.c  | 13 -------------
 2 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index fdb40adc2ebd..334d2c9ae519 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -487,14 +487,26 @@ int commit_creds(struct cred *new)
 	if (!gid_eq(new->fsgid, old->fsgid))
 		key_fsgid_changed(new);
 
-	/* do it
-	 * RLIMIT_NPROC limits on user->processes have already been checked
-	 * in set_user().
-	 */
 	alter_cred_subscribers(new, 2);
 	if (new->user != old->user || new->user_ns != old->user_ns) {
+		bool overlimit;
+
 		set_cred_ucounts(new, new->user_ns, new->euid);
-		inc_rlimit_ucounts(new->ucounts, UCOUNT_RLIMIT_NPROC, 1);
+
+		overlimit = inc_rlimit_ucounts_and_test(new->ucounts, UCOUNT_RLIMIT_NPROC,
+				1, rlimit(RLIMIT_NPROC));
+
+		/*
+		 * We don't fail in case of NPROC limit excess here because too many
+		 * poorly written programs don't check set*uid() return code, assuming
+		 * it never fails if called by root.  We may still enforce NPROC limit
+		 * for programs doing set*uid()+execve() by harmlessly deferring the
+		 * failure to the execve() stage.
+		 */
+		if (overlimit && new->user != INIT_USER)
+			current->flags |= PF_NPROC_EXCEEDED;
+		else
+			current->flags &= ~PF_NPROC_EXCEEDED;
 	}
 	rcu_assign_pointer(task->real_cred, new);
 	rcu_assign_pointer(task->cred, new);
diff --git a/kernel/sys.c b/kernel/sys.c
index c2734ab9474e..180c4e06064f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -467,19 +467,6 @@ static int set_user(struct cred *new)
 	if (!new_user)
 		return -EAGAIN;
 
-	/*
-	 * We don't fail in case of NPROC limit excess here because too many
-	 * poorly written programs don't check set*uid() return code, assuming
-	 * it never fails if called by root.  We may still enforce NPROC limit
-	 * for programs doing set*uid()+execve() by harmlessly deferring the
-	 * failure to the execve() stage.
-	 */
-	if (is_ucounts_overlimit(new->ucounts, UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC)) &&
-			new_user != INIT_USER)
-		current->flags |= PF_NPROC_EXCEEDED;
-	else
-		current->flags &= ~PF_NPROC_EXCEEDED;
-
 	free_uid(new->user);
 	new->user = new_user;
 	return 0;
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
