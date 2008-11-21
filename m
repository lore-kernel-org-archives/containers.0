From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/2] cpuset: use cgroup_path() in proc_cpuset_show()
Date: Fri, 21 Nov 2008 16:49:50 +0800
Message-ID: <4926762E.9010207__21445.5007146627$1227258395$gmane$org@cn.fujitsu.com>
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


use cgroup_path() instead of
task_subsys_state(tsk, cpuset_subsys_id)->cgroup

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3e00526..e0e087e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2387,7 +2386,7 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
 	struct pid *pid;
 	struct task_struct *tsk;
 	char *buf;
-	struct cgroup_subsys_state *css;
+	struct cgroup *cgp;
 	int retval;
 
 	retval = -ENOMEM;
@@ -2403,8 +2402,8 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
 
 	retval = -EINVAL;
 	cgroup_lock();
-	css = task_subsys_state(tsk, cpuset_subsys_id);
-	retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
+	cgp = task_cgroup(tsk, cpuset_subsys_id);
+	retval = cgroup_path(cgp, buf, PAGE_SIZE);
 	if (retval < 0)
 		goto out_unlock;
 	seq_puts(m, buf);
