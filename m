Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA9E017F
	for <containers@lists.linux.dev>; Mon, 28 Jun 2021 22:57:50 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lxzr7-00608r-S8; Mon, 28 Jun 2021 16:35:53 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:42554 helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lxzr6-00HLpd-TB; Mon, 28 Jun 2021 16:35:53 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-kernel@vger.kernel.org> ,
 Linux Containers <containers@lists.linux.dev> 
Date: Mon, 28 Jun 2021 17:35:22 -0500
Message-ID: <87fsx1vcr9.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lxzr6-00HLpd-TB;;;mid=<87fsx1vcr9.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX19Abjp+/CULO/pIKiKFXWFdmlNGmE03DqY=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: **
X-Spam-Status: No, score=2.0 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,XMSubMetaSxObfu_03,XMSubMetaSx_00
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4452]
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: **;Linus Torvalds <torvalds@linux-foundation.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 359 ms - load_scoreonly_sql: 0.03 (0.0%),
	signal_user_changed: 11 (2.9%), b_tie_ro: 9 (2.6%), parse: 0.80 (0.2%),
	 extract_message_metadata: 3.4 (1.0%), get_uri_detail_list: 1.55
	(0.4%), tests_pri_-1000: 3.3 (0.9%), tests_pri_-950: 1.19 (0.3%),
	tests_pri_-900: 1.02 (0.3%), tests_pri_-90: 64 (17.8%), check_bayes:
	63 (17.4%), b_tokenize: 7 (1.9%), b_tok_get_all: 7 (2.0%),
	b_comp_prob: 1.81 (0.5%), b_tok_touch_all: 43 (12.1%), b_finish: 0.91
	(0.3%), tests_pri_0: 257 (71.4%), check_dkim_signature: 0.46 (0.1%),
	check_dkim_adsp: 2.8 (0.8%), poll_dns_idle: 1.05 (0.3%), tests_pri_10:
	2.1 (0.6%), tests_pri_500: 8 (2.3%), rewrite_mail: 0.00 (0.0%)
Subject: [GIT PULL]  ucounts: Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)


Linus,

Please pull the for-linus branch from the git tree:

  git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

  HEAD: 5e6b8a50a7cec5686ee2c4bda1d49899c79a7eae cred: add missing return error code when set_cred_ucounts() failed

This is the work mainly by Alexey Gladkov to limit rlimits to the
rlimits of the user that created a user namespace, and to allow users to
have stricter limits on the resources created within a user namespace.

There is a more detailed changelog from Alexey in the merge commit
9b624988221b ("ucounts: Count rlimits in each user namespace")

---

Alexey Gladkov (9):
      Increase size of ucounts to atomic_long_t
      Add a reference to ucounts for each cred
      Use atomic_t for ucounts reference counting
      Reimplement RLIMIT_NPROC on top of ucounts
      Reimplement RLIMIT_MSGQUEUE on top of ucounts
      Reimplement RLIMIT_SIGPENDING on top of ucounts
      Reimplement RLIMIT_MEMLOCK on top of ucounts
      kselftests: Add test to check for rlimit changes in different user namespaces
      ucounts: Set ucount_max to the largest positive value the type can hold

Eric W. Biederman (2):
      ucounts: Count rlimits in each user namespace
      ucounts: Silence warning in dec_rlimit_ucounts

Yang Yingliang (1):
      cred: add missing return error code when set_cred_ucounts() failed

 fs/exec.c                                          |   6 +-
 fs/hugetlbfs/inode.c                               |  16 +-
 fs/proc/array.c                                    |   2 +-
 include/linux/cred.h                               |   4 +
 include/linux/hugetlb.h                            |   4 +-
 include/linux/mm.h                                 |   4 +-
 include/linux/sched/user.h                         |   7 -
 include/linux/shmem_fs.h                           |   2 +-
 include/linux/signal_types.h                       |   4 +-
 include/linux/user_namespace.h                     |  31 +++-
 ipc/mqueue.c                                       |  40 ++---
 ipc/shm.c                                          |  26 ++--
 kernel/cred.c                                      |  51 ++++++-
 kernel/exit.c                                      |   2 +-
 kernel/fork.c                                      |  18 ++-
 kernel/signal.c                                    |  25 ++--
 kernel/sys.c                                       |  14 +-
 kernel/ucount.c                                    | 116 +++++++++++----
 kernel/user.c                                      |   3 -
 kernel/user_namespace.c                            |   9 +-
 mm/memfd.c                                         |   4 +-
 mm/mlock.c                                         |  22 ++-
 mm/mmap.c                                          |   4 +-
 mm/shmem.c                                         |  10 +-
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/rlimits/.gitignore         |   2 +
 tools/testing/selftests/rlimits/Makefile           |   6 +
 tools/testing/selftests/rlimits/config             |   1 +
 .../testing/selftests/rlimits/rlimits-per-userns.c | 161 +++++++++++++++++++++
 29 files changed, 468 insertions(+), 127 deletions(-)


