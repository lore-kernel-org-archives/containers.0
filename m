From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] cr_tests: futex: pi: Adjust RT priority range
Date: Tue, 13 Apr 2010 15:25:12 -0700
Message-ID: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc@us.ibm.com>
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

Merely checking the priority values does not work on some systems. For example,
my Fedora 12 system shows default realtime priority limits of 0 (soft) 0 (hard)
even for root.

Instead, read the limits and attempt to set them such that they will work
for the test. If we fail to set them then fail the test as well.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 futex/pi.c |   91 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 62 insertions(+), 29 deletions(-)

diff --git a/futex/pi.c b/futex/pi.c
index 36a357c..41f539b 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -552,6 +552,67 @@ out:
 	return retval;
 }
 
+void set_rtprio_range(void)
+{
+	struct rlimit lim;
+	int num_tries;
+
+	/*
+	 * These are the maximums allowed by the scheduler --
+	 * not the maximum prios we are permitted to set. Hence
+	 * the rlimit bits below.
+	 */
+	prio_min = sched_get_priority_min(sched_policy);
+	prio_max = sched_get_priority_max(sched_policy);
+	if (prio_min < 0  || prio_max < 0) {
+		log_error("sched_get_priority_min|max");
+		fclose(logfp);
+		exit(1);
+	}
+
+	if ((prio_max - prio_min) < 1) {
+		log("FAIL", "Too fewer priority levels for this test.\n");
+		fclose(logfp);
+		exit(13);
+	}
+	if (N > (prio_max - prio_min)) {
+		N = prio_max - prio_min;
+		log("WARN", "Fewer priority levels than specified processes. Using %d processes (the number of priority levels)\n", N);
+	}
+
+	for (num_tries = 2; num_tries; num_tries--) {
+
+		if (getrlimit(RLIMIT_RTPRIO, &lim) == -1) {
+			log_error("getrlimit");
+			fclose(logfp);
+			exit(12);
+		}
+		if (lim.rlim_cur == RLIM_INFINITY)
+			break;
+		if (lim.rlim_cur >= N)
+			break;
+
+		/* Else we must try to adjust the allowable range */
+		if (lim.rlim_cur < N)
+			lim.rlim_cur = N;
+		if (lim.rlim_cur > lim.rlim_max)
+			lim.rlim_max = lim.rlim_cur;
+		if (setrlimit(RLIMIT_RTPRIO, &lim) == -1) {
+			log_error("setrlimit");
+			fclose(logfp);
+			exit(10);
+		}
+	}
+
+	if (getrlimit(RLIMIT_RTPRIO, &lim) == -1) {
+		log_error("getrlimit");
+		fclose(logfp);
+		exit(13);
+	}
+	log("INFO", "RLIMIT_RTPRIO: soft (cur): %ld hard (max): %ld\n",
+		lim.rlim_cur, lim.rlim_max);
+}
+
 int main(int argc, char **argv)
 {
 	struct sched_param proc_sched_param;
@@ -574,28 +635,7 @@ int main(int argc, char **argv)
 	dup2(fileno(logfp), 1);
 	dup2(fileno(logfp), 2);
 
-	prio_min = sched_get_priority_min(sched_policy);
-	prio_max = sched_get_priority_max(sched_policy);
-	if (prio_min < 0  || prio_max < 0) {
-		log_error("sched_get_priority_min|max");
-		fclose(logfp);
-		exit(1);
-	}
-
-	/* rlimit also restricts prio_max */
-	{
-		struct rlimit lim;
-		getrlimit(RLIMIT_RTPRIO, &lim);
-		log("INFO", "RLIMIT_RTPRIO: soft (cur): %ld hard (max): %ld\n",
-			lim.rlim_cur, lim.rlim_max);
-		if (lim.rlim_cur == 0) {
-			log("FAIL", "process is restricted from manipulating priorities.\n");
-			fclose(logfp);
-			exit(2);
-		}
-		if (lim.rlim_cur > prio_max)
-			prio_max = lim.rlim_cur;
-	}
+	set_rtprio_range();
 
 	proc_sched_param.sched_priority = prio_min;
 	if (sched_setscheduler(getpid(), sched_policy,
@@ -604,13 +644,6 @@ int main(int argc, char **argv)
 		fclose(logfp);
 		exit(3);
 	}
-	if (N > (prio_max - prio_min))
-		N = prio_max - prio_min;
-	if (N < 1) {
-		log("FAIL", "Not enough priority levels to run test.\n");
-		fclose(logfp);
-		exit(4);
-	}
 
 	log("INFO", "running test with %d children\n", N);
 
-- 
1.6.3.3
