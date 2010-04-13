From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] cr_tests: futex: pu: Fix potential livelock
Date: Tue, 13 Apr 2010 15:25:14 -0700
Message-ID: <4b62b2004556809368f788e9baaf39c529dc3d80.1271197507.git.matthltc@us.ibm.com>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc@us.ibm.com>
	<fb0d102d20653e6715ae7229e3d07263f98456ce.1271197507.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <fb0d102d20653e6715ae7229e3d07263f98456ce.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Fixup flow of release_pi_futex to truly break out of the loop during
an error.

Also, since it's not used, remove the retries parameter from
do_unlock_contended_futex.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 futex/pi.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/futex/pi.c b/futex/pi.c
index 53d4c5d..a39964d 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -330,7 +330,7 @@ again:
 	return -1;
 }
 
-int do_unlock_contended_pi_futex(int retries)
+int do_unlock_contended_pi_futex(void)
 {
 	if (futex(&pi_futex->counter, FUTEX_UNLOCK_PI, 1, NULL, NULL, 0) == 0)
 		return 0;
@@ -400,12 +400,12 @@ void release_pi_futex(int *retries, int *retval, pid_t tid)
 		/* Release the futex */
 		pi_val = atomic_cmpxchg(pi_futex, tid, 0);
 		if (pi_val != tid) {
-		    switch (do_unlock_contended_pi_futex(*retries)) {
+		    switch (do_unlock_contended_pi_futex(void)) {
 		    case -1: /* error -- we already logged the details */
 			    *retval = -100;
-			    break;
+			    retries--;
 		    case 0: /* ok */
-			    break;
+			    goto released;
 		    case 1: /* try again */
 			    if (retries) {
 				    retries--;
@@ -416,6 +416,7 @@ void release_pi_futex(int *retries, int *retval, pid_t tid)
 		    }
 		} /* else we were the last to hold the futex */
 	} while(retries);
+released:
 
 	log("INFO", "exited the critical section\n");
 }
-- 
1.6.3.3
