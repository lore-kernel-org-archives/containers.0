From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 2/5]: Add an instance parameter devpts interfaces
Date: Fri, 29 Aug 2008 00:02:11 -0700
Message-ID: <20080829070211.GA21417@us.ibm.com>
References: <20080829070001.GA21286@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080829070001.GA21286-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 2/5]: Add an instance parameter devpts interfaces

Pass-in 'inode' or 'tty' parameter to devpts interfaces.  With multiple
devpts instances, these parameters will be used in subsequent patches
to identify the instance of devpts mounted. The parameters also help
simplify devpts implementation.

Changelog[v3]:  
	- minor changes due to merge with ttydev updates
	- rename parameters to emphasize they are ptmx or pts inodes
	- pass-in tty_struct * to devpts_pty_kill() (this will help
	  cleanup the get_node() call in a subsequent patch)

---
 drivers/char/pty.c         |   18 ++++++++++--------
 drivers/char/tty_io.c      |   14 ++++++++------
 fs/devpts/inode.c          |   11 ++++++-----
 include/linux/devpts_fs.h  |   31 +++++++++++++++++++++----------
 include/linux/tty_driver.h |    3 ++-
 5 files changed, 47 insertions(+), 30 deletions(-)

Index: linux-2.6.27-rc3-tty/drivers/char/pty.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/drivers/char/pty.c	2008-08-28 16:16:29.000000000 -0700
+++ linux-2.6.27-rc3-tty/drivers/char/pty.c	2008-08-28 16:17:04.000000000 -0700
@@ -60,7 +60,7 @@ static void pty_close(struct tty_struct 
 		set_bit(TTY_OTHER_CLOSED, &tty->flags);
 #ifdef CONFIG_UNIX98_PTYS
 		if (tty->driver == ptm_driver)
-			devpts_pty_kill(tty->index);
+			devpts_pty_kill(tty->link);
 #endif
 		tty_vhangup(tty->link);
 	}
