From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] proc: Simplify and correct proc_flush_task
Date: Fri, 26 Oct 2007 13:43:28 -0600
Message-ID: <m1r6jhzmov.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1y7dp22d4.fsf@ebiederm.dsl.xmission.com>
	<alpine.LFD.0.999.0710261105440.30120@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LFD.0.999.0710261105440.30120-5CScLwifNT1QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
	(Linus Torvalds's message of "Fri, 26 Oct 2007 11:06:52 -0700 (PDT)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Currently we special case when we have only the initial pid namespace.
Unfortunately in doing so the copied case for the other namespaces was
broken so we don't properly flush the thread directories :(

So this patch removes the unnecessary special case (removing a
usage of proc_mnt) and corrects the flushing of the thread directories.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index aeaf0d0..a17c268 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2328,21 +2328,18 @@ out:
 
 void proc_flush_task(struct task_struct *task)
 {
-	int i, leader;
-	struct pid *pid, *tgid;
+	int i;
+	struct pid *pid, *tgid = NULL;
 	struct upid *upid;
 
-	leader = thread_group_leader(task);
-	proc_flush_task_mnt(proc_mnt, task->pid, leader ? task->tgid : 0);
 	pid = task_pid(task);
-	if (pid->level == 0)
-		return;
+	if (thread_group_leader(task))
+		tgid = task_tgid(task);
 
-	tgid = task_tgid(task);
-	for (i = 1; i <= pid->level; i++) {
+	for (i = 0; i <= pid->level; i++) {
 		upid = &pid->numbers[i];
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
-				leader ? 0 : tgid->numbers[i].nr);
+			tgid ? tgid->numbers[i].nr : 0);
 	}
 
 	upid = &pid->numbers[pid->level];
-- 
1.5.3.rc6.17.g1911
