From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr]: Fix C/R of termios
Date: Wed, 22 Dec 2010 01:15:59 -0800
Message-ID: <20101222091559.GA32053@us.ibm.com>
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

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 10 Dec 2010 18:36:34 -0800
Subject: [PATCH 1/1] Fix C/R of termios

The kernel uses 'struct ktermios' to represent the terminal attributes.
We should checkpoint and restart the 'struct ktermios' object rather
than the 'struct termio'.

Signed-off-by: Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
---
 arch/powerpc/include/asm/checkpoint_hdr.h |    6 +++---
 arch/x86/include/asm/checkpoint_hdr.h     |    6 +++---
 drivers/char/tty_io.c                     |    8 ++++++--
 include/linux/checkpoint_hdr.h            |   14 ++++++++------
 kernel/checkpoint/checkpoint.c            |    2 +-
 kernel/checkpoint/restart.c               |    2 +-
 6 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
index fbb1705..d2e6096 100644
--- a/arch/powerpc/include/asm/checkpoint_hdr.h
+++ b/arch/powerpc/include/asm/checkpoint_hdr.h
@@ -5,7 +5,7 @@
 
 /* arch dependent constants */
 #define CKPT_ARCH_NSIG 64
-#define CKPT_TTY_NCC  10
+#define CKPT_TTY_NCCS  19
 
 #ifdef __KERNEL__
 
@@ -15,8 +15,8 @@
 #endif
 
 #include <linux/tty.h>
-#if CKPT_TTY_NCC != NCC
-#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#if CKPT_TTY_NCCS != NCCS
+#error CKPT_TTY_NCCS size is wrong per asm/termbits.h
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 0505329..3ac9d29 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -54,7 +54,7 @@ enum {
 
 /* arch dependent constants */
 #define CKPT_ARCH_NSIG  64
-#define CKPT_TTY_NCC  8
+#define CKPT_TTY_NCCS	19
 
 #ifdef __KERNEL__
 
@@ -64,8 +64,8 @@ enum {
 #endif
 
 #include <linux/tty.h>
-#if CKPT_TTY_NCC != NCC
-#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#if CKPT_TTY_NCCS != NCCS
+#error CKPT_TTY_NCCS size is wrong per asm-generic/termbits.h
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 3a2c770..857d43a 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2882,7 +2882,9 @@ static int checkpoint_tty(struct ckpt_ctx *ctx, void *ptr)
 	h->termios.c_oflag = tty->termios->c_oflag;
 	h->termios.c_cflag = tty->termios->c_cflag;
 	h->termios.c_lflag = tty->termios->c_lflag;
-	memcpy(h->termios.c_cc, tty->termios->c_cc, NCC);
+	memcpy(h->termios.c_cc, tty->termios->c_cc, NCCS);
+	h->termios.c_ispeed = tty->termios->c_ispeed;
+	h->termios.c_ospeed = tty->termios->c_ospeed;
 	h->winsize.ws_row = tty->winsize.ws_row;
 	h->winsize.ws_col = tty->winsize.ws_col;
 	h->winsize.ws_ypixel = tty->winsize.ws_ypixel;
@@ -3099,7 +3101,9 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	tty->termios->c_oflag = h->termios.c_oflag;
 	tty->termios->c_cflag = h->termios.c_cflag;
 	tty->termios->c_lflag = h->termios.c_lflag;
-	memcpy(tty->termios->c_cc, h->termios.c_cc, NCC);
+	memcpy(tty->termios->c_cc, h->termios.c_cc, NCCS);
+	tty->termios->c_ispeed = h->termios.c_ispeed;
+	tty->termios->c_ospeed = h->termios.c_ospeed;
 	tty->winsize.ws_row = h->winsize.ws_row;
 	tty->winsize.ws_col = h->winsize.ws_col;
 	tty->winsize.ws_ypixel = h->winsize.ws_ypixel;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4303235..2f10011 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -317,7 +317,7 @@ struct ckpt_const {
 	__u16 rlimit_nlimits;
 	/* tty */
 	__u16 n_tty_buf_size;
-	__u16 tty_termios_ncc;
+	__u16 tty_termios_nccs;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -1138,12 +1138,14 @@ struct ckpt_hdr_tty {
 
 	/* termios */
 	struct {
-		__u16 c_iflag;
-		__u16 c_oflag;
-		__u16 c_cflag;
-		__u16 c_lflag;
+		__u32 c_iflag;
+		__u32 c_oflag;
+		__u32 c_cflag;
+		__u32 c_lflag;
 		__u8 c_line;
-		__u8 c_cc[CKPT_TTY_NCC];
+		__u8 c_cc[CKPT_TTY_NCCS];
+		__u32 c_ispeed;
+		__u32 c_ospeed;
 	} __attribute__((aligned(8))) termios;
 
 	/* winsize */
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 55f4dc2..853de1b 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -128,7 +128,7 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->rlimit_nlimits = RLIM_NLIMITS;
 	/* tty */
 	h->n_tty_buf_size = N_TTY_BUF_SIZE;
-	h->tty_termios_ncc = NCC;
+	h->tty_termios_nccs = NCCS;
 }
 
 /* write the checkpoint header */
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 17270b8..0e359c2 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -593,7 +593,7 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* tty */
 	if (h->n_tty_buf_size != N_TTY_BUF_SIZE)
 		return -EINVAL;
-	if (h->tty_termios_ncc != NCC)
+	if (h->tty_termios_nccs != NCCS)
 		return -EINVAL;
 
 	return 0;
-- 
1.6.0.4
