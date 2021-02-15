Return-Path: <SRS0=rdDx=HR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55D92C433E9
	for <containers@archiver.kernel.org>; Mon, 15 Feb 2021 12:42:50 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F1B8C64DF4
	for <containers@archiver.kernel.org>; Mon, 15 Feb 2021 12:42:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1B8C64DF4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id B437D6F522
	for <containers@archiver.kernel.org>; Mon, 15 Feb 2021 12:42:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 93Pu5Ld2qwLj for <containers@archiver.kernel.org>;
	Mon, 15 Feb 2021 12:42:48 +0000 (UTC)
Received: by smtp3.osuosl.org (Postfix, from userid 1001)
	id E1D9E6F4B9; Mon, 15 Feb 2021 12:42:47 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 9B5DA6F4E9;
	Mon, 15 Feb 2021 12:42:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 59B12C1DA0;
	Mon, 15 Feb 2021 12:42:45 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F057AC013A
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Feb 2021 12:42:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id ED318847B3
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Feb 2021 12:42:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3K2UCss-orp6
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Feb 2021 12:42:44 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1883D84828
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Feb 2021 12:42:44 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 0416220A1D;
 Mon, 15 Feb 2021 12:42:42 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>, io-uring@vger.kernel.org,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v6 4/7] Reimplement RLIMIT_MSGQUEUE on top of ucounts
Date: Mon, 15 Feb 2021 13:41:11 +0100
Message-Id: <8a3c7bc4c0f45d9b8313ef395f3fa180eef01d67.1613392826.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1613392826.git.gladkov.alexey@gmail.com>
References: <cover.1613392826.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 15 Feb 2021 12:42:43 +0000 (UTC)
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

