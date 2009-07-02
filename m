From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r tests: futexes
Date: Thu, 2 Jul 2009 01:19:47 -0700
Message-ID: <20090702081947.GA19135@count0.beaverton.ibm.com>
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
To: Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

    	Add futex c/r tests
    
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
    
    	run.sh shows how to run each of these tests without
    checkpointing, using "touch ./checkpoint-done" to indicate where
    checkpoint should happen.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--

 Makefile                  |    2 
 futex/Makefile            |   31 +
 futex/README.txt          |   14 
 futex/libfutex/Makefile   |   16 +
 futex/libfutex/atomic.h   |   31 +
 futex/libfutex/libfutex.c |   25 +
 futex/libfutex/libfutex.h |   75 ++++
 futex/pi.c                |  724 ++++++++++++++++++++++++++++++++++++++++++++++
 futex/plain.c             |  205 +++++++++++++
 futex/robust.c            |  456 ++++++++++++++++++++++++++++
 futex/run.sh              |   21 +
 11 files changed, 1599 insertions(+), 1 deletion(-)

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
index 0000000..2d5ec89
--- /dev/null
+++ b/futex/Makefile
@@ -0,0 +1,31 @@
+.PHONY: clean all
+
+TEST_LIBS := libfutex/libfutex.a ../libcrtest/libcrtest.a
+TEST_PROGS := plain robust pi
+ARCH := $(shell uname -m)
+
+# We need -march= for the __sync_* GCC builtins
+CFLAGS := -Wall -march=$(ARCH) -I./libfutex -I../
+
+all: $(TEST_PROGS)
+
+../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
+	$(MAKE) -C ../libcrtest libcrtest.a
+
+libfutex/libfutex.a: libfutex/libfutex.c libfutex/libfutex.h
+	$(MAKE) -C libfutex libfutex.a
+
+plain: plain.c $(TEST_LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(TEST_LIBS)
+
+robust: robust.c $(TEST_LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(TEST_LIBS)
+
+pi: pi.c $(TEST_LIBS) Makefile
+	gcc $(CFLAGS) -o $@ $< $(TEST_LIBS)
+
+clean:
+	rm -f *.o $(TEST_PROGS)
+	rm -rf log.* checkpoint-ready checkpoint-done test_futex.bin
+	$(MAKE) -C libfutex clean
+	$(MAKE) -C ../libcrtest clean
diff --git a/futex/README.txt b/futex/README.txt
new file mode 100644
index 0000000..53f9925
--- /dev/null
+++ b/futex/README.txt
@@ -0,0 +1,14 @@
+Futexes optimize the non-contended case and arbitrate the contended case via
+the kernel. Furthermore, somewhat like undo lists that manage semaphores when
+a task exits, the robust futex list helps clean up futexes on exit. Finally,
+to ensure better realtime response there are priority-inheritance (pi) futexes.
+
+The non-contended plain futex case is uninteresting as it simply involves
+atomically incrementing a value. Similarly, robust futexes and pi futexes
+have uninteresting non-contended cases. Unlike plain futexes, these set
+the futex value to be the thread id.
+
+These tests are designed to trigger the contended cases. We can do this
+by carefully setting the initial value of plain futexes, and by setting
+the tid for robust futexes, and by waiting on a plain futex before trying
+to grab the pi futex.
diff --git a/futex/libfutex/Makefile b/futex/libfutex/Makefile
new file mode 100755
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
index 0000000..2ba394c
--- /dev/null
+++ b/futex/libfutex/libfutex.h
@@ -0,0 +1,75 @@
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
+static inline int futex(int *uaddr, int op, int val,
+			const struct timespec *timeout,
+			int *uaddr2, int val2)
+{
+	return syscall(SYS_futex, uaddr, op, val, timeout, uaddr2, val2);
+}
+
+static inline int set_robust_list(struct robust_list_head *rlist, size_t len)
+{
+	return syscall(__NR_set_robust_list, rlist, len);
+}
+
+static inline int get_robust_list(pid_t pid, struct robust_list_head **rlist,
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
+static inline int tgkill(pid_t tgid, pid_t tid, int sig)
+{
+	return syscall(SYS_tgkill, tgid, tid, sig);
+}
+
+/* Allocate memory suitable for use as a futex */
+extern void *alloc_futex_mem(size_t sz);
+#endif /* __LIBFUTEX_H */
diff --git a/futex/pi.c b/futex/pi.c
new file mode 100644
index 0000000..5751ab7
--- /dev/null
+++ b/futex/pi.c
@@ -0,0 +1,724 @@
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
+/*
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
+ * The futex portions of this test require kernel versions 2.6.13 or higher
+ * and could run as a pi-futex test with the checkpoint/restart sections
+ * disabled.
+ *
+ * The checkpoint/restart portions of this test require kernel versions
+ * 2.6.XX or higher.
+ *
+ * Log lines begin with "INFO:", "WARNING:", "PASS:", or "FAIL:". A "FAIL:" in
+ * any log indicates a failure of the test. That failure is propagated via
+ * exit codes to the main thread which reports failures via its exit code.
+ *
+ * "INFO:" Usually indicates what step is about to be taken. It often includes
+ *         specific details such as process ids, times, etc.
+ * "WARNING:" Is an unusual condition that doesn't indicate an error but
+ *            which the test was designed to avoid.
+ * "PASS:" Indicates that part of the test passed.
+ *
+ * Only the exit code of the test indicates whether the whole test passed.
+ */
+
+
+/*
+ * The globals are set up from the main thread and then left untouched
+ * by the children.
+ */
+#define LOG_FILE	"log.pi"
+FILE *logfp = NULL;
+
+/* like perror() except to the child's log */
+#define log_error(s) perror((s))
+
+/* flush the log after every write since we're multithreaded. */
+#define log(fmt, ...) \
+do { \
+	fprintf(logfp, fmt, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+} while(0)
+
+/*
+ * Number of child processes to WAIT on futex -- must be less than number
+ * of priority levels available.
+ */
+int N = 3;
+
+int prio_min, prio_max, sched_policy = SCHED_RR;
+struct sched_param proc_sched_param;
+
+const int clone_flags = CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_VM|CLONE_SYSVSEM|SIGCHLD|CLONE_THREAD|CLONE_PARENT;
+
+/* Each child pid is recorded in kids[] */
+pid_t *kids;
+
+/* These record the progress of the children so we can dump it for checkpoint */
+atomic_t dumb_barrier[2] = { {0}, {0} };
+
+/* In order to create the priority inversion high priority threads sleep here */
+atomic_t *waitq;
+
+/* The pi futex itself */
+atomic_t *pi_futex;
+
+/*
+ * From the tid we can find out which child we're in. This is useful for
+ * the log routines below.
+ */
+int get_child_num(void)
+{
+	pid_t my_tid = gettid();
+	int i;
+
+	for (i = 0; i < N; i++)
+		if (kids[i] == my_tid)
+			return i;
+	return N;
+}
+
+/*
+ * Saner semantics than getpriority(): the priority is only modified if
+ * getpriority succeeded and we return 0. Otherwise we return -1, put an
+ * error in errno, and do not modify the parameter.
+ */
+int get_my_static_priority(long *prio)
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
+/* Similar to setpriority() */
+int set_my_static_priority(long x)
+{
+	struct sched_param param;
+
+	param.sched_priority = x;
+	return sched_setparam(gettid(), &param);
+}
+
+/*
+ * Normal priority functions deal with static priority -- priority that
+ * doesn't change unless userspace asks nicely. The nice, rtpriority,
+ * and normal_prio of tasks are these kinds of priorities.
+ *
+ * We need to determine the instantaneous priority of a thread. So
+ * we look in /proc. This is less racy because we're cooperating with
+ * the threads -- they should be waiting on the pi futex so their dynamic
+ * priorities shouldn't change unless they are the child 0, which
+ * is written to check for that change.
+ *
+ * Fetch the dynamic priority from the 18th field of
+ * /proc/<tgid>/task/<tid>/stat and transform it from a kernel priority
+ * number to realtime priority number suitable for comparison with
+ * get|set_my_static_priority() above.
+ */
+int get_dynamic_priority(pid_t tid, long *dpriority)
+{
+	char buffer[4096], *pbuf;
+	char path[64];
+	int fd;
+
+	*dpriority = LONG_MAX;
+	snprintf(path, 32, "/proc/%d/task/%d/stat", getpid(), tid);
+	fd = open(path, O_RDONLY);
+	if (fd < 0) {
+		if (errno == ENOENT) {
+			log("INFO: get_dynamic_priority: task %d (%s) gone\n", tid, path);
+			/* task has gone away */
+			return 0;
+		}
+		return -1;
+	}
+	pbuf = buffer;
+	while (pbuf < buffer + 4096) {
+		if (read(fd, pbuf, 4096 - (pbuf - buffer)) <= 0)
+			break;
+	}
+	close(fd);
+
+	buffer[4095] = '\0';
+	if (sscanf(buffer, " %*d %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %*u %*u %*d %*d %ld %*d %*d 0", dpriority) != 1) {
+		log("FAIL: get_dynamic_priority: could not parse \"%s\":\n%s\n", path, buffer);
+		return -1;
+	}
+
+	/* Transform the priority */
+	*dpriority = -1*(*dpriority + 1);
+	return 0;
+}
+
+void dump_priorities(void)
+{
+	long prio;
+	int i;
+
+	log("INFO: ");
+	for (i = 0; i < N; i++) {
+		if (get_dynamic_priority(kids[i], &prio) != 0) {
+			log("%d: warning = \"%s\" ", kids[i], strerror(errno));
+		} else
+			log("%d: %ld ", kids[i], prio);
+	}
+	log("\n");
+}
+
+/*
+ * All the uses of the futex() syscall in this test are wrapped by
+ * functions with nice names, finite retry loops, and verbose error
+ * reporting.
+ */
+
+int sleep_on_waitq(int *wq, int val, int retries)
+{
+	int do_print = 1;
+again:
+	if (futex(wq, FUTEX_WAIT, val, NULL, NULL, 0) == 0)
+		return 0;
+	switch(errno) {
+	case ETIMEDOUT:
+		log_error("WARNING: FUTEX_WAIT ETIMEDOUT");
+		break;
+	case ERESTART:
+		if (do_print && do_print != ERESTART) {
+			log_error("INFO: RESTARTING FUTEX_WAIT (I think I was FROZEN)");
+			do_print = ERESTART; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+	case EAGAIN: /* EWOULDBLOCK */
+		if (do_print && do_print != EAGAIN) {
+			log_error("WARNING: FUTEX_WAIT EAGAIN");
+			do_print = EAGAIN; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+		break;
+	case EINTR:
+		if (do_print && do_print != EINTR) {
+			log_error("WARNING: FUTEX_WAIT EINTR");
+			do_print = EINTR; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+		break;
+	case EACCES:
+		log("FAIL: FUTEX_WAIT EACCES - no read access to futex memory\n");
+		break;
+	case EFAULT:
+		log("FAIL: FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+		break;
+	case EINVAL:
+		log("FAIL: FUTEX_WAIT EINVAL - undefined futex operation\n");
+		break;
+	case ENOSYS:
+		log("FAIL: FUTEX_WAIT ENOSYS - undefined futex operation\n");
+		break;
+	default:
+		log_error("FAIL: FUTEX_WAIT unexpected error (missing from man page)");
+		break;
+	}
+	return -1;
+}
+
+int wake_waitq(int *wq, int val, int retries)
+{
+	int woken = 0, ret;
+
+	do {
+		ret = futex(wq, FUTEX_WAKE, val, NULL, NULL, 0);
+		if (ret > 0) {
+			woken += ret;
+			val -= ret;
+		} else
+			retries--;
+	} while (retries && val && (woken < N - 1));
+
+	if (woken < N - 1) {
+		log("WARNING: Could not wake %d children. Woke %d instead. waitq: %d\n", N - 1, woken, atomic_read(waitq));
+		log_error("        ");
+	}
+	return -1;
+}
+
+int do_lock_contended_pi_futex(int retries)
+{
+	int do_print = 1;
+
+again:
+	if (futex((int*)pi_futex, FUTEX_LOCK_PI, atomic_read(pi_futex),
+	      NULL, NULL, 0) == 0)
+		return 0;
+	switch(errno) {
+	case ETIMEDOUT:
+		log_error("WARNING: FUTEX_WAIT ETIMEDOUT");
+		break;
+	case ERESTART:
+		if (do_print && do_print != ERESTART) {
+			log_error("INFO: RESTARTING FUTEX_WAIT (I think I was FROZEN)");
+			do_print = ERESTART; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+	case EAGAIN: /* EWOULDBLOCK */
+		if (do_print && do_print != EAGAIN) {
+			log_error("WARNING: locking contended pi futex returned EAGAIN");
+			do_print = EAGAIN; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+		break;
+	case EINTR:
+		if (do_print && do_print != EINTR) {
+			log_error("WARNING: FUTEX_WAIT EINTR");
+			do_print = EINTR; /* primitive log-spam prevention */
+		}
+		if (!retries)
+			break;
+		retries--;
+		goto again;
+		break;
+	case EACCES:
+		log("FAIL: FUTEX_WAIT EACCES - no read access to futex memory\n");
+		break;
+	case EFAULT:
+		log("FAIL: FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+		break;
+	case EINVAL:
+		log("FAIL: FUTEX_WAIT EINVAL - undefined futex operation\n");
+		break;
+	case ENOSYS:
+		log("FAIL: FUTEX_WAIT ENOSYS - undefined futex operation\n");
+		break;
+	default:
+		log_error("FAIL: FUTEX_WAIT unexpected error (missing from man page)");
+		break;
+	}
+	return -1;
+}
+
+int do_unlock_contended_pi_futex(int retries)
+{
+	if (futex((int*)pi_futex, FUTEX_UNLOCK_PI, 1, NULL, NULL, 0) == 0)
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
+		log_error("INFO: retrying release_pi_futex since:");
+		return 1;
+	case EFAULT: /* We specified the wrong pi_futex address. */
+		log("FAIL: wrong futex address or page fault/futex race in-kernel.\n");
+		break;
+	case EINVAL:
+		/*
+		 * The old value is wrong. We should never
+		 * get this since the kernel ignores the val
+		 * passed through sys_futex().
+		 */
+		log("FAIL: kernel got confused and lost the old futex value.\n");
+		break;
+	case EPERM:
+		/*
+		 * We are unable to release the futex.
+		 * We may not be holding it like we think
+		 * we do.
+		 */
+		log_error("FAIL: This process seems to lack permission to release a futex it expects to be holding. Maybe it's not being held?\n");
+		break;
+	case EAGAIN:
+		/*
+		 * Task holding the futex is exitting. Odd,
+		 * that's us!
+		 */
+		log("FAIL: kernel insists we're exitting but we're really not!\n");
+		break;
+	case ENOMEM:
+		log_error("FAIL:");
+		break;
+	case ESRCH:
+		/*
+		 * Task that held the futex is no more?! But
+		 * that's us!
+		 */
+		log("FAIL: The kernel can't seem to find this process! I sense impending doom!\n");
+		break;
+	}
+
+	return -1;
+}
+
+long child_static_priority(int child_num)
+{
+	return prio_min + child_num; /* inverted: + (N - 1 - child_num);*/
+}
+
+int kid(void *trash)
+{
+	pid_t tid = gettid();
+	int child_num = (int)trash;
+	long my_prio = child_static_priority(child_num);
+	long held_prio = 0;
+	int retval = -1;
+	int retries = 100;
+	unsigned long pi_val;
+
+	if (sched_getscheduler(tid) != sched_policy) {
+		log_error("FAIL: failed to set scheduler policy of children.\n");
+		return retval;
+	}
+	retval--;
+	if (set_my_static_priority(my_prio)) {
+		log_error("FAIL: setpriority:");
+		return retval;
+	}
+	retval--;
+
+	/* WARN_ON(held_prio != my_prio); */
+	if (get_my_static_priority(&held_prio)) {
+		log_error("FAIL: getpriority:");
+		return retval;
+	}
+	retval--;
+	if (my_prio != held_prio) {
+		log("WARNING: Unexpected priority. Tried to set %ld but got %ld.\n", my_prio, held_prio);
+	}
+	retval --;
+
+	if (child_num > 0) {
+		atomic_inc(&dumb_barrier[0]); /* 1 */
+		atomic_inc(waitq);
+		/* race between inc of waitq and futex()?? */
+		if (sleep_on_waitq((int*)waitq, atomic_read(waitq), retries) != 0) {
+			retval--;
+			return retval;
+		}
+		retval--;
+
+		/*
+		 * Now we attempt to acquire the pi futex. We should find
+		 * ourselves contending on it.
+		 */
+		pi_val = atomic_cmpxchg(pi_futex, 0, tid);
+		if (pi_val == tid)
+			log("WARNING: child %d found uncontended pi futex.\n", tid);
+		else if (do_lock_contended_pi_futex(retries) != 0) {
+			log("FAIL: child %d unable to lock pi futex.\n", tid);
+		}
+
+		/* Compare our priority to what we set above. */
+		retval--;
+		if (get_dynamic_priority(tid, &held_prio))
+			goto release_pi_futex;
+		retval--;
+		log("INFO: child %d enters the critical section with priority %ld.\n", tid, held_prio);
+		if (held_prio != my_prio) {
+			/*
+			 * We should not have elevated priority
+			 * since, after the first acquisition the futex
+			 * should wake the next highest priority waiter.
+			 */
+			log("FAIL: Elevated priority indicates child %d not woken in priority order.\n", tid);
+			goto release_pi_futex;
+		} else
+			log("PASS: Woken in priority order.\n");
+		retval = 0;
+	} else {
+		pi_val = atomic_cmpxchg(pi_futex, 0, tid);
+		retval--;
+		if (pi_val != 0) {
+			log("FAIL: lowest priority child %d found contended pi futex.\n", tid);
+			return retval;
+		}
+		retval--;
+
+		/* Now we have the pi futex but nobody else is waiting for it */
+		for (retries = 1000; atomic_read(&dumb_barrier[0]) < (N - 1);
+		     retries--)
+			usleep(1000);
+		retval--;
+
+		log("INFO: Normal priorities (no inheritance): \n");
+		dump_priorities();
+
+		/* All other children are waiting on the waitq - wake them */
+		wake_waitq((int*)waitq, N - 1, retries);
+		atomic_inc(&dumb_barrier[0]); /* 1 */
+		/* smp_mb() ?? */
+		retval--;
+
+		retval--;
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
+		log("INFO: signalling ready for checkpointing\n");
+		set_checkpoint_ready();
+		while (!test_checkpoint_done()) { sleep(1); }
+
+		log("INFO: lowest priority child %d priority before holding pi futex: %ld, during: %ld\n", tid, my_prio, held_prio);
+		log("INFO: Inherited priorities: \n");
+		dump_priorities();
+		if (held_prio >= child_static_priority(N - 1)) {
+			log("PASS: Inherited priority.\n");
+			retval = 0;
+		} else {
+			log("FAIL: Failed to inherit priority!\n");
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
+
+	atomic_inc(&dumb_barrier[1]); /* 2 */
+	/* smp_mb() ?? */
+	if (retval)
+		log("FAIL: child %d failed with %d\n", tid, retval);
+	return retval;
+}
+
+void dump (const char *prefix)
+{
+	/* smp_mb() ?? */
+	printf("%s children past 1: %d\t children past 2: %d\t futex: %d\n",
+	       prefix,
+	       atomic_read(&dumb_barrier[0]),
+	       atomic_read(&dumb_barrier[1]),
+	       atomic_read(pi_futex));
+}
+
+void sig_dump(int signum)
+{
+	dump("Interrupt sample:");
+	dump_priorities();
+}
+
+int main(int argc, char **argv)
+{
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
+		log_error("FAIL: sched_get_priority_min|max");
+		fclose(logfp);
+		exit(1);
+	}
+
+	/* rlimit also restricts prio_max */
+	{
+		struct rlimit lim;
+		getrlimit(RLIMIT_RTPRIO, &lim);
+		log("INFO: RLIMIT_RTPRIO: soft (cur): %ld hard (max): %ld\n",
+			lim.rlim_cur, lim.rlim_max);
+		if (lim.rlim_cur == 0) {
+			log("FAIL: process is restricted from manipulating priorities.\n");
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
+		log_error("FAIL: sched_setscheduler");
+		fclose(logfp);
+		exit(3);
+	}
+	if (N > (prio_max - prio_min))
+		N = prio_max - prio_min;
+	if (N < 1) {
+		log("FAIL: Not enough priority levels to run test.\n");
+		fclose(logfp);
+		exit(4);
+	}
+
+	log("INFO: running test with %d children\n", N);
+
+	/* Initialize the waitq to hold N - 1 processes */
+	atomic_set(waitq, -(N - 1));
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("FAIL: move_to_cgroup");
+		fclose(logfp);
+		exit(5);
+	}
+
+
+	kids = malloc(sizeof(pid_t)*N);
+	if (kids == NULL) {
+		log_error("FAIL: malloc");
+		fclose(logfp);
+		exit(7);
+	}
+
+	waitq = alloc_futex_mem(sizeof(*waitq));
+	if (!waitq) {
+		log_error("FAIL: alloc_futex_mem");
+		fclose(logfp);
+		exit(8);
+	}
+	atomic_set(waitq, -1);
+	pi_futex = alloc_futex_mem(sizeof(*pi_futex));
+	if (!pi_futex) {
+		log_error("FAIL: alloc_futex_mem");
+		fclose(logfp);
+		exit(9);
+	}
+	atomic_set(pi_futex, 0);
+	signal(SIGINT, sig_dump);
+
+	fflush(logfp);
+	fflush(stderr);
+	fflush(stdout);
+	for (i = 0; i < N; i++) {
+		char *new_stack = malloc(SIGSTKSZ*8);
+		kids[i] = clone(kid, new_stack + SIGSTKSZ*8, clone_flags,
+				(void*)i);
+		if (kids[i] <= 0)
+			break;
+		log("INFO: thread %d started.\n", kids[i]);
+	}
+
+	if (i < N) {
+		log_error("FAIL: couldn't start N children");
+		log("killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		excode = 3;
+		goto out;
+	}
+
+	sleep(1);
+	log("INFO: Waiting for children to finish.\n");
+	for (i = 1000; atomic_read(&dumb_barrier[1]) < N; i--)
+		usleep(1000);
+	excode = 0;
+	log("INFO: %d of %d children past point 2.\n", atomic_read(&dumb_barrier[1]), N);
+
+	do {
+		/*
+		 * __WALL allows us to wait for all threads to exit
+		 * but we won't get status for each!
+		 */
+		finished = waitpid(-1, &status, __WALL);
+		if (!finished)
+			continue;
+		if ((finished == -1) && (errno == ECHILD))
+			break;
+
+		log("INFO: %d exitted\n", finished);
+		/* Save any [ir]regular termination info in excode. */
+		if (WIFEXITED(status)) {
+			log("INFO: child %d exitted with %d\n", finished,
+			    WEXITSTATUS(status));
+			if (!excode)
+				excode = WEXITSTATUS(status);
+		} else if (WIFSIGNALED(status)) {
+			log("FAIL: child %d terminated irregularly with signal %d.\n", finished, WTERMSIG(status));
+			if (!excode)
+				excode = WTERMSIG(status);
+		}
+	} while(1);
+out:
+	fflush(logfp);
+	fclose(logfp);
+	free(kids);
+	exit(excode);
+}
diff --git a/futex/plain.c b/futex/plain.c
new file mode 100644
index 0000000..9490869
--- /dev/null
+++ b/futex/plain.c
@@ -0,0 +1,205 @@
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
+
+#ifndef CHECKPOINT_SUBTREE
+#define CHECKPOINT_SUBTREE 1
+#endif
+
+#include "libcrtest/libcrtest.h"
+
+
+/*
+ * Test the contended case of simple futex operations by causing a bunch of
+ * tasks to WAIT. Then, after checkpoint WAKE them all at once.
+ *
+ * NOTE: The only other non-deprecated/non-racy futex operation which may
+ * need further testing across checkpoint/restart is FUTEX_CMP_REQUEUE. However,
+ * it's supposed to be much like WAKE in that it WAKEs N tasks. So, until we
+ * test it, we might suspect it would have similar issues (if any) to WAKE.
+ * (See futex(2) and futex(7))
+ *
+ * Log lines begin with "INFO:", "WARNING:", "PASS:", or "FAIL:". A "FAIL:" in
+ * any log indicates a failure of the test. That failure is propagated via
+ * exit codes to the main thread which reports failures via its exit code.
+ *
+ * "INFO:" Usually indicates what step is about to be taken. It often includes
+ *         specific details such as process ids, times, etc.
+ * "WARNING:" Is an unusual condition that doesn't indicate an error but
+ *            which the test was designed to avoid.
+ * "PASS:" Indicates that part of the test passed.
+ *
+ * Only the exit code of the test indicates whether the whole test passed.
+ */
+
+#define LOG_FILE	"log.futex"
+FILE *logfp = NULL;
+
+/* like perror() except to the child's log */
+#define log_error(s) perror(s)
+
+/* flush the log after every write since we're multithreaded. */
+#define log(fmt, ...) \
+do { \
+	fprintf(logfp, fmt, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+} while(0)
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
+	if (futex((int*)test_futex, FUTEX_WAIT, -1, NULL, NULL, 0) != 0) {
+		switch(errno) {
+			case ETIMEDOUT:
+				perror("ERROR: FUTEX_WAIT ETIMEDOUT");
+				break;
+			case ERESTART:
+				perror("INFO: RESTARTING FUTEX_WAIT (I think I was FROZEN)");
+				goto again;
+			case EAGAIN: /* EWOULDBLOCK */
+				perror("WARNING: FUTEX_WAIT EAGAIN");
+				goto again;
+				break;
+			case EINTR:
+				perror("WARNING: FUTEX_WAIT EINTR");
+				goto again;
+				break;
+			case EACCES:
+				log("ERROR: FUTEX_WAIT EACCES - no read access to futex memory\n");
+				break;
+			case EFAULT:
+				log("ERROR: FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+				break;
+			case EINVAL:
+				log("ERROR: FUTEX_WAIT EINVAL - undefined futex operation\n");
+				break;
+			case ENOSYS:
+				log("ERROR: FUTEX_WAIT ENOSYS - undefined futex operation\n");
+				break;
+			default:
+				perror("ERROR: FUTEX_WAIT unexpected error (missing from man page)");
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
+	int i = 0, num_killed = 0;
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
+		log_error("FAIL: move_to_cgroup");
+		_exit(2);
+	}
+
+	test_futex = alloc_futex_mem(sizeof(*test_futex));
+	if (!test_futex) {
+		log_error("FAIL: alloc_futex_mem");
+		_exit(3);
+	}
+	atomic_set(test_futex, -1);
+
+	signal(SIGINT, sig_dump);
+	for (; i < N; i++) {
+		char *new_stack = malloc(SIGSTKSZ*8);
+		kids[i] = clone(kid, new_stack + SIGSTKSZ*8, clone_flags,
+				(void*)i);
+		if (kids[i] < 0)
+			break;
+	}
+
+	if (i < N) {
+		log_error("FAIL: N x FUTEX_WAIT");
+		log("killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		_exit(4);
+	}
+
+	/* parent */
+	log("INFO: Waiting for children to sleep on futex\n");
+	while (atomic_read(&dumb_barrier[0]) != N) /* 1 */
+		sleep(1);
+	dump("After 1, before 2:");
+
+	sleep(1);
+	log("INFO: signaling ready for checkpointing\n");
+	set_checkpoint_ready();
+	while (!test_checkpoint_done()) { sleep(1); }
+
+	log("INFO: Parent woken\n");
+	atomic_set(test_futex, 1);
+	dump("After 1, cleared test_futex, before 2:");
+	i = futex((int*)test_futex, FUTEX_WAKE, N, NULL, NULL, 0); /* 2 */
+	if (i < N) {
+		perror("FUTEX_WAKE");
+		sleep(1); /* wait for all woken tasks to exit quietly */
+
+		/* kill the rest */
+		for (i = 0; i < N; i++) {
+			if (kill(kids[i], SIGKILL) == 0)
+				num_killed++;
+		}
+		if (num_killed)
+			log("INFO: killed %d remaining child tasks.\n",
+				num_killed);
+	}
+	dump("After 2:");
+
+	do_wait(N);
+	dump("After 3:");
+	exit(0);
+}
diff --git a/futex/robust.c b/futex/robust.c
new file mode 100644
index 0000000..575a653
--- /dev/null
+++ b/futex/robust.c
@@ -0,0 +1,456 @@
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
+/*
+ * Test simple (non-pi) robust futexes across checkpoint/restart.
+ * See Documentation/robust-futexes.txt (and other futex docs in that directory)
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
+ * Robust futex capable ARCHes require: futex_atomic_cmpxchg_inatomic
+ *     x86, sparc64, sh, s390, powerpc have this
+ *     frv, generic do not have this
+ *
+ * Log lines begin with "INFO:", "WARNING:", "PASS:", or "FAIL:". A "FAIL:" in
+ * any log indicates a failure of the test. That failure is propagated via
+ * exit codes to the main thread which reports failures via its exit code.
+ *
+ * "INFO:" Usually indicates what step is about to be taken. It often includes
+ *         specific details such as process ids, times, etc.
+ * "WARNING:" Is an unusual condition that doesn't indicate an error but
+ *            which the test was designed to avoid.
+ * "PASS:" Indicates that part of the test passed.
+ *
+ * Only the exit code of the test indicates whether the whole test passed.
+ */
+
+#define LOG_FILE	"log.robust"
+FILE *logfp = NULL;
+
+/* like perror() except to the child's log */
+#define log_error(s) perror(s)
+
+/* flush the log after every write since we're multithreaded. */
+#define log(fmt, ...) \
+do { \
+	fprintf(logfp, fmt, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+} while(0)
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
+int pipe0[2];
+int pipe1[2];
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
+void write_crumb(int *fd, char crumb)
+{
+	while (write(*fd, &crumb, sizeof(crumb)) != 1) {}
+	close(*fd);
+	*fd = -1;
+}
+
+/*
+ * HACK: we call this after we've gotten the futex. We're supposed to
+ * set list_op_pending *BEFORE* getting the futex.
+ */
+void add_futex(struct futex *rf, int i)
+{
+	log("INFO: child %d adding test_futex\n", i);
+	rf->rlist.next = rlist.list.next;
+	rlist.list.next  = &rf->rlist;
+	rlist.list_op_pending = NULL; /* ARCH TODO make assign atomic */
+}
+
+void acquire_rfutex(struct futex *rf, pid_t tid, int i)
+{
+	unsigned long val = 0;
+
+	rlist.list_op_pending = &rf->rlist; /* ARCH TODO make sure this assignment is atomic */
+
+	tid = tid & FUTEX_TID_MASK;
+	do {
+		val = atomic_cmpxchg(&rf->tid, 0, tid);
+		if (val == 0) {
+			/* This should never happen */
+			log("FAIL: child %d did not see contended futex\n", i);
+			fail++;
+			break;
+		}
+		log("INFO: child %d cmpxchg %lx\n", i, val);
+
+		/*
+		 * else we're contended -- this is the path we always take
+		 * the first time through this loop in this test program.
+		 *
+		 * Set the WAITERS bit to indicate that we need to be woken.
+		 */
+		val = __sync_or_and_fetch(&rf->tid.counter, FUTEX_WAITERS);
+		log("INFO: child %d futex(FUTEX_WAIT, %lx)\n", i, val);
+		if (futex((int*)&rf->tid.counter, FUTEX_WAIT, val,
+			  NULL, NULL, 0) == 0)
+			break;
+		log("INFO: futex returned with errno %d (%s).\n", errno, strerror(errno));
+		switch(errno) {
+			case ERESTART:
+				log("WARNING: ERESTART while sleeping on futex\n");
+				continue;
+			case EAGAIN:
+				log("WARNING: EAGAIN while sleeping on futex\n");
+				continue;
+			case EINTR:
+				log("WARNING: EINTR while sleeping on futex\n");
+				continue;
+			case ETIMEDOUT:
+				log("WARNING: ETIMEDOUT while sleeping on futex\n");
+				continue;
+			case EACCES:
+				log("FAIL: FUTEX_WAIT EACCES - no read access to futex memory\n");
+				fail++;
+				return;
+			case EFAULT:
+				log("FAIL: FUTEX_WAIT EFAULT - bad timeout timespec address or futex address\n");
+				fail++;
+				return;
+			case EINVAL:
+				log("FAIL: FUTEX_WAIT EINVAL - undefined futex operation\n");
+				fail++;
+				return;
+			case ENOSYS:
+				log("FAIL: FUTEX_WAIT ENOSYS - undefined futex operation\n");
+				fail++;
+				return;
+			default:
+				log_error("FAIL: FUTEX_WAIT unexpected error (missing from man page)");
+				fail++;
+				return;
+		}
+	} while(1);
+
+	log("INFO: child %d holding futex.\n", i);
+
+	if (val & FUTEX_OWNER_DIED) {
+		/*
+		 * We're recovering the futex -- clear the
+		 * FUTEX_OWNER_DIED bit
+		 */
+		log("INFO: previous owner %ld died before %d got futex.\n",
+		    val & FUTEX_TID_MASK, i);
+	}
+	val = tid|(val & FUTEX_WAITERS);
+	atomic_set(&rf->tid, val);
+	add_futex(rf, i);
+}
+
+int release_rfutex(struct futex *rf, pid_t tid, int i)
+{
+	unsigned long val;
+
+	val = atomic_cmpxchg(&rf->tid, tid, 0);
+	if (val == tid) {
+		log("FAIL: No waiters on futex.\n");
+		fail++;
+		return -1;
+	}
+
+	if (futex((int*)&rf->tid.counter, FUTEX_WAKE, 1, NULL, NULL, 0) != 1) {
+		log_error("FAIL: futex(FUTEX_WAKE)");
+		log("FAIL: %d (see above for error string)\n", errno);
+		fail++;
+		return -1;
+	}
+
+	/*
+	 * Technically, we're supposed to remove it from the robust list,
+	 * but only the parent is supposed to release the futex in this
+	 * test. Since it starts holding the futex and is "guaranteed" to
+	 * release it, we don't bother with adding it to or removing it
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
+		log("FAIL: getting robust list %d failed.\n", i);
+		fail++;
+		return -1;
+	}
+
+	if ((fetched_rlist == &rlist) &&
+	    (fetched_rlist_size == sizeof(rlist))) {
+		pass++;
+		return 0;
+	} else  {
+		log("FAIL: checking robust list %d: got: (%p size: %d) expected: (%p size: %d)\n", i,
+		    fetched_rlist, fetched_rlist_size,
+		    &rlist, sizeof(rlist));
+		fail++;
+		return -1;
+	}
+}
+
+int kid(int i)
+{
+	if (set_robust_list(&rlist, sizeof(rlist)) < 0) {
+		log_error("FAIL: set_robust_list");
+		log("FAIL: set_robust_list\n");
+		fail++;
+		write_crumb(&pipe0[1], 'x');
+		write_crumb(&pipe1[1], 'x');
+		return -1;
+	}
+	if (check_rlist(i) != 0) {
+		write_crumb(&pipe0[1], 'x');
+		write_crumb(&pipe1[1], 'x');
+		return -1;
+	}
+
+	log("INFO: signaling ready for checkpointing\n");
+	set_checkpoint_ready();
+	while (!test_checkpoint_done()) { sleep(1); }
+
+	if (check_rlist(i) != 0) {
+		write_crumb(&pipe0[1], 'x');
+		write_crumb(&pipe1[1], 'x');
+		return -1;
+	}
+
+	write_crumb(&pipe0[1], '.');
+	acquire_rfutex(test_futex, gettid(), i);
+	write_crumb(&pipe1[1], '.');
+
+	/*
+	 * Now exit instead of releasing the futex. This should cause
+	 * the kernel to wake the next waiter with FUTEX_OWNER_DIED.
+	 */
+	log("INFO: child %d exiting\n", i);
+	pass++;
+	fflush(logfp);
+	if (pass && !fail)
+		exit(EXIT_SUCCESS);
+	exit(1);
+}
+
+void dump (const char *prefix)
+{
+	log("INFO: %s futex: %d\n", prefix, atomic_read(&test_futex->tid));
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
+	int i;
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("FAIL: logfile");/* perror() since logfp unopened */
+		exit(1);
+	}
+	/* redirect stdout and stderr to the log file */
+	if ((dup2(fileno(logfp), 1) != 1) ||
+	    (dup2(fileno(logfp), 2) != 2)) {
+		log_error("FAIL: dup2() logfp to stdout and stderr");
+		goto exit_logs;
+	}
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("FAIL: move_to_cgroup");
+		goto exit_logs;
+	}
+
+	/*
+	 * Create the pipes that children use to tell us when they get to
+	 * specific points. We use this instead of racier sleeps.
+	 */
+	if (pipe(pipe0) == -1) {
+		log_error("FAIL: pipe(pipe0)");
+		goto exit_logs;
+	}
+
+	if (pipe(pipe1) == -1) {
+		log_error("FAIL: pipe(pipe1)");
+		close(pipe0[0]);
+		close(pipe0[1]);
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
+		log_error("FAIL: mmap shared futex");
+		goto exit_pipes;
+	}
+
+	/* Should already be zero but let's be clear about that. */
+	atomic_set(&test_futex->tid, 0);
+	test_futex->rlist.next = &test_futex->rlist;
+
+	i = set_robust_list(&rlist, sizeof(rlist));
+	if (i < 0) {
+		log_error("FAIL: set_robust_list");
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
+			close(pipe0[0]);
+			close(pipe1[0]);
+			kid(i + 1);
+		}
+	}
+
+	close(pipe0[1]);
+	close(pipe1[1]);
+	if (i < N) {
+		log_error("FAIL: N x FUTEX_WAIT");
+		fail++;
+		log("INFO: killing %d child tasks.\n", i);
+		for (; --i > -1;)
+			kill(kids[i], SIGTERM);
+		close(pipe0[0]);
+		close(pipe1[0]);
+		goto exit_logs;
+	}
+
+	for (i = 0; i < N;) {
+		char crumb;
+
+		if (read(pipe0[0], &crumb, 1) != 1)
+			continue;
+		i++;
+		if (crumb == '.')
+			pass++;
+		else
+			fail++;
+	}
+	close(pipe0[0]);
+
+	/* Wake the first child */
+	log("INFO: Parent waking one child\n");
+	release_rfutex(test_futex, gettid(), 0);
+	for (i = 0; i < N;) {
+		char crumb;
+
+		if (read(pipe1[0], &crumb, 1) != 1)
+			continue;
+		i++;
+		if (crumb == '.')
+			pass++;
+		else
+			fail++;
+	}
+	close(pipe1[0]);
+
+	log("INFO: Parent waiting for children\n");
+	do_wait(N); /* N if we're not using CLONE_THREAD, 1 otherwise */
+	fclose(logfp);
+	if (pass && !fail)
+		exit(EXIT_SUCCESS);
+	exit(1);
+exit_pipes:
+	close(pipe0[0]);
+	close(pipe0[1]);
+	close(pipe1[0]);
+	close(pipe1[1]);
+exit_logs:
+	fclose(logfp);
+	exit(1);
+}
diff --git a/futex/run.sh b/futex/run.sh
new file mode 100755
index 0000000..c437f21
--- /dev/null
+++ b/futex/run.sh
@@ -0,0 +1,21 @@
+#!/bin/bash
+
+set -e
+make
+
+TESTS=( ./plain ./robust ./pi )
+
+for T in ${TESTS[@]} ; do
+	rm -f ./checkpoint-*
+	echo "Running test: ${T}"
+	${T} &
+	TEST_PID=$!
+	while [ '!' -r "./checkpoint-ready" ]; do
+		sleep 1
+	done
+	touch "./checkpoint-done"
+	wait ${TEST_PID}
+	echo "Test ${T} done"
+done
+
+rm -f ./checkpoint-* test_futex.bin
