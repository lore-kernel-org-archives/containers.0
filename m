From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] perf events: Cleanup pid passing
Date: Mon, 13 Sep 2010 13:01:20 -0700
Message-ID: <a134e5e392ab0204961fd1a62c84a222bf5874a9.1284407763.git.matthltc__19030.5726290264$1284408161$gmane$org@us.ibm.com>
References: <1284408080-2135-1-git-send-email-matthltc@us.ibm.com>
	<f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc@us.ibm.com>
	<561205417b450b8a4bf7488374541d64b4690431.1284407762.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <561205417b450b8a4bf7488374541d64b4690431.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Mahesh Salgaonkar <mahesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Robin Green <greenrd-tZez7oB1z75AfugRpC6u6w@public.gmane.org>, Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The kernel perf event creation path shouldn't use find_task_by_vpid()
because a vpid exists in a specific namespace. find_task_by_vpid() uses
current's pid namespace which isn't always the correct namespace to use
for the vpid in all the places perf_event_create_kernel_counter() (and
thus find_get_context()) is called.

The goal is to clean up pid namespace handling and prevent bugs like:

	https://bugzilla.kernel.org/show_bug.cgi?id=17281

Instead of using pids switch find_get_context() to use task struct
pointers directly. The syscall is responsible for resolving the pid to
a task struct. This moves the pid namespace resolution into the syscall
much like every other syscall that takes pid parameters.

Cc: Robin Green <greenrd-tZez7oB1z75AfugRpC6u6w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
Cc: Mahesh Salgaonkar <mahesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/arm/oprofile/common.c |    2 +-
 include/linux/perf_event.h |    2 +-
 kernel/hw_breakpoint.c     |    5 ++---
 kernel/perf_event.c        |   23 ++++++++++++-----------
 kernel/watchdog.c          |    2 +-
 5 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/arch/arm/oprofile/common.c b/arch/arm/oprofile/common.c
index 0691176..aad63e6 100644
--- a/arch/arm/oprofile/common.c
+++ b/arch/arm/oprofile/common.c
@@ -96,7 +96,7 @@ static int op_create_counter(int cpu, int event)
 		return ret;
 
 	pevent = perf_event_create_kernel_counter(&counter_config[event].attr,
-						  cpu, -1,
+						  cpu, NULL,
 						  op_overflow_handler);
 
 	if (IS_ERR(pevent)) {
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 93bf53a..39d8860 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -902,7 +902,7 @@ extern int perf_event_release_kernel(struct perf_event *event);
 extern struct perf_event *
 perf_event_create_kernel_counter(struct perf_event_attr *attr,
 				int cpu,
-				pid_t pid,
+				struct task_struct *task,
 				perf_overflow_handler_t callback);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
diff --git a/kernel/hw_breakpoint.c b/kernel/hw_breakpoint.c
index 6122f02..3b714e8 100644
--- a/kernel/hw_breakpoint.c
+++ b/kernel/hw_breakpoint.c
@@ -433,8 +433,7 @@ register_user_hw_breakpoint(struct perf_event_attr *attr,
 			    perf_overflow_handler_t triggered,
 			    struct task_struct *tsk)
 {
-	return perf_event_create_kernel_counter(attr, -1, task_pid_vnr(tsk),
-						triggered);
+	return perf_event_create_kernel_counter(attr, -1, tsk, triggered);
 }
 EXPORT_SYMBOL_GPL(register_user_hw_breakpoint);
 
@@ -516,7 +515,7 @@ register_wide_hw_breakpoint(struct perf_event_attr *attr,
 	get_online_cpus();
 	for_each_online_cpu(cpu) {
 		pevent = per_cpu_ptr(cpu_events, cpu);
-		bp = perf_event_create_kernel_counter(attr, cpu, -1, triggered);
+		bp = perf_event_create_kernel_counter(attr, cpu, NULL, triggered);
 
 		*pevent = bp;
 
diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index 3f5309d..8477479 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -2053,15 +2053,14 @@ errout:
 }
 
 static struct perf_event_context *
-find_get_context(struct pmu *pmu, pid_t pid, int cpu)
+find_get_context(struct pmu *pmu, struct task_struct *task, int cpu)
 {
 	struct perf_event_context *ctx;
 	struct perf_cpu_context *cpuctx;
-	struct task_struct *task;
 	unsigned long flags;
 	int ctxn, err;
 
-	if (pid == -1 && cpu != -1) {
+	if (!task && cpu != -1) {
 		/* Must be root to operate on a CPU event: */
 		if (perf_paranoid_cpu() && !capable(CAP_SYS_ADMIN))
 			return ERR_PTR(-EACCES);
@@ -2084,10 +2083,6 @@ find_get_context(struct pmu *pmu, pid_t pid, int cpu)
 		return ctx;
 	}
 
-	task = find_lively_task_by_vpid(pid);
-	if (IS_ERR(task))
-		return (void*)task;
-
 	err = -EINVAL;
 	ctxn = pmu->task_ctx_nr;
 	if (ctxn < 0)
@@ -5527,6 +5522,7 @@ SYSCALL_DEFINE5(perf_event_open,
 	struct perf_event_context *ctx;
 	struct file *event_file = NULL;
 	struct file *group_file = NULL;
+	struct task_struct *task;
 	struct pmu *pmu;
 	int event_fd;
 	int fput_needed = 0;
@@ -5584,7 +5580,12 @@ SYSCALL_DEFINE5(perf_event_open,
 	/*
 	 * Get the target context (task or percpu):
 	 */
-	ctx = find_get_context(pmu, pid, cpu);
+	if (pid == -1 && cpu != -1)
+		task = NULL;
+	else
+		task = find_lively_task_by_vpid(pid);
+
+	ctx = find_get_context(pmu, task, cpu);
 	if (IS_ERR(ctx)) {
 		err = PTR_ERR(ctx);
 		goto err_group_fd;
@@ -5666,11 +5667,11 @@ err_fd:
  *
  * @attr: attributes of the counter to create
  * @cpu: cpu in which the counter is bound
- * @pid: task to profile
+ * @task: task to profile (NULL for percpu)
  */
 struct perf_event *
 perf_event_create_kernel_counter(struct perf_event_attr *attr, int cpu,
-				 pid_t pid,
+				 struct task_struct *task,
 				 perf_overflow_handler_t overflow_handler)
 {
 	struct perf_event_context *ctx;
@@ -5687,7 +5688,7 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr, int cpu,
 		goto err;
 	}
 
-	ctx = find_get_context(event->pmu, pid, cpu);
+	ctx = find_get_context(event->pmu, task, cpu);
 	if (IS_ERR(ctx)) {
 		err = PTR_ERR(ctx);
 		goto err_free;
diff --git a/kernel/watchdog.c b/kernel/watchdog.c
index fa71aeb..8ba21ca 100644
--- a/kernel/watchdog.c
+++ b/kernel/watchdog.c
@@ -358,7 +358,7 @@ static int watchdog_nmi_enable(int cpu)
 	/* Try to register using hardware perf events */
 	wd_attr = &wd_hw_attr;
 	wd_attr->sample_period = hw_nmi_get_sample_period();
-	event = perf_event_create_kernel_counter(wd_attr, cpu, -1, watchdog_overflow_callback);
+	event = perf_event_create_kernel_counter(wd_attr, cpu, NULL, watchdog_overflow_callback);
 	if (!IS_ERR(event)) {
 		printk(KERN_INFO "NMI watchdog enabled, takes one hw-pmu counter.\n");
 		goto out_save;
-- 
1.6.3.3
