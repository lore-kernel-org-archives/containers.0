Return-Path: <SRS0=9Mj4=GN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABF09C433E0
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5359B2242A
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5359B2242A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 328378672A;
	Sun, 10 Jan 2021 17:42:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id laG4dymHzjdp; Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 610AB86769;
	Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4CEFCC1E70;
	Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id EF430C088B
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:46 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id DE18F86750
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 76TkJJ0wxPxg
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:45 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by whitealder.osuosl.org (Postfix) with ESMTP id 8CB5E86723
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:45 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id CB9FB20887;
 Sun, 10 Jan 2021 17:34:35 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v2 0/8] Count rlimits in each user namespace
Date: Sun, 10 Jan 2021 18:33:39 +0100
Message-Id: <cover.1610299857.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
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

Preface
-------
These patches are for binding the rlimit counters to a user in user namespace.
This patch set can be applied on top of:

git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git v5.11-rc2

Problem
-------
Some rlimits are set per user: RLIMIT_NPROC, RLIMIT_MEMLOCK, RLIMIT_SIGPENDING,
RLIMIT_MSGQUEUE. When several containers are created from one user then
the processes inside the containers influence each other.

Eric W. Biederman mentioned this issue [1][2][3].

For example, there are two containers (A and B) created by one user. The
container A sets RLIMIT_NPROC=1 and starts one process. Everything is fine, but
when container B tries to do the same it will fail because the number of
processes is counted globally for each user and user has one process already.

On the other hand, we cannot simply calculate the rlimits for each container
separately. This will lead to the fact that the user creating a new user
namespace can create a fork bomb.

Introduced changes
------------------
To address the problem, we bind rlimit counters to each user namespace. The
result is a tree of rlimit counters with the biggest value at the root (aka
init_user_ns). The rlimit counter increment/decrement occurs in the current and
all parent user namespaces.

ToDo
----
* No documentation.
* No tests.

[1] https://lore.kernel.org/containers/87imd2incs.fsf@x220.int.ebiederm.org/
[2] https://lists.linuxfoundation.org/pipermail/containers/2020-August/042096.html
[3] https://lists.linuxfoundation.org/pipermail/containers/2020-October/042524.html

Changelog
---------
v2:
* RLIMIT_MEMLOCK, RLIMIT_SIGPENDING and RLIMIT_MSGQUEUE are migrated to ucounts.
* Added ucounts for pair uid and user namespace into cred.
* Added the ability to increase ucount by more than 1.

v1:
* After discussion with Eric W. Biederman, I increased the size of ucounts to
  atomic_long_t.
* Added ucount_max to avoid the fork bomb.

--

Alexey Gladkov (8):
  Use atomic type for ucounts reference counting
  Add a reference to ucounts for each user
  Increase size of ucounts to atomic_long_t
  Move RLIMIT_NPROC counter to ucounts
  Move RLIMIT_MSGQUEUE counter to ucounts
  Move RLIMIT_SIGPENDING counter to ucounts
  Move RLIMIT_MEMLOCK counter to ucounts
  Move RLIMIT_NPROC check to the place where we increment the counter

 fs/exec.c                      |  2 +-
 fs/hugetlbfs/inode.c           | 17 +++---
 fs/io-wq.c                     | 22 ++++----
 fs/io-wq.h                     |  2 +-
 fs/io_uring.c                  |  2 +-
 fs/proc/array.c                |  2 +-
 include/linux/cred.h           |  3 ++
 include/linux/hugetlb.h        |  3 +-
 include/linux/mm.h             |  4 +-
 include/linux/sched/user.h     |  6 ---
 include/linux/shmem_fs.h       |  2 +-
 include/linux/signal_types.h   |  4 +-
 include/linux/user_namespace.h | 31 +++++++++--
 ipc/mqueue.c                   | 29 +++++-----
 ipc/shm.c                      | 31 ++++++-----
 kernel/cred.c                  | 43 +++++++++++----
 kernel/exit.c                  |  2 +-
 kernel/fork.c                  | 12 +++--
 kernel/signal.c                | 53 ++++++++----------
 kernel/sys.c                   | 13 -----
 kernel/ucount.c                | 99 +++++++++++++++++++++++++++++-----
 kernel/user.c                  |  2 -
 kernel/user_namespace.c        |  7 ++-
 mm/memfd.c                     |  4 +-
 mm/mlock.c                     | 35 +++++-------
 mm/mmap.c                      |  3 +-
 mm/shmem.c                     |  8 +--
 27 files changed, 268 insertions(+), 173 deletions(-)

-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
