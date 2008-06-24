From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/4][cryo]: Test 5: Read/write using dup() of pipe fds
Date: Mon, 23 Jun 2008 20:34:54 -0700
Message-ID: <20080624033454.GD27709@us.ibm.com>
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

From 121c33ebe1ae201d5bb051f9c76e3eaae29329bb Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sun, 22 Jun 2008 23:33:24 -0700
Subject: [PATCH] Test 5: Read/write using dup() of pipe fds

---
 tests/pipe.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/tests/pipe.c b/tests/pipe.c
index 5b04f46..47f5da6 100644
--- a/tests/pipe.c
+++ b/tests/pipe.c
@@ -16,12 +16,13 @@ char *test_descriptions[] = {
 	"Test continous reads/writes from pipe",
 	"Test non-consecutive pipe-fds",
 	"Test with read-fd > write-fd",
+	"Test with dup of pipe fds around"
 	"Test with read-fd/write-fd swapped",
 	"Test with all-fds in use",
 	"Test with all-fds in use for pipes",
 };
 
-static int last_num = 4;
+static int last_num = 5;
 usage(char *argv[])
 {
 	int i;
@@ -145,13 +146,13 @@ int read_write_pipe(int *testfdsp, int close_unused)
 		exit(1);
 	}
 
+	read_fd = tmpfds[0];
+	write_fd = tmpfds[1];
 	if (testfdsp) {
 		reset_pipe_fds(tmpfds, testfdsp, close_unused);
+		/* read from dup'd fds even if main ones are open */
 		read_fd = testfdsp[0];
 		write_fd = testfdsp[1];
-	} else {
-		read_fd = tmpfds[0];
-		write_fd = tmpfds[1];
 	}
 
 	printf("read_fd %d, write_fd %d\n", read_fd, write_fd);
@@ -193,7 +194,7 @@ int read_write_pipe(int *testfdsp, int close_unused)
 		}
 	}
 
-	if (strncmp(wbuf, rbuf, strlen(wbufp))) {
+	if (strncmp(wbuf, rbuf, strlen(wbuf))) {
 		printf("Wrote: %s\n", wbuf);
 		printf("Read : %s\n", rbuf);
 		printf("Test FAILED\n");
@@ -214,6 +215,13 @@ static void test4()
 	read_write_pipe(tmpfds, 1);
 }
 
+static void test5()
+{
+	int tmpfds[2] = { 172, 101 };
+
+	read_write_pipe(tmpfds, 0);
+}
+
 int
 main(int argc, char *argv[])
 {
@@ -238,6 +246,7 @@ main(int argc, char *argv[])
 	case 2: test2(); break;
 	case 3: test3(); break;
 	case 4: test4(); break;
+	case 5: test5(); break;
 	default:
 		printf("Unsupported test case %d\n", tc_num);
 		usage(argv);
-- 
1.5.2.5
