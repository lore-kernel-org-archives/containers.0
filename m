From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] Restore task fs_root and pwd
Date: Thu, 10 Dec 2009 13:00:31 -0600
Message-ID: <20091210190031.GA19315@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint and restore task->fs.  Tasks sharing task->fs will
share them again after restart.

The fs/fs_struct.c part should of course be broken out, but
this does the right thing for me.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |  211 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c           |    9 ++
 checkpoint/process.c           |   13 +++
 fs/open.c                      |   53 ++++++----
 include/linux/checkpoint.h     |   10 ++-
 include/linux/checkpoint_hdr.h |   10 ++
 include/linux/fs.h             |    4 +
 7 files changed, 287 insertions(+), 23 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index b622588..c8e8d7f 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -24,6 +24,9 @@
 #include <linux/checkpoint_hdr.h>
 #include <linux/eventpoll.h>
 #include <linux/eventfd.h>
+#include <linux/fs.h>
+#include <linux/fs_struct.h>
+#include <linux/namei.h>
 #include <net/sock.h>
 
 
@@ -449,6 +452,71 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+int checkpoint_get_task_fs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct fs_struct *fs;
+	int fs_objref;
+	int kill;
+
+	task_lock(current);
+	fs = t->fs;
+	write_lock(&fs->lock);
+	fs->users++;
+	write_unlock(&fs->lock);
+	task_unlock(current);
+
+	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_TASK_FS);
+	write_lock(&fs->lock);
+	kill = !--fs->users;
+	write_unlock(&fs->lock);
+	if (kill)
+		free_fs_struct(fs);
+
+	return fs_objref;
+}
+
+/*
+ * called with fs read_lock()d
+ */
+int checkpoint_obj_task_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
+{
+	struct ckpt_hdr_task_fs *h;
+	int ret;
+	struct fs_struct *fscopy;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret)
+		return ret;
+
+	fscopy = copy_fs_struct(fs);
+	if (!fs)
+		return -ENOMEM;
+
+	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->fs_mnt);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)writing name of fs root");
+		goto out;
+	}
+	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->fs_mnt);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)writing name of pwd");
+		goto out;
+	}
+	ret = 0;
+out:
+	free_fs_struct(fscopy);
+	return ret;
+}
+
+int checkpoint_task_fs(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_obj_task_fs(ctx, (struct fs_struct *) ptr);
+}
+
 /**************************************************************************
  * Restart
  */
@@ -812,3 +880,146 @@ int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
 
 	return 0;
 }
