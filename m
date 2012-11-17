From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH RFC] syslog ns proof of concept
Date: Fri, 16 Nov 2012 18:25:19 -0600
Message-ID: <20121117002519.GA26782@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, =?iso-8859-1?Q?St=E9phane?= Graber <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Introduce a system log namespace.  The syslog ns is tied to a user
namespace.  You must create a new user namespace before you can create a
new sylog ns.  The syslog ns is created through a new command (11) to
the __NR_syslog system call.

Once a task enters a new syslog ns, it's "dmesg", "dmesg -c" and
/dev/kmsg actions affect only itself, so that user-created syslog
messages no longer are confusingly combined in the host's syslog.
"printk" itself always goes to the initial syslog_ns, and consoles
belong only to the initial syslog_ns.  However printks relating to a
specific network namespace, for instance, can now be targeted to the
syslog ns for the user ns which owns the network ns, aiding in debugging
in a container.

This patch is on top of the user namespace enhanced kernel at
git://kernel.ubuntu.com/serge/quantal-userns.  It is good enough to
compile with stock ubuntu kernel options, boot, launch other syslog
namespaces and exercise them.  It will need help before it will compile
with funky options like CONFIG_PRINTK=n.  This is only being sent out to
get feedback on the general idea.

Comments greatly appreciated.

(See https://wiki.ubuntu.com/LxcSyslogNs for background).

Signed-off-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 fs/proc/kmsg.c                 |   12 +-
 include/linux/printk.h         |    1 -
 include/linux/syslog.h         |   70 +++++-
 include/linux/user_namespace.h |    1 +
 kernel/printk.c                |  530 +++++++++++++++++++++++-----------------
 kernel/sysctl.c                |    3 +-
 kernel/user.c                  |    3 +
 kernel/user_namespace.c        |    3 +
 8 files changed, 392 insertions(+), 231 deletions(-)

diff --git a/fs/proc/kmsg.c b/fs/proc/kmsg.c
index bd4b5a7..3ba594c 100644
--- a/fs/proc/kmsg.c
+++ b/fs/proc/kmsg.c
@@ -13,6 +13,8 @@
 #include <linux/proc_fs.h>
 #include <linux/fs.h>
 #include <linux/syslog.h>
+#include <linux/cred.h>
+#include <linux/user_namespace.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -21,12 +23,12 @@ extern wait_queue_head_t log_wait;
 
 static int kmsg_open(struct inode * inode, struct file * file)
 {
-	return do_syslog(SYSLOG_ACTION_OPEN, NULL, 0, SYSLOG_FROM_FILE);
+	return do_syslog(file->f_cred->user_ns->syslog_ns, SYSLOG_ACTION_OPEN, NULL, 0, SYSLOG_FROM_FILE);
 }
 
 static int kmsg_release(struct inode * inode, struct file * file)
 {
-	(void) do_syslog(SYSLOG_ACTION_CLOSE, NULL, 0, SYSLOG_FROM_FILE);
+	(void) do_syslog(file->f_cred->user_ns->syslog_ns, SYSLOG_ACTION_CLOSE, NULL, 0, SYSLOG_FROM_FILE);
 	return 0;
 }
 
@@ -34,15 +36,15 @@ static ssize_t kmsg_read(struct file *file, char __user *buf,
 			 size_t count, loff_t *ppos)
 {
 	if ((file->f_flags & O_NONBLOCK) &&
-	    !do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_FILE))
+	    !do_syslog(file->f_cred->user_ns->syslog_ns, SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_FILE))
 		return -EAGAIN;
-	return do_syslog(SYSLOG_ACTION_READ, buf, count, SYSLOG_FROM_FILE);
+	return do_syslog(file->f_cred->user_ns->syslog_ns, SYSLOG_ACTION_READ, buf, count, SYSLOG_FROM_FILE);
 }
 
 static unsigned int kmsg_poll(struct file *file, poll_table *wait)
 {
 	poll_wait(file, &log_wait, wait);
-	if (do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_FILE))
+	if (do_syslog(file->f_cred->user_ns->syslog_ns, SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_FILE))
 		return POLLIN | POLLRDNORM;
 	return 0;
 }
diff --git a/include/linux/printk.h b/include/linux/printk.h
index 9afc01e..70f8380 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -134,7 +134,6 @@ extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
 				   unsigned int interval_msec);
 
 extern int printk_delay_msec;
-extern int dmesg_restrict;
 extern int kptr_restrict;
 
 void log_buf_kexec_setup(void);
diff --git a/include/linux/syslog.h b/include/linux/syslog.h
index 3891139..b653870 100644
--- a/include/linux/syslog.h
+++ b/include/linux/syslog.h
@@ -44,9 +44,77 @@
 /* Return size of the log buffer */
 #define SYSLOG_ACTION_SIZE_BUFFER   10
 
+#define SYSLOG_ACTION_NEW_NS   11
+
 #define SYSLOG_FROM_CALL 0
 #define SYSLOG_FROM_FILE 1
 
-int do_syslog(int type, char __user *buf, int count, bool from_file);
+enum log_flags {
+	LOG_NOCONS	= 1,	/* already flushed, do not print to console */
+	LOG_NEWLINE	= 2,	/* text ended with a newline */
+	LOG_PREFIX	= 4,	/* text started with a prefix */
+	LOG_CONT	= 8,	/* text is a fragment of a continuation line */
+};
+
+
+struct syslog_ns {
+        unsigned buf_len;	/* buffer available space size				*/
+        char *buf;		/* allocated ring buffer				*/
+
+	/* the next printk record to read by syslog(READ) or /proc/kmsg */
+	u64 syslog_seq;
+	u32 syslog_idx;
+	enum log_flags syslog_prev;
+	size_t syslog_partial;
+
+	/* index and sequence number of the first record stored in the buffer */
+	u64 first_seq;
+	u32 first_idx;
+
+	/* index and sequence number of the next record to store in the buffer */
+	u64 next_seq;
+	u32 next_idx;
+
+	/* the next printk record to read after the last 'clear' command */
+	u64 clear_seq;
+	u32 clear_idx;
+
+	int dmesg_restrict;
+
+	/*
+	 * user namesapce which owns this ns.  It and its ancestors have
+	 * privilege over the syslog_ns.  The userns pins the syslog_ns, so
+	 * syslog_ns can't pin user_ns.  It doesn't need to as we'll only
+	 * use ->owner when a task in the syslog_ns (which must be in ->owner
+	 * or a child thereof, therefore keeping ->owner alive) is calling
+	 * do_syslog().
+	 */
+	struct user_namespace *owner;
+	struct kref kref;
+};
+
+static inline struct syslog_ns *get_syslog_ns(struct syslog_ns *ns)
+{
+	if (ns)
+		kref_get(&ns->kref);
+	return ns;
+}
+
+static inline void free_syslog_ns(struct kref *kref)
+{
+	struct syslog_ns *ns = container_of(kref, struct syslog_ns, kref);
+
+	kfree(ns->buf);
+	kfree(ns);
+}
+
+static inline void put_syslog_ns(struct syslog_ns *ns)
+{
+	if (ns)
+		kref_put(&ns->kref, free_syslog_ns);
+}
+int do_syslog(struct syslog_ns *, int type, char __user *buf, int count, bool from_file);
+
+extern struct syslog_ns init_syslog_ns;
 
 #endif /* _LINUX_SYSLOG_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b9bd2e6..8aebb8b 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -26,6 +26,7 @@ struct user_namespace {
 	kuid_t			owner;
 	kgid_t			group;
 	unsigned int		proc_inum;
