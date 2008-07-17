From: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] signals: replace p->pid == 1 check with a check for
	task_child_reaper
Date: Thu, 17 Jul 2008 10:56:33 -0400
Message-ID: <487F5DA1.6000107@hozac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

p->pid == 1 is insufficient when there are multiple pid namespaces.
Instead, check whether the task is in the current task's
child reaper's thread group.

Signed-off-by: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>

diff --git a/kernel/signal.c b/kernel/signal.c
index 93713a5..be932b9 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1142,10 +1142,20 @@ static int kill_something_info(int sig, struct 
siginfo *info, int pid)
  				pid ? find_vpid(-pid) : task_pgrp(current));
  	} else {
  		int retval = 0, count = 0;
-		struct task_struct * p;
+		struct task_struct *p, *reaper = task_child_reaper(current);
+
+		/*
+		 * The reaper has died, so there's probably a
+		 * SIGKILL pending. Return.
+		 */
+		if (unlikely(!reaper)) {
+			ret = -ESRCH;
+			goto out;
+		}

  		for_each_process(p) {
-			if (p->pid > 1 && !same_thread_group(p, current) &&
+			if (!same_thread_group(p, reaper) &&
+			    !same_thread_group(p, current) &&
  			    task_in_pid_ns(p, current->nsproxy->pid_ns)) {
  				int err = group_send_sig_info(sig, info, p);
  				++count;
@@ -1155,6 +1165,7 @@ static int kill_something_info(int sig, struct 
siginfo *info, int pid)
  		}
  		ret = count ? retval : -ESRCH;
  	}
+out:
  	read_unlock(&tasklist_lock);

  	return ret;
-- 
1.5.5.1
