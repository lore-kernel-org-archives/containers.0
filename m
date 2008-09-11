From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: ptem01 LTP failure in ttydev-0909
Date: Thu, 11 Sep 2008 13:11:59 -0700
Message-ID: <20080911201159.GA17071@us.ibm.com>
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
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Alan,

LTP testcases/kernel/pty/ptem01 is failing on ttydev-0909. The test
passed on ttydev-0828.

The test changes the window size using the slave-fd and expects that
it won't affect the window-size on master-fd. With this change, we
return the slave's window size and test fails.

I suspect that it is due to following change in ttydev.  

Is the test bogus now ?

Suka


commit 4f0fa9c9e6557442b583a687066bebd607246220
Author: Alan Cox <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:   Mon Sep 8 13:49:19 2008 -0700

    tty: Termios locking - sort out real_tty confusions and lock reads

    This moves us towards sanity and should mean our termios locking is now
    complete and comprehensive.

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 69b1766..7eabfbb 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2595,7 +2595,7 @@ long tty_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
        case TIOCSTI:
                return tiocsti(tty, p);
        case TIOCGWINSZ:
-               return tiocgwinsz(tty, p);
+               return tiocgwinsz(real_tty, p);
