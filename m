From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 9/9] selftests: Add a new task counter selftest
Date: Thu, 12 Dec 2013 16:35:18 -0500
Message-ID: <1386884118-14972-10-git-send-email-dwight.engen@oracle.com>
References: <1386884118-14972-1-git-send-email-dwight.engen@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1386884118-14972-1-git-send-email-dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This is a batch of tests running against the cgroup task counter
subsystem in order to validate the expected behaviour from this
cgroup feature.

This checks the reliability of the value found in the tasks.usage file
after events like forks, exits or cgroup migration of whole processes
or individual threads.

This also check that forks or cgroup migration are either accepted or
rejected according to the value set in the tasks.limit file.

A forkbomb is also launched to test if the subsystem stops well its
propagation and kills it properly as expected.

Signed-off-by: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/cpuacct/Makefile           |  11 ++
 tools/testing/selftests/cpuacct/fork.c             |  40 ++++
 tools/testing/selftests/cpuacct/forkbomb.c         |  40 ++++
 tools/testing/selftests/cpuacct/multithread.c      |  68 +++++++
 tools/testing/selftests/cpuacct/run_test           | 214 +++++++++++++++++++++
 .../selftests/cpuacct/spread_thread_group.c        |  82 ++++++++
 7 files changed, 456 insertions(+)
 create mode 100644 tools/testing/selftests/cpuacct/Makefile
 create mode 100644 tools/testing/selftests/cpuacct/fork.c
 create mode 100644 tools/testing/selftests/cpuacct/forkbomb.c
 create mode 100644 tools/testing/selftests/cpuacct/multithread.c
 create mode 100755 tools/testing/selftests/cpuacct/run_test
 create mode 100644 tools/testing/selftests/cpuacct/spread_thread_group.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 9f3eae2..61405ab 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -9,6 +9,7 @@ TARGETS += ptrace
 TARGETS += timers
 TARGETS += vm
 TARGETS += powerpc