@@ -451,9 +451,10 @@ static int pty_unix98_ioctl(struct tty_s
  *	This provides our locking.
  */
 
-static struct tty_struct *ptm_unix98_lookup(struct tty_driver *driver, int idx)
+static struct tty_struct *ptm_unix98_lookup(struct tty_driver *driver,
+		struct inode *ptm_inode, int idx)
 {
-	struct tty_struct *tty = devpts_get_tty(idx);
+	struct tty_struct *tty = devpts_get_tty(ptm_inode, idx);
 	if (tty)
 		tty = tty->link;
 	return tty;
@@ -468,9 +469,10 @@ static struct tty_struct *ptm_unix98_loo
  *	This provides our locking.
  */
 
-static struct tty_struct *pts_unix98_lookup(struct tty_driver *driver, int idx)
+static struct tty_struct *pts_unix98_lookup(struct tty_driver *driver,
+		struct inode *pts_inode, int idx)
 {
-	struct tty_struct *tty = devpts_get_tty(idx);
+	struct tty_struct *tty = devpts_get_tty(pts_inode, idx);
 	/* Master must be open before slave */
 	if (!tty)
 		return ERR_PTR(-EIO);
@@ -598,7 +600,7 @@ static int __ptmx_open(struct inode *ino
 	nonseekable_open(inode, filp);
 
 	/* find a device that is not in use. */
-	index = devpts_new_index();
+	index = devpts_new_index(inode);
 	if (index < 0)
 		return index;
 
@@ -615,7 +617,7 @@ static int __ptmx_open(struct inode *ino
 	filp->private_data = tty;
 	file_move(filp, &tty->tty_files);
 
-	retval = devpts_pty_new(tty->link);
+	retval = devpts_pty_new(inode, tty->link);
 	if (retval)
 		goto out1;
 
@@ -626,7 +628,7 @@ out1:
 	tty_release_dev(filp);
 	return retval;
 out:
-	devpts_kill_index(index);
+	devpts_kill_index(inode, index);
 	return retval;
 }
 
Index: linux-2.6.27-rc3-tty/drivers/char/tty_io.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/drivers/char/tty_io.c	2008-08-28 16:16:29.000000000 -0700
+++ linux-2.6.27-rc3-tty/drivers/char/tty_io.c	2008-08-28 16:17:59.000000000 -0700
@@ -1203,12 +1203,13 @@ static void tty_line_name(struct tty_dri
  *	be held until the 'fast-open' is also done. Will change once we
  *	have refcounting in the driver and per driver locking
  */
-struct tty_struct *tty_driver_lookup_tty(struct tty_driver *driver, int idx)
+struct tty_struct *tty_driver_lookup_tty(struct tty_driver *driver,
+		struct inode *inode, int idx)
 {
 	struct tty_struct *tty;
 
 	if (driver->ops->lookup)
-		return driver->ops->lookup(driver, idx);
+		return driver->ops->lookup(driver, inode, idx);
 
 	tty = driver->ttys[idx];
 	return tty;
@@ -1529,10 +1530,11 @@ void tty_release_dev(struct file *filp)
 	int	devpts;
 	int	idx;
 	char	buf[64];
+	struct 	inode *inode;
 
+	inode = filp->f_path.dentry->d_inode;
 	tty = (struct tty_struct *)filp->private_data;
-	if (tty_paranoia_check(tty, filp->f_path.dentry->d_inode,
-							"tty_release_dev"))
+	if (tty_paranoia_check(tty, inode, "tty_release_dev"))
 		return;
 
 	check_tty_count(tty, "tty_release_dev");
@@ -1741,7 +1743,7 @@ void tty_release_dev(struct file *filp)
 
 	/* Make this pty number available for reallocation */
 	if (devpts)
-		devpts_kill_index(idx);
+		devpts_kill_index(inode, idx);
 }
 
 /**
@@ -1826,7 +1828,7 @@ retry_open:
 got_driver:
 	if (!tty) {
 		/* check whether we're reopening an existing tty */
-		tty = tty_driver_lookup_tty(driver, index);
+		tty = tty_driver_lookup_tty(driver, inode, index);
 
 		if (IS_ERR(tty))
 			return PTR_ERR(tty);
Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-08-28 16:16:29.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-08-28 17:59:15.000000000 -0700
@@ -177,7 +177,7 @@ static struct dentry *get_node(int num)
 	return lookup_one_len(s, root, sprintf(s, "%d", num));
 }
 
-int devpts_new_index(void)
+int devpts_new_index(struct inode *ptmx_inode)
 {
 	int index;
 	int ida_ret;
@@ -205,14 +205,14 @@ retry:
 	return index;
 }
 
-void devpts_kill_index(int idx)
+void devpts_kill_index(struct inode *ptmx_inode, int idx)
 {
 	mutex_lock(&allocated_ptys_lock);
 	ida_remove(&allocated_ptys, idx);
 	mutex_unlock(&allocated_ptys_lock);
 }
 
-int devpts_pty_new(struct tty_struct *tty)
+int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty)
 {
 	int number = tty->index; /* tty layer puts index from devpts_new_index() in here */
 	struct tty_driver *driver = tty->driver;
@@ -245,7 +245,7 @@ int devpts_pty_new(struct tty_struct *tt
 	return 0;
 }
 
-struct tty_struct *devpts_get_tty(int number)
+struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 {
 	struct dentry *dentry = get_node(number);
 	struct tty_struct *tty;
@@ -262,8 +262,9 @@ struct tty_struct *devpts_get_tty(int nu
 	return tty;
 }
 
-void devpts_pty_kill(int number)
+void devpts_pty_kill(struct tty_struct *tty)
 {
+	int number = tty->index;
 	struct dentry *dentry = get_node(number);
 
 	if (!IS_ERR(dentry)) {
Index: linux-2.6.27-rc3-tty/include/linux/devpts_fs.h
===================================================================
--- linux-2.6.27-rc3-tty.orig/include/linux/devpts_fs.h	2008-08-28 16:16:29.000000000 -0700
+++ linux-2.6.27-rc3-tty/include/linux/devpts_fs.h	2008-08-28 16:17:04.000000000 -0700
@@ -17,20 +17,31 @@
 
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(void);
-void devpts_kill_index(int idx);
-int devpts_pty_new(struct tty_struct *tty);      /* mknod in devpts */
-struct tty_struct *devpts_get_tty(int number);	 /* get tty structure */
-void devpts_pty_kill(int number);		 /* unlink */
+int devpts_new_index(struct inode *ptmx_inode);
+void devpts_kill_index(struct inode *ptmx_inode, int idx);
+/* mknod in devpts */
+int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
+/* get tty structure */
+struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number);
+/* unlink */
+void devpts_pty_kill(struct tty_struct *tty);
 
 #else
 
 /* Dummy stubs in the no-pty case */
-static inline int devpts_new_index(void) { return -EINVAL; }
-static inline void devpts_kill_index(int idx) { }
-static inline int devpts_pty_new(struct tty_struct *tty) { return -EINVAL; }
-static inline struct tty_struct *devpts_get_tty(int number) { return NULL; }
-static inline void devpts_pty_kill(int number) { }
+static inline int devpts_new_index(struct inode *ptmx_inode) { return -EINVAL; }
+static inline void devpts_kill_index(struct inode *ptmx_inode, int idx) { }
+static inline int devpts_pty_new(struct inode *ptmx_inode,
+				struct tty_struct *tty)
+{
+	return -EINVAL;
+}
+static inline struct tty_struct *devpts_get_tty(struct inode *pts_inode,
+		int number)
+{
+	return NULL;
+}
+static inline void devpts_pty_kill(struct tty_struct *tty) { }
 
 #endif
 
Index: linux-2.6.27-rc3-tty/include/linux/tty_driver.h
===================================================================
--- linux-2.6.27-rc3-tty.orig/include/linux/tty_driver.h	2008-08-28 16:16:29.000000000 -0700
+++ linux-2.6.27-rc3-tty/include/linux/tty_driver.h	2008-08-28 16:17:04.000000000 -0700
@@ -225,7 +225,8 @@ struct tty_struct;
 struct tty_driver;
 
 struct tty_operations {
-	struct tty_struct * (*lookup)(struct tty_driver *driver, int idx);
+	struct tty_struct * (*lookup)(struct tty_driver *driver,
+			struct inode *inode, int idx);
 	int  (*install)(struct tty_driver *driver, struct tty_struct *tty);
 	void (*remove)(struct tty_driver *driver, struct tty_struct *tty);
 	int  (*open)(struct tty_struct * tty, struct file * filp);
