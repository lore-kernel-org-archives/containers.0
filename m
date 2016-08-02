From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 1/2] Limit dump_pipe program's permission to init for
	container
Date: Tue, 2 Aug 2016 17:08:32 +0800
Message-ID: <c7d8e45aa76a414c73082d22d325cd5a13979773.1470128572.git.zhaolei@cn.fujitsu.com>
References: <cover.1470128571.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1470128571.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

Currently when we set core_pattern to a pipe, the pipe program is
forked by kthread running with root's permission, and write dumpfile
into host's filesystem.
Same thing happened for container, the dumper and dumpfile are also
in host(not in container).

It have following program:
1: Not consistent with file_type core_pattern
   When we set core_pattern to a file, the container will write dump
   into container's filesystem instead of host.
2: Not safe for privileged container
   In a privileged container, user can destroy host system by following
   command:
   # # In a container
   # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
   # make_dump

This patch switch dumper program's environment to init task, so, for
container, dumper program have same environment with init task in
container, which make dumper program put in container's filesystem, and
write coredump into container's filesystem.
The dumper's permission is also limited into subset of container's init
process.

Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c           | 87 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/binfmts.h |  1 +
 2 files changed, 87 insertions(+), 1 deletion(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 281b768..8511267 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -516,6 +516,8 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 {
 	struct file *files[2];
 	struct coredump_params *cp = (struct coredump_params *)info->data;
+	struct task_struct *base_task;
+
 	int err = create_pipe_files(files, 0);
 	if (err)
 		return err;
@@ -524,10 +526,79 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 
 	err = replace_fd(0, files[0], 0);
 	fput(files[0]);
+	if (err)
+		return err;
+
 	/* and disallow core files too */
 	current->signal->rlim[RLIMIT_CORE] = (struct rlimit){1, 1};
 
-	return err;
+	base_task = cp->base_task;
+	if (base_task) {
+		const struct cred *base_cred;
+
+		/* Set fs_root to base_task */
+		spin_lock(&base_task->fs->lock);
+		set_fs_root(current->fs, &base_task->fs->root);
+		spin_unlock(&base_task->fs->lock);
+
+		/* Set namespaces to base_task */
+		get_nsproxy(base_task->nsproxy);
+		switch_task_namespaces(current, base_task->nsproxy);
+
+		/* Set cgroup to base_task */
+		current->flags &= ~PF_NO_SETAFFINITY;
+		err = cgroup_attach_task_all(base_task, current);
+		if (err < 0)
+			return err;
+
+		/* Set cred to base_task */
+		base_cred = get_task_cred(base_task);
+
+		new->uid   = base_cred->uid;
+		new->gid   = base_cred->gid;
+		new->suid  = base_cred->suid;
+		new->sgid  = base_cred->sgid;
+		new->euid  = base_cred->euid;
+		new->egid  = base_cred->egid;
+		new->fsuid = base_cred->fsuid;
+		new->fsgid = base_cred->fsgid;
+
+		new->securebits = base_cred->securebits;
+
+		new->cap_inheritable = base_cred->cap_inheritable;
+		new->cap_permitted   = base_cred->cap_permitted;
+		new->cap_effective   = base_cred->cap_effective;
+		new->cap_bset        = base_cred->cap_bset;
+		new->cap_ambient     = base_cred->cap_ambient;
+
+		security_cred_free(new);
+#ifdef CONFIG_SECURITY
+		new->security = NULL;
+#endif
+		err = security_prepare_creds(new, base_cred, GFP_KERNEL);
+		if (err < 0) {
+			put_cred(base_cred);
+			return err;
+		}
+
+		free_uid(new->user);
+		new->user = base_cred->user;
+		get_uid(new->user);
+
+		put_user_ns(new->user_ns);
+		new->user_ns = base_cred->user_ns;
+		get_user_ns(new->user_ns);
+
+		put_group_info(new->group_info);
+		new->group_info = base_cred->group_info;
+		get_group_info(new->group_info);
+
+		put_cred(base_cred);
+
+		validate_creds(new);
+	}
+
+	return 0;
 }
 
 void do_coredump(const siginfo_t *siginfo)
@@ -590,6 +661,7 @@ void do_coredump(const siginfo_t *siginfo)
 
 	if (ispipe) {
 		int dump_count;
+		struct task_struct *vinit_task;
 		char **helper_argv;
 		struct subprocess_info *sub_info;
 
@@ -631,6 +703,14 @@ void do_coredump(const siginfo_t *siginfo)
 			goto fail_dropcount;
 		}
 
+		rcu_read_lock();
+		vinit_task = find_task_by_vpid(1);
+		rcu_read_unlock();
+		if (!vinit_task) {
+			printk(KERN_WARNING "failed getting init task info, skipping core dump\n");
+			goto fail_dropcount;
+		}
+
 		helper_argv = argv_split(GFP_KERNEL, cn.corename, NULL);
 		if (!helper_argv) {
 			printk(KERN_WARNING "%s failed to allocate memory\n",
@@ -638,6 +718,10 @@ void do_coredump(const siginfo_t *siginfo)
 			goto fail_dropcount;
 		}
 
+		get_task_struct(vinit_task);
+
+		cprm.base_task = vinit_task;
+
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
@@ -646,6 +730,7 @@ void do_coredump(const siginfo_t *siginfo)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
 
+		put_task_struct(vinit_task);
 		argv_free(helper_argv);
 		if (retval) {
 			printk(KERN_INFO "Core dump to |%s pipe failed\n",
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 314b3ca..0c9a72c 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -59,6 +59,7 @@ struct linux_binprm {
 
 /* Function parameter for binfmt->coredump */
 struct coredump_params {
+	struct task_struct *base_task;
 	const siginfo_t *siginfo;
 	struct pt_regs *regs;
 	struct file *file;
-- 
1.8.5.1
