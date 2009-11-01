From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [v10][PATCH 9/9] Document clone_with_pids() syscall
Date: Sun, 1 Nov 2009 12:46:10 -0800
Message-ID: <20091101204610.GH23168@us.ibm.com>
References: <20091101204132.GA22116@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091101204132.GA22116-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <suka@suka.(none)>
Date: Sun, 25 Oct 2009 20:20:00 -0700
Subject: [v10][PATCH 9/9] Document clone_with_pids() syscall

This gives a brief overview of the clone_with_pids() system call.  We should
eventually describe more details in existing clone(2) man page or in
a new man page.

Changelog[v10-rc1]:
	- Rename clone3() to clone_with_pids() and fix some typos.
	- Modify example to show usage with the ptregs implementation.
Changelog[v9]:
	- [Pavel Machek]: Fix an inconsistency and rename new file to
	  Documentation/clone3.
	- [Roland McGrath, H. Peter Anvin] Updates to description and
	  example to reflect new prototype of clone3() and the updated/
	  renamed 'struct clone_args'.

Changelog[v8]:
	- clone2() is already in use in IA64. Rename syscall to clone3()
	- Add notes to say that we return -EINVAL if invalid clone flags
	  are specified or if the reserved fields are not 0.
Changelog[v7]:
	- Rename clone_with_pids() to clone2()
	- Changes to reflect new prototype of clone2() (using clone_struct).

Signed-off-by: Sukadev Bhattiprolu <sukadev-8jLBTbqmX/OZamtmwQBW5tBPR1lH4CV8@public.gmane.org>
---
 Documentation/clone_with_pids |  320 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 320 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/clone_with_pids

