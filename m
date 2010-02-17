From: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Subject: [PATCH 1/1] RFC: Containerized syslog for full fledged container
	(Phase-I, Take III).
Date: Wed, 17 Feb 2010 13:44:26 -0500
Message-ID: <201002171834.o1HIY1RI026002@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-Id: <201002171844.o1HIibiD032576-4srrYzrIIfvCUzpuK5MMl/d9D2ou9A/h@public.gmane.org>
Resent-To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

	Containerized syslog purpose is to avoid corrupting
	kernel syslog (/proc/kmsg) if a process running within
	a container (unsharing everything; net, namespace, pid, etc..)
	is probing /proc/kmsg.

	The perfect example is container rsyslog daemon, competing with
	the host rsyslog daemon, none of the process are able to catch
	clean syslog messages.

	Container /proc/kmsg could have been linked/redirected to
	/dev/null but container sys-admin could need to receive important
	kernel messages (SElinux, iptables logs, container own devices,
	etc...).

	Perfect example are iptables log message where iptables
	rules are defined and managed within the container itself.

	If HOST: and container CONT: have different sys-admin;
	a practical case in real production; needed iptables
	log messages must be directed to CONT: sys-admin
	while they are of none interest to HOST: sys-admin.

	In broader approach, we could say all kernel
	messages related to CONT: device (example, a
	device eth0 defined within CONT:) should be
	directed to CONT: syslog.
	Kernel will report trouble related to hardware
	emulation specific to container.

	Containerized syslog is implemented within nsproxy
	and a small independent ring buffer memory is
	allocated to the messaging procedure named printk.

Signed-off-by:	Jean-Marc Pigeon	<jmp-4qkeo2rQ0gg@public.gmane.org>
---
 include/linux/init_task.h |    2 +
 include/linux/nsproxy.h   |    2 +
 include/linux/syslog.h    |   50 ++++++++
 kernel/Makefile           |    1 +
 kernel/nsproxy.c          |   10 ++
 kernel/printk.c           |  308 +++++++++++++++++++++-----------------------
 kernel/syslog.c           |  217 +++++++++++++++++++++++++++++++
 7 files changed, 429 insertions(+), 161 deletions(-)
 create mode 100644 include/linux/syslog.h
 create mode 100644 kernel/syslog.c

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index abec69b..30b479e 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -11,6 +11,7 @@
 #include <linux/user_namespace.h>
 #include <linux/securebits.h>
 #include <net/net_namespace.h>
+#include <linux/syslog.h>
 
 extern struct files_struct init_files;
 extern struct fs_struct init_fs;
@@ -37,6 +38,7 @@ extern struct nsproxy init_nsproxy;
 	.count		= ATOMIC_INIT(1),				\
 	.uts_ns		= &init_uts_ns,					\
 	.mnt_ns		= NULL,						\
+	.syslog_ns	= &init_kernel_syslog_ns,			\
 	INIT_NET_NS(net_ns)                                             \
 	INIT_IPC_NS(ipc_ns)						\
 }
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 7b370c7..852fed3 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -3,6 +3,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/sched.h>
+#include <linux/syslog.h>
 
 struct mnt_namespace;
 struct uts_namespace;
@@ -29,6 +30,7 @@ struct nsproxy {
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 	struct net 	     *net_ns;
+	struct syslog_ns     *syslog_ns;
 };
 extern struct nsproxy init_nsproxy;
 
diff --git a/include/linux/syslog.h b/include/linux/syslog.h
new file mode 100644
index 0000000..9825fae
--- /dev/null
+++ b/include/linux/syslog.h
@@ -0,0 +1,50 @@
+#ifndef _LINUX_SYSLOG_H
+#define _LINUX_SYSLOG_H
+#include <linux/spinlock_types.h>
+#include <linux/sched.h>
+
+/*TMP_JMPDBG reference to be fully removed when code accepted	*/
+#define	TMP_JMPDBG	1
+
+#define	CLONE_SYSLOG \
+	(CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWUSER | \
+	 CLONE_NEWPID | CLONE_NEWNET)
+
+struct syslog_ns {
+	struct kref kref;	/*syslog_ns reference count & control	  */
+#ifdef	TMP_JMPDBG
+	int nbrtime;
+#endif
+	wait_queue_head_t wait;
+	spinlock_t logbuf_lock;	/* access conflict locker		   */
+	unsigned log_start;	/* Index: next char to be read by syslog() */
+	unsigned con_start;	/* Index: next char to be sent to consoles */
+	unsigned log_end;	/* Index: most-recently-written-char + 1   */
+	unsigned logged_chars;	/* Num chars produced since last read+clear*/
+	unsigned buf_len;	/* buffer available space size		   */
+	char *buf;		/* allocated ring buffer		   */
+};
+
+/*
+ *  Static structure used by kernel
+ */
+extern struct syslog_ns init_kernel_syslog_ns;
+
+/*
+ * Syslog API
+ *
+ */
+extern struct syslog_ns *resize_syslog_ns(struct syslog_ns *syslog_ns,
+					unsigned container_buf_len);
+extern struct syslog_ns *copy_syslog_ns(unsigned long flags,
+					struct syslog_ns *current_syslog_ns);
+extern void free_syslog_ns(struct kref *kref);
+extern struct syslog_ns *current_syslog_ns(void);
+
+static inline void put_syslog_ns(struct syslog_ns *ns)
+{
+	kref_put(&ns->kref, free_syslog_ns);
+}
+
+#else /* !CONFIG_PID_NS */
+#endif /* _LINUX_SYSLOG_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index 864ff75..9268f96 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -24,6 +24,7 @@ CFLAGS_REMOVE_sched_clock.o = -pg
 CFLAGS_REMOVE_perf_event.o = -pg
 endif
 