+	struct syslog_ns	*syslog_ns;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/printk.c b/kernel/printk.c
index 2d607f4..d5fc682 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -42,6 +42,9 @@
 #include <linux/notifier.h>
 #include <linux/rculist.h>
 #include <linux/poll.h>
+#include <linux/spinlock_types.h>
+#include <linux/wait.h>
+#include <linux/user_namespace.h>
 
 #include <asm/uaccess.h>
 
@@ -193,13 +196,6 @@ static int console_may_schedule;
  * separated by ',', and find the message after the ';' character.
  */
 
-enum log_flags {
-	LOG_NOCONS	= 1,	/* already flushed, do not print to console */
-	LOG_NEWLINE	= 2,	/* text ended with a newline */
-	LOG_PREFIX	= 4,	/* text started with a prefix */
-	LOG_CONT	= 8,	/* text is a fragment of a continuation line */
-};
-
 struct log {
 	u64 ts_nsec;		/* timestamp in nanoseconds */
 	u16 len;		/* length of entire record */
@@ -217,28 +213,11 @@ struct log {
 static DEFINE_RAW_SPINLOCK(logbuf_lock);
 
 #ifdef CONFIG_PRINTK
-/* the next printk record to read by syslog(READ) or /proc/kmsg */
-static u64 syslog_seq;
-static u32 syslog_idx;
-static enum log_flags syslog_prev;
-static size_t syslog_partial;
-
-/* index and sequence number of the first record stored in the buffer */
-static u64 log_first_seq;
-static u32 log_first_idx;
-
-/* index and sequence number of the next record to store in the buffer */
-static u64 log_next_seq;
-static u32 log_next_idx;
-
 /* the next printk record to write to the console */
 static u64 console_seq;
 static u32 console_idx;
 static enum log_flags console_prev;
 
-/* the next printk record to read after the last 'clear' command */
-static u64 clear_seq;
-static u32 clear_idx;
 
 #define PREFIX_MAX		32
 #define LOG_LINE_MAX		1024 - PREFIX_MAX
@@ -249,12 +228,29 @@ static u32 clear_idx;
 #else
 #define LOG_ALIGN __alignof__(struct log)
 #endif
+
+/* log_buf for init_syslog_ns */
 #define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
 static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
-static char *log_buf = __log_buf;
-static u32 log_buf_len = __LOG_BUF_LEN;
 
-/* cpu currently holding logbuf_lock */
+struct syslog_ns init_syslog_ns = {
+	.buf = __log_buf,
+	.buf_len = __LOG_BUF_LEN,
+	.owner = &init_user_ns,
+	.kref = {
+		.refcount	= ATOMIC_INIT(2),  // one for init_user_ns, one for cont
+	},
+#ifdef CONFIG_SECURITY_DMESG_RESTRICT
+	.dmesg_restrict = 1,
+#else
+	.dmesg_restrict = 0,
+#endif
+};
+
+#define LOG_BUF_MASK(ns) ((ns)->buf_len-1)
+#define LOG_BUF(ns, idx) ((ns)->buf[(idx) & LOG_BUF_MASK(ns)])
+
+/* cpu currently holding lock */
 static volatile unsigned int logbuf_cpu = UINT_MAX;
 
 /* human readable text of the record */
@@ -270,23 +266,23 @@ static char *log_dict(const struct log *msg)
 }
 
 /* get record by index; idx must point to valid msg */
-static struct log *log_from_idx(u32 idx)
+static struct log *log_from_idx(struct syslog_ns *ns, u32 idx)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(ns->buf + idx);
 
 	/*
 	 * A length == 0 record is the end of buffer marker. Wrap around and
 	 * read the message at the start of the buffer.
 	 */
 	if (!msg->len)
-		return (struct log *)log_buf;
+		return (struct log *)ns->buf;
 	return msg;
 }
 
 /* get next record; idx must point to valid msg */
-static u32 log_next(u32 idx)
+static u32 log_next(struct syslog_ns *ns, u32 idx)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(ns->buf + idx);
 
 	/* length == 0 indicates the end of the buffer; wrap */
 	/*
@@ -295,14 +291,14 @@ static u32 log_next(u32 idx)
 	 * return the one after that.
 	 */
 	if (!msg->len) {
-		msg = (struct log *)log_buf;
+		msg = (struct log *)ns->buf;
 		return msg->len;
 	}
 	return idx + msg->len;
 }
 
 /* insert record into the buffer, discard old ones, update heads */
