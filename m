From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cpuset: rcu_read_lock() to protect task_cs() even we don't
	dereference to task_cs()'s return value
Date: Fri, 21 Nov 2008 16:49:40 +0800
Message-ID: <49267624.70305__35816.2547847771$1227264836$gmane$org@cn.fujitsu.com>
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


task_cs() calls cgroup_subsys_state().

we must use rcu_read_lock() to protect cgroup_subsys_state().

in current_cpuset_is_being_rebound(), we don't dereference to task_cs()'s
return value, but task_cs() accesses css_set, this css_set maybe freed
when task_cs() called.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3e00526..e0e087e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1141,7 +1136,11 @@ done:
 
 int current_cpuset_is_being_rebound(void)
 {
-	return task_cs(current) == cpuset_being_rebound;
+	struct cpuset *cs;
+	rcu_read_lock();
+	cs = task_cs(current);
+	rcu_read_unlock();
+	return cs == cpuset_being_rebound;
 }
 
 static int update_relax_domain_level(struct cpuset *cs, s64 val)
