From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: [PATCH 1/3] ftrace: graph of a single function
Date: Wed, 03 Dec 2008 15:36:57 -0500
Message-ID: <20081203203828.920111079@goodmis.org>
References: <20081203203656.776893226@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=0001-ftrace-graph-of-a-single-function.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Impact: New feature

This patch adds the file:

 /debugfs/tracing/set_graph_function

which can be used along with the function graph tracer.

When this file is empty, the function graph tracer will act as
normal. When the file has a function in it, the function graph
tracer will only trace that function.

For example:

 # echo blk_unplug > /debugfs/tracing/set_graph_function
 # cat /debugfs/tracing/trace
[...]
 ------------------------------------------
 | 2)  make-19003  =>  kjournald-2219
 ------------------------------------------

 2)               |  blk_unplug() {
 2)               |    dm_unplug_all() {
 2)               |      dm_get_table() {
 2)      1.381 us |        _read_lock();
 2)      0.911 us |        dm_table_get();
 2)      1. 76 us |        _read_unlock();
 2) +   12.912 us |      }
 2)               |      dm_table_unplug_all() {
 2)               |        blk_unplug() {
 2)      0.778 us |          generic_unplug_device();
 2)      2.409 us |        }
 2)      5.992 us |      }
 2)      0.813 us |      dm_table_put();
 2) +   29. 90 us |    }
 2) +   34.532 us |  }

You can add up to 32 functions into this file. Currently we limit it
to 32, but this may change with later improvements.

To add another function, use the append '>>':

  # echo sys_read >> /debugfs/tracing/set_graph_function
  # cat /debugfs/tracing/set_graph_function
blk_unplug
sys_read

Using the '>' will clear out the function and write new.

  # echo sys_write > /debug/tracing/set_graph_function
  # cat /debug/tracing/set_graph_function
sys_write

Note, if you have function graph running while doing this, the small
time between clearing it and updating it will cause the graph to
record all functions. This should not be an issue because after
it sets the filter, only those functions will be recorded from then on.
If you need to only record a particular function then set this
file first before starting the function graph tracer. In the future
this side effect may be corrected.

The set_graph_function file is similar to the set_ftrace_filter but
it does not take wild cards nor does it allow for more than one
function to be set with a single write. There is no technical reason why
this is the case, I just do not have the time yet to implement that.

Note, dynamic ftrace must be enabled for this to appear because it
uses the dynamic ftrace records to match the name to the mcount
call sites.

Signed-off-by: Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/ftrace.h |   46 ++++++++++
 include/linux/sched.h  |    4 +
 kernel/trace/ftrace.c  |  227 ++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace.c   |    8 ++
 kernel/trace/trace.h   |   30 ++++++-
 5 files changed, 314 insertions(+), 1 deletions(-)

diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 469ceb3..b295d31 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -7,6 +7,7 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/kallsyms.h>
+#include <linux/bitops.h>
 
 #ifdef CONFIG_FUNCTION_TRACER
 
@@ -391,4 +392,49 @@ static inline void ftrace_graph_init_task(struct task_struct *t) { }
 static inline void ftrace_graph_exit_task(struct task_struct *t) { }
 #endif
 
+#ifdef CONFIG_TRACING
+#include <linux/sched.h>
+
+/* flags for current->trace */
+enum {
+	TSK_TRACE_FL_TRACE_BIT	= 0,
+	TSK_TRACE_FL_GRAPH_BIT	= 1,
+};
+enum {
+	TSK_TRACE_FL_TRACE	= 1 << TSK_TRACE_FL_TRACE_BIT,
+	TSK_TRACE_FL_GRAPH	= 1 << TSK_TRACE_FL_GRAPH_BIT,
+};
+
+static inline void set_tsk_trace_trace(struct task_struct *tsk)
+{
+	set_bit(TSK_TRACE_FL_TRACE_BIT, &tsk->trace);
+}
+
+static inline void clear_tsk_trace_trace(struct task_struct *tsk)
+{
+	clear_bit(TSK_TRACE_FL_TRACE_BIT, &tsk->trace);
+}
+
+static inline int test_tsk_trace_trace(struct task_struct *tsk)
+{
+	return tsk->trace & TSK_TRACE_FL_TRACE;
+}
+
+static inline void set_tsk_trace_graph(struct task_struct *tsk)
+{
+	set_bit(TSK_TRACE_FL_GRAPH_BIT, &tsk->trace);
+}
+
+static inline void clear_tsk_trace_graph(struct task_struct *tsk)
+{
+	clear_bit(TSK_TRACE_FL_GRAPH_BIT, &tsk->trace);
+}
+
+static inline int test_tsk_trace_graph(struct task_struct *tsk)
+{
+	return tsk->trace & TSK_TRACE_FL_GRAPH;
+}
+
+#endif /* CONFIG_TRACING */
+
 #endif /* _LINUX_FTRACE_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 20af8cb..4a33fea 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1390,6 +1390,10 @@ struct task_struct {
 	 */
 	atomic_t trace_overrun;
 #endif
