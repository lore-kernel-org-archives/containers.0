From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] signals: SEND_SIG_NOINFO should be considered as
	SI_FROMUSER()
Date: Sun, 4 Oct 2009 04:19:18 +0200
Message-ID: <20091004021918.GB21006@redhat.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091004021844.GA21006-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

No changes in compiled code. The patch adds the new helper, si_fromuser()
and changes check_kill_permission() to use this helper.

The real effect of this patch is that from now we "officially" consider
SEND_SIG_NOINFO signal as "from user-space" signals. This is already true
if we look at the code which uses SEND_SIG_NOINFO, except __send_signal()
has another opinion - see the next patch.

The naming of these special SEND_SIG_XXX siginfo's is really bad imho.
From __send_signal()'s pov they mean

	SEND_SIG_NOINFO		from user
	SEND_SIG_PRIV		from kernel
	SEND_SIG_FORCED		no info

Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 include/linux/sched.h |    5 -----
 kernel/signal.c       |   16 +++++++++++++---
 2 files changed, 13 insertions(+), 8 deletions(-)

--- TTT_32/include/linux/sched.h~FU_1_HELPER	2009-09-24 21:38:54.000000000 +0200
+++ TTT_32/include/linux/sched.h	2009-10-04 02:21:49.000000000 +0200
@@ -2081,11 +2081,6 @@ static inline int kill_cad_pid(int sig, 
 #define SEND_SIG_PRIV	((struct siginfo *) 1)
 #define SEND_SIG_FORCED	((struct siginfo *) 2)
 
-static inline int is_si_special(const struct siginfo *info)
-{
-	return info <= SEND_SIG_FORCED;
-}
-
 /* True if we are on the alternate signal stack.  */
 
 static inline int on_sig_stack(unsigned long sp)
--- TTT_32/kernel/signal.c~FU_1_HELPER	2009-09-24 21:38:54.000000000 +0200
+++ TTT_32/kernel/signal.c	2009-10-04 02:21:55.000000000 +0200
@@ -584,6 +584,17 @@ static int rm_from_queue(unsigned long m
 	return 1;
 }
 
+static inline int is_si_special(const struct siginfo *info)
+{
+	return info <= SEND_SIG_FORCED;
+}
+
+static inline bool si_fromuser(const struct siginfo *info)
+{
+	return info == SEND_SIG_NOINFO ||
+		(!is_si_special(info) && SI_FROMUSER(info));
+}
+
 /*
  * Bad permissions for sending the signal
  * - the caller must hold at least the RCU read lock
@@ -598,7 +609,7 @@ static int check_kill_permission(int sig
 	if (!valid_signal(sig))
 		return -EINVAL;
 
-	if (info != SEND_SIG_NOINFO && (is_si_special(info) || SI_FROMKERNEL(info)))
+	if (!si_fromuser(info))
 		return 0;
 
 	error = audit_signal_info(sig, t); /* Let audit system see the signal */
@@ -1156,8 +1167,7 @@ int kill_pid_info_as_uid(int sig, struct
 		goto out_unlock;
 	}
 	pcred = __task_cred(p);
-	if ((info == SEND_SIG_NOINFO ||
-	     (!is_si_special(info) && SI_FROMUSER(info))) &&
+	if (si_fromuser(info) &&
 	    euid != pcred->suid && euid != pcred->uid &&
 	    uid  != pcred->suid && uid  != pcred->uid) {
 		ret = -EPERM;
