From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] cgroups: enhance task_cgroup()
Date: Fri, 21 Nov 2008 16:49:46 +0800
Message-ID: <4926762A.7000602__31200.3566803925$1227264965$gmane$org@cn.fujitsu.com>
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


task_cgroup() calls cgroup_subsys_state().
and we must use rcu_read_lock() to protect cgroup_subsys_state().
so we must use rcu_read_lock() to protect task_cgroup().

but it'll not so friendly to caller: the callers of task_cgroup() have
held cgroup_lock(). it means that struct cgroup will not be freed.

So this patch add rcu_read_lock() in task_cgroup() to enhance task_cgroup().
And we do NOT NEED FIX task_cgroup()'s callers, and cgroup_lock()
can protect task_cgroup().

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1164963..22901ff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -359,6 +360,10 @@
 static inline struct cgroup* task_cgroup(struct task_struct *task,
 					       int subsys_id)
 {
-	return task_subsys_state(task, subsys_id)->cgroup;
+	struct cgroup *ret;
+	rcu_read_lock();
+	ret = task_subsys_state(task, subsys_id)->cgroup;
+	rcu_read_unlock();
+	return ret;
 }
 
 int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *ss,
