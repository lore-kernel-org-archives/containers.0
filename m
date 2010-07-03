From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 11/11][v15]: Document sys_eclone
Date: Sat,  3 Jul 2010 13:32:44 -0700
Message-ID: <1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1278189164-28408-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This gives a brief overview of the eclone() system call.  We should
eventually describe more details in existing clone(2) man page or in
a new man page.

Changelog[v15]:
	- [Albert Cahalan, Randy Dunlap]: Specify stack as [base,offset] on
	  all architectures.
	- [Randy Dunlap]: Fix typos and add a pointer to user-cr for usage
	  examples of eclone() on architectures besides x86.
Changelog[v13]:
	- [Nathan Lynch, Serge Hallyn] Rename ->child_stack_base to
	  ->child_stack and ensure ->child_stack_size is 0 on architectures
	  that don't need it.
	- [Arnd Bergmann] Remove ->reserved1 field
	- [Louis Rilling, Dave Hansen] Combine the two asm statements in the
	  example into one and use memory constraint to avoid unncessary copies.
Changelog[v12]:
	- [Serge Hallyn] Fix/simplify stack-setup in the example code
	- [Serge Hallyn, Oren Laadan] Rename syscall to eclone()

Changelog[v11]:
	- [Dave Hansen] Move clone_args validation checks to arch-indpendent
	  code.
	- [Oren Laadan] Make args_size a parameter to system call and remove
	  it from 'struct clone_args'
	- [Oren Laadan] Fix some typos and clarify the order of pids in the
	  @pids parameter.

Changelog[v10]:
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

Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan  <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Documentation/eclone |  354 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 354 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/eclone

