From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/8] cr_tests: factor out do_ckpt()
Date: Tue,  9 Mar 2010 14:48:14 -0800
Message-ID: <c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc@us.ibm.com>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

do_ckpt() sets checkpoint-ready and waits for checkpoint-done.
Test scripts should set checkpoint-skip if tests should skip
the wait for checkpoint-done as if checkpointing were done.

This allows us to have tests with multiple checkpoints in them:

	checkpoint 1
	...
	checkpoint 2
	...

The test script can take checkpoints at each spot in turn,
saving the respective state for each. After each checkpoint
it resumes to the next until the program finishes.

Then the test script begins testing restart of each checkpoint.
This ensures that broken restarts don't prevent at least the
checkpoints from passing. It also cuts the number of times
the test program must start from scratch to 1.

However, because of the way it's designed, using all of these
features is not necessary.

To use them with any "labeled" tests, set the op_num to -1
(checkpoints at all labeled points).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/libeptest.c     |    9 ---------
 eventfd/libeptest.c   |   20 --------------------
 fs/libfstest.c        |    9 ---------
 fs/libfstest.h        |    3 ---
 libcrtest/common.c    |   20 ++++++++++++++++++++
 libcrtest/libcrtest.h |    2 ++
 6 files changed, 22 insertions(+), 41 deletions(-)

diff --git a/epoll/libeptest.c b/epoll/libeptest.c
index 95b42f8..13d9ab3 100644
--- a/epoll/libeptest.c
+++ b/epoll/libeptest.c
@@ -43,12 +43,3 @@ const char * eflags(unsigned int events)
 	return buffer;
 }
 #undef peflag
-
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void)
-{
-	set_checkpoint_ready();
-	while (!test_checkpoint_done())
-		usleep(10000);
-
-}
diff --git a/eventfd/libeptest.c b/eventfd/libeptest.c
index 88e5a9c..073b596 100644
--- a/eventfd/libeptest.c
+++ b/eventfd/libeptest.c
@@ -14,26 +14,6 @@ void print_labels(FILE *pout)
 		fprintf(pout, "\t%d\t%s\n", i, labels(i));
 }
 
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void)
-{
-	int rc;
-
-	set_checkpoint_ready();
-
-	rc = access("./checkpoint-skip", F_OK);
-	if (rc == 0)
-		return;
-	else if (errno != ENOENT)
-		exit(EXIT_FAILURE);
-
-	while (!test_checkpoint_done())
-		usleep(10000);
-	if (unlink("./checkpoint-done") == -1) {
-		/* perror("unlink(\"./checkpoint-done\")"); */
-	}
-}
-
 /* The spot (LABEL or label number) where we should test checkpoint/restart */
 char const *ckpt_label;
 int ckpt_op_num = 0;
diff --git a/fs/libfstest.c b/fs/libfstest.c
index 200dc23..fb94a52 100644
--- a/fs/libfstest.c
+++ b/fs/libfstest.c
@@ -1,12 +1,3 @@
 #include "libfstest.h"
 
 FILE *logfp = NULL;
-
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void)
-{
-	set_checkpoint_ready();
-	while (!test_checkpoint_done())
-		usleep(10000);
-
-}
diff --git a/fs/libfstest.h b/fs/libfstest.h
index 1ef3c5c..238846b 100644
--- a/fs/libfstest.h
+++ b/fs/libfstest.h
@@ -28,7 +28,4 @@ do { \
 /* like perror() except to the log */
 #define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
 
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void);
-
 #define HELLO "Hello world!\n"
diff --git a/libcrtest/common.c b/libcrtest/common.c
index 87967fd..6cfc9a9 100644
--- a/libcrtest/common.c
+++ b/libcrtest/common.c
@@ -68,6 +68,26 @@ void set_checkpoint_ready()
 	close(fd);
 }
 
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void)
+{
+	int rc;
+
+	set_checkpoint_ready();
+
+	rc = access(CKPT_SKIP, F_OK);
+	if (rc == 0)
+		return;
+	else if (errno != ENOENT)
+		do_exit(1);
+
+	while (!test_checkpoint_done())
+		usleep(10000);
+	if (unlink(CKPT_DONE) == -1) {
+		/* perror("unlink(\"./checkpoint-done\")"); */
+	}
+}
+
 void print_exit_status(int pid, int status)
 {
 	fprintf(logfp, "Pid %d unexpected exit - ", pid);
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index d4e2974..7f8cfff 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -3,6 +3,7 @@
 
 #define CKPT_READY		"checkpoint-ready"
 #define CKPT_DONE		"checkpoint-done"
+#define CKPT_SKIP		"checkpoint-skip"
 #define TEST_DONE		"test-done"
 
 extern FILE *logfp;
@@ -18,6 +19,7 @@ extern void do_exit(int status);
 extern int test_done(void);
 extern int test_checkpoint_done();
 extern void set_checkpoint_ready(void);
+extern void do_ckpt(void);
 extern int do_wait(int num_children);
 extern void copy_data(char *srcfile, char *destfile);
 extern void print_exit_status(int pid, int status);
-- 
1.6.3.3
