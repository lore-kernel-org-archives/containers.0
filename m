From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/10] selftests: Add a new task counter selftest
Date: Wed,  1 Feb 2012 04:37:50 +0100
Message-ID: <1328067470-5980-11-git-send-email-fweisbec@gmail.com>
References: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1328067470-5980-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

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

Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Cc: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 tools/testing/selftests/Makefile                   |    2 +-
 tools/testing/selftests/run_tests                  |    2 +-
 tools/testing/selftests/task_counter/Makefile      |    8 +
 tools/testing/selftests/task_counter/fork.c        |   40 ++++
 tools/testing/selftests/task_counter/forkbomb.c    |   40 ++++
 tools/testing/selftests/task_counter/multithread.c |   68 +++++++
 tools/testing/selftests/task_counter/run_test      |  198 ++++++++++++++++++++
 .../selftests/task_counter/spread_thread_group.c   |   82 ++++++++
 8 files changed, 438 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/task_counter/Makefile
 create mode 100644 tools/testing/selftests/task_counter/fork.c
 create mode 100644 tools/testing/selftests/task_counter/forkbomb.c
 create mode 100644 tools/testing/selftests/task_counter/multithread.c
 create mode 100755 tools/testing/selftests/task_counter/run_test
 create mode 100644 tools/testing/selftests/task_counter/spread_thread_group.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 4ec8401..c697742 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -1,4 +1,4 @@
-TARGETS = breakpoints
+TARGETS = breakpoints task_counter
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git a/tools/testing/selftests/run_tests b/tools/testing/selftests/run_tests
index 19043d3..11d76f7 100644
--- a/tools/testing/selftests/run_tests
+++ b/tools/testing/selftests/run_tests
@@ -1,6 +1,6 @@
 #!/bin/bash
 
-TARGETS=breakpoints
+TARGETS="breakpoints task_counter"
 
 for TARGET in $TARGETS
 do
