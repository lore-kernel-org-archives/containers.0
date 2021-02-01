Return-Path: <SRS0=98KY=HD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38144C433E6
	for <containers@archiver.kernel.org>; Mon,  1 Feb 2021 14:21:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6DDB764EB8
	for <containers@archiver.kernel.org>; Mon,  1 Feb 2021 14:21:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDB764EB8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1B3F78453B;
	Mon,  1 Feb 2021 14:21:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lW0jTYalOJSs; Mon,  1 Feb 2021 14:21:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5B06C84526;
	Mon,  1 Feb 2021 14:21:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2460FC0174;
	Mon,  1 Feb 2021 14:21:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A652CC013A
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Feb 2021 14:21:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 94F5A84526
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Feb 2021 14:21:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id u0kuYCvjlVaE
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Feb 2021 14:21:00 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 45D3F84462
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Feb 2021 14:21:00 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-112-41-137.net.upcbroadband.cz [94.112.41.137])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 5D65D20A0F;
 Mon,  1 Feb 2021 14:20:38 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>, io-uring@vger.kernel.org,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v5 0/7] Count rlimits in each user namespace
Date: Mon,  1 Feb 2021 15:18:28 +0100
Message-Id: <cover.1612188590.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 01 Feb 2021 14:20:56 +0000 (UTC)
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

Preface
-------
These patches are for binding the rlimit counters to a user in user namespace.
This patch set can be applied on top of:

git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git v5.11-rc2

Problem
-------
The RLIMIT_NPROC, RLIMIT_MEMLOCK, RLIMIT_SIGPENDING, RLIMIT_MSGQUEUE rlimits
implementation places the counters in user_struct [1]. These limits are global
between processes and persists for the lifetime of the process, even if
processes are in different user namespaces.

To illustrate the impact of rlimits, let's say there is a program that does not
fork. Some service-A wants to run this program as user X in multiple containers.
Since the program never fork the service wants to set RLIMIT_NPROC=1.

service-A
 \- program (uid=1000, container1, rlimit_nproc=1)
 \- program (uid=1000, container2, rlimit_nproc=1)

The service-A sets RLIMIT_NPROC=1 and runs the program in container1. When the
service-A tries to run a program with RLIMIT_NPROC=1 in container2 it fails
since user X already has one running process.

The problem is not that the limit from container1 affects container2. The
problem is that limit is verified against the global counter that reflects
the number of processes in all containers.

This problem can be worked around by using different users for each container
but in this case we face a different problem of uid mapping when transferring
files from one container to another.

Eric W. Biederman mentioned this issue [2][3].

Introduced changes
------------------
To address the problem, we bind rlimit counters to user namespace. Each counter
reflects the number of processes in a given uid in a given user namespace. The
result is a tree of rlimit counters with the biggest value at the root (aka
init_user_ns). The limit is considered exceeded if it's exceeded up in the tree.

[1] https://lore.kernel.org/containers/87imd2incs.fsf@x220.int.ebiederm.org/
[2] https://lists.linuxfoundation.org/pipermail/containers/2020-August/042096.html
[3] https://lists.linuxfoundation.org/pipermail/containers/2020-October/042524.html

Changelog
---------
v5:
* Split the first commit into two commits: change ucounts.count type to atomic_long_t
  and add ucounts to cred. These commits were merged by mistake during the rebase.
* The __get_ucounts() renamed to alloc_ucounts().
* The cred.ucounts update has been moved from commit_creds() as it did not allow
  to handle errors.
* Added error handling of set_cred_ucounts().

v4:
* Reverted the type change of ucounts.count to refcount_t.
* Fixed typo in the kernel/cred.c

v3:
* Added get_ucounts() function to increase the reference count. The existing
  get_counts() function renamed to __get_ucounts().
* The type of ucounts.count changed from atomic_t to refcount_t.
* Dropped 'const' from set_cred_ucounts() arguments.
* Fixed a bug with freeing the cred structure after calling cred_alloc_blank().
* Commit messages have been updated.
* Added selftest.

v2:
* RLIMIT_MEMLOCK, RLIMIT_SIGPENDING and RLIMIT_MSGQUEUE are migrated to ucounts.
* Added ucounts for pair uid and user namespace into cred.
* Added the ability to increase ucount by more than 1.

v1:
* After discussion with Eric W. Biederman, I increased the size of ucounts to
  atomic_long_t.
* Added ucount_max to avoid the fork bomb.

--

Alexey Gladkov (7):
  Increase size of ucounts to atomic_long_t
  Add a reference to ucounts for each cred
  Reimplement RLIMIT_NPROC on top of ucounts
  Reimplement RLIMIT_MSGQUEUE on top of ucounts
  Reimplement RLIMIT_SIGPENDING on top of ucounts
  Reimplement RLIMIT_MEMLOCK on top of ucounts
  kselftests: Add test to check for rlimit changes in different user
    namespaces

 fs/exec.c                                     |   6 +-
 fs/hugetlbfs/inode.c                          |  17 +-
 fs/io-wq.c                                    |  22 ++-
 fs/io-wq.h                                    |   2 +-
 fs/io_uring.c                                 |   2 +-
 fs/proc/array.c                               |   2 +-
 include/linux/cred.h                          |   4 +
 include/linux/hugetlb.h                       |   3 +-
 include/linux/mm.h                            |   4 +-
 include/linux/sched/user.h                    |   7 -
 include/linux/shmem_fs.h                      |   2 +-
 include/linux/signal_types.h                  |   4 +-
 include/linux/user_namespace.h                |  23 ++-
 ipc/mqueue.c                                  |  29 ++--
 ipc/shm.c                                     |  31 ++--
 kernel/cred.c                                 |  56 +++++-
 kernel/exit.c                                 |   2 +-
 kernel/fork.c                                 |  18 +-
 kernel/signal.c                               |  53 +++---
 kernel/sys.c                                  |  14 +-
 kernel/ucount.c                               | 105 ++++++++++--
 kernel/user.c                                 |   3 -
 kernel/user_namespace.c                       |   9 +-
 mm/memfd.c                                    |   4 +-
 mm/mlock.c                                    |  35 ++--
 mm/mmap.c                                     |   3 +-
 mm/shmem.c                                    |   8 +-
 tools/testing/selftests/Makefile              |   1 +
 tools/testing/selftests/rlimits/.gitignore    |   2 +
 tools/testing/selftests/rlimits/Makefile      |   6 +
 tools/testing/selftests/rlimits/config        |   1 +
 .../selftests/rlimits/rlimits-per-userns.c    | 161 ++++++++++++++++++
 32 files changed, 483 insertions(+), 156 deletions(-)
 create mode 100644 tools/testing/selftests/rlimits/.gitignore
 create mode 100644 tools/testing/selftests/rlimits/Makefile
 create mode 100644 tools/testing/selftests/rlimits/config
 create mode 100644 tools/testing/selftests/rlimits/rlimits-per-userns.c

-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
