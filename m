From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: add lock for child->cgroups in cgroup_post_fork()
Date: Fri, 21 Nov 2008 16:49:16 +0800
Message-ID: <4926760C.3040005__11416.4101462395$1227257971$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers@lists.l>
List-Id: containers.vger.kernel.org

when cgroup_post_fork() called, child is seen by find_task_by_vpid(),
so child->cgroups maybe be changed, It'll incorrect.

child->cgroups<old>'s refcnt is decreased
child->cgroups<new>'s refcnt is increased
but child->cg_list is added to child->cgroups<old>'s list.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2823,8 +2831,10 @@ void cgroup_post_fork(struct task_struct *child)
 {
 	if (use_task_css_set_links) {
 		write_lock(&css_set_lock);
+		task_lock(child);
 		if (list_empty(&child->cg_list))
 			list_add(&child->cg_list, &child->cgroups->tasks);
+		task_unlock(child);
 		write_unlock(&css_set_lock);
 	}
 }
