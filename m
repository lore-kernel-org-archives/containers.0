From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/4][cryo]: Test 4: Non-consecutive pipe fds
Date: Mon, 23 Jun 2008 20:34:12 -0700
Message-ID: <20080624033411.GC27709@us.ibm.com>
References: <20080624033133.GA27649@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080624033133.GA27649-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


From c7276c8cb59247faa13d42a1b871c853a80d80d1 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sun, 22 Jun 2008 22:43:01 -0700
Subject: [PATCH] Test4: Non-consecutive pipe fds

---
 tests/pipe.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/tests/pipe.c b/tests/pipe.c
index c81ac2a..5b04f46 100644
--- a/tests/pipe.c
+++ b/tests/pipe.c
@@ -5,6 +5,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <errno.h>
+#include <sys/stat.h>
 
 #define min(a, b)	((a) < (b) ? (a) : (b))
 static char *temp_file;
@@ -20,7 +21,7 @@ char *test_descriptions[] = {
 	"Test with all-fds in use for pipes",
 };
 
-static int last_num = 3;
+static int last_num = 4;
 usage(char *argv[])
 {
 	int i;
@@ -84,13 +85,50 @@ int test2()
 	}
 }
 
-int read_write_pipe()
+
+reset_pipe_fds(int *tmpfds, int *testfds, int close_unused)
+{
+	struct stat statbuf;
+	int rc;
+
+	if (fstat(testfds[0], &statbuf) == 0) {
+		printf("fd %d is in use...\n", testfds[0]);
+		exit(1);
+	}
+	if (fstat(testfds[1], &statbuf) == 0) {
+		printf("fd %d is in use...\n", testfds[1]);
+		exit(1);
+	}
+
+	rc = dup2(tmpfds[0], testfds[0]);
+	if (rc < 0) {
+		printf("dup2(%d, %d) failed, error %d\n",
+				tmpfds[0], testfds[0], rc, errno);
+		exit(1);
+	}
+
+	rc = dup2(tmpfds[1], testfds[1]);
+	if (rc < 0) {
+		printf("dup2(%d, %d) failed, error %d\n",
+				tmpfds[1], testfds[1], rc, errno);
+		exit(1);
+	}
+
+	if (close_unused) {
+		close(tmpfds[0]);
+		close(tmpfds[1]);
+	}
+}
+
+#define TEST_NON_CONSECUTIVE_FD 0x1
+
+int read_write_pipe(int *testfdsp, int close_unused)
 {
 	int i = 0;
 	int rc;
-	int fds[2];
-	int fd1, fd2;
+	int tmpfds[2];
 	int c;
+	int read_fd, write_fd;
 	char *wbufp;
 	char wbuf[256];
 	char rbuf[256];
@@ -102,13 +140,23 @@ int read_write_pipe()
 	strcpy(wbufp, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
 	memset(rbufp, '\0', sizeof(rbuf));
 
-	if (pipe(fds) < 0) {
+	if (pipe(tmpfds) < 0) {
 		perror("pipe()");
 		exit(1);
 	}
-	printf("fds[0] %d, fds[1] %d\n", fds[0], fds[1]);
 
-	if (fcntl(fds[0], F_SETFL, O_NONBLOCK) < 0) {
+	if (testfdsp) {
+		reset_pipe_fds(tmpfds, testfdsp, close_unused);
+		read_fd = testfdsp[0];
+		write_fd = testfdsp[1];
+	} else {
+		read_fd = tmpfds[0];
+		write_fd = tmpfds[1];
+	}
+
+	printf("read_fd %d, write_fd %d\n", read_fd, write_fd);
+
+	if (fcntl(read_fd, F_SETFL, O_NONBLOCK) < 0) {
 		perror("fcntl()");
 		exit(1);
 	}
@@ -118,7 +166,7 @@ int read_write_pipe()
 		sleep(1);
 		if (i%2 == 0) {
 			c = errno = 0;
-			rc = read(fds[0], rbufp, 3);
+			rc = read(read_fd, rbufp, 3);
 
 			if (rc < 0)
 				perror("read() failed");
@@ -132,7 +180,7 @@ int read_write_pipe()
 				continue;
 
 			errno = 0;
-			rc = write(fds[1], wbufp, min(3, strlen(wbufp)));
+			rc = write(write_fd, wbufp, min(3, strlen(wbufp)));
 			if (rc < 0) {
 				perror("write() to pipe");
 			} else {
@@ -156,7 +204,14 @@ int read_write_pipe()
 
 static void test3()
 {
-	read_write_pipe();
+	read_write_pipe(NULL, 1);
+}
+
+static void test4()
+{
+	int tmpfds[2] = { 172, 101 };
+
+	read_write_pipe(tmpfds, 1);
 }
 
 int
@@ -182,6 +237,7 @@ main(int argc, char *argv[])
 	case 1: test1(); break;
 	case 2: test2(); break;
 	case 3: test3(); break;
+	case 4: test4(); break;
 	default:
 		printf("Unsupported test case %d\n", tc_num);
 		usage(argv);
-- 
1.5.2.5
