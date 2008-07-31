From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Thu, 31 Jul 2008 13:32:13 -0500
Message-ID: <20080731183213.GA12033@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Pavel,

Here is the 'hijack' patch that was mentioned during the namespaces
part of the containers mini-summit.  It's a proposed way of entering
namespaces.

It's been rotting for awhile as you can see by the changelog, but
hopefully I updated it sufficiently and correctly.

-serge

From 9a7e1c11cd96435d0d27d28e4508f887d6dbf7ed Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 10 Jul 2008 11:51:38 -0500
Subject: [PATCH 1/1] namespaces: introduce sys_hijack (v11)

Move most of do_fork() into a new do_fork_task() which acts on
a new argument, cgroup, rather than on current.  The original
process actually forks and if passed a non-NULL cgroup then
the new process's cgroup and namespaces are taken from the
target cgroup specified.  If passed a NULL cgroup, fork
behaves exactly as before, thus do_fork() becomes a call to
do_fork_task(NULL, ...).

Introduce sys_hijack (for i386 and s390 only so far).  An open
fd for a cgroup 'tasks' file is specified.  The main purpose
is to allow entering an empty cgroup without having to keep a
task alive in the target cgroup.  Only the cgroup and nsproxy
are copied from the cgroup.  Security, user, and rootfs info
is not retained in the cgroups and so cannot be copied to the
child task.

In order to hijack a cgroup, you must have CAP_SYS_ADMIN and
be entering a decendent of your current cgroup.

The effect is a sort of namespace enter.  The following program
uses sys_hijack to 'enter' all namespaces of the specified
cgroup. For instance in one terminal, do

	mount -t cgroup -ons cgroup /cgroup
	hostname
	  qemu
	ns_exec -u /bin/sh
	  hostname serge
          echo $$
            2996
	  cat /proc/$$/cgroup
	    ns:/node_2996

In another terminal then do

	hostname
	  qemu
	cat /proc/$$/cgroup
	  ns:/
	hijack /cgroup/node_2996/tasks
	  hostname
	    serge
	  cat /proc/$$/cgroup
	    ns:/node_2996

Changelog:
  Jul 31 2008:  Put fs_struct in ns_cgroup, and hijack it in
  		addition to the nsproxy.
  Jul 10 2008:  Port to recent -mm (cope with cgroup changes)
  Aug 23 2007:	send a stop signal to the hijacked process
		(like ptrace does).
  Oct 09 2007:	Update for 2.6.23-rc8-mm2 (mainly pidns)
		Don't take task_lock under rcu_read_lock
		Send hijacked process to cgroup_fork() as
		the first argument.
		Removed some unneeded task_locks.
  Oct 16 2007:	Fix bug introduced into alloc_pid.
  Oct 16 2007:	Add 'int which' argument to sys_hijack to
		allow later expansion to use cgroup in place
		of pid to specify what to hijack.
  Oct 24 2007:	Implement hijack by open cgroup file.
  Nov 02 2007:	Switch copying of task info: do full copy
		from current, then copy relevant pieces from
		hijacked task.
  Nov 06 2007:	Verbatim task_struct copy now comes from current,
		after which copy_hijackable_taskinfo() copies
		relevant context pieces from the hijack source.
  Nov 07 2007:	Move arch-independent hijack code to kernel/fork.c
  Nov 07 2007:	powerpc and x86_64 support (Mark Nelson)
  Nov 07 2007:	Don't allow hijacking members of same session.
  Nov 07 2007:	introduce cgroup_may_hijack, and may_hijack hook to
		cgroup subsystems.  The ns subsystem uses this to
		enforce the rule that one may only hijack descendent
		namespaces.
  Nov 07 2007:	s390 support
  Nov 08 2007:	don't send SIGSTOP to hijack source task
  Nov 10 2007:	cache reference to nsproxy in ns cgroup for use in

		hijacking an empty cgroup.
  Nov 10 2007:	allow partial hijack of empty cgroup
  Nov 13 2007:	don't double-get cgroup for hijack_ns
		find_css_set() actually returns the set with a
		reference already held, so cgroup_fork_fromcgroup()
		by doing a get_css_set() was getting a second
		reference.  Therefore after exiting the hijack
		task we could not rmdir the csgroup.
  Nov 22 2007:	temporarily remove x86_64 and powerpc support
  Nov 27 2007:	rebased on 2.6.24-rc3
  Jan 09 2008:	removed hijack pid and hijack cgroup options
  Jan 11 2008:	renamed cgroup_fork_fromcgroup() to be
		cgroup_fork_into_cgroup()

