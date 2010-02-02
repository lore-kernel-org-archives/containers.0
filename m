From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 5/6][cr-tests]: eclone-5: nr_pids must not exceed nesting level
Date: Tue, 2 Feb 2010 11:41:06 -0800
Message-ID: <20100202194106.GD8793@us.ibm.com>
References: <20100202193508.GA8542@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100202193508.GA8542-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Mon, 1 Feb 2010 18:13:51 -0800
Subject: [PATCH 5/6][cr-tests]: eclone-5: nr_pids must not exceed nesting level

Verify that eclone() fails if nr_pids exceeds the current nesting level
of pid namespaces. Also verify that eclone() succeeds in choosing a pid
for a process in a descendant pid namespace.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/Makefile   |    2 +-
 eclone/eclone-5.c |  174 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 175 insertions(+), 1 deletions(-)
 create mode 100644 eclone/eclone-5.c

diff --git a/eclone/Makefile b/eclone/Makefile
index 86ca859..5777643 100644
--- a/eclone/Makefile
+++ b/eclone/Makefile
@@ -3,7 +3,7 @@ CFLAGS = -Wall
 
 LDFLAGS = 
 
-PROGS = eclone-1 eclone-2 eclone-3 eclone-4
+PROGS = eclone-1 eclone-2 eclone-3 eclone-4 eclone-5
 
 all: $(PROGS)
 
diff --git a/eclone/eclone-5.c b/eclone/eclone-5.c
new file mode 100644
index 0000000..ceaef02
--- /dev/null
+++ b/eclone/eclone-5.c
@@ -0,0 +1,174 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <signal.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/syscall.h>
+#define _GNU_SOURCE
+#include <sched.h>
+#include "clone_args.h"
+
+/*
+ * Verify that eclone() fails if nr_pids exceeds the current nesting level
+ * of pid namespaces
+ */
+int verbose = 0;
+
+#define CHILD_TID1	377
+#define	CHILD_TID2	399
+#define	CHILD_ARG	(void *)0x979797
+
+pid_t pids_list[] = { CHILD_TID1, CHILD_TID2 };
+int parent_tid;
+int child_tid;
+
+int do_child(void *arg)
+{
+	if (verbose)
+		printf("Child created with [%d, %d]\n", gettid(), getpid());
+
+	sleep(2);
+	exit(0);
+}
+
+static int myclone(int (*child_fn)(void *), void *child_arg, 
+		unsigned int flags_low, int nr_pids, pid_t *pids_list)
+{
+	int rc;
+	void *stack;
+	struct clone_args ca;
+	int args_size;
+
+	stack = setup_stack(child_fn, child_arg, STACKSIZE);
+	if (!stack) {
+		printf("ERROR: setup_stack returns NULL for size %d\n",
+				STACKSIZE);
+		exit(1);
+	}
+
+	memset(&ca, 0, sizeof(ca));
+	ca.child_stack_base = (u64)(int)stack;
+	ca.child_stack_size = (u64)0;
+	ca.parent_tid_ptr = (u64)((int)&parent_tid);
+	ca.child_tid_ptr = (u64)((int)&child_tid);
+	ca.nr_pids = nr_pids;
+
+	if (verbose) {
+		printf("[%d, %d]: Parent:\n\t child_stack 0x%p, ptidp %llx, "
+				"ctidp %llx, pids %p\n", getpid(), gettid(),
+				stack, ca.parent_tid_ptr, ca.child_tid_ptr,
+				pids_list);
+	}
+
+	errno = 0;
+	args_size = sizeof(struct clone_args);
+	rc = eclone(flags_low, &ca, args_size, pids_list);
+
+	if (verbose) {
+		printf("[%d, %d]: eclone() returned %d, error %d\n", getpid(),
+				gettid(), rc, errno);
+		fflush(stdout);
+	}
+
+	return rc;
+}
+
+int do_test(void *arg)
+{
+	int rc, pid, status;
+	unsigned long flags; 
+	int nested_ns;
+	int nr_pids;
+	int error;
+
+	nested_ns = *(int *)arg;
+	nr_pids = 2;
+
+	flags = SIGCHLD|CLONE_PARENT_SETTID|CLONE_CHILD_SETTID;
+
+	pid = myclone(do_child, (void *)CHILD_ARG, flags, nr_pids, pids_list);
+
+	error = 0;
+	if (pid < 0)
+		error = errno;
+
+	/* If we did create a child, wait for it to exit */
+	if (pid > 0) {
+		rc = waitpid(pid, &status, __WALL);
+		if (rc < 0) {
+			printf("%d: ERROR: waitpid() rc %d, error %d\n", 
+					getpid(), rc, errno);
+			verbose = 1;
+		}
+	}
+
+	if (verbose) {
+		printf("%d: nested_ns %d, pid %d, error %d\n", getpid(),
+				nested_ns, pid, error);
+	}
+
+	/*
+	 * We set nr_pids to 2 above. If we cloned from current pid ns,
+	 * eclone() must fail with EINVAL. If we eclone() from a nested pid
+	 * ns, eclone() must succeed. In all other cases, test has failed.
+	 */
+	rc = 0;
+	if (!nested_ns && (pid < 0) && (error == EINVAL)) {
+		printf("%d: PASSED: Got EINVAL when nr_pids > nesting-depth\n",
+				getpid());
+	} else if (nested_ns && (pid > 0)) {
+		printf("%d: PASSED: eclone() succeeded in nested pid-ns\n",
+				getpid());
+	} else {
+		printf("%d: FAILED: nested_ns %d, pid %d, error %d\n", getpid(),
+				nested_ns, pid, error);
+		rc = 1;
+	}
+
+	fflush(stdout);
+	return rc;
+}
+
+int main()
+{
+	int rc, pid, status;
+	int nested_ns;
+	unsigned long flags; 
+	void *stack;
+
+	/* First test in current pid namespace */
+	nested_ns = 0;
+	rc = do_test(&nested_ns);
+	if (rc)
+		exit(rc);
+
+	/* Then test in a nested pid-namespace - use normal clone() */
+	stack = malloc(STACKSIZE);
+	if (!stack) {
+		printf("ERROR: setup_stack returns NULL for size %d\n",
+				STACKSIZE);
+		exit(1);
+	}
+	stack += (STACKSIZE - 1);
+
+	nested_ns = 1;
+	flags = SIGCHLD|CLONE_NEWPID|CLONE_NEWNS;
+	pid = clone(do_test, stack, flags, (void *)&nested_ns, NULL, NULL, NULL);
+	if (pid < 0) {
+		printf("ERROR: clone() failed, pid %d, error %s\n", pid,
+				strerror(errno));
+		exit(1);
+	}
+
+	rc = waitpid(pid, &status, __WALL);
+	if (rc < 0) {
+		printf("ERROR: waitpid() failed, rc %d, error %s\n", rc,
+				strerror(errno));
+		fflush(stdout);
+		exit(1);
+	}
+	return 0;
+}
-- 
1.6.6.1
