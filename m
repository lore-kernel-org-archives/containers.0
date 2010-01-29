From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 09/11] pthread1: Don't close stderr() before opening log
Date: Fri, 29 Jan 2010 12:43:32 -0800
Message-ID: <20100129204332.GH26721@us.ibm.com>
References: <20100129202842.GA25490@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100129202842.GA25490-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Tue, 26 Jan 2010 22:47:24 -0800
Subject: [PATCH 09/11] pthread1: Don't close stderr() before opening log

If we encounter an error while opening the log file, we write to stderr.
In which case, we need the 'stderr' to remain open at least till the log
file is open.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/pthread1.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/process-tree/pthread1.c b/process-tree/pthread1.c
index fa45127..d1743de 100644
--- a/process-tree/pthread1.c
+++ b/process-tree/pthread1.c
@@ -9,6 +9,10 @@
 
 int num_threads = 5;
 FILE *logfp;
+/*
+ * Use LOG_PREFIX with thread index as suffix, if each thread needs a
+ * separate log file. For now, we use a single log
+ */
 #define LOG_PREFIX		"logs.d/pthread1"
 
 static void usage(char *argv[])
@@ -137,7 +141,6 @@ main(int argc, char *argv[])
 	pthread_t *tid_list;
 	char log_file[256];
 
-	for (i=0; i<100; i++) close(i);
 	sprintf(log_file, "%s.log", LOG_PREFIX);
 
 	logfp = fopen(log_file, "w");
@@ -148,6 +151,13 @@ main(int argc, char *argv[])
 		do_exit(1);
 	}
 
+	fprintf(stderr, "Redirecting output to logfile %s\n", log_file);
+
+	for (i=0; i<100; i++) {
+		if (i != fileno(logfp))
+			close(i);
+	}
+
 	if (test_done()) {
 		printf("Remove %s before running test\n", TEST_DONE);
 		do_exit(1);
-- 
1.6.0.4