+obj-$(CONFIG_PRINTK) += syslog.o
 obj-$(CONFIG_FREEZER) += freezer.o
 obj-$(CONFIG_PROFILING) += profile.o
 obj-$(CONFIG_SYSCTL_SYSCALL_CHECK) += sysctl_check.o
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 09b4ff9..cd17cfb 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -80,9 +80,17 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
 	}
+	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk->nsproxy->syslog_ns);
+	if (IS_ERR(new_nsp->syslog_ns)) {
+		err = PTR_ERR(new_nsp->syslog_ns);
+		goto out_syslog;
+	}
 
 	return new_nsp;
 
+out_syslog:
+	if (new_nsp->net_ns)
+		put_net(new_nsp->net_ns);
 out_net:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
@@ -151,6 +159,8 @@ out:
 
 void free_nsproxy(struct nsproxy *ns)
 {
+	if (ns->syslog_ns)
+		put_syslog_ns(ns->syslog_ns);
 	if (ns->mnt_ns)
 		put_mnt_ns(ns->mnt_ns);
 	if (ns->uts_ns)
diff --git a/kernel/printk.c b/kernel/printk.c
index 1751c45..446a8a0 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -35,6 +35,7 @@
 #include <linux/kexec.h>
 #include <linux/ratelimit.h>
 #include <linux/kmsg_dump.h>
+#include <linux/syslog.h>
 
 #include <asm/uaccess.h>
 
@@ -51,8 +52,6 @@ void asmlinkage __attribute__((weak)) early_printk(const char *fmt, ...)
 {
 }
 
-#define __LOG_BUF_LEN	(1 << CONFIG_LOG_BUF_SHIFT)
-
 /* printk's without a loglevel use this.. */
 #define DEFAULT_MESSAGE_LOGLEVEL 4 /* KERN_WARNING */
 
@@ -69,8 +68,6 @@ int console_printk[4] = {
 	DEFAULT_CONSOLE_LOGLEVEL,	/* default_console_loglevel */
 };
 
-static int saved_console_loglevel = -1;
-
 /*
  * Low level drivers may need that to know if they can schedule in
  * their unblank() callback or not. So let's export it.
@@ -97,23 +94,20 @@ EXPORT_SYMBOL_GPL(console_drivers);
  */
 static int console_locked, console_suspended;
 
-/*
- * logbuf_lock protects log_buf, log_start, log_end, con_start and logged_chars
- * It is also used in interesting ways to provide interlocking in
- * release_console_sem().
- */
-static DEFINE_SPINLOCK(logbuf_lock);
-
-#define LOG_BUF_MASK (log_buf_len-1)
-#define LOG_BUF(idx) (log_buf[(idx) & LOG_BUF_MASK])
+#define LOG_BUF_MASK(ns) ((ns)->buf_len-1)
+#define LOG_BUF(ns, idx) ((ns)->buf[(idx) & LOG_BUF_MASK(ns)])
 
 /*
- * The indices into log_buf are not constrained to log_buf_len - they
- * must be masked before subscripting
+ * To access container syslog ring buffer
  */
-static unsigned log_start;	/* Index into log_buf: next char to be read by syslog() */
-static unsigned con_start;	/* Index into log_buf: next char to be sent to consoles */
-static unsigned log_end;	/* Index into log_buf: most-recently-written-char + 1 */
+#define sys_log_wait (syslog_ns->wait)
+#define sys_log_lock (syslog_ns->logbuf_lock)
+#define sys_log_start (syslog_ns->log_start)
+#define sys_log_end (syslog_ns->log_end)
+#define sys_log_con_start (syslog_ns->con_start)
+#define sys_log_buf_len (syslog_ns->buf_len)
+#define sys_log_logged_chars (syslog_ns->logged_chars)
+#define sys_log_buf (syslog_ns->buf)
 
 /*
  *	Array of consoles built from command line options (console=)
@@ -141,10 +135,7 @@ static int console_may_schedule;
 
 #ifdef CONFIG_PRINTK
 
-static char __log_buf[__LOG_BUF_LEN];
-static char *log_buf = __log_buf;
-static int log_buf_len = __LOG_BUF_LEN;
-static unsigned logged_chars; /* Number of chars produced since last read+clear operation */
+static int saved_console_loglevel = -1;
 
 #ifdef CONFIG_KEXEC
 /*
@@ -157,49 +148,23 @@ static unsigned logged_chars; /* Number of chars produced since last read+clear
  */
 void log_buf_kexec_setup(void)
 {
-	VMCOREINFO_SYMBOL(log_buf);
-	VMCOREINFO_SYMBOL(log_end);
-	VMCOREINFO_SYMBOL(log_buf_len);
-	VMCOREINFO_SYMBOL(logged_chars);
+	struct syslog_ns *syslog_ns = current_syslog_ns();
+
+	VMCOREINFO_SYMBOL(sys_log_buf);
+	VMCOREINFO_SYMBOL(sys_log_end);
+	VMCOREINFO_SYMBOL(sys_log_buf_len);
+	VMCOREINFO_SYMBOL(sys_log_logged_chars);
 }
 #endif
 
 static int __init log_buf_len_setup(char *str)
 {
 	unsigned size = memparse(str, &str);
-	unsigned long flags;
 
-	if (size)
+	if (size) {
 		size = roundup_pow_of_two(size);
-	if (size > log_buf_len) {
-		unsigned start, dest_idx, offset;
-		char *new_log_buf;
-
-		new_log_buf = alloc_bootmem(size);
-		if (!new_log_buf) {
-			printk(KERN_WARNING "log_buf_len: allocation failed\n");
-			goto out;
-		}
-
-		spin_lock_irqsave(&logbuf_lock, flags);
-		log_buf_len = size;
-		log_buf = new_log_buf;
-
-		offset = start = min(con_start, log_start);
-		dest_idx = 0;
-		while (start != log_end) {
-			log_buf[dest_idx] = __log_buf[start & (__LOG_BUF_LEN - 1)];
-			start++;
-			dest_idx++;
-		}
-		log_start -= offset;
-		con_start -= offset;
-		log_end -= offset;
-		spin_unlock_irqrestore(&logbuf_lock, flags);
-
-		printk(KERN_NOTICE "log_buf_len: %d\n", log_buf_len);
+		resize_syslog_ns(&init_kernel_syslog_ns, size);
 	}
-out:
 	return 1;
 }
 
@@ -279,6 +244,7 @@ int do_syslog(int type, char __user *buf, int len)
 	int do_clear = 0;
 	char c;
 	int error = 0;
+	struct syslog_ns *syslog_ns = current_syslog_ns();
 
 	error = security_syslog(type);
 	if (error)
@@ -300,23 +266,23 @@ int do_syslog(int type, char __user *buf, int len)
 			error = -EFAULT;
 			goto out;
 		}
-		error = wait_event_interruptible(log_wait,
-							(log_start - log_end));
+		error = wait_event_interruptible(sys_log_wait,
+					(sys_log_start - sys_log_end));
 		if (error)
 			goto out;
 		i = 0;
-		spin_lock_irq(&logbuf_lock);
-		while (!error && (log_start != log_end) && i < len) {
-			c = LOG_BUF(log_start);
-			log_start++;
-			spin_unlock_irq(&logbuf_lock);
+		spin_lock_irq(&sys_log_lock);
+		while (!error && (sys_log_start != sys_log_end) && i < len) {
+			c = LOG_BUF(syslog_ns, sys_log_start);
+			sys_log_start++;
+			spin_unlock_irq(&sys_log_lock);
 			error = __put_user(c,buf);
 			buf++;
 			i++;
 			cond_resched();
-			spin_lock_irq(&logbuf_lock);
+			spin_lock_irq(&sys_log_lock);
 		}
-		spin_unlock_irq(&logbuf_lock);
+		spin_unlock_irq(&sys_log_lock);
 		if (!error)
 			error = i;
 		break;
@@ -335,14 +301,14 @@ int do_syslog(int type, char __user *buf, int len)
 			goto out;
 		}
 		count = len;
-		if (count > log_buf_len)
-			count = log_buf_len;
-		spin_lock_irq(&logbuf_lock);
-		if (count > logged_chars)
-			count = logged_chars;
+		if (count > sys_log_buf_len)
+			count = sys_log_buf_len;
+		spin_lock_irq(&sys_log_lock);
+		if (count > sys_log_logged_chars)
+			count = sys_log_logged_chars;
 		if (do_clear)
-			logged_chars = 0;
-		limit = log_end;
+			sys_log_logged_chars = 0;
+		limit = sys_log_end;
 		/*
 		 * __put_user() could sleep, and while we sleep
 		 * printk() could overwrite the messages
@@ -351,15 +317,15 @@ int do_syslog(int type, char __user *buf, int len)
 		 */
 		for (i = 0; i < count && !error; i++) {
 			j = limit-1-i;
-			if (j + log_buf_len < log_end)
+			if (j + sys_log_buf_len < sys_log_end)
 				break;
-			c = LOG_BUF(j);
-			spin_unlock_irq(&logbuf_lock);
+			c = LOG_BUF(syslog_ns, j);
+			spin_unlock_irq(&sys_log_lock);
 			error = __put_user(c,&buf[count-1-i]);
 			cond_resched();
-			spin_lock_irq(&logbuf_lock);
+			spin_lock_irq(&sys_log_lock);
 		}
-		spin_unlock_irq(&logbuf_lock);
+		spin_unlock_irq(&sys_log_lock);
 		if (error)
 			break;
 		error = i;
@@ -377,7 +343,7 @@ int do_syslog(int type, char __user *buf, int len)
 		}
 		break;
 	case 5:		/* Clear ring buffer */
