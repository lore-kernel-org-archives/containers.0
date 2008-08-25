From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 2/3] Move some init_dev() code to callers
Date: Mon, 25 Aug 2008 13:23:14 -0700
Message-ID: <20080825202314.GA318@us.ibm.com>
References: <20080825201110.GA32440@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080825201110.GA32440-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Subject: [RFC][PATCH 2/3] Move some init_dev() code to callers

init_dev() tries to find a tty and if it finds an existing tty, does
a 'fast' open. If its not an existing tty, init_dev does a slower
first time open requiring allocation and complex initialization.

All these seem to make the code more complex. When opening /dev/tty,
the caller already has the tty so there is no need to find it. Further
the fast and slow opens in init_dev() don't really share much code
and could be in separate functions.

With only two callers, init_dev() does not really need to be that
generalized and some of the pieces can be moved into the callers.

---
 drivers/char/tty_io.c |   71 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 47 insertions(+), 24 deletions(-)

Index: linux-next/drivers/char/tty_io.c
===================================================================
--- linux-next.orig/drivers/char/tty_io.c	2008-08-25 12:31:15.000000000 -0700
+++ linux-next/drivers/char/tty_io.c	2008-08-25 12:54:35.000000000 -0700
@@ -1322,20 +1322,6 @@ static int init_dev(struct tty_driver *d
 	struct ktermios *ltp, **ltp_loc, *o_ltp, **o_ltp_loc;
 	int retval = 0;
 
-	tty = find_tty(driver, idx);
-	if (IS_ERR(tty)) {
-		retval = PTR_ERR(tty);
-		goto end_init;
-	}
-
-	if (tty) {
-		retval = fast_tty_open(tty);
-		if (retval)
-			return retval;
-		*ret_tty = tty;
-		return 0;
-	}
-
 	/* Check if pty master is being opened multiple times */
 	if (driver->subtype == PTY_TYPE_MASTER &&
 		(driver->flags & TTY_DRIVER_DEVPTS_MEM) && !first_ok) {
@@ -1476,9 +1462,7 @@ static int init_dev(struct tty_driver *d
 
 	if (retval)
 		goto release_mem_out;
-	goto success;
 
-success:
 	*ret_tty = tty;
 
 	/* All paths come through here to release the mutex */
@@ -1853,14 +1837,15 @@ static void release_dev(struct file *fil
  *	The termios state of a pty is reset on first open so that
  *	settings don't persist across reuse.
  *
- *	Locking: tty_mutex protects tty, get_tty_driver and init_dev work.
+ *	Locking: tty_mutex protects tty, get_tty_driver, find_tty,
+ *		fast_tty_open and init_dev work.
  *		 tty->count should protect the rest.
  *		 ->siglock protects ->signal/->sighand
  */
 
 static int __tty_open(struct inode *inode, struct file *filp)
 {
-	struct tty_struct *tty;
+	struct tty_struct *tty = NULL;
 	int noctty, retval;
 	struct tty_driver *driver;
 	int index;
@@ -1917,8 +1902,19 @@ retry_open:
 		return -ENODEV;
 	}
 got_driver:
-	retval = init_dev(driver, index, &tty, 0);
+	if (!tty) {
+		tty = find_tty(driver, index);
+		if (IS_ERR(tty))
+			return PTR_ERR(tty);
+	}
+
+	if (tty)
+		retval = fast_tty_open(tty);
+	else
+		retval = init_dev(driver, index, &tty, 0);
+
 	mutex_unlock(&tty_mutex);
+
 	if (retval)
 		return retval;
 
@@ -1986,8 +1982,24 @@ static int tty_open(struct inode *inode,
 }
 
 
-
 #ifdef CONFIG_UNIX98_PTYS
+
+static struct tty_struct *find_open_tty(struct tty_driver *driver, int index)
+{
+	int retval;
+	struct tty_struct *tty;
+
+	tty = find_tty(driver, index);
+	if (!tty || IS_ERR(tty))
+		return tty;
+
+	retval = fast_tty_open(tty);
+	if (retval)
+		tty = ERR_PTR(retval);
+
+	return tty;
+}
+
 /**
  *	ptmx_open		-	open a unix 98 pty master
  *	@inode: inode of device file
@@ -1995,15 +2007,15 @@ static int tty_open(struct inode *inode,
  *
  *	Allocate a unix98 pty master device from the ptmx driver.
  *
- *	Locking: tty_mutex protects theinit_dev work. tty->count should
- * 		protect the rest.
+ *	Locking: tty_mutex protects the find_open_tty and init_dev work.
+ *		tty->count should protect the rest.
  *		allocated_ptys_lock handles the list of free pty numbers
  */
 
 static int __ptmx_open(struct inode *inode, struct file *filp)
 {
 	struct tty_struct *tty;
-	int retval;
+	int retval = 0;
 	int index;
 
 	nonseekable_open(inode, filp);
@@ -2014,7 +2026,18 @@ static int __ptmx_open(struct inode *ino
 		return index;
 
 	mutex_lock(&tty_mutex);
-	retval = init_dev(ptm_driver, index, &tty, 1);
+
+	/*
+	 * TODO: We just allocated the index, will find_open_tty() ever
+	 *	 find a tty ? Keep the find for now for compatiblity with
+	 *	 old init_dev().
+	 */
+	tty = find_open_tty(ptm_driver, index);
+	if (IS_ERR(tty))
+		retval = PTR_ERR(tty);
+	else if (!tty)
+		retval = init_dev(ptm_driver, index, &tty, 1);
+
 	mutex_unlock(&tty_mutex);
 
 	if (retval)
