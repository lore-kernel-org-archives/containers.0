From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 1/8]: /dev/tty tweak in init_dev()
Date: Wed, 20 Aug 2008 19:26:21 -0700
Message-ID: <20080821022621.GA29658@us.ibm.com>
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
Subject: [RFC][PATCH 1/8]: /dev/tty tweak in init_dev()

When opening /dev/tty, __tty_open() finds the tty using get_current_tty().
When __tty_open() calls init_dev() it passes in this tty in '*ret_tty'.
init_dev() ignores this and asks devpts again for the tty.  Is that really
necessary ?

The problem with asking devpts again is that with multiple mounts, devpts
cannot find the tty without knowing the specific mount instance. We can't
find the mount instance of devpts, since the inode of /dev/tty is in a
 different filesystem.

Changelog:[v2]:
	- minor change due to moving patch up in patchset
	- added comments

TODO:
	Looks ugly to use '*ret_tty' this way. Rename param or call
	get_current_tty() ?

---
 drivers/char/tty_io.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

Index: linux-2.6.26-rc8-mm1/drivers/char/tty_io.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/drivers/char/tty_io.c	2008-08-20 12:57:51.000000000 -0700
+++ linux-2.6.26-rc8-mm1/drivers/char/tty_io.c	2008-08-20 12:57:53.000000000 -0700
@@ -2066,7 +2066,17 @@ static int init_dev(struct tty_driver *d
 
 	/* check whether we're reopening an existing tty */
 	if (driver->flags & TTY_DRIVER_DEVPTS_MEM) {
-		tty = devpts_get_tty(idx);
+		/*
+		 * For /dev/tty, caller already found the tty and saved it in
+		 * *ret_tty. Avoid asking devpts for it since, with support
+		 * for multiple mounts of devpts, we  would need to know the
+		 * mount instance. And we can't (easily ?) find the mount
+		 * instance from the inode of /dev/tty.
+		 */
+		 if (inode->i_rdev == MKDEV(TTYAUX_MAJOR, 0))
+			tty = *ret_tty;
+		else
+			tty = devpts_get_tty(idx);
 		/*
 		 * If we don't have a tty here on a slave open, it's because
 		 * the master already started the close process and there's
