From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 7/8] checkpoint: __SI_KILL does not use si_ptr
Date: Tue, 13 Jul 2010 10:44:23 -0500
Message-ID: <1279035864-10533-8-git-send-email-ntl@pobox.com>
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

Handle __SI_KILL in its own case during siginfo save/restore; grouping
it with __SI_RT and __SI_MESGQ doesn't make sense as si_ptr use is not
implied.  See copy_siginfo_to_user, signalfd_copyinfo.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 kernel/signal.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index fccf9b6..85757e1 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2922,6 +2922,10 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 	/* TODO: convert info->si_uid to uid_objref */
 
 	switch (info->si_code & __SI_MASK) {
+	case __SI_KILL:
+		si->csi_pid = info->si_pid;
+		si->csi_uid = info->si_uid;
+		break;
 	case __SI_TIMER:
 		si->csi_tid = info->si_tid;
 		si->csi_overrun = info->si_overrun;
@@ -2945,12 +2949,11 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 		si->csi_stime = info->si_stime;
 		si->csi_utime = info->si_utime;
 		break;
-	case __SI_KILL:
 	case __SI_RT:
 	case __SI_MESGQ:
 		si->csi_pid = info->si_pid;
 		si->csi_uid = info->si_uid;
-		si->csi_ptr = (unsigned long) info->si_ptr;
+		si->csi_ptr = (unsigned long)info->si_ptr;
 		break;
 	default:
 		BUG();
@@ -2971,6 +2974,10 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 	/* TODO: validate remaining signal fields */
 
 	switch (info->si_code & __SI_MASK) {
+	case __SI_KILL:
+		info->si_pid = si->csi_pid;
+		info->si_uid = si->csi_uid;
+		break;
 	case __SI_TIMER:
 		info->si_tid = si->csi_tid;
 		info->si_overrun = si->csi_overrun;
@@ -2994,12 +3001,11 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 		info->si_stime = si->csi_stime;
 		info->si_utime = si->csi_utime;
 		break;
-	case __SI_KILL:
 	case __SI_RT:
 	case __SI_MESGQ:
 		info->si_pid = si->csi_pid;
 		info->si_uid = si->csi_uid;
-		info->si_ptr = (void __user *) (unsigned long) si->csi_ptr;
+		info->si_ptr = (void __user *)(unsigned long)si->csi_ptr;
 		break;
 	default:
 		return -EINVAL;
-- 
1.7.1.1
