From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cr: pty: don't use required_id, change ptmx_open()
Date: Wed, 9 Sep 2009 21:28:06 -0500
Message-ID: <20090910022806.GA12993@us.ibm.com>
References: <20090902233111.GA27125@us.ibm.com> <4AA69EEB.9040706@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA69EEB.9040706-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > +	file = alloc_file(nd.path.mnt, ptmxdentry, FMODE_READ|FMODE_WRITE, &tty_fops);
> > +	path_put(&nd.path);
> > +	if (!file) {
> > +		dput(ptmxdentry);
> > +		return ERR_PTR(-EINVAL);
> > +	}
> > +
> > +	ret = security_dentry_open(file, current_cred());
> > +	if (ret) {
> > +		fput(file);
> > +		return ERR_PTR(ret);
> > +	}
> > +	/* check write access perms to file */
> 
> I bet the above can be done by reusing lookup and __dentry_open()
> functions from fs/open.c and fs/namei.c ...

All right, so I tried the below patch (lots of debugging left in) but
the master end doesn't seem to end up right.  After restart, pty_write()
continues to succeed on the re-opened /dev/pts/N, but no reads happen
on the master.

What I'm doing is passing a new flag LOOKUP_CALLER_OPEN to filp_open(),
to tell it not to actually call the fops->open() routine (ptmx_open).
Then I call ptmx_create() (the renamed ptmx_open) by hand.  Seems like
it certainly ought to be working...  But I'm getting nowhere figuring
out what's happening to the major file, so putting it aside for a bit.

Following is the patch against the tree with Oren's original pty patches.

-serge

---
 checkpoint/sys.c           |    8 -----
 drivers/char/pty.c         |   43 ++++++++++++++++++++--------
 drivers/char/tty_io.c      |   69 ++++++++++++++++++++++++++++++++++++---------
 fs/devpts/inode.c          |   60 +++++++++++++++++++++++++++++++++++++--
 fs/open.c                  |   19 +++++++++++-
 include/linux/checkpoint.h |    2 -
 include/linux/devpts_fs.h  |    3 +
 include/linux/namei.h      |    1 
 include/linux/sched.h      |    1 
 9 files changed, 167 insertions(+), 39 deletions(-)

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
index afdab5e..6ea8afb 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -28,6 +28,8 @@
 #include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/devpts_fs.h>
+#include <linux/file.h>
+#include <linux/mount.h>
 
 #include <asm/system.h>
 
