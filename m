From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 2/8]: Add inode parameter devpts interfaces
Date: Wed, 20 Aug 2008 19:26:44 -0700
Message-ID: <20080821022644.GB29658@us.ibm.com>
References: <20080821022126.GA29449@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080821022126.GA29449-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 2/8]: Add inode parameter devpts interfaces

Pass-in an 'inode' parameter to devpts interfaces.  The parameter
itself will be used in subsequent patches to identify the instance
of devpts mounted.

---
 drivers/char/pty.c        |    3 ++-
 drivers/char/tty_io.c     |   21 +++++++++++----------
 fs/devpts/inode.c         |   10 +++++-----
 include/linux/devpts_fs.h |   34 ++++++++++++++++++++++++----------
 4 files changed, 42 insertions(+), 26 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-20 12:33:21.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-20 12:34:38.000000000 -0700
@@ -177,7 +177,7 @@ static struct dentry *get_node(int num)
 	return lookup_one_len(s, root, sprintf(s, "%d", num));
 }
 
-int devpts_new_index(void)
+int devpts_new_index(struct inode *inode)
 {
 	int index;
 	int idr_ret;
@@ -205,14 +205,14 @@ retry:
 	return index;
 }
 
-void devpts_kill_index(int idx)
+void devpts_kill_index(struct inode *inode, int idx)
 {
 	mutex_lock(&allocated_ptys_lock);
 	idr_remove(&allocated_ptys, idx);
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
+struct tty_struct *devpts_get_tty(struct inode *inode, int number)
 {
 	struct dentry *dentry = get_node(number);
 	struct tty_struct *tty;
@@ -262,7 +262,7 @@ struct tty_struct *devpts_get_tty(int nu
 	return tty;
 }
 
-void devpts_pty_kill(int number)
+void devpts_pty_kill(struct inode *inode, int number)
 {
 	struct dentry *dentry = get_node(number);
 
Index: linux-2.6.26-rc8-mm1/include/linux/devpts_fs.h
===================================================================
--- linux-2.6.26-rc8-mm1.orig/include/linux/devpts_fs.h	2008-08-20 12:33:21.000000000 -0700
+++ linux-2.6.26-rc8-mm1/include/linux/devpts_fs.h	2008-08-20 12:34:38.000000000 -0700
@@ -17,20 +17,34 @@
 
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(void);
-void devpts_kill_index(int idx);
-int devpts_pty_new(struct tty_struct *tty);      /* mknod in devpts */
-struct tty_struct *devpts_get_tty(int number);	 /* get tty structure */
-void devpts_pty_kill(int number);		 /* unlink */
+int devpts_new_index(struct inode *inode);
+void devpts_kill_index(struct inode *inode, int idx);
+
+/* mknod in devpts */
+int devpts_pty_new(struct inode *inode, struct tty_struct *tty);
+
+/* get tty structure */
+struct tty_struct *devpts_get_tty(struct inode *inode, int number);
+
+/* unlink */
+void devpts_pty_kill(struct inode *inode, int number);
 
 #else
 
 /* Dummy stubs in the no-pty case */
-static inline int devpts_new_index(void) { return -EINVAL; }
-static inline void devpts_kill_index(int idx) { }
-static inline int devpts_pty_new(struct tty_struct *tty) { return -EINVAL; }
-static inline struct tty_struct *devpts_get_tty(int number) { return NULL; }
-static inline void devpts_pty_kill(int number) { }
+static inline int devpts_new_index(struct inode *inode) { return -EINVAL; }
+static inline void devpts_kill_index(struct inode *inode, int idx) { }
+
+static inline int devpts_pty_new(struc inode *inode, struct tty_struct *tty)
+{
+	return -EINVAL;
+}
+
+static inline struct tty_struct *devpts_get_tty(struct inode *inode, int number)
+{
+	return NULL;
+}
+static inline void devpts_pty_kill(struc inode *inode, int number) { }
 
 #endif
 
Index: linux-2.6.26-rc8-mm1/drivers/char/pty.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/drivers/char/pty.c	2008-08-20 12:33:21.000000000 -0700
+++ linux-2.6.26-rc8-mm1/drivers/char/pty.c	2008-08-20 12:34:38.000000000 -0700
@@ -59,7 +59,8 @@ static void pty_close(struct tty_struct 
 		set_bit(TTY_OTHER_CLOSED, &tty->flags);
 #ifdef CONFIG_UNIX98_PTYS
 		if (tty->driver == ptm_driver)
-			devpts_pty_kill(tty->index);
+			devpts_pty_kill(filp->f_path.dentry->d_inode,
+					tty->index);
 #endif
 		tty_vhangup(tty->link);
 	}
Index: linux-2.6.26-rc8-mm1/drivers/char/tty_io.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/drivers/char/tty_io.c	2008-08-20 12:34:36.000000000 -0700
+++ linux-2.6.26-rc8-mm1/drivers/char/tty_io.c	2008-08-20 12:34:38.000000000 -0700
@@ -2056,7 +2056,7 @@ static void tty_line_name(struct tty_dri
  * relaxed for the (most common) case of reopening a tty.
  */
 
-static int init_dev(struct tty_driver *driver, int idx,
+static int init_dev(struct tty_driver *driver, struct inode *inode,  int idx,
 	struct tty_struct **ret_tty)
 {
 	struct tty_struct *tty, *o_tty;
@@ -2076,7 +2076,7 @@ static int init_dev(struct tty_driver *d
 		 if (inode->i_rdev == MKDEV(TTYAUX_MAJOR, 0))
 			tty = *ret_tty;
 		else
-			tty = devpts_get_tty(idx);
+			tty = devpts_get_tty(inode, idx);
 		/*
 		 * If we don't have a tty here on a slave open, it's because
 		 * the master already started the close process and there's
@@ -2380,10 +2380,11 @@ static void release_dev(struct file *fil
 	int	idx;
 	char	buf[64];
 	unsigned long flags;
+	struct inode *inode;
 
+	inode = filp->f_path.dentry->d_inode;
 	tty = (struct tty_struct *)filp->private_data;
-	if (tty_paranoia_check(tty, filp->f_path.dentry->d_inode,
-							"release_dev"))
+	if (tty_paranoia_check(tty, inode, "release_dev"))
 		return;
 
 	check_tty_count(tty, "release_dev");
@@ -2638,7 +2639,7 @@ static void release_dev(struct file *fil
 
 	/* Make this pty number available for reallocation */
 	if (devpts)
-		devpts_kill_index(idx);
+		devpts_kill_index(inode, idx);
 }
 
 /**
@@ -2719,7 +2720,7 @@ retry_open:
 		return -ENODEV;
 	}
 got_driver:
-	retval = init_dev(driver, index, &tty);
+	retval = init_dev(driver, inode, index, &tty);
 	mutex_unlock(&tty_mutex);
 	if (retval)
 		return retval;
@@ -2811,12 +2812,12 @@ static int __ptmx_open(struct inode *ino
 	nonseekable_open(inode, filp);
 
 	/* find a device that is not in use. */
-	index = devpts_new_index();
+	index = devpts_new_index(inode);
 	if (index < 0)
 		return index;
 
 	mutex_lock(&tty_mutex);
-	retval = init_dev(ptm_driver, index, &tty);
+	retval = init_dev(ptm_driver, inode, index, &tty);
 	mutex_unlock(&tty_mutex);
 
 	if (retval)
@@ -2826,7 +2827,7 @@ static int __ptmx_open(struct inode *ino
 	filp->private_data = tty;
 	file_move(filp, &tty->tty_files);
 
-	retval = devpts_pty_new(tty->link);
+	retval = devpts_pty_new(inode, tty->link);
 	if (retval)
 		goto out1;
 
@@ -2838,7 +2839,7 @@ out1:
 	release_dev(filp);
 	return retval;
 out:
-	devpts_kill_index(index);
+	devpts_kill_index(inode, index);
 	return retval;
 }
