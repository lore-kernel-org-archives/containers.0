From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Make tst_ipcshm_multi automatable
Date: Mon, 13 Apr 2009 12:26:48 -0700
Message-ID: <1239650808-22254-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Add a little to tst_ipcshm_multi to make it automatically validate the
results and return a pass/fail status indication for automated runs.

Since Oren said he applied my previous patch to his repository, I'm
sending this as a delta from the last one I sent[1].  Since the public
user-cr is not updated yet, you'll need to apply that first to try this.

1: https://lists.linux-foundation.org/pipermail/containers/2009-April/016827.html

Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 tst_ipcshm_multi.c |   86 ++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 70 insertions(+), 16 deletions(-)

diff --git a/tst_ipcshm_multi.c b/tst_ipcshm_multi.c
index 1ef31f7..1bc0cd2 100644
--- a/tst_ipcshm_multi.c
+++ b/tst_ipcshm_multi.c
@@ -4,6 +4,8 @@
 #include <errno.h>
 #include <sys/ipc.h>
 #include <sys/shm.h>
+#include <sys/types.h>
+#include <sys/wait.h>
 
 #include <linux/sched.h>
 #include <sched.h>
@@ -11,6 +13,7 @@
 #define OUTFILE  "/tmp/cr-test.out"
 #define SEG_SIZE (20 * 4096)
 #define DELAY 20
+#define COUNT_MAX 15
 
 int attach(unsigned char **seg, int num)
 {
@@ -50,14 +53,45 @@ int validate(unsigned char *seg, int num)
 	return 0;
 }
 
-void track(unsigned char *seg, int num)
+int track_incr(unsigned char *seg, int num)
 {
 	int i;
+	int last = seg[0];
 
 	for (i = 0; i < 20; i++) {
+		if (seg[0] == COUNT_MAX)
+			break;
+
+		if (abs(last - (int)seg[0]) > 1) {
+			printf("[CHILD %i] Expected +/-%i (got %i) %i\n",
+			       num, last, seg[0], abs(last - seg[0]));
+			return 1;
+		}
+
+		last = seg[0] + 1;
+
 		printf("[CHILD %i] Seg[0]: %i\n", num, seg[0]);
 		sleep(1);
 	}
+
+	return !(seg[0] == COUNT_MAX);
+}
+
+int track_const(unsigned char *seg, int num, int val)
+{
+	int i;
+
+	for (i = 0; i < 20; i++) {
+		if (seg[0] != val) {
+			printf("[CHILD %i] Expected %i not %i\n",
+			       num, val, seg[0]);
+			return 1;
+		}
+		printf("[CHILD %i] Seg[0]: %i\n", num, seg[0]);
+		sleep(1);
+	}
+
+	return 0;
 }
 
 /*
@@ -81,9 +115,7 @@ int child1(void)
 
 	sleep(DELAY - 1); /* Wait until after the checkpoint */
 
-	track(seg, num);
-
-	return 0;
+	return track_incr(seg, num);
 }
 
 /*
@@ -106,12 +138,10 @@ int child2(void)
 	if (validate(seg, num))
 		return -1;
 
-	track(seg, num);
-
-	return 0;
+	return track_incr(seg, num);
 }
 
-int child4(void);
+int child4(int constval);
 
 /*
  * Detach from the parent's IPC namespace and verify that:
@@ -123,14 +153,20 @@ int child3(void)
 {
 	unsigned char *seg;
 	int num = 3;
+	int cpid;
+	int ret;
+	int status;
 
 	if (unshare(CLONE_NEWIPC) != 0) {
 		printf("[CHILD %i] unshare(CLONE_NEWIPC): %m", num);
 		return -1;
 	}
 
-	if (fork() == 0)
-		return child4();
+	cpid = fork();
+	if (cpid < 0)
+		return 1;
+	else if (cpid == 0)
+		return child4(123);
 
 	printf("[CHILD %i] Running (new IPC NS)\n", num);
 
@@ -153,16 +189,22 @@ int child3(void)
 
 	sleep(DELAY); /* Wait until after checkpoint, then attach */
 
-	track(seg, num);
-  
-	return 0;
+	ret = track_const(seg, num, 123);
+
+	printf("[CHILD %i] Waiting for child %i\n", num, cpid);
+	wait(&status);
+
+	if (ret == 0)
+		return WEXITSTATUS(status);
+	else
+		return ret;
 }
 
 /*
  * This child is forked from child3 under the new IPC namespace.
  * Verify that post-restart, we do not see the changing seg[0]
  */
-int child4(void)
+int child4(int constval)
 {
 	unsigned char *seg;
 	int num = 4;
@@ -174,7 +216,7 @@ int child4(void)
 	if (attach(&seg, num))
 		return -1;
 
-	track(seg, num);
+	return track_const(seg, num, constval);
 
 	return 0;
 }
@@ -250,11 +292,23 @@ int main(int argc, char *argv[])
 	sleep(DELAY);
 	printf("[MSTER] Woke\n");
 
-	for (i = 0; i < 15; i++) {
+	for (i = 0; i <= COUNT_MAX; i++) {
 		seg[0] = i;
 		sleep(1);
 	}
 
+	for (i = 0; i < 3; i++) {
+		int status;
+
+		printf("[MSTER] Waiting on child %i\n", i+1);
+		wait(&status);
+		if (WEXITSTATUS(status)) {
+			printf("[MSTER] child exited with %i\n",
+			       WEXITSTATUS(status));
+			return WEXITSTATUS(status);
+		}
+	}
+
 	if (shmdt(seg) < 0)
 		perror("shmdt");
 
-- 
1.6.0.3
