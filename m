From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 3/3] ftrace: trace single pid for function graph tracer
Date: Wed, 03 Dec 2008 15:36:59 -0500
Message-ID: <20081203203829.362295724@goodmis.org>
References: <20081203203656.776893226@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758660AbYLCUmU@vger.kernel.org>
Content-Disposition: inline; filename=0003-ftrace-trace-single-pid-for-function-graph-tracer.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <srostedt@redhat.com>

Impact: New feature

This patch makes the changes to set_ftrace_pid apply to the function
graph tracer.

 # echo $$ > /debugfs/tracing/set_ftrace_pid
 # echo function_graph > /debugfs/tracing/current_tracer

Will cause only the current task to be traced. Note, the trace flags are
also inherited by child processes, so the children of the shell
will also be traced.

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/ftrace.c |    2 +-
 kernel/trace/trace.c  |    3 +++
 kernel/trace/trace.h  |   10 ++++++++++
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index c5049f5..57592a9 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -48,7 +48,7 @@ int ftrace_enabled __read_mostly;
 static int last_ftrace_enabled;
 
 /* set when tracing only a pid */
-static int ftrace_pid_trace = -1;
+int ftrace_pid_trace = -1;
 
 /* Quick disabling of function tracer. */
 int function_trace_stop;
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 710b39a..1bd9574 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -1209,6 +1209,9 @@ int trace_graph_entry(struct ftrace_graph_ent *trace)
 	int cpu;
 	int pc;
 
+	if (!ftrace_trace_task(current))
+		return 0;
+
 	if (!ftrace_graph_addr(trace->func))
 		return 0;
 
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 41f026b..95fff37 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -541,6 +541,16 @@ print_graph_function(struct trace_iterator *iter)
 }
 #endif /* CONFIG_FUNCTION_GRAPH_TRACER */
 
+extern int ftrace_pid_trace;
+
+static inline int ftrace_trace_task(struct task_struct *task)
+{
+	if (ftrace_pid_trace < 0)
+		return 1;
+
+	return test_tsk_trace_trace(task);
+}
+
 /*
  * trace_iterator_flags is an enumeration that defines bit
  * positions into trace_flags that controls the output.
-- 
1.5.6.5

-- 
