From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: use task_lock() for access tsk->cgroups safe in
	cgroup_clone()
Date: Fri, 21 Nov 2008 16:49:55 +0800
Message-ID: <49267633.8040607__41795.5391611487$1227264604$gmane$org@cn.fujitsu.com>
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


use task_lock() protect tsk->cgroups and get_css_set(tsk->cgroups)


Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2933,6 +2943,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 		mutex_unlock(&cgroup_mutex);
 		return 0;
 	}
+	task_lock(tsk);
 	cg = tsk->cgroups;
 	parent = task_cgroup(tsk, subsys->subsys_id);
 
@@ -2941,6 +2952,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 
 	/* Keep the cgroup alive */
 	get_css_set(cg);
+	task_unlock(tsk);
 	mutex_unlock(&cgroup_mutex);
 
 	/* Now do the VFS work to create a cgroup */
