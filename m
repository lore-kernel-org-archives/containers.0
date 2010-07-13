From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/8] checkpoint: clean up pending posix timer signal handling
Date: Tue, 13 Jul 2010 10:44:19 -0500
Message-ID: <1279035864-10533-4-git-send-email-ntl@pobox.com>
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

Add a field to ckpt_siginfo corresponding to the si_sys_private
siginfo field.  Stop overloading unrelated fields and use the
appropriate members for timer id and overrun.

si_int is a member of union sigval, whose other member is a pointer;
saving and restoring si_int will work for 32- but not 64-bit
architectures.  Save and restore the si_ptr field instead, which will
cover the whole union.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    1 +
 kernel/signal.c                |   16 ++++++++--------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b46d586..16b1723 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -936,6 +936,7 @@ struct ckpt_siginfo {
 	__u64 csi_utime;
 	__u64 csi_stime;
 	__u64 csi_addr;
+	__s32 csi_sys_private; /* POSIX.1b timers */
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_sigpending {
diff --git a/kernel/signal.c b/kernel/signal.c
index 13ab68e..e78a08e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2923,10 +2923,10 @@ static void fill_siginfo(struct ckpt_siginfo *si, const siginfo_t *info)
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_TIMER:
-		si->csi_pid = info->si_tid;
-		si->csi_uid = info->si_overrun;
-		si->csi_int = info->si_int;
-		si->csi_utime = info->si_sys_private;
+		si->csi_tid = info->si_tid;
+		si->csi_overrun = info->si_overrun;
+		si->csi_ptr = (unsigned long)info->si_ptr;
+		si->csi_sys_private = info->si_sys_private;
 		break;
 	case __SI_POLL:
 		si->csi_pid = info->si_band;
@@ -2972,10 +2972,10 @@ static int load_siginfo(siginfo_t *info, const struct ckpt_siginfo *si)
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_TIMER:
-		info->si_tid = si->csi_pid;
-		info->si_overrun = si->csi_uid;
-		info->si_int = si->csi_int;
-		info->si_sys_private = si->csi_utime;
+		info->si_tid = si->csi_tid;
+		info->si_overrun = si->csi_overrun;
+		info->si_ptr = (void __user *)(unsigned long)si->csi_ptr;
+		info->si_sys_private = si->csi_sys_private;
 		break;
 	case __SI_POLL:
 		info->si_band = si->csi_pid;
-- 
1.7.1.1
