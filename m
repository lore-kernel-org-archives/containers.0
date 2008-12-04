From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 00:26:41 -0500
Message-ID: <20081204052735.362609481@goodmis.org>
References: <20081204052638.425740534@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753374AbYLDF2K@vger.kernel.org>
Content-Disposition: inline; filename=0003-ftrace-add-ability-to-only-trace-swapper-tasks.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <srostedt@redhat.com>

Impact: New feature

This patch lets the swapper tasks of all CPUS be filtered by the
set_ftrace_pid file.

If '0' is echoed into this file, then all the idle tasks (aka swapper)
is flagged to be traced.  This affects all CPU idle tasks.

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/ftrace.c |   74 +++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 63 insertions(+), 11 deletions(-)

diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 10b1d7c..eb57dc1 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -49,6 +49,7 @@ static int last_ftrace_enabled;
 
 /* set when tracing only a pid */
 struct pid *ftrace_pid_trace;
+static struct pid * const ftrace_swapper_pid = (struct pid *)1;
 
 /* Quick disabling of function tracer. */
 int function_trace_stop;
@@ -1678,7 +1679,9 @@ ftrace_pid_read(struct file *file, char __user *ubuf,
 	char buf[64];
 	int r;
 
-	if (ftrace_pid_trace)
+	if (ftrace_pid_trace == ftrace_swapper_pid)
+		r = sprintf(buf, "swapper tasks\n");
+	else if (ftrace_pid_trace)
 		r = sprintf(buf, "%u\n", pid_nr(ftrace_pid_trace));
 	else
 		r = sprintf(buf, "no pid\n");
@@ -1686,19 +1689,43 @@ ftrace_pid_read(struct file *file, char __user *ubuf,
 	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
 }
 
-static void clear_ftrace_pid_task(struct pid **pid)
+static void clear_ftrace_swapper(void)
 {
 	struct task_struct *p;
+	int cpu;
 
-	do_each_pid_task(*pid, PIDTYPE_PID, p) {
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		p = idle_task(cpu);
 		clear_tsk_trace_trace(p);
-	} while_each_pid_task(*pid, PIDTYPE_PID, p);
-	put_pid(*pid);
+	}
+	put_online_cpus();
+}
 
-	*pid = NULL;
+static void set_ftrace_swapper(void)
+{
+	struct task_struct *p;
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		p = idle_task(cpu);
+		set_tsk_trace_trace(p);
+	}
+	put_online_cpus();
 }
 
-static void set_ftrace_pid_task(struct pid *pid)
+static void clear_ftrace_pid(struct pid *pid)
+{
+	struct task_struct *p;
+
+	do_each_pid_task(pid, PIDTYPE_PID, p) {
+		clear_tsk_trace_trace(p);
+	} while_each_pid_task(pid, PIDTYPE_PID, p);
+	put_pid(pid);
+}
+
+static void set_ftrace_pid(struct pid *pid)
 {
 	struct task_struct *p;
 
@@ -1707,6 +1734,24 @@ static void set_ftrace_pid_task(struct pid *pid)
 	} while_each_pid_task(pid, PIDTYPE_PID, p);
 }
 
+static void clear_ftrace_pid_task(struct pid **pid)
+{
+	if (*pid == ftrace_swapper_pid)
+		clear_ftrace_swapper();
+	else
+		clear_ftrace_pid(*pid);
+
+	*pid = NULL;
+}
+
+static void set_ftrace_pid_task(struct pid *pid)
+{
+	if (pid == ftrace_swapper_pid)
+		set_ftrace_swapper();
+	else
+		set_ftrace_pid(pid);
+}
+
 static ssize_t
 ftrace_pid_write(struct file *filp, const char __user *ubuf,
 		   size_t cnt, loff_t *ppos)
@@ -1737,11 +1782,18 @@ ftrace_pid_write(struct file *filp, const char __user *ubuf,
 		clear_ftrace_pid_task(&ftrace_pid_trace);
 
 	} else {
-		pid = find_get_pid(val);
+		/* swapper task is special */
+		if (!val) {
+			pid = ftrace_swapper_pid;
+			if (pid == ftrace_pid_trace)
+				goto out;
+		} else {
+			pid = find_get_pid(val);
 
-		if (pid == ftrace_pid_trace) {
-			put_pid(pid);
-			goto out;
+			if (pid == ftrace_pid_trace) {
+				put_pid(pid);
+				goto out;
+			}
 		}
 
 		if (ftrace_pid_trace)
-- 
1.5.6.5

-- 