@@ -114,6 +116,13 @@ static int pty_write(struct tty_struct *tty, const unsigned char *buf,
 {
 	struct tty_struct *to = tty->link;
 	int c;
+	int debug = (tty->index > 0);
+
+	if (debug)
+		printk(KERN_NOTICE "%s: called on %s idx %d buf .%s. count %d\n",
+			__func__,
+			tty->driver->subtype == PTY_TYPE_MASTER ? "master" : "slave",
+			tty->index, buf, count);
 
 	if (tty->stopped)
 		return 0;
@@ -122,6 +131,8 @@ static int pty_write(struct tty_struct *tty, const unsigned char *buf,
 	   big deal */
 
 	c = pty_space(to);
+	if (debug)
+		printk(KERN_NOTICE "%s: space was %d\n", __func__, c);
 	if (c > count)
 		c = count;
 	if (c > 0) {
@@ -131,6 +142,8 @@ static int pty_write(struct tty_struct *tty, const unsigned char *buf,
 		tty_flip_buffer_push(to);
 		tty_wakeup(tty);
 	}
+	if (debug)
+		printk(KERN_NOTICE "%s: returning %d\n", __func__, c);
 	return c;
 }
 
@@ -196,13 +209,21 @@ static int pty_open(struct tty_struct *tty, struct file *filp)
 	if (!tty || !tty->link)
 		goto out;
 
+	printk(KERN_NOTICE "%s: tty is %pS link %pS\n",
+		__func__, tty, tty->link);
 	retval = -EIO;
-	if (test_bit(TTY_OTHER_CLOSED, &tty->flags))
+	if (test_bit(TTY_OTHER_CLOSED, &tty->flags)) {
+		printk(KERN_NOTICE "%s: other end closed\n", __func__);
 		goto out;
-	if (test_bit(TTY_PTY_LOCK, &tty->link->flags))
+	}
+	if (test_bit(TTY_PTY_LOCK, &tty->link->flags)) {
+		printk(KERN_NOTICE "%s: ptylock\n", __func__);
 		goto out;
-	if (tty->link->count != 1)
+	}
+	if (tty->link->count != 1) {
+		printk(KERN_NOTICE "%s: count is %d (!=1)\n", __func__, tty->link->count);
 		goto out;
+	}
 
 	clear_bit(TTY_OTHER_CLOSED, &tty->link->flags);
 	set_bit(TTY_THROTTLED, &tty->flags);
@@ -629,27 +650,22 @@ static const struct tty_operations pty_unix98_ops = {
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
+	printk(KERN_NOTICE "%s: index %d\n", __func__, index);
 	if (index < 0)
 		return index;
 
 	mutex_lock(&tty_mutex);
 	tty = tty_init_dev(ptm_driver, index, 1);
 	mutex_unlock(&tty_mutex);
+	printk(KERN_NOTICE "%s: tty is %pS\n", __func__, tty);
 
 	if (IS_ERR(tty)) {
 		retval = PTR_ERR(tty);
@@ -675,6 +691,11 @@ out:
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
index b8f8d79..d363c0e 100644
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
@@ -891,8 +892,19 @@ static ssize_t tty_read(struct file *file, char __user *buf, size_t count,
 	struct tty_struct *tty;
 	struct inode *inode;
 	struct tty_ldisc *ld;
+	int debug = 0;
 
 	tty = (struct tty_struct *)file->private_data;
+	if ((tty->driver->subtype == PTY_TYPE_MASTER ||
+			tty->driver->subtype == PTY_TYPE_SLAVE) &&
+			tty->index > 0)
+		debug = 1;
+
+	if (debug)
+		printk(KERN_NOTICE "%s: called on %s idx %d count %ld\n",
+			__func__,
+			tty->driver->subtype == PTY_TYPE_MASTER ? "master" : "slave",
+			tty->index, count);
 	inode = file->f_path.dentry->d_inode;
 	if (tty_paranoia_check(tty, inode, "tty_read"))
 		return -EIO;
@@ -909,6 +921,8 @@ static ssize_t tty_read(struct file *file, char __user *buf, size_t count,
 	tty_ldisc_deref(ld);
 	if (i > 0)
 		inode->i_atime = current_fs_time(inode->i_sb);
+	if (debug)
+		printk(KERN_NOTICE "%s: returning %d\n", __func__, i);
 	return i;
 }
 
@@ -2907,6 +2921,7 @@ struct file *tty_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		clear_bit(TTY_PTY_LOCK, &tty->link->flags);
 		file = filp_open(slavepath, O_RDWR | O_NOCTTY, 0);
 		ckpt_debug("slave file %p (idnex %d)\n", file, tty->index);
+		ckpt_debug("slavelock was %d\n", slavelock);
 		if (IS_ERR(file))
 			return file;
 		if (slavelock)
@@ -2982,13 +2997,43 @@ static int restore_tty_ldisc(struct ckpt_ctx *ctx,
 	return 0;
 }
 
-#define CKPT_PTMX_PATH  "/dev/ptmx"
+struct file *pty_open_by_index(char *ptmxpath, int index)
+{
+	struct file *ptmxfile;
+	int ret;
+
+	/*
+	 * we need to pick a way to specify which devpts
+	 * mountpoint to use.  For now, we'll just use
+	 * whatever /dev/ptmx points to
+	 */
+	ptmxfile = filp_open(ptmxpath, O_RDWR|O_NOCTTY|LOOKUP_CALLER_OPEN, 0);
+	if (IS_ERR(ptmxfile))
+		return ptmxfile;
+
+	if (!file_is_ptmx(ptmxfile)) {
+		printk(KERN_NOTICE "%s: dentry was not ptmx\n", __func__);
+		fput(ptmxfile);
+		return ERR_PTR(-ENOENT);
+	}
+
+	lock_kernel();
+	ret = open_create_pty(ptmxfile, index);
+	unlock_kernel();
+	printk(KERN_NOTICE "%s: open_create_pty returned %d\n", __func__, ret);
+	if (ret) {
+		fput(ptmxfile);
+		return ERR_PTR(ret);
+	}
+	printk(KERN_NOTICE "%s: done\n", __func__);
+
+	return ptmxfile;
+}
 
 static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tty *h;
 	struct tty_struct *tty = ERR_PTR(-EINVAL);
-	struct file *file = NULL;
 	int master, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TTY);
@@ -3025,30 +3070,25 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	 * specific (and probably called via tty_operations).
 	 */
 	if (master) {
-		current->required_id = h->index;
-		file = filp_open(CKPT_PTMX_PATH, O_RDWR | O_NOCTTY, 0);
-		current->required_id = CKPT_REQUIRED_NONE;
-		ckpt_debug("master file %p (obj %d)\n", file, h->file_objref);
-		if (IS_ERR(file)) {
-			tty = (struct tty_struct *) file;
+		struct file *f = pty_open_by_index("/dev/ptmx", h->index);
+		if (IS_ERR(f))
 			goto out;
-		}
+		tty = f->private_data;
 
 		/*
 		 * Add file to objhash to ensure proper cleanup later
 		 * (it isn't referenced elsewhere). Use h->file_objref
 		 * which was explicitly during checkpoint for this.
 		 */
-		ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
+		ret = ckpt_obj_insert(ctx, f, h->file_objref, CKPT_OBJ_FILE);
+		fput(f);  /* objhash took an extra reference */
 		if (ret < 0) {
 			tty = ERR_PTR(ret);
-			fput(file);
 			goto out;
 		}
-
-		tty = file->private_data;
 	} else {
 		tty = ckpt_obj_fetch(ctx, h->link_objref, CKPT_OBJ_TTY);
+		ckpt_debug("restoring slave");
 		if (IS_ERR(tty))
 			goto out;
 		tty = tty->link;
@@ -3077,15 +3117,18 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	tty->winsize.ws_xpixel = h->winsize.ws_xpixel;
 	mutex_unlock(&tty->termios_mutex);
 
+	ckpt_debug("after mutex_unlock");
 	if (test_bit(TTY_HUPPED, (unsigned long *) &h->flags))
 		tty_vhangup(tty);
 	else {
 		ret = restore_tty_ldisc(ctx, tty, h);
+		ckpt_debug("restore_tty_ldisc returnd %d\n", ret);
 		if (ret < 0) {
 			tty = ERR_PTR(ret);
 			goto out;
 		}
 	}
+	ckpt_debug("at end tty is %pS", tty);
 
 	tty_kref_get(tty);
  out:
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 8921726..cfadb22 100644
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
@@ -557,6 +566,51 @@ out:
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
+int open_create_pty(struct file *ptmxfile, int idx)
+{
+	return  ptmx_create(ptmxfile->f_dentry->d_inode, ptmxfile, idx);
+}
+
+int file_is_ptmx(struct file *file)
+{
+	dev_t device;
+	struct inode *inode;
+
+	if (!file->f_dentry)
+		return 0;
+	inode = file->f_dentry->d_inode;
+	if (!inode)
+		return 0;
+	device = inode->i_rdev;
+	if (!device)
+		return 0;
+	if (imajor(inode) != TTYAUX_MAJOR)
+		return 0;
+	if (iminor(inode) != 2)
+		return 0;
+	return 1;
+}
+
 static int __init init_devpts_fs(void)
 {
 	int err = register_filesystem(&devpts_fs_type);
diff --git a/fs/open.c b/fs/open.c
index dd98e80..c65229a 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -924,6 +924,17 @@ out_err:
 }
 EXPORT_SYMBOL_GPL(lookup_instantiate_filp);
 
+/*
+ * Passed to nameidata_to_filp to keep it from running
+ * the file-specified open routine.
+ * We pass this along if LOOKUP_CALLER_OPEN was passed to
+ * filp_open, meaning the caller will open the file by hand
+ */
+static int __dummy_open(struct inode *inode, struct file *filp)
+{
+	return 0;
+}
+
 /**
  * nameidata_to_filp - convert a nameidata to an open filp.
  * @nd: pointer to nameidata
@@ -935,13 +946,19 @@ struct file *nameidata_to_filp(struct nameidata *nd, int flags)
 {
 	const struct cred *cred = current_cred();
 	struct file *filp;
+	int (*open)(struct inode *, struct file *) = NULL;
+
+	if (flags & LOOKUP_CALLER_OPEN) {
+		printk(KERN_NOTICE "%s: I was passed LOOKUP_CALLER_OPEN\n", __func__);
+		open = __dummy_open;
+	}
 
 	/* Pick up the filp from the open intent */
 	filp = nd->intent.open.file;
 	/* Has the filesystem initialised the file for us? */
 	if (filp->f_path.dentry == NULL)
 		filp = __dentry_open(nd->path.dentry, nd->path.mnt, flags, filp,
-				     NULL, cred);
+				     open, cred);
 	else
 		path_put(&nd->path);
 	return filp;
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
index 14948ee..ddb418d 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,10 +15,13 @@
 
 #include <linux/errno.h>
 
+#define UNSPECIFIED_PTY_INDEX -1
 #ifdef CONFIG_UNIX98_PTYS
 
 int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
+int open_create_pty(struct file *ptmxfile, int idx);
+int file_is_ptmx(struct file *file);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
 /* get tty structure */
diff --git a/include/linux/namei.h b/include/linux/namei.h
index d870ae2..fae5159 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -56,6 +56,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_CREATE		0x0200
 #define LOOKUP_EXCL		0x0400
 #define LOOKUP_RENAME_TARGET	0x0800
+#define LOOKUP_CALLER_OPEN	0x1000
 
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 
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
