From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 07/11] fsetown1: Test async I/O notification after restart
Date: Fri, 29 Jan 2010 12:43:04 -0800
Message-ID: <20100129204304.GF26721@us.ibm.com>
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
Date: Thu, 21 Jan 2010 23:07:51 -0800
Subject: [PATCH 07/11] fsetown1: Test async I/O notification after restart

Checkpoint a process that is waiting for async notification of data
being available on a pipe. When the process is restarted, make data
available on the pipe and ensure that the process is notified.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/Makefile        |    4 +-
 fileio/fsetown1.c      |  268 ++++++++++++++++++++++++++++++++++++++++++++++++
 fileio/run-fsetown1.sh |    3 +
 fileio/runtests.sh     |    5 +
 libcrtest/common.c     |    2 +-
 5 files changed, 279 insertions(+), 3 deletions(-)
 create mode 100644 fileio/fsetown1.c
 create mode 100755 fileio/run-fsetown1.sh

diff --git a/fileio/Makefile b/fileio/Makefile
index acc2df9..bd28561 100644
--- a/fileio/Makefile
+++ b/fileio/Makefile
@@ -1,4 +1,4 @@
-targets = fileio1 filelock1 filelease1
+targets = fileio1 filelock1 filelease1 fsetown1
 
 INCLUDE   = ../libcrtest
 LIBCRTEST = ../libcrtest/common.o
@@ -9,4 +9,4 @@ all: $(LIBCRTEST) $(targets)
 
 clean:
 	rm -f $(targets)