==============================================================
hijack.c
==============================================================
 #include <stdio.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <signal.h>
 #include <sys/wait.h>
 #include <stdlib.h>
 #include <unistd.h>

 #define __NR_hijack 333

/*
 *	hijack /cgroup/node_1078/tasks
 */

void usage(char *me)
{
	printf("Usage: %s <cgroup_tasks_file>\n", me);
	exit(1);
}

int exec_shell(void)
{
	execl("/bin/sh", "/bin/sh", NULL);
}

int main(int argc, char *argv[])
{
	int id;
	int ret;
	int status;

	if (argc < 2 || !strcmp(argv[1], "-h"))
		usage(argv[0]);

	id = open(argv[1], O_RDONLY);
	if (id == -1) {
		perror("cgroup open");
		return 1;
	}

	ret = syscall(__NR_hijack, SIGCHLD, (unsigned long)id);

	if  (ret == 0) {
		return exec_shell();
	} else if (ret < 0) {
		perror("sys_hijack");
	} else {
		printf("waiting on cloned process %d\n", ret);
		while(waitpid(-1, &status, __WALL) != -1)
				;
		printf("cloned process exited with %d (waitpid ret %d)\n",
				status, ret);
	}

	return ret;
}
==============================================================

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
---
 Documentation/cgroups.txt          |    8 +++
 arch/s390/kernel/process.c         |   10 +++
 arch/x86/kernel/process_32.c       |   10 +++
 arch/x86/kernel/syscall_table_32.S |    1 +
 include/asm-x86/unistd_32.h        |    1 +
 include/linux/cgroup.h             |   12 ++++
 include/linux/nsproxy.h            |   13 ++++-
 include/linux/sched.h              |    3 +
 include/linux/syscalls.h           |    2 +
 kernel/cgroup.c                    |   32 +++++++++++
 kernel/fork.c                      |   59 +++++++++++++++++---
 kernel/ns_cgroup.c                 |  108 +++++++++++++++++++++++++++++++++++-
 kernel/nsproxy.c                   |    2 +-
 13 files changed, 248 insertions(+), 13 deletions(-)

diff --git a/Documentation/cgroups.txt b/Documentation/cgroups.txt
index d9014aa..b7ba41e 100644
--- a/Documentation/cgroups.txt
+++ b/Documentation/cgroups.txt
@@ -502,6 +502,14 @@ void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
 
+int may_hijack(struct cgroup_subsys *ss, struct cgroup *new_cgroup,
+	       struct task_struct *task)
+
+Called prior to hijacking a cgroup.  Current is cloning a new child
+which is hijacking the cgroup and namespace from the target cgroup.
+Security context is kept from the original (forking) process.
+Return 0 to allow.
+
 void fork(struct cgroup_subsy *ss, struct task_struct *task)
 
 Called when a task is forked into a cgroup.
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 9839767..3b64077 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -278,6 +278,16 @@ asmlinkage long sys_clone(void)
 		       parent_tidptr, child_tidptr);
 }
 
+asmlinkage long sys_hijack(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	unsigned long sp = regs->orig_gpr2;
+	unsigned long clone_flags = regs->gprs[3];
+	unsigned int fd = regs->gprs[4];
+
+	return hijack_ns(fd, clone_flags, *regs, sp);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 53bc653..4711eed 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -36,6 +36,7 @@
 #include <linux/personality.h>
 #include <linux/tick.h>
 #include <linux/percpu.h>
+#include <linux/cgroup.h>
 #include <linux/prctl.h>
 
 #include <asm/uaccess.h>
@@ -648,6 +649,15 @@ asmlinkage int sys_clone(struct pt_regs regs)
 	return do_fork(clone_flags, newsp, &regs, 0, parent_tidptr, child_tidptr);
 }
 
