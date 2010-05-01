From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 076/100] c/r: [pty 1/2] allow allocation of desired pty
	slave
Date: Sat,  1 May 2010 10:15:58 -0400
Message-ID: <1272723382-19470-77-git-send-email-orenl__7777.80919238484$1272727883$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

During restart, we need to allocate pty slaves with the same
identifiers as recorded during checkpoint. Modify the allocation code
to allow an in-kernel caller to request a specific slave identifier.

For this, add a new field to task_struct - 'required_id'. It will
hold the desired identifier when restoring a (master) pty.

The code in ptmx_open() will use this value only for tasks that try to
open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
isn't CKPT_REQUIRED_NONE (-1).

Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33

Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/pty.c        |   66 +++++++++++++++++++++++++++++++++++++++++---
 fs/devpts/inode.c         |   13 +++++++--
 include/linux/devpts_fs.h |    6 +++-
 include/linux/tty.h       |    1 -
 4 files changed, 76 insertions(+), 10 deletions(-)

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index d83a431..cfe77c8 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -28,6 +28,7 @@
 #include <linux/device.h>
 #include <linux/uaccess.h>
 #include <linux/bitops.h>
+#include <linux/file.h>
 #include <linux/devpts_fs.h>
 #include <linux/slab.h>
 
@@ -615,9 +616,10 @@ static const struct tty_operations pty_unix98_ops = {
 };
 
 /**
- *	ptmx_open		-	open a unix 98 pty master
+ *	__ptmx_open		-	open a unix 98 pty master
  *	@inode: inode of device file
  *	@filp: file pointer to tty
+ *	@index: desired slave index
  *
  *	Allocate a unix98 pty master device from the ptmx driver.
  *
@@ -626,16 +628,15 @@ static const struct tty_operations pty_unix98_ops = {
  *		allocated_ptys_lock handles the list of free pty numbers
  */
 
-static int __ptmx_open(struct inode *inode, struct file *filp)
+static int __ptmx_open(struct inode *inode, struct file *filp, int index)
 {
 	struct tty_struct *tty;
 	int retval;
-	int index;
 
 	nonseekable_open(inode, filp);
 
 	/* find a device that is not in use. */
-	index = devpts_new_index(inode);
+	index = devpts_new_index(inode, index);
 	if (index < 0)
 		return index;
 
@@ -671,12 +672,66 @@ static int ptmx_open(struct inode *inode, struct file *filp)
 {
 	int ret;
 
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * If current task is restarting, we skip the actual open.
+	 * Instead, leave it up to the caller (restart code) to invoke
+	 * __ptmx_open() with the desired pty index request.
+	 *
+	 * NOTE: this gives a half-baked file that has ptmx f_op but
+	 * the tty (private_data) is NULL. It is the responsibility of
+	 * the _caller_ to ensure proper initialization before
+	 * allowing it to be used (ptmx_release() tolerates NULL tty).
+	 */
+	if (current->flags & PF_RESTARTING)
+		return 0;
+#endif
+
 	lock_kernel();
-	ret = __ptmx_open(inode, filp);
+	ret = __ptmx_open(inode, filp, UNSPECIFIED_PTY_INDEX);
 	unlock_kernel();
 	return ret;
 }
 
+static int ptmx_release(struct inode *inode, struct file *filp)
+{
+#ifdef CONFIG_CHECKPOINT
+	/*
+	 * It is possible for a restart to create a half-baked
+	 * ptmx file - see ptmx_open(). In that case there is no
+	 * tty (private_data) and nothing to do.
+	 */
+	if (!filp->private_data)
+		return 0;
+#endif
+
+	return tty_release(inode, filp);
+}
+
+struct file *pty_open_by_index(char *ptmxpath, int index)
+{
+	struct file *ptmxfile;
+	int ret;
+
+	/*
+	 * We need to pick a way to specify which devpts mountpoint to
+	 * use. For now, we'll just use whatever /dev/ptmx points to.
+	 */
+	ptmxfile = filp_open(ptmxpath, O_RDWR|O_NOCTTY, 0);
+	if (IS_ERR(ptmxfile))
+		return ptmxfile;
+
+	lock_kernel();
+	ret = __ptmx_open(ptmxfile->f_dentry->d_inode, ptmxfile, index);
+	unlock_kernel();
+	if (ret) {
+		fput(ptmxfile);
+		return ERR_PTR(ret);
+	}
+
+	return ptmxfile;
+}
+
 static struct file_operations ptmx_fops;
 
 static void __init unix98_pty_init(void)
@@ -733,6 +788,7 @@ static void __init unix98_pty_init(void)
 	/* Now create the /dev/ptmx special device */
 	tty_default_fops(&ptmx_fops);
 	ptmx_fops.open = ptmx_open;
+	ptmx_fops.release = ptmx_release;
 
 	cdev_init(&ptmx_cdev, &ptmx_fops);
 	if (cdev_add(&ptmx_cdev, MKDEV(TTYAUX_MAJOR, 2), 1) ||
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 0120247..75fb8c5 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -433,11 +433,11 @@ static struct file_system_type devpts_fs_type = {
  * to the System V naming convention
  */
 
-int devpts_new_index(struct inode *ptmx_inode)
+int devpts_new_index(struct inode *ptmx_inode, int req_idx)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	int index;
+	int index = req_idx;
 	int ida_ret;
 
 retry:
@@ -445,7 +445,9 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	ida_ret = ida_get_new(&fsi->allocated_ptys, &index);
+	if (index == UNSPECIFIED_PTY_INDEX)
+		index = 0;
+	ida_ret = ida_get_new_above(&fsi->allocated_ptys, index, &index);
 	if (ida_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
 		if (ida_ret == -EAGAIN)
@@ -453,6 +455,11 @@ retry:
 		return -EIO;
 	}
 
+	if (req_idx != UNSPECIFIED_PTY_INDEX && index != req_idx) {
+		ida_remove(&fsi->allocated_ptys, index);
+		mutex_unlock(&allocated_ptys_lock);
+		return -EBUSY;
+	}
 	if (index >= pty_limit) {
 		ida_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 5ce0e5f..163a70e 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,9 +15,13 @@
 
 #include <linux/errno.h>
 
+#define UNSPECIFIED_PTY_INDEX -1
+
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(struct inode *ptmx_inode);
+struct file *pty_open_by_index(char *ptmxpath, int index);
+
+int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 4409967..d0cbcec 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -513,7 +513,6 @@ extern void tty_ldisc_begin(void);
 /* This last one is just for the tty layer internals and shouldn't be used elsewhere */
 extern void tty_ldisc_enable(struct tty_struct *tty);
 
-
 /* n_tty.c */
 extern struct tty_ldisc_ops tty_ldisc_N_TTY;
 extern void n_tty_inherit_ops(struct tty_ldisc_ops *ops);
-- 
1.6.3.3
