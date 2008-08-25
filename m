From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 1/3] Move parts of init_dev() into new functions
Date: Mon, 25 Aug 2008 13:11:10 -0700
Message-ID: <20080825201110.GA32440@us.ibm.com>
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
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


init_dev() is doing too many things all in one function, making it
harder to understand/extend. This and following two patches attempt
to simplify/cleanup the interface a bit.

Only touch tested at this point. Appreciate any comments :-)

---

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 1/3] Move parts of init_dev() into new functions

Move the 'find-tty' and 'fast-track-open' parts of init_dev() to
separate functions.
---
 drivers/char/tty_io.c |  140 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 89 insertions(+), 51 deletions(-)

Index: linux-next/drivers/char/tty_io.c
===================================================================
--- linux-next.orig/drivers/char/tty_io.c	2008-08-25 11:57:15.000000000 -0700
+++ linux-next/drivers/char/tty_io.c	2008-08-25 12:31:15.000000000 -0700
@@ -1213,6 +1213,82 @@ static void tty_line_name(struct tty_dri
 	sprintf(p, "%s%d", driver->name, index + driver->name_base);
 }
 
+/*
+ * 	find_tty() - find an existing tty, if any
+ * 	@driver: the driver for the tty
+ * 	@idx:	 the minor number
+ *
+ * 	Return the tty, if found or ERR_PTR() otherwise.
+ *
+ * 	Locking: tty_mutex must be held. If tty is found, the mutex must
+ * 		 be held until the 'fast-open' is also done.
+ */
+struct tty_struct *find_tty(struct tty_driver *driver, int idx)
+{
+	struct tty_struct *tty;
+
+	/* check whether we're reopening an existing tty */
+	if (driver->flags & TTY_DRIVER_DEVPTS_MEM) {
+		tty = devpts_get_tty(idx);
+		/*
+		 * If we don't have a tty here on a slave open, it's because
+		 * the master already started the close process and there's
+		 * no relation between devpts file and tty anymore.
+		 */
+		if (!tty && driver->subtype == PTY_TYPE_SLAVE)
+			return ERR_PTR(-EIO);
+
+		/*
+		 * tty is safe on because we are called with tty_mutex held
+		 * and release_dev() won't change tty->count or tty->flags
+		 * without grabbing tty_mutex.
+		 */
+		if (tty && driver->subtype == PTY_TYPE_MASTER)
+			tty = tty->link;
+	} else {
+		tty = driver->ttys[idx];
+	}
+
+	return tty;
+}
+
+/*
+ * 	fast_tty_open()	- fast re-open of an open tty
+ * 	@tty	- the tty to open
+ *
+ * 	Return 0 on success, -errno on error.
+ *
+ * 	Locking: tty_mutex must be held from the time the tty was found
+ * 		 till this open completes.
+ */
+static int fast_tty_open(struct tty_struct *tty)
+{
+	struct tty_driver *driver = tty->driver;
+
+	if (test_bit(TTY_CLOSING, &tty->flags))
+		return -EIO;
+
+	if (driver->type == TTY_DRIVER_TYPE_PTY &&
+	    driver->subtype == PTY_TYPE_MASTER) {
+		/*
+		 * special case for PTY masters: only one open permitted,
+		 * and the slave side open count is incremented as well.
+		 */
+		if (tty->count)
+			return -EIO;
+
+		tty->link->count++;
+	}
+	tty->count++;
+	tty->driver = driver; /* N.B. why do this every time?? */
+
+	/* FIXME */
+	if (!test_bit(TTY_LDISC, &tty->flags))
+		printk(KERN_ERR "fast_tty_open: no ldisc\n");
+
+	return 0;
+}
+
 /**
  *	init_dev		-	initialise a tty device
  *	@driver: tty driver we are opening a device on
@@ -1246,30 +1322,21 @@ static int init_dev(struct tty_driver *d
 	struct ktermios *ltp, **ltp_loc, *o_ltp, **o_ltp_loc;
 	int retval = 0;
 
-	/* check whether we're reopening an existing tty */
-	if (driver->flags & TTY_DRIVER_DEVPTS_MEM) {
-		tty = devpts_get_tty(idx);
-		/*
-		 * If we don't have a tty here on a slave open, it's because
-		 * the master already started the close process and there's
-		 * no relation between devpts file and tty anymore.
-		 */
-		if (!tty && driver->subtype == PTY_TYPE_SLAVE) {
-			retval = -EIO;
-			goto end_init;
-		}
-		/*
-		 * It's safe from now on because init_dev() is called with
-		 * tty_mutex held and release_dev() won't change tty->count
-		 * or tty->flags without having to grab tty_mutex
-		 */
-		if (tty && driver->subtype == PTY_TYPE_MASTER)
-			tty = tty->link;
-	} else {
-		tty = driver->ttys[idx];
+	tty = find_tty(driver, idx);
+	if (IS_ERR(tty)) {
+		retval = PTR_ERR(tty);
+		goto end_init;
 	}
-	if (tty) goto fast_track;
 
+	if (tty) {
+		retval = fast_tty_open(tty);
+		if (retval)
+			return retval;
+		*ret_tty = tty;
+		return 0;
+	}
+
+	/* Check if pty master is being opened multiple times */
 	if (driver->subtype == PTY_TYPE_MASTER &&
 		(driver->flags & TTY_DRIVER_DEVPTS_MEM) && !first_ok) {
 		retval = -EIO;
@@ -1411,35 +1478,6 @@ static int init_dev(struct tty_driver *d
 		goto release_mem_out;
 	goto success;
 
-	/*
-	 * This fast open can be used if the tty is already open.
-	 * No memory is allocated, and the only failures are from
-	 * attempting to open a closing tty or attempting multiple
-	 * opens on a pty master.
-	 */
-fast_track:
-	if (test_bit(TTY_CLOSING, &tty->flags)) {
-		retval = -EIO;
-		goto end_init;
-	}
-	if (driver->type == TTY_DRIVER_TYPE_PTY &&
-	    driver->subtype == PTY_TYPE_MASTER) {
-		/*
-		 * special case for PTY masters: only one open permitted,
-		 * and the slave side open count is incremented as well.
-		 */
-		if (tty->count) {
-			retval = -EIO;
-			goto end_init;
-		}
-		tty->link->count++;
-	}
-	tty->count++;
-	tty->driver = driver; /* N.B. why do this every time?? */
-
-	/* FIXME */
-	if (!test_bit(TTY_LDISC, &tty->flags))
-		printk(KERN_ERR "init_dev but no ldisc\n");
 success:
 	*ret_tty = tty;
