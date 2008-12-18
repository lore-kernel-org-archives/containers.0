From: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 5/5] pid: use namespaced iteration on processes while managing
	priority
Date: Thu, 18 Dec 2008 22:12:33 +0530
Message-ID: <1229618553-6348-6-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229618553-6348-1-git-send-email-gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

At present we scan all processes in init namespace, while getting or setting
process priorities for a user. Incase of PID namespace, it leads to leak
priority to processes in other namespace.

Below patch proposes to use new macro controller to fix the boundary of
processes list in current namespace.

Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/sys.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 31deba8..50973de 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -181,7 +181,7 @@ asmlinkage long sys_setpriority(int which, int who, int niceval)
 				if ((who != current->uid) && !(user = find_user(who)))
 					goto out_unlock;	/* No processes for this user */
 
-			do_each_thread(g, p)
+			do_each_thread_in_ns(g, p, current->nsproxy->pid_ns)
 				if (p->uid == who)
 					error = set_one_prio(p, niceval, error);
 			while_each_thread(g, p);
@@ -243,7 +243,7 @@ asmlinkage long sys_getpriority(int which, int who)
 				if ((who != current->uid) && !(user = find_user(who)))
 					goto out_unlock;	/* No processes for this user */
 
-			do_each_thread(g, p)
+			do_each_thread_in_ns(g, p, current->nsproxy->pid_ns)
 				if (p->uid == who) {
 					niceval = 20 - task_nice(p);
 					if (niceval > retval)
-- 
1.5.5.1
