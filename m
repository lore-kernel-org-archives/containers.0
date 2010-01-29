From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 08/11] filelock1: Extend for mandatory locks
Date: Fri, 29 Jan 2010 12:43:19 -0800
Message-ID: <20100129204319.GG26721@us.ibm.com>
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
Date: Tue, 26 Jan 2010 19:38:28 -0800
Subject: [PATCH 08/11] filelock1: Extend for mandatory locks

Extend filelock1 to test for mandatory locks, when filelock1 is run
with the -m option.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/filelock1.c       |   67 +++++++++++++++++++++++++++++++++++++++------
 fileio/run-fcntltests.sh |    5 ++-
 fileio/run-filelock1.sh  |    2 +
 3 files changed, 63 insertions(+), 11 deletions(-)

diff --git a/fileio/filelock1.c b/fileio/filelock1.c
index 19f7e3b..34e9ad2 100644
--- a/fileio/filelock1.c
+++ b/fileio/filelock1.c
@@ -4,6 +4,7 @@
 #include <string.h>
 #include <signal.h>
 #include <errno.h>
+#include <sys/stat.h>
 #include "libcrtest.h"
 
 #define TEST_FILE	"data.d/data.filelock1"
@@ -13,6 +14,7 @@ extern FILE *logfp;
 int test_fd;
 int event_fd1;
 int event_fd2;
+int mandatory_locks = 1;
 
 /*
  * Description:
@@ -60,6 +62,9 @@ void set_lock(int fd, struct test_arg *tlock)
 		fprintf(logfp, "%d: set_lock(): ERROR [%d, %llu, %llu]: %s\n",
 				getpid(), tlock->type, (u64)tlock->start,
 				(u64)tlock->len, strerror(errno));
+		if (mandatory_locks)
+			fprintf(logfp, "\n\t***** Is the FS mounted with "
+					"'-o mand' option ?\n\n");
 		fflush(logfp);
 		kill(getppid(), SIGUSR1);
 		do_exit(1);
@@ -108,6 +113,9 @@ void test_lock(int fd, int locked_by_me, struct test_arg *tlock)
 	} else if (rc < 0) {
 		fprintf(logfp, "ERROR: fcntl(F_SETLK): %s, error %s\n",
 				lock_info, strerror(errno));
+		if (mandatory_locks)
+			fprintf(logfp, "\n\t***** Is the FS mounted with "
+					"'-o mand' option ?\n\n");
 		goto error;
 	}
 
@@ -215,8 +223,12 @@ int do_child1(int idx)
 void setup_test_file()
 {
 	char buf[256];
+	int mode;
+	int rc;
+
+	mode = S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH; /* 0666 */
 
-	test_fd = open(TEST_FILE, O_RDWR|O_CREAT|O_TRUNC, 0666);
+	test_fd = open(TEST_FILE, O_RDWR|O_CREAT|O_TRUNC, mode);
 	if (test_fd < 0) {
 		fprintf(logfp, "ERROR: open(%s): %s\n", TEST_FILE,
 				strerror(errno));
@@ -225,6 +237,23 @@ void setup_test_file()
 
 	memset(buf, 0, sizeof(buf));
 	write(test_fd, buf, sizeof(buf));
+
+	if (!mandatory_locks)
+		return;
+
+	/* Enable mandatory file locks (setgid, clear group execute) */
+	mode |= S_ISGID;
+	mode &= ~S_IXGRP;
+
+	rc = fchmod(test_fd, mode);
+	if (rc < 0) {
+		fprintf(logfp, "ERROR: fchmod(%s): rc %d, error %s\n",
+				TEST_FILE, rc, strerror(errno));
+		fprintf(logfp, "Maybe '-o mand' mount option is not set ?\n");
+		do_exit(1);
+	}
+	fprintf(logfp, "Mandatory locking set on %s, mode 0%o\n", TEST_FILE,
+			mode);
 }
 
 int pid1, pid2;
@@ -238,25 +267,32 @@ void child_handler(int sig)
 
 	if (sig == SIGCHLD)
 		do_wait(1);
+
 	fprintf(logfp, "%d: Test case FAILED\n", getpid());
 	fflush(logfp);
 	/*
 	 * Kill (remaining) children and exit.
 	 */
-	kill(pid1, SIGKILL);
-	kill(pid2, SIGKILL);
+	if (pid1)
+		kill(pid1, SIGKILL);
+	if (pid2)
+		kill(pid2, SIGKILL);
 
 	do_exit(-1);
 }
 
-main(int argc, char *argv[])
+usage(char *argv[])
 {
-	int i, status, rc;
+	fprintf(logfp, "Usage: %s [-m]\n", argv[0]);
+	fprintf(logfp, "\tTest POSIX (advisory) file locks (without -m)\n");
+	fprintf(logfp, "\t-m: Test mandatory file locks\n");
+	fprintf(logfp, "Test FAILED\n");
+	do_exit(1);
+}
 
-	if (test_done()) {
-		printf("Remove %s before running test\n", TEST_DONE);
-		do_exit(1);
-	}
+main(int argc, char *argv[])
+{
+	int i, c, status, rc;
 
 	logfp = fopen(LOG_FILE, "w");
 	if (!logfp) {
@@ -264,6 +300,19 @@ main(int argc, char *argv[])
 		do_exit(1);
 	}
 
+	mandatory_locks = 0;
+	while((c = getopt(argc, argv, "m")) != EOF) {
+		switch (c) {
+			case 'm': mandatory_locks = 1; break;
+			default: usage(argv);
+		}
+	}
+
+	if (test_done()) {
+		printf("Remove %s before running test\n", TEST_DONE);
+		do_exit(1);
+	}
+
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
 
diff --git a/fileio/run-fcntltests.sh b/fileio/run-fcntltests.sh
index 0b168e9..f76c942 100755
--- a/fileio/run-fcntltests.sh
+++ b/fileio/run-fcntltests.sh
@@ -2,12 +2,13 @@
 
 source ../common.sh
 
-if [ $# -ne 1 ]; then
+if [ $# -lt 1 ]; then
 	echo "Usage: $0 <test-case>";
 	exit 1;
 fi
 
 test_case=$1;
+shift
 
 if [ ! -x $test_case ]; then
 	echo "$0: Test case \'$test_case\' does not exist / not executable ?"
@@ -25,7 +26,7 @@ RESTART=`which restart`
 ECHO="/bin/echo -e"
 
 TEST_CMD="../$test_case"
-TEST_ARGS=""
+TEST_ARGS=$*
 TEST_LOG="logs.d/log.${test_case}"
 SCRIPT_LOG="logs.d/log.run-${test_case}"
 TEST_PID_FILE="pid.${test_case}";
diff --git a/fileio/run-filelock1.sh b/fileio/run-filelock1.sh
index 554c24a..b7d5cd6 100755
--- a/fileio/run-filelock1.sh
+++ b/fileio/run-filelock1.sh
@@ -1,3 +1,5 @@
 #!/bin/bash
 
 ./run-fcntltests.sh filelock1
+
+./run-fcntltests.sh filelock1 -m
-- 
1.6.0.4
