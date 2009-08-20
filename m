From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 03/11] cr_tests: Always report an exit code that could
	indicate failure.
Date: Wed, 19 Aug 2009 21:58:06 -0700
Message-ID: <76a291414f32bcd5af54b641e0be556868af9cbe.1250744013.git.matthltc@us.ibm.com>
References: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Restructure the exit paths of the children to always report the exit and
check the pass/fail variables before exiting.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/robust.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/futex/robust.c b/futex/robust.c
index 05fd4e9..f63b7d1 100644
--- a/futex/robust.c
+++ b/futex/robust.c
@@ -259,13 +259,14 @@ int kid(int i)
 {
 	if (set_robust_list(&rlist, sizeof(rlist)) < 0) {
 		log_error("set_robust_list");
-		fail++;
 		send_parent_status(&children_ready[1], CHILD_ERROR);
-		return -1;
+		fail++;
+		goto do_exit;
 	}
 	if (check_rlist(i) != 0) {
 		send_parent_status(&children_ready[1], CHILD_ERROR);
-		return -1;
+		fail++;
+		goto do_exit;
 	}
 
 	log("INFO", "signaling ready for checkpointing\n");
@@ -274,18 +275,20 @@ int kid(int i)
 
 	if (check_rlist(i) != 0) {
 		send_parent_status(&children_ready[1], CHILD_ERROR);
-		return -1;
+		fail++;
+		goto do_exit;
 	}
 
 	send_parent_status(&children_ready[1], CHILD_READY);
 	acquire_rfutex(test_futex, gettid());
+	pass++;
 
 	/*
 	 * Now exit instead of releasing the futex. This should cause
 	 * the kernel to wake the next waiter with FUTEX_OWNER_DIED.
 	 */
+do_exit:
 	log("INFO", "exiting\n");
-	pass++;
 	if (pass && !fail)
 		exit(EXIT_SUCCESS);
 	exit(EXIT_FAILURE);
-- 
1.5.6.3
