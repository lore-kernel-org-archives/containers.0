From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/3] [RFC] Make dump_pipe thread possilbe to select the rootfs
Date: Fri, 15 Apr 2016 18:47:12 +0800
Message-ID: <74c6e102f0931044889bb12c1b096edf695052c8.1460716337.git.zhaolei@cn.fujitsu.com>
References: <cover.1460716336.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1460716336.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

To make the dump_pipe thread run in container's filesystem, we need to
make it possible to select its fs_root from fork.

Then the dump_pipe thread will exec user_defined pipe program in
container's fs_root, and the problem will also write dumpdata into
the same fs_root.

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c               |  3 ++-
 fs/fs_struct.c              | 25 ++++++++++++++++---------
 include/linux/fs_struct.h   |  3 ++-
 include/linux/kmod.h        |  4 +++-
 include/linux/sched.h       |  5 +++--
 init/do_mounts_initrd.c     |  3 ++-
 init/main.c                 |  4 ++--
 kernel/fork.c               | 34 ++++++++++++++++++++--------------
 kernel/kmod.c               | 13 ++++++++-----
 kernel/kthread.c            |  3 ++-
 lib/kobject_uevent.c        |  3 ++-
 security/keys/request_key.c |  2 +-
 12 files changed, 63 insertions(+), 39 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 47c32c3..9fc74fb 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -639,7 +639,8 @@ void do_coredump(const siginfo_t *siginfo)
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
-						umh_pipe_setup, NULL, &cprm);
+						umh_pipe_setup, NULL, &cprm,
+						NULL);
 		if (sub_info)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 7dca743..0ff30ad 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -107,7 +107,8 @@ void exit_fs(struct task_struct *tsk)
 	}
 }
 
-struct fs_struct *copy_fs_struct(struct fs_struct *old)
+struct fs_struct *copy_fs_struct(struct fs_struct *old,
+				 struct path *root_override)
 {
 	struct fs_struct *fs = kmem_cache_alloc(fs_cachep, GFP_KERNEL);
 	/* We don't need to lock fs - think why ;-) */
@@ -117,13 +118,19 @@ struct fs_struct *copy_fs_struct(struct fs_struct *old)
 		spin_lock_init(&fs->lock);
 		seqcount_init(&fs->seq);
 		fs->umask = old->umask;
-
-		spin_lock(&old->lock);
-		fs->root = old->root;
-		path_get(&fs->root);
-		fs->pwd = old->pwd;
-		path_get(&fs->pwd);
-		spin_unlock(&old->lock);
+		if (root_override) {
+			fs->root = *root_override;
+			path_get(&fs->root);
+			fs->pwd = *root_override;
+			path_get(&fs->pwd);
+		} else {
+			spin_lock(&old->lock);
+			fs->root = old->root;
+			path_get(&fs->root);
+			fs->pwd = old->pwd;
+			path_get(&fs->pwd);
+			spin_unlock(&old->lock);
+		}
 	}
 	return fs;
 }
@@ -131,7 +138,7 @@ struct fs_struct *copy_fs_struct(struct fs_struct *old)
 int unshare_fs_struct(void)
 {
 	struct fs_struct *fs = current->fs;
-	struct fs_struct *new_fs = copy_fs_struct(fs);
+	struct fs_struct *new_fs = copy_fs_struct(fs, NULL);
 	int kill;
 
 	if (!new_fs)
diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
index 0efc3e6..7274b29 100644
--- a/include/linux/fs_struct.h
+++ b/include/linux/fs_struct.h
@@ -19,7 +19,8 @@ extern struct kmem_cache *fs_cachep;
 extern void exit_fs(struct task_struct *);
 extern void set_fs_root(struct fs_struct *, const struct path *);
 extern void set_fs_pwd(struct fs_struct *, const struct path *);
-extern struct fs_struct *copy_fs_struct(struct fs_struct *);
+extern struct fs_struct *copy_fs_struct(struct fs_struct *,
+					struct path *root_override);
 extern void free_fs_struct(struct fs_struct *);
 extern int unshare_fs_struct(void);
 
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index fcfd2bf..73f5265 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -56,6 +56,7 @@ struct file;
 struct subprocess_info {
 	struct work_struct work;
 	struct completion *complete;
+	struct path *root_override;
 	char *path;
 	char **argv;
 	char **envp;
@@ -72,7 +73,8 @@ call_usermodehelper(char *path, char **argv, char **envp, int wait);
 extern struct subprocess_info *
 call_usermodehelper_setup(char *path, char **argv, char **envp, gfp_t gfp_mask,
 			  int (*init)(struct subprocess_info *info, struct cred *new),
-			  void (*cleanup)(struct subprocess_info *), void *data);
+			  void (*cleanup)(struct subprocess_info *), void *data,
+			  struct path *root_override);
 
 extern int
 call_usermodehelper_exec(struct subprocess_info *info, int wait);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 52c4847..3f942c6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -135,6 +135,7 @@ struct perf_event_context;
 struct blk_plug;
 struct filename;
 struct nameidata;
+struct path;
 
 #define VMACACHE_BITS 2
 #define VMACACHE_SIZE (1U << VMACACHE_BITS)
@@ -2663,10 +2664,10 @@ extern int do_execveat(int, struct filename *,
 		       const char __user * const __user *,
 		       const char __user * const __user *,
 		       int);
-extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
+extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long, struct path *);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
-extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
+extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags, struct path *);
 
 extern void __set_task_comm(struct task_struct *tsk, const char *from, bool exec);
 static inline void set_task_comm(struct task_struct *tsk, const char *from)
