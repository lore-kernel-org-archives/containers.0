From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] cr: pty: don't use required_id, change ptmx_open()
Date: Wed, 2 Sep 2009 18:31:11 -0500
Message-ID: <20090902233111.GA27125@us.ibm.com>
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

Ok so here is the patch to do unix98 pty restore by making
invasive changes to ptmx_open() instead of using
task_struct->required_id to pass an index.  Patch generated
against the cr tree with the original pty patches, as I
assume that will be easier to read.

Break ptmx_open() into a ptmx_create() which is used both
by ptmx_open itself, and fs/devpts/inode.c:open_create_pty().
The latter function is used only during sys_restart() when
a unix98 pty must be restored.

Either with or without this patch, the pty test at
	git://git.sr71.net/~hallyn/cr_tests.git
under the pty/ directory.  The question then is which is
a more likely approach to be acceptable upstream.  The
task->required_id approach is imo 'hacky', but it actually
does a much better job of re-using existing helpers, and
therefore is more maintainable.  So part of me DOES prefer
the original required_id approach.

This is purely RFC, so comments very much appreciated.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--
 checkpoint/sys.c           |    8 ---
 drivers/char/pty.c         |   16 +++---
 drivers/char/tty_io.c      |  112 +++++++++++++++++++++++++++++++++++----------
 fs/devpts/inode.c          |   55 ++++++++++++++++++++--
 include/linux/checkpoint.h |    2 
 include/linux/devpts_fs.h  |    2 
 include/linux/sched.h      |    1 
 7 files changed, 151 insertions(+), 45 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 3db18f7..b1fdbd7 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -339,14 +339,6 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	return ret;
 }
 
-static int __init checkpoint_init(void)
-{
-	init_task.required_id = CKPT_REQUIRED_NONE;
-	return 0;
-}
-__initcall(checkpoint_init);
-
-
 /* 'ckpt_debug_level' controls the verbosity level of c/r code */
 #ifdef CONFIG_CHECKPOINT_DEBUG
 
diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index afdab5e..79e86e4 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -28,6 +28,8 @@
 #include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/devpts_fs.h>
+#include <linux/file.h>
+#include <linux/mount.h>
 
 #include <asm/system.h>
 
