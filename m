From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-test] eclone-2 bug fix
Date: Mon, 3 May 2010 19:09:19 -0700
Message-ID: <20100504020919.GB5098@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Date: Mon, 3 May 2010 17:49:32 -0700
Subject: [PATCH 1/1] eclone-2 bug fix

When target-pid is in use, eclone() returns EBUSY, not EAGAIN.  The
test passes now because eclone() correctly fails, but the test case
can do a better job of checking the errno.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/eclone-2.c |   49 ++++++++++++++++++++++++-------------------------
 1 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/eclone/eclone-2.c b/eclone/eclone-2.c
index b825ac3..5550e43 100644
--- a/eclone/eclone-2.c
+++ b/eclone/eclone-2.c
@@ -64,14 +64,11 @@ static int do_eclone(int (*child_fn)(void *), void *child_arg,
 		fflush(stdout);
 	}
 
-	if (rc < 0 && errno == EAGAIN) {
-		printf("PASS: Unable to create a process with a pid that is "
-			"in use\n");
-		exit(0);
-	} else {
-		printf("ERROR: eclone(): rc %d, errno %d\n", rc, errno);
-		return rc;
-	}
+	if (rc < 0)
+		rc = -errno;
+
+	return rc;
+
 }
 
 int main()
@@ -90,27 +87,29 @@ int main()
 
 	pid = do_eclone(do_child, CHILD_ARG, flags, nr_pids, pids);
 
-	if (verbose) {
-		printf("[%d, %d]: Parent waiting for %d\n", getpid(),
-					gettid(), pid);
+	if (pid == -EBUSY) {
+		printf("PASS: Unable to create a process with a pid that is "
+			"in use\n");
+		return 0;
+	} else if (pid < 0) {
+		printf("ERROR: eclone(): errno %d\n", pid);
+		return 1;
 	}
 
+	printf("[%d, %d]: Parent waiting for %d\n", getpid(), gettid(), pid);
+
 	rc = waitpid(pid, &status, __WALL);
-	if (rc < 0) {
-		printf("ERROR: ");
-		verbose = 1;
-	}
 
-	if (verbose) {
-		printf("\twaitpid(): child %d, rc %d, error %d, status 0x%x\n",
-				getpid(), rc, errno, status);
-		if (rc >=0) {
-			if (WIFEXITED(status)) {
-				printf("\t EXITED, %d\n", WEXITSTATUS(status));
-			} else if (WIFSIGNALED(status)) {
-				printf("\t SIGNALED, %d\n", WTERMSIG(status));
-			}
+	printf("\twaitpid(): child %d, rc %d, error %d, status 0x%x\n",
+			getpid(), rc, errno, status);
+
+	if (rc >=0) {
+		if (WIFEXITED(status)) {
+			printf("\t EXITED, %d\n", WEXITSTATUS(status));
+		} else if (WIFSIGNALED(status)) {
+			printf("\t SIGNALED, %d\n", WTERMSIG(status));
 		}
 	}
-	return 0;
+
+	return 1;
 }
-- 
1.6.6.1