-		logged_chars = 0;
+		sys_log_logged_chars = 0;
 		break;
 	case 6:		/* Disable logging to console */
 		if (saved_console_loglevel == -1)
@@ -402,10 +368,10 @@ int do_syslog(int type, char __user *buf, int len)
 		error = 0;
 		break;
 	case 9:		/* Number of chars in the log buffer */
-		error = log_end - log_start;
+		error = sys_log_end - sys_log_start;
 		break;
 	case 10:	/* Size of the log buffer */
-		error = log_buf_len;
+		error = sys_log_buf_len;
 		break;
 	default:
 		error = -EINVAL;
@@ -423,7 +389,8 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
 /*
  * Call the console drivers on a range of log_buf
  */
-static void __call_console_drivers(unsigned start, unsigned end)
+static void __call_console_drivers(struct syslog_ns *syslog_ns,
+				unsigned start, unsigned end)
 {
 	struct console *con;
 
@@ -431,7 +398,8 @@ static void __call_console_drivers(unsigned start, unsigned end)
 		if ((con->flags & CON_ENABLED) && con->write &&
 				(cpu_online(smp_processor_id()) ||
 				(con->flags & CON_ANYTIME)))
-			con->write(con, &LOG_BUF(start), end - start);
+			con->write(con, &LOG_BUF(syslog_ns, start),
+				end - start);
 	}
 }
 
