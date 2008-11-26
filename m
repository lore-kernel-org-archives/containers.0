From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 3/5] ftrace: let function tracing and function return run together
Date: Wed, 26 Nov 2008 00:16:25 -0500
Message-ID: <20081126051709.953338542@goodmis.org>
References: <20081126051622.134970943@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753855AbYKZFS0@vger.kernel.org>
Content-Disposition: inline; filename=0003-ftrace-let-function-tracing-and-function-return-run.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>

Impact: feature

This patch enables function tracing and function return to run together.
I've tested this by enabling the stack tracer and return tracer, where
both the function entry and function return are used together with
dynamic ftrace.

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/ftrace.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 5f7c864..cbf8b09 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -53,9 +53,6 @@ static int ftrace_pid_trace = -1;
 /* Quick disabling of function tracer. */
 int function_trace_stop;
 
-/* By default, current tracing type is normal tracing. */
-enum ftrace_tracing_type_t ftrace_tracing_type = FTRACE_TYPE_ENTER;
-
 /*
  * ftrace_disabled is set when an anomaly is discovered.
  * ftrace_disabled is much stronger than ftrace_enabled.
@@ -1576,15 +1573,9 @@ int register_ftrace_function(struct ftrace_ops *ops)
 
 	mutex_lock(&ftrace_sysctl_lock);
 
-	if (ftrace_tracing_type == FTRACE_TYPE_RETURN) {
-		ret = -EBUSY;
-		goto out;
-	}
-
 	ret = __register_ftrace_function(ops);
 	ftrace_startup(0);
 
-out:
 	mutex_unlock(&ftrace_sysctl_lock);
 	return ret;
 }
@@ -1731,23 +1722,16 @@ int register_ftrace_graph(trace_func_graph_ret_t retfunc,
 
 	mutex_lock(&ftrace_sysctl_lock);
 
-	/*
-	 * Don't launch return tracing if normal function
-	 * tracing is already running.
-	 */
-	if (ftrace_trace_function != ftrace_stub) {
-		ret = -EBUSY;
-		goto out;
-	}
 	atomic_inc(&ftrace_graph_active);
 	ret = start_graph_tracing();
 	if (ret) {
 		atomic_dec(&ftrace_graph_active);
 		goto out;
 	}
-	ftrace_tracing_type = FTRACE_TYPE_RETURN;
+
 	ftrace_graph_return = retfunc;
 	ftrace_graph_entry = entryfunc;
+
 	ftrace_startup(FTRACE_START_FUNC_RET);
 
 out:
@@ -1763,8 +1747,6 @@ void unregister_ftrace_graph(void)
 	ftrace_graph_return = (trace_func_graph_ret_t)ftrace_stub;
 	ftrace_graph_entry = (trace_func_graph_ent_t)ftrace_stub;
 	ftrace_shutdown(FTRACE_STOP_FUNC_RET);
-	/* Restore normal tracing type */
-	ftrace_tracing_type = FTRACE_TYPE_ENTER;
 
 	mutex_unlock(&ftrace_sysctl_lock);
 }
-- 
1.5.6.5

-- 
