Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C420C388F2
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:23 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BF941222EC
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF941222EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 79BFF86ACD;
	Mon,  2 Nov 2020 17:01:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p1mgEh-Ao1UC; Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id BEE4486A91;
	Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9F2EDC1AD9;
	Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 90684C0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7BBC2868C5
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XaTYrVBF-p8G
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:19 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7DE7E86AEF
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id C2A43209AF;
 Mon,  2 Nov 2020 16:52:27 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v1 0/4] Per user namespace rlimits
Date: Mon,  2 Nov 2020 17:50:29 +0100
Message-Id: <cover.1604335819.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.25.4
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 02 Nov 2020 16:52:29 +0000 (UTC)
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

Preface
-------
These patches are for binding the rlimits to a user in the user namespace.
This patch set can be applied on top of:

git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git v5.8-2-g43e210d68200

Problem
-------
Some rlimits are set per user: RLIMIT_NPROC, RLIMIT_MEMLOCK, RLIMIT_SIGPENDING,
RLIMIT_MSGQUEUE. When several containers are created from one user then
the processes inside the containers influence each other.

Eric W. Biederman mentioned this issue [1][2][3].

Introduced changes
------------------
To fix this problem, you can bind the counter of the specified rlimits to the
user within the user namespace. By default, to preserve backward compatibility,
only the initial user namespace is used. This patch adds one more prctl
parameter to change the binding to the user namespace.

This will not cause the user to take more resources than allowed in the parent
user namespace because it only virtualizes the rlimit counter. Limits in all
parent user namespaces are taken into account.

For example, this allows us to run multiple containers by the same user and
set the RLIMIT_NPROC to 1 inside.

ToDo
----
* RLIMIT_MEMLOCK, RLIMIT_SIGPENDING and RLIMIT_MSGQUEUE are not implemented.
* No documentation.
* No tests.

[1] https://lore.kernel.org/containers/87imd2incs.fsf@x220.int.ebiederm.org/
[2] https://lists.linuxfoundation.org/pipermail/containers/2020-August/042096.html
[3] https://lists.linuxfoundation.org/pipermail/containers/2020-October/042524.html

Changelog
---------
v1:
* After discussion with Eric W. Biederman, I increased the size of ucounts to
  atomic_long_t.
* Added ucount_max to avoid the fork bomb.

--

Alexey Gladkov (4):
  Increase size of ucounts to atomic_long_t
  Move the user's process counter to ucounts
  Do not allow fork if RLIMIT_NPROC is exceeded in the user namespace
    tree
  Allow to change the user namespace in which user rlimits are counted

 fs/exec.c                      | 13 ++++++---
 fs/io-wq.c                     | 25 +++++++++++++-----
 fs/io-wq.h                     |  1 +
 fs/io_uring.c                  |  1 +
 include/linux/cred.h           |  8 ++++++
 include/linux/sched.h          |  3 +++
 include/linux/sched/user.h     |  1 -
 include/linux/user_namespace.h | 12 +++++++--
 include/uapi/linux/prctl.h     |  5 ++++
 kernel/cred.c                  | 44 ++++++++++++++++++++++++-------
 kernel/exit.c                  |  2 +-
 kernel/fork.c                  | 13 ++++++---
 kernel/sys.c                   | 26 ++++++++++++++++--
 kernel/ucount.c                | 48 +++++++++++++++++++++++++++++-----
 kernel/user.c                  |  3 ++-
 kernel/user_namespace.c        |  3 +++
 16 files changed, 171 insertions(+), 37 deletions(-)

-- 
2.25.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
