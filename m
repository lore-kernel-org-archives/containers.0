From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH] SEND_SIG_NOINFO: Set si_pid to tgid instead of pid
Date: Tue, 16 Dec 2008 18:06:01 -0800
Message-ID: <20081217020601.GB2866@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 16 Dec 2008 17:07:17 -0800
Subject: [PATCH] SEND_SIG_NOINFO: Set si_pid to tgid instead of pid

POSIX requires the si_pid to be the process id of the sender, so ->si_pid
should really be set to 'tgid'. This change does have following changes
in behavior:

	- When sending pdeath_signal on re-parent to a sub-thread, ->si_pid
	  cannot be used to identify the thread that did the re-parent since
	  it will now show the tgid instead of thread id.

	- A multi-threaded application that expects to find the specific
	  thread that encountered a SIGPIPE using the ->si_pid will now
	  break.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/signal.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index d11e5f8..700d767 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -856,7 +856,7 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			q->info.si_signo = sig;
 			q->info.si_errno = 0;
 			q->info.si_code = SI_USER;
-			q->info.si_pid = task_pid_nr_ns(current,
+			q->info.si_pid = task_tgid_nr_ns(current,
 							task_active_pid_ns(t));
 			q->info.si_uid = current_uid();
 			break;
-- 
1.5.2.5