+TARGETS += cpuacct
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git a/tools/testing/selftests/cpuacct/Makefile b/tools/testing/selftests/cpuacct/Makefile
new file mode 100644
index 0000000..feb39e5
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/Makefile
@@ -0,0 +1,11 @@
+all:
+	gcc fork.c -o fork
+	gcc forkbomb.c -o forkbomb
+	gcc multithread.c -o multithread -lpthread
+	gcc spread_thread_group.c -o spread_thread_group -lpthread
+
+run_tests: all
+	./run_test
+
+clean:
+	rm -f fork forkbomb multithread spread_thread_group *~
diff --git a/tools/testing/selftests/cpuacct/fork.c b/tools/testing/selftests/cpuacct/fork.c
new file mode 100644
index 0000000..c85a610
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/fork.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ *
+ * Licensed under the terms of the GNU GPL License version 2
+ *
+ * Move a task to a cgroup and try to fork on it.
+ */
+
+#include <stdio.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <string.h>
+
+int main(int argc, char **argv)
+{
+	FILE *fp;
+	int pid;
+	char cpid[50];
+
+	if (argc < 2)
+		return -1;
+
+	pid = getpid();
+	fp = fopen(argv[1], "w");
+	if (!fp)
+		return -2;
+
+	sprintf(cpid, "%d\n", pid);
+
+	if (fwrite(cpid, strlen(cpid), 1, fp) != 1) {
+		perror("can't write pid");
+		return -3;
+	}
+	fclose(fp);
+
+	if (fork() == -1)
+		return -4;
+
+	return 0;
+}
diff --git a/tools/testing/selftests/cpuacct/forkbomb.c b/tools/testing/selftests/cpuacct/forkbomb.c
new file mode 100644
index 0000000..221fefb
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/forkbomb.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ *
+ * Licensed under the terms of the GNU GPL License version 2
+ *
+ * Move a task to a cgroup and forkbomb there.
+ */
+
+#include <stdio.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <string.h>
+
+int main(int argc, char **argv)
+{
+	FILE *fp;
+	int pid;
+	char cpid[50];
+
+	if (argc < 2)
+		return -1;
+
+	pid = getpid();
+	fp = fopen(argv[1], "w");
+	if (!fp)
+		return -2;
+
+	sprintf(cpid, "%d\n", pid);
+
+	if (fwrite(cpid, strlen(cpid), 1, fp) != 1) {
+		perror("can't write pid\n");
+		return -3;
+	}
+	fclose(fp);
+
+	for (;;)
+		fork();
+
+	return 0;
+}
diff --git a/tools/testing/selftests/cpuacct/multithread.c b/tools/testing/selftests/cpuacct/multithread.c
new file mode 100644
index 0000000..6d485de
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/multithread.c
@@ -0,0 +1,68 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ *
+ * Licensed under the terms of the GNU GPL License version 2
+ *
+ * Try to move a multithread proc to a cgroup.
+ */
+
+
+#include <stdio.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+#include <pthread.h>
+
+static volatile int thread_end;
+pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
+pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
+
+
+static void *thread_start(void *unused)
+{
+	pthread_mutex_lock(&mutex);
+
+	while (!thread_end)
+		pthread_cond_wait(&cond, &mutex);
+
+	pthread_mutex_unlock(&mutex);
+
+	return NULL;
+}
+
+int main(int argc, char **argv)
+{
+	int fd;
+	int pid;
+	char cpid[50];
+	pthread_t thread;
+
+	if (argc < 2)
+		return -1;
+
+	if (pthread_create(&thread, NULL, thread_start, NULL) != 0)
+		return -2;
+
+	pid = getpid();
+	fd = open(argv[1], O_WRONLY);
+	if (fd < 0)
+		return -3;
+
+	sprintf(cpid, "%d\n", pid);
+
+	if (write(fd, cpid, strlen(cpid)) < 0)
+		return -4;
+
+	close(fd);
+
+	pthread_mutex_lock(&mutex);
+	thread_end = 1;
+	pthread_cond_signal(&cond);
+	pthread_mutex_unlock(&mutex);
+
+	pthread_join(thread, NULL);
+
+	return 0;
+}
diff --git a/tools/testing/selftests/cpuacct/run_test b/tools/testing/selftests/cpuacct/run_test
new file mode 100755
index 0000000..7532404
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/run_test
@@ -0,0 +1,214 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+#
+# Licensed under the terms of the GNU GPL License version 2
+#
+# Validation tests for the cgroup task counter subsystem
+
+BASE=`grep '^cgroup.*cpuacct' /proc/mounts |awk '{print $2}'`
+
+if [ $UID != 0 ]
+then
+	echo "Must be root to run task counter selftest"
+	exit 0
+fi
+
+if [ -z $BASE ]
+then
+	echo "Can't find cpuacct mount in /proc/mounts"
+	echo "Ensure cpuacct cgroup is mounted"
+	exit 0
+fi
+
+sleep 1d &
+PID1=$!
+
+sleep 1d &
+PID2=$!
+
+echo 1 > $BASE/cgroup.clone_children
+mkdir $BASE/cgroup0
+
+function test_result
+{
+    # Result of the test
+    res=$1
+    # Expected result
+    expected=$2
+    # Invert test against expected result
+    # 0 = equal
+    # 1 = non equal
+    inv=$3
+    # String message
+    test_str=$4
+    passed=0
+
+    echo -n $test_str
+
+    if [ $res = $expected ]
+    then
+	passed=1
+    fi
+
+    passed=$[$passed ^ $inv]
+
+    if [ $passed = 1 ]
+    then
+	echo " [OK]"
+    else
+	echo " [FAILED]"
+    fi
+
+}
+
+# simple test limit
+echo 1 > $BASE/cgroup0/cpuacct.task_limit
+echo $PID1 >  $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Allow 1 task on limit 1"
+
+echo $PID2 >  $BASE/cgroup0/cgroup.procs 2>/dev/null
+test_result $? 0 1 "Don't allow 2 tasks on limit 1"
+
+# can't change limit once cgroup has tasks
+echo 2 > $BASE/cgroup0/cpuacct.task_limit 2>/dev/null
+test_result $? 0 1 "Can't change limit with tasks"
+
+# simple test usage
+USAGE=$(cat $BASE/cgroup0/cpuacct.task_usage)
+test_result $USAGE 1 0 "Correct usage count "
+
+# simple test exit
+kill $PID1
+wait $PID1 2>/dev/null
+USAGE=$(cat $BASE/cgroup0/cpuacct.task_usage)
+test_result $USAGE 0 0 "Correct usage count after exit "
+
+sleep 1d &
+PID1=$!
+
+echo 1 > $BASE/cgroup0/cpuacct.task_limit
+echo $PID1 >  $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Correct reuse after exit "
+USAGE=$(cat $BASE/cgroup0/cpuacct.task_usage)
+test_result $USAGE 1 0 "Correct usage count "
+
+# simple move to root
+
+echo $PID1 > $BASE/cgroup.procs
+test_result $? 0 0 "Correct move to root "
+
+# propagation tests
+
+mkdir $BASE/cgroup0/cgroup1
+mkdir $BASE/cgroup0/cgroup2
+
+echo 1 > $BASE/cgroup0/cgroup1/cpuacct.task_limit
+echo $PID1 > $BASE/cgroup0/cgroup1/cgroup.procs
+USAGE=$(cat $BASE/cgroup0/cpuacct.task_usage)
+test_result $USAGE 1 0 "Correct propagated usage "
+
+echo $PID1 > $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Correct move on parent "
+
+
+# move
+
+echo $PID1 > $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 0 "Correct move on child "
+
+echo $PID1 > $BASE/cgroup0/cgroup2/cgroup.procs
+test_result $? 0 0 "Correct move on sibling "
+
+echo $PID2 > $BASE/cgroup0/cgroup1/cgroup.procs 2>/dev/null
+test_result $? 0 1 "Correct propagation limit "
+
+kill $PID1
+wait $PID1 2>/dev/null
+kill $PID2
+wait $PID2 2>/dev/null
+
+rmdir $BASE/cgroup0/cgroup1
+rmdir $BASE/cgroup0/cgroup2
+
+# test limit on thread group
+usleep 100000
+echo 1024 > $BASE/cgroup0/cpuacct.task_limit
+mkdir $BASE/cgroup0/cgroup1
+
+# can't change limit once cgroup has children
+echo 2 > $BASE/cgroup0/cpuacct.task_limit 2>/dev/null
+test_result $? 0 1 "Can't change limit with children"
+
+echo 0 > $BASE/cgroup0/cgroup1/cpuacct.task_limit
+./multithread $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 1 "Correct limit on multithreaded"
+
+# test move of a thread group
+echo 2 > $BASE/cgroup0/cgroup1/cpuacct.task_limit
+
+./multithread $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 0 "Correct move of multithreaded"
+
+rmdir $BASE/cgroup0/cgroup1
+
+# test bug on common ancestor logic
+# as described in https://lkml.org/lkml/2011/11/8/218
+
+./spread_thread_group $BASE/cgroup0/cgroup.procs $BASE/tasks
+test_result $? 0 0 "Test bug on common ancestor logic"
+
+# test task limit with fork
+usleep 100000
+echo 1 > $BASE/cgroup0/cpuacct.task_limit
+./fork $BASE/cgroup0/cgroup.procs
+test_result $? 0 1 "Correct task limit "
+
+# test fork limit
+echo 2 > $BASE/cgroup0/cpuacct.task_limit
+echo 1 > $BASE/cgroup0/cpuacct.fork_limit
+./fork $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Fork allowed "
+./fork $BASE/cgroup0/cgroup.procs
+test_result $? 0 1 "Fork denied "
+
+rmdir $BASE/cgroup0
+mkdir $BASE/cgroup0
+
+# test forkbomb
+
+echo 128 > $BASE/cgroup0/cpuacct.task_limit
+echo -n "Trying to stop forkbomb propagation..."
+./forkbomb $BASE/cgroup0/cgroup.procs &
+sleep 1
+RES=$(cat $BASE/cgroup0/cpuacct.task_usage)
+test_result $RES 128 0 ""
+
+# kill forkbomb
+
+echo -n "Trying to kill forkbomb "
+echo 0 > $BASE/cgroup0/cpuacct.fork_limit
+END=false
+
+while [ $END = false ]
+do
+	NR_TASKS=$(cat $BASE/cgroup0/cpuacct.task_usage)
+	NR_KILLED=0
+
+	for TASK in $(cat $BASE/cgroup0/cgroup.procs)
+	do
+		NR_KILLED=$(($NR_KILLED+1))
+		kill -KILL $TASK
+		wait $TASK 2>/dev/null
+	done
+
+	if [ "$NR_TASKS" = "$NR_KILLED" ]
+	then
+		END=true
+	fi
+done
+
+echo "[OK]"
+
+# Wait a bit for killed tasks to exit the cgroup
+sleep 1
+rmdir $BASE/cgroup0
diff --git a/tools/testing/selftests/cpuacct/spread_thread_group.c b/tools/testing/selftests/cpuacct/spread_thread_group.c
new file mode 100644
index 0000000..24f42b9
--- /dev/null
+++ b/tools/testing/selftests/cpuacct/spread_thread_group.c
@@ -0,0 +1,82 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ *
+ * Licensed under the terms of the GNU GPL License version 2
+ *
+ * Try to reproduce bug on common ancestor logic as described
+ * at https://lkml.org/lkml/2011/11/8/218
+ */
+
+#include <stdio.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <string.h>
+#include <pthread.h>
+
+static volatile int thread_end;
+pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
+pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
+
+
+static void *thread_start(void *unused)
+{
+	pthread_mutex_lock(&mutex);
+
+	while (!thread_end)
+		pthread_cond_wait(&cond, &mutex);
+
+	pthread_mutex_unlock(&mutex);
+
+	return NULL;
+}
+
+int main(int argc, char **argv)
+{
+	int fd_root, fd;
+	int pid;
+	char cpid[50];
+	pthread_t thread;
+
+	if (argc < 3)
+		return -1;
+
+	if (pthread_create(&thread, NULL, thread_start, NULL) != 0)
+		return -2;
+
+	pid = getpid();
+	fd = open(argv[1], O_WRONLY);
+	if (fd < 0)
+		return -3;
+
+	sprintf(cpid, "%d\n", pid);
+
+	/* Move group to /dev/cgroup/cgroup0 */
+	if (write(fd, cpid, strlen(cpid)) < 0)
+		return -4;
+
+	fd_root = open(argv[2], O_WRONLY);
+	if (fd < 0)
+		return -5;
+
+	/* Move group leader to /dev/cgroup/ root */
+	if (write(fd_root, cpid, strlen(cpid)) < 0)
+		return -6;
+
+	/* Move back group to /dev/cgroup/cgroup0 */
+	if (write(fd, cpid, strlen(cpid)) < 0)
+		return -7;
+
+	close(fd_root);
+	close(fd);
+
+	pthread_mutex_lock(&mutex);
+	thread_end = 1;
+	pthread_cond_signal(&cond);
+	pthread_mutex_unlock(&mutex);
+
+	pthread_join(thread, NULL);
+
+	return 0;
+}
-- 
1.8.3.1
