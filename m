From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC][gross hack] containerized syslog
Date: Thu, 4 Feb 2010 00:09:18 -0600
Message-ID: <20100204060918.GA13193@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Provide each user namespace with its own syslog ringbuffer.

So you can do
	ns_exec -cU /bin/bash
	dmesg
and see nothing.  Root in a container (with private user namespace)
cannot clear the host's ring buffer.

Since containers do not have a notion of consoles at present,
only the initial user namespace deals with console output or
with the console-related syslog commands.

This opens the door to targetting printk at certain syslog
namespaces.  It's not safe to be applied - it's a quick-n-dirty
hack and won't even compile for CONFIG_PRINTK=n.  Also I've not decided
what to do about duplication of printks to init_user_ns so for
now emit_one_char always duplicates to inti_user_ns.  We probably
want to be smarter about this and output a prefix indicating the
target.

But I figured discussions about the API would be more meaningful
with a testable patch.

---
 fs/proc/kmsg.c                 |    5 +-
 include/linux/user_namespace.h |    2 +
 kernel/printk.c                |  225 ++++++++++++++++++++++++++--------------
 kernel/user.c                  |    4 +
 kernel/user_namespace.c        |   13 +++
 5 files changed, 168 insertions(+), 81 deletions(-)

diff --git a/fs/proc/kmsg.c b/fs/proc/kmsg.c
index 7ca7834..2746b70 100644
--- a/fs/proc/kmsg.c
+++ b/fs/proc/kmsg.c
@@ -12,11 +12,12 @@
 #include <linux/poll.h>
 #include <linux/proc_fs.h>
 #include <linux/fs.h>
+#include <linux/syslog.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
 
-extern wait_queue_head_t log_wait;
+extern struct syslog_ns init_syslog_ns;
 
 extern int do_syslog(int type, char __user *bug, int count);
 