diff --git a/tools/testing/selftests/task_counter/Makefile b/tools/testing/selftests/task_counter/Makefile
new file mode 100644
index 0000000..e314ce4
--- /dev/null
+++ b/tools/testing/selftests/task_counter/Makefile
@@ -0,0 +1,8 @@
+all:
+	gcc fork.c -o fork
+	gcc forkbomb.c -o forkbomb
+	gcc multithread.c -o multithread -lpthread
+	gcc spread_thread_group.c -o spread_thread_group -lpthread
+
+clean:
+	rm -f fork forkbomb multithread spread_thread_group *~
diff --git a/tools/testing/selftests/task_counter/fork.c b/tools/testing/selftests/task_counter/fork.c
new file mode 100644
index 0000000..20b48a9
--- /dev/null
+++ b/tools/testing/selftests/task_counter/fork.c
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
+		perror("can't write pid\n");
+		return -3;
+	}
+	fclose(fp);
+
+	if (fork() == -1)
+		return 0;
+
+	return -4;
+}
diff --git a/tools/testing/selftests/task_counter/forkbomb.c b/tools/testing/selftests/task_counter/forkbomb.c
new file mode 100644
index 0000000..221fefb
--- /dev/null
+++ b/tools/testing/selftests/task_counter/forkbomb.c
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
diff --git a/tools/testing/selftests/task_counter/multithread.c b/tools/testing/selftests/task_counter/multithread.c
new file mode 100644
index 0000000..e566a02
--- /dev/null
+++ b/tools/testing/selftests/task_counter/multithread.c
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
+volatile static int thread_end;
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
diff --git a/tools/testing/selftests/task_counter/run_test b/tools/testing/selftests/task_counter/run_test
new file mode 100755
index 0000000..ee063aa
--- /dev/null
+++ b/tools/testing/selftests/task_counter/run_test
@@ -0,0 +1,198 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc., Frederic Weisbecker <fweisbec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+#
+# Licensed under the terms of the GNU GPL License version 2
+#
+# Validation tests for the cgroup task counter subsystem
+
+BASE=/dev/cgroup
+
+if [ $UID != 0 ]
+then
+	echo "Must be root to run task counter selftest"
+	exit 0
+fi
+
+if [ -e $BASE ]
+then
+	echo "Directory $BASE already exist"
+	echo "Can't run task counter selftest"
+	exit 0
+fi
+
+mkdir $BASE
+mount -t cgroup -o tasks cgroup $BASE
+if [ $? != 0 ]
+then
+    echo "Unable to mount cgroup filesystem"
+    echo "Can't run task counter selftest."
+    rmdir $BASE
+    exit 0
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
+echo 1 > $BASE/cgroup0/tasks.limit
+echo $PID1 >  $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Allow 1 task on limit 1"
+
+echo $PID2 >  $BASE/cgroup0/cgroup.procs
+test_result $? 0 1 "Don't allow 2 tasks on limit 1"
+
+# simple test usage
+USAGE=$(cat $BASE/cgroup0/tasks.usage)
+test_result $USAGE 1 0 "Correct usage "
+
+# simple test exit
+kill $PID1
+USAGE=$(cat $BASE/cgroup0/tasks.usage)
+test_result $USAGE 0 0 "Correct usage after exit "
+
+
+sleep 1d &
+PID1=$!
+
+echo 1 > $BASE/cgroup0/tasks.limit
+echo $PID1 >  $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Correct reuse after exit "
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
+echo 1 > $BASE/cgroup0/cgroup1/tasks.limit
+echo $PID1 > $BASE/cgroup0/cgroup1/cgroup.procs
+USAGE=$(cat $BASE/cgroup0/tasks.usage)
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
+echo $PID2 > $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 1 "Correct propagation limit "
+
+kill $PID1
+kill $PID2
+
+# test limit on thread group
+echo 1024 > $BASE/cgroup0/tasks.limit
+echo 0 > $BASE/cgroup0/cgroup1/tasks.limit
+
+./multithread $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 1 "Correct limit on multithreaded"
+
+# test move of a thread group
+echo 2 > $BASE/cgroup0/cgroup1/tasks.limit
+
+./multithread $BASE/cgroup0/cgroup1/cgroup.procs
+test_result $? 0 0 "Correct move of multithreaded"
+
+rmdir $BASE/cgroup0/cgroup1
+rmdir $BASE/cgroup0/cgroup2
+
+# test bug on common ancestor logic
+# as described in https://lkml.org/lkml/2011/11/8/218
+
+./spread_thread_group $BASE/cgroup0/cgroup.procs $BASE/tasks
+test_result $? 0 0 "Test bug on common ancestor logic"
+
+# test fork
+
+echo 1 > $BASE/cgroup0/tasks.limit
+./fork $BASE/cgroup0/cgroup.procs
+test_result $? 0 0 "Correct fork limit "
+
+# test forkbomb
+
+echo 128 > $BASE/cgroup0/tasks.limit
+echo -n "Trying to stop forkbomb propagation..."
+./forkbomb $BASE/cgroup0/cgroup.procs &
+sleep 1
+RES=$(cat $BASE/cgroup0/tasks.usage)
+test_result $RES 128 0 ""
+
+# kill forkbomb
+
+echo -n "Trying to kill forkbomb "
+echo 0 > $BASE/cgroup0/tasks.limit
+END=false
+
+while [ $END = false ]
+do
+	NR_TASKS=$(cat $BASE/cgroup0/tasks.usage)
+	NR_KILLED=0
+
+	for TASK in $(cat $BASE/cgroup0/cgroup.procs)
+	do
+		NR_KILLED=$(($NR_KILLED+1))
+		kill -KILL $TASK
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
+umount $BASE
+rmdir $BASE
\ No newline at end of file
diff --git a/tools/testing/selftests/task_counter/spread_thread_group.c b/tools/testing/selftests/task_counter/spread_thread_group.c
new file mode 100644
index 0000000..e088deb
--- /dev/null
+++ b/tools/testing/selftests/task_counter/spread_thread_group.c
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
+volatile static int thread_end;
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
1.7.5.4
