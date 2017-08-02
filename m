From: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH_v4.1_2/3] Limit dump_pipe program's permission to init for
	container
Date: Wed, 2 Aug 2017 14:37:28 +0800
Message-ID: <1501655849-9149-3-git-send-email-caosf.fnst__13033.4426103675$1501656489$gmane$org@cn.fujitsu.com>
References: <1501655849-9149-1-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1501655849-9149-1-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
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

Signed-off-by: Cao ShuFeng<caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/coredump.c           | 126 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/binfmts.h |   2 +
 2 files changed, 126 insertions(+), 2 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 802f434..745c757 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -507,6 +507,45 @@ static void wait_for_dump_helpers(struct file *file)
 }
 
 /*
+ * umh_ns_setup
+ * set the namesapces to the bask task of a container.
+ * we need to switch back to the original namespaces
+ * so that the thread of workqueue is not influlenced.
+ *
+ * this method runs in workqueue kernel thread.
+ */
+static void umh_ns_setup(struct subprocess_info *info)
+{
+	struct coredump_params *cp = (struct coredump_params *)info->data;
+	struct task_struct *base_task = cp->base_task;
+
+	if (base_task) {
+		cp->current_task_nsproxy = current->nsproxy;
+		//prevent current namespace from being freed
+		get_nsproxy(current->nsproxy);
+		/* Set namespaces to base_task */
+		get_nsproxy(base_task->nsproxy);
+		switch_task_namespaces(current, base_task->nsproxy);
+	}
+}
+
+/*
+ * umh_ns_cleanup
+ * cleanup what we have done in umh_ns_setup.
+ *
+ * this method runs in workqueue kernel thread.
+ */
+static void umh_ns_cleanup(struct subprocess_info *info)
+{
+	struct coredump_params *cp = (struct coredump_params *)info->data;
+	struct nsproxy *current_task_nsproxy = cp->current_task_nsproxy;
+	if (current_task_nsproxy) {
+		/* switch workqueue's original namespace back */
+		switch_task_namespaces(current, current_task_nsproxy);
+	}
+}
+
+/*
  * umh_pipe_setup
  * helper function to customize the process used
  * to collect the core in userspace.  Specifically
@@ -521,6 +560,8 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 {
 	struct file *files[2];
 	struct coredump_params *cp = (struct coredump_params *)info->data;
+	struct task_struct *base_task;
+
 	int err = create_pipe_files(files, 0);
 	if (err)
 		return err;
@@ -529,10 +570,76 @@ static int umh_pipe_setup(struct subprocess_info *info, struct cred *new)
 
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
+		set_fs_pwd(current->fs, &base_task->fs->pwd);
+		spin_unlock(&base_task->fs->lock);
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
@@ -595,6 +702,7 @@ void do_coredump(const siginfo_t *siginfo)
 
 	if (ispipe) {
 		int dump_count;
+                struct task_struct *vinit_task;
 		char **helper_argv;
 		struct subprocess_info *sub_info;
 
@@ -636,6 +744,15 @@ void do_coredump(const siginfo_t *siginfo)
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
+
 		helper_argv = argv_split(GFP_KERNEL, cn.corename, NULL);
 		if (!helper_argv) {
 			printk(KERN_WARNING "%s failed to allocate memory\n",
@@ -643,15 +760,20 @@ void do_coredump(const siginfo_t *siginfo)
 			goto fail_dropcount;
 		}
 
+		get_task_struct(vinit_task);
+
+		cprm.base_task = vinit_task;
+
 		retval = -ENOMEM;
 		sub_info = call_usermodehelper_setup(helper_argv[0],
 						helper_argv, NULL, GFP_KERNEL,
-						NULL, NULL, umh_pipe_setup,
+						umh_ns_setup, umh_ns_cleanup, umh_pipe_setup,
 						NULL, &cprm);
 		if (sub_info)
 			retval = call_usermodehelper_exec(sub_info,
 							  UMH_WAIT_EXEC);
 
+		put_task_struct(vinit_task);
 		argv_free(helper_argv);
 		if (retval) {
 			printk(KERN_INFO "Core dump to |%s pipe failed\n",
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 05488da..fa13104 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -61,6 +61,8 @@ struct linux_binprm {
 
 /* Function parameter for binfmt->coredump */
 struct coredump_params {
+        struct task_struct *base_task;
+        struct nsproxy *current_task_nsproxy;
 	const siginfo_t *siginfo;
 	struct pt_regs *regs;
 	struct file *file;
-- 
2.9.3
