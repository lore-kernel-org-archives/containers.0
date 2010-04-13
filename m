From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] cr_tests: futex: pi: Factor out release_pi_futex()
Date: Tue, 13 Apr 2010 15:25:13 -0700
Message-ID: <fb0d102d20653e6715ae7229e3d07263f98456ce.1271197507.git.matthltc@us.ibm.com>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Try to make the control flow of this function easier to analyze.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 futex/pi.c |   61 ++++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/futex/pi.c b/futex/pi.c
index 41f539b..53d4c5d 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -392,6 +392,34 @@ int child_static_priority(int child_num)
 	return prio_min + child_num; /* inverted: + (N - 1 - child_num);*/
 }
 
+void release_pi_futex(int *retries, int *retval, pid_t tid)
+{
+	int pi_val;
+
+	do {
+		/* Release the futex */
+		pi_val = atomic_cmpxchg(pi_futex, tid, 0);
+		if (pi_val != tid) {
+		    switch (do_unlock_contended_pi_futex(*retries)) {
+		    case -1: /* error -- we already logged the details */
+			    *retval = -100;
+			    break;
+		    case 0: /* ok */
+			    break;
+		    case 1: /* try again */
+			    if (retries) {
+				    retries--;
+				    continue;
+			    }
+			    *retval = -101;
+			    break;
+		    }
+		} /* else we were the last to hold the futex */
+	} while(retries);
+
+	log("INFO", "exited the critical section\n");
+}
+
 int kid(void *child_num_as_pointer)
 {
 	pid_t tid = gettid();
@@ -441,7 +469,8 @@ int kid(void *child_num_as_pointer)
 		pi_val = atomic_cmpxchg(pi_futex, 0, tid);
 		if (pi_val == tid) {
 			log("WARN", "found uncontended pi futex.\n");
-			goto release_pi_futex;
+			release_pi_futex(&retries, &retval, tid);
+			goto out;
 		}
 		retval--;
 
@@ -456,7 +485,8 @@ int kid(void *child_num_as_pointer)
 		retval--;
 		if (get_dynamic_priority(tid, &held_prio)) {
 			log("FAIL", "could not get priority.\n");
-			goto release_pi_futex;
+			release_pi_futex(&retries, &retval, tid);
+			goto out;
 		}
 		retval--;
 
@@ -467,7 +497,8 @@ int kid(void *child_num_as_pointer)
 			 * should wake the next highest priority waiter.
 			 */
 			log("FAIL", "Not woken in priority order.\n");
-			goto release_pi_futex;
+			release_pi_futex(&retries, &retval, tid);
+			goto out;
 		}
 		log("PASS", "Woken in priority order.\n");
 		retval = 0;
@@ -499,7 +530,8 @@ int kid(void *child_num_as_pointer)
 			/* Compare our priority to what we set above. */
 			if (get_dynamic_priority(tid, &held_prio)) {
 				retries = 100;
-				goto release_pi_futex;
+				release_pi_futex(&retries, &retval, tid);
+				goto out;
 			}
 			usleep(1000);
 			retries--;
@@ -522,26 +554,7 @@ int kid(void *child_num_as_pointer)
 		}
 	}
 
-release_pi_futex:
-	/* Release the futex */
-	pi_val = atomic_cmpxchg(pi_futex, tid, 0);
-	if (pi_val != tid) {
-	    switch (do_unlock_contended_pi_futex(retries)) {
-	    case -1: /* error -- we already logged the details */
-		    retval = -100;
-		    break;
-	    case 0: /* ok */
-		    break;
-	    case 1: /* try again */
-		    if (retries) {
-			    retries--;
-			    goto release_pi_futex;
-		    }
-		    retval = -101;
-		    break;
-	    }
-	} /* else we were the last to hold the futex */
-	log("INFO", "exited the critical section\n");
+	release_pi_futex(&retries, &retval, tid);
 out:
 	log("INFO", "exiting\n");
 	/* smp_mb() ?? */
-- 
1.6.3.3