diff --git a/init/do_mounts_initrd.c b/init/do_mounts_initrd.c
index a1000ca..b401b22 100644
--- a/init/do_mounts_initrd.c
+++ b/init/do_mounts_initrd.c
@@ -72,7 +72,8 @@ static void __init handle_initrd(void)
 	current->flags |= PF_FREEZER_SKIP;
 
 	info = call_usermodehelper_setup("/linuxrc", argv, envp_init,
-					 GFP_KERNEL, init_linuxrc, NULL, NULL);
+					 GFP_KERNEL, init_linuxrc, NULL, NULL,
+					 NULL);
 	if (!info)
 		return;
 	call_usermodehelper_exec(info, UMH_WAIT_PROC);
diff --git a/init/main.c b/init/main.c
index b3c6e36..1a67522 100644
--- a/init/main.c
+++ b/init/main.c
@@ -390,9 +390,9 @@ static noinline void __init_refok rest_init(void)
 	 * the init task will end up wanting to create kthreads, which, if
 	 * we schedule it before we create kthreadd, will OOPS.
 	 */
-	kernel_thread(kernel_init, NULL, CLONE_FS);
+	kernel_thread(kernel_init, NULL, CLONE_FS, NULL);
 	numa_default_policy();
-	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES);
+	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES, NULL);
 	rcu_read_lock();
 	kthreadd_task = find_task_by_pid_ns(pid, &init_pid_ns);
 	rcu_read_unlock();
diff --git a/kernel/fork.c b/kernel/fork.c
index d277e83..ca3c1ee 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1001,7 +1001,8 @@ fail_nomem:
 	return retval;
 }
 
-static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
+static int copy_fs(unsigned long clone_flags, struct task_struct *tsk,
+		   struct path *root_override)
 {
 	struct fs_struct *fs = current->fs;
 	if (clone_flags & CLONE_FS) {
@@ -1015,7 +1016,7 @@ static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
 		spin_unlock(&fs->lock);
 		return 0;
 	}
-	tsk->fs = copy_fs_struct(fs);
+	tsk->fs = copy_fs_struct(fs, root_override);
 	if (!tsk->fs)
 		return -ENOMEM;
 	return 0;
@@ -1256,7 +1257,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 					int __user *child_tidptr,
 					struct pid *pid,
 					int trace,
-					unsigned long tls)
+					unsigned long tls,
+					struct path *root_override)
 {
 	int retval;
 	struct task_struct *p;
@@ -1444,7 +1446,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	retval = copy_files(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_semundo;
-	retval = copy_fs(clone_flags, p);
+	retval = copy_fs(clone_flags, p, root_override);
 	if (retval)
 		goto bad_fork_cleanup_files;
 	retval = copy_sighand(clone_flags, p);
@@ -1684,7 +1686,8 @@ static inline void init_idle_pids(struct pid_link *links)
 struct task_struct *fork_idle(int cpu)
 {
 	struct task_struct *task;
-	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0);
+	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0,
+			    NULL);
 	if (!IS_ERR(task)) {
 		init_idle_pids(task->pids);
 		init_idle(task, cpu);
@@ -1704,7 +1707,8 @@ long _do_fork(unsigned long clone_flags,
 	      unsigned long stack_size,
 	      int __user *parent_tidptr,
 	      int __user *child_tidptr,
-	      unsigned long tls)
+	      unsigned long tls,
+	      struct path *root_override)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -1729,7 +1733,7 @@ long _do_fork(unsigned long clone_flags,
 	}
 
 	p = copy_process(clone_flags, stack_start, stack_size,
-			 child_tidptr, NULL, trace, tls);
+			 child_tidptr, NULL, trace, tls, root_override);
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
 	 * might get invalid after that point, if the thread exits quickly.
@@ -1780,24 +1784,25 @@ long do_fork(unsigned long clone_flags,
 	      int __user *child_tidptr)
 {
 	return _do_fork(clone_flags, stack_start, stack_size,
-			parent_tidptr, child_tidptr, 0);
+			parent_tidptr, child_tidptr, 0, NULL);
 }
 #endif
 
 /*
  * Create a kernel thread.
  */
-pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
+pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags,
+		    struct path *root_override)
 {
 	return _do_fork(flags|CLONE_VM|CLONE_UNTRACED, (unsigned long)fn,
-		(unsigned long)arg, NULL, NULL, 0);
+		(unsigned long)arg, NULL, NULL, 0, root_override);
 }
 
 #ifdef __ARCH_WANT_SYS_FORK
 SYSCALL_DEFINE0(fork)
 {
 #ifdef CONFIG_MMU
-	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0);
+	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, NULL);
 #else
 	/* can not support in nommu mode */
 	return -EINVAL;