The rlimit counter is tied to uid in the user_namespace. This allows
rlimit values to be specified in userns even if they are already
globally exceeded by the user. However, the value of the previous
user_namespaces cannot be exceeded.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 include/linux/sched/user.h     |  4 ----
 include/linux/user_namespace.h |  1 +
 ipc/mqueue.c                   | 29 +++++++++++++++--------------
 kernel/fork.c                  |  1 +
 kernel/ucount.c                |  1 +
 kernel/user_namespace.c        |  1 +
 6 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index d33d867ad6c1..8a34446681aa 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -18,10 +18,6 @@ struct user_struct {
 #endif
 #ifdef CONFIG_EPOLL
 	atomic_long_t epoll_watches; /* The number of file descriptors currently watched */
-#endif
-#ifdef CONFIG_POSIX_MQUEUE
-	/* protected by mq_lock	*/
-	unsigned long mq_bytes;	/* How many bytes can be allocated to mqueue? */
 #endif
 	unsigned long locked_shm; /* How many pages of mlocked shm ? */
 	unsigned long unix_inflight;	/* How many files in flight in unix sockets */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 0a27cd049404..52453143fe23 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -51,6 +51,7 @@ enum ucount_type {
 	UCOUNT_INOTIFY_WATCHES,
 #endif
 	UCOUNT_RLIMIT_NPROC,
+	UCOUNT_RLIMIT_MSGQUEUE,
 	UCOUNT_COUNTS,
 };
 
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index beff0cfcd1e8..05fcf067131f 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -144,7 +144,7 @@ struct mqueue_inode_info {
 	struct pid *notify_owner;
 	u32 notify_self_exec_id;
 	struct user_namespace *notify_user_ns;
-	struct user_struct *user;	/* user who created, for accounting */
+	struct ucounts *ucounts;	/* user who created, for accounting */
 	struct sock *notify_sock;
 	struct sk_buff *notify_cookie;
 
@@ -292,7 +292,6 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 		struct ipc_namespace *ipc_ns, umode_t mode,
 		struct mq_attr *attr)
 {
-	struct user_struct *u = current_user();
 	struct inode *inode;
 	int ret = -ENOMEM;
 
@@ -309,6 +308,8 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 	if (S_ISREG(mode)) {
 		struct mqueue_inode_info *info;
 		unsigned long mq_bytes, mq_treesize;
+		struct ucounts *ucounts;
+		bool overlimit;
 
 		inode->i_fop = &mqueue_file_operations;
 		inode->i_size = FILENT_SIZE;
@@ -321,7 +322,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 		info->notify_owner = NULL;
 		info->notify_user_ns = NULL;
 		info->qsize = 0;
-		info->user = NULL;	/* set when all is ok */
+		info->ucounts = NULL;	/* set when all is ok */
 		info->msg_tree = RB_ROOT;
 		info->msg_tree_rightmost = NULL;
 		info->node_cache = NULL;
@@ -371,19 +372,19 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 		if (mq_bytes + mq_treesize < mq_bytes)
 			goto out_inode;
 		mq_bytes += mq_treesize;
+		ucounts = current_ucounts();
 		spin_lock(&mq_lock);
-		if (u->mq_bytes + mq_bytes < u->mq_bytes ||
-		    u->mq_bytes + mq_bytes > rlimit(RLIMIT_MSGQUEUE)) {
+		overlimit = inc_rlimit_ucounts_and_test(ucounts, UCOUNT_RLIMIT_MSGQUEUE,
+				mq_bytes, rlimit(RLIMIT_MSGQUEUE));
+		if (overlimit) {
+			dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_MSGQUEUE, mq_bytes);
 			spin_unlock(&mq_lock);
 			/* mqueue_evict_inode() releases info->messages */
 			ret = -EMFILE;
 			goto out_inode;
 		}
-		u->mq_bytes += mq_bytes;
 		spin_unlock(&mq_lock);
-
-		/* all is ok */
-		info->user = get_uid(u);
+		info->ucounts = get_ucounts(ucounts);
 	} else if (S_ISDIR(mode)) {
 		inc_nlink(inode);
 		/* Some things misbehave if size == 0 on a directory */
@@ -497,7 +498,7 @@ static void mqueue_free_inode(struct inode *inode)
 static void mqueue_evict_inode(struct inode *inode)
 {
 	struct mqueue_inode_info *info;
-	struct user_struct *user;
+	struct ucounts *ucounts;
 	struct ipc_namespace *ipc_ns;
 	struct msg_msg *msg, *nmsg;
 	LIST_HEAD(tmp_msg);
@@ -520,8 +521,8 @@ static void mqueue_evict_inode(struct inode *inode)
 		free_msg(msg);
 	}
 
-	user = info->user;
-	if (user) {
+	ucounts = info->ucounts;
+	if (ucounts) {
 		unsigned long mq_bytes, mq_treesize;
 
 		/* Total amount of bytes accounted for the mqueue */
@@ -533,7 +534,7 @@ static void mqueue_evict_inode(struct inode *inode)
 					  info->attr.mq_msgsize);
 
 		spin_lock(&mq_lock);
-		user->mq_bytes -= mq_bytes;
+		dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_MSGQUEUE, mq_bytes);
 		/*
 		 * get_ns_from_inode() ensures that the
 		 * (ipc_ns = sb->s_fs_info) is either a valid ipc_ns
@@ -543,7 +544,7 @@ static void mqueue_evict_inode(struct inode *inode)
 		if (ipc_ns)
 			ipc_ns->mq_queues_count--;
 		spin_unlock(&mq_lock);
-		free_uid(user);
+		put_ucounts(ucounts);
 	}
 	if (ipc_ns)
 		put_ipc_ns(ipc_ns);
diff --git a/kernel/fork.c b/kernel/fork.c
index 812b023ecdce..0a939332efcc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -823,6 +823,7 @@ void __init fork_init(void)
 		init_user_ns.ucount_max[i] = max_threads/2;
 
 	init_user_ns.ucount_max[UCOUNT_RLIMIT_NPROC] = task_rlimit(&init_task, RLIMIT_NPROC);
+	init_user_ns.ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = task_rlimit(&init_task, RLIMIT_MSGQUEUE);
 
 #ifdef CONFIG_VMAP_STACK
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 2f42d2ee6e27..6fb2ebdef0bc 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -81,6 +81,7 @@ static struct ctl_table user_table[] = {
 	UCOUNT_ENTRY("max_inotify_instances"),
 	UCOUNT_ENTRY("max_inotify_watches"),
 #endif
+	{ },
 	{ },
 	{ }
 };
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 2434b13b02e5..cc90d5203acf 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -122,6 +122,7 @@ int create_user_ns(struct cred *new)
 		ns->ucount_max[i] = INT_MAX;
 	}
 	ns->ucount_max[UCOUNT_RLIMIT_NPROC] = rlimit(RLIMIT_NPROC);
+	ns->ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = rlimit(RLIMIT_MSGQUEUE);
 	ns->ucounts = ucounts;
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
