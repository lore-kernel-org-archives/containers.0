From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3] c/r: [pty 2/2] support for pseudo terminals
Date: Wed, 2 Sep 2009 09:48:37 -0500
Message-ID: <20090902144837.GA15116@us.ibm.com>
References: <1250642549-23656-1-git-send-email-orenl@librato.com>
	<1250642549-23656-4-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1250642549-23656-4-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

All right, I'm not sure how to go about this - i want to have a conversation
involving patches without making it seem like I want any of the patches
pushed yet :)  To get this working on s390, I needed the two attached
patches.  Then the testcase under git://git.sr71.net/~hallyn/cr_tests.git
under cr_tests/pty/ passes with your code.

I'd still like to get a more invasive approach working where we directly
ask the pty code to create the pty with the right index.  I'm playing with
it right now, but of course having some trouble figuring out what to do
for the master end and how best to construct a filp to pass to
the main pty_create function.  I'll take a few more stabs and send out
what I have later (or announce defeat).

There is certainly something to be said for the un-invasiveness of
your approach (and that it works).

In either case, we will need to figure out how to deal with devpts
namespaces.  Perhaps we separately checkpoint a 'devpts_mnt'.  It
just stores the mountpoint of the mount.  At restart, we don't
recreate those, we just confirm that the mountpoints still exist.
Then, each pty entry has a ref to its devpts mount, and we use the
mountpoint to construct ${mountpoint}/ptmx and pass that to
filp_open() or ptmx_create)( to create the pty entry.

-serge

--M9NhX3UHpAaciwkO
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-pty-cr-s390-define-CKPT_TTY_NCC.patch"

From 552f3df7802a8833276a0aac69b92c1bce385dbf Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 1 Sep 2009 12:36:28 -0400
Subject: [PATCH 1/2] pty cr: s390: define CKPT_TTY_NCC

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index 1976355..609fc4c 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -90,6 +90,14 @@ struct ckpt_hdr_mm_context {
 #endif
 #endif
 
+#define CKPT_TTY_NCC  8
+#ifdef __KERNEL__
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#endif
+#endif
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 };
-- 
1.6.1


--M9NhX3UHpAaciwkO
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002-cr-bugfixes-of-oren-s-code.patch"

From 68b12cb69f2741052eba60658404e4eec221d112 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 1 Sep 2009 21:34:12 -0400
Subject: [PATCH 2/2] cr: bugfixes of oren's code

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/tty_io.c          |    6 +++++-
 include/linux/checkpoint_hdr.h |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 9d98bb8..b8f8d79 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2730,7 +2730,11 @@ static int checkpoint_tty_ldisc(struct ckpt_ctx *ctx, struct tty_struct *tty)
 	h->column = tty->column;
 	h->datalen = tty->read_cnt;
 	h->canon_column = tty->canon_column;
-	h->canon_datalen = tty->canon_head - tty->read_tail;
+	h->canon_datalen = tty->canon_head;
+	if (tty->canon_head > tty->read_tail)
+		h->canon_datalen -= tty->read_tail;
+	else
+		h->canon_datalen += N_TTY_BUF_SIZE - tty->read_tail;
 	h->canon_data = tty->canon_data;
 
 	datalen = tty->read_cnt;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 5febdc7..492b4d5 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -688,7 +688,7 @@ struct ckpt_hdr_ldisc_n_tty {
 	struct ckpt_hdr h;
 
 	__u32 column;
-	__u32 datalen;
+	__s32 datalen;
 	__u32 canon_column;
 	__u32 canon_datalen;
 	__u32 canon_data;
-- 
1.6.1


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--M9NhX3UHpAaciwkO--
