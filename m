From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
Date: Wed, 5 Aug 2009 23:25:05 -0700
Message-ID: <20090806062505.GG5619@us.ibm.com>
References: <20090806061056.GA1044@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090806061056.GA1044-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Subject: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall

Container restart requires that a task have the same pid it had when it was
checkpointed. When containers are nested the tasks within the containers
exist in multiple pid namespaces and hence have multiple pids to specify
during restart.

This patch defines, a new system call, clone_extended() which is like clone(),
but takes a new 'pid_set' parameter.  This parameter lets caller choose
specific pid numbers for the child process, in the process's active and
ancestor pid namespaces. (Descendant pid namespaces in general don't matter
since processes don't have pids in them anyway, but see comments in
copy_target_pids() regarding CLONE_NEWPID).

Unlike clone(), however, clone_extended() needs CAP_SYS_ADMIN, at least for
now, to prevent unprivileged processes from misusing this interface.

While the main motivation for this interface is the need to let a process
choose its 'pid numbers', the clone_extended() interface uses 64-bit clone
flags.  The 'higher' portion of the clone flags are unused and are only
included to preclude yet another version of clone when a new clone flag is
needed. 

===== Interface:

Compared to clone(), clone_extended() needs to pass in three more pieces
of information:

	- additional 32-bit of clone_flags
	- number of pids in the set
	- user buffer containing the list of pids.

But since clone() already takes 5 parameters and some (all ?) architectures
are restricted to 6 parameters to a system-call, additional data-structures
(and copy_from_user()) are needed.

The proposed interface for clone_extended() is:

	struct clone_tid_info {
		void *parent_tid; 	/* parent_tid_ptr parameter */
		void *child_tid; 	/* child_tid_ptr parameter */
	};

	struct pid_set {
		int num_pids;
		pid_t *pids;
	};

	int clone_extended(int flags_low, int flags_high, void *child_stack,
			void *unused, struct clone_tid_info *tid_ptrs,
			struct pid_set *pid_setp);

where:

	- flags_low corresponds to the 'flags' parameter in normal clone().

	- flags_high is currently unused and meant to be used if/when a new
	  clone flag is needed.

	- 'tid_ptrs' is rather an aribtrary grouping of parameters to keep
	  total parameter count to 6

	- pid_setp specifies the pid-numbers for the process in the different
	  pid namespaces (discussed further below). We expect 'struct pid_set'
	  to be useful in other contexts.

	- if pid_setp is NULL and flags_high is 0, clone_extended() behaves
	  like normal clone(), except for an extra copy_from_user() when
	  'tid_ptrs' is non-NULL.

===== Usage: 

	int flags_low = (CLONE_FS|CLONE_VM|SIGCHLD);
	int flags_high = 0;	// unused

	pid_t pids[] = { 0, 77, 99 };
	struct pid_set pid_set;

	int parent_tid;
	int child_tid;
	struct clone_tid_info tid_ptrs = {&parent_tid, &child_tid};

	pid_set.num_pids = sizeof(pids) / sizeof(int);
	pid_set.pids = &pids;

	syscall(__NR_clone_extended, flags_low, flags_high, stack, 
		NULL, &tid_ptrs, &pid_set);

===== Notes on 'struct pid_set' parameter

	When pid_set is specified and a target-pid (i.e pid_set.pids[i]) is 0,
	the kernel continues to assign a pid for the process in that namespace.

	In the above example, pids[0] is 0, meaning the kernel will assign next
	available pid to the process in init_pid_ns.
	
	But kernel will assign pid 77 in the child pid namespace 1 and pid 99
	in pid namespace 2. If either 77 or 99 are taken, the system call fails
	with -EBUSY.

	If 'pid_set.num_pids' exceeds the current nesting level of pid
	namespaces, the system call fails with -EINVAL.

TODO:
	- Its mostly an exploratory patch seeking feedback on the interface.
	- Gently tested.
	- May need additional sanity checks in do_fork_with_pids().

Changelog[v4]:

	(address following comments from Serge Hallyn, Oren Laadan).
	- Rename interface from clone_with_pids() to clone_extended()
	- Add support for clone_flags (define/use 'struct clone_tid_info')
	- Rename 'target_pid_set' to simply 'pid_set' since pid_set may be
	  useful in other contexts.

Changelog[v3]:
	- (Oren Laadan) Allow CLONE_NEWPID flag (by allocating an extra pid
	  in the target_pids[] list and setting it 0. See copy_target_pids()).
	- (Oren Laadan) Specified target pids should apply only to youngest
	  pid-namespaces (see copy_target_pids())
	- (Matt Helsley) Update patch description.

