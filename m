From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 06/11] filelease1: Test restore of file leases
Date: Fri, 29 Jan 2010 12:42:45 -0800
Message-ID: <20100129204245.GE26721@us.ibm.com>
References: <20100129202842.GA25490@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100129202842.GA25490-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 21 Jan 2010 12:36:24 -0800
Subject: [PATCH 06/11] filelease1: Test restore of file leases

Checkpoint an application that has F_RDLCK and F_WRLCK leases on files.
Restart the application and ensure that the leases are restored.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/Makefile          |    4 +-
 fileio/filelease1.c      |  262 ++++++++++++++++++++++++++++++++++++++++++++++
 fileio/run-filelease1.sh |    3 +
 fileio/runtests.sh       |    5 +
 4 files changed, 272 insertions(+), 2 deletions(-)
 create mode 100644 fileio/filelease1.c
 create mode 100755 fileio/run-filelease1.sh

diff --git a/fileio/Makefile b/fileio/Makefile
index eb3887b..acc2df9 100644
--- a/fileio/Makefile
+++ b/fileio/Makefile
@@ -1,4 +1,4 @@
-targets = fileio1 filelock1
+targets = fileio1 filelock1 filelease1
 
 INCLUDE   = ../libcrtest
 LIBCRTEST = ../libcrtest/common.o
@@ -9,4 +9,4 @@ all: $(LIBCRTEST) $(targets)
 
 clean:
 	rm -f $(targets)
