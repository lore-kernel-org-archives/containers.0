From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Sat, 11 Jul 2009 21:30:55 +0200
Message-ID: <20090711193055.GA11303@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090708105417.GA16833-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 08, 2009 at 12:54:17PM +0200, Grzegorz Nosek wrote:
> Jul  8 13:53:52 debian kernel: [   31.429837] BUG: unable to handle kernel paging request at 6b6b6bcf
> Jul  8 13:53:52 debian kernel: [   31.429837] IP: [<c122c46c>] tty_open+0x11c/0x4b0

With the following (whitespace-damaged etc.) patch applied I can no longer
oops the kernel but there are several issues:

1. A warning occurs (after several dozen start/shutdown cycles):
Warning: dev (pts0) tty->count(2) != #fd's(1) in tty_release_dev
So refcounting is still broken and this patch possibly just papers over
the real bug.

2. There's a memory leak somewhere (don't know if it was there before as
the system hadn't survived long enough to test that) guesstimated at
several KB per container cycle; building with kmemleak to see what
happens.

3. After adding tons of debug statements I saw that the TTY objects
weren't always freed immediately after container shutdown but were
somehow batched (e.g. a single container shut down would cause two or
three previous containers' tty objects to be freed). Increasing the
delay between subsequent cycles from 3 to 10 seconds didn't seem to
affect the batching. On an otherwise unpatched kernel, the crashes
happened right after the 'batched' cleanups.

All feedback really appreciated.

Best regards,
 Grzegorz Nosek

diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index daebe1b..0ca0c1c 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -556,12 +556,23 @@ static struct tty_struct *pts_unix98_lookup(struct tty_driver *driver,
        return tty;
 }

-static void pty_unix98_shutdown(struct tty_struct *tty)
+static void ptm_unix98_shutdown(struct tty_struct *tty)
 {
        /* We have our own method as we don't use the tty index */
        kfree(tty->termios);
 }

+static void pts_unix98_shutdown(struct tty_struct *tty)
+{
+       struct inode *ino = (struct inode *)tty->driver_data;
+
+       /* We have our own method as we don't use the tty index */
+       kfree(tty->termios);
+
+       if (ino)
+               ino->i_private = NULL;
+}
+
 /* We have no need to install and remove our tty objects as devpts does all
    the work for us */

@@ -633,7 +644,7 @@ static const struct tty_operations ptm_unix98_ops = {
        .unthrottle = pty_unthrottle,
        .set_termios = pty_set_termios,
        .ioctl = pty_unix98_ioctl,
-       .shutdown = pty_unix98_shutdown,
+       .shutdown = ptm_unix98_shutdown,
        .resize = pty_resize
 };

@@ -649,7 +660,7 @@ static const struct tty_operations pty_unix98_ops = {
        .chars_in_buffer = pty_chars_in_buffer,
        .unthrottle = pty_unthrottle,
        .set_termios = pty_set_termios,
-       .shutdown = pty_unix98_shutdown
+       .shutdown = pts_unix98_shutdown
 };

 /**