+#ifdef CONFIG_TRACING
+	/* state flags for use by tracers */
+	unsigned long trace;
+#endif
 };
 
 /*
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 65b9e86..b17a303 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -1320,6 +1320,224 @@ static struct file_operations ftrace_notrace_fops = {
 	.release = ftrace_notrace_release,
 };
 
+#ifdef CONFIG_FUNCTION_GRAPH_TRACER
+
+static DEFINE_MUTEX(graph_lock);
+
+int ftrace_graph_count;
+unsigned long ftrace_graph_funcs[FTRACE_GRAPH_MAX_FUNCS] __read_mostly;
+
+static void *
+g_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	unsigned long *array = m->private;
+	int index = *pos;
+
+	(*pos)++;
+
+	if (index >= ftrace_graph_count)
+		return NULL;
+
+	return &array[index];
+}
+
+static void *g_start(struct seq_file *m, loff_t *pos)
+{
+	void *p = NULL;
+
+	mutex_lock(&graph_lock);
+
+	p = g_next(m, p, pos);
+
+	return p;
+}
+
+static void g_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&graph_lock);
+}
+
+static int g_show(struct seq_file *m, void *v)
+{
+	unsigned long *ptr = v;
+	char str[KSYM_SYMBOL_LEN];
+
+	if (!ptr)
+		return 0;
+
+	kallsyms_lookup(*ptr, NULL, NULL, NULL, str);
+
+	seq_printf(m, "%s\n", str);
+
+	return 0;
+}
+
+static struct seq_operations ftrace_graph_seq_ops = {
+	.start = g_start,
+	.next = g_next,
+	.stop = g_stop,
+	.show = g_show,
+};
+
+static int
+ftrace_graph_open(struct inode *inode, struct file *file)
+{
+	int ret = 0;
+
+	if (unlikely(ftrace_disabled))
+		return -ENODEV;
+
+	mutex_lock(&graph_lock);
+	if ((file->f_mode & FMODE_WRITE) &&
+	    !(file->f_flags & O_APPEND)) {
+		ftrace_graph_count = 0;
+		memset(ftrace_graph_funcs, 0, sizeof(ftrace_graph_funcs));
+	}
+
+	if (file->f_mode & FMODE_READ) {
+		ret = seq_open(file, &ftrace_graph_seq_ops);
+		if (!ret) {
+			struct seq_file *m = file->private_data;
+			m->private = ftrace_graph_funcs;
+		}
+	} else
+		file->private_data = ftrace_graph_funcs;
+	mutex_unlock(&graph_lock);
+
+	return ret;
+}
+
+static ssize_t
+ftrace_graph_read(struct file *file, char __user *ubuf,
+		       size_t cnt, loff_t *ppos)
+{
+	if (file->f_mode & FMODE_READ)
+		return seq_read(file, ubuf, cnt, ppos);
+	else
+		return -EPERM;
+}
+
+static int
+ftrace_set_func(unsigned long *array, int idx, char *buffer)
+{
+	char str[KSYM_SYMBOL_LEN];
+	struct dyn_ftrace *rec;
+	struct ftrace_page *pg;
+	int found = 0;
+	int i;
+
+	if (ftrace_disabled)
+		return -ENODEV;
+
+	/* should not be called from interrupt context */
+	spin_lock(&ftrace_lock);
+
+	for (pg = ftrace_pages_start; pg; pg = pg->next) {
+		for (i = 0; i < pg->index; i++) {
+			rec = &pg->records[i];
+
+			if (rec->flags & (FTRACE_FL_FAILED | FTRACE_FL_FREE))
+				continue;
+
+			kallsyms_lookup(rec->ip, NULL, NULL, NULL, str);
+			if (strcmp(str, buffer) == 0) {
+				found = 1;
+				array[idx] = rec->ip;
+				break;
+			}
+		}
+	}
+	spin_unlock(&ftrace_lock);
+
+	return found ? 0 : -EINVAL;
+}
+
+static ssize_t
+ftrace_graph_write(struct file *file, const char __user *ubuf,
+		   size_t cnt, loff_t *ppos)
+{
+	unsigned char buffer[FTRACE_BUFF_MAX+1];
+	unsigned long *array;
+	size_t read = 0;
+	ssize_t ret;
+	int index = 0;
+	char ch;
+
+	if (!cnt || cnt < 0)
+		return 0;
+
+	mutex_lock(&graph_lock);
+
+	if (ftrace_graph_count >= FTRACE_GRAPH_MAX_FUNCS) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	if (file->f_mode & FMODE_READ) {
+		struct seq_file *m = file->private_data;
+		array = m->private;
+	} else
+		array = file->private_data;
+
+	ret = get_user(ch, ubuf++);
+	if (ret)
+		goto out;
+	read++;
+	cnt--;
+
+	/* skip white space */
+	while (cnt && isspace(ch)) {
+		ret = get_user(ch, ubuf++);
+		if (ret)
+			goto out;
+		read++;
+		cnt--;
+	}
+
+	if (isspace(ch)) {
+		*ppos += read;
+		ret = read;
+		goto out;
+	}
+
+	while (cnt && !isspace(ch)) {
+		if (index < FTRACE_BUFF_MAX)
+			buffer[index++] = ch;
+		else {
+			ret = -EINVAL;
+			goto out;
+		}
+		ret = get_user(ch, ubuf++);
+		if (ret)
+			goto out;
+		read++;
+		cnt--;
+	}
+	buffer[index] = 0;
+
+	/* we allow only one at a time */
+	ret = ftrace_set_func(array, ftrace_graph_count, buffer);
+	if (ret)
+		goto out;
+
+	ftrace_graph_count++;
+
+	file->f_pos += read;
+
+	ret = read;
+ out:
+	mutex_unlock(&graph_lock);
+
+	return ret;
+}
+
+static const struct file_operations ftrace_graph_fops = {
+	.open = ftrace_graph_open,
+	.read = ftrace_graph_read,
+	.write = ftrace_graph_write,
+};
+#endif /* CONFIG_FUNCTION_GRAPH_TRACER */
+
 static __init int ftrace_init_dyn_debugfs(struct dentry *d_tracer)
 {
 	struct dentry *entry;
@@ -1347,6 +1565,15 @@ static __init int ftrace_init_dyn_debugfs(struct dentry *d_tracer)
 		pr_warning("Could not create debugfs "
 			   "'set_ftrace_notrace' entry\n");
 
+#ifdef CONFIG_FUNCTION_GRAPH_TRACER
+	entry = debugfs_create_file("set_graph_function", 0444, d_tracer,
+				    NULL,
+				    &ftrace_graph_fops);
+	if (!entry)
+		pr_warning("Could not create debugfs "
+			   "'set_graph_function' entry\n");
+#endif /* CONFIG_FUNCTION_GRAPH_TRACER */
+
 	return 0;
 }
 
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 8b6409a..710b39a 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -1209,6 +1209,9 @@ int trace_graph_entry(struct ftrace_graph_ent *trace)
 	int cpu;
 	int pc;
 