diff --git a/Documentation/eclone b/Documentation/eclone
new file mode 100644
index 0000000..25db2f5
--- /dev/null
+++ b/Documentation/eclone
@@ -0,0 +1,354 @@
+
+struct clone_args {
+	u64 clone_flags_high;
+	u64 child_stack_base;
+	u64 child_stack_size;
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+	u32 nr_pids;
+	u32 reserved0;
+};
+
+
+sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
+		pid_t * __user pids)
+
+	In addition to doing everything that the clone() system call does, the
+	eclone() system call:
+
+		- allows additional clone flags (31 of 32 bits in the flags
+		  parameter to clone() are in use)
+
+		- allows user to specify a pid for the child process in its
+		  active and ancestor pid namespaces.
+
+	This system call is meant to be used when restarting an application
+	from a checkpoint. Such restart requires that the processes in the
+	application have the same pids they had when the application was
+	checkpointed. When containers are nested, the processes within the
+	containers exist in multiple pid namespaces and hence have multiple
+	pids to specify during restart.
+
+	The @flags_low parameter is identical to the 'clone_flags' parameter
+	in the existing clone() system call.
+
+	The fields in 'struct clone_args' are meant to be used as follows:
+
+	u64 clone_flags_high:
+
+		When eclone() supports more than 32 flags, the additional bits
+		in the clone_flags should be specified in this field. This
+		field is currently unused and must be set to 0.
+
+	u64 child_stack_base;
+	u64 child_stack_size;
+
+		These two fields describe the region to be used for the child
+		stack. 
+		
+		Note that this specification of the stack is similar to the
+		clone2() system call (used on IA64) but different from clone()
+		system call. The clone() system call specifies the stack pointer
+		as a parameter, but eclone() and clone2() describe stack as
+		[base, offset].
+
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+
+		These two fields correspond to the 'parent_tid_ptr' and
+		'child_tid_ptr' fields in the clone() system call.
+
+	u32 nr_pids;
+
+		nr_pids specifies the number of pids in the @pids array
+		parameter to eclone() (see below). nr_pids should not exceed
+		the current nesting level of the calling process (i.e. if the
+		process is in init_pid_ns, nr_pids must be 1, if process is
+		in a pid namespace that is a child of init-pid-ns, nr_pids
+		cannot exceed 2, and so on).
+
+	u32 reserved0;
+
+		This field is intended to extend the functionality of the
+		eclone() in the future, while preserving backward compatibility.
+		It must be set to 0 for now.
+
+	The @cargs_size parameter specifes the sizeof(struct clone_args) and
+	is intended to enable extending this structure in the future, while
+	preserving backward compatibility.  For now, this field must be set
+	to the sizeof(struct clone_args) and this size must match the kernel's
+	view of the structure.
+
+	The @pids parameter defines the set of pids that should be assigned to
+	the child process in its active and ancestor pid namespaces. The
+	descendant pid namespaces do not matter since a process does not have a
+	pid in descendant namespaces, unless the process is in a new pid
+	namespace in which case the process is a container-init (and must have
+	the pid 1 in that namespace).
+
+	See CLONE_NEWPID section of the clone(2) man page for details about pid
+	namespaces.
+
+	If a pid in the @pids list is 0, the kernel will assign the next
+	available pid in the pid namespace.
+
+	If a pid in the @pids list is non-zero, the kernel tries to assign
+	the specified pid in that namespace.  If that pid is already in use
+	by another process, the system call fails (see EBUSY below).
+
+	The order of pids in @pids is oldest in pids[0] to youngest pid
+	namespace in pids[nr_pids-1]. If the number of pids specified in the
+	@pids list is fewer than the nesting level of the process, the pids
+	are applied from youngest namespace. I.e if the process is nested in
+	a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
+	are applied to levels 6, 5 and 4. Levels 0 through 3 are assumed to
+	have a pid of '0' (the kernel will assign a pid in those namespaces).
+
+	On success, the system call returns the pid of the child process in
+	the parent's active pid namespace.
+
+	On failure, eclone() returns -1 and sets 'errno' to one of following
+	values (the child process is not created).
+
+	EPERM	Caller does not have the CAP_SYS_ADMIN privilege needed to
+		specify the pids in this call (if pids are not specifed
+		CAP_SYS_ADMIN is not required).
+
+	EINVAL	The number of pids specified in 'clone_args.nr_pids' exceeds
+		the current nesting level of parent process.
+
+	EINVAL	Not all specified clone-flags are valid.
+
+	EINVAL	The reserved fields in the clone_args argument are not 0.
+
+	EINVAL	The child_stack_size field is not 0 (on architectures that
+		pass in a stack pointer in ->child_stack field).
+
+	EBUSY	A requested pid is in use by another process in that namespace.
+
+Following shows an example usage of eclone() on x86. To build/use eclone() with
+other supported architectures (x86_64, ppc and s390), see the clone*[hcS] files
+in the following git-tree.
+
+	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
+
+The Makefile in the top-level directory builds a 'libeclone.a' which implements
+the eclone() interface for the appropriate architecture.
+
+---
+/*
+ * Example eclone() usage - Create a child process with pid CHILD_TID1 in
+ * the current pid namespace. The child gets the usual "random" pid in any
+ * ancestor pid namespaces.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include <unistd.h>
+#include <wait.h>
+#include <sys/syscall.h>
+
+#define __NR_eclone		338
+#define CLONE_NEWPID            0x20000000
+#define CLONE_CHILD_SETTID      0x01000000
+#define CLONE_PARENT_SETTID     0x00100000
+#define CLONE_UNUSED		0x00001000
+
+#define STACKSIZE		8192
+
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+struct clone_args {
+	u64 clone_flags_high;
+	u64 child_stack_base;
+	u64 child_stack_size;
+
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+
+	u32 nr_pids;
+
+	u32 reserved0;
+};
+
+#define exit		_exit
+
+/*
+ * Following eclone() is based on code posted by Oren Laadan at:
+ * https://lists.linux-foundation.org/pipermail/containers/2009-June/018463.html
+ */
+#if defined(__i386__) && defined(__NR_eclone)
+
+int eclone(u32 flags_low, struct clone_args *clone_args, int args_size,
+		int *pids)
+{
+	long retval;
+
+	__asm__ __volatile__(
+		 "movl %3, %%ebx\n\t"	/* flags_low -> 1st (ebx) */
+		 "movl %4, %%ecx\n\t"	/* clone_args -> 2nd (ecx)*/
+		 "movl %5, %%edx\n\t"	/* args_size -> 3rd (edx) */
+		 "movl %6, %%esi\n\t"	/* pids -> 4th (esi)*/
+
+		 "pushl %%ebp\n\t"	/* save value of ebp */
+		 "int $0x80\n\t"	/* Linux/i386 system call */
+		 "testl %0,%0\n\t"	/* check return value */
+		 "jne 1f\n\t"		/* jump if parent */
+
+		 "popl %%esi\n\t"	/* get subthread function */
+		 "call *%%esi\n\t"	/* start subthread function */
+		 "movl %2,%0\n\t"
+		 "int $0x80\n"		/* exit system call: exit subthread */
+		 "1:\n\t"
+		 "popl %%ebp\t"		/* restore parent's ebp */
+
+		:"=a" (retval)
+
+		:"0" (__NR_eclone),
+		 "i" (__NR_exit),
+		 "m" (flags_low),
+		 "m" (clone_args),
+		 "m" (args_size),
+		 "m" (pids)
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
+void *setup_stack(int (*child_fn)(void *), void *child_arg, int size)
+{
+	int rc;
+	void *stack_base;
+	void **stack;
+
+	rc = posix_memalign(&stack_base, getpagesize(), size);
+	if (rc) {
+		perror("posix_memalign()");
+		exit(1);
+	}
+
+	stack = (void **)((unsigned long)stack_base + size);
+	*--stack = child_arg;
+	*--stack = child_fn;
+
+	return stack_base;
+}
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
+#define CHILD_TID1	377
+#define CHILD_TID2	1177
+#define CHILD_TID3	2799
+
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
+	ctid = *((int *)(unsigned long)cs->child_tid_ptr);
+	if (ctid != CHILD_TID1) {
+		printf("Child: Incorrect child tid, expected %d, actual %d\n",
+				CHILD_TID1, ctid);
+		exit(1);
+	} else {
+		printf("Child got the expected tid, %d\n", gettid());
+	}
+	sleep(2);
+
+	printf("[%d, %d]: Child exiting\n", getpid(), ctid);
+	exit(0);
+}
+
+static int do_clone(int (*child_fn)(void *), void *child_arg,
+		unsigned int flags_low, int nr_pids, pid_t *pids_list)
+{
+	int rc;
+	void *stack_base;
+	struct clone_args *ca = &clone_args;
+	int args_size;
+
+	stack_base = setup_stack(child_fn, child_arg, STACKSIZE);
+
+	memset(ca, 0, sizeof(*ca));
+
+	ca->child_stack_base	= (unsigned long)stack_base;
+	ca->child_stack_size	= (u64)STACKSIZE;
+	ca->child_tid_ptr	= (unsigned long)&child_tid;
+	ca->nr_pids		= nr_pids;
+
+	args_size = sizeof(struct clone_args);
+	rc = eclone(flags_low, ca, args_size, pids_list);
+
+	printf("[%d, %d]: eclone() returned %d, error %d\n", getpid(), gettid(),
+				rc, errno);
+	return rc;
+}
+
+/*
+ * Multiple pid_t pid_t values in pids_list[] here are just for illustration.
+ * The test case creates a child in the current pid namespace and uses only
+ * the first value, CHILD_TID1.
+ */
+pid_t pids_list[] = { CHILD_TID1, CHILD_TID2, CHILD_TID3 };
+int main()
+{
+	int rc, pid, status;
+	unsigned long flags;
+	int nr_pids = 1;
+
+	flags = SIGCHLD|CLONE_CHILD_SETTID;
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
+	return 0;
+}
-- 
1.6.0.4
