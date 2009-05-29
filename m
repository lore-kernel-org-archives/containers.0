From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 20:05:58 -0700
Message-ID: <20090529030558.GA2548@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528173019.GB26183@us.ibm.com>
	<4A1F228C.2020201@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1F228C.2020201-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Here is an updated patch with hopefully some useful comments on why
we copy to the end of target_pids[] (comments were harder to write
than the code :-)

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 4 May 2009 01:17:45 -0700
Subject: [PATCH 7/7] Define clone_with_pids syscall

Container restart requires that a task have the same pid it had when it was
checkpointed. When containers are nested the tasks within the containers
exist in multiple pid namespaces and hence have multiple pids to specify
during restart.

clone_with_pids(), intended for use during restart, is the same as clone(),
except that it takes a 'target_pid_set' paramter. This parameter lets caller
choose specific pid numbers for the child process, in the process's active
and descendant pid namespaces. Since the application does/can not know of any
ancestor pid namespaces, it cannot choose a pid in those namespaces.

Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
prevent unprivileged processes from misusing this interface.

Call clone_with_pids as follows:

	pid_t pids[] = { 0, 77, 99 };
	struct target_pid_set pid_set;

	pid_set.num_pids = sizeof(pids) / sizeof(int);
	pid_set.target_pids = &pids;

	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);

If a target-pid is 0, the kernel continues to assign a pid for the process in
that namespace. In the above example, pids[0] is 0, meaning the kernel will
assign next available pid to the process in init_pid_ns. But kernel will assign
pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
77 or 99 are taken, the system call fails with -EBUSY.

If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
the system call fails with -EINVAL.

Its mostly an exploratory patch seeking feedback on the interface.

NOTE:
	Compared to clone(), clone_with_pids() needs to pass in two more
	pieces of information:

		- number of pids in the set
		- user buffer containing the list of pids.

	But since clone() already takes 5 parameters, use a 'struct
	target_pid_set'.

TODO:
	- Gently tested.
	- May need additional sanity checks in do_fork_with_pids().
	- Allow CLONE_NEWPID() with clone_with_pids() (ensure target-pid in
	  the namespace is either 1 or 0).

Changelog[v2]:
	- (Oren Laadan) Specified target pids should apply to youngest
	  pid-namespaces only (see comments in copy_target_pids())
	- Remove unnecessary printk and add a note to callers of
	  copy_target_pids() to free target_pids.
	- (Matt Helsley) Update patch description.
	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
	  'num_pids == 0' (fall back to normal clone()).
	- Move arch-independent code (sanity checks and copy-in of target-pids)
	  into kernel/fork.c and simplify sys_clone_with_pids()

Changelog[v1]:
	- Fixed some compile errors (had fixed these errors earlier in my
	  git tree but had not refreshed patches before emailing them)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/syscalls.h    |    1 +
 arch/x86/include/asm/unistd_32.h   |    1 +
 arch/x86/kernel/entry_32.S         |    1 +
 arch/x86/kernel/process_32.c       |   21 +++++++
 arch/x86/kernel/syscall_table_32.S |    1 +
 kernel/fork.c                      |  107 +++++++++++++++++++++++++++++++++++-
 6 files changed, 131 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 7043408..1fdc149 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -31,6 +31,7 @@ asmlinkage int sys_get_thread_area(struct user_desc __user *);
 /* kernel/process_32.c */
 int sys_fork(struct pt_regs *);
 int sys_clone(struct pt_regs *);
+int sys_clone_with_pids(struct pt_regs *);
 int sys_vfork(struct pt_regs *);
 int sys_execve(struct pt_regs *);
 
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 6e72d74..90f906f 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -340,6 +340,7 @@
 #define __NR_inotify_init1	332
 #define __NR_preadv		333
 #define __NR_pwritev		334
+#define __NR_clone_with_pids	335
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index c929add..ee92b0d 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -707,6 +707,7 @@ ptregs_##name: \
 PTREGSCALL(iopl)
 PTREGSCALL(fork)
 PTREGSCALL(clone)
+PTREGSCALL(clone_with_pids)
 PTREGSCALL(vfork)
 PTREGSCALL(execve)
 PTREGSCALL(sigaltstack)
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 76f8f84..1efc3de 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -445,6 +445,27 @@ int sys_clone(struct pt_regs *regs)
 	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
 }
 
