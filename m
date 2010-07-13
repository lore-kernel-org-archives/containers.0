From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/8] checkpoint: clean up __SI_FAULT siginfo save/restore
Date: Tue, 13 Jul 2010 10:44:21 -0500
Message-ID: <1279035864-10533-6-git-send-email-ntl@pobox.com>
References: <1279035864-10533-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1279035864-10533-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

ckpt_siginfo now has addr and trapno fields, so use them for the
__SI_FAULT case.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 kernel/signal.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index df9b7be..de85c35 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2933,9 +2933,9 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 		si->csi_fd = info->si_fd;
 		break;
 	case __SI_FAULT:
-		si->csi_ptr = (unsigned long) info->si_addr;
+		si->csi_addr = (unsigned long)info->si_addr;
 #ifdef __ARCH_SI_TRAPNO
-		si->csi_int = info->si_trapno;
+		si->csi_trapno = info->si_trapno;
 #endif
 		break;
 	case __SI_CHLD:
@@ -2982,9 +2982,9 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 		info->si_fd = si->csi_fd;
 		break;
 	case __SI_FAULT:
-		info->si_addr = (void __user *) (unsigned long) si->csi_ptr;
+		info->si_addr = (void __user *)(unsigned long)si->csi_addr;
 #ifdef __ARCH_SI_TRAPNO
-		info->si_trapno = si->csi_int;
+		info->si_trapno = si->csi_trapno;
 #endif
 		break;
 	case __SI_CHLD:
-- 
1.7.1.1