+asmlinkage int sys_hijack(struct pt_regs regs)
+{
+	unsigned long sp = regs.sp;
+	unsigned long clone_flags = regs.bx;
+	unsigned int fd = regs.cx;
+
+	return hijack_ns(fd, clone_flags, regs, sp);
+}
+
 /*
  * This is trivial, and on the face of it looks like it
  * could equally well be done in user mode.
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d44395f..fd9d4f4 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -332,3 +332,4 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+	.long sys_hijack
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index d739467..70280da 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -338,6 +338,7 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_hijack		333
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c98dd7c..ca6a439 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -30,6 +30,8 @@ extern void cgroup_lock(void);
 extern bool cgroup_lock_live_group(struct cgroup *cgrp);
 extern void cgroup_unlock(void);
 extern void cgroup_fork(struct task_struct *p);
+extern void cgroup_fork_into_cgroup(struct cgroup *new_cg,
+					struct task_struct *child);
 extern void cgroup_fork_callbacks(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
@@ -313,6 +315,8 @@ struct cgroup_subsys {
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss,
 			  struct cgroup *cgrp, struct task_struct *tsk);
+	int (*may_hijack)(struct cgroup_subsys *ss,
+			  struct cgroup *cont, struct task_struct *tsk);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *tsk);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
@@ -393,12 +397,19 @@ void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
+struct cgroup *cgroup_from_fd(unsigned int fd);
 #else /* !CONFIG_CGROUPS */
+struct cgroup {
+};
 
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 static inline void cgroup_init_smp(void) {}
 static inline void cgroup_fork(struct task_struct *p) {}
+
+static inline void cgroup_fork_into_cgroup(struct cgroup *new_cg,
+					struct task_struct *child) {}
+
 static inline void cgroup_fork_callbacks(struct task_struct *p) {}
 static inline void cgroup_post_fork(struct task_struct *p) {}
 static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
@@ -411,6 +422,7 @@ static inline int cgroupstats_build(struct cgroupstats *stats,
 	return -EINVAL;
 }
 
+static inline struct cgroup *cgroup_from_fd(unsigned int fd) { return NULL; }
 #endif /* !CONFIG_CGROUPS */
 
 #ifdef CONFIG_MM_OWNER
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index c8a768e..d5d6def 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -3,6 +3,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/sched.h>
+#include <linux/err.h>
 
 struct mnt_namespace;
 struct uts_namespace;
@@ -81,13 +82,21 @@ static inline void get_nsproxy(struct nsproxy *ns)
 	atomic_inc(&ns->count);
 }
 
+struct cgroup;
 #ifdef CONFIG_CGROUP_NS
-int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid);
+int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid,
+			struct nsproxy *nsproxy);
+int ns_cgroup_verify(struct cgroup *cgroup);
+void copy_hijack_nsproxy(struct task_struct *tsk, struct cgroup *cgroup);
 #else
-static inline int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid)
+static inline int ns_cgroup_clone(struct task_struct *tsk, struct pid *pid,
+	struct nsproxy *nsproxy)
 {
 	return 0;
 }
+static inline int ns_cgroup_verify(struct cgroup *cgroup) { return 0; }
+static inline void copy_hijack_nsproxy(struct task_struct *tsk,
+				       struct cgroup *cgroup) {}
 #endif
 
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5270d44..f12c891 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1871,6 +1871,9 @@ extern int do_execve(char *, char __user * __user *, char __user * __user *, str
 extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
 
+extern int hijack_ns(unsigned int fd, unsigned long clone_flags,
+		struct pt_regs regs, unsigned long sp);
+
 extern void set_task_comm(struct task_struct *tsk, char *from);
 extern char *get_task_comm(char *to, struct task_struct *tsk);
 
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index d6ff145..8a031c8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -625,4 +625,6 @@ asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
+asmlinkage long sys_hijack(unsigned long flags, unsigned long fd);
+
 #endif
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 13932ab..7108626 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -46,6 +46,7 @@
 #include <linux/cgroupstats.h>
 #include <linux/hash.h>
 #include <linux/namei.h>
+#include <linux/file.h>
 
 #include <asm/atomic.h>
 
@@ -2707,6 +2708,14 @@ void cgroup_fork(struct task_struct *child)
 	INIT_LIST_HEAD(&child->cg_list);
 }
 