+
+static int restore_chroot(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
+{
+	struct nameidata nd;
+	int ret;
+
+	ckpt_debug("attempting chroot to %s\n", name);
+	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Opening chroot dir %s", name);
+		return ret;
+	}
+	ret = do_chroot(fs, &nd.path);
+	path_put(&nd.path);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Setting chroot %s", name);
+		return ret;
+	}
+	return 0;
+}
+
+static int restore_cwd(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
+{
+	struct nameidata nd;
+	int ret;
+
+	ckpt_debug("attempting chdir to %s\n", name);
+	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Opening cwd %s", name);
+		return ret;
+	}
+	ret = do_chdir(fs, &nd.path);
+	path_put(&nd.path);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Setting cwd %s", name);
+		return ret;
+	}
+	return 0;
+}
+
+int obj_task_fs_grab(void *ptr)
+{
+	struct fs_struct *fs = ptr;
+
+	write_lock(&fs->lock);
+	fs->users++;
+	write_unlock(&fs->lock);
+	return 0;
+}
+
+void obj_task_fs_drop(void *ptr, int lastref)
+{
+	struct fs_struct *fs = ptr;
+	int kill;
+
+	write_lock(&fs->lock);
+	kill = !--fs->users;
+	write_unlock(&fs->lock);
+	if (kill)
+		free_fs_struct(fs);
+}
+
+/* this is the fn called by objhash when it runs into a
+ * CKPT_OBJ_TASK_FS entry.  Creates an fs_struct and
+ * places it in the hash. */
+static struct fs_struct *restore_obj_task_fs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_fs *h;
+	struct fs_struct *fs;
+	int ret = 0;
+	char *root, *cwd;
+	int len;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	ckpt_hdr_put(ctx, h);
+
+	fs = copy_fs_struct(current->fs);
+	if (!fs)
+		return ERR_PTR(-ENOMEM);
+
+	len = ckpt_read_payload(ctx, (void **) &root,
+				PATH_MAX, CKPT_HDR_FILE_NAME);
+	ret = restore_chroot(ctx, fs, root);
+	kfree(root);
+	if (ret) {
+		free_fs_struct(fs);
+		return ERR_PTR(ret);
+	}
+
+	len = ckpt_read_payload(ctx, (void **) &cwd,
+				PATH_MAX, CKPT_HDR_FILE_NAME);
+	ret = restore_cwd(ctx, fs, cwd);
+	kfree(cwd);
+
+	if (ret) {
+		free_fs_struct(fs);
+		return ERR_PTR(ret);
+	}
+	return fs;
+}
+
+void *restore_task_fs(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_obj_task_fs(ctx);
+}
+
+/*
+ * Called by task restore code to set the restarted task's
+ * current->fs to an entry on the hash
+ */
+int restore_set_task_fs(struct ckpt_ctx *ctx, int fs_objref)
+{
+	struct fs_struct *newfs, *oldfs;
+	int kill;
+
+	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_TASK_FS);
+	if (IS_ERR(newfs))
+		return PTR_ERR(newfs);
+
+	task_lock(current);
+	oldfs = current->fs;
+	write_lock(&oldfs->lock);
+	/* tasks run sys_restart in serial, and the restored fs was
+	 * created during restart, so (a) no contention and therefore
+	 * no deadlock is possible by the wait on newfs->lock, and so (b)
+	 * we really shouldn't need this lock at all, but it woudl be
+	 * improper to skip it... */
+	write_lock(&newfs->lock);
+	kill = --oldfs->users;
+	current->fs = newfs;
+	newfs->users++;
+	write_unlock(&newfs->lock);
+	write_unlock(&oldfs->lock);
+	task_unlock(current);
+
+	if (kill)
+		free_fs_struct(oldfs);
+
+	return 0;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 782661d..20fd3e9 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -417,6 +417,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_userns,
 		.restore = restore_userns,
 	},