@@ -450,18 +418,21 @@ early_param("ignore_loglevel", ignore_loglevel_setup);
 /*
  * Write out chars from start to end - 1 inclusive
  */
-static void _call_console_drivers(unsigned start,
-				unsigned end, int msg_log_level)
+static void _call_console_drivers(struct syslog_ns *syslog_ns, unsigned start,
+				  unsigned end, int msg_log_level)
 {
 	if ((msg_log_level < console_loglevel || ignore_loglevel) &&
 			console_drivers && start != end) {
-		if ((start & LOG_BUF_MASK) > (end & LOG_BUF_MASK)) {
+		if ((start & LOG_BUF_MASK(syslog_ns)) >
+			(end & LOG_BUF_MASK(syslog_ns))) {
 			/* wrapped write */
-			__call_console_drivers(start & LOG_BUF_MASK,
-						log_buf_len);
-			__call_console_drivers(0, end & LOG_BUF_MASK);
+			__call_console_drivers(syslog_ns,
+					start & LOG_BUF_MASK(syslog_ns),
+					sys_log_buf_len);
+			__call_console_drivers(syslog_ns, 0,
+					end & LOG_BUF_MASK(syslog_ns));
 		} else {
-			__call_console_drivers(start, end);
+			__call_console_drivers(syslog_ns, start, end);
 		}
 	}
 }
@@ -471,7 +442,8 @@ static void _call_console_drivers(unsigned start,
  * log_buf[start] to log_buf[end - 1].
  * The console_sem must be held.
  */
-static void call_console_drivers(unsigned start, unsigned end)
+static void call_console_drivers(struct syslog_ns *syslog_ns,
+				unsigned start, unsigned end)
 {
 	unsigned cur_index, start_print;
 	static int msg_level = -1;
@@ -482,16 +454,16 @@ static void call_console_drivers(unsigned start, unsigned end)
 	start_print = start;
 	while (cur_index != end) {
 		if (msg_level < 0 && ((end - cur_index) > 2) &&
-				LOG_BUF(cur_index + 0) == '<' &&
-				LOG_BUF(cur_index + 1) >= '0' &&
-				LOG_BUF(cur_index + 1) <= '7' &&
-				LOG_BUF(cur_index + 2) == '>') {
-			msg_level = LOG_BUF(cur_index + 1) - '0';
+				LOG_BUF(syslog_ns, cur_index + 0) == '<' &&
+				LOG_BUF(syslog_ns, cur_index + 1) >= '0' &&
+				LOG_BUF(syslog_ns, cur_index + 1) <= '7' &&
+				LOG_BUF(syslog_ns, cur_index + 2) == '>') {
+			msg_level = LOG_BUF(syslog_ns, cur_index + 1) - '0';
 			cur_index += 3;
 			start_print = cur_index;
 		}
 		while (cur_index != end) {
-			char c = LOG_BUF(cur_index);
+			char c = LOG_BUF(syslog_ns, cur_index);
 
 			cur_index++;
 			if (c == '\n') {
@@ -504,26 +476,27 @@ static void call_console_drivers(unsigned start, unsigned end)
 					 */
 					msg_level = default_message_loglevel;
 				}
-				_call_console_drivers(start_print, cur_index, msg_level);
+				_call_console_drivers(syslog_ns,
+					start_print, cur_index, msg_level);
 				msg_level = -1;
 				start_print = cur_index;
 				break;
 			}
 		}
 	}
-	_call_console_drivers(start_print, end, msg_level);
+	_call_console_drivers(syslog_ns, start_print, end, msg_level);
 }
 
-static void emit_log_char(char c)
+static void emit_log_char(struct syslog_ns *syslog_ns, char c)
 {
-	LOG_BUF(log_end) = c;
-	log_end++;
-	if (log_end - log_start > log_buf_len)
-		log_start = log_end - log_buf_len;
-	if (log_end - con_start > log_buf_len)
-		con_start = log_end - log_buf_len;
-	if (logged_chars < log_buf_len)
-		logged_chars++;
+	LOG_BUF(syslog_ns, sys_log_end) = c;
+	sys_log_end++;
+	if (sys_log_end - sys_log_start > sys_log_buf_len)
+		sys_log_start = sys_log_end - sys_log_buf_len;
+	if (sys_log_end - sys_log_con_start > sys_log_buf_len)
+		sys_log_con_start = sys_log_end - sys_log_buf_len;
+	if (sys_log_logged_chars < sys_log_buf_len)
+		sys_log_logged_chars++;
 }
 
 /*
@@ -531,7 +504,7 @@ static void emit_log_char(char c)
  * every 10 seconds, to leave time for slow consoles to print a
  * full oops.
  */
-static void zap_locks(void)
+static void zap_locks(struct syslog_ns *syslog_ns)
 {
 	static unsigned long oops_timestamp;
 
@@ -542,7 +515,7 @@ static void zap_locks(void)
 	oops_timestamp = jiffies;
 
 	/* If a crash is occurring, make sure we can't deadlock */
-	spin_lock_init(&logbuf_lock);
+	spin_lock_init(&sys_log_lock);
 	/* And make sure that we print immediately */
 	init_MUTEX(&console_sem);
 }
@@ -626,7 +599,8 @@ static inline int can_use_console(unsigned int cpu)
  * interrupts disabled. It should return with 'lockbuf_lock'
  * released but interrupts still disabled.
  */
-static int acquire_console_semaphore_for_printk(unsigned int cpu)
+static int acquire_console_semaphore_for_printk(
+		struct syslog_ns *syslog_ns, unsigned int cpu)
 {
 	int retval = 0;
 
@@ -646,7 +620,7 @@ static int acquire_console_semaphore_for_printk(unsigned int cpu)
 		}
 	}
 	printk_cpu = UINT_MAX;
