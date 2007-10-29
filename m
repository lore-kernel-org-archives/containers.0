From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org (Paul Menage)
Subject: [PATCH] Report usage in CFS cgroup
Date: Mon, 29 Oct 2007 13:19:08 -0400 (EDT)
Message-ID: <20071029171908.A4633465FDC__25343.3582060554$1193678816$gmane$org@localhost>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Report CPU usage in CFS Cgroup directories

Adds a cpu.usage file to the CFS cgroup that reports CPU usage in
milliseconds for that cgroup's tasks

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 kernel/sched.c |   36 +++++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

Index: container-2.6.23-mm1/kernel/sched.c
===================================================================
--- container-2.6.23-mm1.orig/kernel/sched.c
+++ container-2.6.23-mm1/kernel/sched.c
@@ -7005,15 +7005,41 @@ static u64 cpu_shares_read_uint(struct c
 	return (u64) tg->shares;
 }
 
-static struct cftype cpu_shares = {
-	.name = "shares",
-	.read_uint = cpu_shares_read_uint,
-	.write_uint = cpu_shares_write_uint,
+static u64 cpu_usage_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct task_group *tg = cgroup_tg(cgrp);
+	int i;
+	u64 res = 0;
+	for_each_possible_cpu(i) {
+		unsigned long flags;
+		/*
+		 * Lock to prevent races with updating 64-bit counters
+		 * on 32-bit arches.
+		 */
+		spin_lock_irqsave(&cpu_rq(i)->lock, flags);
+		res += tg->se[i]->sum_exec_runtime;
+		spin_unlock_irqrestore(&cpu_rq(i)->lock, flags);
+	}
+	/* Convert from ns to ms */
+	do_div(res, 1000000);
+	return res;
+}
+
+static struct cftype cpu_files[] = {
+	{
+		.name = "shares",
+		.read_uint = cpu_shares_read_uint,
+		.write_uint = cpu_shares_write_uint,
+	},
+	{
+		.name = "usage",
+		.read_uint = cpu_usage_read,
+	},
 };
 
 static int cpu_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	return cgroup_add_file(cont, ss, &cpu_shares);
+	return cgroup_add_files(cont, ss, cpu_files, ARRAY_SIZE(cpu_files));
 }
 
 struct cgroup_subsys cpu_cgroup_subsys = {