+void cgroup_fork_into_cgroup(struct cgroup *new_cg, struct task_struct *child)
+{
+	mutex_lock(&cgroup_mutex);
+	child->cgroups = find_css_set(child->cgroups, new_cg);
+	INIT_LIST_HEAD(&child->cg_list);
+	mutex_unlock(&cgroup_mutex);
+}
+
 /**
  * cgroup_fork_callbacks - run fork callbacks
  * @child: the new task
@@ -3095,6 +3104,29 @@ static void cgroup_release_agent(struct work_struct *work)
 	mutex_unlock(&cgroup_mutex);
 }
 
+struct cgroup *cgroup_from_fd(unsigned int fd)
+{
+	struct file *file;
+	struct cgroup *cgroup = NULL;;
+
+	file = fget(fd);
+	if (!file)
+		return NULL;
+
+	if (!file->f_dentry || !file->f_dentry->d_sb)
+		goto out_fput;
+	if (file->f_dentry->d_parent->d_sb->s_magic != CGROUP_SUPER_MAGIC)
+		goto out_fput;
+	if (strcmp(file->f_dentry->d_name.name, "tasks"))
+		goto out_fput;
+
+	cgroup = __d_cgrp(file->f_dentry->d_parent);
+
+out_fput:
+	fput(file);
+	return cgroup;
+}
+
 static int __init cgroup_disable(char *str)
 {
 	int i;
diff --git a/kernel/fork.c b/kernel/fork.c
index 7ce2ebe..52b5037 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -674,11 +674,15 @@ EXPORT_SYMBOL_GPL(copy_fs_struct);
 
 static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
 {
+	if (!tsk->fs) {
+		printk(KERN_NOTICE "%s: tsk didn't have fs\n", __func__);
+		tsk->fs = current->fs;
+	}
 	if (clone_flags & CLONE_FS) {
-		atomic_inc(&current->fs->count);
+		atomic_inc(&tsk->fs->count);
 		return 0;
 	}
-	tsk->fs = __copy_fs_struct(current->fs);
+	tsk->fs = __copy_fs_struct(tsk->fs);
 	if (!tsk->fs)
 		return -ENOMEM;
 	return 0;
@@ -893,7 +897,8 @@ void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
  * parts of the process environment (as per the clone
  * flags). The actual kick-off is left to the caller.
  */
