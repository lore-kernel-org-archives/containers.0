From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [LTP PATCH 4/4] posix mqns: test that user mount of posixmq
	survivies the ipcns
Date: Wed, 17 Dec 2008 11:58:23 -0600
Message-ID: <20081217175823.GF23331@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752671AbYLQR6y@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081217175513.GA23291@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux Containers <containers@lists.osdl.org>, Subrata Modak1 <subrata.modak@in.ibm.com>
List-Id: containers.vger.kernel.org

If the mqueuefs for a ipc namespace is mounted in a mounts namespace
which outlives the ipcns, then the view of the fs remains valid
until someone umounts it.  Run some tests to make sure that all is
sane.

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 testcases/kernel/containers/mqns/mqns.h         |    1 +
 testcases/kernel/containers/mqns/mqns_04.c      |  169 +++++++++++++++++++++++
 testcases/kernel/containers/mqns/runmqnstest.sh |    2 +-
 3 files changed, 171 insertions(+), 1 deletions(-)
 create mode 100644 testcases/kernel/containers/mqns/mqns_04.c

diff --git a/testcases/kernel/containers/mqns/mqns.h b/testcases/kernel/containers/mqns/mqns.h
index 4bf1e1f..33166d2 100644
--- a/testcases/kernel/containers/mqns/mqns.h
+++ b/testcases/kernel/containers/mqns/mqns.h
@@ -8,6 +8,7 @@
 
 
 #define DEV_MQUEUE "/dev/mqueue"
+#define DEV_MQUEUE2 "/dev/mqueue2"
 #define SLASH_MQ1 "/MQ1"
 #define SLASH_MQ2 "/MQ2"
 
diff --git a/testcases/kernel/containers/mqns/mqns_04.c b/testcases/kernel/containers/mqns/mqns_04.c
new file mode 100644
index 0000000..ef76f0a
--- /dev/null
+++ b/testcases/kernel/containers/mqns/mqns_04.c
@@ -0,0 +1,169 @@
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
+* Author: Serge Hallyn <serue@us.ibm.com>
+*
+* Check mqueuefs lifetime
+* . parent creates /dev/mqueue2
+* . child mounts mqueue there
+* . child does mq_open("/ab")
+* . parent checks for /dev/mqueue2
+* . child exits
+* . parent checks for /dev/mqueue2
+* . parent tries 'touch /dev/mqueue2/dd' -> should fail
+* . parent umounts /dev/mqueue2
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
+char *TCID = "posixmq_namespace_04";
+int TST_TOTAL=1;
+
+int p1[2];
+int p2[2];
+
+#define FNAM1 DEV_MQUEUE2 SLASH_MQ1
+#define FNAM2 DEV_MQUEUE2 SLASH_MQ2
+
+int check_mqueue(void *vtest)
+{
+	char buf[30];
+	mqd_t mqd;
+	int rc;
+
+	close(p1[1]);
+	close(p2[0]);
+
+	read(p1[0], buf, 3); /* go */
+
+	mqd = mq_open(SLASH_MQ1, O_RDWR|O_CREAT|O_EXCL, 0755, NULL);
+	if (mqd == -1) {
+		write(p2[1], "mqfail", 7);
+		tst_exit(3);
+	}
+
+	mq_close(mqd);
+
+	rc = mount("mqueue", DEV_MQUEUE2, "mqueue", 0, NULL);
+	if (rc == -1) {
+		perror("mount");
+		write(p2[1], "mount", 6);
+		tst_exit(3);
+	}
+
+	write(p2[1], "go", 3);
+	read(p1[0], buf, 3);
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
+	int r = TFAIL;
+	int rc;
+	int status;
+	char buf[7];
+	struct stat statbuf;
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
+	mkdir(DEV_MQUEUE2, 0755);
+
+	tst_resm(TINFO, "Checking mqueue filesystem lifetime\n");
+
+	/* fire off the test */
+	rc = do_clone_unshare_test(use_clone, CLONE_NEWIPC, check_mqueue, NULL);
+	if (rc < 0) {
+		tst_resm(TFAIL, "failed clone/unshare\n");
+		goto fail;
+	}
+
+	close(p1[0]);
+	close(p2[1]);
+	write(p1[1], "go", 3);
+
+	read(p2[0], buf, 7);
+	if (!strcmp(buf, "mqfail")) {
+		tst_resm(TFAIL, "child process could not create mqueue\n");
+		goto fail;
+	} else if (!strcmp(buf, "mount")) {
+		tst_resm(TFAIL, "child process could not mount mqueue\n");
+		goto fail;
+	}
+
+	rc = stat(FNAM1, &statbuf);
+	if (rc == -1) {
+		perror("stat");
+		write(p1[1], "go", 3);
+		tst_resm(TFAIL, "parent could not see child's created mq\n");
+		goto fail;
+	}
+	write(p1[1], "go", 3);
+
+	rc = wait(&status);
+	if (rc == -1) {
+		perror("wait");
+		tst_resm(TFAIL, "error while parent waited on child to exit\n");
+		goto fail;
+	}
+	if (!WIFEXITED(status)) {
+		tst_resm(TFAIL, "Child did not exit normally (status %d)\n", status);
+		goto fail;
+	}
+	rc = stat(FNAM1, &statbuf);
+	if (rc == -1) {
+		tst_resm(TFAIL, "parent's view of child's mq died with child\n");
+		goto fail;
+	}
+
+	rc = creat(FNAM2, 0755);
+	if (rc != -1) {
+		tst_resm(TFAIL, "parent was able to create a file in dead child's mqfs\n");
+		goto fail;
+	}
+
+	tst_resm(TPASS, "Child mqueue fs still visible for parent\n");
+
+	r = 0;
+
+fail:
+	umount(DEV_MQUEUE2);
+	rmdir(DEV_MQUEUE2);
+	tst_exit(r);
+
+	/* NOT REACHED */
+	return 0;
+}
diff --git a/testcases/kernel/containers/mqns/runmqnstest.sh b/testcases/kernel/containers/mqns/runmqnstest.sh
index b518d28..9008fd0 100755
--- a/testcases/kernel/containers/mqns/runmqnstest.sh
+++ b/testcases/kernel/containers/mqns/runmqnstest.sh
@@ -20,7 +20,7 @@
 ################################################################################
 
 exit_code=0
-tests_list='mqns_01 mqns_02 mqns_03'
+tests_list='mqns_01 mqns_02 mqns_03 mqns_04'
 
 for t in $tests_list
 do
-- 
1.6.0.5
