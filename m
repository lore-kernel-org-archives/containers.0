From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [RFC] checkpoint: handle more siginfo->si_code values
Date: Thu, 17 Jun 2010 17:37:39 -0500
Message-ID: <1276814259.6401.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I have a multithreaded testcase that easily hits the BUG() in
fill_siginfo() by raise()'ing a signal it has blocked before
checkpoint.  The value of si_code in this case is SI_TKILL.

This gets my testcase to pass, but I'm not sure it's a complete
solution...  comments?
---
 kernel/signal.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index e4ca9a6..cd25592 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2919,6 +2919,9 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 	si->_errno = info->si_errno;
 	si->code = info->si_code;
 
+	if (info->si_code < 0)
+		return;
+
 	/* TODO: convert info->si_uid to uid_objref */
 
 	switch (info->si_code & __SI_MASK) {
@@ -2953,7 +2956,8 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 		si->sigval_ptr = (unsigned long) info->si_ptr;
 		break;
 	default:
-		BUG();
+		ckpt_debug("unknown si_code 0x%x\n", info->si_code);
+		break;
 	}
 }
 
@@ -3002,7 +3006,7 @@ static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
 		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
 		break;
 	default:
-		return -EINVAL;
+		break;
 	}
 
 	return 0;
-- 
1.6.0.2
