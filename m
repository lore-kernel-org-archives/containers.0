From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Mon, 16 Nov 2009 17:18:42 -0600
Message-ID: <1258413522.4031.1036.camel@localhost.localdomain>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
	<1258089886-10034-3-git-send-email-serue@us.ibm.com>
	<1258325156.4031.3.camel@localhost.localdomain>
	<20091116111249.GA32340@us.ibm.com>
	<1258328984.4031.21.camel@localhost.localdomain>
	<20091116182655.GA3777@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091116182655.GA3777-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-11-16 at 12:26 -0600, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > On Mon, 2009-11-16 at 05:12 -0600, Serge E. Hallyn wrote:
> > > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > > On Thu, 2009-11-12 at 23:24 -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > > > > +	if (use_clone) {
> > > > > +		int stacksize = 4*getpagesize();
> > > > > +		void *stack = malloc(stacksize);
> > > > > +
> > > > > +		if (!stack) {
> > > > > +			perror("malloc");
> > > > > +			return -1;
> > > > > +		}
> > > > > +
> > > > > +		printf("about to clone with %lx\n", flags);
> > > > > +		if (chosen_pid)
> > > > > +			printf("Will choose pid %d\n", chosen_pid);
> > > > > +		flags |= SIGCHLD;
> > > > > +		pid = clone_with_pids(do_child, stack, flags, &pid_set,
> > > > > +					(void *)argv);
> > > > 
> > > > The stack argument should be adjusted with the usual stack += stacksize
> > > > - 1 or similar, right?
> > > 
> > > the clone_with_pids() helper in user-cr/clone_s390x.c (and IIRC the
> > > x86 one by Suka also) does this implicitly, by doing:
> > > 
> > > 	s = child_stack;
> > > 	*--s = arg;
> > > 	*--s = fn;
> > > 	child_stack -= 16
> > 
> > That's setting up arguments for the function to run in the child, and
> > afaict that code assumes the value of child_stack is the _end_ of the
> > stack region.
> 
> Yes.
> 
> > The code I quoted above is passing the beginning of the
> > region (the return value from malloc).
> 
> Holy cow, that was a snafu in my switching to sending (stack_base,stack_size)
> for the previous version, and then back again.  It was meant to send
> stack_base+stack_size now.

Okay, here's the violence I've committed against your code to get eclone
working on powerpc (tested 32-bit userspace against 64-bit kernel).

./nsexeccwp -z 300 /bin/bash -c 'echo $$'
[debugging cruft elided]
300

This is meant not for inclusion but for discussion at this point.  I
made some changes that will certainly break the builds for other
architectures.

Note that I have generic code initializing clone_args with the true
stack base and size and passing that to the architecture code.  The
architecture code (e.g. clone_ppc.c) is responsible for calculating the
stack pointer to pass to the kernel.  The architecture code is also
responsible for clearing clone_args.child_stack_size and updating
clone_args.child_stack, adjusting for alignment and arguments if
appropriate.  In this way, we can accommodate ia64 and parisc and keep
platform details in platform-specific code.


 clone_ppc.c  |   54 +++++++++++++++++++++++++++++++++++
 clone_ppc_.S |   88 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 eclone.h     |   25 ++++++++++++++++
 nsexeccwp.c  |   42 ++++++++++++----------------
 4 files changed, 182 insertions(+), 27 deletions(-)

diff --git a/clone_ppc.c b/clone_ppc.c
index 49797fd..9e19fae 100644
--- a/clone_ppc.c
+++ b/clone_ppc.c
@@ -10,14 +10,25 @@
 
 #define _GNU_SOURCE
 
+#include <stdint.h>
+#include <stdio.h>
+#include <string.h>
 #include <unistd.h>
 #include <errno.h>
 #include <sys/types.h>
 #include <sys/syscall.h>
 #include <asm/unistd.h>
 
+#include "eclone.h"
+
 struct target_pid_set;
 
+struct pid_set {
+	size_t nr_pids;
+	pid_t *pids;
+};
+
+
 extern int __clone_with_pids(int (*fn)(void *arg),
 			     void *child_stack ,
 			     int flags,
@@ -56,3 +67,46 @@ int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 }
 
 #endif
+
+extern int __eclone(int (*fn)(void *arg),
+		    void *child_sp,
+		    int flags,
+		    void *fn_arg,
+		    struct clone_args *args,
+		    size_t args_size,
+		    pid_t *pids);
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+	   struct clone_args *clone_args, pid_t *pids)
+{
+	struct clone_args my_args;
+	unsigned long child_sp;
+	int newpid;
+
+	if (clone_args->child_stack)
+		child_sp = clone_args->child_stack +
+			clone_args->child_stack_size - 1;
+	else
+		child_sp = 0;
+
+	my_args = *clone_args;
+	my_args.child_stack = child_sp;
+	my_args.child_stack_size = 0;
+
+	printf("%s: child_sp = %p\n", __func__, (void *)child_sp);
+
+	newpid = __eclone(fn,
+			  (void *)child_sp,
+			  clone_flags_low,
+			  fn_arg,
+			  &my_args,
+			  sizeof(my_args),
+			  pids);
+
+	if (newpid < 0) {
+		errno = -newpid;
+		newpid = -1;
+	}
+
+	return newpid;
+}
diff --git a/clone_ppc_.S b/clone_ppc_.S
index cb3e053..b777b2d 100644
--- a/clone_ppc_.S
+++ b/clone_ppc_.S
@@ -11,6 +11,14 @@
 #include <asm/unistd.h>
 #include "powerpc_asm.h"
 
