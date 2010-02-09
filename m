From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/6][cr-test][v2]: eclone-1: Test basic functionality
Date: Tue, 9 Feb 2010 11:33:31 -0800
Message-ID: <20100209193331.GB30005@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 30 Jan 2010 12:49:30 -0800
Subject: [PATCH 1/6] eclone-1: Test basic functionality

Verify that a child process gets the expected pid and arguments on stack
when it is created with eclone() system call.

Changelog[v2]:
	- Use libeclone.a from user-cr git tree so tests are portable across
	  architectures.
	- Fix a couple of nits identified by Serge Hallyn

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile              |    2 +-
 eclone/Makefile       |   21 +++++++++
 eclone/eclone-1.c     |  119 +++++++++++++++++++++++++++++++++++++++++++++++++
 eclone/eclone-tests.h |   66 +++++++++++++++++++++++++++
 4 files changed, 207 insertions(+), 1 deletions(-)
 create mode 100644 eclone/Makefile
 create mode 100644 eclone/eclone-1.c
 create mode 100644 eclone/eclone-tests.h

diff --git a/Makefile b/Makefile
index 95f8b6e..1d412b9 100644
--- a/Makefile
+++ b/Makefile
@@ -1,5 +1,5 @@
 SUBDIRS = libcrtest counterloop fileio simple userns ipc sleep \
-	  process-tree futex epoll taskfs
+	  process-tree futex epoll taskfs eclone
 
 targets = ns_exec mysu
 