-	spin_unlock(&logbuf_lock);
+	spin_unlock(&sys_log_lock);
 	return retval;
 }
 static const char recursion_bug_msg [] =
@@ -673,6 +647,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 {
 	int printed_len = 0;
 	int current_log_level = default_message_loglevel;
+	struct syslog_ns *syslog_ns = current_syslog_ns();
 	unsigned long flags;
 	int this_cpu;
 	char *p;
@@ -700,11 +675,11 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 			recursion_bug = 1;
 			goto out_restore_irqs;
 		}
-		zap_locks();
+		zap_locks(syslog_ns);
 	}
 
 	lockdep_off();
-	spin_lock(&logbuf_lock);
+	spin_lock(&sys_log_lock);
 	printk_cpu = this_cpu;
 
 	if (recursion_bug) {
@@ -729,7 +704,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 			/* Fallthrough - make sure we're on a new line */
 			case 'd': /* KERN_DEFAULT */
 				if (!new_text_line) {
-					emit_log_char('\n');
+					emit_log_char(syslog_ns, '\n');
 					new_text_line = 1;
 				}
 			/* Fallthrough - skip the loglevel */
@@ -747,9 +722,9 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	for ( ; *p; p++) {
 		if (new_text_line) {
 			/* Always output the token */
-			emit_log_char('<');
-			emit_log_char(current_log_level + '0');
-			emit_log_char('>');
+			emit_log_char(syslog_ns, '<');
+			emit_log_char(syslog_ns, current_log_level + '0');
+			emit_log_char(syslog_ns, '>');
 			printed_len += 3;
 			new_text_line = 0;
 
@@ -767,15 +742,22 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 						nanosec_rem / 1000);
 
 				for (tp = tbuf; tp < tbuf + tlen; tp++)
-					emit_log_char(*tp);
+					emit_log_char(syslog_ns, *tp);
 				printed_len += tlen;
+#ifdef TMP_JMPDBG		/*to display syslog number	*/
+				tlen = sprintf(tbuf, "[sl=%d] ",
+						syslog_ns->nbrtime);
+				for (tp = tbuf; tp < tbuf + tlen; tp++)
+					emit_log_char(syslog_ns, *tp);
+				printed_len += tlen;
+#endif
 			}
 
 			if (!*p)
 				break;
 		}
 
