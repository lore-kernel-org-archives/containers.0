From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: C/R of termios
Date: Wed, 8 Dec 2010 17:28:20 -0800
Message-ID: <20101209012820.GA10001@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren,

Any reason we only checkpoint/restore a 'struct termio' instead of a
'struct termios' ?

AFAICT, 'struct termios' seems to supersede 'struct termio' (i.e includes
all fields of 'struct termio' plus more). The TCGETS ioctl and tcgetattr()
interface return a 'struct termios' to user space.

The man page termio(7) says the 'struct termio' interface is obsolete.

The kernel uses 'struct ktermios' to represent the attributes internally.
So shouldn't we checkpoint/restore the 'struct ktermios' object ?

If application uses legacy interface (TCGETA/TCSETA with 'struct termio')
the kernel converts the 'struct ktermios' to the 'struct termio' in
kernel_termios_to_user_termio(). So we should be fine if we C/R the
ktermios object right ?

Here is a quick hack, just for reference. With this hack, I can C/R an
app that does tcgetattr() of a pty before/after checkpoint.

---
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 0505329..2778aed 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -55,6 +55,7 @@ enum {
 /* arch dependent constants */
 #define CKPT_ARCH_NSIG  64
 #define CKPT_TTY_NCC  8
+#define CKPT_TTY_NCCS  19
 
 #ifdef __KERNEL__
 
@@ -68,6 +69,10 @@ enum {
 #error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
 #endif
 
+#if CKPT_TTY_NCCS != NCCS
+#error CKPT_TTY_NCCS size is wrong per asm-generic/termbits.h
+#endif
+
 #endif /* __KERNEL__ */
 
 
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 3a2c770..2b3f001 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2882,7 +2882,7 @@ static int checkpoint_tty(struct ckpt_ctx *ctx, void *ptr)
 	h->termios.c_oflag = tty->termios->c_oflag;
 	h->termios.c_cflag = tty->termios->c_cflag;
 	h->termios.c_lflag = tty->termios->c_lflag;
-	memcpy(h->termios.c_cc, tty->termios->c_cc, NCC);
+	memcpy(h->termios.c_cc, tty->termios->c_cc, NCCS);
 	h->winsize.ws_row = tty->winsize.ws_row;
 	h->winsize.ws_col = tty->winsize.ws_col;
 	h->winsize.ws_ypixel = tty->winsize.ws_ypixel;
@@ -3099,7 +3099,7 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	tty->termios->c_oflag = h->termios.c_oflag;
 	tty->termios->c_cflag = h->termios.c_cflag;
 	tty->termios->c_lflag = h->termios.c_lflag;
-	memcpy(tty->termios->c_cc, h->termios.c_cc, NCC);
+	memcpy(tty->termios->c_cc, h->termios.c_cc, NCCS);
 	tty->winsize.ws_row = h->winsize.ws_row;
 	tty->winsize.ws_col = h->winsize.ws_col;
 	tty->winsize.ws_ypixel = h->winsize.ws_ypixel;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4303235..e432b04 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -1143,7 +1143,9 @@ struct ckpt_hdr_tty {
 		__u16 c_cflag;
 		__u16 c_lflag;
 		__u8 c_line;
-		__u8 c_cc[CKPT_TTY_NCC];
+		__u8 c_cc[CKPT_TTY_NCCS];
+		__u32 c_ispeed;
+		__u32 c_ospeed;
 	} __attribute__((aligned(8))) termios;
 
 	/* winsize */
