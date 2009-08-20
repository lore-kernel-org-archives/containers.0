From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 01/11] cr_tests: Add timeout to robust futex test.
Date: Wed, 19 Aug 2009 21:58:04 -0700
Message-ID: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc@us.ibm.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The robust futex test can hang if the kernel fails to properly set the
robust list pointer. This currently happens during restart. The test should not
hang and instead should report failure.

Use a timeout to ensure that hangs are caught and reported as failure.
The timeout should return ETIMEDOUT. This limits the total amount of
time checkpoint/restart can take so a suitable timeout is essential here.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/robust.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/futex/robust.c b/futex/robust.c
index 1025515..304c35f 100644
--- a/futex/robust.c
+++ b/futex/robust.c
@@ -103,6 +103,10 @@ void add_rfutex(struct futex *rf)
 
 void acquire_rfutex(struct futex *rf, pid_t tid)
 {
+	struct timespec timeout = {
+		.tv_sec = 5,
+		.tv_nsec = 0
+	};
 	int oldval, newval, val = 0;
 
 	rlist.list_op_pending = &rf->rlist; /* ARCH TODO make sure this assignment is atomic */
@@ -126,7 +130,7 @@ void acquire_rfutex(struct futex *rf, pid_t tid)
 		val = __sync_or_and_fetch(&rf->tid.counter, FUTEX_WAITERS);
 		log("INFO", "futex(FUTEX_WAIT, %x)\n", val);
 		if (futex(&rf->tid.counter, FUTEX_WAIT, val,
-			  NULL, NULL, 0) == 0)
+			  &timeout, NULL, 0) == 0)
 			break;
 		log("INFO", "futex returned with errno %d (%s).\n", errno, strerror(errno));
 		switch(errno) {
@@ -147,8 +151,9 @@ void acquire_rfutex(struct futex *rf, pid_t tid)
 				log("WARN", "EINTR while sleeping on futex\n");
 				continue;
 			case ETIMEDOUT:
-				log("WARN", "ETIMEDOUT while sleeping on futex\n");
-				continue;
+				log("FAIL", "ETIMEDOUT while sleeping on futex.\n");
+				fail++;
+				return;
 			case EACCES:
 				log("FAIL", "FUTEX_WAIT EACCES - no read access to futex memory\n");
 				fail++;
-- 
1.5.6.3