+int sys_clone_with_pids(struct pt_regs *regs)
+{
+	unsigned long clone_flags;
+	unsigned long newsp;
+	int __user *parent_tidptr;
+	int __user *child_tidptr;
+	void __user *upid_setp;
+
+	clone_flags = regs->bx;
+	newsp = regs->cx;
+	parent_tidptr = (int __user *)regs->dx;
+	child_tidptr = (int __user *)regs->di;
+	upid_setp = (void __user *)regs->bp;
+
+	if (!newsp)
+		newsp = regs->sp;
+
+	return do_fork_with_pids(clone_flags, newsp, regs, 0, parent_tidptr,
+			child_tidptr, upid_setp);
+}
+
 /*
  * sys_execve() executes a new program.
  */
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index ff5c873..94c1a58 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -334,3 +334,4 @@ ENTRY(sys_call_table)
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long ptregs_clone_with_pids	/* 335 */
diff --git a/kernel/fork.c b/kernel/fork.c
index a16ef7b..06b1583 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1335,6 +1335,84 @@ struct task_struct * __cpuinit fork_idle(int cpu)
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
+	int num_pids;
+	int nesting;
+	pid_t __user *utarget_pids;
+	pid_t *target_pids;
+	struct target_pid_set pid_set;
+
+	if(!upid_setp)
+		return NULL;
+
+	if (copy_from_user(&pid_set, upid_setp, sizeof(pid_set)))
+		return ERR_PTR(-EFAULT);
+
+	num_pids = pid_set.num_pids;
+	utarget_pids = pid_set.target_pids;
+	nesting = task_pid(current)->level + 1;
+
+	if (!num_pids)
+		return NULL;
+
+	if (num_pids < 0 || num_pids > nesting)
+		return ERR_PTR(-EINVAL);
+
+	target_pids = kzalloc((nesting * sizeof(pid_t)), GFP_KERNEL);
+	if (!target_pids)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * A process running in a level-1 pid namespace has two pid
+	 * namespaces and hence two pid numbers. If this process is
+	 * checkpointed, information about these two namespaces are
+	 * saved. We refer to these namespaces as 'known namespaces'.
+	 *
+	 * If this checkpointed process is however restarted in a 
+	 * level-2 pid namespace, the restarted process has an extra
+	 * ancestor pid namespace (i.e 'unknown namespace').
+	 *
+	 * During restart, the process requests specific pids for its
+	 * 'known namespaces' and lets kernel assign pids to its 'unknown
+	 * namespaces'. 
+	 *
+	 * Since the requested-pids correspond to 'known namespaces' and
+	 * since 'known-namespaces' are younger than (i.e descendants of)
+	 * 'unknown-namespaces', copy requested pids to end of target_pids[]
+	 * and copy zeroes to the beginning (so kernel can assign a pid for
+	 * the unknown namespaces).
+	 *
+	 * NOTE: The order of pids in target_pids[] is oldest pid namespace
+	 * 	 to youngest (i.e target_pids[0] corresponds to init_pid_ns). 
+	 */
+	j = nesting - num_pids;
+	size = num_pids * sizeof(pid_t);
+
+	rc = -EFAULT;
+	if (copy_from_user(&target_pids[j], pid_set.target_pids, size))
+		goto out_free;
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
@@ -1351,7 +1429,7 @@ long do_fork_with_pids(unsigned long clone_flags,
 	struct task_struct *p;
 	int trace = 0;
 	long nr;
-	pid_t *target_pids = NULL;
+	pid_t *target_pids;
 
 	/*
 	 * Do some preliminary argument and permissions checking before we
@@ -1385,6 +1463,29 @@ long do_fork_with_pids(unsigned long clone_flags,
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
+
+		/*
+		 * CLONE_NEWPID implies pid == 1
+		 *
+		 * TODO: Should this be more fine-grained ? (i.e would we want
+		 * 	 to have a container-init have a specific pid in an
+		 * 	 ancestor namespace ?) Maybe needed to checkpoint/
+		 * 	 restart an application that has a nested container.
+		 */
+		nr = -EINVAL;
+		if (clone_flags & CLONE_NEWPID)
+			goto out_free;
+	}
+
 	/*
 	 * When called from kernel_thread, don't do user tracing stuff.
 	 */
@@ -1446,6 +1547,10 @@ long do_fork_with_pids(unsigned long clone_flags,
 	} else {
 		nr = PTR_ERR(p);
 	}
+
+out_free:
+	kfree(target_pids);
+
 	return nr;
 }
 
-- 
1.5.2.5
