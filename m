From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/5] ftrace: use code patching for ftrace graph tracer
Date: Wed, 26 Nov 2008 00:16:24 -0500
Message-ID: <20081126051709.774546196@goodmis.org>
References: <20081126051622.134970943@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753241AbYKZFSn@vger.kernel.org>
Content-Disposition: inline; filename=0002-ftrace-use-code-patching-for-ftrace-graph-tracer.patch
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>

Impact: more efficient code for ftrace graph tracer

This patch uses the dynamic patching, when available, to patch
the function graph code into the kernel.

This patch will ease the way for letting both function tracing
and function graph tracing run together.

Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 arch/x86/kernel/entry_32.S |    5 ++++
 arch/x86/kernel/ftrace.c   |   48 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/ftrace.h     |    5 ++++
 kernel/trace/ftrace.c      |   35 ++++++++++++++-----------------
 4 files changed, 72 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index 71cdda1..37feecf 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -1185,6 +1185,11 @@ ftrace_call:
 	popl %edx
 	popl %ecx
 	popl %eax
+#ifdef CONFIG_FUNCTION_GRAPH_TRACER
+.globl ftrace_graph_call
+ftrace_graph_call:
+	jmp ftrace_stub
+#endif
 
 .globl ftrace_stub
 ftrace_stub:
diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 26b2d92..7ef914e 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -111,7 +111,6 @@ static void ftrace_mod_code(void)
 	 */
 	mod_code_status = probe_kernel_write(mod_code_ip, mod_code_newcode,
 					     MCOUNT_INSN_SIZE);
-
 }
 
 void ftrace_nmi_enter(void)
@@ -325,7 +324,51 @@ int __init ftrace_dyn_arch_init(void *data)
 
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 
-#ifndef CONFIG_DYNAMIC_FTRACE
+#ifdef CONFIG_DYNAMIC_FTRACE
+extern void ftrace_graph_call(void);
+
+static int ftrace_mod_jmp(unsigned long ip,
+			  int old_offset, int new_offset)
+{
+	unsigned char code[MCOUNT_INSN_SIZE];
+
+	if (probe_kernel_read(code, (void *)ip, MCOUNT_INSN_SIZE))
+		return -EFAULT;
+
+	if (code[0] != 0xe9 || old_offset != *(int *)(&code[1]))
+		return -EINVAL;
+
+	*(int *)(&code[1]) = new_offset;
+
+	if (do_ftrace_mod_code(ip, &code))
+		return -EPERM;
+
+	return 0;
+}
+
+int ftrace_enable_ftrace_graph_caller(void)
+{
+	unsigned long ip = (unsigned long)(&ftrace_graph_call);
+	int old_offset, new_offset;
+
+	old_offset = (unsigned long)(&ftrace_stub) - (ip + MCOUNT_INSN_SIZE);
+	new_offset = (unsigned long)(&ftrace_graph_caller) - (ip + MCOUNT_INSN_SIZE);
+
+	return ftrace_mod_jmp(ip, old_offset, new_offset);
+}
+
+int ftrace_disable_ftrace_graph_caller(void)
+{
+	unsigned long ip = (unsigned long)(&ftrace_graph_call);
+	int old_offset, new_offset;
+
+	old_offset = (unsigned long)(&ftrace_graph_caller) - (ip + MCOUNT_INSN_SIZE);
+	new_offset = (unsigned long)(&ftrace_stub) - (ip + MCOUNT_INSN_SIZE);
+
+	return ftrace_mod_jmp(ip, old_offset, new_offset);
+}
+
+#else /* CONFIG_DYNAMIC_FTRACE */
 
 /*
  * These functions are picked from those used on
@@ -343,6 +386,7 @@ void ftrace_nmi_exit(void)
 {
 	atomic_dec(&in_nmi);
 }
+
 #endif /* !CONFIG_DYNAMIC_FTRACE */
 
 /* Add a function return address to the trace stack on thread info.*/
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index fc2d549..f9792c0 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -117,6 +117,11 @@ extern void ftrace_call(void);
 extern void mcount_call(void);
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 extern void ftrace_graph_caller(void);
+extern int ftrace_enable_ftrace_graph_caller(void);
+extern int ftrace_disable_ftrace_graph_caller(void);
+#else
+static inline int ftrace_enable_ftrace_graph_caller(void) { return 0; }
+static inline int ftrace_disable_ftrace_graph_caller(void) { return 0; }
 #endif
 
 /**
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 00d98c6..5f7c864 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -281,6 +281,8 @@ enum {
 	FTRACE_UPDATE_TRACE_FUNC	= (1 << 2),
 	FTRACE_ENABLE_MCOUNT		= (1 << 3),
 	FTRACE_DISABLE_MCOUNT		= (1 << 4),
+	FTRACE_START_FUNC_RET		= (1 << 5),
+	FTRACE_STOP_FUNC_RET		= (1 << 6),
 };
 
 static int ftrace_filtered;
@@ -465,14 +467,7 @@ __ftrace_replace_code(struct dyn_ftrace *rec, int enable)
 	unsigned long ip, fl;
 	unsigned long ftrace_addr;
 
-#ifdef CONFIG_FUNCTION_GRAPH_TRACER
-	if (ftrace_tracing_type == FTRACE_TYPE_ENTER)
-		ftrace_addr = (unsigned long)ftrace_caller;
-	else
-		ftrace_addr = (unsigned long)ftrace_graph_caller;
-#else
 	ftrace_addr = (unsigned long)ftrace_caller;
-#endif
 
 	ip = rec->ip;
 
@@ -605,6 +600,11 @@ static int __ftrace_modify_code(void *data)
 	if (*command & FTRACE_UPDATE_TRACE_FUNC)
 		ftrace_update_ftrace_func(ftrace_trace_function);
 
+	if (*command & FTRACE_START_FUNC_RET)
+		ftrace_enable_ftrace_graph_caller();
+	else if (*command & FTRACE_STOP_FUNC_RET)
+		ftrace_disable_ftrace_graph_caller();
+
 	return 0;
 }
 
@@ -629,10 +629,8 @@ static void ftrace_startup_enable(int command)
 	ftrace_run_update_code(command);
 }
 
-static void ftrace_startup(void)
+static void ftrace_startup(int command)
 {
-	int command = 0;
-
 	if (unlikely(ftrace_disabled))
 		return;
 
@@ -645,10 +643,8 @@ static void ftrace_startup(void)
 	mutex_unlock(&ftrace_start_lock);
 }
 
-static void ftrace_shutdown(void)
+static void ftrace_shutdown(int command)
 {
-	int command = 0;
-
 	if (unlikely(ftrace_disabled))
 		return;
 
@@ -1453,8 +1449,9 @@ device_initcall(ftrace_nodyn_init);
 
 static inline int ftrace_init_dyn_debugfs(struct dentry *d_tracer) { return 0; }
 static inline void ftrace_startup_enable(int command) { }
-# define ftrace_startup()		do { } while (0)
-# define ftrace_shutdown()		do { } while (0)
+/* Keep as macros so we do not need to define the commands */
+# define ftrace_startup(command)	do { } while (0)
+# define ftrace_shutdown(command)	do { } while (0)
 # define ftrace_startup_sysctl()	do { } while (0)
 # define ftrace_shutdown_sysctl()	do { } while (0)
 #endif /* CONFIG_DYNAMIC_FTRACE */
