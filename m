From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/11] pidns: Don't allow new processes in a dead pid
	namespace.
Date: Fri, 16 Nov 2012 08:35:45 -0800
Message-ID: <1353083750-3621-6-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Set nr_hashed to -1 just before we schedule the work to cleanup proc.
Test nr_hashed just before we hash a new pid and if nr_hashed is < 0
fail.

This guaranteees that processes never enter a pid namespaces after we
have cleaned up the state to support processes in a pid namespace.

Currently sending SIGKILL to all of the process in a pid namespace as
init exists gives us this guarantee but we need something a little
stronger to support unsharing and joining a pid namespace.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/pid.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index e957f8b..9c21911 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -274,8 +274,10 @@ void free_pid(struct pid *pid)
 	for (i = 0; i <= pid->level; i++) {
 		struct upid *upid = pid->numbers + i;
 		hlist_del_rcu(&upid->pid_chain);
-		if (--upid->ns->nr_hashed == 0)
+		if (--upid->ns->nr_hashed == 0) {
+			upid->ns->nr_hashed = -1;
 			schedule_work(&upid->ns->proc_work);
+		}
 	}
 	spin_unlock_irqrestore(&pidmap_lock, flags);
 
@@ -321,6 +323,8 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	upid = pid->numbers + ns->level;
 	spin_lock_irq(&pidmap_lock);
+	if (ns->nr_hashed < 0)
+		goto out_unlock;
 	for ( ; upid >= pid->numbers; --upid) {
 		hlist_add_head_rcu(&upid->pid_chain,
 				&pid_hash[pid_hashfn(upid->nr, upid->ns)]);
@@ -331,6 +335,8 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 out:
 	return pid;
 
+out_unlock:
+	spin_unlock(&pidmap_lock);
 out_free:
 	while (++i <= ns->level)
 		free_pidmap(pid->numbers + i);
-- 
1.7.5.4
