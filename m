From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [LTP PATCH 1/4] posix message queue namespaces: first test
Date: Wed, 17 Dec 2008 11:57:18 -0600
Message-ID: <20081217175718.GC23331@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752153AbYLQR5b@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081217175513.GA23291@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux Containers <containers@lists.osdl.org>, Subrata Modak1 <subrata.modak@in.ibm.com>
List-Id: containers.vger.kernel.org

(Subrata, I'm sending these testcases now so people can use them,
but they should not yet be considered for integration into ltp
of course, and when they are, the kernel version test will need
to be switched to at least 2.6.29)

Add the first test for posix message queue namespaces, plus a
test to detect whether they are enabled.

Note that the kernel version check is currently bogus - these are
not yet enabled in 2.6.28.  But a fella's gotta test.

Based on older version by Nadia Derbey.
Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 testcases/kernel/containers/Makefile               |    2 +-
 testcases/kernel/containers/README                 |    4 +
 testcases/kernel/containers/container_test.sh      |    9 ++
 testcases/kernel/containers/mqns/Makefile          |   41 +++++++
 .../kernel/containers/mqns/check_mqns_enabled.c    |   65 ++++++++++
 testcases/kernel/containers/mqns/mqns.h            |   13 ++
 testcases/kernel/containers/mqns/mqns_01.c         |  123 ++++++++++++++++++++
 testcases/kernel/containers/mqns/runmqnstest.sh    |   39 ++++++
 8 files changed, 295 insertions(+), 1 deletions(-)
 create mode 100644 testcases/kernel/containers/mqns/Makefile
 create mode 100644 testcases/kernel/containers/mqns/check_mqns_enabled.c
 create mode 100644 testcases/kernel/containers/mqns/mqns.h
 create mode 100644 testcases/kernel/containers/mqns/mqns_01.c
 create mode 100644 testcases/kernel/containers/mqns/runmqnstest.sh

diff --git a/testcases/kernel/containers/Makefile b/testcases/kernel/containers/Makefile
index d2d143d..b1b6cdc 100644
--- a/testcases/kernel/containers/Makefile
+++ b/testcases/kernel/containers/Makefile
@@ -18,7 +18,7 @@
 ##                                                                            ##
 ################################################################################
 
-SUBDIRS := libclone utsname sysvipc pidns netns
+SUBDIRS := libclone utsname sysvipc pidns netns mqns
 
 all: check_for_unshare
 	@set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i $@; done
