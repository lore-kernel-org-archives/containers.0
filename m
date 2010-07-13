From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/8] checkpoint: add const qualifiers to siginfo handlers
Date: Tue, 13 Jul 2010 10:44:18 -0500
Message-ID: <1279035864-10533-3-git-send-email-ntl@pobox.com>
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

fill_siginfo and load_siginfo both have parameters that can be const.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 kernel/signal.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 07647d7..13ab68e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2913,7 +2913,7 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
  * signal checkpoint/restart
  */
 
-static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
+static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 {
 	si->csi_signo = info->si_signo;
 	si->csi_errno = info->si_errno;
@@ -2957,7 +2957,7 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 	}
 }
 
-static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
+static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 {
 	if (!valid_signal(si->csi_signo))
 		return -EINVAL;
-- 
1.7.1.1