@@ -41,7 +42,7 @@ static ssize_t kmsg_read(struct file *file, char __user *buf,
 
 static unsigned int kmsg_poll(struct file *file, poll_table *wait)
 {
-	poll_wait(file, &log_wait, wait);
+	poll_wait(file, &init_syslog_ns.wait, wait);
 	if (do_syslog(9, NULL, 0))
 		return POLLIN | POLLRDNORM;
 	return 0;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index cc4f453..3926c89 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -5,6 +5,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/syslog.h>
 
 #define UIDHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 8)
 #define UIDHASH_SZ	(1 << UIDHASH_BITS)
@@ -14,6 +15,7 @@ struct user_namespace {
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*creator;
 	struct work_struct	destroyer;
+	struct syslog_ns	*syslog;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/printk.c b/kernel/printk.c
index 1751c45..5b93447 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -35,9 +35,18 @@
 #include <linux/kexec.h>
 #include <linux/ratelimit.h>
 #include <linux/kmsg_dump.h>
+#include <linux/user_namespace.h>
 
 #include <asm/uaccess.h>
 
+struct syslog_ns init_syslog_ns;
+#define g_log_wait (init_syslog_ns.wait)
+#define g_log_start (init_syslog_ns.start)
+#define g_log_end (init_syslog_ns.end)
+#define g_log_buf_len (init_syslog_ns.buf_len)
+#define g_logged_chars (init_syslog_ns.logged_chars)
+#define g_log_buf (init_syslog_ns.buf)
+
 /*
  * for_each_console() allows you to iterate on each console
  */
@@ -52,6 +61,7 @@ void asmlinkage __attribute__((weak)) early_printk(const char *fmt, ...)
 }
 
 #define __LOG_BUF_LEN	(1 << CONFIG_LOG_BUF_SHIFT)
+#define  CONTAINER_BUF_LEN 4096
 
 /* printk's without a loglevel use this.. */
 #define DEFAULT_MESSAGE_LOGLEVEL 4 /* KERN_WARNING */
@@ -60,8 +70,6 @@ void asmlinkage __attribute__((weak)) early_printk(const char *fmt, ...)
 #define MINIMUM_CONSOLE_LOGLEVEL 1 /* Minimum loglevel we let people use */
 #define DEFAULT_CONSOLE_LOGLEVEL 7 /* anything MORE serious than KERN_DEBUG */
 
-DECLARE_WAIT_QUEUE_HEAD(log_wait);
-
 int console_printk[4] = {
 	DEFAULT_CONSOLE_LOGLEVEL,	/* console_loglevel */
 	DEFAULT_MESSAGE_LOGLEVEL,	/* default_message_loglevel */
@@ -98,22 +106,20 @@ EXPORT_SYMBOL_GPL(console_drivers);
 static int console_locked, console_suspended;
 
 /*
- * logbuf_lock protects log_buf, log_start, log_end, con_start and logged_chars
+ * logbuf_lock protects g_log_buf, g_log_start, g_log_end, con_start and g_logged_chars
  * It is also used in interesting ways to provide interlocking in
  * release_console_sem().
  */
 static DEFINE_SPINLOCK(logbuf_lock);
 
-#define LOG_BUF_MASK (log_buf_len-1)
-#define LOG_BUF(idx) (log_buf[(idx) & LOG_BUF_MASK])
+#define LOG_BUF_MASK(ns) ((ns)->buf_len-1)
+#define LOG_BUF(ns, idx) ((ns)->buf[(idx) & LOG_BUF_MASK(ns)])
 
 /*
- * The indices into log_buf are not constrained to log_buf_len - they
+ * The indices into g_log_buf are not constrained to g_log_buf_len - they
  * must be masked before subscripting
  */
-static unsigned log_start;	/* Index into log_buf: next char to be read by syslog() */
-static unsigned con_start;	/* Index into log_buf: next char to be sent to consoles */
-static unsigned log_end;	/* Index into log_buf: most-recently-written-char + 1 */
+static unsigned con_start;	/* Index into g_log_buf: next char to be sent to consoles */
 
 /*
  *	Array of consoles built from command line options (console=)
@@ -142,9 +148,6 @@ static int console_may_schedule;
 #ifdef CONFIG_PRINTK
 
 static char __log_buf[__LOG_BUF_LEN];
-static char *log_buf = __log_buf;
-static int log_buf_len = __LOG_BUF_LEN;
-static unsigned logged_chars; /* Number of chars produced since last read+clear operation */
 
 #ifdef CONFIG_KEXEC
 /*
@@ -157,10 +160,10 @@ static unsigned logged_chars; /* Number of chars produced since last read+clear
  */
 void log_buf_kexec_setup(void)
 {
-	VMCOREINFO_SYMBOL(log_buf);
-	VMCOREINFO_SYMBOL(log_end);
-	VMCOREINFO_SYMBOL(log_buf_len);
-	VMCOREINFO_SYMBOL(logged_chars);
+	VMCOREINFO_SYMBOL(g_log_buf);
+	VMCOREINFO_SYMBOL(g_log_end);
+	VMCOREINFO_SYMBOL(g_log_buf_len);
+	VMCOREINFO_SYMBOL(g_logged_chars);
 }
 #endif
 
@@ -171,7 +174,7 @@ static int __init log_buf_len_setup(char *str)
 
 	if (size)
 		size = roundup_pow_of_two(size);
-	if (size > log_buf_len) {
+	if (size > g_log_buf_len) {
 		unsigned start, dest_idx, offset;
 		char *new_log_buf;
 
@@ -182,22 +185,22 @@ static int __init log_buf_len_setup(char *str)
 		}
 
 		spin_lock_irqsave(&logbuf_lock, flags);
-		log_buf_len = size;
-		log_buf = new_log_buf;
+		g_log_buf_len = size;
+		g_log_buf = new_log_buf;
 
-		offset = start = min(con_start, log_start);
+		offset = start = min(con_start, g_log_start);
 		dest_idx = 0;
-		while (start != log_end) {
-			log_buf[dest_idx] = __log_buf[start & (__LOG_BUF_LEN - 1)];
+		while (start != g_log_end) {
+			g_log_buf[dest_idx] = g_log_buf[start & (__LOG_BUF_LEN - 1)];
 			start++;
 			dest_idx++;
 		}
-		log_start -= offset;
+		g_log_start -= offset;
 		con_start -= offset;
-		log_end -= offset;
+		g_log_end -= offset;
 		spin_unlock_irqrestore(&logbuf_lock, flags);
 
-		printk(KERN_NOTICE "log_buf_len: %d\n", log_buf_len);
+		printk(KERN_NOTICE "log_buf_len: %d\n", g_log_buf_len);
 	}
 out:
 	return 1;
@@ -279,6 +282,7 @@ int do_syslog(int type, char __user *buf, int len)
 	int do_clear = 0;
 	char c;
 	int error = 0;
+	struct syslog_ns *syslog_ns = current_user_ns()->syslog;
 
 	error = security_syslog(type);
 	if (error)
@@ -300,15 +304,17 @@ int do_syslog(int type, char __user *buf, int len)
 			error = -EFAULT;
 			goto out;
 		}
-		error = wait_event_interruptible(log_wait,
-							(log_start - log_end));
+		error = wait_event_interruptible(syslog_ns->wait,
+					(syslog_ns->start - syslog_ns->end));
 		if (error)
 			goto out;
 		i = 0;
 		spin_lock_irq(&logbuf_lock);
-		while (!error && (log_start != log_end) && i < len) {
-			c = LOG_BUF(log_start);
-			log_start++;
+		while (!error &&
+				(syslog_ns->start != syslog_ns->end)
+				&& i < len) {
+			c = LOG_BUF(syslog_ns, syslog_ns->start);
+			syslog_ns->start++;
 			spin_unlock_irq(&logbuf_lock);
 			error = __put_user(c,buf);
 			buf++;
@@ -335,14 +341,14 @@ int do_syslog(int type, char __user *buf, int len)
 			goto out;
 		}
 		count = len;
-		if (count > log_buf_len)
-			count = log_buf_len;
+		if (count > syslog_ns->buf_len)
+			count = syslog_ns->buf_len;
 		spin_lock_irq(&logbuf_lock);
-		if (count > logged_chars)
-			count = logged_chars;
+		if (count > syslog_ns->logged_chars)
+			count = syslog_ns->logged_chars;
 		if (do_clear)
-			logged_chars = 0;
-		limit = log_end;
+			syslog_ns->logged_chars = 0;
+		limit = syslog_ns->end;
 		/*
 		 * __put_user() could sleep, and while we sleep
 		 * printk() could overwrite the messages
@@ -351,9 +357,9 @@ int do_syslog(int type, char __user *buf, int len)
 		 */
 		for (i = 0; i < count && !error; i++) {
 			j = limit-1-i;
-			if (j + log_buf_len < log_end)
+			if (j + syslog_ns->buf_len < syslog_ns->end)
 				break;
-			c = LOG_BUF(j);
+			c = LOG_BUF(syslog_ns, j);
 			spin_unlock_irq(&logbuf_lock);
 			error = __put_user(c,&buf[count-1-i]);
 			cond_resched();
@@ -377,20 +383,32 @@ int do_syslog(int type, char __user *buf, int len)
 		}
 		break;
 	case 5:		/* Clear ring buffer */
-		logged_chars = 0;
+		syslog_ns->logged_chars = 0;
 		break;
 	case 6:		/* Disable logging to console */
+		if (syslog_ns != &init_syslog_ns) {
+			error = -EPERM;
+			break;
+		}
 		if (saved_console_loglevel == -1)
 			saved_console_loglevel = console_loglevel;
 		console_loglevel = minimum_console_loglevel;
 		break;
 	case 7:		/* Enable logging to console */
+		if (syslog_ns != &init_syslog_ns) {
+			error = -EPERM;
+			break;
+		}
 		if (saved_console_loglevel != -1) {
 			console_loglevel = saved_console_loglevel;
 			saved_console_loglevel = -1;
 		}
 		break;
 	case 8:		/* Set level of messages printed to console */
+		if (syslog_ns != &init_syslog_ns) {
+			error = -EPERM;
+			break;
+		}
 		error = -EINVAL;
 		if (len < 1 || len > 8)
 			goto out;
@@ -402,10 +420,10 @@ int do_syslog(int type, char __user *buf, int len)
 		error = 0;
 		break;
 	case 9:		/* Number of chars in the log buffer */
-		error = log_end - log_start;
+		error = syslog_ns->end - syslog_ns->start;
 		break;
 	case 10:	/* Size of the log buffer */
-		error = log_buf_len;
+		error = syslog_ns->buf_len;
 		break;
 	default:
 		error = -EINVAL;
@@ -421,7 +439,7 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
 }
 
 /*
- * Call the console drivers on a range of log_buf
+ * Call the console drivers on a range of g_log_buf
  */
 static void __call_console_drivers(unsigned start, unsigned end)
 {
@@ -431,7 +449,8 @@ static void __call_console_drivers(unsigned start, unsigned end)
 		if ((con->flags & CON_ENABLED) && con->write &&
 				(cpu_online(smp_processor_id()) ||
 				(con->flags & CON_ANYTIME)))
-			con->write(con, &LOG_BUF(start), end - start);
+			con->write(con, &LOG_BUF(&init_syslog_ns, start),
+					end - start);
 	}
 }
 
@@ -455,11 +474,14 @@ static void _call_console_drivers(unsigned start,
 {
 	if ((msg_log_level < console_loglevel || ignore_loglevel) &&
 			console_drivers && start != end) {
-		if ((start & LOG_BUF_MASK) > (end & LOG_BUF_MASK)) {
+		if ((start & LOG_BUF_MASK(&init_syslog_ns)) >
+				(end & LOG_BUF_MASK(&init_syslog_ns))) {
 			/* wrapped write */
-			__call_console_drivers(start & LOG_BUF_MASK,
-						log_buf_len);
-			__call_console_drivers(0, end & LOG_BUF_MASK);
+			__call_console_drivers(start &
+						LOG_BUF_MASK(&init_syslog_ns),
+						g_log_buf_len);
+			__call_console_drivers(0,
+				end & LOG_BUF_MASK(&init_syslog_ns));
 		} else {
 			__call_console_drivers(start, end);
 		}
@@ -468,13 +490,14 @@ static void _call_console_drivers(unsigned start,
 
 /*
  * Call the console drivers, asking them to write out
- * log_buf[start] to log_buf[end - 1].
+ * g_log_buf[start] to g_log_buf[end - 1].
  * The console_sem must be held.
  */
 static void call_console_drivers(unsigned start, unsigned end)
 {
 	unsigned cur_index, start_print;
 	static int msg_level = -1;
+	static struct syslog_ns *ns = &init_syslog_ns;
 
 	BUG_ON(((int)(start - end)) > 0);
 
@@ -482,16 +505,16 @@ static void call_console_drivers(unsigned start, unsigned end)
 	start_print = start;
 	while (cur_index != end) {
 		if (msg_level < 0 && ((end - cur_index) > 2) &&
-				LOG_BUF(cur_index + 0) == '<' &&
-				LOG_BUF(cur_index + 1) >= '0' &&
-				LOG_BUF(cur_index + 1) <= '7' &&
-				LOG_BUF(cur_index + 2) == '>') {
-			msg_level = LOG_BUF(cur_index + 1) - '0';
+				LOG_BUF(ns, cur_index + 0) == '<' &&
+				LOG_BUF(ns, cur_index + 1) >= '0' &&
+				LOG_BUF(ns, cur_index + 1) <= '7' &&
+				LOG_BUF(ns, cur_index + 2) == '>') {
+			msg_level = LOG_BUF(ns, cur_index + 1) - '0';
 			cur_index += 3;
 			start_print = cur_index;
 		}
 		while (cur_index != end) {
-			char c = LOG_BUF(cur_index);
+			char c = LOG_BUF(ns, cur_index);
 
 			cur_index++;
 			if (c == '\n') {
@@ -514,16 +537,26 @@ static void call_console_drivers(unsigned start, unsigned end)
 	_call_console_drivers(start_print, end, msg_level);
 }
 
+static void do_emit_log_char(struct syslog_ns *ns, char c)
+{
+	LOG_BUF(ns, ns->end) = c;
+	ns->end++;
+	if (ns->end - ns->start > ns->buf_len)
+		ns->start = ns->end - ns->buf_len;
+	if (ns == &init_syslog_ns) {
+		if (g_log_end - con_start > g_log_buf_len)
+			con_start = g_log_end - g_log_buf_len;
+	}
+	if (ns->logged_chars < ns->buf_len)
+		ns->logged_chars++;
+}
+
 static void emit_log_char(char c)
 {
-	LOG_BUF(log_end) = c;
-	log_end++;
-	if (log_end - log_start > log_buf_len)
-		log_start = log_end - log_buf_len;
-	if (log_end - con_start > log_buf_len)
-		con_start = log_end - log_buf_len;
-	if (logged_chars < log_buf_len)
-		logged_chars++;
+	struct syslog_ns *ns = current_user_ns()->syslog;
+	if (ns != &init_syslog_ns)
+		do_emit_log_char(ns,c);
+	do_emit_log_char(&init_syslog_ns, c);
 }
 
 /*
@@ -669,6 +702,25 @@ static inline void printk_delay(void)
 	}
 }
 
+/* called from create_user_ns() */
+struct syslog_ns * do_syslog_init(void)
+{
+	struct syslog_ns *ns;
+
+	ns = kzalloc(sizeof(*ns), GFP_KERNEL);
+	if (!ns)
+		return ERR_PTR(-ENOMEM);
+	ns->buf = kzalloc(CONTAINER_BUF_LEN, GFP_KERNEL);
+	if (!ns->buf) {
+		kfree(ns);
+		return ERR_PTR(-ENOMEM);
+	}
+	init_waitqueue_head(&ns->wait);
+	ns->buf_len = CONTAINER_BUF_LEN;
+
+	return ns;
+}
+
 asmlinkage int vprintk(const char *fmt, va_list args)
 {
 	int printed_len = 0;
@@ -676,6 +728,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	unsigned long flags;
 	int this_cpu;
 	char *p;
+	struct syslog_ns *syslog_ns;
 
 	boot_delay_msec();
 	printk_delay();
@@ -741,7 +794,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	}
 
 	/*
-	 * Copy the output into log_buf.  If the caller didn't provide
+	 * Copy the output into g_log_buf.  If the caller didn't provide
 	 * appropriate log level tags, we insert them here
 	 */
 	for ( ; *p; p++) {
@@ -790,7 +843,13 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 	 * will release 'logbuf_lock' regardless of whether it
 	 * actually gets the semaphore or not.
 	 */
-	if (acquire_console_semaphore_for_printk(this_cpu))
+	syslog_ns = current_user_ns()->syslog;
+	if (syslog_ns != &init_syslog_ns) {
+		int need_wake = (syslog_ns->start != syslog_ns->end);
+		spin_unlock_irqrestore(&logbuf_lock, flags);
+		if (!oops_in_progress && need_wake)
+			wake_up_interruptible(&syslog_ns->wait);
+	} else if (acquire_console_semaphore_for_printk(this_cpu))
 		release_console_sem();
 
 	lockdep_on();
@@ -811,6 +870,14 @@ static void call_console_drivers(unsigned start, unsigned end)
 
 #endif
 
+/*  init_syslog_ns is part of init_user_ns */
+/* note this does not work for !CONFIG_PRINTK */
+struct syslog_ns init_syslog_ns = {
+	.wait = __WAIT_QUEUE_HEAD_INITIALIZER(init_syslog_ns.wait),
+	.buf_len = __LOG_BUF_LEN,
+	.buf = __log_buf,
+};
+
 static int __add_preferred_console(char *name, int idx, char *options,
 				   char *brl_options)
 {
@@ -1010,7 +1077,7 @@ void printk_tick(void)
 {
 	if (__get_cpu_var(printk_pending)) {
 		__get_cpu_var(printk_pending) = 0;
-		wake_up_interruptible(&log_wait);
+		wake_up_interruptible(&g_log_wait);
 	}
 }
 
@@ -1021,7 +1088,7 @@ int printk_needs_cpu(int cpu)
 
 void wake_up_klogd(void)
 {
-	if (waitqueue_active(&log_wait))
+	if (waitqueue_active(&g_log_wait))
 		__raw_get_cpu_var(printk_pending) = 1;
 }
 
@@ -1054,12 +1121,12 @@ void release_console_sem(void)
 
 	for ( ; ; ) {
 		spin_lock_irqsave(&logbuf_lock, flags);
-		wake_klogd |= log_start - log_end;
-		if (con_start == log_end)
+		wake_klogd |= g_log_start - g_log_end;
+		if (con_start == g_log_end)
 			break;			/* Nothing to print */
 		_con_start = con_start;
-		_log_end = log_end;
-		con_start = log_end;		/* Flush */
+		_log_end = g_log_end;
+		con_start = g_log_end;		/* Flush */
 		spin_unlock(&logbuf_lock);
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(_con_start, _log_end);
@@ -1287,7 +1354,7 @@ void register_console(struct console *newcon)
 		 * for us.
 		 */
 		spin_lock_irqsave(&logbuf_lock, flags);
-		con_start = log_start;
+		con_start = g_log_start;
 		spin_unlock_irqrestore(&logbuf_lock, flags);
 	}
 	release_console_sem();
@@ -1498,22 +1565,22 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 	   there's not a lot we can do about that. The new messages
 	   will overwrite the start of what we dump. */
 	spin_lock_irqsave(&logbuf_lock, flags);
-	end = log_end & LOG_BUF_MASK;
-	chars = logged_chars;
+	end = g_log_end & LOG_BUF_MASK(&init_syslog_ns);
+	chars = g_logged_chars;
 	spin_unlock_irqrestore(&logbuf_lock, flags);
 
-	if (logged_chars > end) {
-		s1 = log_buf + log_buf_len - logged_chars + end;
-		l1 = logged_chars - end;
+	if (g_logged_chars > end) {
+		s1 = g_log_buf + g_log_buf_len - g_logged_chars + end;
+		l1 = g_logged_chars - end;
 
-		s2 = log_buf;
+		s2 = g_log_buf;
 		l2 = end;
 	} else {
 		s1 = "";
 		l1 = 0;
 
-		s2 = log_buf + end - logged_chars;
-		l2 = logged_chars;
+		s2 = g_log_buf + end - g_logged_chars;
+		l2 = g_logged_chars;
 	}
 
 	if (!spin_trylock_irqsave(&dump_list_lock, flags)) {
diff --git a/kernel/user.c b/kernel/user.c
index 46d0165..102c2ce 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -18,11 +18,15 @@
 #include <linux/user_namespace.h>
 #include "cred-internals.h"
 
+/* defined in kernel/printk.c */
+extern struct syslog_ns init_syslog_ns;
+
 struct user_namespace init_user_ns = {
 	.kref = {
 		.refcount	= ATOMIC_INIT(2),
 	},
 	.creator = &root_user,
+	.syslog = &init_syslog_ns,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..43d46d1 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -11,6 +11,9 @@
 #include <linux/user_namespace.h>
 #include <linux/cred.h>
 
+/* defined in kernel/printk.c */
+extern struct syslog_ns *do_syslog_init(void);
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -34,9 +37,17 @@ int create_user_ns(struct cred *new)
 	for (n = 0; n < UIDHASH_SZ; ++n)
 		INIT_HLIST_HEAD(ns->uidhash_table + n);
 
+	ns->syslog = do_syslog_init();
+	if (!ns->syslog) {
+		kfree(ns);
+		return -ENOMEM;
+	}
+
 	/* Alloc new root user.  */
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
+		kfree(ns->syslog->buf);
+		kfree(ns->syslog);
 		kfree(ns);
 		return -ENOMEM;
 	}
@@ -70,6 +81,8 @@ static void free_user_ns_work(struct work_struct *work)
 	struct user_namespace *ns =
 		container_of(work, struct user_namespace, destroyer);
 	free_uid(ns->creator);
+	kfree(ns->syslog->buf);
+	kfree(ns->syslog);
 	kfree(ns);
 }
 
-- 
1.6.1