Changelog[v2]:
	- Remove unnecessary printk and add a note to callers of
	  copy_target_pids() to free target_pids.
	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
	  'num_pids == 0' (fall back to normal clone()).
	- Move arch-independent code (sanity checks and copy-in of target-pids)
	  into kernel/fork.c and simplify sys_clone_with_pids()

Changelog[v1]:
	- Fixed some compile errors (had fixed these errors earlier in my
	  git tree but had not refreshed patches before emailing them)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 arch/x86/include/asm/syscalls.h    |    2 +
 arch/x86/include/asm/unistd_32.h   |    1 +
 arch/x86/kernel/entry_32.S         |    1 +
 arch/x86/kernel/process_32.c       |   21 +++++++
 arch/x86/kernel/syscall_table_32.S |    1 +
 kernel/fork.c                      |  108 +++++++++++++++++++++++++++++++++++-
 6 files changed, 133 insertions(+), 1 deletions(-)

Index: linux-2.6/arch/x86/include/asm/syscalls.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/syscalls.h	2009-08-05 19:55:41.000000000 -0700
+++ linux-2.6/arch/x86/include/asm/syscalls.h	2009-08-05 19:56:15.000000000 -0700
@@ -40,6 +40,8 @@
 
 /* kernel/process_32.c */
 int sys_clone(struct pt_regs *);
+int sys_clone_extended(struct pt_regs *);
+int sys_vfork(struct pt_regs *);
 int sys_execve(struct pt_regs *);
 
 /* kernel/signal.c */
Index: linux-2.6/arch/x86/include/asm/unistd_32.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/unistd_32.h	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/arch/x86/include/asm/unistd_32.h	2009-08-05 19:56:15.000000000 -0700
@@ -342,6 +342,7 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
+#define __NR_clone_extended	337
 
 #ifdef __KERNEL__
 
Index: linux-2.6/arch/x86/kernel/entry_32.S
===================================================================
--- linux-2.6.orig/arch/x86/kernel/entry_32.S	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/arch/x86/kernel/entry_32.S	2009-08-05 19:56:15.000000000 -0700
@@ -718,6 +718,7 @@
 PTREGSCALL(iopl)
 PTREGSCALL(fork)
 PTREGSCALL(clone)
+PTREGSCALL(clone_extended)
 PTREGSCALL(vfork)
 PTREGSCALL(execve)
 PTREGSCALL(sigaltstack)
Index: linux-2.6/arch/x86/kernel/process_32.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/process_32.c	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/arch/x86/kernel/process_32.c	2009-08-05 19:56:15.000000000 -0700
@@ -443,6 +443,44 @@
 	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
 }
 