diff --git a/eclone/Makefile b/eclone/Makefile
new file mode 100644
index 0000000..10b63d3
--- /dev/null
+++ b/eclone/Makefile
@@ -0,0 +1,21 @@
+#
+# libeclone.a is built/installed from user-cr git-tree. Point USER_CR_DIR
+# to the directory containing libeclone.a and genstack.h
+#
+USER_CR_DIR ?= ../../user-cr
+
+CFLAGS = -Wall -I $(USER_CR_DIR)
+
+LDFLAGS =
+
+LIB_ECLONE = $(USER_CR_DIR)/libeclone.a
+
+PROGS = eclone-1
+
+all: $(PROGS)
+
+$(PROGS): %: %.c
+	$(CC) $(CFLAGS) -o $@ $< $(LIB_ECLONE) $(LDFLAGS)
+
+clean:
+	rm -f *.o $(PROGS)
diff --git a/eclone/eclone-1.c b/eclone/eclone-1.c
new file mode 100644
index 0000000..5aa69ed
--- /dev/null
+++ b/eclone/eclone-1.c
@@ -0,0 +1,119 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <signal.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/syscall.h>
+#include "eclone-tests.h"
+#include "genstack.h"
+
+int verbose = 0;
+int child_tid, parent_tid;
+
+#define CHILD_TID1	377
+#define	CHILD_ARG	(void *)0x979797
+
+pid_t pids[] = { CHILD_TID1 };
+
+int do_child(void *arg)
+{
+	sleep(3);
+
+	if (arg != CHILD_ARG) {
+		printf("ERROR: Expected arg %p, actual %p\n", CHILD_ARG, arg);
+		exit(1);
+	}
+
+	if (gettid() != CHILD_TID1) {
+		printf("FAIL: Child expected pid %d, actual %d\n", CHILD_TID1,
+					getpid());
+		exit(2);
+	} else {
+		printf("PASS: Child got expected pid %d\n", CHILD_TID1);
+		exit(0);
+	}
+
+}
+
+static int do_eclone(int (*child_fn)(void *), void *child_arg, 
+		unsigned int flags_low, int nr_pids, pid_t *pids)
+{
+	int rc;
+	struct clone_args clone_args;
+	genstack stack;
+
+	stack = genstack_alloc(STACKSIZE);
+	if (!stack) {
+		printf("ERROR: genstack_alloc() returns NULL for size %d\n",
+				STACKSIZE);
+		exit(1);
+	}
+
+	memset(&clone_args, 0, sizeof(clone_args));
+	clone_args.child_stack = (u64)(int)genstack_sp(stack);
+	clone_args.child_stack_size = (u64)0;
+	clone_args.parent_tid_ptr = (u64)((int)&parent_tid);
+	clone_args.child_tid_ptr = (u64)((int)&child_tid);
+	clone_args.nr_pids = nr_pids;
+
+	if (verbose) {
+		printf("[%d, %d]: Parent:\n\t child_stack 0x%p, ptidp %llx, "
+				"ctidp %llx, pids %p\n", getpid(), gettid(),
+				stack, clone_args.parent_tid_ptr,
+				clone_args.child_tid_ptr, pids);
+	}
+
+	rc = eclone(child_fn, child_arg, flags_low, &clone_args, pids);
+
+	if (verbose) {
+		printf("[%d, %d]: eclone() returned %d, error %d\n", getpid(),
+				gettid(), rc, errno);
+		fflush(stdout);
+	}
+
+	if (rc < 0) {
+		printf("ERROR: rc %d, errno %d\n", rc, errno);
+		exit(1);
+	}
+
+	return rc;
+}
+
+int main()
+{
+	int rc, pid, status;
+	unsigned long flags; 
+	int nr_pids = 1;
+
+	flags = SIGCHLD|CLONE_PARENT_SETTID|CLONE_CHILD_SETTID;
+
+	pid = do_eclone(do_child, CHILD_ARG, flags, nr_pids, pids);
+
+	if (verbose) {
+		printf("[%d, %d]: Parent waiting for %d\n", getpid(),
+					gettid(), pid);
+	}
+
+	rc = waitpid(pid, &status, __WALL);
+	if (rc < 0) {
+		printf("ERROR: ");
+		verbose = 1;
+	}
+
+	if (verbose) {
+		printf("\twaitpid(): child %d, rc %d, error %d, status 0x%x\n",
+				getpid(), rc, errno, status);
+		if (rc >=0) {
+			if (WIFEXITED(status)) {
+				printf("\t EXITED, %d\n", WEXITSTATUS(status));
+			} else if (WIFSIGNALED(status)) {
+				printf("\t SIGNALED, %d\n", WTERMSIG(status));
+			} 
+		}
+	}
+
+	return 0;
+}
diff --git a/eclone/eclone-tests.h b/eclone/eclone-tests.h
new file mode 100644
index 0000000..f869f99
--- /dev/null
+++ b/eclone/eclone-tests.h
@@ -0,0 +1,66 @@
+#include <errno.h>
+
+/*
+ * Some of these definitions need to eventually be defined  in system files
+ * like <sys/types.h>, <sched.h> etc
+ */
+#ifndef CLONE_NEWPID
+#define CLONE_NEWPID            0x20000000
+#endif
+
+#ifndef CLONE_CHILD_SETTID
+#define CLONE_CHILD_SETTID      0x01000000
+#endif
+
+#ifndef CLONE_PARENT_SETTID
+#define CLONE_PARENT_SETTID     0x00100000
+#endif
+
+#ifndef CLONE_UNUSED
+#define CLONE_UNUSED		0x00001000
+#endif
+
+#define STACKSIZE		8192
+
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+
+struct clone_args {
+        u64 clone_flags_high;
+        /*
+         * Architectures can use child_stack for either the stack pointer or
+         * the base of of stack. If child_stack is used as the stack pointer,
+         * child_stack_size must be 0. Otherwise child_stack_size must be
+         * set to size of allocated stack.
+         */
+        u64 child_stack;
+        u64 child_stack_size;
+        u64 parent_tid_ptr;
+        u64 child_tid_ptr;
+        u32 nr_pids;
+        u32 reserved0;
+};
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+           struct clone_args *clone_args, pid_t *pids);
+
+#if __i386__
+#    define __NR_gettid 224
+#elif __x86_64__
+#    define __NR_gettid	186
+#elif __ia64__
+#    define __NR_gettid	1105
+#elif __s390x__
+#    define __NR_gettid	236
+#elif __powerpc__
+#    define __NR_gettid	207
+#else
+#    error "Architecture not supported for gettid()"
+#endif
+
+/* gettid() is sometimes more useful than getpid() when using clone() */
+static inline int gettid()
+{
+	return syscall(__NR_gettid, 0, 0, 0);
+}
-- 
1.6.6.1
