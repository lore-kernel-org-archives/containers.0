From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/10] cr_tests: Factor log() and log_error()
Date: Mon, 15 Mar 2010 16:01:02 -0700
Message-ID: <5b1bb7d32f49f39912aceddc22139fdb342d699f.1268694050.git.matthltc@us.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Factor these macro definitions from epoll, futex, eventfd, and fs tests.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/libeptest.h         |   19 +----------------
 eventfd/libeptest.h       |   19 +----------------
 fs/libfstest.h            |   20 +-----------------
 futex/libfutex/libfutex.h |   34 +++----------------------------
 libcrtest/libcrtest.h     |    9 ++++++++
 libcrtest/log.h           |   48 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 64 insertions(+), 85 deletions(-)
 create mode 100644 libcrtest/log.h

diff --git a/epoll/libeptest.h b/epoll/libeptest.h
index 990412d..2e4dbc3 100644
--- a/epoll/libeptest.h
+++ b/epoll/libeptest.h
@@ -7,27 +7,10 @@
 
 #include "libcrtest/libcrtest.h"
 #include "libcrtest/labels.h"
+#include "libcrtest/log.h"
 
 extern FILE *logfp;
 
-/*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
- */
-#define log(tag, fmt, ...) \
-do { \
-	pid_t __tid = getpid(); \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
-
 /* Non-reentrant!! */
 const char * eflags(unsigned int events);
 
diff --git a/eventfd/libeptest.h b/eventfd/libeptest.h
index 3f1522e..c2f327d 100644
--- a/eventfd/libeptest.h
+++ b/eventfd/libeptest.h
@@ -7,23 +7,6 @@
 
 #include "libcrtest/libcrtest.h"
 #include "libcrtest/labels.h"
+#include "libcrtest/log.h"
 
 extern FILE *logfp;
-
-/*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
- */
-#define log(tag, fmt, ...) \
-do { \
-	pid_t __tid = getpid(); \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
diff --git a/fs/libfstest.h b/fs/libfstest.h
index 238846b..143b0bc 100644
--- a/fs/libfstest.h
+++ b/fs/libfstest.h
@@ -7,25 +7,7 @@
 
 #include "libcrtest/libcrtest.h"
 #include "libcrtest/labels.h"
+#include "libcrtest/log.h"
 
-extern FILE *logfp;
-
-/*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
- */
-#define log(tag, fmt, ...) \
-do { \
-	pid_t __tid = getpid(); \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
 
 #define HELLO "Hello world!\n"
diff --git a/futex/libfutex/libfutex.h b/futex/libfutex/libfutex.h
index 4fdb527..c5a176d 100644
--- a/futex/libfutex/libfutex.h
+++ b/futex/libfutex/libfutex.h
@@ -15,6 +15,10 @@
 
 #include "atomic.h"
 
+#define HAVE_LOG_LOCK 1
+#define HAVE_GETTID 1
+#include "libcrtest/log.h"
+
 #ifndef SYS_futex
 #ifdef __NR_futex
 #define SYS_futex __NR_futex
@@ -60,11 +64,6 @@ static inline long get_robust_list(pid_t pid, struct robust_list_head **rlist,
 	return syscall(__NR_get_robust_list, pid, rlist, len);
 }
 
-static inline pid_t gettid(void)
-{
-	return syscall(SYS_gettid);
-}
-
 static inline long tgkill(pid_t tgid, pid_t tid, int sig)
 {
 	return syscall(SYS_tgkill, tgid, tid, sig);
@@ -73,29 +72,4 @@ static inline long tgkill(pid_t tgid, pid_t tid, int sig)
 /* Allocate memory suitable for use as a futex */
 extern void *alloc_futex_mem(size_t sz);
 
-
-/* Thread-safe logging */
-extern FILE *logfp;
-extern atomic_t log_lock; /* initialize to = { 0 }; !! */
-
-/*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
- */
-#define log(tag, fmt, ...) \
-do { \
-	int __tid = gettid(); \
-	while (atomic_cmpxchg(&log_lock, 0, __tid) != 0) {} \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-	while (atomic_cmpxchg(&log_lock, __tid, 0) != __tid) {} \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
-
 #endif /* __LIBFUTEX_H */
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index 8e68261..2ef5e1e 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -1,5 +1,7 @@
 #ifndef LIBCRTEST_H
 #define LIBCRTEST_H 1
+#include <unistd.h>
+#include <sys/syscall.h>
 
 #define CKPT_READY		"checkpoint-ready"
 #define CKPT_DONE		"checkpoint-done"
@@ -32,4 +34,11 @@ extern int move_to_cgroup(char *subsys, char *grp, int pid);
 extern void notify_one_event(int efd);
 extern void wait_for_events(int efd, u64 total);
 extern int setup_notification();
+
+static inline pid_t gettid(void)
+{
+	return syscall(SYS_gettid);
+}
+#define HAVE_GETTID 1
+
 #endif /* LIBCRTEST_H */
diff --git a/libcrtest/log.h b/libcrtest/log.h
new file mode 100644
index 0000000..0bb49b2
--- /dev/null
+++ b/libcrtest/log.h
@@ -0,0 +1,48 @@
+#ifndef LIBCRTEST_LOG_H
+#define LIBCRTEST_LOG_H
+
+extern FILE *logfp;
+
+#ifdef HAVE_LOG_LOCK
+/* Thread-safe logging */
+extern atomic_t log_lock; /* initialize to = { 0 }; !! */
+#endif
+
+#ifdef HAVE_LOG_LOCK
+#define lock_log() do { \
+	while (atomic_cmpxchg(&log_lock, 0, __tid) != 0) {} \
+} while(0)
+
+#define unlock_log() do { \
+	while (atomic_cmpxchg(&log_lock, __tid, 0) != __tid) {} \
+} while(0)
+#else
+#define lock_log() do {} while (0)
+#define unlock_log() do {} while (0)
+#endif
+
+#ifndef HAVE_GETTID
+#define gettid getpid
+#endif
+
+/*
+ * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
+ * Adds information about the thread originating the message.
+ *
+ * Flush the log after every write to make sure we get consistent, and
+ * complete logs.
+ */
+#define log(tag, fmt, ...) \
+do { \
+	pid_t __tid = gettid(); \
+	lock_log(); \
+	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+	fsync(fileno(logfp)); \
+	unlock_log(); \
+} while(0)
+
+/* like perror() except to the log */
+#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+
+#endif /* LIBCRTEST_LOG_H */
-- 
1.6.3.3