-		emit_log_char(*p);
+		emit_log_char(syslog_ns, *p);
 		if (*p == '\n')
 			new_text_line = 1;
 	}
@@ -790,7 +772,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	 * will release 'logbuf_lock' regardless of whether it
 	 * actually gets the semaphore or not.
 	 */
-	if (acquire_console_semaphore_for_printk(this_cpu))
+	if (acquire_console_semaphore_for_printk(syslog_ns, this_cpu))
 		release_console_sem();
 
 	lockdep_on();
@@ -803,12 +785,6 @@ out_restore_irqs:
 EXPORT_SYMBOL(printk);
 EXPORT_SYMBOL(vprintk);
 
-#else
-
-static void call_console_drivers(unsigned start, unsigned end)
-{
-}
-
 #endif
 
 static int __add_preferred_console(char *name, int idx, char *options,
@@ -1041,36 +1017,40 @@ void wake_up_klogd(void)
  */
 void release_console_sem(void)
 {
-	unsigned long flags;
-	unsigned _con_start, _log_end;
-	unsigned wake_klogd = 0;
-
 	if (console_suspended) {
 		up(&console_sem);
 		return;
 	}
 
 	console_may_schedule = 0;
-
-	for ( ; ; ) {
-		spin_lock_irqsave(&logbuf_lock, flags);
-		wake_klogd |= log_start - log_end;
-		if (con_start == log_end)
-			break;			/* Nothing to print */
-		_con_start = con_start;
-		_log_end = log_end;
-		con_start = log_end;		/* Flush */
-		spin_unlock(&logbuf_lock);
-		stop_critical_timings();	/* don't trace print latency */
-		call_console_drivers(_con_start, _log_end);
-		start_critical_timings();
-		local_irq_restore(flags);
+#ifdef	CONFIG_PRINTK
+	{
+		unsigned long flags;
+		unsigned _con_start, _log_end;
+		unsigned wake_klogd = 0;
+		struct syslog_ns *syslog_ns = current_syslog_ns();
+
+		for ( ; ; ) {
+			spin_lock_irqsave(&sys_log_lock, flags);
+			wake_klogd |= sys_log_start - sys_log_end;
+			if (sys_log_con_start == sys_log_end)
+				break;			/* Nothing to print */
+			_con_start = sys_log_con_start;
+			_log_end = sys_log_end;
+			sys_log_con_start = sys_log_end;	/* Flush */
+			spin_unlock(&sys_log_lock);
+			stop_critical_timings();/* don't trace print latency */
+			call_console_drivers(syslog_ns, _con_start, _log_end);
+			start_critical_timings();
+			local_irq_restore(flags);
+		}
+		spin_unlock_irqrestore(&sys_log_lock, flags);
+		if (wake_klogd)
+			wake_up_klogd();
 	}
+#endif
 	console_locked = 0;
 	up(&console_sem);
-	spin_unlock_irqrestore(&logbuf_lock, flags);
-	if (wake_klogd)
-		wake_up_klogd();
 }
 EXPORT_SYMBOL(release_console_sem);
 
@@ -1175,7 +1155,6 @@ EXPORT_SYMBOL(console_start);
 void register_console(struct console *newcon)
 {
 	int i;
-	unsigned long flags;
 	struct console *bcon = NULL;
 
 	/*
@@ -1281,15 +1260,21 @@ void register_console(struct console *newcon)
 		newcon->next = console_drivers->next;
 		console_drivers->next = newcon;
 	}
+#ifdef	CONFIG_PRINTK
 	if (newcon->flags & CON_PRINTBUFFER) {
+		unsigned long flags;
 		/*
 		 * release_console_sem() will print out the buffered messages
 		 * for us.
 		 */
-		spin_lock_irqsave(&logbuf_lock, flags);
-		con_start = log_start;
-		spin_unlock_irqrestore(&logbuf_lock, flags);
+
+		struct syslog_ns *syslog_ns = current_syslog_ns();
+
+		spin_lock_irqsave(&sys_log_lock, flags);
+		sys_log_con_start = sys_log_start;
+		spin_unlock_irqrestore(&sys_log_lock, flags);
 	}
+#endif
 	release_console_sem();
 
 	/*
@@ -1493,27 +1478,28 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 	const char *s1, *s2;
 	unsigned long l1, l2;
 	unsigned long flags;
+	struct syslog_ns *syslog_ns = current_syslog_ns();
 
 	/* Theoretically, the log could move on after we do this, but
 	   there's not a lot we can do about that. The new messages
 	   will overwrite the start of what we dump. */
-	spin_lock_irqsave(&logbuf_lock, flags);
-	end = log_end & LOG_BUF_MASK;
-	chars = logged_chars;
-	spin_unlock_irqrestore(&logbuf_lock, flags);
+	spin_lock_irqsave(&sys_log_lock, flags);
+	end = sys_log_end & LOG_BUF_MASK(syslog_ns);
+	chars = sys_log_logged_chars;
+	spin_unlock_irqrestore(&sys_log_lock, flags);
 
-	if (logged_chars > end) {
-		s1 = log_buf + log_buf_len - logged_chars + end;
-		l1 = logged_chars - end;
+	if (sys_log_logged_chars > end) {
+		s1 = sys_log_buf + sys_log_buf_len - sys_log_logged_chars + end;
+		l1 = sys_log_logged_chars - end;
 
-		s2 = log_buf;
+		s2 = sys_log_buf;
 		l2 = end;
 	} else {
 		s1 = "";
 		l1 = 0;
 
-		s2 = log_buf + end - logged_chars;
-		l2 = logged_chars;
+		s2 = sys_log_buf + end - sys_log_logged_chars;
+		l2 = sys_log_logged_chars;
 	}
 
 	if (!spin_trylock_irqsave(&dump_list_lock, flags)) {
diff --git a/kernel/syslog.c b/kernel/syslog.c
new file mode 100644
index 0000000..8ca4b4e
--- /dev/null
+++ b/kernel/syslog.c
@@ -0,0 +1,217 @@
+/*
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ *  Feb 2010
+ *  Serge E. Hallyn	<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *  Jean-Marc Pigeon	<jmp-4qkeo2rQ0gg@public.gmane.org>
+ *
+ *  Purpose is to regroup all procedure involved
+ *  in system log.
+ *  System log need to be containerized to avoid
+ *  crossing over critical data between physical host layer
+ *  and container layer.
+ *
+ *  The principle is to keep a containerized ring buffer
+ *  where container kernel data are redirected, kept and
+ *  managed.
+ *
+ *  Containerized syslog is activated by CLONE_SYSLOG
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/bootmem.h>
+#include <linux/slab.h>
+#include <linux/cred.h>
+#include <linux/kref.h>
+#include <linux/user_namespace.h>
+#include <linux/syslog.h>
+/*
+ * Static memory definition, used to assign a syslog
+ * to the kernel itself
+ *
+ */
+
+
+#define __LOG_BUF_LEN   (1 << CONFIG_LOG_BUF_SHIFT)
+static char __log_buf[__LOG_BUF_LEN];
+
+struct syslog_ns init_kernel_syslog_ns = {
+	.kref = {
+		.refcount	= ATOMIC_INIT(2),
+	},
+#ifdef	TMP_JMPDBG
+	.nbrtime = 1,
+#endif
+	.wait = __WAIT_QUEUE_HEAD_INITIALIZER(init_kernel_syslog_ns.wait),
+	.buf_len = __LOG_BUF_LEN,
+	.buf = __log_buf
+};
+
+struct syslog_ns init_kernel_syslog_ns;
+EXPORT_SYMBOL_GPL(init_kernel_syslog_ns);
+
+/*
+ * Procedure to free all ressources tied to syslog
+ *
+ */
+struct syslog_ns *free_all_syslog_ns(struct syslog_ns *syslog)
+
+{
+	if (syslog != (struct syslog_ns *)0) {
+		(void) kfree(syslog->buf);
+		(void) kfree(syslog);
+		syslog = (struct syslog_ns *)0;
+		}
+	return syslog;
+}
+
+/*
+ * Procedure to assign memory for syslog area
+ *
+ */
+static struct syslog_ns *malloc_syslog_ns(unsigned container_buf_len)
+{
+#ifdef	TMP_JMPDBG
+	static int nbrtime = 1;
+#endif
+	struct syslog_ns *ns;
+
+	if (container_buf_len <= 0)
+		return ERR_PTR(-EINVAL);
+
+	ns = kzalloc(sizeof(*ns), GFP_KERNEL);
+	if (!ns)
+		return ERR_PTR(-ENOMEM);
+
+	(void) kref_init(&(ns->kref));
+
+#ifdef	TMP_JMPDBG
+	nbrtime++;
+	ns->nbrtime = nbrtime;
+#endif
+	ns->buf_len = container_buf_len;
+	ns->buf = kzalloc(container_buf_len, GFP_KERNEL);
+	if (!ns->buf) {
+		(void) kfree(ns);
+		return ERR_PTR(-ENOMEM);
+	}
+	spin_lock_init(&(ns->logbuf_lock));
+	init_waitqueue_head(&ns->wait);
+	return ns;
+}
+
+/*
+ * Procedure to ONLY increase syslog buffer size
+ * If syslog_ns is NULL, assign a brand new syslog_ns
+ *
+ */
+struct syslog_ns *resize_syslog_ns(struct syslog_ns *syslog_ns,
+			unsigned container_buf_len)
+
+{
+	if ((syslog_ns == &init_kernel_syslog_ns) &&
+		(container_buf_len > syslog_ns->buf_len)) {
+		int old_buf_len;
+		char *old_buf;
+		char *new_buf;
+		unsigned long flags;
+
+		old_buf_len = syslog_ns->buf_len;
+		old_buf = syslog_ns->buf;
+		new_buf = alloc_bootmem(container_buf_len);
+		if (!new_buf) {
+			(void) printk(KERN_WARNING
+				"log_buf_len: allocation failed\n");
+			return ERR_PTR(-ENOMEM);
+			}
+		spin_lock_irqsave(&(syslog_ns->logbuf_lock), flags);
+		(void) memmove(new_buf, old_buf, old_buf_len);
+		syslog_ns->buf = new_buf;
+		syslog_ns->buf_len = container_buf_len;
+		spin_unlock_irqrestore(&(syslog_ns->logbuf_lock), flags);
+		if (old_buf != __log_buf)
+			(void) free_bootmem((unsigned long)old_buf,
+					    old_buf_len);
+		}
+	if (!syslog_ns)
+		return malloc_syslog_ns(container_buf_len);
+	if (syslog_ns->buf_len > container_buf_len) {
+		(void) printk(KERN_WARNING "log_buf_len: Not allowed "
+					"to decrease syslog buffer\n");
+		return ERR_PTR(-EINVAL);
+		}
+	if (syslog_ns->buf_len < container_buf_len) {
+		char *old_buf;
+		char *new_buf;
+		unsigned long flags;
+
+		old_buf = syslog_ns->buf;
+		new_buf = kzalloc(container_buf_len, GFP_KERNEL);
+		if (!new_buf)
+			return ERR_PTR(-ENOMEM);
+		spin_lock_irqsave(&(syslog_ns->logbuf_lock), flags);
+		(void) memmove(new_buf, old_buf, syslog_ns->buf_len);
+		syslog_ns->buf = new_buf;
+		syslog_ns->buf_len = container_buf_len;
+		spin_unlock_irqrestore(&(syslog_ns->logbuf_lock), flags);
+		(void) kfree(old_buf);
+		}
+	(void) printk(KERN_NOTICE "log_buf_len: %u\n", syslog_ns->buf_len);
+	return syslog_ns;
+}
+
+/*
+ * Procedure to use current syslog unless a CLONE_SYSLOG is set
+ * such a new syslog area is defined and used
+ *
+ */
+struct syslog_ns *copy_syslog_ns(unsigned long flags,
+				struct syslog_ns *current_syslog_ns)
+
+{
+/*4096 should be enough for container syslog	*/
+#define	CONTAINER_BUF_LEN	4096
+
+	BUG_ON(!current_syslog_ns);
+	if ((flags & CLONE_SYSLOG) != CLONE_SYSLOG)
+		/*incrementing usage ref count	*/
+		(void) kref_get(&(current_syslog_ns->kref));
+	else
+		current_syslog_ns = malloc_syslog_ns(CONTAINER_BUF_LEN);
+	return current_syslog_ns;
+}
+
+/*
+ * Procedure to decrement syslog usage count and free memory
+ * if syslog usage count reach zero.
+ *
+ */
+void free_syslog_ns(struct kref *kref)
+
+{
+	struct syslog_ns *sl;
+
+	sl = container_of(kref, struct syslog_ns, kref);
+	sl = free_all_syslog_ns(sl);
+}
+
+/*
+ * Procedure to get the current syslog area linked to a
+ * container (by CLONE_SYSLOG).
+ * if trouble, pin down the problem before it propagate.
+ *
+ */
+struct syslog_ns *current_syslog_ns(void)
+
+{
+
+	struct syslog_ns *ns;
+
+	ns = current->nsproxy->syslog_ns;
+	BUG_ON(!ns);
+	return ns;
+}
-- 
1.6.6
