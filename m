From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.7-fixes 1/2] Revert "cgroup: Remove
	task_lock() from cgroup_post_fork()"
Date: Thu, 18 Oct 2012 17:59:22 -0700
Message-ID: <20121019005922.GG13370__20009.3727944934$1350608386$gmane$org@google.com>
References: <20121008020000.GB2575@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121008020000.GB2575@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From d935a5d6832a264ce52f4257e176f4f96cbaf048 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 18 Oct 2012 17:40:30 -0700

This reverts commit 7e3aa30ac8c904a706518b725c451bb486daaae9.

The commit incorrectly assumed that fork path always performed
threadgroup_change_begin/end() and depended on that for
synchronization against task exit and cgroup migration paths instead
of explicitly grabbing task_lock().

threadgroup_change is not locked when forking a new process (as
opposed to a new thread in the same process) and even if it were it
wouldn't be effective as different processes use different threadgroup
locks.

Revert the incorrect optimization.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
LKML-Reference: <20121008020000.GB2575@localhost>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 kernel/cgroup.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d1739fc..2990dc7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4894,19 +4894,10 @@ void cgroup_post_fork(struct task_struct *child)
 	 */
 	if (use_task_css_set_links) {
 		write_lock(&css_set_lock);
-		if (list_empty(&child->cg_list)) {
-			/*
-			 * It's safe to use child->cgroups without task_lock()
-			 * here because we are protected through
-			 * threadgroup_change_begin() against concurrent
-			 * css_set change in cgroup_task_migrate(). Also
-			 * the task can't exit at that point until
-			 * wake_up_new_task() is called, so we are protected
-			 * against cgroup_exit() setting child->cgroup to
-			 * init_css_set.
-			 */
+		task_lock(child);
+		if (list_empty(&child->cg_list))
 			list_add(&child->cg_list, &child->cgroups->tasks);
-		}
+		task_unlock(child);
 		write_unlock(&css_set_lock);
 	}
 }
-- 
1.7.7.3