diff --git a/Documentation/clone_with_pids b/Documentation/clone_with_pids
new file mode 100644
index 0000000..917992a
--- /dev/null
+++ b/Documentation/clone_with_pids
@@ -0,0 +1,320 @@
+
+struct clone_args {
+	u64 clone_flags_high;
+	u64 child_stack_base;
+	u64 child_stack_size;
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+	u32 nr_pids;
+	u32 clone_args_size;
+	u64 reserved1;
+};
+
+
+clone_with_pids(u32 flags_low, struct clone_args * __user cargs,
+		pid_t * __user pids)
+
+	In addition to doing everything that clone() system call does,
+	the clone_with_pids() system call:
+
+		- allows additional clone flags (31 of 32 bits in the flags
+		  parameter to clone() are in use)
+
+		- allows user to specify a pid for the child process in its
+		  active and ancestor pid namespaces.
+
+	This system call is meant to be used when restarting an application
+	from a checkpoint.  Such restart requires that the processes in the
+	application have the same pids they had when the application was
+	checkpointed. When containers are nested, the processes within the
+	containers exist in multiple pid namespaces and hence have multiple
+	pids to specify during restart.
+
+	The @flags_low parameter is identical to the 'clone_flags' parameter
+	in existing clone() system call.
+
+	The fields in 'struct clone_args' are meant to be used as follows:
+
+	u64 clone_flags_high:
+
+		When clone_with_pids() supports more than 32 clone flags, the
+		higher bits in the clone_flags should be specified in this
+		field.  This field is currently unused and must be set to 0.
+
+	u64 child_stack_base;
+	u64 child_stack_size;
+
+		These two fields correspond to the 'child_stack' fields
+		in clone() and clone2() system calls (on IA64).
+
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+
+		These two fields correspond to the 'parent_tid_ptr' and
+		'child_tid_ptr' fields in the clone() system call
+
+	u32 nr_pids;
+
+		nr_pids specifies the number of pids in the @pids array
+		parameter to clone_with_pids() (see below). nr_pids should
+		not exceed the current nesting level of the calling process
+		(i.e if the process is in init_pid_ns, nr_pids must be 1,
+		if process is in a pid namespace that is a child of
+		init-pid-ns, nr_pids cannot exceed 2, and so on).
+
+	u32 clone_args_size;
+
+		clone_args_size specifes the sizeof(struct clone_args) and is
+		intended to enable extending this structure in the future,
+		while preserving backward compatibility.  For now, this field
+		must be set to the sizeof(struct clone_args) and this size must
+		match the kernel's view of the structure.
+
+	u64 reserved1;
+
+		reserved1 is intended to enable extending the functionality
+		of the clone_with_pids() system call in the future, while
+		preserving backward compatibility. It must currently be set
+		to 0.
+
+	The @pids parameter defines the set of pids that should be assigned to
+	the child process in its active and ancestor pid namespaces. The
+	descendant pid namespaces do not matter since a process does not have a
+	pid in descendant namespaces, unless the process is in a new pid
+	namespace in which case the process is a container-init (and must have
+	the pid 1 in that namespace).
+
+	See CLONE_NEWPID section of clone(2) man page for details about pid
+	namespaces.
+
+	The order of pids in @pids corresponds to the nesting order of pid-
+	namespaces, with @pids[0] corresponding to the init_pid_ns.
+
+	If a pid in the @pids list is 0, the kernel will assign the next
+	available pid in the pid namespace, for the process.
+
+	If a pid in the @pids list is non-zero, the kernel tries to assign
+	the specified pid in that namespace.  If that pid is already in use
+	by another process, the system call fails (see EBUSY below).
+
+	On success, the system call returns the pid of the child process in
+	the parent's active pid namespace.
+
+	On failure, clone_with_pids() returns -1 and sets 'errno' to one of
+	following values (the child process is not created).
+
+	EPERM	Caller does not have the SYS_ADMIN privilege needed to execute
+		this call.
+
+	EINVAL	The number of pids specified in 'clone_args.nr_pids' exceeds
+		the current nesting level of parent process
+
+	EINVAL	Not all specified clone-flags are valid.
+
+	EINVAL	The reserved fields in the clone_args argument are not 0.
+
+	EBUSY	A requested pid is in use by another process in that name space.
+
+---
+/* Example clone_with_pids() usage - Create a child with pid CHILD_TID */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include <unistd.h>
+#include <wait.h>
+#include <sys/syscall.h>
+
+#define __NR_clone_with_pids	337
+#define CLONE_NEWPID            0x20000000
+#define CLONE_CHILD_SETTID      0x01000000
+#define CLONE_PARENT_SETTID     0x00100000
+#define CLONE_UNUSED		0x00001000
+
+#define STACKSIZE	8192
+
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+struct clone_args {
+        u64 clone_flags_high;
+
+        u64 child_stack_base;
+        u64 child_stack_size;
+
+        u64 parent_tid_ptr;
+        u64 child_tid_ptr;
+
+        u32 nr_pids;
+        u32 clone_args_size;
+
+        u64 reserved1;
+};
+
+#define exit		_exit
+
+/*
+ * Following clone_with_pids() is based on code posted by Oren Laadan at:
+ * https://lists.linux-foundation.org/pipermail/containers/2009-June/018463.html
+ */
+#if defined(__i386__) && defined(__NR_clone_with_pids)
+
+int clone_with_pids(int flags_low, struct clone_args *clone_args, int *pids)
+{
+	long retval;
+
+	__asm__  __volatile__(
+		 "movl %0, %%ebx\n\t"		/* flags -> 1st (ebx) */
+		 "movl %1, %%ecx\n\t"		/* clone_args -> 2nd (ecx)*/
+		 "movl %2, %%edx\n\t"		/* pids */
+		 "pushl %%ebp\n\t"		/* save value of ebp */
+		:
+		:"b" (flags_low),
+		 "c" (clone_args),
+		 "d" (pids)
+		);
+
+	__asm__ __volatile__(
+		 "int $0x80\n\t"	/* Linux/i386 system call */
+		 "testl %0,%0\n\t"	/* check return value */
+		 "jne 1f\n\t"		/* jump if parent */
+		 "popl %%ebx\n\t"	/* get subthread function */
+		 "call *%%ebx\n\t"	/* start subthread function */
+		 "movl %2,%0\n\t"
+		 "int $0x80\n"		/* exit system call: exit subthread */
+		 "1:\n\t"
+		 "popl %%ebp\t"		/* restore parent's ebp */
+		:"=a" (retval)
+		:"0" (__NR_clone_with_pids), "i" (__NR_exit)
+		:"ebx", "ecx", "edx"
+		);
+
+	if (retval < 0) {
+		errno = -retval;
+		retval = -1;
+	}
+	return retval;
+}
+
+/*
+ * Allocate a stack for the clone-child and arrange to have the child
+ * execute @child_fn with @child_arg as the argument.
+ */
+void *setup_stack(int (*child_fn)(void *), void *child_arg)
+{
+	void *child_stack;
+	void **new_stack;
+
+        child_stack = malloc(STACKSIZE);
+        if (!child_stack) {
+		perror("malloc()");
+		exit(1);
+	}
+        child_stack = (char *)child_stack + (STACKSIZE - 4);
+
+	new_stack = (void **)child_stack;
+	*--new_stack = child_arg;
+	*--new_stack = child_fn;
+
+	return new_stack;
+}
+
+#endif
+
+/* gettid() is a bit more useful than getpid() when messing with clone() */
+int gettid()
+{
+	int rc;
+
+	rc = syscall(__NR_gettid, 0, 0, 0);
+	if (rc < 0) {
+		printf("rc %d, errno %d\n", rc, errno);
+		exit(1);
+	}
+	return rc;
+}
+
+#define CHILD_TID	377
+struct clone_args clone_args;
+void *child_arg = &clone_args;
+int child_tid;
+
+int do_child(void *arg)
+{
+	struct clone_args *cs = (struct clone_args *)arg;
+	int ctid;
+
+	/* Verify we pushed the arguments correctly on the stack... */
+	if (arg != child_arg)  {
+		printf("Child: Incorrect child arg pointer, expected %p,"
+				"actual %p\n", child_arg, arg);
+		exit(1);
+	}
+
+	/* ... and that we got the thread-id we expected */
+	ctid = *((int *)cs->child_tid_ptr);
+	if (ctid != CHILD_TID) {
+		printf("Child: Incorrect child tid, expected %d, actual %d\n",
+				CHILD_TID, ctid);
+		exit(1);
+	}
+	sleep(3);
+
+	printf("[%d, %d]: Child exiting\n", getpid(), ctid);
+	exit(0);
+}
+
+static int do_clone(int (*child_fn)(void *), void *child_arg,
+		unsigned int flags_low, int nr_pids, pid_t *pids_list)
+{
+	int rc;
+	void *stack;
+	struct clone_args *ca = &clone_args;
+
+	stack = setup_stack(child_fn, child_arg);
+
+	memset(ca, 0, sizeof(*ca));
+	ca->child_stack_base 	= (u64)stack;
+	ca->child_stack_size 	= (u64)0;
+	ca->parent_tid_ptr   	= (u64)0;
+	ca->child_tid_ptr 	= (u64)&child_tid;
+	ca->nr_pids 		= nr_pids;
+	ca->clone_args_size 	= sizeof(*ca);
+
+	rc = clone_with_pids(flags_low, ca, pids_list);
+
+	printf("[%d, %d]: clone_with_pids() returned %d, error %d\n",
+		 getpid(), gettid(), rc, errno);
+
+	return rc;
+}
+
+pid_t pids_list[] = { CHILD_TID, CHILD_TID };
+main()
+{
+	int rc, pid, ret, status;
+	unsigned long flags;
+	int nr_pids = 1;
+
+	flags = SIGCHLD|CLONE_PARENT_SETTID|CLONE_CHILD_SETTID;
+
+	pid = do_clone(do_child, &clone_args, flags, nr_pids, pids_list);
+
+	printf("[%d, %d]: Parent waiting for %d\n", getpid(), gettid(), pid);
+
+	rc = waitpid(pid, &status, __WALL);
+	if (rc < 0) {
+		printf("waitpid(): rc %d, error %d\n", rc, errno);
+	} else {
+		printf("[%d, %d]: child %d:\n\t wait-status 0x%x\n", getpid(),
+			 gettid(), rc, status);
+
+		if (WIFEXITED(status)) {
+			printf("\t EXITED, %d\n", WEXITSTATUS(status));
+		} else if (WIFSIGNALED(status)) {
+			printf("\t SIGNALED, %d\n", WTERMSIG(status));
+		}
+	}
+}
-- 
1.6.0.4
