From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 3/4] freezer_cg: use thaw_process() in unfreeze_cgroup()
Date: Tue, 21 Oct 2008 08:51:16 +0800
Message-ID: <48FD2784.30906__48734.367840416$1224550608$gmane$org@cn.fujitsu.com>
References: <48FD26F5.1070809@cn.fujitsu.com> <48FD273F.3040505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD273F.3040505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Don't duplicate the implementation of thaw_process().

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup_freezer.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 6fadafe..3ea57e4 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -275,25 +275,18 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 	return num_cant_freeze_now ? -EBUSY : 0;
 }
 
-static int unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
+static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
 {
 	struct cgroup_iter it;
 	struct task_struct *task;
 
 	cgroup_iter_start(cgroup, &it);
 	while ((task = cgroup_iter_next(cgroup, &it))) {
-		int do_wake;
-
-		task_lock(task);
-		do_wake = __thaw_process(task);
-		task_unlock(task);
-		if (do_wake)
-			wake_up_process(task);
+		thaw_process(task);
 	}
 	cgroup_iter_end(cgroup, &it);
-	freezer->state = CGROUP_THAWED;
 
-	return 0;
+	freezer->state = CGROUP_THAWED;
 }
 
 static int freezer_change_state(struct cgroup *cgroup,
@@ -320,7 +313,7 @@ static int freezer_change_state(struct cgroup *cgroup,
 		}
 		/* state == FREEZING and goal_state == THAWED, so unfreeze */
 	case CGROUP_FROZEN:
-		retval = unfreeze_cgroup(cgroup, freezer);
+		unfreeze_cgroup(cgroup, freezer);
 		break;
 	default:
 		break;
-- 
1.5.4.rc3
