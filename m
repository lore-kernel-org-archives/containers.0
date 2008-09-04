From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 1/11][v3]: Move tty lookup/reopen to tty_open
Date: Wed, 3 Sep 2008 22:29:33 -0700
Message-ID: <20080904052933.GB3680@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080904052718.GA3680-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Subject: [PATCH 1/11]: Move tty lookup/reopen to tty_open

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Move tty_driver_lookup_tty() and tty_reopen() from tty_init_dev()
into tty_open() (one of the two callers of tty_init_dev()).  These
calls are not really required in ptmx_open(), the other caller,
since ptmx_open() would be setting up a new tty.

Changelog[v2]:
	- remove the lookup and reopen calls from ptmx_open
	- merge with recent changes to ttydev tree

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 drivers/char/tty_io.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

Index: linux-2.6.27-rc3-tty/drivers/char/tty_io.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/drivers/char/tty_io.c	2008-08-28 15:26:34.000000000 -0700
+++ linux-2.6.27-rc3-tty/drivers/char/tty_io.c	2008-08-28 16:16:29.000000000 -0700
@@ -1366,19 +1366,6 @@ struct tty_struct *tty_init_dev(struct t
 	struct tty_struct *tty;
 	int retval;
 
-	/* check whether we're reopening an existing tty */
-	tty = tty_driver_lookup_tty(driver, idx);
-
-	if (IS_ERR(tty))
-		return tty;
-
-	if (tty) {
-		retval = tty_reopen(tty);
-		if (retval)
-			return ERR_PTR(retval);
-		return tty;
-	}
-
 	/* Check if pty master is being opened multiple times */
 	if (driver->subtype == PTY_TYPE_MASTER &&
 		(driver->flags & TTY_DRIVER_DEVPTS_MEM) && !first_ok)
@@ -1780,7 +1767,7 @@ void tty_release_dev(struct file *filp)
 
 static int __tty_open(struct inode *inode, struct file *filp)
 {
-	struct tty_struct *tty;
+	struct tty_struct *tty = NULL;
 	int noctty, retval;
 	struct tty_driver *driver;
 	int index;
@@ -1837,7 +1824,21 @@ retry_open:
 		return -ENODEV;
 	}
 got_driver:
-	tty = tty_init_dev(driver, index, 0);
+	if (!tty) {
+		/* check whether we're reopening an existing tty */
+		tty = tty_driver_lookup_tty(driver, index);
+
+		if (IS_ERR(tty))
+			return PTR_ERR(tty);
+	}
+
+	if (tty) {
+		retval = tty_reopen(tty);
+		if (retval)
+			tty = ERR_PTR(retval);
+	} else
+		tty = tty_init_dev(driver, index, 0);
+
 	mutex_unlock(&tty_mutex);
 	tty_driver_kref_put(driver);
 	if (IS_ERR(tty))
