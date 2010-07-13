From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/8] checkpoint: clean up __SI_CHLD siginfo save/restore
Date: Tue, 13 Jul 2010 10:44:22 -0500
Message-ID: <1279035864-10533-7-git-send-email-ntl@pobox.com>
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

ckpt_siginfo now has a field for exit status; use it.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 kernel/signal.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index de85c35..fccf9b6 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2941,7 +2941,7 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 	case __SI_CHLD:
 		si->csi_pid = info->si_pid;
 		si->csi_uid = info->si_uid;
-		si->csi_int = info->si_status;
+		si->csi_status = info->si_status;
 		si->csi_stime = info->si_stime;
 		si->csi_utime = info->si_utime;
 		break;
@@ -2990,7 +2990,7 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 	case __SI_CHLD:
 		info->si_pid = si->csi_pid;
 		info->si_uid = si->csi_uid;
-		info->si_status = si->csi_int;
+		info->si_status = si->csi_status;
 		info->si_stime = si->csi_stime;
 		info->si_utime = si->csi_utime;
 		break;
-- 
1.7.1.1