-	rm -rf cr_fileio* cr_filelock1* cr_filelease1*
+	rm -rf cr_fileio* cr_filelock1* cr_filelease1* cr_fsetown1*
diff --git a/fileio/fsetown1.c b/fileio/fsetown1.c
new file mode 100644
index 0000000..c6c5734
--- /dev/null
+++ b/fileio/fsetown1.c
@@ -0,0 +1,268 @@
+#include <stdio.h>
+#include <unistd.h>
+#define __USE_GNU
+#include <fcntl.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include <wait.h>
+#include "libcrtest.h"
+
+#define LOG_FILE	"logs.d/log.fsetown1"
+
+int pipe_fds[2];
+int event_fd1;
+int got_sigio;
+
+/*
+ * Description:
+ * 	Checkpoint a process that is waiting for async notification of data
+ * 	being available on a pipe. When the process is restarted, make data
+ * 	available on the pipe and ensure that the process is notified.
+ *
+ * Implementation:
+ */
+void iohandler(int sig)
+{
+	int rc;
+	char buf[16];
+
+	fprintf(logfp, "%d: Got signal %d\n", getpid(), sig);
+	fflush(logfp);
+	got_sigio = 1;
+}
+
+static void wait_for_child()
+{
+	int rc;
+	int status;
+
+	rc = waitpid(-1, &status, 0);
+	if (rc < 0) {
+		fprintf(logfp, "%d: waitpid(): rc %d, error %s\n",
+				getpid(), rc, strerror(errno));
+		do_exit(1);
+	}
+
+	if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
+		fprintf(logfp, "%d: Test case PASSED\n", getpid());
+		rc = 0;
+	} else {
+		fprintf(logfp, "%d: Test case FAILED\n", getpid());
+		print_exit_status(rc, status);
+		rc = 1;
+	}
+	do_exit(rc);
+}
+
+void set_owner(int fd)
+{
+	int rc;
+	long flags;
+
+	fprintf(logfp, "%d: Setting owner to myself\n", getpid());
+
+	signal(SIGIO, iohandler);
+
+	flags = O_ASYNC;
+	rc = fcntl(fd, F_SETFL, flags);
+	if (rc < 0) {
+		fprintf(logfp, "%d: set_owner(): F_SETFL ERROR %s\n", getpid(),
+				strerror(errno));
+		goto error;
+	}
+
+	rc = fcntl(fd, F_SETOWN, getpid());
+	if (rc < 0) {
+		fprintf(logfp, "%d: set_owner():, ERROR %s\n", getpid(),
+				strerror(errno));
+		if (errno == EINVAL)
+			fprintf(logfp, "%d: Maybe the fs does not support "
+					"F_SETLEASE (eg: NFS)\n", getpid());
+		goto error;
+	}
+
+	fprintf(logfp, "%d: Set owner() done\n", getpid());
+	return;
+
+error:
+	/*
+	 * Parent will be waiting for notification. Signal that we failed
+	 * and are exiting
+	 */
+	kill(getppid(), SIGUSR1);
+	do_exit(1);
+}
+
+/*
+ * Called by parent to see if child is still the owner
+ */
+void test_owner(int fd, int exp_owner)
+{
+	int rc;
+
+	rc = fcntl(fd, F_GETOWN, 0);
+	if (rc < 0) {
+		fprintf(logfp, "%d: ERROR: fcntl(F_GETOWN) error %s\n",
+				getpid(), strerror(errno));
+		do_exit(1);
+	}
+
+	if (rc != exp_owner) {
+		fprintf(logfp, "%d: FAILED: Expected owner %d, actual %d\n",
+				getpid(), exp_owner, rc);
+		/*
+		 * Terminate the child since it will not be notified of I/O.
+		 */
+		kill(exp_owner, SIGKILL);
+		wait_for_child();
+		do_exit(1);
+	}
+
+	fprintf(logfp, "%d: PASS: Owner is %d\n", getpid(), exp_owner);
+	return;
+}
+
+int do_child()
+{
+	int rc;
+	char buf[16];
+	int fd = pipe_fds[0];
+
+	set_owner(fd);
+
+	/*
+	 * Tell parent we are ready for checkpoint...
+	 */
+	notify_one_event(event_fd1);
+
+	/*
+	 * Read data from the pipe. If this synchronous read finds data
+	 * without a SIGIO signal, then we were not notified and the
+	 * test fails.
+	 */
+	fprintf(logfp, "%d: Waiting for data to be available\n", getpid());
+	fflush(logfp);
+
+	rc = read(fd, buf, 4);
+	if (rc <= 0) {
+		fprintf(logfp, "%d: ERROR: read(): rc %d, error %s\n",
+				getpid(), rc, strerror(errno));
+		do_exit(1);
+	} else if (!got_sigio) {
+		fprintf(logfp, "%d: FAILED: read() found data but did not"
+				"get SIGIO, rc %d buf %.4s\n", getpid(),
+				rc, buf);
+		do_exit(1);
+	} else {
+		fprintf(logfp, "%d: PASS: Got SIGIO, read data, rc %d, "
+				"buf '%.4s'\n", getpid(), rc, buf);
+		do_exit(0);
+	}
+}
+
+/*
+ * Create a pipe that the child will try to read from and parent will
+ * write to.
+ */
+void setup_test_data()
+{
+	int rc;
+
+	rc = pipe(pipe_fds);
+	if (rc < 0) {
+		fprintf(logfp, "%d: pipe() failed, rc %d, error %s\n",
+				getpid(), rc, strerror(errno));
+		do_exit(1);
+	}
+
+	return;
+}
+
+void usr1_handler(int sig)
+{
+	/*
+	 * Test failed or a child encountered an error.
+	 * Reap the child, report error and exit.
+	 */
+	fprintf(logfp, "%d: Signal %d, Test case FAILED\n", getpid(), sig);
+	fflush(logfp);
+
+	wait_for_child();
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
+	 * if a child encounters an error.
+	 */
+	signal(SIGUSR1, usr1_handler);
+
+	/*
+	 * Create the child process and wait for it to be ready for checkpoint.
+	 */
+	pid = fork();
+	if (pid == 0)
+		do_child(i);
+
+	if (pid < 0) {
+		fprintf(logfp, "%d: fork() failed, rc %d, error %s\n", getpid(),
+				rc, strerror(errno));
+		do_exit(1);
+	}
+
+	wait_for_events(event_fd1, 1);
+
+	/*
+	 * Tell any wrapper scripts, we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	fprintf(logfp, "%d: ***** Ready for checkpoint\n", getpid());
+	fflush(logfp);
+
+	/* Wait for wrappers to complete checkpoint/restart */
+	while(!test_done())
+		sleep(1);
+
+	/* Ensure that child is still owner for the read side of pipe */
+	test_owner(pipe_fds[0], pid);
+
+	/* Make data available on the pipe for the child */
+	rc = write(pipe_fds[1], "done", 4);
+	if (rc < 0) {
+		fprintf(logfp, "%d: write() failed, rc %d, error %s\n",
+				getpid(), rc, strerror(errno));
+		kill(pid, SIGKILL);
+		do_exit(1);
+	}
+
+	fflush(logfp);
+	wait_for_child();
+}
diff --git a/fileio/run-fsetown1.sh b/fileio/run-fsetown1.sh
new file mode 100755
index 0000000..535c544
--- /dev/null
+++ b/fileio/run-fsetown1.sh
@@ -0,0 +1,3 @@
+#!/bin/bash
+
+./run-fcntltests.sh fsetown1
diff --git a/fileio/runtests.sh b/fileio/runtests.sh
index e83f9cc..b808927 100755
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -14,3 +14,8 @@ echo
 echo "****** $0: Running test: filelease1"
 echo
 ./run-fcntltests.sh filelease1
+
+echo
+echo "****** $0: Running test: fsetown1"
+echo
+./run-fcntltests.sh fsetown1
diff --git a/libcrtest/common.c b/libcrtest/common.c
index b29042a..c20da5e 100644
--- a/libcrtest/common.c
+++ b/libcrtest/common.c
@@ -58,7 +58,7 @@ void set_checkpoint_ready()
 	close(fd);
 }
 
-static void print_exit_status(int pid, int status)
+void print_exit_status(int pid, int status)
 {
 	fprintf(logfp, "Pid %d unexpected exit - ", pid);
 	if (WIFEXITED(status)) {
-- 
1.6.0.4
