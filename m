From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add a choosepid() syscall as a simpler alternative to
	clone_with_pids()
Date: Mon,  2 Nov 2009 12:38:13 -0800
Message-ID: <1257194293-12099-1-git-send-email-danms@us.ibm.com>
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
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

This proposed simpler interface builds on all the real work done by Suka's
early patches in his clone3() set.  Instead of passing in the pids we want
in the clone3() call itself, this interface lets us build that list ahead
of time, to be used on the next regular clone().

Some points about the implementation:
 - The first call to choosepid() allocates a pid_t array on current
 - All pids in that list start as zero, which do_fork_with_pids treats as
   undefined
 - A call to clone() or exec() always clears the current set of next pids
 - This was Serge's idea, based on a permutation of Daniel Lezcano's
   cloneat() suggestion
 - This is based on all Suka's hard work, with a trivial change to the
   do_fork_with_pids() function to eliminate the copy_from_user() of the
   pid_t list

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/syscalls.h    |    1 +
 arch/x86/include/asm/unistd_32.h   |    1 +
 arch/x86/kernel/process_32.c       |   19 ++++++++++++++++++-
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/exec.c                          |    2 ++
 include/linux/sched.h              |    3 +++
 kernel/exit.c                      |    3 +++
 kernel/fork.c                      |   33 +++++++++++++++++++++++++++++++++
 8 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 372b76e..a9e9298 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -74,6 +74,7 @@ int sys_vm86(struct pt_regs *);
 asmlinkage long sys_iopl(unsigned int, struct pt_regs *);
 
 /* kernel/process_64.c */
+asmlinkage long sys_choosepid(unsigned int, pid_t);
 asmlinkage long sys_clone(unsigned long, unsigned long,
 			  void __user *, void __user *,
 			  struct pt_regs *);
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 732a307..fe9c6e7 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -342,6 +342,7 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
+#define __NR_choosepid		337
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 59f4524..dbf085a 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -40,6 +40,7 @@
 #include <linux/uaccess.h>
 #include <linux/io.h>
 #include <linux/kdebug.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/pgtable.h>
 #include <asm/system.h>
@@ -433,6 +434,7 @@ int sys_clone(struct pt_regs *regs)
 	unsigned long clone_flags;
 	unsigned long newsp;
 	int __user *parent_tidptr, *child_tidptr;
+	int ret;
 
 	clone_flags = regs->bx;
 	newsp = regs->cx;
@@ -440,7 +442,22 @@ int sys_clone(struct pt_regs *regs)
 	child_tidptr = (int __user *)regs->di;
 	if (!newsp)
 		newsp = regs->sp;
-	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
+
+	if (current->nextpids) {
+		pid_t *pids = current->nextpids;
+
+		current->nextpids = NULL;
+		ret = do_fork_with_pids(clone_flags, newsp, regs, 0,
+					parent_tidptr, child_tidptr,
+					current->nsproxy->pid_ns->level,
+					pids);
+		kfree(pids);
+	} else {
+		ret = do_fork(clone_flags, newsp, regs, 0,
+			      parent_tidptr, child_tidptr);
+	}
+
+	return ret;
 }
 
 /*
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d51321d..be92c97 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -336,3 +336,4 @@ ENTRY(sys_call_table)
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
+	.long sys_choosepid
diff --git a/fs/exec.c b/fs/exec.c
index 172ceb6..242fa28 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1361,6 +1361,8 @@ int do_execve(char * filename,
 	free_bprm(bprm);
 	if (displaced)
 		put_files_struct(displaced);
+	kfree(current->nextpids);
+	current->nextpids = NULL;
 	return retval;
 
 out:
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 994ee03..c2a5e4c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1492,6 +1492,9 @@ struct task_struct {
 	/* bitmask of trace recursion */
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
+
+	pid_t *nextpids;
+
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/exit.c b/kernel/exit.c
index 869dc22..03cfd72 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1009,6 +1009,9 @@ NORET_TYPE void do_exit(long code)
 	if (tsk->splice_pipe)
 		__free_pipe_info(tsk->splice_pipe);
 
+	kfree(tsk->nextpids);
+	tsk->nextpids = NULL;
+
 	preempt_disable();
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
diff --git a/kernel/fork.c b/kernel/fork.c
index 7ae7c67..f3fd82a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -62,6 +62,7 @@
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
 #include <linux/perf_counter.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1455,6 +1456,38 @@ long do_fork(unsigned long clone_flags,
 			parent_tidptr, child_tidptr, 0, NULL);
 }
 
+asmlinkage
+int sys_choosepid(unsigned int level, pid_t pid)
+{
+	unsigned int cur_level = current->nsproxy->pid_ns->level;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (level > cur_level)
+		return -EINVAL;
+
+	/* If the next clone() has CLONE_NEWPID, then we'll have one
+	 * more level than we do now.  Allocate the extra spot, which
+	 * will remain 0 (default) and will correspond to the new
+	 * pid_ns, which prevents the user from choosing the pid in the
+	 * new namespace.
+	 */
+	if (!current->nextpids) {
+		current->nextpids = kzalloc(sizeof(pid_t) * (cur_level + 2),
+					    GFP_KERNEL);
+		if (!current->nextpids)
+			return -ENOMEM;
+	}
+
+	/* This array is in order of init_ns..current_ns, but the index
+	 * we take from the user is the opposite.
+	 */
+	current->nextpids[cur_level - level] = pid;
+
+	return 0;
+}
+
 #ifndef ARCH_MIN_MMSTRUCT_ALIGN
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
-- 
1.6.2.5
