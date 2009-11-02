From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 08/12] drivers/char/tty_io.c ckpt_write_err->ckpt_err
Date: Mon,  2 Nov 2009 16:23:36 -0600
Message-ID: <1257200620-15499-9-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/tty_io.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 1b220c1..5a853a3 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2622,19 +2622,19 @@ static int tty_can_checkpoint(struct ckpt_ctx *ctx, struct tty_struct *tty)
 {
 	/* only support pty driver */
 	if (tty->driver->type != TTY_DRIVER_TYPE_PTY) {
-		ckpt_write_err(ctx, "TSP", "tty: unknown driverv type %d",
+		ckpt_err(ctx, "%(T)%(S)%(P)tty: unknown driverv type %d\n",
 			       tty->driver, tty, tty->driver->type);
 		return 0;
 	}
 	/* only support unix98 style */
 	if (tty->driver->major != UNIX98_PTY_MASTER_MAJOR &&
 	    tty->driver->major != UNIX98_PTY_SLAVE_MAJOR) {
-		ckpt_write_err(ctx, "TP", "tty: legacy pty", tty);
+		ckpt_err(ctx, "%(T)%(P)tty: legacy pty\n", tty);
 		return 0;
 	}
 	/* only support n_tty ldisc */
 	if (tty->ldisc->ops->num != N_TTY) {
-		ckpt_write_err(ctx, "TSP", "tty: unknown ldisc type %d",
+		ckpt_err(ctx, "%(T)%(S)%(P)tty: unknown ldisc type %d\n",
 			       tty->ldisc->ops, tty, tty->ldisc->ops->num);
 		return 0;
 	}
@@ -2711,7 +2711,7 @@ static int tty_file_collect(struct ckpt_ctx *ctx, struct file *file)
 
 	if (tty->driver->subtype == PTY_TYPE_MASTER) {
 		if (!tty->link) {
-			ckpt_write_err(ctx, "TP", "tty: missing link\n", tty);
+			ckpt_err(ctx, "%(T)%(P)tty: missing link\n\n", tty);
 			return -EIO;
 		}
 		ckpt_debug("collecting slave tty: %p\n", tty->link);
@@ -2735,7 +2735,7 @@ static int checkpoint_tty_ldisc(struct ckpt_ctx *ctx, struct tty_struct *tty)
 	BUG_ON(tty->ldisc->ops->num != N_TTY);
 
 	if ((tty->flags & CKPT_LDISC_FLAGS) != CKPT_LDISC_GOOD) {
-		ckpt_write_err(ctx, "TP", "tty: bad ldisc flags %#lx\n",
+		ckpt_err(ctx, "%(T)%(P)tty: bad ldisc flags %#lx\n",
 			       tty, tty->flags);
 		return -EBUSY;
 	}
@@ -2808,7 +2808,7 @@ static int do_checkpoint_tty(struct ckpt_ctx *ctx, struct tty_struct *tty)
 	int ret;
 
 	if ((tty->flags & (CKPT_TTY_BAD | CKPT_TTY_GOOD)) != CKPT_TTY_GOOD) {
-		ckpt_write_err(ctx, "TP", "tty: bad flags %#lx\n",
+		ckpt_err(ctx, "%(T)%(P)tty: bad flags %#lx\n",
 			       tty, tty->flags);
 		return -EBUSY;
 	}
@@ -3035,7 +3035,7 @@ static struct tty_struct *do_restore_tty(struct ckpt_ctx *ctx)
 	if (master) {
 		file = pty_open_by_index("/dev/ptmx", h->index);
 		if (IS_ERR(file)) {
-			ckpt_write_err(ctx, "TE", "open ptmx", PTR_ERR(file));
+			ckpt_err(ctx, "%(T)%(E)Open ptmx\n", PTR_ERR(file));
 			tty = ERR_PTR(PTR_ERR(file));
 			goto out;
 		}
-- 
1.6.1
