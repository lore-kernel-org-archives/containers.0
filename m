Return-Path: <SRS0=LRkw=JE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 807D9C43461
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 17:08:51 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3EE9B6128D
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 17:08:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EE9B6128D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 1848184C61;
	Wed,  7 Apr 2021 17:08:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qk4nAmFAQYNA; Wed,  7 Apr 2021 17:08:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id E6D9084C64;
	Wed,  7 Apr 2021 17:08:49 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D637BC000C;
	Wed,  7 Apr 2021 17:08:49 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1D8E7C0014
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id F1DD883A3A
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mRQqtR8FHt-G
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:38 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp1.osuosl.org (Postfix) with ESMTP id EEF1184C31
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 17:08:37 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 2E397417CC;
 Wed,  7 Apr 2021 17:08:37 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v10 8/9] kselftests: Add test to check for rlimit changes in
 different user namespaces
Date: Wed,  7 Apr 2021 19:08:13 +0200
Message-Id: <f8a1f13c6e94431e2dc165aa6d8e62b6fd48d090.1617814298.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1617814298.git.gladkov.alexey@gmail.com>
References: <cover.1617814298.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [5.9.43.93]); Wed, 07 Apr 2021 17:08:37 +0000 (UTC)
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

The testcase runs few instances of the program with RLIMIT_NPROC=1 from
user uid=60000, in different user namespaces.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 tools/testing/selftests/Makefile              |   1 +
 tools/testing/selftests/rlimits/.gitignore    |   2 +
 tools/testing/selftests/rlimits/Makefile      |   6 +
 tools/testing/selftests/rlimits/config        |   1 +
 .../selftests/rlimits/rlimits-per-userns.c    | 161 ++++++++++++++++++
 5 files changed, 171 insertions(+)
 create mode 100644 tools/testing/selftests/rlimits/.gitignore
 create mode 100644 tools/testing/selftests/rlimits/Makefile
 create mode 100644 tools/testing/selftests/rlimits/config
 create mode 100644 tools/testing/selftests/rlimits/rlimits-per-userns.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 6c575cf34a71..a4ea1481bd9a 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -48,6 +48,7 @@ TARGETS += proc
 TARGETS += pstore
 TARGETS += ptrace
 TARGETS += openat2
+TARGETS += rlimits
 TARGETS += rseq
 TARGETS += rtc
 TARGETS += seccomp
