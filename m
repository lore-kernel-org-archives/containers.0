From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 3/3] Rename and change init_dev() prototype
Date: Mon, 25 Aug 2008 13:23:44 -0700
Message-ID: <20080825202344.GB318@us.ibm.com>
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
Subject: [RFC][PATCH 3/3] Rename and change init_dev() prototype

init_dev() takes an additional '*ret_tty' parameter so it can either return
a valid 'tty_struct *' (on success) or an integer error code on failure.

Drop the '*ret_tty' and return either a tty_struct * or ERR_PTR().

Also since init_dev() now only handles the (slow) open of a _new_ tty,
rename to alloc_init_dev().

---
 drivers/char/tty_io.c |   56 ++++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 26 deletions(-)

Index: linux-next/drivers/char/tty_io.c
===================================================================
--- linux-next.orig/drivers/char/tty_io.c	2008-08-25 12:54:35.000000000 -0700
+++ linux-next/drivers/char/tty_io.c	2008-08-25 12:56:30.000000000 -0700
@@ -1290,7 +1290,7 @@ static int fast_tty_open(struct tty_stru
 }
 
 /**
- *	init_dev		-	initialise a tty device
+ *	alloc_init_dev		-	alloc/initialise a new tty device
  *	@driver: tty driver we are opening a device on
  *	@idx: device index
  *	@ret_tty: returned tty structure
@@ -1314,20 +1314,19 @@ static int fast_tty_open(struct tty_stru
  * relaxed for the (most common) case of reopening a tty.
  */
 
-static int init_dev(struct tty_driver *driver, int idx,
-	struct tty_struct **ret_tty, int first_ok)
+static struct tty_struct *alloc_init_dev(struct tty_driver *driver, int idx,
+	int first_ok)
 {
-	struct tty_struct *tty, *o_tty;
+	struct tty_struct *tty, *o_tty, *ret_tty;
 	struct ktermios *tp, **tp_loc, *o_tp, **o_tp_loc;
 	struct ktermios *ltp, **ltp_loc, *o_ltp, **o_ltp_loc;
-	int retval = 0;
+	int err;
 
 	/* Check if pty master is being opened multiple times */
+	ret_tty = ERR_PTR(-EIO);
 	if (driver->subtype == PTY_TYPE_MASTER &&
-		(driver->flags & TTY_DRIVER_DEVPTS_MEM) && !first_ok) {
-		retval = -EIO;
+		(driver->flags & TTY_DRIVER_DEVPTS_MEM) && !first_ok)
 		goto end_init;
-	}
 	/*
 	 * First time open is complex, especially for PTY devices.
 	 * This code guarantees that either everything succeeds and the
@@ -1336,10 +1335,9 @@ static int init_dev(struct tty_driver *d
 	 * and locked termios may be retained.)
 	 */
 
-	if (!try_module_get(driver->owner)) {
-		retval = -ENODEV;
+	ret_tty = ERR_PTR(-ENODEV);
+	if (!try_module_get(driver->owner))
 		goto end_init;
-	}
 
 	o_tty = NULL;
 	tp = o_tp = NULL;
@@ -1348,6 +1346,7 @@ static int init_dev(struct tty_driver *d
 	tty = alloc_tty_struct();
 	if (!tty)
 		goto fail_no_mem;
+
 	initialize_tty_struct(tty);
 	tty->driver = driver;
 	tty->ops = driver->ops;
@@ -1458,16 +1457,15 @@ static int init_dev(struct tty_driver *d
 	 * to decrement the use counts, as release_tty doesn't care.
 	 */
 
-	retval = tty_ldisc_setup(tty, o_tty);
-
-	if (retval)
+	err = tty_ldisc_setup(tty, o_tty);
+	if (err)
 		goto release_mem_out;
 
-	*ret_tty = tty;
+	ret_tty = tty;
 
 	/* All paths come through here to release the mutex */
 end_init:
-	return retval;
+	return ret_tty;
 
 	/* Release locally allocated memory ... nothing placed in slots */
 free_mem_out:
@@ -1482,13 +1480,13 @@ free_mem_out:
 
 fail_no_mem:
 	module_put(driver->owner);
-	retval = -ENOMEM;
+	ret_tty = ERR_PTR(-ENOMEM);
 	goto end_init;
 
 	/* call the tty release_tty routine to clean out this slot */
 release_mem_out:
 	if (printk_ratelimit())
-		printk(KERN_INFO "init_dev: ldisc open failed, "
+		printk(KERN_INFO "alloc_init_dev: ldisc open failed, "
 				 "clearing slot %d\n", idx);
 	release_tty(tty, idx);
 	goto end_init;
@@ -1910,8 +1908,11 @@ got_driver:
 
 	if (tty)
 		retval = fast_tty_open(tty);
-	else
-		retval = init_dev(driver, index, &tty, 0);
+	else {
+		tty = alloc_init_dev(driver, index, 0);
+		if (IS_ERR(tty))
+			retval = PTR_ERR(tty);
+	}
 
 	mutex_unlock(&tty_mutex);
 
@@ -2007,7 +2008,7 @@ static struct tty_struct *find_open_tty(
  *
  *	Allocate a unix98 pty master device from the ptmx driver.
  *
- *	Locking: tty_mutex protects the find_open_tty and init_dev work.
+ *	Locking: tty_mutex protects the find_open_tty and alloc_init_dev work.
  *		tty->count should protect the rest.
  *		allocated_ptys_lock handles the list of free pty numbers
  */
@@ -2033,15 +2034,18 @@ static int __ptmx_open(struct inode *ino
 	 *	 old init_dev().
 	 */
 	tty = find_open_tty(ptm_driver, index);
-	if (IS_ERR(tty))
-		retval = PTR_ERR(tty);
-	else if (!tty)
-		retval = init_dev(ptm_driver, index, &tty, 1);
+
+	if (!tty)
+		tty = alloc_init_dev(ptm_driver, index, 1);
 
 	mutex_unlock(&tty_mutex);
 
-	if (retval)
+	BUG_ON(tty == NULL);	/* TODO: remove */
+
+	if (IS_ERR(tty)) {
+		retval = PTR_ERR(tty);
 		goto out;
+	}
 
 	set_bit(TTY_PTY_LOCK, &tty->flags); /* LOCK THE SLAVE */
 	filp->private_data = tty;
