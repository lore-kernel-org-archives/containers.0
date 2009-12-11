From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] Have threads wait in pthread_cond_wait()
Date: Thu, 10 Dec 2009 20:10:04 -0800
Message-ID: <20091211041004.GB20947@us.ibm.com>
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
Date: Wed, 9 Dec 2009 10:09:08 +0530
Subject: [PATCH] Have threads wait in pthread_cond_wait()

Rather than sleep() have the threads wait in pthread_cond_wait() for
the checkpoint and ensure they are properly signalled after restart.
Also add some debug messages.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/pthread1.c |   66 +++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 61 insertions(+), 5 deletions(-)

diff --git a/process-tree/pthread1.c b/process-tree/pthread1.c
index c9e849c..fa45127 100644
--- a/process-tree/pthread1.c
+++ b/process-tree/pthread1.c
@@ -5,6 +5,7 @@
 #include <string.h>
 #include <stdlib.h>
 #include <libcrtest.h>
+#include <pthread.h>
 
 int num_threads = 5;
 FILE *logfp;
@@ -17,17 +18,61 @@ static void usage(char *argv[])
 	do_exit(1);
 }
 
+struct test_arg {
+	pthread_mutex_t *mutex;
+	pthread_cond_t  *cond;
+};
+
 void *
 do_work(void *arg)
 {
-#if 0
-	fprintf(logfp, "Thread %lu sleeping...\n", pthread_self());
+	int rc;
+	struct test_arg *targ = (struct test_arg *)arg;
+
+	fprintf(logfp, "Thread %lu: waiting...\n", pthread_self());
 	fflush(logfp);
-#endif
+
+	rc = pthread_cond_wait(targ->cond, targ->mutex);
+	if (rc < 0) {
+		perror("pthread_cond_wait()");
+		exit(1);
+	}
+	pthread_mutex_unlock(targ->mutex);
+
+	fprintf(logfp, "Thread %lu: wokeup...\n", pthread_self());
+	rc = pthread_cond_signal(targ->cond);
+	if (rc < 0)
+		fprintf(logfp, "do_work(): pthread_cond_signal() failed %s\n",
+					strerror(errno));
+
+	fprintf(logfp, "Thread %lu: exiting...\n", pthread_self());
+	fflush(logfp);
+}
+
+void *
+do_work_coord(void *arg)
+{
+	int rc;
+	struct test_arg *targ = (struct test_arg *)arg;
+
 	while(!test_done())
 		sleep(1);
+
+	fprintf(logfp, "Thread %lu: test-done\n", pthread_self());
+
+	rc = pthread_cond_signal(targ->cond);
+	if (rc < 0)
+		fprintf(logfp, "do_work_coord(): pthread_cond_signal() error "
+				"%s\n", strerror(errno));
+
+	fprintf(logfp, "Thread %lu: exiting...\n", pthread_self());
+	fflush(logfp);
 }
 
+pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
+pthread_cond_t  cond = PTHREAD_COND_INITIALIZER;
+struct test_arg targ;
+
 pthread_t *create_threads(int n)
 {
 	int i;
@@ -35,6 +80,9 @@ pthread_t *create_threads(int n)
 	pthread_t *tid_list;
 	pthread_t tid;
 
+	targ.mutex = &mutex;
+	targ.cond = &cond;
+
 	tid_list = (pthread_t *)malloc(n * sizeof(pthread_t));
 	if (!tid_list) {
 		fprintf(logfp, "malloc(%d) failed, error %s\n",
@@ -42,8 +90,16 @@ pthread_t *create_threads(int n)
 		do_exit(1);
 	}
 
-	for (i = 0; i < n; i++) {
-		rc = pthread_create(&tid, NULL, do_work, NULL);
+	rc = pthread_create(&tid, NULL, do_work_coord, &targ);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_create() of coord failed, rc %d "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+	tid_list[0] = tid;
+
+	for (i = 1; i < n; i++) {
+		rc = pthread_create(&tid, NULL, do_work, &targ);
 		if (rc < 0) {
 			fprintf(logfp, "pthread_create() failed, i %d, rc %d "
 					"error %s\n", i, rc, strerror(errno));
-- 
1.6.0.4
