From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/8] checkpoint: model ckpt_siginfo on signalfd_siginfo
Date: Tue, 13 Jul 2010 10:44:17 -0500
Message-ID: <1279035864-10533-2-git-send-email-ntl@pobox.com>
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

ckpt_siginfo doesn't cover all of the possible siginfo fields; the
current code overloads some fields (such as si_uid for si_overrun),
which is confusing.  Signed-ness on some fields is not correct either.

signalfd_siginfo is a straightforward format for representing siginfo,
so copy it and update the signal checkpoint code to use the new
fields.  Although the ckpt_siginfo struct grows, there should be no
behavioral changes.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |   28 ++++++++------
 kernel/signal.c                |   80 ++++++++++++++++++++--------------------
 2 files changed, 56 insertions(+), 52 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index c8383c0..b46d586 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -919,20 +919,24 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
-#ifndef HAVE_ARCH_SIGINFO_T
 struct ckpt_siginfo {
-	__u32 signo;
-	__u32 _errno;
-	__u32 code;
-
-	__u32 pid;
-	__s32 uid;
-	__u32 sigval_int;
-	__u64 sigval_ptr;
-	__u64 utime;
-	__u64 stime;
+	__u32 csi_signo;
+	__s32 csi_errno;
+	__s32 csi_code;
+	__u32 csi_pid;
+	__u32 csi_uid;
+	__s32 csi_fd;
+	__u32 csi_tid;
+	__u32 csi_band;
+	__u32 csi_overrun;
+	__u32 csi_trapno;
+	__s32 csi_status;
+	__s32 csi_int;
+	__u64 csi_ptr;
+	__u64 csi_utime;
+	__u64 csi_stime;
+	__u64 csi_addr;
 } __attribute__((aligned(8)));
-#endif
 
 struct ckpt_hdr_sigpending {
 	struct ckpt_hdr h;
diff --git a/kernel/signal.c b/kernel/signal.c
index e4ca9a6..07647d7 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2915,42 +2915,42 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
 
 static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 {
-	si->signo = info->si_signo;
-	si->_errno = info->si_errno;
-	si->code = info->si_code;
+	si->csi_signo = info->si_signo;
+	si->csi_errno = info->si_errno;
+	si->csi_code = info->si_code;
 
 	/* TODO: convert info->si_uid to uid_objref */
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_TIMER:
-		si->pid = info->si_tid;
-		si->uid = info->si_overrun;
-		si->sigval_int = info->si_int;
-		si->utime = info->si_sys_private;
+		si->csi_pid = info->si_tid;
+		si->csi_uid = info->si_overrun;
+		si->csi_int = info->si_int;
+		si->csi_utime = info->si_sys_private;
 		break;
 	case __SI_POLL:
-		si->pid = info->si_band;
-		si->sigval_int = info->si_fd;
+		si->csi_pid = info->si_band;
+		si->csi_int = info->si_fd;
 		break;
 	case __SI_FAULT:
-		si->sigval_ptr = (unsigned long) info->si_addr;
+		si->csi_ptr = (unsigned long) info->si_addr;
 #ifdef __ARCH_SI_TRAPNO
-		si->sigval_int = info->si_trapno;
+		si->csi_int = info->si_trapno;
 #endif
 		break;
 	case __SI_CHLD:
-		si->pid = info->si_pid;
-		si->uid = info->si_uid;
-		si->sigval_int = info->si_status;
-		si->stime = info->si_stime;
-		si->utime = info->si_utime;
+		si->csi_pid = info->si_pid;
+		si->csi_uid = info->si_uid;
+		si->csi_int = info->si_status;
+		si->csi_stime = info->si_stime;
+		si->csi_utime = info->si_utime;
 		break;
 	case __SI_KILL:
 	case __SI_RT:
 	case __SI_MESGQ:
-		si->pid = info->si_pid;
-		si->uid = info->si_uid;
-		si->sigval_ptr = (unsigned long) info->si_ptr;
+		si->csi_pid = info->si_pid;
+		si->csi_uid = info->si_uid;
+		si->csi_ptr = (unsigned long) info->si_ptr;
 		break;
 	default:
 		BUG();
@@ -2959,47 +2959,47 @@ static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 
 static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
 {
-	if (!valid_signal(si->signo))
+	if (!valid_signal(si->csi_signo))
 		return -EINVAL;
-	if (!ckpt_validate_errno(si->_errno))
+	if (!ckpt_validate_errno(si->csi_errno))
 		return -EINVAL;
 
-	info->si_signo = si->signo;
-	info->si_errno = si->_errno;
-	info->si_code = si->code;
+	info->si_signo = si->csi_signo;
+	info->si_errno = si->csi_errno;
+	info->si_code = si->csi_code;
 
 	/* TODO: validate remaining signal fields */
 
 	switch (info->si_code & __SI_MASK) {
 	case __SI_TIMER:
-		info->si_tid = si->pid;
-		info->si_overrun = si->uid;
-		info->si_int = si->sigval_int;
-		info->si_sys_private = si->utime;
+		info->si_tid = si->csi_pid;
+		info->si_overrun = si->csi_uid;
+		info->si_int = si->csi_int;
+		info->si_sys_private = si->csi_utime;
 		break;
 	case __SI_POLL:
-		info->si_band = si->pid;
-		info->si_fd = si->sigval_int;
+		info->si_band = si->csi_pid;
+		info->si_fd = si->csi_int;
 		break;
 	case __SI_FAULT:
-		info->si_addr = (void __user *) (unsigned long) si->sigval_ptr;
+		info->si_addr = (void __user *) (unsigned long) si->csi_ptr;
 #ifdef __ARCH_SI_TRAPNO
-		info->si_trapno = si->sigval_int;
+		info->si_trapno = si->csi_int;
 #endif
 		break;
 	case __SI_CHLD:
-		info->si_pid = si->pid;
-		info->si_uid = si->uid;
-		info->si_status = si->sigval_int;
-		info->si_stime = si->stime;
-		info->si_utime = si->utime;
+		info->si_pid = si->csi_pid;
+		info->si_uid = si->csi_uid;
+		info->si_status = si->csi_int;
+		info->si_stime = si->csi_stime;
+		info->si_utime = si->csi_utime;
 		break;
 	case __SI_KILL:
 	case __SI_RT:
 	case __SI_MESGQ:
-		info->si_pid = si->pid;
-		info->si_uid = si->uid;
-		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
+		info->si_pid = si->csi_pid;
+		info->si_uid = si->csi_uid;
+		info->si_ptr = (void __user *) (unsigned long) si->csi_ptr;
 		break;
 	default:
 		return -EINVAL;
-- 
1.7.1.1
