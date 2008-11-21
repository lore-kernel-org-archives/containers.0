From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] memcontrol: rcu_read_lock() to protect mm_match_cgroup()
Date: Fri, 21 Nov 2008 16:49:43 +0800
Message-ID: <49267627.80103__3664.05529571257$1227265144$gmane$org@cn.fujitsu.com>
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


mm_match_cgroup() calls cgroup_subsys_state().

we must use rcu_read_lock() to protect cgroup_subsys_state().

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1fbe14d..ce89ff0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -47,8 +47,15 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
-#define mm_match_cgroup(mm, cgroup)	\
-	((cgroup) == mem_cgroup_from_task((mm)->owner))
+static inline
+int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
+{
+	struct mem_cgroup *mem;
+	rcu_read_lock();
+	mem = mem_cgroup_from_task((mm)->owner);
+	rcu_read_unlock();
+	return cgroup == mem;
+}
 
 extern int
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