@@ -1809,7 +1814,7 @@ SYSCALL_DEFINE0(fork)
 SYSCALL_DEFINE0(vfork)
 {
 	return _do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, 0,
-			0, NULL, NULL, 0);
+			0, NULL, NULL, 0, NULL);
 }
 #endif
 
@@ -1837,7 +1842,8 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
 		 unsigned long, tls)
 #endif
 {
-	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls);
+	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr,
+			tls, NULL);
 }
 #endif
 
@@ -1933,7 +1939,7 @@ static int unshare_fs(unsigned long unshare_flags, struct fs_struct **new_fsp)
 	if (fs->users == 1)
 		return 0;
 
-	*new_fsp = copy_fs_struct(fs);
+	*new_fsp = copy_fs_struct(fs, NULL);
 	if (!*new_fsp)
 		return -ENOMEM;
 
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 0277d12..0d7f9e0 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -91,7 +91,7 @@ static int call_modprobe(char *module_name, int wait)
 	argv[4] = NULL;
 
 	info = call_usermodehelper_setup(modprobe_path, argv, envp, GFP_KERNEL,
-					 NULL, free_modprobe_argv, NULL);
+					 NULL, free_modprobe_argv, NULL, NULL);
 	if (!info)
 		goto free_module_name;
 
@@ -272,7 +272,8 @@ static void call_usermodehelper_exec_sync(struct subprocess_info *sub_info)
 
 	/* If SIGCLD is ignored sys_wait4 won't populate the status. */
 	kernel_sigaction(SIGCHLD, SIG_DFL);
-	pid = kernel_thread(call_usermodehelper_exec_async, sub_info, SIGCHLD);
+	pid = kernel_thread(call_usermodehelper_exec_async, sub_info, SIGCHLD,
+			    sub_info->root_override);
 	if (pid < 0) {
 		sub_info->retval = pid;
 	} else {
@@ -333,7 +334,8 @@ static void call_usermodehelper_exec_work(struct work_struct *work)
 		 * that always ignores SIGCHLD to ensure auto-reaping.
 		 */
 		pid = kernel_thread(call_usermodehelper_exec_async, sub_info,
-				    CLONE_PARENT | SIGCHLD);
+				    CLONE_PARENT | SIGCHLD,
+				    sub_info->root_override);
 		if (pid < 0) {
 			sub_info->retval = pid;
 			umh_complete(sub_info);
@@ -520,7 +522,7 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 		char **envp, gfp_t gfp_mask,
 		int (*init)(struct subprocess_info *info, struct cred *new),
 		void (*cleanup)(struct subprocess_info *info),
-		void *data)
+		void *data, struct path *root_override)
 {
 	struct subprocess_info *sub_info;
 	sub_info = kzalloc(sizeof(struct subprocess_info), gfp_mask);
@@ -528,6 +530,7 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 		goto out;
 
 	INIT_WORK(&sub_info->work, call_usermodehelper_exec_work);
+	sub_info->root_override = root_override;
 	sub_info->path = path;
 	sub_info->argv = argv;
 	sub_info->envp = envp;
@@ -619,7 +622,7 @@ int call_usermodehelper(char *path, char **argv, char **envp, int wait)
 	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
 
 	info = call_usermodehelper_setup(path, argv, envp, gfp_mask,
-					 NULL, NULL, NULL);
+					 NULL, NULL, NULL, NULL);
 	if (info == NULL)
 		return -ENOMEM;
 
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 9ff173d..cc3b143 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -230,7 +230,8 @@ static void create_kthread(struct kthread_create_info *create)
 	current->pref_node_fork = create->node;
 #endif
 	/* We want our own signal handler (we take no signals by default). */
-	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD);
+	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD,
+			    NULL);
 	if (pid < 0) {
 		/* If user was SIGKILLed, I release the structure. */
 		struct completion *done = xchg(&create->done, NULL);
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index f6c2c1e..490d268 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -345,7 +345,8 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 		retval = -ENOMEM;
 		info = call_usermodehelper_setup(env->argv[0], env->argv,
 						 env->envp, GFP_KERNEL,
-						 NULL, cleanup_uevent_env, env);
+						 NULL, cleanup_uevent_env, env,
+						 NULL);
 		if (info) {
 			retval = call_usermodehelper_exec(info, UMH_NO_WAIT);
 			env = NULL;	/* freed by cleanup_uevent_env */
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index c7a117c..b0e0a6e 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -79,7 +79,7 @@ static int call_usermodehelper_keys(char *path, char **argv, char **envp,
 
 	info = call_usermodehelper_setup(path, argv, envp, GFP_KERNEL,
 					  umh_keys_init, umh_keys_cleanup,
-					  session_keyring);
+					  session_keyring, NULL);
 	if (!info)
 		return -ENOMEM;
 
-- 
1.8.5.1