-static struct task_struct *copy_process(unsigned long clone_flags,
+static struct task_struct *copy_process(struct cgroup *cgroup,
+					unsigned long clone_flags,
 					unsigned long stack_start,
 					struct pt_regs *regs,
 					unsigned long stack_size,
@@ -931,6 +936,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p = dup_task_struct(current);
 	if (!p)
 		goto fork_out;
+	if (cgroup)
+		copy_hijack_nsproxy(p, cgroup);
 
 	rt_mutex_init_task(p);
 
@@ -1012,7 +1019,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->cap_bset = current->cap_bset;
 	p->io_context = NULL;
 	p->audit_context = NULL;
-	cgroup_fork(p);
+	if (cgroup)
+		cgroup_fork_into_cgroup(cgroup, p);
+	else
+		cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
@@ -1100,7 +1110,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		p->tgid = current->tgid;
 
 	if (current->nsproxy != p->nsproxy) {
-		retval = ns_cgroup_clone(p, pid);
+		retval = ns_cgroup_clone(p, pid, p->nsproxy);
 		if (retval)
 			goto bad_fork_free_pid;
 	}
@@ -1304,7 +1314,7 @@ struct task_struct * __cpuinit fork_idle(int cpu)
 	struct task_struct *task;
 	struct pt_regs regs;
 
-	task = copy_process(CLONE_VM, 0, idle_regs(&regs), 0, NULL,
+	task = copy_process(NULL, CLONE_VM, 0, idle_regs(&regs), 0, NULL,
 			    &init_struct_pid, 0);
 	if (!IS_ERR(task))
 		init_idle(task, cpu);
@@ -1318,7 +1328,8 @@ struct task_struct * __cpuinit fork_idle(int cpu)
  * It copies the process, and if successful kick-starts
  * it and waits for it to finish using the VM if required.
  */
-long do_fork(unsigned long clone_flags,
+long do_fork_task(struct cgroup *cgroup,
+	      unsigned long clone_flags,
 	      unsigned long stack_start,
 	      struct pt_regs *regs,
 	      unsigned long stack_size,
@@ -1352,7 +1363,7 @@ long do_fork(unsigned long clone_flags,
 	if (likely(user_mode(regs)))
 		trace = tracehook_prepare_clone(clone_flags);
 
-	p = copy_process(clone_flags, stack_start, regs, stack_size,
+	p = copy_process(cgroup, clone_flags, stack_start, regs, stack_size,
 			 child_tidptr, NULL, trace);
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
@@ -1407,6 +1418,38 @@ long do_fork(unsigned long clone_flags,
 	return nr;
 }
 
+/*
+ *  Ok, this is the main fork-routine.
+ *
+ * It copies the process, and if successful kick-starts
+ * it and waits for it to finish using the VM if required.
+ */
+long do_fork(unsigned long clone_flags,
+	      unsigned long stack_start,
+	      struct pt_regs *regs,
+	      unsigned long stack_size,
+	      int __user *parent_tidptr,
+	      int __user *child_tidptr)
+{
+	return do_fork_task(NULL, clone_flags, stack_start,
+		regs, stack_size, parent_tidptr, child_tidptr);
+}
+
+int hijack_ns(unsigned int fd, unsigned long clone_flags,
+		  struct pt_regs regs, unsigned long sp)
+{
+	struct cgroup *cgroup;
+
+	cgroup = cgroup_from_fd(fd);
+	if (!cgroup)
+		return -EINVAL;
+
+	if (!ns_cgroup_verify(cgroup))
+		return -EINVAL;
+
+	return do_fork_task(cgroup, clone_flags, sp, &regs, 0, NULL, NULL);
+}
+
 #ifndef ARCH_MIN_MMSTRUCT_ALIGN
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 43c2111..1ab8699 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -10,9 +10,12 @@
 #include <linux/proc_fs.h>
 #include <linux/slab.h>
 #include <linux/nsproxy.h>
+#include <linux/fs_struct.h>
 
 struct ns_cgroup {
 	struct cgroup_subsys_state css;
+	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
 	spinlock_t lock;
 };
 
@@ -25,12 +28,67 @@ static inline struct ns_cgroup *cgroup_to_ns(
 			    struct ns_cgroup, css);
 }
 
-int ns_cgroup_clone(struct task_struct *task, struct pid *pid)
+int ns_cgroup_clone(struct task_struct *task, struct pid *pid,
+				struct nsproxy *nsproxy)
 {
 	char name[PROC_NUMBUF];
+	struct cgroup *cgroup;
+	struct ns_cgroup *ns_cgroup;
+	int ret;
 
 	snprintf(name, PROC_NUMBUF, "%d", pid_vnr(pid));
-	return cgroup_clone(task, &ns_subsys, name);
+
+	ret = cgroup_clone(task, &ns_subsys, name);
+
+	if (ret)
+		return ret;
+
+	cgroup = task_cgroup(task, ns_subsys_id);
+	ns_cgroup = cgroup_to_ns(cgroup);
+	ns_cgroup->nsproxy = nsproxy;
+	ns_cgroup->fs = task->fs;
+	atomic_inc(&task->fs->count);
+	get_nsproxy(nsproxy);
+
+	return 0;
+}
+
+/*
+ * Verify that the cgroup contains a valid ns_cgroup (which can
+ * be entered), in case a different cgroup fd is passed in, for
+ * example a cpuset cgroup.
+ */
+int ns_cgroup_verify(struct cgroup *cgroup)
+{
+	struct cgroup_subsys_state *css;
+	struct ns_cgroup *ns_cgroup;
+
+	css = cgroup_subsys_state(cgroup, ns_subsys_id);
+	if (!css)
+		return 0;
+	ns_cgroup = container_of(css, struct ns_cgroup, css);
+	if (!ns_cgroup->nsproxy)
+		return 0;
+	return 1;
+}
+
+/*
+ * this shouldn't be called unless ns_cgroup_verify() has
+ * confirmed that there is a ns_cgroup in this cgroup
+ * (which is done in hijack_ns() at the moment)
+ *
+ * tsk is not yet running, and has not yet taken a reference
+ * to it's previous ->nsproxy, so we just do a simple assignment
+ * rather than switch_task_namespaces()
+ * Same with fs
+ */
+void copy_hijack_nsproxy(struct task_struct *tsk, struct cgroup *cgroup)
+{
+	struct ns_cgroup *ns_cgroup;
+
+	ns_cgroup = cgroup_to_ns(cgroup);
+	tsk->nsproxy = ns_cgroup->nsproxy;
+	tsk->fs = ns_cgroup->fs;
 }
 
 /*
@@ -66,6 +124,46 @@ static int ns_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
+static void ns_attach(struct cgroup_subsys *ss,
+			  struct cgroup *cgroup, struct cgroup *oldcgroup,
+			  struct task_struct *tsk)
+{
+	struct ns_cgroup *ns_cgroup = cgroup_to_ns(cgroup);
+
+	if (likely(ns_cgroup->nsproxy))
+		return;
+
+	spin_lock(&ns_cgroup->lock);
+	if (!ns_cgroup->nsproxy) {
+		ns_cgroup->nsproxy = tsk->nsproxy;
+		get_nsproxy(ns_cgroup->nsproxy);
+	}
+	if (!ns_cgroup->fs) {
+		ns_cgroup->fs = tsk->fs;
+		atomic_inc(&ns_cgroup->fs->count);
+	}
+	spin_unlock(&ns_cgroup->lock);
+}
+
+/*
+ * only allow hijacking child namespaces
+ * Q: is it crucial to prevent hijacking a task in your same cgroup?
+ */
+static int ns_may_hijack(struct cgroup_subsys *ss,
+		struct cgroup *new_cgroup, struct task_struct *task)
+{
+	if (current == task)
+		return -EINVAL;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (!cgroup_is_descendant(new_cgroup))
+		return -EPERM;
+
+	return 0;
+}
+
 /*
  * Rules: you can only create a cgroup if
  *     1. you are capable(CAP_SYS_ADMIN)
@@ -94,12 +192,18 @@ static void ns_destroy(struct cgroup_subsys *ss,
 	struct ns_cgroup *ns_cgroup;
 
 	ns_cgroup = cgroup_to_ns(cgroup);
+	if (ns_cgroup->nsproxy)
+		put_nsproxy(ns_cgroup->nsproxy);
+	if (ns_cgroup->fs)
+		put_fs_struct(ns_cgroup->fs);
 	kfree(ns_cgroup);
 }
 
 struct cgroup_subsys ns_subsys = {
 	.name = "ns",
 	.can_attach = ns_can_attach,
+	.attach = ns_attach,
+	.may_hijack = ns_may_hijack,
 	.create = ns_create,
 	.destroy  = ns_destroy,
 	.subsys_id = ns_subsys_id,
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 21575fc..70b8c7f 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -203,7 +203,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 		goto out;
 	}
 
-	err = ns_cgroup_clone(current, task_pid(current));
+	err = ns_cgroup_clone(current, task_pid(current), *new_nsp);
 	if (err)
 		put_nsproxy(*new_nsp);
 
-- 
1.5.3.6
