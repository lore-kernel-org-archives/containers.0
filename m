From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/8] checkpoint: handle siginfo->si_code < 0
Date: Tue, 13 Jul 2010 10:44:24 -0500
Message-ID: <1279035864-10533-9-git-send-email-ntl@pobox.com>
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

If we checkpoint a task that has a pending signal with si_code < 0
(easily caused by raising a blocked signal) we hit the BUG() in
fill_siginfo.  In this case, we should checkpoint and restore si_pid,
si_uid, and the members of the si_val union.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 kernel/signal.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 85757e1..cc7aee9 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2920,6 +2920,25 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 	si->csi_code = info->si_code;
 
 	/* TODO: convert info->si_uid to uid_objref */
+	if (info->si_code < 0) {
+		switch(info->si_code) {
+		case SI_QUEUE:
+		case SI_TIMER:
+		case SI_MESGQ:
+		case SI_ASYNCIO:
+		case SI_SIGIO:
+		case SI_TKILL:
+		case SI_DETHREAD:
+			si->csi_pid = info->si_pid;
+			si->csi_uid = info->si_uid;
+			si->csi_ptr = (unsigned long)info->si_ptr;
+			si->csi_int = info->si_int;
+			break;
+		default:
+			BUG();
+		}
+		return;
+	}
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_KILL:
@@ -2972,6 +2991,27 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 	info->si_code = si->csi_code;
 
 	/* TODO: validate remaining signal fields */
+	if (info->si_code < 0) {
+		switch(info->si_code) {
+		case SI_QUEUE:
+		case SI_TIMER:
+		case SI_MESGQ:
+		case SI_ASYNCIO:
+		case SI_SIGIO:
+		case SI_TKILL:
+		case SI_DETHREAD:
+			info->si_pid = si->csi_pid;
+			info->si_uid = si->csi_uid;
+			info->si_ptr = (void __user *)
+				(unsigned long)si->csi_ptr;
+			info->si_int = si->csi_int;
+			break;
+		default:
+			return -EINVAL;
+			break;
+		}
+		return 0;
+	}
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_KILL:
-- 
1.7.1.1
