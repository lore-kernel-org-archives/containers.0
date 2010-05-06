From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/1] Fix typos and minor errors in eclone documentation
Date: Wed,  5 May 2010 20:22:23 -0700
Message-ID: <1273116143-20963-1-git-send-email-sukadev@linux.vnet.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

The typos/errors were identified by Randy Dunlap. Also add a pointer to the
user-cr git tree and a note about building eclone() library interface for other
architectures. This pointer can probably be removed when eclone() makes it
into libc.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Documentation/eclone |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/Documentation/eclone b/Documentation/eclone
index c2f1b4b..c1032d5 100644
--- a/Documentation/eclone
+++ b/Documentation/eclone
@@ -13,7 +13,7 @@ struct clone_args {
 sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 		pid_t * __user pids)
 
-	In addition to doing everything that clone() system call does, the
+	In addition to doing everything that the clone() system call does, the
 	eclone() system call:
 
 		- allows additional clone flags (31 of 32 bits in the flags
@@ -30,7 +30,7 @@ sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 	pids to specify during restart.
 
 	The @flags_low parameter is identical to the 'clone_flags' parameter
-	in existing clone() system call.
+	in the existing clone() system call.
 
 	The fields in 'struct clone_args' are meant to be used as follows:
 
@@ -47,35 +47,34 @@ sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 		clone() and clone2() (on IA64) system calls. The usage of
 		these two fields depends on the processor architecture.
 
-		Most architectures use ->child_stack to pass-in a stack-pointer
+		Most architectures use ->child_stack to pass in a stack-pointer
 		itself and don't need the ->child_stack_size field. On these
 		architectures the ->child_stack_size field must be 0.
 
-		Some architectures, eg IA64, use ->child_stack to pass-in the
+		Some architectures, e.g. IA64, use ->child_stack to pass in the
 		base of the region allocated for stack. These architectures
-		must pass in the size of the stack-region in ->child_stack_size.
+		must pass in the size of the stack region in ->child_stack_size.
 
 	u64 parent_tid_ptr;
 	u64 child_tid_ptr;
 
 		These two fields correspond to the 'parent_tid_ptr' and
-		'child_tid_ptr' fields in the clone() system call
+		'child_tid_ptr' fields in the clone() system call.
 
 	u32 nr_pids;
 
 		nr_pids specifies the number of pids in the @pids array
 		parameter to eclone() (see below). nr_pids should not exceed
-		the current nesting level of the calling process (i.e if the
+		the current nesting level of the calling process (i.e. if the
 		process is in init_pid_ns, nr_pids must be 1, if process is
 		in a pid namespace that is a child of init-pid-ns, nr_pids
 		cannot exceed 2, and so on).
 
 	u32 reserved0;
-	u64 reserved1;
 
-		These fields are intended to extend the functionality of the
+		This field is intended to extend the functionality of the
 		eclone() in the future, while preserving backward compatibility.
-		They must be set to 0 for now.
+		It must be set to 0 for now.
 
 	The @cargs_size parameter specifes the sizeof(struct clone_args) and
 	is intended to enable extending this structure in the future, while
@@ -90,7 +89,7 @@ sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 	namespace in which case the process is a container-init (and must have
 	the pid 1 in that namespace).
 
-	See CLONE_NEWPID section of clone(2) man page for details about pid
+	See CLONE_NEWPID section of the clone(2) man page for details about pid
 	namespaces.
 
 	If a pid in the @pids list is 0, the kernel will assign the next
@@ -103,8 +102,8 @@ sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 	The order of pids in @pids is oldest in pids[0] to youngest pid
 	namespace in pids[nr_pids-1]. If the number of pids specified in the
 	@pids list is fewer than the nesting level of the process, the pids
-	are applied from youngest namespace. i.e if the process is nested in
-	a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
+	are applied from the youngest namespace. I.e. if the process is nested
+	in a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
 	are applied to levels 6, 5 and 4. Levels 0 through 3 are assumed to
 	have a pid of '0' (the kernel will assign a pid in those namespaces).
 
@@ -119,17 +118,25 @@ sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
 		CAP_SYS_ADMIN is not required).
 
 	EINVAL	The number of pids specified in 'clone_args.nr_pids' exceeds
-		the current nesting level of parent process
+		the current nesting level of parent process.
 
 	EINVAL	Not all specified clone-flags are valid.
 
 	EINVAL	The reserved fields in the clone_args argument are not 0.
 
 	EINVAL	The child_stack_size field is not 0 (on architectures that
-		pass in a stack pointer in ->child_stack field)
+		pass in a stack pointer in ->child_stack field).
 
 	EBUSY	A requested pid is in use by another process in that namespace.
 
+Following shows an example usage of eclone() on x86. To build/use eclone() with
+other supported architectures (x86_64, ppc and s390), see the clone*[hcS] files
+in the following git-tree.
+
+	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
+
+The Makefile in the top-level directory builds a 'libeclone.a' which implements
+the eclone() interface for the appropriate architecture.
 ---
 /*
  * Example eclone() usage - Create a child process with pid CHILD_TID1 in
-- 
1.6.0.4