+	/* struct fs_struct */
+	{
+		.obj_name = "TASK_FS",
+		.obj_type = CKPT_OBJ_TASK_FS,
+		.ref_drop = obj_task_fs_drop,
+		.ref_grab = obj_task_fs_grab,
+		.checkpoint = checkpoint_task_fs,
+		.restore = restore_task_fs,
+	},
 	/* struct cred */
 	{
 		.obj_name = "CRED",
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 9c0463d..603bbf4 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -234,6 +234,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int mm_objref;
 	int sighand_objref;
 	int signal_objref;
+	int fs_objref;
 	int first, ret;
 
 	/*
@@ -253,6 +254,12 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		return ret;
 
+	fs_objref = checkpoint_get_task_fs(ctx, t);
+	if (fs_objref < 0) {
+		ckpt_err(ctx, fs_objref, "%(T)process fs\n");
+		return fs_objref;
+	}
+
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
 	if (files_objref < 0) {
@@ -294,6 +301,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->mm_objref = mm_objref;
 	h->sighand_objref = sighand_objref;
 	h->signal_objref = signal_objref;
+	h->fs_objref = fs_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 	if (ret < 0)
@@ -628,6 +636,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 	}
 
+	ret = restore_set_task_fs(ctx, h->fs_objref);
+	ckpt_debug("restore_task_fs returned %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
 	if (ret < 0)
diff --git a/fs/open.c b/fs/open.c
index 4f01e06..75c395d 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -524,6 +524,18 @@ SYSCALL_DEFINE2(access, const char __user *, filename, int, mode)
 	return sys_faccessat(AT_FDCWD, filename, mode);
 }
 
+int do_chdir(struct fs_struct *fs, struct path *path)
+{
+	int error;
+
+	error = inode_permission(path->dentry->d_inode, MAY_EXEC | MAY_ACCESS);
+	if (error)
+		return error;
+
+	set_fs_pwd(fs, path);
+	return 0;
+}
+
 SYSCALL_DEFINE1(chdir, const char __user *, filename)
 {
 	struct path path;
@@ -531,17 +543,10 @@ SYSCALL_DEFINE1(chdir, const char __user *, filename)
 
 	error = user_path_dir(filename, &path);
 	if (error)
-		goto out;
-
-	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_ACCESS);
-	if (error)
-		goto dput_and_out;
-
-	set_fs_pwd(current->fs, &path);
+		return error;
 
-dput_and_out:
+	error = do_chdir(current->fs, &path);
 	path_put(&path);
-out:
 	return error;
 }
 
@@ -571,6 +576,21 @@ out:
 	return error;
 }
 
+int do_chroot(struct fs_struct *fs, struct path *path)
+{
+	int error;
+
+	error = inode_permission(path->dentry->d_inode, MAY_EXEC | MAY_ACCESS);
+	if (error)
+		return error;
+
+	if (!capable(CAP_SYS_CHROOT))
+		return -EPERM;
+
+	set_fs_root(fs, path);
+	return 0;
+}
+
 SYSCALL_DEFINE1(chroot, const char __user *, filename)
 {
 	struct path path;
@@ -578,21 +598,10 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
 
 	error = user_path_dir(filename, &path);
 	if (error)
-		goto out;
-
-	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_ACCESS);
-	if (error)
-		goto dput_and_out;
-
-	error = -EPERM;
-	if (!capable(CAP_SYS_CHROOT))
-		goto dput_and_out;
+		return error;
 
-	set_fs_root(current->fs, &path);
-	error = 0;
-dput_and_out:
+	error = do_chroot(current->fs, &path);
 	path_put(&path);
-out:
 	return error;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1f85162..92d47fa 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  4
+#define CHECKPOINT_VERSION  5
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
@@ -229,6 +229,14 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 			       struct ckpt_hdr_file *h);
 
+extern int checkpoint_task_fs(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_task_fs(struct ckpt_ctx *ctx);
+extern void obj_task_fs_drop(void *ptr, int lastref);
+extern int obj_task_fs_grab(void *ptr);
+
+extern int restore_set_task_fs(struct ckpt_ctx *ctx, int fs_objref);
+extern int checkpoint_get_task_fs(struct ckpt_ctx *ctx, struct task_struct *t);
+
 /* credentials */
 extern int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr);
 extern int checkpoint_user(struct ckpt_ctx *ctx, void *ptr);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4e57d37..82937c2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -89,6 +89,8 @@ enum {
 #define CKPT_HDR_TASK CKPT_HDR_TASK
 	CKPT_HDR_TASK_NS,
 #define CKPT_HDR_TASK_NS CKPT_HDR_TASK_NS
+	CKPT_HDR_TASK_FS,
+#define CKPT_HDR_TASK_FS CKPT_HDR_TASK_FS
 	CKPT_HDR_TASK_OBJS,
 #define CKPT_HDR_TASK_OBJS CKPT_HDR_TASK_OBJS
 	CKPT_HDR_RESTART_BLOCK,
@@ -228,6 +230,8 @@ enum obj_type {
 #define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
 	CKPT_OBJ_USER_NS,
 #define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
+	CKPT_OBJ_TASK_FS,
+#define CKPT_OBJ_TASK_FS CKPT_OBJ_TASK_FS
 	CKPT_OBJ_CRED,
 #define CKPT_OBJ_CRED CKPT_OBJ_CRED
 	CKPT_OBJ_USER,
@@ -365,6 +369,11 @@ struct ckpt_hdr_task_creds {
 	__s32 ecred_ref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_task_fs {
+	struct ckpt_hdr h;
+	/* followed by filenames for fs->root and fs->pwd */
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_cred {
 	struct ckpt_hdr h;
 	__u32 uid, suid, euid, fsuid;
@@ -452,6 +461,7 @@ struct ckpt_hdr_task_objs {
 	__s32 mm_objref;
 	__s32 sighand_objref;
 	__s32 signal_objref;
+	__s32 fs_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5ae34fc..0efa62a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1819,9 +1819,13 @@ extern struct vfsmount *collect_mounts(struct path *);
 extern void drop_collected_mounts(struct vfsmount *);
 
 extern int vfs_statfs(struct dentry *, struct kstatfs *);
+struct fs_struct;
+extern int do_chdir(struct fs_struct *fs, struct path *path);
+extern int do_chroot(struct fs_struct *fs, struct path *path);
 
 extern int current_umask(void);
 
+
 /* /sys/fs */
 extern struct kobject *fs_kobj;
 
-- 
1.6.0.4