-static void log_store(int facility, int level,
+static void log_store(struct syslog_ns *ns, int facility, int level,
 		      enum log_flags flags, u64 ts_nsec,
 		      const char *dict, u16 dict_len,
 		      const char *text, u16 text_len)
@@ -315,34 +311,34 @@ static void log_store(int facility, int level,
 	pad_len = (-size) & (LOG_ALIGN - 1);
 	size += pad_len;
 
-	while (log_first_seq < log_next_seq) {
+	while (ns->first_seq < ns->next_seq) {
 		u32 free;
 
-		if (log_next_idx > log_first_idx)
-			free = max(log_buf_len - log_next_idx, log_first_idx);
+		if (ns->next_idx > ns->first_idx)
+			free = max(ns->buf_len - ns->next_idx, ns->first_idx);
 		else
-			free = log_first_idx - log_next_idx;
+			free = ns->first_idx - ns->next_idx;
 
 		if (free > size + sizeof(struct log))
 			break;
 
 		/* drop old messages until we have enough contiuous space */
-		log_first_idx = log_next(log_first_idx);
-		log_first_seq++;
+		ns->first_idx = log_next(ns, ns->first_idx);
+		ns->first_seq++;
 	}
 
-	if (log_next_idx + size + sizeof(struct log) >= log_buf_len) {
+	if (ns->next_idx + size + sizeof(struct log) >= ns->buf_len) {
 		/*
 		 * This message + an additional empty header does not fit
 		 * at the end of the buffer. Add an empty header with len == 0
 		 * to signify a wrap around.
 		 */
-		memset(log_buf + log_next_idx, 0, sizeof(struct log));
-		log_next_idx = 0;
+		memset(ns->buf + ns->next_idx, 0, sizeof(struct log));
+		ns->next_idx = 0;
 	}
 
 	/* fill message */
-	msg = (struct log *)(log_buf + log_next_idx);
+	msg = (struct log *)(ns->buf + ns->next_idx);
 	memcpy(log_text(msg), text, text_len);
 	msg->text_len = text_len;
 	memcpy(log_dict(msg), dict, dict_len);
@@ -358,8 +354,8 @@ static void log_store(int facility, int level,
 	msg->len = sizeof(struct log) + text_len + dict_len + pad_len;
 
 	/* insert message */
-	log_next_idx += msg->len;
-	log_next_seq++;
+	ns->next_idx += msg->len;
+	ns->next_seq++;
 }
 
 /* /dev/kmsg - userspace message inject/listen interface */
@@ -437,6 +433,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	char cont = '-';
 	size_t len;
 	ssize_t ret;
+	struct syslog_ns *ns = file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return -EBADF;
@@ -445,7 +442,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	if (ret)
 		return ret;
 	raw_spin_lock_irq(&logbuf_lock);
-	while (user->seq == log_next_seq) {
+	while (user->seq == ns->next_seq) {
 		if (file->f_flags & O_NONBLOCK) {
 			ret = -EAGAIN;
 			raw_spin_unlock_irq(&logbuf_lock);
@@ -454,22 +451,22 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 
 		raw_spin_unlock_irq(&logbuf_lock);
 		ret = wait_event_interruptible(log_wait,
-					       user->seq != log_next_seq);
+					       user->seq != ns->next_seq);
 		if (ret)
 			goto out;
 		raw_spin_lock_irq(&logbuf_lock);
 	}
 
-	if (user->seq < log_first_seq) {
+	if (user->seq < ns->first_seq) {
 		/* our last seen message is gone, return error and reset */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = ns->first_idx;
+		user->seq = ns->first_seq;
 		ret = -EPIPE;
 		raw_spin_unlock_irq(&logbuf_lock);
 		goto out;
 	}
 
-	msg = log_from_idx(user->idx);
+	msg = log_from_idx(ns, user->idx);
 	ts_usec = msg->ts_nsec;
 	do_div(ts_usec, 1000);
 
@@ -530,7 +527,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 		user->buf[len++] = '\n';
 	}
 
-	user->idx = log_next(user->idx);
+	user->idx = log_next(ns, user->idx);
 	user->seq++;
 	raw_spin_unlock_irq(&logbuf_lock);
 
@@ -553,6 +550,7 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct devkmsg_user *user = file->private_data;
 	loff_t ret = 0;
+	struct syslog_ns *ns = file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return -EBADF;
@@ -563,8 +561,8 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 	switch (whence) {
 	case SEEK_SET:
 		/* the first record */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = ns->first_idx;
+		user->seq = ns->first_seq;
 		break;
 	case SEEK_DATA:
 		/*
@@ -572,13 +570,13 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 		 * like issued by 'dmesg -c'. Reading /dev/kmsg itself
 		 * changes no global state, and does not clear anything.
 		 */
-		user->idx = clear_idx;
-		user->seq = clear_seq;
+		user->idx = ns->clear_idx;
+		user->seq = ns->clear_seq;
 		break;
 	case SEEK_END:
 		/* after the last record */
-		user->idx = log_next_idx;
-		user->seq = log_next_seq;
+		user->idx = ns->next_idx;
+		user->seq = ns->next_seq;
 		break;
 	default:
 		ret = -EINVAL;
@@ -591,6 +589,7 @@ static unsigned int devkmsg_poll(struct file *file, poll_table *wait)
 {
 	struct devkmsg_user *user = file->private_data;
 	int ret = 0;
+	struct syslog_ns *ns = file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return POLLERR|POLLNVAL;
@@ -598,9 +597,9 @@ static unsigned int devkmsg_poll(struct file *file, poll_table *wait)
 	poll_wait(file, &log_wait, wait);
 
 	raw_spin_lock_irq(&logbuf_lock);
-	if (user->seq < log_next_seq) {
+	if (user->seq < ns->next_seq) {
 		/* return error when data has vanished underneath us */
-		if (user->seq < log_first_seq)
+		if (user->seq < ns->first_seq)
 			ret = POLLIN|POLLRDNORM|POLLERR|POLLPRI;
 		ret = POLLIN|POLLRDNORM;
 	}
@@ -613,6 +612,7 @@ static int devkmsg_open(struct inode *inode, struct file *file)
 {
 	struct devkmsg_user *user;
 	int err;
+	struct syslog_ns *ns = file->f_cred->user_ns->syslog_ns;
 
 	/* write-only does not need any file context */
 	if ((file->f_flags & O_ACCMODE) == O_WRONLY)
@@ -629,8 +629,8 @@ static int devkmsg_open(struct inode *inode, struct file *file)
 	mutex_init(&user->lock);
 
 	raw_spin_lock_irq(&logbuf_lock);
-	user->idx = log_first_idx;
-	user->seq = log_first_seq;
+	user->idx = ns->first_idx;
+	user->seq = ns->first_seq;
 	raw_spin_unlock_irq(&logbuf_lock);
 
 	file->private_data = user;
@@ -669,10 +669,12 @@ const struct file_operations kmsg_fops = {
  */
 void log_buf_kexec_setup(void)
 {
-	VMCOREINFO_SYMBOL(log_buf);
-	VMCOREINFO_SYMBOL(log_buf_len);
-	VMCOREINFO_SYMBOL(log_first_idx);
-	VMCOREINFO_SYMBOL(log_next_idx);
+	struct syslog_ns *ns = &init_syslog_ns;
+
+	VMCOREINFO_SYMBOL(logbuf_lock);
+	VMCOREINFO_SYMBOL(ns->buf_len);
+	VMCOREINFO_SYMBOL(ns->first_idx);
+	VMCOREINFO_SYMBOL(ns->next_idx);
 	/*
 	 * Export struct log size and field offsets. User space tools can
 	 * parse it and detect any changes to structure down the line.
@@ -695,7 +697,7 @@ static int __init log_buf_len_setup(char *str)
 
 	if (size)
 		size = roundup_pow_of_two(size);
-	if (size > log_buf_len)
+	if (size > __LOG_BUF_LEN)
 		new_log_buf_len = size;
 
 	return 0;
@@ -729,14 +731,14 @@ void __init setup_log_buf(int early)
 	}
 
 	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	log_buf_len = new_log_buf_len;
-	log_buf = new_log_buf;
+	init_syslog_ns.buf_len = new_log_buf_len;
+	init_syslog_ns.buf = new_log_buf;
 	new_log_buf_len = 0;
-	free = __LOG_BUF_LEN - log_next_idx;
-	memcpy(log_buf, __log_buf, __LOG_BUF_LEN);
+	free = __LOG_BUF_LEN - init_syslog_ns.next_idx;
+	memcpy(&init_syslog_ns.buf, __log_buf, __LOG_BUF_LEN);
 	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
 
-	pr_info("log_buf_len: %d\n", log_buf_len);
+	pr_info("log_buf_len: %d\n", init_syslog_ns.buf_len);
 	pr_info("early log buf free: %d(%d%%)\n",
 		free, (free * 100) / __LOG_BUF_LEN);
 }
@@ -794,21 +796,15 @@ static inline void boot_delay_msec(void)
 }
 #endif
 
-#ifdef CONFIG_SECURITY_DMESG_RESTRICT
-int dmesg_restrict = 1;
-#else
-int dmesg_restrict;
-#endif
-
-static int syslog_action_restricted(int type)
+static int syslog_action_restricted(struct syslog_ns *ns, int type)
 {
-	if (dmesg_restrict)
+	if (ns->dmesg_restrict)
 		return 1;
 	/* Unless restricted, we allow "read all" and "get buffer size" for everybody */
 	return type != SYSLOG_ACTION_READ_ALL && type != SYSLOG_ACTION_SIZE_BUFFER;
 }
 
-static int check_syslog_permissions(int type, bool from_file)
+static int check_syslog_permissions(struct syslog_ns *ns, int type, bool from_file)
 {
 	/*
 	 * If this is from /proc/kmsg and we've already opened it, then we've
@@ -817,11 +813,22 @@ static int check_syslog_permissions(int type, bool from_file)
 	if (from_file && type != SYSLOG_ACTION_OPEN)
 		return 0;
 
-	if (syslog_action_restricted(type)) {
-		if (capable(CAP_SYSLOG))
+	/*
+	 * we need to check for priv against init_user_ns for
+	 * SYSLOG_ACTION_CONSOLE.
+	 */
+	if (type == SYSLOG_ACTION_CONSOLE_OFF || type == SYSLOG_ACTION_CONSOLE_ON
+	    || type == SYSLOG_ACTION_CONSOLE_LEVEL)
+		ns = &init_syslog_ns;
+
+	if (type == SYSLOG_ACTION_NEW_NS)  // will be at create_syslog_ns()
+		return 0;
+
+	if (syslog_action_restricted(ns, type)) {
+		if (ns_capable(ns->owner, CAP_SYSLOG))
 			return 0;
 		/* For historical reasons, accept CAP_SYS_ADMIN too, with a warning */
-		if (capable(CAP_SYS_ADMIN)) {
+		if (ns_capable(ns->owner, CAP_SYS_ADMIN)) {
 			printk_once(KERN_WARNING "%s (%d): "
 				 "Attempt to access syslog with CAP_SYS_ADMIN "
 				 "but no CAP_SYSLOG (deprecated).\n",
@@ -937,7 +944,7 @@ static size_t msg_print_text(const struct log *msg, enum log_flags prev,
 	return len;
 }
 
-static int syslog_print(char __user *buf, int size)
+static int syslog_print(struct syslog_ns *ns, char __user *buf, int size)
 {
 	char *text;
 	struct log *msg;
@@ -952,33 +959,33 @@ static int syslog_print(char __user *buf, int size)
 		size_t skip;
 
 		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		if (ns->syslog_seq < ns->first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			ns->syslog_seq = ns->first_seq;
+			ns->syslog_idx = ns->first_idx;
+			ns->syslog_prev = 0;
+			ns->syslog_partial = 0;
 		}
-		if (syslog_seq == log_next_seq) {
+		if (ns->syslog_seq == ns->next_seq) {
 			raw_spin_unlock_irq(&logbuf_lock);
 			break;
 		}
 
-		skip = syslog_partial;
-		msg = log_from_idx(syslog_idx);
-		n = msg_print_text(msg, syslog_prev, true, text,
+		skip = ns->syslog_partial;
+		msg = log_from_idx(ns, ns->syslog_idx);
+		n = msg_print_text(msg, ns->syslog_prev, true, text,
 				   LOG_LINE_MAX + PREFIX_MAX);
-		if (n - syslog_partial <= size) {
+		if (n - ns->syslog_partial <= size) {
 			/* message fits into buffer, move forward */
-			syslog_idx = log_next(syslog_idx);
-			syslog_seq++;
-			syslog_prev = msg->flags;
-			n -= syslog_partial;
-			syslog_partial = 0;
+			ns->syslog_idx = log_next(ns, ns->syslog_idx);
+			ns->syslog_seq++;
+			ns->syslog_prev = msg->flags;
+			n -= ns->syslog_partial;
+			ns->syslog_partial = 0;
 		} else if (!len){
 			/* partial read(), remember position */
 			n = size;
-			syslog_partial += n;
+			ns->syslog_partial += n;
 		} else
 			n = 0;
 		raw_spin_unlock_irq(&logbuf_lock);
@@ -1001,7 +1008,7 @@ static int syslog_print(char __user *buf, int size)
 	return len;
 }
 
-static int syslog_print_all(char __user *buf, int size, bool clear)
+static int syslog_print_all(struct syslog_ns *ns, char __user *buf, int size, bool clear)
 {
 	char *text;
 	int len = 0;
@@ -1017,48 +1024,48 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 		u32 idx;
 		enum log_flags prev;
 
-		if (clear_seq < log_first_seq) {
+		if (ns->clear_seq < ns->first_seq) {
 			/* messages are gone, move to first available one */
-			clear_seq = log_first_seq;
-			clear_idx = log_first_idx;
+			ns->clear_seq = ns->first_seq;
+			ns->clear_idx = ns->first_idx;
 		}
 
 		/*
 		 * Find first record that fits, including all following records,
 		 * into the user-provided buffer for this dump.
 		 */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = ns->clear_seq;
+		idx = ns->clear_idx;
 		prev = 0;
-		while (seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (seq < ns->next_seq) {
+			struct log *msg = log_from_idx(ns, idx);
 
 			len += msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(ns, idx);
 			seq++;
 		}
 
 		/* move first record forward until length fits into the buffer */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = ns->clear_seq;
+		idx = ns->clear_idx;
 		prev = 0;
-		while (len > size && seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (len > size && seq < ns->next_seq) {
+			struct log *msg = log_from_idx(ns, idx);
 
 			len -= msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(ns, idx);
 			seq++;
 		}
 
 		/* last message fitting into this dump */
-		next_seq = log_next_seq;
+		next_seq = ns->next_seq;
 
 		len = 0;
 		prev = 0;
 		while (len >= 0 && seq < next_seq) {
-			struct log *msg = log_from_idx(idx);
+			struct log *msg = log_from_idx(ns, idx);
 			int textlen;
 
 			textlen = msg_print_text(msg, prev, true, text,
@@ -1067,7 +1074,7 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 				len = textlen;
 				break;
 			}
-			idx = log_next(idx);
+			idx = log_next(ns, idx);
 			seq++;
 			prev = msg->flags;
 
@@ -1078,18 +1085,18 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 				len += textlen;
 			raw_spin_lock_irq(&logbuf_lock);
 
-			if (seq < log_first_seq) {
+			if (seq < ns->first_seq) {
 				/* messages are gone, move to next one */
-				seq = log_first_seq;
-				idx = log_first_idx;
+				seq = ns->first_seq;
+				idx = ns->first_idx;
 				prev = 0;
 			}
 		}
 	}
 
 	if (clear) {
-		clear_seq = log_next_seq;
-		clear_idx = log_next_idx;
+		ns->clear_seq = ns->next_seq;
+		ns->clear_idx = ns->next_idx;
 	}
 	raw_spin_unlock_irq(&logbuf_lock);
 
@@ -1097,13 +1104,68 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 	return len;
 }
 
-int do_syslog(int type, char __user *buf, int len, bool from_file)
+void free_syslog(struct kref *kref)
+{
+	struct syslog_ns *ns = container_of(kref, struct syslog_ns, kref);
+
+	kfree(ns->buf);
+	kfree(ns);
+}
+
+static DEFINE_SPINLOCK(syslog_ns_lock);
+
+static int create_syslog_ns(void)
+{
+	struct user_namespace *userns = current_user_ns();
+	struct syslog_ns *oldns, *newns;
+	int err;
+
+	/*
+	 * syslog ns belongs to a user ns.  So you can only unshare your
+	 * user_ns if you share a user_ns with your parent userns
+	 */
+	if (userns == &init_user_ns || userns->syslog_ns != userns->parent->syslog_ns)
+		return -EINVAL;
+
+	if (!ns_capable(userns, CAP_SYSLOG))
+		return -EPERM;
+
+	spin_lock(&syslog_ns_lock);
+	err = -ENOMEM;
+	oldns = userns->syslog_ns;
+	newns = kzalloc(sizeof(*newns), GFP_ATOMIC);
+	if (!newns)
+		goto out;
+	newns->buf_len = __LOG_BUF_LEN;  // should be smaller?  XXX
+	newns->buf = kzalloc(newns->buf_len, GFP_ATOMIC);
+	if (!newns->buf)
+		goto out;
+
+	newns->owner = get_user_ns(userns);
+	newns->dmesg_restrict = oldns->dmesg_restrict;
+	put_syslog_ns(oldns);
+	kref_init(&newns->kref);
+	userns->syslog_ns = newns;
+	newns = NULL;
+
+	err = 0;
+
+out:
+	spin_unlock(&syslog_ns_lock);
+	if (newns) {
+		kfree(newns->buf);
+		kfree(newns);
+	}
+	return err;
+}
+
+int do_syslog(struct syslog_ns *ns, int type, char __user *buf, int len, bool from_file)
 {
 	bool clear = false;
 	static int saved_console_loglevel = -1;
 	int error;
 
-	error = check_syslog_permissions(type, from_file);
+	error = check_syslog_permissions(ns, type, from_file);
 	if (error)
 		goto out;
 
@@ -1128,10 +1190,10 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			goto out;
 		}
 		error = wait_event_interruptible(log_wait,
-						 syslog_seq != log_next_seq);
+						 ns->syslog_seq != ns->next_seq);
 		if (error)
 			goto out;
-		error = syslog_print(buf, len);
+		error = syslog_print(ns, buf, len);
 		break;
 	/* Read/clear last kernel messages */
 	case SYSLOG_ACTION_READ_CLEAR:
@@ -1149,11 +1211,11 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			error = -EFAULT;
 			goto out;
 		}
-		error = syslog_print_all(buf, len, clear);
+		error = syslog_print_all(ns, buf, len, clear);
 		break;
 	/* Clear ring buffer */
 	case SYSLOG_ACTION_CLEAR:
-		syslog_print_all(NULL, 0, true);
+		syslog_print_all(ns, NULL, 0, true);
 		break;
 	/* Disable logging to console */
 	case SYSLOG_ACTION_CONSOLE_OFF:
@@ -1183,12 +1245,12 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 	/* Number of chars in the log buffer */
 	case SYSLOG_ACTION_SIZE_UNREAD:
 		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		if (ns->syslog_seq < ns->first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			ns->syslog_seq = ns->first_seq;
+			ns->syslog_idx = ns->first_idx;
+			ns->syslog_prev = 0;
+			ns->syslog_partial = 0;
 		}
 		if (from_file) {
 			/*
@@ -1196,28 +1258,31 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			 * for pending data, not the size; return the count of
 			 * records, not the length.
 			 */
-			error = log_next_idx - syslog_idx;
+			error = ns->next_idx - ns->syslog_idx;
 		} else {
-			u64 seq = syslog_seq;
-			u32 idx = syslog_idx;
-			enum log_flags prev = syslog_prev;
+			u64 seq = ns->syslog_seq;
+			u32 idx = ns->syslog_idx;
+			enum log_flags prev = ns->syslog_prev;
 
 			error = 0;
-			while (seq < log_next_seq) {
-				struct log *msg = log_from_idx(idx);
+			while (seq < ns->next_seq) {
+				struct log *msg = log_from_idx(ns, idx);
 
 				error += msg_print_text(msg, prev, true, NULL, 0);
-				idx = log_next(idx);
+				idx = log_next(ns, idx);
 				seq++;
 				prev = msg->flags;
 			}
-			error -= syslog_partial;
+			error -= ns->syslog_partial;
 		}
 		raw_spin_unlock_irq(&logbuf_lock);
 		break;
 	/* Size of the log buffer */
 	case SYSLOG_ACTION_SIZE_BUFFER:
-		error = log_buf_len;
+		error = ns->buf_len;
+		break;
+	case SYSLOG_ACTION_NEW_NS:
+		error = create_syslog_ns();
 		break;
 	default:
 		error = -EINVAL;
@@ -1229,7 +1294,7 @@ out:
 
 SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
 {
-	return do_syslog(type, buf, len, SYSLOG_FROM_CALL);
+	return do_syslog(current_user_ns()->syslog_ns, type, buf, len, SYSLOG_FROM_CALL);
 }
 
 static bool __read_mostly ignore_loglevel;
@@ -1375,30 +1440,27 @@ static inline void printk_delay(void)
 	}
 }
 
-/*
- * Continuation lines are buffered, and not committed to the record buffer
- * until the line is complete, or a race forces it. The line fragments
- * though, are printed immediately to the consoles to ensure everything has
- * reached the console in case of a kernel crash.
- */
 static struct cont {
 	char buf[LOG_LINE_MAX];
-	size_t len;			/* length == 0 means unused buffer */
-	size_t cons;			/* bytes written to console */
-	struct task_struct *owner;	/* task of first print*/
-	u64 ts_nsec;			/* time of first print */
-	u8 level;			/* log level of first message */
-	u8 facility;			/* log level of first message */
-	enum log_flags flags;		/* prefix, newline flags */
-	bool flushed:1;			/* buffer sealed and committed */
-} cont;
+	size_t len;                     /* length == 0 means unused buffer */
+	size_t cons;                    /* bytes written to console */
+	struct task_struct *owner;      /* task of first print*/
+	u64 ts_nsec;                    /* time of first print */
+	u8 level;                       /* log level of first message */
+	u8 facility;                    /* log level of first message */
+	enum log_flags flags;           /* prefix, newline flags */
+	bool flushed:1;                 /* buffer sealed and committed */
+	struct syslog_ns *ns;		/* namespace this msg belongs to */
+} cont = {
+	.ns = &init_syslog_ns,
+};
 
-static void cont_flush(enum log_flags flags)
+static void cont_flush(struct syslog_ns *ns, enum log_flags flags)
 {
 	if (cont.flushed)
-		return;
+		goto out;
 	if (cont.len == 0)
-		return;
+		goto out;
 
 	if (cont.cons) {
 		/*
@@ -1406,7 +1468,7 @@ static void cont_flush(enum log_flags flags)
 		 * console; wait for the console to pick up the rest of the
 		 * line. LOG_NOCONS suppresses a duplicated output.
 		 */
-		log_store(cont.facility, cont.level, flags | LOG_NOCONS,
+		log_store(cont.ns, cont.facility, cont.level, flags | LOG_NOCONS,
 			  cont.ts_nsec, NULL, 0, cont.buf, cont.len);
 		cont.flags = flags;
 		cont.flushed = true;
@@ -1415,22 +1477,30 @@ static void cont_flush(enum log_flags flags)
 		 * If no fragment of this line ever reached the console,
 		 * just submit it to the store and free the buffer.
 		 */
-		log_store(cont.facility, cont.level, flags, 0,
+		log_store(cont.ns, cont.facility, cont.level, flags, 0,
 			  NULL, 0, cont.buf, cont.len);
 		cont.len = 0;
 	}
+
+out:
+	if (cont.ns != ns) {
+		put_syslog_ns(cont.ns);
+		cont.ns = get_syslog_ns(ns);
+	}
 }
 
-static bool cont_add(int facility, int level, const char *text, size_t len)
+static bool cont_add(struct syslog_ns *ns, int facility, int level, const char *text, size_t len)
 {
 	if (cont.len && cont.flushed)
 		return false;
 
 	if (cont.len + len > sizeof(cont.buf)) {
 		/* the line gets too long, split it up in separate records */
-		cont_flush(LOG_CONT);
+		cont_flush(ns, LOG_CONT);
 		return false;
-	}
+	} else if (cont.len && cont.ns != ns)
+		cont_flush(ns, 0);
+
 
 	if (!cont.len) {
 		cont.facility = facility;
@@ -1440,13 +1510,17 @@ static bool cont_add(int facility, int level, const char *text, size_t len)
 		cont.flags = 0;
 		cont.cons = 0;
 		cont.flushed = false;
+		if (cont.ns != ns) {
+			put_syslog_ns(cont.ns);
+			cont.ns = get_syslog_ns(ns);
+		}
 	}
 
 	memcpy(cont.buf + cont.len, text, len);
 	cont.len += len;
 
 	if (cont.len > (sizeof(cont.buf) * 80) / 100)
-		cont_flush(LOG_CONT);
+		cont_flush(ns, LOG_CONT);
 
 	return true;
 }
@@ -1479,7 +1553,7 @@ static size_t cont_print_text(char *text, size_t size)
 	return textlen;
 }
 
-asmlinkage int vprintk_emit(int facility, int level,
+int nsvprintk_emit(struct syslog_ns *ns, int facility, int level,
 			    const char *dict, size_t dictlen,
 			    const char *fmt, va_list args)
 {
@@ -1528,7 +1602,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 		recursion_bug = 0;
 		printed_len += strlen(recursion_msg);
 		/* emit KERN_CRIT message */
-		log_store(0, 2, LOG_PREFIX|LOG_NEWLINE, 0,
+		log_store(ns, 0, 2, LOG_PREFIX|LOG_NEWLINE, 0,
 			  NULL, 0, recursion_msg, printed_len);
 	}
 
@@ -1576,11 +1650,11 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 * or another task also prints continuation lines.
 		 */
 		if (cont.len && (lflags & LOG_PREFIX || cont.owner != current))
-			cont_flush(LOG_NEWLINE);
+			cont_flush(ns, LOG_NEWLINE);
 
 		/* buffer line if possible, otherwise store it right away */
-		if (!cont_add(facility, level, text, text_len))
-			log_store(facility, level, lflags | LOG_CONT, 0,
+		if (!cont_add(ns, facility, level, text, text_len))
+			log_store(ns, facility, level, lflags | LOG_CONT, 0,
 				  dict, dictlen, text, text_len);
 	} else {
 		bool stored = false;
@@ -1593,12 +1667,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (cont.len && cont.owner == current) {
 			if (!(lflags & LOG_PREFIX))
-				stored = cont_add(facility, level, text, text_len);
-			cont_flush(LOG_NEWLINE);
+				stored = cont_add(ns, facility, level, text, text_len);
+			cont_flush(ns, LOG_NEWLINE);
 		}
 
 		if (!stored)
-			log_store(facility, level, lflags, 0,
+			log_store(ns, facility, level, lflags, 0,
 				  dict, dictlen, text, text_len);
 	}
 	printed_len += text_len;
@@ -1620,6 +1694,14 @@ out_restore_irqs:
 
 	return printed_len;
 }
+
+asmlinkage int vprintk_emit(int facility, int level,
+			    const char *dict, size_t dictlen,
+			    const char *fmt, va_list args)
+{
+	return nsvprintk_emit(&init_syslog_ns, facility, level, dict, dictlen,
+		fmt, args);
+}
 EXPORT_SYMBOL(vprintk_emit);
 
 asmlinkage int vprintk(const char *fmt, va_list args)
@@ -1690,23 +1772,18 @@ EXPORT_SYMBOL(printk);
 #define LOG_LINE_MAX		0
 #define PREFIX_MAX		0
 #define LOG_LINE_MAX 0
-static u64 syslog_seq;
-static u32 syslog_idx;
 static u64 console_seq;
 static u32 console_idx;
-static enum log_flags syslog_prev;
-static u64 log_first_seq;
-static u32 log_first_idx;
-static u64 log_next_seq;
 static enum log_flags console_prev;
 static struct cont {
 	size_t len;
 	size_t cons;
 	u8 level;
 	bool flushed:1;
+	struct syslog_ns *ns;
 } cont;
-static struct log *log_from_idx(u32 idx) { return NULL; }
-static u32 log_next(u32 idx) { return 0; }
+static struct log *log_from_idx(struct syslog_ns *ns, u32 idx) { return NULL; }
+static u32 log_next(struct syslog_ns *ns, u32 idx) { return 0; }
 static void call_console_drivers(int level, const char *text, size_t len) {}
 static size_t msg_print_text(const struct log *msg, enum log_flags prev,
 			     bool syslog, char *buf, size_t size) { return 0; }
@@ -1988,7 +2065,7 @@ static void console_cont_flush(char *text, size_t size)
 
 	raw_spin_lock_irqsave(&logbuf_lock, flags);
 
-	if (!cont.len)
+	if (!cont.len || cont.ns != &init_syslog_ns)
 		goto out;
 
 	/*
@@ -1996,7 +2073,7 @@ static void console_cont_flush(char *text, size_t size)
 	 * busy. The earlier ones need to be printed before this one, we
 	 * did not flush any fragment so far, so just let it queue up.
 	 */
-	if (console_seq < log_next_seq && !cont.cons)
+	if (console_seq < init_syslog_ns.next_seq && !cont.cons)
 		goto out;
 
 	len = cont_print_text(text, size);
@@ -2031,6 +2108,7 @@ void console_unlock(void)
 	unsigned long flags;
 	bool wake_klogd = false;
 	bool retry;
+	struct syslog_ns *ns = &init_syslog_ns;
 
 	if (console_suspended) {
 		up(&console_sem);
@@ -2048,28 +2126,28 @@ again:
 		int level;
 
 		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		if (seen_seq != log_next_seq) {
+		if (seen_seq != ns->next_seq) {
 			wake_klogd = true;
-			seen_seq = log_next_seq;
+			seen_seq = ns->next_seq;
 		}
 
-		if (console_seq < log_first_seq) {
+		if (console_seq < ns->first_seq) {
 			/* messages are gone, move to first one */
-			console_seq = log_first_seq;
-			console_idx = log_first_idx;
+			console_seq = ns->first_seq;
+			console_idx = ns->first_idx;
 			console_prev = 0;
 		}
 skip:
-		if (console_seq == log_next_seq)
+		if (console_seq == ns->next_seq)
 			break;
 
-		msg = log_from_idx(console_idx);
+		msg = log_from_idx(ns, console_idx);
 		if (msg->flags & LOG_NOCONS) {
 			/*
 			 * Skip record we have buffered and already printed
 			 * directly to the console when we received it.
 			 */
-			console_idx = log_next(console_idx);
+			console_idx = log_next(ns, console_idx);
 			console_seq++;
 			/*
 			 * We will get here again when we register a new
@@ -2084,7 +2162,7 @@ skip:
 		level = msg->level;
 		len = msg_print_text(msg, console_prev, false,
 				     text, sizeof(text));
-		console_idx = log_next(console_idx);
+		console_idx = log_next(ns, console_idx);
 		console_seq++;
 		console_prev = msg->flags;
 		raw_spin_unlock(&logbuf_lock);
@@ -2111,7 +2189,7 @@ skip:
 	 * flush, no worries.
 	 */
 	raw_spin_lock(&logbuf_lock);
-	retry = console_seq != log_next_seq;
+	retry = console_seq != ns->next_seq;
 	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
 
 	if (retry && console_trylock())
@@ -2237,6 +2315,7 @@ void register_console(struct console *newcon)
 	int i;
 	unsigned long flags;
 	struct console *bcon = NULL;
+	struct syslog_ns *ns = &init_syslog_ns;
 
 	/*
 	 * before we register a new CON_BOOT console, make sure we don't
@@ -2347,9 +2426,9 @@ void register_console(struct console *newcon)
 		 * for us.
 		 */
 		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		console_seq = syslog_seq;
-		console_idx = syslog_idx;
-		console_prev = syslog_prev;
+		console_seq = ns->syslog_seq;
+		console_idx = ns->syslog_idx;
+		console_prev = ns->syslog_prev;
 		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
 		/*
 		 * We're about to replay the log buffer.  Only do this to the
@@ -2573,6 +2652,7 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 {
 	struct kmsg_dumper *dumper;
 	unsigned long flags;
+	struct syslog_ns *ns = &init_syslog_ns;
 
 	if ((reason > KMSG_DUMP_OOPS) && !always_kmsg_dump)
 		return;
@@ -2586,10 +2666,10 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 		dumper->active = true;
 
 		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		dumper->cur_seq = clear_seq;
-		dumper->cur_idx = clear_idx;
-		dumper->next_seq = log_next_seq;
-		dumper->next_idx = log_next_idx;
+		dumper->cur_seq = ns->clear_seq;
+		dumper->cur_idx = ns->clear_idx;
+		dumper->next_seq = ns->next_seq;
+		dumper->next_idx = ns->next_idx;
 		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
 
 		/* invoke dumper which will iterate over records */
@@ -2626,24 +2706,25 @@ bool kmsg_dump_get_line_nolock(struct kmsg_dumper *dumper, bool syslog,
 	struct log *msg;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_ns *ns = &init_syslog_ns;
 
 	if (!dumper->active)
 		goto out;
 
-	if (dumper->cur_seq < log_first_seq) {
+	if (dumper->cur_seq < ns->first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = ns->first_seq;
+		dumper->cur_idx = ns->first_idx;
 	}
 
 	/* last entry */
-	if (dumper->cur_seq >= log_next_seq)
+	if (dumper->cur_seq >= ns->next_seq)
 		goto out;
 
-	msg = log_from_idx(dumper->cur_idx);
+	msg = log_from_idx(ns, dumper->cur_idx);
 	l = msg_print_text(msg, 0, syslog, line, size);
 
-	dumper->cur_idx = log_next(dumper->cur_idx);
+	dumper->cur_idx = log_next(ns, dumper->cur_idx);
 	dumper->cur_seq++;
 	ret = true;
 out:
@@ -2713,15 +2794,16 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	enum log_flags prev;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_ns *ns = &init_syslog_ns;
 
 	if (!dumper->active)
 		goto out;
 
 	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	if (dumper->cur_seq < log_first_seq) {
+	if (dumper->cur_seq < ns->first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = ns->first_seq;
+		dumper->cur_idx = ns->first_idx;
 	}
 
 	/* last entry */
@@ -2735,10 +2817,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(ns, idx);
 
 		l += msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(ns, idx);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2748,10 +2830,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (l > size && seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(ns, idx);
 
 		l -= msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(ns, idx);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2763,10 +2845,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	l = 0;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(ns, idx);
 
 		l += msg_print_text(msg, prev, syslog, buf + l, size - l);
-		idx = log_next(idx);
+		idx = log_next(ns, idx);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2794,10 +2876,12 @@ EXPORT_SYMBOL_GPL(kmsg_dump_get_buffer);
  */
 void kmsg_dump_rewind_nolock(struct kmsg_dumper *dumper)
 {
-	dumper->cur_seq = clear_seq;
-	dumper->cur_idx = clear_idx;
-	dumper->next_seq = log_next_seq;
-	dumper->next_idx = log_next_idx;
+	struct syslog_ns *ns = &init_syslog_ns;
+
+	dumper->cur_seq = ns->clear_seq;
+	dumper->cur_idx = ns->clear_idx;
+	dumper->next_seq = ns->next_seq;
+	dumper->next_idx = ns->next_idx;
 }
 
 /**
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..3d5f19f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -61,6 +61,7 @@
 #include <linux/kmod.h>
 #include <linux/capability.h>
 #include <linux/binfmts.h>
+#include <linux/syslog.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -712,7 +713,7 @@ static struct ctl_table kern_table[] = {
 	},
 	{
 		.procname	= "dmesg_restrict",
-		.data		= &dmesg_restrict,
+		.data		= &init_syslog_ns.dmesg_restrict,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax_sysadmin,
diff --git a/kernel/user.c b/kernel/user.c
index 33acb5e..bd176cc 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -18,6 +18,8 @@
 #include <linux/user_namespace.h>
 #include <linux/proc_fs.h>
 
+struct syslog_ns;
+extern struct syslog_ns init_syslog_ns;
 /*
  * userns count is 1 for root user, 1 for init_uts_ns,
  * and 1 for... ?
@@ -53,6 +55,7 @@ struct user_namespace init_user_ns = {
 	.owner = GLOBAL_ROOT_UID,
 	.group = GLOBAL_ROOT_GID,
 	.proc_inum = PROC_USER_INIT_INO,
+	.syslog_ns = &init_syslog_ns,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index dafa125..f62c8a9 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -21,6 +21,7 @@
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
 #include <linux/projid.h>
+#include <linux/syslog.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 
@@ -84,6 +85,7 @@ int create_user_ns(struct cred *new)
 	ns->owner = owner;
 	ns->group = group;
 
+	ns->syslog_ns = get_syslog_ns(parent_ns->syslog_ns);
 
 	/* Leave the new user namespace reference ns on new */
 	set_cred_user_ns(new, ns);
@@ -111,6 +113,7 @@ void free_user_ns(struct kref *kref)
 	struct user_namespace *parent, *ns =
 		container_of(kref, struct user_namespace, kref);
 
+	put_syslog_ns(ns->syslog_ns);
 	parent = ns->parent;
 	proc_free_inum(ns->proc_inum);
 	kmem_cache_free(user_ns_cachep, ns);
-- 
1.7.10.4
