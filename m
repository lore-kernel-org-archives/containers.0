From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [LTP PATCH 2/4] posix mqns: test parent to child mq access
Date: Wed, 17 Dec 2008 11:57:31 -0600
Message-ID: <20081217175731.GD23331@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752362AbYLQR6Q@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081217175513.GA23291@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux Containers <containers@lists.osdl.org>, Subrata Modak1 <subrata.modak@in.ibm.com>
List-Id: containers.vger.kernel.org

It's kind of redundant with test 01 since there is no hierarchical
relationship between ipc namespaces - they are all completely isolated.
But heck it can't hurt.

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>
Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 testcases/kernel/containers/mqns/mqns_02.c      |  138 +++++++++++++++++++++++
 testcases/kernel/containers/mqns/runmqnstest.sh |    2 +-
 2 files changed, 139 insertions(+), 1 deletions(-)
 create mode 100644 testcases/kernel/containers/mqns/mqns_02.c
 mode change 100644 => 100755 testcases/kernel/containers/mqns/runmqnstest.sh

diff --git a/testcases/kernel/containers/mqns/mqns_02.c b/testcases/kernel/containers/mqns/mqns_02.c
new file mode 100644
index 0000000..2414f43
--- /dev/null
+++ b/testcases/kernel/containers/mqns/mqns_02.c
@@ -0,0 +1,138 @@
+/*
+* Copyright (c) International Business Machines Corp., 2007
+* This program is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License as published by
+* the Free Software Foundation; either version 2 of the License, or
+* (at your option) any later version.
+*
+* This program is distributed in the hope that it will be useful,
+* but WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
+* the GNU General Public License for more details.
+* You should have received a copy of the GNU General Public License
+* along with this program; if not, write to the Free Software
+* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+*
+* Author: Nadia Derbey <Nadia.Derbey@bull.net>
+*
+* Check mqns isolation: child mqns cannot be accessed from father
+*
+* Mount mqueue fs
+* unshare
+* In unshared process:
+*    Mount newinstance mqueuefs
+*    Create a posix mq -->mq1
+* Check that mq1 is not readable from father
+*
+* Changelog:
+* 	Dec 16: accomodate new mqns semantics (Serge Hallyn)
+
+***************************************************************************/
+
+#define _GNU_SOURCE 1
+#include <sys/wait.h>
+#include <assert.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include "mqns.h"
+
+char *TCID = "posixmq_namespace_02";
+int TST_TOTAL=1;
+
+int p1[2];
+int p2[2];
+
+int check_mqueue(void *vtest)
+{
+	char buf[3];
+	mqd_t mqd;
+
+	close(p1[1]);
+	close(p2[0]);
+
+	read(p1[0], buf, 3);
+
+	mqd = mq_open(SLASH_MQ1, O_RDWR|O_CREAT|O_EXCL, 0777, NULL);
+	if (mqd == -1) {
+		write(p2[1], "mqfail", 7);
+		tst_exit(3);
+	}
+
+	write(p2[1], "mqopen", 7);
+
+	read(p1[0], buf, 5);
+
+	/* destroy the mqueue */
+	mq_close(mqd);
+	mq_unlink(SLASH_MQ1);
+
+	write(p2[1], "done", 5);
+
+	tst_exit(0);
+
+	/* NOT REACHED */
+	return 0;
+}
+
+
+int main(int argc, char *argv[])
+{
+	int r;
+	mqd_t mqd;
+	char buf[7];
+	int use_clone = T_UNSHARE;
+
+	if (argc == 2 && strcmp(argv[1], "-clone") == 0) {
+		tst_resm(TINFO, "Testing posix mq namespaces through clone(2).\n");
+		use_clone = T_CLONE;
+	} else
+		tst_resm(TINFO, "Testing posix mq namespaces through unshare(2).\n");
+
+	if (pipe(p1) == -1) { perror("pipe"); exit(EXIT_FAILURE); }
+	if (pipe(p2) == -1) { perror("pipe"); exit(EXIT_FAILURE); }
+
+	/* fire off the test */
+	r = do_clone_unshare_test(use_clone, CLONE_NEWIPC, check_mqueue, NULL);
+	if (r < 0) {
+		tst_resm(TFAIL, "failed clone/unshare\n");
+		tst_exit(1);
+	}
+
+	tst_resm(TINFO, "Checking namespaces isolation (child to parent)\n");
+
+	close(p1[0]);
+	close(p2[1]);
+	write(p1[1], "go", 3);
+
+	read(p2[0], buf, 7);
+	if (!strcmp(buf, "mqfail")) {
+		tst_resm(TFAIL, "child process could not create mqueue\n");
+		umount(DEV_MQUEUE);
+		tst_exit(TFAIL);
+	} else if (strcmp(buf, "mqopen")) {
+		tst_resm(TFAIL, "child process could not create mqueue\n");
+		umount(DEV_MQUEUE);
+		tst_exit(TFAIL);
+	}
+
+	mqd = mq_open(SLASH_MQ1, O_RDONLY);
+	if (mqd == -1) {
+		r = TPASS;
+		tst_resm(TPASS, "Father process doesn't see mqueue\n");
+	} else {
+		r = TFAIL;
+		tst_resm(TFAIL, "Father process found mqueue\n");
+		mq_close(mqd);
+	}
+
+	write(p1[1], "cont", 5);
+	read(p2[0], buf, 7);
+
+	tst_exit(r);
+
+	/* NOT REACHED */
+	return 0;
+}
diff --git a/testcases/kernel/containers/mqns/runmqnstest.sh b/testcases/kernel/containers/mqns/runmqnstest.sh
old mode 100644
new mode 100755
index 87c712e..a5bbd24
--- a/testcases/kernel/containers/mqns/runmqnstest.sh
+++ b/testcases/kernel/containers/mqns/runmqnstest.sh
@@ -20,7 +20,7 @@
 ################################################################################
 
 exit_code=0
-tests_list='mqns_01'
+tests_list='mqns_01 mqns_02'
 
 for t in $tests_list
 do
-- 
1.6.0.5