@@ -1585,7 +1582,7 @@ int register_ftrace_function(struct ftrace_ops *ops)
 	}
 
 	ret = __register_ftrace_function(ops);
-	ftrace_startup();
+	ftrace_startup(0);
 
 out:
 	mutex_unlock(&ftrace_sysctl_lock);
@@ -1604,7 +1601,7 @@ int unregister_ftrace_function(struct ftrace_ops *ops)
 
 	mutex_lock(&ftrace_sysctl_lock);
 	ret = __unregister_ftrace_function(ops);
-	ftrace_shutdown();
+	ftrace_shutdown(0);
 	mutex_unlock(&ftrace_sysctl_lock);
 
 	return ret;
@@ -1751,7 +1748,7 @@ int register_ftrace_graph(trace_func_graph_ret_t retfunc,
 	ftrace_tracing_type = FTRACE_TYPE_RETURN;
 	ftrace_graph_return = retfunc;
 	ftrace_graph_entry = entryfunc;
-	ftrace_startup();
+	ftrace_startup(FTRACE_START_FUNC_RET);
 
 out:
 	mutex_unlock(&ftrace_sysctl_lock);
@@ -1765,7 +1762,7 @@ void unregister_ftrace_graph(void)
 	atomic_dec(&ftrace_graph_active);
 	ftrace_graph_return = (trace_func_graph_ret_t)ftrace_stub;
 	ftrace_graph_entry = (trace_func_graph_ent_t)ftrace_stub;
-	ftrace_shutdown();
+	ftrace_shutdown(FTRACE_STOP_FUNC_RET);
 	/* Restore normal tracing type */
 	ftrace_tracing_type = FTRACE_TYPE_ENTER;
 
-- 
1.5.6.5

-- 
