From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][-mm PATCH 7/8] Memory controller OOM handling (v3)
Date: Fri, 20 Jul 2007 13:55:18 +0530
Message-ID: <20070720082518.20752.6752.sendpatchset@balbir-laptop>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Out of memory handling for containers over their limit. A task from the
container over limit is chosen using the existing OOM logic and killed.

TODO:
1. As discussed in the OLS BOF session, consider implementing a user
space policy for OOM handling.

Signed-off-by: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Signed-off-by: <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |    1 +
 mm/oom_kill.c              |   42 ++++++++++++++++++++++++++++++++++++++----
 3 files changed, 40 insertions(+), 4 deletions(-)

diff -puN include/linux/memcontrol.h~mem-control-out-of-memory include/linux/memcontrol.h
--- linux-2.6.22-rc6/include/linux/memcontrol.h~mem-control-out-of-memory	2007-07-20 13:13:26.000000000 +0530
+++ linux-2.6.22-rc6-balbir/include/linux/memcontrol.h	2007-07-20 13:13:26.000000000 +0530
@@ -38,6 +38,7 @@ extern unsigned long mem_container_isola
 					int mode, struct zone *z,
 					struct mem_container *mem_cont,
 					int active);
+extern void mem_container_out_of_memory(struct mem_container *mem);
 
 #else /* CONFIG_CONTAINER_MEM_CONT */
 static inline void mm_init_container(struct mm_struct *mm,
diff -puN mm/memcontrol.c~mem-control-out-of-memory mm/memcontrol.c
--- linux-2.6.22-rc6/mm/memcontrol.c~mem-control-out-of-memory	2007-07-20 13:13:26.000000000 +0530
+++ linux-2.6.22-rc6-balbir/mm/memcontrol.c	2007-07-20 13:13:26.000000000 +0530
@@ -272,6 +272,7 @@ int mem_container_charge(struct page *pa
 			continue;
 
 		css_put(&mem->css);
+		mem_container_out_of_memory(mem);
 		goto free_mp;
 	}
 
diff -puN mm/oom_kill.c~mem-control-out-of-memory mm/oom_kill.c
--- linux-2.6.22-rc6/mm/oom_kill.c~mem-control-out-of-memory	2007-07-20 13:13:26.000000000 +0530
+++ linux-2.6.22-rc6-balbir/mm/oom_kill.c	2007-07-20 13:13:26.000000000 +0530
@@ -24,6 +24,7 @@
 #include <linux/cpuset.h>
 #include <linux/module.h>
 #include <linux/notifier.h>
+#include <linux/memcontrol.h>
 
 int sysctl_panic_on_oom;
 /* #define DEBUG */
@@ -47,7 +48,8 @@ int sysctl_panic_on_oom;
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime)
+unsigned long badness(struct task_struct *p, unsigned long uptime,
+			struct mem_container *mem)
 {
 	unsigned long points, cpu_time, run_time, s;
 	struct mm_struct *mm;
@@ -60,6 +62,13 @@ unsigned long badness(struct task_struct
 		return 0;
 	}
 
+#ifdef CONFIG_CONTAINER_MEM_CONT
+	if (mem != NULL && mm->mem_container != mem) {
+		task_unlock(p);
+		return 0;
+	}
+#endif
+
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
@@ -204,7 +213,8 @@ static inline int constrained_alloc(stru
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned long *ppoints)
+static struct task_struct *select_bad_process(unsigned long *ppoints,
+						struct mem_container *mem)
 {
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
@@ -258,7 +268,7 @@ static struct task_struct *select_bad_pr
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec);
+		points = badness(p, uptime.tv_sec, mem);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
@@ -372,6 +382,30 @@ static int oom_kill_process(struct task_
 	return oom_kill_task(p);
 }
 
+#ifdef CONFIG_CONTAINER_MEM_CONT
+void mem_container_out_of_memory(struct mem_container *mem)
+{
+	unsigned long points = 0;
+	struct task_struct *p;
+
+	container_lock();
+	rcu_read_lock();
+retry:
+	p = select_bad_process(&points, mem);
+	if (PTR_ERR(p) == -1UL)
+		goto out;
+
+	if (!p)
+		p = current;
+
+	if (oom_kill_process(p, points, "Memory container out of memory"))
+		goto retry;
+out:
+	rcu_read_unlock();
+	container_unlock();
+}
+#endif
+
 static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
 
 int register_oom_notifier(struct notifier_block *nb)
@@ -444,7 +478,7 @@ retry:
 		 * Rambo mode: Shoot down a process and hope it solves whatever
 		 * issues we may have.
 		 */
-		p = select_bad_process(&points);
+		p = select_bad_process(&points, NULL);
 
 		if (PTR_ERR(p) == -1UL)
 			goto out;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
