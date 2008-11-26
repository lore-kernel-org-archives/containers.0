From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 5/5] ftrace: add cpu annotation for function graph tracer
Date: Wed, 26 Nov 2008 00:16:27 -0500
Message-ID: <20081126051710.339437727@goodmis.org>
References: <20081126051622.134970943@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754154AbYKZFTA@vger.kernel.org>
Content-Disposition: inline; filename=0005-ftrace-add-cpu-annotation-for-function-graph-tracer.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>

Impact: enhancement for function graph tracer

When run on a SMP box, the function graph tracer is confusing because
it shows the different CPUS as changes in the trace.

This patch adds the annotation of 'CPU[###]' where ### is a three digit
number. The output will look similar to this:

CPU[001]     dput() {
CPU[000] } 726
CPU[001]     } 487
CPU[000] do_softirq() {
CPU[001]   } 2221
CPU[000]   __do_softirq() {
CPU[000]     __local_bh_disable() {
CPU[001]   unroll_tree_refs() {
CPU[000]     } 569
CPU[001]   } 501
CPU[000]     rcu_process_callbacks() {
CPU[001]   kfree() {

What makes this nice is that now you can grep the file and produce
readable format for a particular CPU.

 # cat /debug/tracing/trace > /tmp/trace
 # grep '^CPU\[000\]' /tmp/trace > /tmp/trace0
 # grep '^CPU\[001\]' /tmp/trace > /tmp/trace1

Will give you:

 # head /tmp/trace0
CPU[000] ------------8<---------- thread sshd-3899 ------------8<----------
CPU[000]     inotify_dentry_parent_queue_event() {
CPU[000]     } 2531
CPU[000]     inotify_inode_queue_event() {
CPU[000]     } 505
CPU[000]   } 69626
CPU[000] } 73089
CPU[000] audit_syscall_exit() {
CPU[000]   path_put() {
CPU[000]     dput() {

 # head /tmp/trace1
CPU[001] ------------8<---------- thread pcscd-3446 ------------8<----------
CPU[001]               } 4186
CPU[001]               dput() {
CPU[001]               } 543
CPU[001]               vfs_permission() {
CPU[001]                 inode_permission() {
CPU[001]                   shmem_permission() {
CPU[001]                     generic_permission() {
CPU[001]                     } 501
CPU[001]                   } 2205

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/trace_functions_graph.c |   34 ++++++++++++++++++++++------------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/kernel/trace/trace_functions_graph.c b/kernel/trace/trace_functions_graph.c
index bbb81e7..d31d695 100644
--- a/kernel/trace/trace_functions_graph.c
+++ b/kernel/trace/trace_functions_graph.c
@@ -28,7 +28,7 @@ static struct tracer_flags tracer_flags = {
 };
 
 /* pid on the last trace processed */
-static pid_t last_pid = -1;
+static pid_t last_pid[NR_CPUS] = { [0 ... NR_CPUS-1] = -1 };
 
 static int graph_trace_init(struct trace_array *tr)
 {
@@ -53,29 +53,34 @@ static void graph_trace_reset(struct trace_array *tr)
 }
 
 /* If the pid changed since the last trace, output this event */
-static int verif_pid(struct trace_seq *s, pid_t pid)
+static int verif_pid(struct trace_seq *s, pid_t pid, int cpu)
 {
 	char *comm;
 
-	if (last_pid != -1 && last_pid == pid)
+	if (last_pid[cpu] != -1 && last_pid[cpu] == pid)
 		return 1;
 
-	last_pid = pid;
+	last_pid[cpu] = pid;
 	comm = trace_find_cmdline(pid);
 
-	return trace_seq_printf(s, "\n------------8<---------- thread %s-%d"
+	return trace_seq_printf(s, "\nCPU[%03d]"
+				    " ------------8<---------- thread %s-%d"
 				    " ------------8<----------\n\n",
-				    comm, pid);
+				    cpu, comm, pid);
 }
 
 static enum print_line_t
 print_graph_entry(struct ftrace_graph_ent *call, struct trace_seq *s,
-		struct trace_entry *ent)
+		  struct trace_entry *ent, int cpu)
 {
 	int i;
 	int ret;
 
-	if (!verif_pid(s, ent->pid))
+	if (!verif_pid(s, ent->pid, cpu))
+		return TRACE_TYPE_PARTIAL_LINE;
+
+	ret = trace_seq_printf(s, "CPU[%03d] ", cpu);
+	if (!ret)
 		return TRACE_TYPE_PARTIAL_LINE;
 
 	for (i = 0; i < call->depth * TRACE_GRAPH_INDENT; i++) {
@@ -96,12 +101,16 @@ print_graph_entry(struct ftrace_graph_ent *call, struct trace_seq *s,
 
 static enum print_line_t
 print_graph_return(struct ftrace_graph_ret *trace, struct trace_seq *s,
-		   struct trace_entry *ent)
+		   struct trace_entry *ent, int cpu)
 {
 	int i;
 	int ret;
 
-	if (!verif_pid(s, ent->pid))
+	if (!verif_pid(s, ent->pid, cpu))
+		return TRACE_TYPE_PARTIAL_LINE;
+
+	ret = trace_seq_printf(s, "CPU[%03d] ", cpu);
+	if (!ret)
 		return TRACE_TYPE_PARTIAL_LINE;
 
 	for (i = 0; i < trace->depth * TRACE_GRAPH_INDENT; i++) {
@@ -137,12 +146,13 @@ print_graph_function(struct trace_iterator *iter)
 	case TRACE_GRAPH_ENT: {
 		struct ftrace_graph_ent_entry *field;
 		trace_assign_type(field, entry);
-		return print_graph_entry(&field->graph_ent, s, entry);
+		return print_graph_entry(&field->graph_ent, s, entry,
+					 iter->cpu);
 	}
 	case TRACE_GRAPH_RET: {
 		struct ftrace_graph_ret_entry *field;
 		trace_assign_type(field, entry);
-		return print_graph_return(&field->ret, s, entry);
+		return print_graph_return(&field->ret, s, entry, iter->cpu);
 	}
 	default:
 		return TRACE_TYPE_UNHANDLED;
-- 
1.5.6.5

-- 
