From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/6][cr-test][v2]: Verify eclone() fails if
	clone_flags_high is non-zero
Date: Tue, 9 Feb 2010 11:35:52 -0800
Message-ID: <20100209193552.GC32274@us.ibm.com>
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
Date: Mon, 1 Feb 2010 18:10:32 -0800
Subject: [PATCH 4/6] eclone-4: Verify eclone() fails if clone_flags_high is non-zero

To ensure future extendability, we want the unused fields to be 0. Ensure
eclone() fails if ->clone_flags_high field is non-0.

Changelog[v2]:
	- Use libeclone.a from user-cr git tree so tests are portable across
	  architectures.
	- Fix some nits identified by Serge Hallyn

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/Makefile   |    2 +-
 eclone/eclone-4.c |  115 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+), 1 deletions(-)
 create mode 100644 eclone/eclone-4.c

diff --git a/eclone/Makefile b/eclone/Makefile
index ee0471f..ba3d6ac 100644
--- a/eclone/Makefile
+++ b/eclone/Makefile
@@ -10,7 +10,7 @@ LDFLAGS =
 
 LIB_ECLONE = $(USER_CR_DIR)/libeclone.a
 
-PROGS = eclone-1 eclone-2 eclone-3
+PROGS = eclone-1 eclone-2 eclone-3 eclone-4
 
 all: $(PROGS)
 
diff --git a/eclone/eclone-4.c b/eclone/eclone-4.c
new file mode 100644
index 0000000..1b6cf86
--- /dev/null
+++ b/eclone/eclone-4.c
@@ -0,0 +1,115 @@
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
+ * Verify that eclone() fails if ->clone_flags_high is not 0.
+ */
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
+	printf("FAIL: Child created with [%d, %d]. We expected eclone() to "
+			"fail with EINVAL since clone_flags_high is not 0\n",
+			 gettid(), getpid());
+	exit(2);
+}
+
+static int do_eclone(int (*child_fn)(void *), void *child_arg,
+		unsigned int flags_low, int nr_pids, pid_t *pids)
+{
+	int rc;
+	void *stack;
+	struct clone_args clone_args;
+	int args_size;
+
+	stack = genstack_alloc(STACKSIZE);
+	if (!stack) {
+		printf("ERROR: setup_stack returns NULL for size %d\n",
+				STACKSIZE);
+		exit(1);
+	}
+
+	memset(&clone_args, 0, sizeof(clone_args));
+	clone_args.clone_flags_high = (u64)1 << 33;
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
+	args_size = sizeof(struct clone_args);
+	rc = eclone(child_fn, child_arg, flags_low, &clone_args, pids);
+
+	if (verbose) {
+		printf("[%d, %d]: eclone() returned %d, error %d\n", getpid(),
+				gettid(), rc, errno);
+		fflush(stdout);
+	}
+
+	if (rc < 0 && errno == EINVAL) {
+		printf("PASS: eclone() failed (clone_flags_high not 0)\n");
+		exit(0);
+	} else {
+		printf("FAIL: Expected eclone() to fail with EINVAL");
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
+	flags = SIGCHLD;
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