+#ifndef __NR_clone_with_pids
+#define __NR_clone_with_pids	325
+#endif
+
+#ifndef __NR_eclone
+#define __NR_eclone	323
+#endif
+
 /* int [r3] clone_with_pids(int (*fn)(void *arg) [r3],
  *                          void *child_stack [r4],
  *                          int flags [r5],
@@ -29,10 +37,10 @@
 .globl __clone_with_pids
 __clone_with_pids:
 
-/* No argument validation. */
+	/* No argument validation. */
 
-/* Set up parent's stack frame. */
-stwu	r1,-32(r1)
+	/* Set up parent's stack frame. */
+	stwu	r1,-32(r1)
 
 	/* Save non-volatiles (r28-r31) which we plan to use. */
 	stmw	r28,16(r1)
@@ -88,3 +96,77 @@ parent:
 	neg	r3,r3
 	blr
 
+/* int [r3] eclone(int (*fn)(void *arg) [r3],
+ *                          void *child_sp [r4],
+ *                          int flags [r5],
+ *                          void *fn_arg [r6],
+ *                          struct clone_args *args [r7],
+ *                          size_t args_size [r8],
+ *                          pid_t *pids [r9]);
+ * Creates a child task with the pids specified by pids.
+ * Returns to parent only, child execution and exit is handled here.
+ * On error, returns negated errno.  On success, returns the pid of the child
+ * created.
+ */
+
+.globl __eclone
+__eclone:
+
+	/* No argument validation. */
+
+	/* Set up parent's stack frame. */
+	stwu	r1,-32(r1)
+
+	/* Save non-volatiles (r28-r31) which we plan to use. */
+	stmw	r28,16(r1)
+
+	/* Set up child's stack frame. */
+	clrrwi	r4,r4,4
+	li	r0,0
+	stw	r0,-16(r4)
+
+	/* Save fn, stack pointer, flags, and fn_arg across system call. */
+	mr	r28,r3
+	mr	r29,r4
+	mr	r30,r5
+	mr	r31,r6
+
+	/* Set up arguments for system call. */
+	mr	r3,r5	/* flags */
+	mr	r4,r7	/* clone_args */
+	mr	r5,r8	/* clone_args' size */
+	mr	r6,r9	/* pids */
+
+	/* Do the system call */
+	li	r0,__NR_eclone
+	sc
+
+	/* Parent or child? */
+	cmpwi	cr1,r3,0
+	crandc	4*cr1+eq,4*cr1+eq,4*cr0+so
+	bne	cr1,eclone_parent
+
+	/* Child. Call fn. */
+	mtctr	r28
+	mr 	r3,r31
+	bctrl
+
+	/* Assume result of fn in r3 and exit. */
+	li	r0,__NR_exit
+	sc
+
+eclone_parent:
+	/* Restore non-volatiles. */
+	lmw	r28,16(r1)
+
+	addi	r1,r1,32
+
+	/* Return to caller on success. */
+	bnslr
+
+	/* Handle error.  Negate the return value to signal an error
+	 * to the caller, which must set errno.
+	 */
+	neg	r3,r3
+	blr
+
diff --git a/eclone.h b/eclone.h
new file mode 100644
index 0000000..601a621
--- /dev/null
+++ b/eclone.h
@@ -0,0 +1,25 @@
+#ifndef _ECLONE_H_
+#define _ECLONE_H_
+
+#include <stdint.h>
+
+struct clone_args {
+	uint64_t clone_flags_high;
+	uint64_t child_stack;
+	uint64_t child_stack_size;
+	uint64_t parent_tid_ptr;
+	uint64_t child_tid_ptr;
+
+	uint32_t nr_pids;
+
+	uint32_t reserved0;
+	uint64_t reserved1;
+};
+
+/* arch-dependent code implements this interface */
+extern int eclone(int (*fn)(void *), void *fn_arg,
+		  int clone_flags_low,
+		  struct clone_args *clone_args,
+		  pid_t *pids);
+
+#endif
diff --git a/nsexeccwp.c b/nsexeccwp.c
index a71d9a4..b80b78e 100644
--- a/nsexeccwp.c
+++ b/nsexeccwp.c
@@ -17,29 +17,13 @@
 #include <sys/wait.h>
 
 #include "clone.h"