-	rm -rf cr_fileio* cr_filelock1*
+	rm -rf cr_fileio* cr_filelock1* cr_filelease1*
diff --git a/fileio/filelease1.c b/fileio/filelease1.c
new file mode 100644
index 0000000..21494e9
--- /dev/null
+++ b/fileio/filelease1.c
@@ -0,0 +1,262 @@
+#include <stdio.h>
+#include <unistd.h>
+#define __USE_GNU
+#include <fcntl.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include "libcrtest.h"
+
+#define TEST_FILE1	"data.d/data.filelease1"
+#define TEST_FILE2	"data.d/data.filelease2"
+#define LOG_FILE	"logs.d/log.filelease1"
+
+extern FILE *logfp;
+int test_fd;
+int event_fd1;
+int event_fd2;
+
+/*
+ * Description:
+ * 	Ensure that F_RDLCK and F_WRLCK file leases held by a process at
+ * 	the time of checkpoint are properly restored when the process is
+ * 	restarted from the checkpoint.
+ *
+ * Implementation:
+ * 	Two processes, P0 and P1 acquire a F_RDLCK lease on file F1.
+ * 	Process P2 acquires a F_WRLCK lease on file F2. After acquiring
+ * 	leases the processes notify parent they are ready for checkpoint
+ * 	and wait for checkpoint to be done.  When they are restarted
+ * 	(i.e when test_done() is TRUE), each process verifies that it has the
+ * 	lease it had at the time of checkpoint.
+ */
+
+void set_lease(int fd, int type)
+{
+	int rc;
+
+	fprintf(logfp, "%d: set_lease() called for fd %d, type %d\n",
+			getpid(), fd, type);
+
+	rc = fcntl(fd, F_SETLEASE, type);
+	if (rc < 0) {
+		fprintf(logfp, "%d: set_lease(type %d):, ERROR %s\n",
+				getpid(), type, strerror(errno));
+		if (errno == EINVAL)
+			fprintf(logfp, "%d: Maybe the fs does not support "
+					"F_SETLEASE (eg: NFS)\n", getpid());
+		fflush(logfp);
+		kill(getppid(), SIGUSR1);
+		do_exit(1);
+	}
+
+	fprintf(logfp, "%d: set_lease(%d): %s\n", getpid(), type,
+			rc < 0 ? strerror(errno) : "done");
+}
+
+char *get_lease_desc(int type)
+{
+	switch(type) {
+		case F_RDLCK: return "F_RDLCK";
+		case F_WRLCK: return "F_WRLCK";
+		case F_UNLCK: return "F_UNLCK";
+		default:	return "Unknown !";
+	}
+}
+
+void test_lease(int fd, int exp_type)
+{
+	int rc;
+
+	rc = fcntl(fd, F_GETLEASE, 0);
+	if (rc < 0 || rc > 2) {
+		fprintf(logfp, "ERROR: fcntl(F_GETLEASE): expected %s, rc %d, "
+				"error %s\n", get_lease_desc(exp_type), rc,
+				strerror(errno));
+		do_exit(1);
+	}
+
+	if (rc != exp_type) {
+		fprintf(logfp, "%d: FAIL: Expected %s, actual %s\n", getpid(),
+				get_lease_desc(exp_type), get_lease_desc(rc));
+		do_exit(1);
+	}
+
+	fprintf(logfp, "%d: PASS: Expected %s, actual %s\n", getpid(),
+			get_lease_desc(exp_type), get_lease_desc(rc));
+	return;
+}
+
+struct test_arg {
+	int fd;
+	int type;
+	int pid;
+};
+
+struct test_arg test_data[3];
+
+int do_child(int idx)
+{
+	int type = test_data[idx].type;
+	int fd = test_data[idx].fd;
+
+	fprintf(logfp, "%d: Setting lease to type %s\n", getpid(),
+			get_lease_desc(type));
+
+	set_lease(fd, type);
+
+	/*
+	 * Tell parent we are ready for checkpoint...
+	 */
+	notify_one_event(event_fd1);
+
+	/*
+	 * Wait for checkpoint/restart
+	 */
+	fprintf(logfp, "%d: waiting for test-done\n", getpid());
+	while(!test_done()) {
+		sleep(1);
+	}
+	fprintf(logfp, "%d: Found test-done\n", getpid());
+
+	test_lease(fd, type);
+
+	do_exit(0);
+}
+
+/*
+ * Create two test files and populate test_data[] so that:
+ * 	- first two childrent get a F_RDLCK lease on file TEST_FILE1.
+ * 	- third child gets a F_WRLCK lease on file TEST_FILE2.
+ */
+void setup_test_data()
+{
+	int fd;
+	char buf[256];
+
+	/* Create TEST_FILE1 */
+	fd = open(TEST_FILE1, O_RDWR|O_CREAT|O_TRUNC, 0666);
+	if (fd < 0) {
+		fprintf(logfp, "ERROR: open(%s): %s\n", TEST_FILE1,
+				strerror(errno));
+		do_exit(1);
+	}
+
+	memset(buf, 0, sizeof(buf));
+	write(fd, buf, sizeof(buf));
+
+	/* Close TEST_FILE1 and open for read-only */
+	close(fd);
+
+	fd = open(TEST_FILE1, O_RDONLY);
+	if (fd < 0) {
+		fprintf(logfp, "ERROR: open(%s): %s\n", TEST_FILE1,
+				strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * First two childrent get a F_RDLCK lease on file TEST_FILE1.
+	 * Third child gets a F_WRLCK lease on file TEST_FILE2.
+	 */
+	test_data[0].fd = test_data[1].fd = fd;
+	test_data[0].type = test_data[1].type = F_RDLCK;
+	fprintf(logfp, "fd0: %d, type %d\n",
+				test_data[0].fd, test_data[0].type);
+
+	/* Create TEST_FILE2 */
+	fd = open(TEST_FILE2, O_RDWR|O_CREAT|O_TRUNC, 0666);
+	if (fd < 0) {
+		fprintf(logfp, "ERROR: open(%s): %s\n", TEST_FILE2,
+				strerror(errno));
+		do_exit(1);
+	}
+	write(fd, buf, sizeof(buf));
+
+	test_data[2].fd = fd;
+	test_data[2].type = F_WRLCK;
+
+	return;
+}
+
+void child_handler(int sig)
+{
+	int i;
+	int num_children = 3;
+	/*
+	 * Test failed or a child encountered an error.
+	 * Kill (remaining) children, reap children and exit.
+	 */
+	fprintf(logfp, "%d: Got signal %d\n", getpid(), sig);
+	for (i = 0; i < num_children; i++)
+		if (test_data[i].pid)
+			kill(test_data[i].pid, SIGKILL);
+
+	fprintf(logfp, "%d: Test case FAILED\n", getpid());
+	fflush(logfp);
+
+	do_wait(num_children);
+
+	do_exit(-1);
+}
+
+main(int argc, char *argv[])
+{
+	int i, status, rc;
+	int pid;
+
+	if (test_done()) {
+		printf("Remove %s before running test\n", TEST_DONE);
+		do_exit(1);
+	}
+
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("open() logfile");
+		do_exit(1);
+	}
+
+	printf("%s: Closing stdio fds and writing messages to %s\n",
+			argv[0], LOG_FILE);
+
+	for (i=0; i<100; i++)  {
+		if (fileno(logfp) != i)
+			close(i);
+	}
+
+	setup_test_data();
+	event_fd1 = setup_notification();
+
+	/*
+	 * Before waiting for events below, ensure we will be notified
+	 * if a child encounters an error and/or exits prematurely.
+	 */
+	signal(SIGUSR1, child_handler);
+	signal(SIGCHLD, child_handler);
+
+	/*
+	 * Create the test processes and wait for them to be ready for
+	 * checkpoint.
+	 */
+	for (i = 0; i < 3; i ++) {
+		pid = fork();
+		if (pid == 0)
+			do_child(i);
+		test_data[i].pid = pid;
+	}
+
+	wait_for_events(event_fd1, 1);
+
+	/*
+	 * Now that the test processes are ready, tell any wrapper scripts,
+	 * we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	fprintf(logfp, "***** %d: Ready for checkpoint\n", getpid());
+	fflush(logfp);
+
+	do_wait(3);
+
+	do_exit(0);
+}
diff --git a/fileio/run-filelease1.sh b/fileio/run-filelease1.sh
new file mode 100755
index 0000000..41249a8
--- /dev/null
+++ b/fileio/run-filelease1.sh
@@ -0,0 +1,3 @@
+#!/bin/bash
+
+./run-fcntltests.sh filelease1
diff --git a/fileio/runtests.sh b/fileio/runtests.sh
index d674311..e83f9cc 100755
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -9,3 +9,8 @@ echo
 echo "****** $0: Running test: filelock1"
 echo
 ./run-fcntltests.sh filelock1
+
+echo
+echo "****** $0: Running test: filelease1"
+echo
+./run-fcntltests.sh filelease1
-- 
1.6.0.4
