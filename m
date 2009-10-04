From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] signals: send_signal: use si_fromuser() to detect
	from_ancestor_ns
Date: Sun, 4 Oct 2009 04:19:54 +0200
Message-ID: <20091004021954.GC21006@redhat.com>
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

Change send_signal() to use si_fromuser(). From now SEND_SIG_NOINFO
triggers the "from_ancestor_ns" check.

This fixes reparent_thread()->group_send_sig_info(pdeath_signal)
behaviour, before this patch send_signal() does not detect the
cross-namespace case when the child of the dying parent belongs
to the sub-namespace.

This patch can affect the behaviour of send_sig(), kill_pgrp() and
kill_pid() when the caller sends the signal to the sub-namespace
with "priv == 0" but surprisingly all callers seem to use them
correctly, including disassociate_ctty(on_exit).

Except: drivers/staging/comedi/drivers/addi-data/*.c incorrectly
use send_sig(priv => 0). But his is minor and should be fixed
anyway.

Reported-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 kernel/signal.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- TTT_32/kernel/signal.c~FU_2_SEND_SIGNAL	2009-10-04 02:21:55.000000000 +0200
+++ TTT_32/kernel/signal.c	2009-10-04 03:09:44.000000000 +0200
@@ -928,9 +928,8 @@ static int send_signal(int sig, struct s
 	int from_ancestor_ns = 0;
 
 #ifdef CONFIG_PID_NS
-	if (!is_si_special(info) && SI_FROMUSER(info) &&
-			task_pid_nr_ns(current, task_active_pid_ns(t)) <= 0)
-		from_ancestor_ns = 1;
+	from_ancestor_ns = si_fromuser(info) &&
+			   !task_pid_nr_ns(current, task_active_pid_ns(t));
 #endif
 
 	return __send_signal(sig, info, t, group, from_ancestor_ns);
