From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] pthread4: Ensure mutexes are consistent across C/R
Date: Fri, 8 Jan 2010 17:31:30 -0800
Message-ID: <20100109013130.GC21607@us.ibm.com>
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
Date: Fri, 8 Jan 2010 10:56:38 -0800
Subject: [PATCH] pthread4: Ensure mutexes are consistent across C/R

Pthread mutex (not) held at checkpoint must continue to be (not) held
after restart.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/Makefile   |    2 +-
 process-tree/pthread4.c |  285 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 286 insertions(+), 1 deletions(-)
 create mode 100644 process-tree/pthread4.c

diff --git a/process-tree/Makefile b/process-tree/Makefile
index b043394..64fdd20 100644
--- a/process-tree/Makefile
+++ b/process-tree/Makefile
@@ -1,5 +1,5 @@
 
-targets		= ptree1 pthread1 pthread2 pthread3
+targets		= ptree1 pthread1 pthread2 pthread3 pthread4
 
 INCLUDE		= ../libcrtest
 LIBCRTEST	= ../libcrtest/common.o
diff --git a/process-tree/pthread4.c b/process-tree/pthread4.c
new file mode 100644
index 0000000..b7afcab
--- /dev/null
+++ b/process-tree/pthread4.c
@@ -0,0 +1,285 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <wait.h>
+#include <errno.h>
+#include <string.h>
+#include <stdlib.h>
+#include <libcrtest.h>
+#define __USE_UNIX98
+#include <pthread.h>
+
+
+#define	ERROR_EXIT	((void *)1)
+#define MIN_STACK_SIZE	(64 *1024)
+#define LOG_PREFIX	"logs.d/pthread4"
+
+FILE *logfp;
+int num_threads = 4;
+int *tstatus;
+pthread_barrier_t cr_ready;
+pthread_barrier_t threads_created;
+pthread_mutex_t mutex;
+
+static void usage(char *argv[])
+{
+	printf("%s [h] [-n num-threads]\n", argv[0]);
+	printf("\t <num-threads> # of threads, default 5\n");
+	do_exit(1);
+}
+
+void * do_work(void *arg)
+{
+	int tnum = (int)arg;
+	int rc;
+	int lock_acquired;
+
+	/*
+	 * Wait for all threads to be created, so a random thread can
+	 * get the lock.
+	 */
+	rc = pthread_barrier_wait(&threads_created);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "%d: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_mutex_trylock(&mutex);
+	if (rc && rc != EBUSY) {
+		fprintf(logfp, "%d: pthread_mutex_trylock() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	lock_acquired = 0;
+	if (!rc)
+		lock_acquired++;
+
+	fprintf(logfp, "%d: Thread %lu: lock_acquired %d waiting for "
+			"checkpoint\n", tnum, pthread_self(), lock_acquired);
+	fflush(logfp);
+
+	/*
+	 * Inform main-thread we are ready for checkpoint.
+	 */
+	rc = pthread_barrier_wait(&cr_ready);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "%d: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * Wait for checkpoint/restart.
+	 */
+	while(!test_done())
+		sleep(1);
+
+	rc = pthread_mutex_trylock(&mutex);
+	if (rc && rc != EBUSY) {
+		fprintf(logfp, "%d: pthread_mutex_trylock() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * If I already hold the lock, this trylock better fail :-)
+	 */
+	tstatus[tnum] = 0;
+	if (lock_acquired && !rc) {
+		fprintf(logfp, "%d: FAIL: I no longer hold the lock held "
+				"before checkpoint/restart !!! rc %d "
+				"lock_acquired %d\n", tnum, rc, lock_acquired);
+		tstatus[tnum] = 1;
+	}
+
+	if (lock_acquired || !rc)
+		pthread_mutex_unlock(&mutex);
+
+	fprintf(logfp, "%d: Thread %lu: exiting, rc 0\n", tnum,
+			pthread_self());
+	fflush(logfp);
+
+	pthread_exit((void *)&tstatus[tnum]);
+
+}
+
+pthread_t *create_threads(int n)
+{
+	int i;
+	int rc;
+	pthread_t *tid_list;
+	pthread_t tid;
+	pthread_attr_t *attr = NULL;
+
+	tid_list = (pthread_t *)malloc(n * sizeof(pthread_t));
+	tstatus = malloc(sizeof(int) * n);
+
+	if (!tid_list || !tstatus) {
+		fprintf(logfp, "malloc() failed, n %d, error %s\n",
+				n, strerror(errno));
+		do_exit(1);
+	}
+
+	attr = NULL;
+	for (i = 0; i < n; i++) {
+		rc = pthread_create(&tid, attr, do_work, (void *)i);
+		if (rc < 0) {
+			fprintf(logfp, "pthread_create(): i %d, rc %d, "
+					"error %s\n", i, rc, strerror(errno));
+			do_exit(1);
+		}
+
+		tid_list[i] = tid;
+	}
+
+	fprintf(logfp, "Created %d threads\n", n);
+	fflush(logfp);
+
+	return tid_list;
+}
+
+int wait_for_threads(pthread_t *tid_list, int n)
+{
+	int i;
+	int rc;
+	int status;
+	int *statusp;
+	int exit_status;
+
+	exit_status = 0;
+	for (i = 0; i < n; i++) {
+		rc = pthread_join(tid_list[i], (void **)&statusp);
+		if (rc < 0) {
+			fprintf(logfp, "pthread_join() failed, i %d, rc %d "
+					"error %s\n", i, rc, strerror(errno));
+			do_exit(1);
+		}
+
+		fprintf(logfp, "i %d: *statusp %x\n", i, *statusp);
+		fflush(logfp);
+
+		if (*statusp)
+			exit_status = 1;
+	}
+
+	return exit_status;
+}
+
+init_mutex(pthread_mutex_t *mutex)
+{
+	int rc;
+	pthread_mutexattr_t mutex_attr;
+
+	rc = pthread_mutexattr_init(&mutex_attr);
+	if (rc) {
+		fprintf(logfp, "pthread_mutexattr_init() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_mutexattr_settype(&mutex_attr, PTHREAD_MUTEX_ERRORCHECK);
+	if (rc) {
+		fprintf(logfp, "pthread_mutexattr_settype() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * TODO: Change other attributes of the mutex to non-default values ?
+	 */
+
+	rc = pthread_mutex_init(mutex, &mutex_attr);
+	if (rc) {
+		fprintf(logfp, "pthread_mutex_init() failed, rc %d, error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+main(int argc, char *argv[])
+{
+	int c;
+	int i;
+	int rc;
+	int status;
+	pthread_t *tid_list;
+	char log_file[256];
+
+	sprintf(log_file, "%s.log", LOG_PREFIX);
+
+	if (test_done()) {
+		fprintf(stderr, "Remove %s before running test\n", TEST_DONE);
+		do_exit(1);
+	}
+
+	while ((c = getopt(argc, argv, "hn:")) != EOF) {
+		switch (c) {
+		case 'n': num_threads = atoi(optarg); break;
+		case 'h':
+		default:
+			usage(argv);
+		}
+	};
+
+	logfp = fopen(log_file, "w");
+	if (!logfp) {
+		fprintf(stderr, "fopen(%s) failed, %s\n", log_file,
+					strerror(errno));
+		fflush(stderr);
+		do_exit(1);
+	}
+
+	fprintf(stderr, "Redirecting output to %s\n", log_file);
+	fflush(stderr);
+
+	for (i=0; i<100; i++)  {
+		if (fileno(logfp) != i)
+			close(i);
+	}
+
+
+	/*
+	 * Create a barrier which the main-thread can use to determine
+	 * when all threads are ready for checkpoint.
+	 */
+	rc = pthread_barrier_init(&cr_ready, NULL, num_threads+1);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_barrier_init() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_barrier_init(&threads_created, NULL, num_threads);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_barrier_init() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	init_mutex(&mutex);
+
+	tid_list = create_threads(num_threads);
+
+	/*
+	 * Wait for everyone to be ready for checkpoint
+	 */
+	pthread_barrier_wait(&cr_ready);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "main: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * Now that we closed the special files and created the threads,
+	 * tell any wrapper scripts, we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	rc = wait_for_threads(tid_list, num_threads);
+
+	fprintf(logfp, "Exiting with status %d\n", rc);
+
+	do_exit(rc);
+}
-- 
1.6.0.4
