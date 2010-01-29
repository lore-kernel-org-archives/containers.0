From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 05/11] Move event-notifications to libcrtest/common.c
Date: Fri, 29 Jan 2010 12:42:28 -0800
Message-ID: <20100129204228.GD26721@us.ibm.com>
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
Date: Tue, 26 Jan 2010 16:46:09 -0800
Subject: [PATCH 05/11] Move event-notifications to libcrtest/common.c

The event notification functions using eventfd can be used by other
fcntl tests (and possibly other tests). Move them out of filelock1.c
and into libcrtest/common.c

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/filelock1.c    |   53 -------------------------------------------
 libcrtest/common.c    |   60 +++++++++++++++++++++++++++++++++++++++++++++++++
 libcrtest/libcrtest.h |    7 +++++
 3 files changed, 67 insertions(+), 53 deletions(-)

diff --git a/fileio/filelock1.c b/fileio/filelock1.c
index 305cbeb..19f7e3b 100644
--- a/fileio/filelock1.c
+++ b/fileio/filelock1.c
@@ -9,8 +9,6 @@
 #define TEST_FILE	"data.d/data.filelock1"
 #define LOG_FILE	"logs.d/log.filelock1"
 
-typedef unsigned long long u64;
-
 extern FILE *logfp;
 int test_fd;
 int event_fd1;
@@ -31,57 +29,6 @@ int event_fd2;
  * 	held by the other process.
  */
 
-setup_notification()
-{
-	int efd;
-
-	efd = eventfd(0, 0);
-	if (efd < 0) {
-		fprintf(logfp, "ERROR: eventfd(): %s\n", strerror(errno));
-		do_exit(1);
-	}
-	return efd;
-}
-
-wait_for_events(int efd, u64 total)
-{
-	int n;
-	u64 events;
-	u64 count = (u64)0;
-
-	do {
-		fprintf(logfp, "%d: wait_for_events: fd %d, reading for %llu\n",
-				getpid(), efd, total);
-		fflush(logfp);
-
-		n = read(efd, &events, sizeof(events));
-		if (n != sizeof(events)) {
-			fprintf(logfp, "ERROR: read(event_fd) %s\n",
-						strerror(errno));
-			do_exit(1);
-		}
-		fprintf(logfp, "%d: wait_for_events: fd %d read %llu\n",
-				getpid(), efd, events);
-
-		count += events;
-	} while (count < total);
-}
-
-notify_one_event(int efd)
-{
-	int n;
-	u64 event = (u64)1;
-
-	fprintf(logfp, "%d: Notifying one event on fd %d\n", getpid(), efd);
-	fflush(logfp);
-
-	n = write(efd, &event, sizeof(event));
-	if (n != sizeof(event)) {
-		fprintf(logfp, "ERROR: write(event_fd) %s\n", strerror(errno));
-		do_exit(1);
-	}
-}
-
 struct test_arg {
 	int child_idx;
 	int type;
diff --git a/libcrtest/common.c b/libcrtest/common.c
index ca3d2d8..b29042a 100644
--- a/libcrtest/common.c
+++ b/libcrtest/common.c
@@ -335,3 +335,63 @@ int move_to_cgroup(char *subsys, char *grp, int pid)
 	fclose(fout);
 	return 1;
 }
+
+/*
+ * Set up an eventfd for communication between parent/child processes
+ */
+int setup_notification(void)
+{
+	int efd;
+
+	efd = eventfd(0, 0);
+	if (efd < 0) {
+		fprintf(logfp, "ERROR: eventfd(): %s\n", strerror(errno));
+		do_exit(1);
+	}
+	return efd;
+}
+
+/*
+ * Wait on eventfd @efd till the total number of events equals @total.
+ */
+void wait_for_events(int efd, u64 total)
+{
+	int n;
+	u64 events;
+	u64 count = (u64)0;
+
+	do {
+		fprintf(logfp, "%d: wait_for_events: fd %d, reading for %llu\n",
+				getpid(), efd, total);
+		fflush(logfp);
+
+		n = read(efd, &events, sizeof(events));
+		if (n != sizeof(events)) {
+			fprintf(logfp, "ERROR: read(event_fd) %s\n",
+						strerror(errno));
+			do_exit(1);
+		}
+		fprintf(logfp, "%d: wait_for_events: fd %d read %llu\n",
+				getpid(), efd, events);
+
+		count += events;
+	} while (count < total);
+}
+
+/*
+ * Notify one event on the eventfd @efd.
+ */
+void notify_one_event(int efd)
+{
+	int n;
+	u64 event = (u64)1;
+
+	fprintf(logfp, "%d: Notifying one event on fd %d\n", getpid(), efd);
+	fflush(logfp);
+
+	n = write(efd, &event, sizeof(event));
+	if (n != sizeof(event)) {
+		fprintf(logfp, "ERROR: write(event_fd) %s\n", strerror(errno));
+		do_exit(1);
+	}
+}
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index a42c178..9a0a13e 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -12,6 +12,10 @@ struct record {
 	char data[256];
 };
 
+#ifdef __i386__
+typedef unsigned long long u64;
+#endif
+
 extern void do_exit(int status);
 extern int test_done(void);
 extern int test_checkpoint_done();
@@ -23,4 +27,7 @@ extern char *freezer_mountpoint(void);
 /* right now, subsys must always be "freezer" */
 extern int move_to_cgroup(char *subsys, char *grp, int pid);
 
+extern void notify_one_event(int efd);
+extern void wait_for_events(int efd, u64 total);
+extern int setup_notification();
 #endif /* LIBCRTEST_H */
-- 
1.6.0.4