diff --git a/testcases/kernel/containers/README b/testcases/kernel/containers/README
index f1e485b..fd0898f 100644
--- a/testcases/kernel/containers/README
+++ b/testcases/kernel/containers/README
@@ -37,6 +37,10 @@ each functionality README file for detail:
 
 sysvipc/*
 	Contains all the testcases related to IPC NS tests.
+posixmq/*
+	Contains all the testcases related to POSIX MQ NS tests.  These
+	are strictly speaking a part of the ipc namespaces, but can be
+	enabled in the kernel without SYSV IPC support.
 utsname/*
 	Contains all the testcases related to utsname tests.
 libclone/*
diff --git a/testcases/kernel/containers/container_test.sh b/testcases/kernel/containers/container_test.sh
index 911a6a4..755e910 100755
--- a/testcases/kernel/containers/container_test.sh
+++ b/testcases/kernel/containers/container_test.sh
@@ -54,6 +54,15 @@ else
 	echo "Process id namespaces not enabled in kernel.  Not running pidns tests."
 fi
 
+check_mqns_enabled
+if [ $? -eq 0 ]; then
+	echo "Running POSIX message queue tests."
+	runmqnstest.sh
+else
+	echo "Posix message queues or ipc namespaces not enabled in kernel."
+	echo "Not running mqns tests."
+fi
+
 check_netns_enabled
 if [ $? -eq 0 ]; then
 	echo "Running netns tests."
diff --git a/testcases/kernel/containers/mqns/Makefile b/testcases/kernel/containers/mqns/Makefile
new file mode 100644
index 0000000..ec6ba14
--- /dev/null
+++ b/testcases/kernel/containers/mqns/Makefile
@@ -0,0 +1,41 @@
+################################################################################
+##                                                                            ##
+## Copyright (c) International Business Machines  Corp., 2007                 ##
+##                                                                            ##
+## This program is free software;  you can redistribute it and#or modify      ##
+## it under the terms of the GNU General Public License as published by       ##
+## the Free Software Foundation; either version 2 of the License, or          ##
+## (at your option) any later version.                                        ##
+##                                                                            ##
+## This program is distributed in the hope that it will be useful, but        ##
+## WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY ##
+## or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License   ##
+## for more details.                                                          ##
+##                                                                            ##
+## You should have received a copy of the GNU General Public License          ##
+## along with this program;  if not, write to the Free Software               ##
+## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA    ##
+##                                                                            ##
+################################################################################
+
+CFLAGS += -Wall
+CPPFLAGS += -I../../../../include -I../libclone
+LDLIBS += -L../../../../lib -L../libclone ../libclone/libclone.a -lltp -lrt
+
+SRCS    := $(wildcard *.c)
+TARGETS := $(SRCS:%.c=%)
+
+HAS_UNSHARE ?= $(shell ../check_for_unshare && echo y)
+ifneq ($(HAS_UNSHARE),y)
+TARGETS :=
+endif
+
+all: $(TARGETS)
+
+clean:
+	rm -f $(TARGETS) *.o
+
+install:
+ifeq ($(HAS_UNSHARE),y)
+	@set -e; for i in $(TARGETS) runmqnstest.sh check_mqns_enabled; do ln -f $$i ../../../bin/$$i ; chmod +x runmqnstest.sh ; done
+endif
diff --git a/testcases/kernel/containers/mqns/check_mqns_enabled.c b/testcases/kernel/containers/mqns/check_mqns_enabled.c
new file mode 100644
index 0000000..21d56a9
--- /dev/null
+++ b/testcases/kernel/containers/mqns/check_mqns_enabled.c
@@ -0,0 +1,65 @@
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
+***************************************************************************/
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <stdio.h>
+#include "../libclone/libclone.h"
+#include "test.h"
+#include "mqns.h"
+
+int dummy(void *v)
+{
+	return 0;
+}
+
+int main()
+{
+	void *childstack, *stack;
+	int pid;
+	mqd_t mqd;
+
+        if (tst_kvercmp(2,6,27) < 0)
+                return 1;
+
+	mq_unlink("/checkmqnsenabled");
+	mqd = mq_open("/checkmqnsenabled", O_RDWR|O_CREAT|O_EXCL, 0777, NULL);
+        if (mqd == -1) {
+		perror("mq_open");
+                return 3;
+	}
+	mq_close(mqd);
+	mq_unlink("/checkmqnsenabled");
+
+	stack = malloc(getpagesize());
+	if (!stack) {
+		perror("malloc");
+		return 4;
+	}
+	childstack = stack + getpagesize();
+#ifdef __ia64__
+	pid = clone2(dummy, childstack, getpagesize(), CLONE_NEWIPC, NULL, NULL, NULL, NULL);
+#else
+	pid = clone(dummy, childstack, CLONE_NEWIPC, NULL);
+#endif
+
+	if (pid == -1)
+		return 5;
+
+        return 0;
+}
diff --git a/testcases/kernel/containers/mqns/mqns.h b/testcases/kernel/containers/mqns/mqns.h
new file mode 100644
index 0000000..df8fc4b
--- /dev/null
+++ b/testcases/kernel/containers/mqns/mqns.h
@@ -0,0 +1,13 @@
+#ifndef __MQNS_H
+#define __MQNS_H
+
+#include <sys/mount.h>
+#include <mqueue.h>
+#include <test.h>
+#include <libclone.h>
+
+
+#define DEV_MQUEUE "/dev/mqueue"
+#define SLASH_MQ1 "/MQ1"
+
+#endif /* __MQNS_H */
diff --git a/testcases/kernel/containers/mqns/mqns_01.c b/testcases/kernel/containers/mqns/mqns_01.c
new file mode 100644
index 0000000..7cf5482
--- /dev/null
+++ b/testcases/kernel/containers/mqns/mqns_01.c
@@ -0,0 +1,123 @@
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
+* Check mqns isolation: father mqns cannot be accessed from newinstance
+*
+* Mount mqueue fs
+* Create a posix mq -->mq1
+* unshare
+* In unshared process:
+*    Mount newinstance mqueuefs
+*    Check that mq1 is not readable from new ns
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
+char *TCID = "posixmq_namespace_01";
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
+	mqd = mq_open(SLASH_MQ1, O_RDONLY);
+	if (mqd == -1) {
+		write(p2[1], "notfnd", 7);
+	} else {
+		write(p2[1], "exists", 7);
+		mq_close(mqd);
+	}
+	tst_exit(0);
+
+	/* NOT REACHED */
+	return 0;
+}
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
+	mqd = mq_open(SLASH_MQ1, O_RDWR|O_CREAT|O_EXCL, 0777, NULL);
+	if (mqd == -1) {
+		perror("mq_open");
+		tst_resm(TFAIL, "mq_open failed\n");
+		tst_exit(3);
+	}
+
+	tst_resm(TINFO, "Checking namespaces isolation from parent to child\n");
+	/* fire off the test */
+	r = do_clone_unshare_test(use_clone, CLONE_NEWIPC, check_mqueue, NULL);
+	if (r < 0) {
+		tst_resm(TFAIL, "failed clone/unshare\n");
+		mq_close(mqd);
+		mq_unlink(SLASH_MQ1);
+		tst_exit(1);
+	}
+
+	close(p1[0]);
+	close(p2[1]);
+	write(p1[1], "go", 3);
+	read(p2[0], buf, 7);
+	if (!strcmp(buf, "exists")) {
+		tst_resm(TFAIL, "child process found mqueue\n");
+		r = TFAIL;
+	} else if (!strcmp(buf, "notfnd")) {
+		tst_resm(TPASS, "child process didn't find mqueue\n");
+		r = TPASS;
+	} else {
+		tst_resm(TFAIL, "UNKNOWN RESULT\n");
+		r = TFAIL;
+	}
+
+	/* destroy the mqueue */
+	mq_close(mqd);
+	mq_unlink(SLASH_MQ1);
+
+	tst_exit(r);
+
+	/* NOT REACHED */
+	return 0;
+}
diff --git a/testcases/kernel/containers/mqns/runmqnstest.sh b/testcases/kernel/containers/mqns/runmqnstest.sh
new file mode 100644
index 0000000..87c712e
--- /dev/null
+++ b/testcases/kernel/containers/mqns/runmqnstest.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+################################################################################
+##                                                                            ##
+## Copyright (c) International Business Machines  Corp., 2007                 ##
+##                                                                            ##
+## This program is free software;  you can redistribute it and#or modify      ##
+## it under the terms of the GNU General Public License as published by       ##
+## the Free Software Foundation; either version 2 of the License, or          ##
+## (at your option) any later version.                                        ##
+##                                                                            ##
+## This program is distributed in the hope that it will be useful, but        ##
+## WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY ##
+## or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License   ##
+## for more details.                                                          ##
+##                                                                            ##
+## You should have received a copy of the GNU General Public License          ##
+## along with this program;  if not, write to the Free Software               ##
+## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA    ##
+##                                                                            ##
+################################################################################
+
+exit_code=0
+tests_list='mqns_01'
+
+for t in $tests_list
+do
+	$t
+	if [ $? -ne 0 ]; then
+		exit_code="$?"
+		exit $exit_code
+	fi
+	$t -clone
+	if [ $? -ne 0 ]; then
+		exit_code="$?"
+		exit $exit_code
+	fi
+done
+
+exit $exit_code
-- 
1.6.0.5
