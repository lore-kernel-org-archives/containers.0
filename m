From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r tests: Add futex c/r tests
Date: Mon,  6 Jul 2009 12:54:57 -0700
Message-ID: <1246910097-30792-1-git-send-email-matthltc@us.ibm.com>
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

	Add tests for plain, robust, and pi futexes. Each test sets up a
typical contended futex scenario and then awaits checkpoint. We only test
the contended case since the uncontended cases are entirely based on the
state of userspace memory. After checkpoint each test verifies that the
critical semantics of the futex still works.

	For plain futexes we ensure that the same number of tasks that
were asleep on the futex are woken up.

	For robust futexes we set the robust list head of each process
and wait for checkpoint. After checkpoint we verify that the kernel
still knows about the robust list head then each child exits without
releasing the futex. Since the child still holds the futex at exit the
kernel wakes another waiting child.

	For pi futexes we set up the contended priority inversion case
which is supposed to cause priority inheritance. Then we wait for checkpoint.
After checkpoint we verify that the priority is inherited and we also
check that the remaining waiters are woken in priority order.

	We do not test some variations on these such as private futexes,
bitsets, requeing, and futexes mapped in filesystem files. All of the futexes
in these tests are in anonymous shared mappings.

	README.txt describes the tests and their log output. run.sh shows
