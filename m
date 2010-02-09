From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/6][cr-test][v2]: eclone-2: Ensure eclone() fails if
	selected pid is in use
Date: Tue, 9 Feb 2010 11:34:46 -0800
Message-ID: <20100209193446.GA32274@us.ibm.com>
References: <20100209193331.GB30005@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100209193331.GB30005-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Sat, 30 Jan 2010 12:51:23 -0800
Subject: [PATCH 2/6] eclone-2: Ensure eclone() fails if selected pid is in use

Ensure that eclone() system call fails with -EBUSY if selected pid is in use.

Changelog[v2]:
	- Use libeclone.a from user-cr git tree so tests are portable across
	  architectures.
	- Fix a few nits identified by Serge Hallyn

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/Makefile   |    2 +-
 eclone/eclone-2.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+), 1 deletions(-)
 create mode 100644 eclone/eclone-2.c

diff --git a/eclone/Makefile b/eclone/Makefile
index 10b63d3..91aaffc 100644
--- a/eclone/Makefile
+++ b/eclone/Makefile
@@ -10,7 +10,7 @@ LDFLAGS =
 
 LIB_ECLONE = $(USER_CR_DIR)/libeclone.a
 
-PROGS = eclone-1
+PROGS = eclone-1 eclone-2
 
 all: $(PROGS)
 
diff --git a/eclone/eclone-2.c b/eclone/eclone-2.c
new file mode 100644
index 0000000..5641247
--- /dev/null
+++ b/eclone/eclone-2.c
@@ -0,0 +1,116 @@
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
+/*
+ * Verify that eclone() fails if the selected pid is in use.
+ * We try to assign parent's pid which should already be in use.
+ */
+int verbose = 0;
+int child_tid, parent_tid;
+#define	CHILD_ARG	(void *)0x979797
+
+pid_t pids[2];
+
+int do_child(void *arg)
+{
+	printf("FAIL: Child created with [%d, %d], but we expected child "
+			"creation to fail since pid is in use\n", gettid(),
+ 			getpid());
+	exit(2);
+}
+
+static int do_eclone(int (*child_fn)(void *), void *child_arg,
+		unsigned int flags_low, int nr_pids, pid_t *pids)
+{
+	int rc;
+	void *stack;
+	struct clone_args clone_args;
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
+	if (rc < 0 && errno == EAGAIN) {
+		printf("PASS: Unable to create a process with a pid that is "
+			"in use\n");
+		exit(0);
+	} else {
+		printf("ERROR: eclone(): rc %d, errno %d\n", rc, errno);
+		return rc;
+	}
+}
+
+int main()
+{
+	int rc, pid, status;
+	unsigned long flags;
+	int nr_pids;
+
+	flags = SIGCHLD;
+
+	/*
+	 * Try to create a process with same pid as parent !
+	 */
+	pids[0] = getpid();
+	nr_pids = 1;
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
+	return 0;
+}
-- 
1.6.6.1