+int sys_clone_extended(struct pt_regs *regs)
+{
+	unsigned long clone_flags_low;
+	unsigned long clone_flags_high;
+	int __user *utids;
+	struct clone_tid_info ktids;
+	unsigned long newsp;
+	int __user *parent_tidptr;
+	int __user *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags_low = regs->bx;
+	/*
+	 * clone_flags_high unused for now. If additional clone flags
+	 * are defined, this could be used
+	 */
+	clone_flags_high = regs->cx;
+	newsp = regs->dx;
+	utids = (int __user *)regs->di;
+	upid_setp = (void __user *)regs->bp;
+
+	if (!newsp)
+		newsp = regs->sp;
+
+	parent_tidptr = NULL;
+	child_tidptr = NULL;
+	if (utids) {
+		int n = sizeof(struct clone_tid_info);
+		if (copy_from_user(&ktids, utids, n))
+			return -EFAULT;
+		parent_tidptr = ktids.parent_tid;
+		child_tidptr = ktids.child_tid;
+	}
+
+	return do_fork_with_pids(clone_flags_low, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * sys_execve() executes a new program.
  */
Index: linux-2.6/arch/x86/kernel/syscall_table_32.S
===================================================================
--- linux-2.6.orig/arch/x86/kernel/syscall_table_32.S	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/arch/x86/kernel/syscall_table_32.S	2009-08-05 19:56:15.000000000 -0700
@@ -336,3 +336,4 @@
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
+	.long ptregs_clone_extended
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/kernel/fork.c	2009-08-05 19:57:10.000000000 -0700
@@ -1338,6 +1338,97 @@
 }
 
 /*
+ * If user specified any 'target-pids' in @upid_setp, copy them from
+ * user and return a pointer to a local copy of the list of pids. The
+ * caller must free the list, when they are done using it.
+ *
+ * If user did not specify any target pids, return NULL (caller should
+ * treat this like normal clone).
+ *
+ * On any errors, return the error code
+ */
+static pid_t *copy_target_pids(void __user *upid_setp)
+{
+	int j;
+	int rc;
+	int size;
+	int unum_pids;		/* # of pids specified by user */
+	int knum_pids;		/* # of pids needed in kernel */
+	pid_t *target_pids;
+	struct pid_set pid_set;
+
+	if (!upid_setp)
+		return NULL;
+
+	rc = copy_from_user(&pid_set, upid_setp, sizeof(pid_set));
+	if (rc)
+		return ERR_PTR(-EFAULT);
+
+	unum_pids = pid_set.num_pids;
+	knum_pids = task_pid(current)->level + 1;
+
+	if (!unum_pids)
+		return NULL;
+
+	if (unum_pids < 0 || unum_pids > knum_pids)
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * To keep alloc_pid() simple, allocate an extra pid_t in target_pids[]
+	 * and set it to 0. This last entry in target_pids[] corresponds to the
+	 * (yet-to-be-created) descendant pid-namespace if CLONE_NEWPID was
+	 * specified. If CLONE_NEWPID was not specified, this last entry will
+	 * simply be ignored.
+	 */
+	target_pids = kzalloc((knum_pids + 1) * sizeof(pid_t), GFP_KERNEL);
+	if (!target_pids)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * A process running in a level 2 pid namespace has three pid namespaces
+	 * and hence three pid numbers. If this process is checkpointed,
+	 * information about these three namespaces are saved. We refer to these
+	 * namespaces as 'known namespaces'.
+	 *
+	 * If this checkpointed process is however restarted in a level 3 pid
+	 * namespace, the restarted process has an extra ancestor pid namespace
+	 * (i.e 'unknown namespace') and 'knum_pids' exceeds 'unum_pids'.
+	 *
+	 * During restart, the process requests specific pids for its 'known
+	 * namespaces' and lets kernel assign pids to its 'unknown namespaces'.
+	 *
+	 * Since the requested-pids correspond to 'known namespaces' and since
+	 * 'known-namespaces' are younger than (i.e descendants of) 'unknown-
+	 * namespaces', copy requested pids to the back-end of target_pids[]
+	 * (i.e before the last entry for CLONE_NEWPID mentioned above).
+	 * Any entries in target_pids[] not corresponding to a requested pid
+	 * will be set to zero and kernel assigns a pid in those namespaces.
+	 *
+	 * NOTE: The order of pids in target_pids[] is oldest pid namespace to
+	 * 	 youngest (target_pids[0] corresponds to init_pid_ns). i.e.
+	 * 	 the order is:
+	 *
+	 * 		- pids for 'unknown-namespaces' (if any)
+	 * 		- pids for 'known-namespaces' (requested pids)
+	 * 		- 0 in the last entry (for CLONE_NEWPID).
+	 */
+	j = knum_pids - unum_pids;
+	size = unum_pids * sizeof(pid_t);
+
+	rc = copy_from_user(&target_pids[j], pid_set.pids, size);
+	if (rc) {
+		rc = -EFAULT;
+		goto out_free;
+	}
+
+	return target_pids;
+
+out_free:
+	kfree(target_pids);
+	return ERR_PTR(rc);
+}
+
+/*
  *  Ok, this is the main fork-routine.
  *
  * It copies the process, and if successful kick-starts
@@ -1354,7 +1445,7 @@
 	struct task_struct *p;
 	int trace = 0;
 	long nr;
-	pid_t *target_pids = NULL;
+	pid_t *target_pids;
 
 	/*
 	 * Do some preliminary argument and permissions checking before we
@@ -1388,6 +1479,17 @@
 		}
 	}
 
+	target_pids = copy_target_pids(pid_setp);
+
+	if (target_pids) {
+		if (IS_ERR(target_pids))
+			return PTR_ERR(target_pids);
+
+		nr = -EPERM;
+		if (!capable(CAP_SYS_ADMIN))
+			goto out_free;
+	}
+
 	/*
 	 * When called from kernel_thread, don't do user tracing stuff.
 	 */
@@ -1449,6 +1551,10 @@
 	} else {
 		nr = PTR_ERR(p);
 	}
+
+out_free:
+	kfree(target_pids);
+
 	return nr;
 }
 
Index: linux-2.6/include/linux/types.h
===================================================================
--- linux-2.6.orig/include/linux/types.h	2009-08-05 19:55:42.000000000 -0700
+++ linux-2.6/include/linux/types.h	2009-08-05 19:56:15.000000000 -0700
@@ -209,6 +209,11 @@
 	pid_t *pids;
 };
 
+struct clone_tid_info {
+	void *parent_tid;
+	void *child_tid;
+};
+
 #endif	/* __KERNEL__ */
 #endif /*  __ASSEMBLY__ */
 #endif /* _LINUX_TYPES_H */