+	if (!ftrace_graph_addr(trace->func))
+		return 0;
+
 	local_irq_save(flags);
 	cpu = raw_smp_processor_id();
 	data = tr->data[cpu];
@@ -1217,6 +1220,9 @@ int trace_graph_entry(struct ftrace_graph_ent *trace)
 		pc = preempt_count();
 		__trace_graph_entry(tr, data, trace, flags, pc);
 	}
+	/* Only do the atomic if it is not already set */
+	if (!test_tsk_trace_graph(current))
+		set_tsk_trace_graph(current);
 	atomic_dec(&data->disabled);
 	local_irq_restore(flags);
 
@@ -1240,6 +1246,8 @@ void trace_graph_return(struct ftrace_graph_ret *trace)
 		pc = preempt_count();
 		__trace_graph_return(tr, data, trace, flags, pc);
 	}
+	if (!trace->depth)
+		clear_tsk_trace_graph(current);
 	atomic_dec(&data->disabled);
 	local_irq_restore(flags);
 }
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 0565ae9..41f026b 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -505,13 +505,41 @@ extern unsigned long trace_flags;
 /* Standard output formatting function used for function return traces */
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 extern enum print_line_t print_graph_function(struct trace_iterator *iter);
+
+#ifdef CONFIG_DYNAMIC_FTRACE
+/* TODO: make this variable */
+#define FTRACE_GRAPH_MAX_FUNCS		32
+extern int ftrace_graph_count;
+extern unsigned long ftrace_graph_funcs[FTRACE_GRAPH_MAX_FUNCS];
+
+static inline int ftrace_graph_addr(unsigned long addr)
+{
+	int i;
+
+	if (!ftrace_graph_count || test_tsk_trace_graph(current))
+		return 1;
+
+	for (i = 0; i < ftrace_graph_count; i++) {
+		if (addr == ftrace_graph_funcs[i])
+			return 1;
+	}
+
+	return 0;
+}
 #else
+static inline int ftrace_trace_addr(unsigned long addr)
+{
+	return 1
+}
+#endif /* CONFIG_DYNAMIC_FTRACE */
+
+#else /* CONFIG_FUNCTION_GRAPH_TRACER */
 static inline enum print_line_t
 print_graph_function(struct trace_iterator *iter)
 {
 	return TRACE_TYPE_UNHANDLED;
 }
-#endif
+#endif /* CONFIG_FUNCTION_GRAPH_TRACER */
 
 /*
  * trace_iterator_flags is an enumeration that defines bit
-- 
1.5.6.5

-- 
