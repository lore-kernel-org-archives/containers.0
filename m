From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/10] Enabling checkpoint relink of unlinked files inside
	containers
Date: Mon, 28 Feb 2011 20:05:15 -0800
Message-ID: <7c6e1ebb39ca920c0c4c572e1f455250b2fbba4b.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
	<dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
	<ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc@us.ibm.com>
	<24a5e0d9179d6e3c29ec0197a3251963ff2a4dbd.1298952288.git.matthltc@us.ibm.com>
	<3d0a3c702e5986a45676987a4f3a6607d28725e7.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3d0a3c702e5986a45676987a4f3a6607d28725e7.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

When we use relinking to checkpoint unlinked files we're often working
in a different mount namespace than the opened file. This means that
we'll get -EXDEV because the mounts are different and there is no
reasonable way to map between them in different namespaces.

Factor setns() and utilize it to quickly switch namespaces so that
we may relink files in different mount namespaces during checkpoint.

Unlike setns() we already have the mount namespace pointer and know
the proc namespace ops to use -- so we can skip a few steps and call
a factored kern_setns() in both the setns() syscall and from
checkpoint.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c              |   40 +++++++++++++++++++++++++++++++++-------
 include/linux/nsproxy.h |    3 +++
 kernel/nsproxy.c        |   33 +++++++++++++++++++--------------
 3 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index fcf35b3..f6361f8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -33,6 +33,8 @@
 #include <linux/device_cgroup.h>
 #include <linux/fs_struct.h>
 #ifdef CONFIG_CHECKPOINT
+#include <linux/proc_fs.h>
+#include <linux/nsproxy.h>
 #include <linux/sys-wrapper.h>
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
@@ -2623,27 +2625,51 @@ static int checkpoint_file_relink(struct ckpt_ctx *ctx,
 				  struct file *file,
 				  char new_path[PATH_MAX])
 {
+	struct nsproxy *old_nsproxy;
 	int ret, len;
 
 	/* 
 	 * Relinking arbitrary files without searching a path
 	 * (which is non-existent if the file is unlinked) requires
-	 * special privileges.
+	 * special privileges. Also, since we need to set the mount
+	 * namespace we need CAP_SYS_ADMIN (see sys_setns).
 	 */
-	if (!capable(CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH)) {
-		ckpt_err(ctx, -EPERM, "%(T)Relinking unlinked files requires CAP_DAC_{OVERRIDE,READ_SEARCH}\n");
+	if (!capable(CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH) || !capable(CAP_SYS_ADMIN)) {
+		ckpt_err(ctx, -EPERM, "%(T)Relinking unlinked files requires CAP_DAC_{OVERRIDE,READ_SEARCH} and CAP_SYS_ADMIN\n");
 		return -EPERM;
 	}
-	ret = checkpoint_fill_relink_fname(ctx, file, new_path, &len);
-	if (ret)
+
+	/* Temporarily set mount namespace to be that of the file to 'relink' */
+	old_nsproxy = current->nsproxy;
+	get_nsproxy(old_nsproxy);
+	ret = kern_setns(&mntns_operations, file->f_path.mnt->mnt_ns);
+	if (ret) {
+		/* We never switched so we never dropped the new ref to old_nsproxy*/
+		put_nsproxy(old_nsproxy);
 		return ret;
+	}
+
+	/* The switch dropped the old ref to old_nsproxy */
+
+	/* Relink it */
+	ret = checkpoint_fill_relink_fname(ctx, file, new_path, &len);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to fill relink name.\n", file, file->f_op);
+		goto switch_oldns;
+	}
 	ret = checkpoint_make_relink_collection(ctx, new_path, len);
-	if (ret)
-		return ret;
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to make relink collection dir for \"%s\".\n", file, file->f_op, new_path);
+		goto switch_oldns;
+	}
 	ret = do_kern_linkat(&file->f_path, file->f_dentry,
 			     AT_FDCWD, new_path, 0);
 	if (ret)
 		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to relink unlinked file.\n", file, file->f_op);
+
+	/* Restore old mount namespace */
+switch_oldns:
+	switch_task_namespaces(current, old_nsproxy);
 	return ret;
 }
 
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 7b370c7..adcef23 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -69,6 +69,9 @@ void free_nsproxy(struct nsproxy *ns);
 int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
 	struct fs_struct *);
 
+struct proc_ns_operations;
+int kern_setns(const struct proc_ns_operations *ops, void *ns);
+
 static inline void put_nsproxy(struct nsproxy *ns)
 {
 	if (atomic_dec_and_test(&ns->count)) {
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 62ee344..5c7c59a 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -454,11 +454,27 @@ static inline int checkpoint_register_nsproxy(void)
 }
 #endif /* CONFIG_CHECKPOINT */
 
+int kern_setns(const struct proc_ns_operations *ops, void *ns)
+{
+	struct nsproxy *new_nsproxy;
+	int err;
+
+	new_nsproxy = create_new_namespaces(0, current, current->fs);
+	if (IS_ERR(new_nsproxy))
+		return PTR_ERR(new_nsproxy);
+	err = ops->install(new_nsproxy, ns);
+	if (err) {
+		free_nsproxy(new_nsproxy);
+		goto out;
+	}
+	switch_task_namespaces(current, new_nsproxy);
+out:
+	return err;
+}
+
 SYSCALL_DEFINE2(setns, unsigned int, nstype, int, fd)
 {
 	const struct proc_ns_operations *ops;
-	struct task_struct *tsk = current;
-	struct nsproxy *new_nsproxy;
 	struct proc_inode *ei;
 	struct file *file;
 	int err;
@@ -478,18 +494,7 @@ SYSCALL_DEFINE2(setns, unsigned int, nstype, int, fd)
 	    memcmp(&nstype, ops->name.name, ops->name.len)))
 		goto out;
 
-	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
-	if (IS_ERR(new_nsproxy)) {
-		err = PTR_ERR(new_nsproxy);
-		goto out;
-	}
-
-	err = ops->install(new_nsproxy, ei->ns);
-	if (err) {
-		free_nsproxy(new_nsproxy);
-		goto out;
-	}
-	switch_task_namespaces(tsk, new_nsproxy);
+	err = kern_setns(ops, ei->ns);
 out:
 	fput(file);
 	return err;
-- 
1.6.3.3