diff --git a/tools/testing/selftests/rlimits/.gitignore b/tools/testing/selftests/rlimits/.gitignore
new file mode 100644
index 000000000000..091021f255b3
--- /dev/null
+++ b/tools/testing/selftests/rlimits/.gitignore
@@ -0,0 +1,2 @@
+# SPDX-License-Identifier: GPL-2.0-only
+rlimits-per-userns
diff --git a/tools/testing/selftests/rlimits/Makefile b/tools/testing/selftests/rlimits/Makefile
new file mode 100644
index 000000000000..03aadb406212
--- /dev/null
+++ b/tools/testing/selftests/rlimits/Makefile
@@ -0,0 +1,6 @@
+# SPDX-License-Identifier: GPL-2.0-or-later
+
+CFLAGS += -Wall -O2 -g
+TEST_GEN_PROGS := rlimits-per-userns
+
+include ../lib.mk
diff --git a/tools/testing/selftests/rlimits/config b/tools/testing/selftests/rlimits/config
new file mode 100644
index 000000000000..416bd53ce982
--- /dev/null
+++ b/tools/testing/selftests/rlimits/config
@@ -0,0 +1 @@
+CONFIG_USER_NS=y
diff --git a/tools/testing/selftests/rlimits/rlimits-per-userns.c b/tools/testing/selftests/rlimits/rlimits-per-userns.c
new file mode 100644
index 000000000000..26dc949e93ea
--- /dev/null
+++ b/tools/testing/selftests/rlimits/rlimits-per-userns.c
@@ -0,0 +1,161 @@
+// SPDX-License-Identifier: GPL-2.0-or-later
+/*
+ * Author: Alexey Gladkov <gladkov.alexey@gmail.com>
+ */
+#define _GNU_SOURCE
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+#include <sys/prctl.h>
+#include <sys/stat.h>
+
+#include <unistd.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <sched.h>
+#include <signal.h>
+#include <limits.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <err.h>
+
+#define NR_CHILDS 2
+
+static char *service_prog;
+static uid_t user   = 60000;
+static uid_t group  = 60000;
+
+static void setrlimit_nproc(rlim_t n)
+{
+	pid_t pid = getpid();
+	struct rlimit limit = {
+		.rlim_cur = n,
+		.rlim_max = n
+	};
+
+	warnx("(pid=%d): Setting RLIMIT_NPROC=%ld", pid, n);
+
+	if (setrlimit(RLIMIT_NPROC, &limit) < 0)
+		err(EXIT_FAILURE, "(pid=%d): setrlimit(RLIMIT_NPROC)", pid);
+}
+
+static pid_t fork_child(void)
+{
+	pid_t pid = fork();
+
+	if (pid < 0)
+		err(EXIT_FAILURE, "fork");
+
+	if (pid > 0)
+		return pid;
+
+	pid = getpid();
+
+	warnx("(pid=%d): New process starting ...", pid);
+
+	if (prctl(PR_SET_PDEATHSIG, SIGKILL) < 0)
+		err(EXIT_FAILURE, "(pid=%d): prctl(PR_SET_PDEATHSIG)", pid);
+
+	signal(SIGUSR1, SIG_DFL);
+
+	warnx("(pid=%d): Changing to uid=%d, gid=%d", pid, user, group);
+
+	if (setgid(group) < 0)
+		err(EXIT_FAILURE, "(pid=%d): setgid(%d)", pid, group);
+	if (setuid(user) < 0)
+		err(EXIT_FAILURE, "(pid=%d): setuid(%d)", pid, user);
+
+	warnx("(pid=%d): Service running ...", pid);
+
+	warnx("(pid=%d): Unshare user namespace", pid);
+	if (unshare(CLONE_NEWUSER) < 0)
+		err(EXIT_FAILURE, "unshare(CLONE_NEWUSER)");
+
+	char *const argv[] = { "service", NULL };
+	char *const envp[] = { "I_AM_SERVICE=1", NULL };
+
+	warnx("(pid=%d): Executing real service ...", pid);
+
+	execve(service_prog, argv, envp);
+	err(EXIT_FAILURE, "(pid=%d): execve", pid);
+}
+
+int main(int argc, char **argv)
+{
+	size_t i;
+	pid_t child[NR_CHILDS];
+	int wstatus[NR_CHILDS];
+	int childs = NR_CHILDS;
+	pid_t pid;
+
+	if (getenv("I_AM_SERVICE")) {
+		pause();
+		exit(EXIT_SUCCESS);
+	}
+
+	service_prog = argv[0];
+	pid = getpid();
+
+	warnx("(pid=%d) Starting testcase", pid);
+
+	/*
+	 * This rlimit is not a problem for root because it can be exceeded.
+	 */
+	setrlimit_nproc(1);
+
+	for (i = 0; i < NR_CHILDS; i++) {
+		child[i] = fork_child();
+		wstatus[i] = 0;
+		usleep(250000);
+	}
+
+	while (1) {
+		for (i = 0; i < NR_CHILDS; i++) {
+			if (child[i] <= 0)
+				continue;
+
+			errno = 0;
+			pid_t ret = waitpid(child[i], &wstatus[i], WNOHANG);
+
+			if (!ret || (!WIFEXITED(wstatus[i]) && !WIFSIGNALED(wstatus[i])))
+				continue;
+
+			if (ret < 0 && errno != ECHILD)
+				warn("(pid=%d): waitpid(%d)", pid, child[i]);
+
+			child[i] *= -1;
+			childs -= 1;
+		}
+
+		if (!childs)
+			break;
+
+		usleep(250000);
+
+		for (i = 0; i < NR_CHILDS; i++) {
+			if (child[i] <= 0)
+				continue;
+			kill(child[i], SIGUSR1);
+		}
+	}
+
+	for (i = 0; i < NR_CHILDS; i++) {
+		if (WIFEXITED(wstatus[i]))
+			warnx("(pid=%d): pid %d exited, status=%d",
+				pid, -child[i], WEXITSTATUS(wstatus[i]));
+		else if (WIFSIGNALED(wstatus[i]))
+			warnx("(pid=%d): pid %d killed by signal %d",
+				pid, -child[i], WTERMSIG(wstatus[i]));
+
+		if (WIFSIGNALED(wstatus[i]) && WTERMSIG(wstatus[i]) == SIGUSR1)
+			continue;
+
+		warnx("(pid=%d): Test failed", pid);
+		exit(EXIT_FAILURE);
+	}
+
+	warnx("(pid=%d): Test passed", pid);
+	exit(EXIT_SUCCESS);
+}
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