@@ -629,20 +631,13 @@ static const struct tty_operations pty_unix98_ops = {
  *		allocated_ptys_lock handles the list of free pty numbers
  */
 
-static int __ptmx_open(struct inode *inode, struct file *filp)
+int ptmx_create(struct inode *inode, struct file *filp, int index)
 {
 	struct tty_struct *tty;
 	int retval;
-	int index = -1;
 
 	nonseekable_open(inode, filp);
 
-#ifdef CONFIG_CHECKPOINT
-	/* when restarting, request specific index */
-	if (current->flags & PF_RESTARTING)
-		index = (int) current->required_id;
-#endif
-	/* find a device that is not in use. */
 	index = devpts_new_index(inode, index);
 	if (index < 0)
 		return index;
@@ -675,6 +670,11 @@ out:
 	return retval;
 }
 
+static int __ptmx_open(struct inode *inode, struct file *filp)
+{
+	return ptmx_create(inode, filp, UNSPECIFIED_PTY_INDEX);
+}
+
 static int ptmx_open(struct inode *inode, struct file *filp)
 {
 	int ret;
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index b8f8d79..d27ec36 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -79,6 +79,7 @@
 #include <linux/devpts_fs.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/namei.h>
 #include <linux/console.h>
 #include <linux/timer.h>
 #include <linux/ctype.h>
@@ -2982,13 +2983,97 @@ static int restore_tty_ldisc(struct ckpt_ctx *ctx,
 	return 0;
 }
 
-#define CKPT_PTMX_PATH  "/dev/ptmx"
+#define PTMXNAME "ptmx"
+struct tty_struct *pty_open_by_master_in_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_tty *h, struct file *fdir)
+{
+	struct tty_struct *tty;
+	struct file *file;
+	int ret;
+	struct qstr ptmxname;
+	struct dentry *ptmxdentry;
+	struct nameidata nd;
+
+	ret = file_permission(fdir, MAY_EXEC);
+	if (ret)
+		return ERR_PTR(ret);
+	nd.path = fdir->f_path;
+	path_get(&nd.path);
+	ptmxname.name = PTMXNAME;
+	ptmxname.len = strlen(ptmxname.name);
+	mutex_lock(&fdir->f_dentry->d_inode->i_mutex);
+	ptmxdentry = d_hash_and_lookup(fdir->f_dentry, &ptmxname);
+	mutex_unlock(&fdir->f_dentry->d_inode->i_mutex);
+	if (!ptmxdentry) {
+		path_put(&nd.path);
+		return ERR_PTR(-ENOENT);
+	}
+
+	/* should get mode from the file handle... */
+	file = alloc_file(nd.path.mnt, ptmxdentry, FMODE_READ|FMODE_WRITE, &tty_fops);
+	path_put(&nd.path);
+	if (!file) {
+		dput(ptmxdentry);
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = security_dentry_open(file, current_cred());
+	if (ret) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+	/* check write access perms to file */
+
+	lock_kernel();  /* tty_open does it... */
+	ret = open_create_pty(fdir, h->index, file);
+	unlock_kernel();
+	if (ret) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+	ckpt_debug("master file %p (obj %d)\n", file, h->file_objref);
+
+	/*
+	 * Add file to objhash to ensure proper cleanup later
+	 * (it isn't referenced elsewhere). Use h->file_objref
+	 * which was explicitly during checkpoint for this.
+	 */
+	ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
+	if (ret < 0) {
+		fput(file);
+		return ERR_PTR(ret);
+	}
+
+	tty = file->private_data;
+	fput(file);   /* objhash took a ref */
+
+	return tty;
+}
+
+struct tty_struct *pty_open_by_master(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_tty *h)
+{
+	struct file *fdir;
+	struct tty_struct *tty;
+	/*
+	 * we need to pick a way to specify which devpts
+	 * mountpoint to use.  For now, we'll just use
+	 * whatever /dev/ptmx points to
+	 */
+	fdir = filp_open("/dev/pts", O_RDONLY, 0);
+	if (IS_ERR(fdir))
+		return ERR_PTR(PTR_ERR(fdir));
+
+	tty = pty_open_by_master_in_ns(ctx, h, fdir);
+	fput(fdir);
+
+	return tty;
+}
 
 static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tty *h;
 	struct tty_struct *tty = ERR_PTR(-EINVAL);
-	struct file *file = NULL;
 	int master, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TTY);
@@ -3025,28 +3110,9 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	 * specific (and probably called via tty_operations).
 	 */
 	if (master) {
-		current->required_id = h->index;
-		file = filp_open(CKPT_PTMX_PATH, O_RDWR | O_NOCTTY, 0);
-		current->required_id = CKPT_REQUIRED_NONE;
-		ckpt_debug("master file %p (obj %d)\n", file, h->file_objref);
-		if (IS_ERR(file)) {
-			tty = (struct tty_struct *) file;
-			goto out;
-		}
-
-		/*
-		 * Add file to objhash to ensure proper cleanup later
-		 * (it isn't referenced elsewhere). Use h->file_objref
-		 * which was explicitly during checkpoint for this.
-		 */
-		ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
-		if (ret < 0) {
-			tty = ERR_PTR(ret);
-			fput(file);
+		tty = pty_open_by_master(ctx, h);
+		if (IS_ERR(tty))
 			goto out;
-		}
-
-		tty = file->private_data;
 	} else {
 		tty = ckpt_obj_fetch(ctx, h->link_objref, CKPT_OBJ_TTY);
 		if (IS_ERR(tty))
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 8921726..f76083f 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -14,6 +14,9 @@
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/smp_lock.h>
+#include <linux/file.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/tty.h>
@@ -431,13 +434,18 @@ static struct file_system_type devpts_fs_type = {
 /*
  * The normal naming convention is simply /dev/pts/<number>; this conforms
  * to the System V naming convention
+ *
+ * @ptmx_inode: inode of the /dev/ptmx file - each pty namepace has its
+ * own
+ * @req_idx: requested specific index (i.e. 5 for /dev/pts/5).  If -1,
+ * then return first available.
  */
 
 int devpts_new_index(struct inode *ptmx_inode, int req_idx)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	int index;
+	int index = req_idx;
 	int ida_ret;
 
 retry:
@@ -445,7 +453,8 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	index = (req_idx >= 0 ? req_idx : 0);
+	if (index == UNSPECIFIED_PTY_INDEX)
+		index = 0;
 	ida_ret = ida_get_new_above(&fsi->allocated_ptys, index, &index);
 	if (ida_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
@@ -454,7 +463,7 @@ retry:
 		return -EIO;
 	}
 
-	if (req_idx >= 0 && index != req_idx) {
+	if (req_idx != UNSPECIFIED_PTY_INDEX && index != req_idx) {
 		ida_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
 		return -EBUSY;
@@ -557,6 +566,46 @@ out:
 	mutex_unlock(&root->d_inode->i_mutex);
 }
 
+struct inode *get_ptmx_inode(struct super_block *sb)
+{
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct dentry *dentry = fsi->ptmx_dentry;
+	struct inode *inode = dentry->d_inode;
+
+	return igrab(inode);
+}
+
+/* defined in drivers/char/pty.c */
+extern int ptmx_create(struct inode *inode, struct file *filp, int index);
+
+/*
+ * fn caller (in restart code) has checked for the rights on the
+ * part of the userspace task to open the ptmx file.
+ * @pdir: an open file handle to the /dev/pts directory, which we
+ * will use to determine the devpts namespace, and to confirm that
+ * the resulting file is in the right directory.
+ * @file is a file for /dev/ptmx
+ */
+int open_create_pty(struct file *fdir, int idx, struct file *file)
+{
+	struct inode *ptmx_ino;
+	struct dentry *pdir = fdir->f_dentry;
+	struct super_block *sb;
+	int ret;
+
+	if (!pdir || !pdir->d_inode)
+		return -EINVAL;
+
+	sb = pts_sb_from_inode(pdir->d_inode);
+	ptmx_ino = get_ptmx_inode(sb);
+	if (!ptmx_ino)
+		return -EINVAL;
+
+	ret = ptmx_create(ptmx_ino, file, idx);
+	iput(ptmx_ino);
+	return ret;
+}
+
 static int __init init_devpts_fs(void)
 {
 	int err = register_filesystem(&devpts_fs_type);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 5e90ef9..0cbe8c4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -46,8 +46,6 @@
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
 #define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
 
-#define CKPT_REQUIRED_NONE  ((unsigned long) -1L)
-
 extern void exit_checkpoint(struct task_struct *tsk);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 14948ee..a15d23c 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,10 +15,12 @@
 
 #include <linux/errno.h>
 
+#define UNSPECIFIED_PTY_INDEX -1
 #ifdef CONFIG_UNIX98_PTYS
 
 int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
+int open_create_pty(struct file *fdir, int idx, struct file *file);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
 /* get tty structure */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f6f1350..0e67de7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1481,7 +1481,6 @@ struct task_struct {
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_CHECKPOINT
 	struct ckpt_ctx *checkpoint_ctx;
-	unsigned long required_id;
 #endif
 };
