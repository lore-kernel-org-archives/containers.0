From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: fix incorrect using rcu_dereference() in
	cgroup_subsys_state()
Date: Fri, 21 Nov 2008 16:49:34 +0800
Message-ID: <4926761E.8030002__12743.0766974159$1227258394$gmane$org@cn.fujitsu.com>
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


It's task->cgroups protected by RCU. and struct css_set.subsys[subsys_id]
is readonly(after init). so we don't need rcu_dereference() for
struct css_set.subsys[subsys_id].

the ways using cgroup_subsys_state() safely:

#1:
rcu_read_lock() / task_lock();
c = cgroup_subsys_state(tsk, id);
use c;
rcu_read_unlock() / task_unlock();


#2: use cgroup_lock() for _current_ task.
cgroup_lock();
c = cgroup_subsys_state(current, id);
use c;
cgroup_unlock();

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1164963..22901ff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -359,10 +360,15 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
 	return cgrp->subsys[subsys_id];
 }
 
+/* Caller must hold task_lock() or rcu_read_lock() */
 static inline struct cgroup_subsys_state *task_subsys_state(
 	struct task_struct *task, int subsys_id)
 {
-	return rcu_dereference(task->cgroups->subsys[subsys_id]);
+	/*
+	 * ->subsys[subsys_id] are read-only data, so we do not need
+	 * rcu_dereference() for it.
+	 */
+	return rcu_dereference(task->cgroups)->subsys[subsys_id];
 }
 
 static inline struct cgroup* task_cgroup(struct task_struct *task,
