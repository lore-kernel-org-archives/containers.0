From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 04 Dec 2008 00:26:40 -0500
Message-ID: <20081204052735.175697908@goodmis.org>
References: <20081204052638.425740534@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756383AbYLDF2v@vger.kernel.org>
Content-Disposition: inline; filename=0002-ftrace-use-struct-pid.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <srostedt@redhat.com>

Impact: clean up

Eric Biederman suggested using the struct pid for filtering on
pids in the kernel. This patch is based off of a demonstration
of an implementation that Eric sent me in an email.

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/ftrace.c |   76 ++++++++++++++++++++++++++++--------------------
 kernel/trace/trace.h  |    4 +-
 2 files changed, 46 insertions(+), 34 deletions(-)

diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 57592a9..10b1d7c 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -48,7 +48,7 @@ int ftrace_enabled __read_mostly;
 static int last_ftrace_enabled;
 
 /* set when tracing only a pid */
-int ftrace_pid_trace = -1;
+struct pid *ftrace_pid_trace;
 
 /* Quick disabling of function tracer. */
 int function_trace_stop;
@@ -153,7 +153,7 @@ static int __register_ftrace_function(struct ftrace_ops *ops)
 		else
 			func = ftrace_list_func;
 
-		if (ftrace_pid_trace >= 0) {
+		if (ftrace_pid_trace) {
 			set_ftrace_pid_function(func);
 			func = ftrace_pid_func;
 		}
@@ -209,7 +209,7 @@ static int __unregister_ftrace_function(struct ftrace_ops *ops)
 		if (ftrace_list->next == &ftrace_list_end) {
 			ftrace_func_t func = ftrace_list->func;
 
-			if (ftrace_pid_trace >= 0) {
+			if (ftrace_pid_trace) {
 				set_ftrace_pid_function(func);
 				func = ftrace_pid_func;
 			}
@@ -239,7 +239,7 @@ static void ftrace_update_pid_func(void)
 
 	func = ftrace_trace_function;
 
-	if (ftrace_pid_trace >= 0) {
+	if (ftrace_pid_trace) {
 		set_ftrace_pid_function(func);
 		func = ftrace_pid_func;
 	} else {
@@ -1678,18 +1678,40 @@ ftrace_pid_read(struct file *file, char __user *ubuf,
 	char buf[64];
 	int r;
 
-	if (ftrace_pid_trace >= 0)
-		r = sprintf(buf, "%u\n", ftrace_pid_trace);
+	if (ftrace_pid_trace)
+		r = sprintf(buf, "%u\n", pid_nr(ftrace_pid_trace));
 	else
 		r = sprintf(buf, "no pid\n");
 
 	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
 }
 
+static void clear_ftrace_pid_task(struct pid **pid)
+{
+	struct task_struct *p;
+
+	do_each_pid_task(*pid, PIDTYPE_PID, p) {
+		clear_tsk_trace_trace(p);
+	} while_each_pid_task(*pid, PIDTYPE_PID, p);
+	put_pid(*pid);
+
+	*pid = NULL;
+}
+
+static void set_ftrace_pid_task(struct pid *pid)
+{
+	struct task_struct *p;
+
+	do_each_pid_task(pid, PIDTYPE_PID, p) {
+		set_tsk_trace_trace(p);
+	} while_each_pid_task(pid, PIDTYPE_PID, p);
+}
+
 static ssize_t
 ftrace_pid_write(struct file *filp, const char __user *ubuf,
 		   size_t cnt, loff_t *ppos)
 {
+	struct pid *pid;
 	char buf[64];
 	long val;
 	int ret;
@@ -1707,40 +1729,30 @@ ftrace_pid_write(struct file *filp, const char __user *ubuf,
 		return ret;
 
 	mutex_lock(&ftrace_start_lock);
-	if (ret < 0) {
+	if (val < 0) {
 		/* disable pid tracing */
-		if (ftrace_pid_trace < 0)
+		if (!ftrace_pid_trace)
 			goto out;
-		ftrace_pid_trace = -1;
+
+		clear_ftrace_pid_task(&ftrace_pid_trace);
 
 	} else {
-		struct task_struct *p;
-		int found = 0;
+		pid = find_get_pid(val);
 
-		if (ftrace_pid_trace == val)
+		if (pid == ftrace_pid_trace) {
+			put_pid(pid);
 			goto out;
-
-		/*
-		 * Find the task that matches this pid.
-		 * TODO: use pid namespaces instead.
-		 */
-		rcu_read_lock();
-		for_each_process(p) {
-			if (p->pid == val) {
-				found = 1;
-				set_tsk_trace_trace(p);
-			} else if (test_tsk_trace_trace(p))
-				clear_tsk_trace_trace(p);
 		}
-		rcu_read_unlock();
 
-		if (found)
-			ftrace_pid_trace = val;
-		else {
-			if (ftrace_pid_trace < 0)
-				goto out;
-			ftrace_pid_trace = -1;
-		}
+		if (ftrace_pid_trace)
+			clear_ftrace_pid_task(&ftrace_pid_trace);
+
+		if (!pid)
+			goto out;
+
+		ftrace_pid_trace = pid;
+
+		set_ftrace_pid_task(ftrace_pid_trace);
 	}
 
 	/* update the function call */
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 95fff37..8b81b4d 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -541,11 +541,11 @@ print_graph_function(struct trace_iterator *iter)
 }
 #endif /* CONFIG_FUNCTION_GRAPH_TRACER */
 
-extern int ftrace_pid_trace;
+extern struct pid *ftrace_pid_trace;
 
 static inline int ftrace_trace_task(struct task_struct *task)
 {
-	if (ftrace_pid_trace < 0)
+	if (ftrace_pid_trace)
 		return 1;
 
 	return test_tsk_trace_trace(task);
-- 
1.5.6.5

-- 