+#include "eclone.h"
 
 struct pid_set {
 	int num_pids;
 	pid_t *pids;
 };
 
-typedef unsigned long long u64;
-typedef unsigned int u32;
-typedef int pid_t;
-struct clone_args {
-	u64 clone_flags_high;
-
-	u64 child_stack_base;
-	u64 child_stack_size;
-
-	u64 parent_tid_ptr;
-	u64 child_tid_ptr;
-
-	u32 nr_pids;
-
-	u32 reserved0;
-	u64 reserved1;
-};
 /* (until it's supported by libc) from clone_ARCH.c */
 extern int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 			   struct pid_set *target_pids, void *arg);
@@ -210,6 +194,9 @@ int do_child(void *vargv)
 {
 	char **argv = (char **)vargv;
 
+	printf("%s(%p)/%lu\n", __func__, vargv, (unsigned long)getpid());
+	fflush(NULL);
+
 	if (check_newcgrp())
 		return 1;
 
@@ -237,6 +224,7 @@ void write_pid(char *pid_file, int pid)
 
 int main(int argc, char *argv[])
 {
+	int i;
 	int c;
 	unsigned long flags = 0, eflags = 0;
 	char ttyname[256];
@@ -244,11 +232,8 @@ int main(int argc, char *argv[])
 	int ret, use_clone = 0;
 	int pid;
 	char *pid_file = NULL;
-	struct pid_set pid_set;
-	int chosen_pid = 0;
-
-	pid_set.num_pids = 1;
-	pid_set.pids = &chosen_pid;
+	size_t nr_pids = 1;
+	pid_t chosen_pid = 0;
 
 	procname = basename(argv[0]);
 
@@ -287,6 +272,9 @@ int main(int argc, char *argv[])
 	argv = &argv[optind];
 	argc = argc - optind;
 
+	for (i = 0; i < argc; i++)
+		printf("argv[%d] = '%s'\n", i, argv[i]);
+
 	if (do_newcgrp) {
 		ret = pipe(pipefd);
 		if (ret) {
@@ -297,6 +285,7 @@ int main(int argc, char *argv[])
 	}
 
 	if (use_clone) {
+		struct clone_args clone_args;
 		int stacksize = 4*getpagesize();
 		void *stack = malloc(stacksize);
 
@@ -305,12 +294,17 @@ int main(int argc, char *argv[])
 			return -1;
 		}
 
+		memset(&clone_args, 0, sizeof(clone_args));
+		clone_args.child_stack = (unsigned long)stack;
+		clone_args.child_stack_size = stacksize;
+		clone_args.nr_pids = nr_pids;
+
 		printf("about to clone with %lx\n", flags);
 		if (chosen_pid)
 			printf("Will choose pid %d\n", chosen_pid);
+		printf("argv = %p\n", argv);
 		flags |= SIGCHLD;
-		pid = clone_with_pids(do_child, stack, flags, &pid_set,
-					(void *)argv);
+		pid = eclone(do_child, argv, flags, &clone_args, &chosen_pid);
 		if (pid == -1) {
 			perror("clone");
 			return -1;