how to run these tests.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
v2:
	Clean up some unnecessary typecasts/differences
	Expand the run.sh script to test for some prereqs
	Add a section to the runall.sh script
	Fixed segfault using patch that immediately followed the last posting.
	Added slow thread-safe lock around the log output.
	Print orginating thread id for each log message, make the INFO, FAIL,
		etc. "tags" more formal (separate parameter).
	Factored the common logging bits into libfutex.a
		Could potentially move into libcrtest.a in the future.
	Tested on Intel x86-64 and ppc64
	Fix Makefile to be more cross-platform -- only gcc configured to
		compile to i386-*-linux seems to have trouble with GCC
		atomic builtins.

 Makefile                  |    2 
 futex/Makefile            |   44 ++
 futex/README.txt          |   37 ++
 futex/libfutex/Makefile   |   16 +
 futex/libfutex/atomic.h   |   31 ++
 futex/libfutex/libfutex.c |   25 +
 futex/libfutex/libfutex.h |  101 ++++++
 futex/pi.c                |  699 ++++++++++++++++++++++++++++++++++++++++++++++
 futex/plain.c             |  183 ++++++++++++
 futex/robust.c            |  400 ++++++++++++++++++++++++++
 futex/run.sh              |   59 +++
 runall.sh                 |    8 
 12 files changed, 1604 insertions(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index ceba676..cf88ed1 100644
--- a/Makefile
+++ b/Makefile
@@ -1,5 +1,5 @@
 SUBDIRS = libcrtest counterloop fileio simple cr-ipc-test userns ipc \
-	  sleep process-tree
+	  sleep process-tree futex
 
 targets = ns_exec
 
diff --git a/futex/Makefile b/futex/Makefile
new file mode 100644
index 0000000..951c891
--- /dev/null
+++ b/futex/Makefile
@@ -0,0 +1,44 @@
+.PHONY: clean all
+
+LIBS := libfutex/libfutex.a ../libcrtest/libcrtest.a
+PROGS := plain robust pi
+
+MACHINE=$(shell gcc -dumpmachine)
+ifeq ($(MACHINE:i386-%=i386),i386)
+ARCHOPTS := -march=i486
+endif
+
+# PowerPC doesn't seem to require any particular target machine specification
+# # to get the __sync_* GCC builtins.
+# Neither should x86_64.
+#
+# If you see output like:
+#	/tmp/ccqoSnmA.o: In function `atomic_cmpxchg':
+#	plain.c:(.text+0x69b): undefined reference to `__sync_val_compare_and_swap_4'
+#
+# then you probably need a -mFOO option to gcc set in ARCHOPT.
+
+CFLAGS := -Wall $(ARCHOPTS) -I./libfutex -I../
+
+all: $(PROGS)
+
+../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
+	$(MAKE) -C ../libcrtest libcrtest.a
+
+libfutex/libfutex.a: libfutex/libfutex.c libfutex/libfutex.h
+	$(MAKE) -C libfutex libfutex.a
+
+plain: plain.c $(LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(LIBS)
+
+robust: robust.c $(LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(LIBS)
+
+pi: pi.c $(LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(LIBS)
+
+clean:
+	rm -f *.o $(PROGS)
+	rm -rf log.* checkpoint-ready checkpoint-done
+	$(MAKE) -C libfutex clean
+	$(MAKE) -C ../libcrtest clean
diff --git a/futex/README.txt b/futex/README.txt
new file mode 100644
index 0000000..bba03bc
--- /dev/null
+++ b/futex/README.txt
@@ -0,0 +1,37 @@
+Futexes are synchronization primitives which optimize the non-contended case and
+arbitrate the contended case via the kernel. Furthermore, somewhat like undo
+lists that manage semaphores when a task exits, the robust futex list helps
+clean up futexes on exit. Finally, to ensure better realtime response there are 
+priority-inheritance (pi) futexes.
+
+The non-contended plain futex case is uninteresting as it simply involves
+atomically incrementing/decrementing a value. Similarly, robust futexes and pi
+futexes have uninteresting non-contended cases. Unlike plain futexes, these set
+the futex value to be the thread id.
+
+These tests are designed to trigger the contended cases. We can do this
+by carefully setting the initial value of plain futexes, by setting
+the initial tid for robust futexes, and by waiting on a plain futex before
+trying to grab the pi futex.
+
+Not all architectures support robust and priority-inheritance futexes
+because they require futex_atomic_cmpxchg_inatomic. Known-good archs:
+	x86, x86_64, sparc64, sh, s390, powerpc
+
+The checkpoint/restart portions of this test require kernel versions
+2.6.XX or higher.
+
+Log lines begin with "INFO:", "WARN:", "PASS:", or "FAIL:".
+
+"FAIL:" in any log indicates a failure of the test. Failure is propagated
+        via exit codes to the main thread which reports failures via its exit
+	code.
+
+"INFO:" Usually indicates what step is about to be taken. It often includes
+        specific details such as process ids, futex operations, etc.
+
+"WARN:" Is an unusual condition that doesn't indicate an error but
+        which the test was designed to avoid.
+
+"PASS:" Indicates that part of the test passed. Check the exit code for
+        a summary of PASS/FAIL.
diff --git a/futex/libfutex/Makefile b/futex/libfutex/Makefile
new file mode 100644
index 0000000..379e62c
--- /dev/null
+++ b/futex/libfutex/Makefile
@@ -0,0 +1,16 @@
+SRCS := $(wildcard *.c)
+OBJS := $(SRCS:%.c=%.o)
+
+CFLAGS += -I./ # LTP -I../../../../include
+
+TARGET := libfutex.a
+
+all: $(TARGET)
+
+libfutex.a: $(OBJS)
+	$(AR) -cr $@ libfutex.o
+
+clean:
+	rm -f $(TARGET) $(OBJS)
+
+install:
diff --git a/futex/libfutex/atomic.h b/futex/libfutex/atomic.h
new file mode 100644
index 0000000..f82b7de
--- /dev/null
+++ b/futex/libfutex/atomic.h
@@ -0,0 +1,31 @@
+#ifndef _ASM_GENERIC_ATOMIC_H_
+#define _ASM_GENERIC_ATOMIC_H_
+/*
+ * Implement the Linux Kernel's atomic_t type in userspace based on:
+ * http://gcc.gnu.org/onlinedocs/gcc-4.1.0/gcc/Atomic-Builtins.html
+ */
+
+typedef struct {
+	volatile int counter;
+} atomic_t;
+
+static inline int atomic_read(atomic_t *v)
+{
+	return v->counter;
+}
+
+static inline void atomic_set(atomic_t *v, int val)
+{
+	v->counter = val;
+}
+
+static inline void atomic_inc(atomic_t *v)
+{
+	__sync_add_and_fetch(&v->counter, 1);
+}
+
+static inline int atomic_cmpxchg(atomic_t *v, int old, int new)
+{
+	return __sync_val_compare_and_swap(&v->counter, old, new);
+}
+#endif /* _ASM_GENERIC_ATOMIC_H_ */
diff --git a/futex/libfutex/libfutex.c b/futex/libfutex/libfutex.c
new file mode 100644
index 0000000..4b1872b
--- /dev/null
+++ b/futex/libfutex/libfutex.c
@@ -0,0 +1,25 @@
+#include <stdlib.h>
+#include <sys/mman.h>
+#include "libfutex.h"
+
+void *alloc_futex_mem(size_t sz)
+{
+	void *p;
+	size_t pagesize = sysconf(_SC_PAGE_SIZE);
+	int rc;
+
+	if (pagesize == -1)
+		return NULL;
+
+	rc = posix_memalign(&p, pagesize, sz);
+	if (rc != 0) {
+		errno = rc;
+		return NULL;
+	}
+
+	rc = mprotect(p, sz, PROT_READ|PROT_WRITE|PROT_SEM);
+	if (rc == 0)
+		return p;
+	free(p);
+	return NULL;
+}
diff --git a/futex/libfutex/libfutex.h b/futex/libfutex/libfutex.h
new file mode 100644
index 0000000..e9b6e81
--- /dev/null
+++ b/futex/libfutex/libfutex.h
@@ -0,0 +1,101 @@
+#ifndef __LIBFUTEX_H
+#define __LIBFUTEX_H
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <stdlib.h>
+#include <sched.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <sys/syscall.h>
+#include <signal.h>
+#include <linux/futex.h>
+#include <sys/time.h>
+
+#include <atomic.h>
+
+#ifndef SYS_futex
+#ifdef __NR_futex
+#define SYS_futex __NR_futex
+#elif __i386__
+#define SYS_futex 240
+#elif __ia64__
+#define SYS_futex 1230
+#elif __x86_64__
+#define SYS_futex 202
+#elif __s390x__ || __s390__
+#define SYS_futex 238
+#elif __powerpc__
+#define SYS_futex 221
+#else
+#error "libfutex not supported on this architecure yet. If your arch and kernel support futexes then it is just syscall glue plus some basic atomic operations. So a patch would be fairly easy and welcome upstream."
+#endif
+#endif
+
+#ifndef __NR_futex
+#define __NR_futex SYS_futex
+#endif
+
+#ifndef PROT_SEM
+#define PROT_SEM 0x08
+#endif
+
+static inline long futex(volatile int *uaddr, int op, int val,
+			const struct timespec *timeout,
+			int *uaddr2, int val2)
+{
+	return syscall(SYS_futex, uaddr, op, val, timeout, uaddr2, val2);
+}
+
+static inline long set_robust_list(struct robust_list_head *rlist, size_t len)
+{
+	return syscall(__NR_set_robust_list, rlist, len);
+}
+
+static inline long get_robust_list(pid_t pid, struct robust_list_head **rlist,
+				  size_t *len)
+{
+
+	return syscall(__NR_get_robust_list, pid, rlist, len);
+}
+
+static inline pid_t gettid(void)
+{
+	return syscall(SYS_gettid);
+}
+
+static inline long tgkill(pid_t tgid, pid_t tid, int sig)
+{
+	return syscall(SYS_tgkill, tgid, tid, sig);
+}
+
+/* Allocate memory suitable for use as a futex */
+extern void *alloc_futex_mem(size_t sz);
+
+
+/* Thread-safe logging */
+extern FILE *logfp;
+extern atomic_t log_lock; /* initialize to = { 0 }; !! */
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
+	int __tid = gettid(); \
+	while (atomic_cmpxchg(&log_lock, 0, __tid) != 0) {} \
+	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+	fsync(fileno(logfp)); \
+	while (atomic_cmpxchg(&log_lock, __tid, 0) != __tid) {} \
+} while(0)
+
+/* like perror() except to the log */
+#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+
+#endif /* __LIBFUTEX_H */
diff --git a/futex/pi.c b/futex/pi.c
new file mode 100644
index 0000000..595b9e7
--- /dev/null
+++ b/futex/pi.c
@@ -0,0 +1,699 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ * Test priority inheritance of futexes along with checkpoint/restart.
+ *
+ * This test starts multiple child processes each with succesively
+ * higher priority. The lowest priority child grabs a pi futex while
+ * all of the higher priority children wait on a plain futex. Once
+ * it has the pi futex the lowest priority child wakes up the other
+ * children so that they will contend for the pi futex. The lowest
+ * priority child can then watch its priority rise to that of the
+ * highest priority child because it holds the futex.
+ *
+ * Then the lowest priority child releases the futex and thus wakes
+ * the highest priority child. Each of the contended children is
+ * subsequently woken in priority order -- so it does not inherit
+ * elevated priority -- until the last child releases the futex.
+ *
+ * NOTES:
+ *
+ * See README for information on interpretting the log output.
+ *
+ * Since this test sets realtime priorities, the user running the tests
+ * needs permission to set realtime priorities. To see if the user has permission:
+ * $ ulimit -r
+ * N
+ */
+#include <limits.h>
+#include <unistd.h>
+#include <signal.h>
+#include <errno.h>
+#include <sched.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <fcntl.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/wait.h>
+#include <sys/mman.h>
+#include <asm/mman.h> /* for PROT_SEM */
+#include <string.h>
+#include <linux/futex.h>
+
+#include "libfutex/libfutex.h"
+#include "libfutex/atomic.h"
+#include "libcrtest/libcrtest.h"
+
+
+
+/*
+ * The globals are set up from the main thread and then left untouched
+ * by the children.
+ */
+#define LOG_FILE	"log.pi"
+FILE *logfp = NULL;
+atomic_t log_lock = { 0 };
+
+/*
+ * Number of child processes to WAIT on futex -- must be less than number
+ * of priority levels available.
+ */
+int N = 3;
+
+const int clone_flags = CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_VM|CLONE_SYSVSEM|SIGCHLD; //|CLONE_THREAD|CLONE_PARENT;
+int prio_min, prio_max, sched_policy = SCHED_RR;
+
+/* Each child pid is recorded in kids[] */
+pid_t *kids;
+
+/* These record the progress of the children so we can dump it for checkpoint */
+atomic_t dumb_barrier[1] = { {0} };
+
+/* In order to create the priority inversion high priority threads sleep here */
+atomic_t *waitq;
+
+/* The pi futex itself */
+atomic_t *pi_futex;
+
+/*
+ * Normal priority functions deal with static priority -- priority that
+ * doesn't change unless userspace asks nicely. The nice, rtpriority,
+ * and normal_prio of tasks are these kinds of priorities.
+ *
+ * The priority is only modified if getpriority succeeded and we return 0.
+ * Otherwise we return -1, put an error in errno, and do not modify the
+ * parameter.
+ */
+int get_my_static_priority(int *prio)
+{
+	struct sched_param param;
+
+	if (sched_getparam(gettid(), &param) == 0) {
+		*prio = param.sched_priority;
+		return 0;
+	}
+	return -1;
+}
+
+int set_my_static_priority(int prio)
+{
+	struct sched_param param;
+
+	param.sched_priority = prio;
+	return sched_setparam(gettid(), &param);
+}
+
+/*
+ * We need to determine the instantaneous priority of a thread. So
+ * we look in /proc. This isn't racy because we're cooperating with
+ * the threads -- they should be waiting on the pi futex so their
+ * dynamic priorities shouldn't change.
+ *
+ * Fetch the dynamic priority from the 18th field of
+ * /proc/<tgid>/task/<tid>/stat and transform it from a kernel priority
+ * number to realtime priority number suitable for comparison with
+ * get|set_my_static_priority() above.
+ */
+int get_dynamic_priority(pid_t tid, int *dpriority)
+{
+	char buffer[4096];
+	int fd;
+	int retval = -1;
+	pid_t tgid;
+
+	if (clone_flags & CLONE_THREAD)
+		tgid = getpid();
+	else
+		tgid = tid;
+
+	*dpriority = INT_MAX;
+	snprintf(buffer, sizeof(buffer),
+		 "/proc/%d/task/%d/stat", tgid, tid);
+	fd = open(buffer, O_RDONLY);
+	if (fd < 0)
+		goto out;
+	if (read(fd, buffer, sizeof(buffer)) < 0)
+		goto out;
+	close(fd);
+	buffer[sizeof(buffer) - 1] = '\0';
+
+	if (sscanf(buffer, " %*d %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %*u %*u %*d %*d %d %*d %*d 0", dpriority) != 1)
+		goto out;
+	retval = 0;
+
+	/* Transform the priority */
+	*dpriority = -1*(*dpriority + 1);
+out:
+	return retval;
+}
+
+void dump_dynamic_priorities(void)
+{
+	/*
+	 * Since multiple calls to log() are not "atomic" we accumulate the
+	 * output in a temporary buffer then pass it all to log()
+	 */
+	char buffer[4096];
+	char *pos;
+	int prio;
+	int i;
+
+	pos = buffer;
+	for (i = 0; i < N; i++) {
+		if (get_dynamic_priority(kids[i], &prio) != 0) {
+			pos += snprintf(pos, sizeof(buffer) - (pos - buffer),
+				 " %d: warning = \"%s\"",
+				 kids[i], strerror(errno));
+		} else
+			pos += snprintf(pos, sizeof(buffer) - (pos - buffer),
+				 " %d: %d", kids[i], prio);
+	}
+	log("INFO", "dynamic priorities: %s\n", buffer);
+}
+
+/*
+ * All the uses of the futex() syscall in this test are wrapped by
+ * functions with nice names, finite retry loops, and verbose error
+ * reporting.
+ */
+
+int sleep_on_waitq(atomic_t *wq, int retries)
+{
+	int do_print = 1;
+
+again:
+	if (futex(&wq->counter, FUTEX_WAIT, -1, NULL, NULL, 0) == 0)
+		return 0;
+	switch(errno) {
+	case ETIMEDOUT:
+		log_error("FUTEX_WAIT");
+		break;
+	case ERESTART:
+		if (do_print && do_print != ERESTART) {
+			log("INFO", "RESTARTING FUTEX_WAIT (I think I was FROZEN)\n");
+			do_print = ERESTART; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log_error("FUTEX_WAIT ERESTART too many times\n");
+			break;
+		}
+		retries--;
+		goto again;
+	case EAGAIN: /* EWOULDBLOCK */
+		if (do_print && do_print != EAGAIN) {
+			log("INFO", "FUTEX_WAIT EAGAIN\n");
+			do_print = EAGAIN; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log_error("FUTEX_WAIT EAGAIN too many times\n");
+			break;
+		}
+		retries--;
+		goto again;
+		break;
+	case EINTR:
+		if (do_print && do_print != EINTR) {
+			log("INFO", "FUTEX_WAIT EINTR\n");
+			do_print = EINTR; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log_error("FUTEX_WAIT EINTR too many times\n");
+			break;
+		}
+		retries--;
+		goto again;
+		break;
+	case EACCES:
+		log("FAIL", "FUTEX_WAIT EACCES - no read access to futex memory\n");
+		break;
+	case EFAULT:
+		log("FAIL", "FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+		break;
+	case EINVAL:
+		log("FAIL", "FUTEX_WAIT EINVAL - undefined futex operation\n");
+		break;
+	case ENOSYS:
+		log("FAIL", "FUTEX_WAIT ENOSYS - undefined futex operation\n");
+		break;
+	case EDEADLK:
+		log("FAIL", "FUTEX_WAIT EDEADLK - avoided deadlock\n");
+		break;
+	default:
+		log_error("FUTEX_WAIT unexpected error (missing from man page)");
+		break;
+	}
+	return -1;
+}
+
+int wake_waitq(atomic_t *wq, int retries)
+{
+	int woken = 0, ret;
+
+	atomic_set(wq, 1);
+	do {
+		ret = futex(&wq->counter, FUTEX_WAKE, N - 1 - woken, NULL, NULL, 0);
+		retries--;
+		if (ret > 0)
+			woken += ret;
+	} while (retries && woken < N - 1);
+
+	if (woken < N - 1) {
+		log("WARN", "Could not wake %d children. Woke %d instead. waitq: %d\n", N - 1, woken, atomic_read(waitq));
+		log_error("     ");
+	}
+	return -1;
+}
+
+int do_lock_contended_pi_futex(int retries)
+{
+	int do_print = 1;
+
+again:
+	if (futex(&pi_futex->counter, FUTEX_LOCK_PI, atomic_read(pi_futex),
+	      NULL, NULL, 0) == 0)
+		return 0;
+	switch(errno) {
+	case ETIMEDOUT:
+		log("WARN", "FUTEX_LOCK_PI unexpected ETIMEDOUT\n");
+		break;
+	case ERESTART:
+		if (do_print && do_print != ERESTART) {
+			log("INFO", "RESTARTING FUTEX_LOCK_PI\n");
+			do_print = ERESTART; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log("FAIL", "locking contended pi futex returned ERESTART too many times.\n");
+			break;
+		}
+		retries--;
+	case EAGAIN: /* EWOULDBLOCK */
+		if (do_print && do_print != EAGAIN) {
+			log("INFO", "locking contended pi futex returned EAGAIN\n");
+			do_print = EAGAIN; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log("FAIL", "locking contended pi futex returned EAGAIN too many times\n");
+			break;
+		}
+		retries--;
+		goto again;
+	case EINTR:
+		if (do_print && do_print != EINTR) {
+			log("INFO", "FUTEX_LOCK_PI EINTR\n");
+			do_print = EINTR; /* primitive log-spam prevention */
+		}
+		if (!retries) {
+			log("FAIL", "locking contended pi futex returned EINTR too many times.\n");
+			break;
+		}
+		retries--;
+		goto again;
+	case EACCES:
+		log("FAIL", "FUTEX_LOCK_PI EACCES - no read access to futex memory\n");
+		break;
+	case EFAULT:
+		log("FAIL", "FUTEX_LOCK_PI EFAULT - bad timeout timespec address or futex address\n");
+		break;
+	case EINVAL:
+		log("FAIL", "FUTEX_LOCK_PI EINVAL - undefined futex operation\n");
+		break;
+	case ENOSYS:
+		log("FAIL", "FUTEX_LOCK_PI ENOSYS - undefined futex operation\n");
+		break;
+	default:
+		log_error("FUTEX_LOCK_PI unexpected error (missing from man page)");
+		break;
+	}
+	return -1;
+}
+
+int do_unlock_contended_pi_futex(int retries)
+{
+	if (futex(&pi_futex->counter, FUTEX_UNLOCK_PI, 1, NULL, NULL, 0) == 0)
+		return 0;
+
+	/*
+	 * There are still some lower priority waiters we failed to
+	 * wake for some reason. Documentation/pi-futex.txt fails
+	 * to mention what FUTEX_UNLOCK_PI returns!
+	 */
+	switch(errno) {
+	case ERESTART:
+	case EINTR:
+		log("INFO", "retrying release_pi_futex since interrupted\n");
+		return 1;
+	case EFAULT: /* We specified the wrong pi_futex address. */
+		log("FAIL", "wrong futex address or page fault/futex race in-kernel.\n");
+		break;
+	case EINVAL:
+		/*
+		 * The old value is wrong. We should never
+		 * get this since the kernel ignores the val
+		 * passed through sys_futex().
+		 */
+		log("FAIL", "kernel got confused and lost the old futex value.\n");
+		break;
+	case EPERM:
+		/*
+		 * We are unable to release the futex.
+		 * We may not be holding it like we think
+		 * we do.
+		 */
+		log_error("This process seems to lack permission to release a futex it expects to be holding. Maybe it's not being held?\n");
+		break;
+	case EAGAIN:
+		/*
+		 * Task holding the futex is exiting. Odd,
+		 * that's us!
+		 */
+		log("FAIL", "kernel insists we're exiting but we're really not!\n");
+		break;
+	case ENOMEM:
+		log_error("");
+		break;
+	case ESRCH:
+		/*
+		 * Task that held the futex is no more?! But
+		 * that's us!
+		 */
+		log("FAIL", "The kernel can't seem to find this process! I sense impending doom!\n");
+		break;
+	}
+
+	return -1;
+}
+
+/* Calculate the static priority to assign to a child */
+int child_static_priority(int child_num)
+{
+	return prio_min + child_num; /* inverted: + (N - 1 - child_num);*/
+}
+
+int kid(void *child_num_as_pointer)
+{
+	pid_t tid = gettid();
+	int child_num = (long)child_num_as_pointer;
+	int my_prio = child_static_priority(child_num);
+	int held_prio = 0;
+	int retval = -1;
+	int retries = 100;
+	int pi_val;
+
+	if (sched_getscheduler(tid) != sched_policy) {
+		log_error("failed to set scheduler policy of children.\n");
+		return retval;
+	}
+	retval--;
+	if (set_my_static_priority(my_prio)) {
+		log_error("setpriority:");
+		return retval;
+	}
+	retval--;
+
+	/* WARN_ON(held_prio != my_prio); */
+	if (get_my_static_priority(&held_prio)) {
+		log_error("getpriority:");
+		return retval;
+	}
+	retval--;
+	if (my_prio != held_prio) {
+		log("WARN", "Unexpected priority. Tried to set %d but got %d.\n", my_prio, held_prio);
+	}
+	retval --;
+
+	if (child_num > 0) {
+		atomic_inc(&dumb_barrier[0]); /* 1 */
+		/* race between inc of waitq and futex()?? */
+		if (sleep_on_waitq(waitq, retries) != 0) {
+			log("FAIL", "unable to sleep on waitq.\n");
+			retval--;
+			goto out;
+		}
+		retval--;
+
+		/*
+		 * Now we attempt to acquire the pi futex. We should find
+		 * ourselves contending on it.
+		 */
+		pi_val = atomic_cmpxchg(pi_futex, 0, tid);
+		if (pi_val == tid) {
+			log("WARN", "found uncontended pi futex.\n");
+			goto release_pi_futex;
+		}
+		retval--;
+
+		if (do_lock_contended_pi_futex(retries) != 0) {
+			log("FAIL", "unable to lock pi futex.\n");
+			goto out;
+		}
+		retval--;
+		log("INFO", "enters the critical section with priority %d.\n", held_prio);
+
+		/* Compare our priority to what we set above. */
+		retval--;
+		if (get_dynamic_priority(tid, &held_prio)) {
+			log("FAIL", "could not get priority.\n");
+			goto release_pi_futex;
+		}
+		retval--;
+
+		if (held_prio != my_prio) {
+			/*
+			 * We should not have elevated priority
+			 * since, after the first acquisition the futex
+			 * should wake the next highest priority waiter.
+			 */
+			log("FAIL", "Not woken in priority order.\n");
+			goto release_pi_futex;
+		}
+		log("PASS", "Woken in priority order.\n");
+		retval = 0;
+	} else {
+		pi_val = atomic_cmpxchg(pi_futex, 0, tid);
+		retval--;
+		if (pi_val != 0) {
+			log("FAIL", "lowest priority found contended pi futex.\n");
+			goto out;
+		}
+		retval--;
+
+		/* Now we have the pi futex but nobody else is waiting for it */
+		for (retries = 1000; atomic_read(&dumb_barrier[0]) < (N - 1);
+		     retries--)
+			usleep(1000);
+		retval--;
+
+		log("INFO", "Normal priorities (no inheritance): \n");
+		dump_dynamic_priorities();
+
+		log("INFO", "Waking other children to contend on pi futex.\n");
+		wake_waitq(waitq, retries);
+		atomic_inc(&dumb_barrier[0]); /* 1 */
+		retval--;
+
+		retries = 1000;
+		do {
+			/* Compare our priority to what we set above. */
+			if (get_dynamic_priority(tid, &held_prio)) {
+				retries = 100;
+				goto release_pi_futex;
+			}
+			usleep(1000);
+			retries--;
+		} while(retries && (held_prio != child_static_priority(N - 1)));
+
+		/* checkpoint should happen here */
+		log("INFO", "signaling ready for checkpointing\n");
+		set_checkpoint_ready();
+		while (!test_checkpoint_done()) { sleep(1); }
+
+		log("INFO", "lowest priority priority before holding pi futex: %d, during: %d\n", my_prio, held_prio);
+		log("INFO", "Inherited priorities: \n");
+		dump_dynamic_priorities();
+		if (held_prio >= child_static_priority(N - 1)) {
+			log("PASS", "Inherited priority.\n");
+			retval = 0;
+		} else {
+			log("FAIL", "Failed to inherit priority!\n");
+			retval--;
+		}
+	}
+
+release_pi_futex:
+	/* Release the futex */
+	pi_val = atomic_cmpxchg(pi_futex, tid, 0);
+	if (pi_val != tid) {
+	    switch (do_unlock_contended_pi_futex(retries)) {
+	    case -1: /* error -- we already logged the details */
+		    retval = -100;
+		    break;
+	    case 0: /* ok */
+		    break;
+	    case 1: /* try again */
+		    if (retries) {
+			    retries--;
+			    goto release_pi_futex;
+		    }
+		    retval = -101;
+		    break;
+	    }
+	} /* else we were the last to hold the futex */
+	log("INFO", "exited the critical section\n");
+out:
+	log("INFO", "exiting\n");
+	/* smp_mb() ?? */
+	if (retval) {
+		log("FAIL", "failed with %d\n", retval);
+		_exit(retval);
+	}
+	return retval;
+}
+
+int main(int argc, char **argv)
+{
+	struct sched_param proc_sched_param;
+	pid_t finished;
+	int i = 0, status = 0, excode;
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("FAIL: couldn't open logfile");
+		exit(6);
+	}
+	 /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 1);
+	dup2(fileno(logfp), 2);
+
+	prio_min = sched_get_priority_min(sched_policy);
+	prio_max = sched_get_priority_max(sched_policy);
+	if (prio_min < 0  || prio_max < 0) {
+		log_error("sched_get_priority_min|max");
+		fclose(logfp);
+		exit(1);
+	}
+
+	/* rlimit also restricts prio_max */
+	{
+		struct rlimit lim;
+		getrlimit(RLIMIT_RTPRIO, &lim);
+		log("INFO", "RLIMIT_RTPRIO: soft (cur): %ld hard (max): %ld\n",
+			lim.rlim_cur, lim.rlim_max);
+		if (lim.rlim_cur == 0) {
+			log("FAIL", "process is restricted from manipulating priorities.\n");
+			fclose(logfp);
+			exit(2);
+		}
+		if (lim.rlim_cur > prio_max)
+			prio_max = lim.rlim_cur;
+	}
+
+	proc_sched_param.sched_priority = prio_min;
+	if (sched_setscheduler(getpid(), sched_policy,
+			       &proc_sched_param) != 0) {
+		log_error("sched_setscheduler");
+		fclose(logfp);
+		exit(3);
+	}
+	if (N > (prio_max - prio_min))
+		N = prio_max - prio_min;
+	if (N < 1) {
+		log("FAIL", "Not enough priority levels to run test.\n");
+		fclose(logfp);
+		exit(4);
+	}
+
+	log("INFO", "running test with %d children\n", N);
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		fclose(logfp);
+		exit(5);
+	}
+
+	kids = malloc(sizeof(pid_t)*N);
+	if (kids == NULL) {
+		log_error("malloc");
+		fclose(logfp);
+		exit(7);
+	}
+
+	/* Initialize the waitq to hold N - 1 processes */
+	waitq = alloc_futex_mem(sizeof(*waitq));
+	if (!waitq) {
+		log_error("alloc_futex_mem");
+		fclose(logfp);
+		exit(8);
+	}
+	atomic_set(waitq, -1);
+
+	pi_futex = alloc_futex_mem(sizeof(*pi_futex));
+	if (!pi_futex) {
+		log_error("alloc_futex_mem");
+		fclose(logfp);
+		exit(9);
+	}
+	atomic_set(pi_futex, 0);
+
+	fflush(logfp);
+	fflush(stderr);
+	fflush(stdout);
+	for (i = 0; i < N; i++) {
+
+		char *new_stack = malloc(SIGSTKSZ*8);
+		kids[i] = clone(kid, new_stack + SIGSTKSZ*8, clone_flags, (void*)(long)i);
+		if (kids[i] <= 0)
+			break;
+		log("INFO", "thread %d started.\n", kids[i]);
+	}
+
+	if (i < N) {
+		log_error("couldn't start N children");
+		log("INFO", "killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		excode = 3;
+		goto out;
+	}
+
+	log("INFO", "Waiting for children to finish.\n");
+	excode = 0;
+	do {
+		/*
+		 * __WALL allows us to wait for all threads to exit
+		 */
+		finished = waitpid(-1, &status, __WALL);
+		if (!finished)
+			continue;
+		if ((finished == -1) && (errno == ECHILD))
+			break;
+
+		if (clone_flags & CLONE_THREAD)
+			i = 0;
+		else
+			i--;
+
+		log("INFO", "%d exited\n", finished);
+		/* Save any [ir]regular termination info in excode. */
+		if (WIFEXITED(status)) {
+			log("INFO", "child %d exited with %d\n", finished,
+			    WEXITSTATUS(status));
+			if (!excode)
+				excode = WEXITSTATUS(status);
+		} else if (WIFSIGNALED(status)) {
+			log("FAIL", "child %d terminated irregularly with signal %d.\n", finished, WTERMSIG(status));
+			if (!excode)
+				excode = WTERMSIG(status);
+		}
+	} while(1);
+out:
+	log("INFO", "Parent exiting (%d children left).\n", i);
+	fflush(logfp);
+	fclose(logfp);
+	free(kids);
+	exit(excode);
+}
diff --git a/futex/plain.c b/futex/plain.c
new file mode 100644
index 0000000..e9cbe7a
--- /dev/null
+++ b/futex/plain.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ * Test the contended case of simple futex operations by causing a bunch of
+ * tasks to WAIT. Then, after checkpoint WAKE them all at once.
+ *
+ * NOTE: The only other non-deprecated/non-racy futex operation which may
+ * need further testing across checkpoint/restart is FUTEX_CMP_REQUEUE. However,
+ * it's supposed to be much like WAKE in that it WAKEs N tasks. So, until we
+ * test it, we might suspect it would have similar issues (if any) to WAKE.
+ * (See futex(2) and futex(7))
+ *
+ * See README for information on interpretting the log output.
+ */
+#include <unistd.h>
+#include <signal.h>
+#include <errno.h>
+#include <sched.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/time.h>
+#include <sys/wait.h>
+#include <sys/mman.h>
+#include <asm/mman.h> /* for PROT_SEM */
+#include <linux/futex.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <fcntl.h>
+
+#include "libfutex/libfutex.h"
+#include "libfutex/atomic.h"
+#include "libcrtest/libcrtest.h"
+
+#define LOG_FILE	"log.plain"
+FILE *logfp = NULL;
+atomic_t log_lock = { 0 };
+
+/* number of child processes to WAIT on futex */
+#define N 3
+
+const int clone_flags = CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_VM|CLONE_SYSVSEM|SIGCHLD; /* !CLONE_THREAD because we want to wait for the children */
+
+/* These record the progress of the children so we can dump it for checkpoint */
+atomic_t dumb_barrier[2] = { {0}, {0} };
+
+atomic_t *test_futex; /* simulating already-contended test_futex */
+
+int kid(void *trash)
+{
+	atomic_inc(&dumb_barrier[0]); /* 1 */
+again:
+	if (futex(&test_futex->counter, FUTEX_WAIT, -1, NULL, NULL, 0) != 0) {
+		switch(errno) {
+			case ETIMEDOUT:
+				log_error("FUTEX_WAIT ETIMEDOUT");
+				break;
+			case ERESTART:
+				log("INFO", "RESTARTING FUTEX_WAIT (I think I was FROZEN)");
+				goto again;
+			case EAGAIN: /* EWOULDBLOCK */
+				log("INFO", "FUTEX_WAIT EAGAIN");
+				goto again;
+				break;
+			case EINTR:
+				log("INFO", "FUTEX_WAIT EINTR");
+				goto again;
+				break;
+			case EACCES:
+				log("FAIL", "FUTEX_WAIT EACCES - no read access to futex memory\n");
+				break;
+			case EFAULT:
+				log("FAIL", "FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+				break;
+			case EINVAL:
+				log("FAIL", "FUTEX_WAIT EINVAL - undefined futex operation\n");
+				break;
+			case ENOSYS:
+				log("FAIL", "FUTEX_WAIT ENOSYS - undefined futex operation\n");
+				break;
+			default:
+				log_error("FUTEX_WAIT unexpected error (missing from man page)");
+				break;
+		}
+	}
+	atomic_inc(&dumb_barrier[1]); /* 2 */
+	return 0;
+}
+
+void dump (const char *prefix)
+{
+	fprintf(logfp, "%s children past 1: %d\t children past 2: %d\t futex: %d\n",
+	       prefix,
+	       atomic_read(&dumb_barrier[0]),
+	       atomic_read(&dumb_barrier[1]),
+	       atomic_read(test_futex));
+}
+
+void sig_dump(int signum)
+{
+	dump("Interrupt sample:");
+}
+
+int main(int argc, char **argv)
+{
+	pid_t kids[N];
+	int i, num_killed = 0;
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 2);
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+	test_futex = alloc_futex_mem(sizeof(*test_futex));
+	if (!test_futex) {
+		log_error("alloc_futex_mem");
+		exit(3);
+	}
+	atomic_set(test_futex, -1);
+
+	signal(SIGINT, sig_dump);
+	for (i = 0; i < N; i++) {
+		char *new_stack = malloc(SIGSTKSZ*8);
+		kids[i] = clone(kid, new_stack + SIGSTKSZ*8, clone_flags,
+				NULL);
+		if (kids[i] < 0)
+			break;
+	}
+
+	if (i < N) {
+		log_error("N x FUTEX_WAIT");
+		log("INFO", "killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		_exit(4);
+	}
+
+	/* parent */
+	log("INFO", "Waiting for children to sleep on futex\n");
+	while (atomic_read(&dumb_barrier[0]) != N) /* 1 */
+		sleep(1);
+	dump("After 1, before 2:");
+
+	sleep(1);
+	log("INFO", "signaling ready for checkpointing\n");
+	set_checkpoint_ready();
+	while (!test_checkpoint_done()) { sleep(1); }
+
+	log("INFO", "Parent woken\n");
+	atomic_set(test_futex, 1);
+	dump("After 1, cleared test_futex, before 2:");
+	i = futex(&test_futex->counter, FUTEX_WAKE, N, NULL, NULL, 0);
+	if (i < N) {
+		log_error("FUTEX_WAKE");
+		sleep(1); /* wait for all woken tasks to exit quietly */
+
+		/* kill the rest */
+		for (i = 0; i < N; i++) {
+			if (kill(kids[i], SIGKILL) == 0)
+				num_killed++;
+		}
+		if (num_killed)
+			log("INFO", "killed %d remaining child tasks.\n",
+				num_killed);
+	}
+	dump("After 2:");
+
+	do_wait(N);
+	dump("After 3:");
+	fclose(logfp);
+	exit(0);
+}
diff --git a/futex/robust.c b/futex/robust.c
new file mode 100644
index 0000000..e15ef83
--- /dev/null
+++ b/futex/robust.c
@@ -0,0 +1,400 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ * Test simple (non-pi) robust futexes across checkpoint/restart.
+ * See Documentation/robust-futexes.txt (and other futex docs in that
+ * kernel source directory)
+ *
+ * Robust futex lists are shared with the kernel. They are per-thread lists
+ * of acquired futexes. When a thread/task exits the kernel walks this list,
+ * WAKE'ing one waiter for each futex it still holds. This ensures that tasks
+ * which die while holding a futex do not necessarily prevent other tasks
+ * from recovering.
+ *
+ * When the futex owner (see below) dies the FUTEX_OWNER_DIED bit is set
+ * (0x40000000)
+ *
+ * Waiters must set the FUTEX_WAITERS bit (0x80000000) and use the remaining
+ * bits for the TID of the task that "owns" the futex.
+ *
+ * See README for information on interpretting the log output.
+ */
+
+#include <unistd.h>
+#include <fcntl.h>
+#include <signal.h>
+#include <errno.h>
+#include <sched.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/wait.h>
+#include <sys/mman.h>
+#include <asm/mman.h> /* for PROT_SEM */
+#include <linux/futex.h>
+
+#include "libfutex/libfutex.h"
+#include "libfutex/atomic.h"
+
+#include "libcrtest/libcrtest.h"
+
+#define LOG_FILE	"log.robust"
+FILE *logfp = NULL;
+atomic_t log_lock = { 0 };
+
+/* number of child processes to WAIT on futex. Must be >= 2. */
+#define N 3
+
+/* From the Linux kernel */
+#ifndef offsetof
+#ifdef __compiler_offsetof
+#define offsetof(TYPE,MEMBER) __compiler_offsetof(TYPE,MEMBER)
+#else
+#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
+#endif
+#endif
+
+int pass = 0;
+int fail = 0;
+
+/* Children send ready-status bytes to the parent via this pipe. */
+#define CHILD_READY 0
+#define CHILD_ERROR 255
+int children_ready[2];
+
+struct futex {
+	atomic_t tid;
+	struct robust_list rlist;
+};
+
+struct futex *test_futex;
+
+struct robust_list_head rlist = {
+	.list = {
+		/*
+		 * Circular singly-linked list with each next field pointing to
+		 * the next field of the next list element.
+		 */
+		.next = &rlist.list,
+	},
+
+	/*
+	 * Offset of the futex word relative to the next entry of its
+	 * robust_list head.
+	 */
+	.futex_offset = offsetof(struct futex, tid) - offsetof(struct futex, rlist),
+	/*
+	 * Set list_op_pending before acquiring the futex and
+	 * clears it once the futex has been added to rlist.
+	 */
+	.list_op_pending = NULL
+};
+
+void add_rfutex(struct futex *rf)
+{
+	log("INFO", "adding test_futex\n");
+	rf->rlist.next = rlist.list.next;
+	rlist.list.next  = &rf->rlist;
+	rlist.list_op_pending = NULL; /* ARCH TODO make assign atomic */
+}
+
+void acquire_rfutex(struct futex *rf, pid_t tid)
+{
+	int val = 0;
+
+	rlist.list_op_pending = &rf->rlist; /* ARCH TODO make sure this assignment is atomic */
+
+	tid = tid & FUTEX_TID_MASK;
+	do {
+		val = atomic_cmpxchg(&rf->tid, 0, tid);
+		if (val == 0) {
+			log("FAIL", "did not see contended futex\n");
+			fail++;
+			break;
+		}
+
+		/*
+		 * else we're contended -- this is the path we always take
+		 * the first time through this loop in this test program.
+		 *
+		 * Set the WAITERS bit to indicate that we need to be woken.
+		 */
+		val = __sync_or_and_fetch(&rf->tid.counter, FUTEX_WAITERS);
+		log("INFO", "futex(FUTEX_WAIT, %x)\n", val);
+		if (futex(&rf->tid.counter, FUTEX_WAIT, val,
+			  NULL, NULL, 0) == 0)
+			break;
+		log("INFO", "futex returned with errno %d (%s).\n", errno, strerror(errno));
+		switch(errno) {
+			case ERESTART:
+				log("WARN", "ERESTART while sleeping on futex\n");
+				continue;
+			case EAGAIN:
+				log("WARN", "EAGAIN while sleeping on futex\n");
+				continue;
+			case EINTR:
+				log("WARN", "EINTR while sleeping on futex\n");
+				continue;
+			case ETIMEDOUT:
+				log("WARN", "ETIMEDOUT while sleeping on futex\n");
+				continue;
+			case EACCES:
+				log("FAIL", "FUTEX_WAIT EACCES - no read access to futex memory\n");
+				fail++;
+				return;
+			case EFAULT:
+				log("FAIL", "FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+				fail++;
+				return;
+			case EINVAL:
+				log("FAIL", "FUTEX_WAIT EINVAL - undefined futex operation\n");
+				fail++;
+				return;
+			case ENOSYS:
+				log("FAIL", "FUTEX_WAIT ENOSYS - undefined futex operation\n");
+				fail++;
+				return;
+			default:
+				log_error("FUTEX_WAIT unexpected error (missing from man page)");
+				fail++;
+				return;
+		}
+	} while(1);
+
+	log("INFO", "holding futex.\n");
+
+	val = atomic_read(&rf->tid);
+	if (val & FUTEX_OWNER_DIED)
+		/* could change INFO to PASS if we could know that we're not
+		   the first child to acquire the futex */
+		log("INFO", "previous owner died before got futex.\n");
+
+	/*
+	 * Recovering the futex so it's OK to clear FUTEX_OWNER_DIED
+	 * but we must preserve the FUTEX_WAITERS bit.
+	 */
+	atomic_set(&rf->tid, tid|(val & FUTEX_WAITERS));
+	add_rfutex(rf);
+}
+
+int release_rfutex(struct futex *rf, pid_t tid, int i)
+{
+	int val;
+
+	val = atomic_cmpxchg(&rf->tid, tid, 0);
+	if (val == tid) {
+		log("FAIL", "No waiters on futex.\n");
+		fail++;
+		return -1;
+	}
+
+	if (futex(&rf->tid.counter, FUTEX_WAKE, 1, NULL, NULL, 0) != 1) {
+		log_error("futex(FUTEX_WAKE)");
+		log("FAIL", "%d (see above for error string)\n", errno);
+		fail++;
+		return -1;
+	}
+
+	/*
+	 * Technically, we're supposed to remove it from the robust list,
+	 * but only the parent is supposed to release the futex in this
+	 * test. Since it starts holding the futex and is "guaranteed" to
+	 * release it, we don't bother with adding or removing it
+	 * from the robust list.
+	 */
+	return 0;
+}
+
+/* Make sure the robust list is set correctly */
+int check_rlist(int i)
+{
+	struct robust_list_head *fetched_rlist = NULL;
+	size_t fetched_rlist_size = 0;
+	int rc;
+
+	rc = get_robust_list(0, &fetched_rlist, &fetched_rlist_size);
+	if (rc < 0) {
+		log("FAIL", "getting robust list %d failed.\n", i);
+		fail++;
+		return -1;
+	}
+
+	if ((fetched_rlist == &rlist) &&
+	    (fetched_rlist_size == sizeof(rlist))) {
+		pass++;
+		return 0;
+	} else  {
+		log("FAIL", "checking robust list %d: got: (%p size: %zd) expected: (%p size: %zd)\n", i,
+		    fetched_rlist, fetched_rlist_size,
+		    &rlist, sizeof(rlist));
+		fail++;
+		return -1;
+	}
+}
+
+void send_parent_status(int *fd, char status)
+{
+	while (write(*fd, &status, sizeof(status)) != 1) {}
+	close(*fd);
+	*fd = -1;
+}
+
+int kid(int i)
+{
+	if (set_robust_list(&rlist, sizeof(rlist)) < 0) {
+		log_error("set_robust_list");
+		fail++;
+		send_parent_status(&children_ready[1], CHILD_ERROR);
+		return -1;
+	}
+	if (check_rlist(i) != 0) {
+		send_parent_status(&children_ready[1], CHILD_ERROR);
+		return -1;
+	}
+
+	log("INFO", "signaling ready for checkpointing\n");
+	set_checkpoint_ready();
+	while (!test_checkpoint_done()) { sleep(1); }
+
+	if (check_rlist(i) != 0) {
+		send_parent_status(&children_ready[1], CHILD_ERROR);
+		return -1;
+	}
+
+	send_parent_status(&children_ready[1], CHILD_READY);
+	acquire_rfutex(test_futex, gettid());
+
+	/*
+	 * Now exit instead of releasing the futex. This should cause
+	 * the kernel to wake the next waiter with FUTEX_OWNER_DIED.
+	 */
+	log("INFO", "exiting\n");
+	pass++;
+	if (pass && !fail)
+		exit(EXIT_SUCCESS);
+	exit(EXIT_FAILURE);
+}
+
+void dump (const char *prefix)
+{
+	log("INFO", "%s futex: %d\n", prefix, atomic_read(&test_futex->tid));
+}
+
+void sig_dump(int signum)
+{
+	dump("Ctrl-C Interrupt sample:");
+}
+
+int main(int argc, char **argv)
+{
+	pid_t kids[N];
+	int i, excode = EXIT_FAILURE;
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("FAIL: logfile");/* perror() since logfp unopened */
+		exit(excode);
+	}
+	/* redirect stdout and stderr to the log file */
+	if ((dup2(fileno(logfp), 1) != 1) ||
+	    (dup2(fileno(logfp), 2) != 2)) {
+		log_error("dup2() logfp to stdout and stderr");
+		goto exit_logs;
+	}
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		goto exit_logs;
+	}
+
+	/*
+	 * Create the pipes that children use to tell us when they get to
+	 * specific points. We use this instead of racier sleeps.
+	 */
+	if (pipe(children_ready) == -1) {
+		log_error("pipe(children_ready)");
+		goto exit_logs;
+	}
+
+	/*
+	 * Create the futex. We can't use alloc_futex_mem() since we need
+	 * MAP_SHARED.
+	 */
+	test_futex = mmap(NULL, sizeof(*test_futex),
+			  PROT_READ|PROT_WRITE|PROT_SEM,
+			  MAP_ANONYMOUS|MAP_SHARED, -1, 0);
+	if (test_futex == MAP_FAILED) {
+		log_error("mmap shared futex");
+		goto exit_pipes;
+	}
+
+	/* Should already be zero but let's be clear about that. */
+	atomic_set(&test_futex->tid, 0);
+	test_futex->rlist.next = &test_futex->rlist;
+
+	if (set_robust_list(&rlist, sizeof(rlist))) {
+		log_error("set_robust_list");
+		goto exit_pipes;
+	}
+	check_rlist(0);
+
+	/* Give the futex to the parent initially */
+	atomic_set(&test_futex->tid, gettid());
+	signal(SIGINT, sig_dump);
+	for (i = 0; i < N; i++) {
+		/*
+		 * Each thread starts with it's own empty robust list.
+		 * set_robust_list() must be called from the thread before
+		 * this list can record held futexes.
+		*/
+		kids[i] = fork();
+		if (kids[i] < 0)
+			break;
+		else if (kids[i] == 0) {
+			close(children_ready[0]);
+			kid(i + 1);
+		}
+	}
+
+	if (i < N) {
+		log_error("N x FUTEX_WAIT");
+		fail++;
+		log("INFO", "killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		goto exit_pipes;
+	}
+
+	close(children_ready[1]);
+	do {
+		char status;
+
+		if (read(children_ready[0], &status, 1) != 1)
+			continue;
+		if (status == CHILD_READY)
+			pass++;
+		else
+			fail++;
+	} while (pass + fail < N);
+	close(children_ready[0]);
+
+	/* Now that all the children are waiting on the futex, wake one. */
+	log("INFO", "Parent waking one child\n");
+	release_rfutex(test_futex, gettid(), 0);
+	log("INFO", "Parent waiting for children\n");
+	do_wait(N); /* N if we're not using CLONE_THREAD, 1 otherwise */
+	log("INFO", "Parent exiting.\n");
+	if (pass && !fail)
+		excode = EXIT_SUCCESS;
+exit_pipes:
+	close(children_ready[0]);
+	close(children_ready[1]);
+exit_logs:
+	fclose(logfp);
+	exit(excode);
+}
diff --git a/futex/run.sh b/futex/run.sh
new file mode 100755
index 0000000..c90cb89
--- /dev/null
+++ b/futex/run.sh
@@ -0,0 +1,59 @@
+#!/bin/bash
+
+set -e
+
+#
+# Check if the running kernel supports futexes
+#
+if [ -r /proc/config.gz ]; then
+	zcat /proc/config.gz | grep -F 'CONFIG_FUTEX=y' > /dev/null 2>&1
+	[ $? ] || {
+		echo "WARNING: Kernel does not support futexes. Skipping tests."
+		exit 1
+	}
+fi
+if [ -r /proc/config ]; then
+	cat /proc/config | grep -F 'CONFIG_FUTEX=y' > /dev/null 2>&1
+	[ $? ] || {
+		echo "WARNING: Kernel does not support futexes. Skipping tests."
+		exit 1
+	}
+fi
+
+TESTS=( ./plain ./robust )
+
+if [ `ulimit -r` -lt 2 ]; then
+	echo "WARNING: Priority inheritance test must be able to set at least two realtime priorities. ulimit -r indicates otherwise so skipping pi futex test(s)."
+else
+	echo "INFO: Priority inheritance tests included."
+	TESTS+=( ./pi )
+fi
+
+make ${TESTS[@]}
+
+# mount -t cgroup foo /cg
+# mkdir /cg/1
+# chown -R $(id --name -u).$(id --name -g) /cg/1
+
+for T in ${TESTS[@]} ; do
+	trap 'break' ERR EXIT
+	rm -f ./checkpoint-*
+	echo "Running test: ${T}"
+	${T} &
+	TEST_PID=$!
+	while [ '!' -r "./checkpoint-ready" ]; do
+		sleep 1
+	done
+	# echo FROZEN > /cg/1/freezer.state
+	# ckpt
+	# echo THAWED > /cg/1/freezer.state
+	touch "./checkpoint-done"
+	wait ${TEST_PID}
+	echo "Test ${T} done"
+	trap "" ERR EXIT
+done
+
+rm -f ./checkpoint-*
+
+# rmdir /cg/1
+# umount /cg
diff --git a/runall.sh b/runall.sh
index 8700c3b..231e720 100644
--- a/runall.sh
+++ b/runall.sh
@@ -107,4 +107,12 @@ if [ $? -ne 0 ]; then
 fi
 popd
 
+echo Running futex tests
+pushd futex
+bash run.sh
+if [ $? -ne 0 ]; then
+	echo FAIL
+	exit 8
+fi
+popd
 exit 0
-- 
1.5.6.3
