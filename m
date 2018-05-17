From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [PATCH v2 1/4] seccomp: add a return code to trap to userspace
Date: Thu, 17 May 2018 09:12:15 -0600
Message-ID: <20180517151218.12850-2-tycho__22672.7112466053$1526569888$gmane$org@tycho.ws>
References: <20180517151218.12850-1-tycho@tycho.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180517151218.12850-1-tycho-E0fblnxP3wo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch introduces a means for syscalls matched in seccomp to notify
some other task that a particular filter has been triggered.

The motivation for this is primarily for use with containers. For example,
if a container does an init_module(), we obviously don't want to load this
untrusted code, which may be compiled for the wrong version of the kernel
anyway. Instead, we could parse the module image, figure out which module
the container is trying to load and load it on the host.

As another example, containers cannot mknod(), since this checks
capable(CAP_SYS_ADMIN). However, harmless devices like /dev/null or
/dev/zero should be ok for containers to mknod, but we'd like to avoid hard
coding some whitelist in the kernel. Another example is mount(), which has
many security restrictions for good reason, but configuration or runtime
knowledge could potentially be used to relax these restrictions.

This patch adds functionality that is already possible via at least two
other means that I know about, both of which involve ptrace(): first, one
could ptrace attach, and then iterate through syscalls via PTRACE_SYSCALL.
Unfortunately this is slow, so a faster version would be to install a
filter that does SECCOMP_RET_TRACE, which triggers a PTRACE_EVENT_SECCOMP.
Since ptrace allows only one tracer, if the container runtime is that
tracer, users inside the container (or outside) trying to debug it will not
be able to use ptrace, which is annoying. It also means that older
distributions based on Upstart cannot boot inside containers using ptrace,
since upstart itself uses ptrace to start services.

The actual implementation of this is fairly small, although getting the
synchronization right was/is slightly complex.

Finally, it's worth noting that the classic seccomp TOCTOU of reading
memory data from the task still applies here, but can be avoided with
careful design of the userspace handler: if the userspace handler reads all
of the task memory that is necessary before applying its security policy,
the tracee's subsequent memory edits will not be read by the tracer.

v2: * make id a u64; the idea here being that it will never overflow,
      because 64 is huge (one syscall every nanosecond => wrap every 584
      years)
    * prevent nesting of user notifications: if someone is already attached
      the tree in one place, nobody else can attach to the tree
    * notify the listener of signals the tracee receives as well
    * implement poll

Signed-off-by: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
CC: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
---
 arch/Kconfig                                  |   7 +
 include/linux/seccomp.h                       |   3 +-
 include/uapi/linux/seccomp.h                  |  18 +-
 kernel/seccomp.c                              | 402 +++++++++++++++++-
 tools/testing/selftests/seccomp/seccomp_bpf.c | 181 +++++++-
 5 files changed, 605 insertions(+), 6 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 8e0d665c8d53..dd99eef3e049 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -401,6 +401,13 @@ config SECCOMP_FILTER
 
 	  See Documentation/prctl/seccomp_filter.txt for details.
 
+config SECCOMP_USER_NOTIFICATION
+	bool "Enable the SECCOMP_RET_USER_NOTIF seccomp action"
+	depends on SECCOMP_FILTER
+	help
+	  Enable SECCOMP_RET_USER_NOTIF, a return code which can be used by seccomp
+	  programs to notify a userspace listener that a particular event happened.
+
 config HAVE_GCC_PLUGINS
 	bool
 	help
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index c723a5c4e3ff..0fd3e0676a1c 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -5,7 +5,8 @@
 #include <uapi/linux/seccomp.h>
 
 #define SECCOMP_FILTER_FLAG_MASK	(SECCOMP_FILTER_FLAG_TSYNC | \
-					 SECCOMP_FILTER_FLAG_LOG)
+					 SECCOMP_FILTER_FLAG_LOG | \
+					 SECCOMP_FILTER_FLAG_GET_LISTENER)
 
 #ifdef CONFIG_SECCOMP
 
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 2a0bd9dd104d..8160e6cad528 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -17,8 +17,9 @@
 #define SECCOMP_GET_ACTION_AVAIL	2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
-#define SECCOMP_FILTER_FLAG_TSYNC	1
-#define SECCOMP_FILTER_FLAG_LOG		2
+#define SECCOMP_FILTER_FLAG_TSYNC		1
+#define SECCOMP_FILTER_FLAG_LOG			2
+#define SECCOMP_FILTER_FLAG_GET_LISTENER	4
 
 /*
  * All BPF programs must return a 32-bit value.
@@ -34,6 +35,7 @@
 #define SECCOMP_RET_KILL	 SECCOMP_RET_KILL_THREAD
 #define SECCOMP_RET_TRAP	 0x00030000U /* disallow and force a SIGSYS */
 #define SECCOMP_RET_ERRNO	 0x00050000U /* returns an errno */
+#define SECCOMP_RET_USER_NOTIF   0x7fc00000U /* notifies userspace */
 #define SECCOMP_RET_TRACE	 0x7ff00000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_LOG		 0x7ffc0000U /* allow after logging */
 #define SECCOMP_RET_ALLOW	 0x7fff0000U /* allow */
@@ -59,4 +61,16 @@ struct seccomp_data {
 	__u64 args[6];
 };
 
+struct seccomp_notif {
+	__u64 id;
+	pid_t pid;
+	struct seccomp_data data;
+};
+
+struct seccomp_notif_resp {
+	__u64 id;
+	__s32 error;
+	__s64 val;
+};
+
 #endif /* _UAPI_LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index dc77548167ef..a169a62cb78a 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -38,6 +38,53 @@
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
 
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+#include <linux/file.h>
+#include <linux/anon_inodes.h>
+
+enum notify_state {
+	SECCOMP_NOTIFY_INIT,
+	SECCOMP_NOTIFY_SENT,
+	SECCOMP_NOTIFY_REPLIED,
+};
+
+struct seccomp_knotif {
+	/* The pid whose filter triggered the notification */
+	pid_t pid;
+
+	/*
+	 * The "cookie" for this request; this is unique for this filter.
+	 */
+	u32 id;
+
+	/*
+	 * The seccomp data. This pointer is valid the entire time this
+	 * notification is active, since it comes from __seccomp_filter which
+	 * eclipses the entire lifecycle here.
+	 */
+	const struct seccomp_data *data;
+
+	/*
+	 * Notification states. When SECCOMP_RET_USER_NOTIF is returned, a
+	 * struct seccomp_knotif is created and starts out in INIT. Once the
+	 * handler reads the notification off of an FD, it transitions to READ.
+	 * If a signal is received the state transitions back to INIT and
+	 * another message is sent. When the userspace handler replies, state
+	 * transitions to REPLIED.
+	 */
+	enum notify_state state;
+
+	/* The return values, only valid when in SECCOMP_NOTIFY_REPLIED */
+	int error;
+	long val;
+
+	/* Signals when this has entered SECCOMP_NOTIFY_REPLIED */
+	struct completion ready;
+
+	struct list_head list;
+};
+#endif
+
 /**
  * struct seccomp_filter - container for seccomp BPF programs
  *
@@ -64,6 +111,27 @@ struct seccomp_filter {
 	bool log;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
+
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+	/*
+	 * A semaphore that users of this notification can wait on for
+	 * changes. Actual reads and writes are still controlled with
+	 * filter->notify_lock.
+	 */
+	struct semaphore request;
+
+	/* A lock for all notification-related accesses. */
+	struct mutex notify_lock;
+
+	/* Is there currently an attached listener? */
+	bool has_listener;
+
+	/* The id of the next request. */
+	u64 next_id;
+
+	/* A list of struct seccomp_knotif elements. */
+	struct list_head notifications;
+#endif
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
@@ -383,6 +451,13 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 	if (!sfilter)
 		return ERR_PTR(-ENOMEM);
 
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+	mutex_init(&sfilter->notify_lock);
+	sema_init(&sfilter->request, 0);
+	INIT_LIST_HEAD(&sfilter->notifications);
+	sfilter->next_id = get_random_u64();
+#endif
+
 	ret = bpf_prog_create_from_user(&sfilter->prog, fprog,
 					seccomp_check_filter, save_orig);
 	if (ret < 0) {
@@ -547,13 +622,15 @@ static void seccomp_send_sigsys(int syscall, int reason)
 #define SECCOMP_LOG_TRACE		(1 << 4)
 #define SECCOMP_LOG_LOG			(1 << 5)
 #define SECCOMP_LOG_ALLOW		(1 << 6)
+#define SECCOMP_LOG_USER_NOTIF		(1 << 7)
 
 static u32 seccomp_actions_logged = SECCOMP_LOG_KILL_PROCESS |
 				    SECCOMP_LOG_KILL_THREAD  |
 				    SECCOMP_LOG_TRAP  |
 				    SECCOMP_LOG_ERRNO |
 				    SECCOMP_LOG_TRACE |
-				    SECCOMP_LOG_LOG;
+				    SECCOMP_LOG_LOG |
+				    SECCOMP_LOG_USER_NOTIF;
 
 static inline void seccomp_log(unsigned long syscall, long signr, u32 action,
 			       bool requested)
@@ -572,6 +649,9 @@ static inline void seccomp_log(unsigned long syscall, long signr, u32 action,
 	case SECCOMP_RET_TRACE:
 		log = requested && seccomp_actions_logged & SECCOMP_LOG_TRACE;
 		break;
+	case SECCOMP_RET_USER_NOTIF:
+		log = requested && seccomp_actions_logged & SECCOMP_LOG_USER_NOTIF;
+		break;
 	case SECCOMP_RET_LOG:
 		log = seccomp_actions_logged & SECCOMP_LOG_LOG;
 		break;
@@ -645,6 +725,91 @@ void secure_computing_strict(int this_syscall)
 }
 #else
 
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+static u64 seccomp_next_notify_id(struct seccomp_filter *filter)
+{
+	u64 ret = filter->next_id;
+
+	/* Note: overflow is ok here, the id just needs to be unique */
+	filter->next_id++;
+
+	return ret;
+}
+
+static void seccomp_do_user_notification(int this_syscall,
+					 struct seccomp_filter *match,
+					 const struct seccomp_data *sd)
+{
+	int err;
+	long ret = 0;
+	struct seccomp_knotif n = {};
+
+	mutex_lock(&match->notify_lock);
+	if (!match->has_listener) {
+		err = -ENOSYS;
+		goto out;
+	}
+
+	n.pid = current->pid;
+	n.state = SECCOMP_NOTIFY_INIT;
+	n.data = sd;
+	n.id = seccomp_next_notify_id(match);
+	init_completion(&n.ready);
+
+	list_add(&n.list, &match->notifications);
+
+	mutex_unlock(&match->notify_lock);
+	up(&match->request);
+
+	err = wait_for_completion_interruptible(&n.ready);
+	mutex_lock(&match->notify_lock);
+
+	/*
+	 * Here it's possible we got a signal and then had to wait on the mutex
+	 * while the reply was sent, so let's be sure there wasn't a response
+	 * in the meantime.
+	 */
+	if (err < 0 && n.state != SECCOMP_NOTIFY_REPLIED) {
+		/*
+		 * We got a signal. Let's tell userspace about it (potentially
+		 * again, if we had already notified them about the first one).
+		 */
+		if (n.state == SECCOMP_NOTIFY_SENT) {
+			n.state = SECCOMP_NOTIFY_INIT;
+			up(&match->request);
+		}
+		mutex_unlock(&match->notify_lock);
+		err = wait_for_completion_killable(&n.ready);
+		mutex_lock(&match->notify_lock);
+		if (err < 0)
+			goto remove_list;
+	}
+
+	ret = n.val;
+	err = n.error;
+
+	WARN(n.state != SECCOMP_NOTIFY_REPLIED,
+	     "notified about write complete when state is not write");
+
+remove_list:
+	list_del(&n.list);
+out:
+	mutex_unlock(&match->notify_lock);
+	syscall_set_return_value(current, task_pt_regs(current),
+				 err, ret);
+}
+#else
+static void seccomp_do_user_notification(int this_syscall,
+					 u32 action,
+					 struct seccomp_filter *match,
+					 const struct seccomp_data *sd)
+{
+	WARN(1, "user notification received, but disabled");
+	seccomp_log(this_syscall, SIGSYS, action, true);
+	do_exit(SIGSYS);
+}
+#endif
+
 #ifdef CONFIG_SECCOMP_FILTER
 static int __seccomp_filter(int this_syscall, const struct seccomp_data *sd,
 			    const bool recheck_after_trace)
@@ -722,6 +887,9 @@ static int __seccomp_filter(int this_syscall, const struct seccomp_data *sd,
 
 		return 0;
 
+	case SECCOMP_RET_USER_NOTIF:
+		seccomp_do_user_notification(this_syscall, match, sd);
+		goto skip;
 	case SECCOMP_RET_LOG:
 		seccomp_log(this_syscall, 0, action, true);
 		return 0;
@@ -828,6 +996,11 @@ static long seccomp_set_mode_strict(void)
 }
 
 #ifdef CONFIG_SECCOMP_FILTER
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+static struct file *init_listener(struct task_struct *,
+				  struct seccomp_filter *);
+#endif
+
 /**
  * seccomp_set_mode_filter: internal function for setting seccomp filter
  * @flags:  flags to change filter behavior
@@ -847,6 +1020,8 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	const unsigned long seccomp_mode = SECCOMP_MODE_FILTER;
 	struct seccomp_filter *prepared = NULL;
 	long ret = -EINVAL;
+	int listener = 0;
+	struct file *listener_f = NULL;
 
 	/* Validate flags. */
 	if (flags & ~SECCOMP_FILTER_FLAG_MASK)
@@ -857,13 +1032,28 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	if (IS_ERR(prepared))
 		return PTR_ERR(prepared);
 
+	if (flags & SECCOMP_FILTER_FLAG_GET_LISTENER) {
+		listener = get_unused_fd_flags(O_RDWR);
+		if (listener < 0) {
+			ret = listener;
+			goto out_free;
+		}
+
+		listener_f = init_listener(current, prepared);
+		if (IS_ERR(listener_f)) {
+			put_unused_fd(listener);
+			ret = PTR_ERR(listener_f);
+			goto out_free;
+		}
+	}
+
 	/*
 	 * Make sure we cannot change seccomp or nnp state via TSYNC
 	 * while another thread is in the middle of calling exec.
 	 */
 	if (flags & SECCOMP_FILTER_FLAG_TSYNC &&
 	    mutex_lock_killable(&current->signal->cred_guard_mutex))
-		goto out_free;
+		goto out_put_fd;
 
 	spin_lock_irq(&current->sighand->siglock);
 
@@ -881,6 +1071,16 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	spin_unlock_irq(&current->sighand->siglock);
 	if (flags & SECCOMP_FILTER_FLAG_TSYNC)
 		mutex_unlock(&current->signal->cred_guard_mutex);
+out_put_fd:
+	if (flags & SECCOMP_FILTER_FLAG_GET_LISTENER) {
+		if (ret < 0) {
+			fput(listener_f);
+			put_unused_fd(listener);
+		} else {
+			fd_install(listener, listener_f);
+			ret = listener;
+		}
+	}
 out_free:
 	seccomp_filter_free(prepared);
 	return ret;
@@ -909,6 +1109,9 @@ static long seccomp_get_action_avail(const char __user *uaction)
 	case SECCOMP_RET_LOG:
 	case SECCOMP_RET_ALLOW:
 		break;
+	case SECCOMP_RET_USER_NOTIF:
+		if (IS_ENABLED(CONFIG_SECCOMP_USER_NOTIFICATION))
+			break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1105,6 +1308,7 @@ long seccomp_get_metadata(struct task_struct *task,
 #define SECCOMP_RET_KILL_THREAD_NAME	"kill_thread"
 #define SECCOMP_RET_TRAP_NAME		"trap"
 #define SECCOMP_RET_ERRNO_NAME		"errno"
+#define SECCOMP_RET_USER_NOTIF_NAME	"user_notif"
 #define SECCOMP_RET_TRACE_NAME		"trace"
 #define SECCOMP_RET_LOG_NAME		"log"
 #define SECCOMP_RET_ALLOW_NAME		"allow"
@@ -1114,6 +1318,7 @@ static const char seccomp_actions_avail[] =
 				SECCOMP_RET_KILL_THREAD_NAME	" "
 				SECCOMP_RET_TRAP_NAME		" "
 				SECCOMP_RET_ERRNO_NAME		" "
+				SECCOMP_RET_USER_NOTIF_NAME     " "
 				SECCOMP_RET_TRACE_NAME		" "
 				SECCOMP_RET_LOG_NAME		" "
 				SECCOMP_RET_ALLOW_NAME;
@@ -1131,6 +1336,7 @@ static const struct seccomp_log_name seccomp_log_names[] = {
 	{ SECCOMP_LOG_TRACE, SECCOMP_RET_TRACE_NAME },
 	{ SECCOMP_LOG_LOG, SECCOMP_RET_LOG_NAME },
 	{ SECCOMP_LOG_ALLOW, SECCOMP_RET_ALLOW_NAME },
+	{ SECCOMP_LOG_USER_NOTIF, SECCOMP_RET_USER_NOTIF_NAME },
 	{ }
 };
 
@@ -1279,3 +1485,195 @@ static int __init seccomp_sysctl_init(void)
 device_initcall(seccomp_sysctl_init)
 
 #endif /* CONFIG_SYSCTL */
+
+#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
+static int seccomp_notify_release(struct inode *inode, struct file *file)
+{
+	struct seccomp_filter *filter = file->private_data;
+	struct seccomp_knotif *knotif;
+
+	mutex_lock(&filter->notify_lock);
+
+	/*
+	 * If this file is being closed because e.g. the task who owned it
+	 * died, let's wake everyone up who was waiting on us.
+	 */
+	list_for_each_entry(knotif, &filter->notifications, list) {
+		if (knotif->state == SECCOMP_NOTIFY_REPLIED)
+			continue;
+
+		knotif->state = SECCOMP_NOTIFY_REPLIED;
+		knotif->error = -ENOSYS;
+		knotif->val = 0;
+
+		complete(&knotif->ready);
+	}
+
+	filter->has_listener = false;
+	mutex_unlock(&filter->notify_lock);
+	__put_seccomp_filter(filter);
+	return 0;
+}
+
+static ssize_t seccomp_notify_read(struct file *f, char __user *buf,
+				   size_t size, loff_t *ppos)
+{
+	struct seccomp_filter *filter = f->private_data;
+	struct seccomp_knotif *knotif = NULL, *cur;
+	struct seccomp_notif unotif;
+	ssize_t ret;
+
+	/* No offset reads. */
+	if (*ppos != 0)
+		return -EINVAL;
+
+	ret = down_interruptible(&filter->request);
+	if (ret < 0)
+		return ret;
+
+	mutex_lock(&filter->notify_lock);
+	list_for_each_entry(cur, &filter->notifications, list) {
+		if (cur->state == SECCOMP_NOTIFY_INIT) {
+			knotif = cur;
+			break;
+		}
+	}
+
+	/*
+	 * If we didn't find a notification, it could be that the task was
+	 * interrupted between the time we were woken and when we were able to
+	 * acquire the rw lock. Should we retry here or just -ENOENT? -ENOENT
+	 * for now.
+	 */
+	if (!knotif) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	unotif.id = knotif->id;
+	unotif.pid = knotif->pid;
+	unotif.data = *(knotif->data);
+
+	size = min_t(size_t, size, sizeof(struct seccomp_notif));
+	if (copy_to_user(buf, &unotif, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = sizeof(unotif);
+	knotif->state = SECCOMP_NOTIFY_SENT;
+
+out:
+	mutex_unlock(&filter->notify_lock);
+	return ret;
+}
+
+static ssize_t seccomp_notify_write(struct file *file, const char __user *buf,
+				    size_t size, loff_t *ppos)
+{
+	struct seccomp_filter *filter = file->private_data;
+	struct seccomp_notif_resp resp = {};
+	struct seccomp_knotif *knotif = NULL;
+	ssize_t ret = -EINVAL;
+
+	/* No partial writes. */
+	if (*ppos != 0)
+		return -EINVAL;
+
+	size = min_t(size_t, size, sizeof(resp));
+	if (copy_from_user(&resp, buf, size))
+		return -EFAULT;
+
+	ret = mutex_lock_interruptible(&filter->notify_lock);
+	if (ret < 0)
+		return ret;
+
+	list_for_each_entry(knotif, &filter->notifications, list) {
+		if (knotif->id == resp.id)
+			break;
+	}
+
+	if (!knotif || knotif->id != resp.id) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* Allow exactly one reply. */
+	if (knotif->state != SECCOMP_NOTIFY_SENT) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = size;
+	knotif->state = SECCOMP_NOTIFY_REPLIED;
+	knotif->error = resp.error;
+	knotif->val = resp.val;
+	complete(&knotif->ready);
+out:
+	mutex_unlock(&filter->notify_lock);
+	return ret;
+}
+
+static __poll_t seccomp_notify_poll(struct file *file,
+				    struct poll_table_struct *poll_tab)
+{
+	struct seccomp_filter *filter = file->private_data;
+	__poll_t ret = 0;
+	struct seccomp_knotif *cur;
+
+	ret = mutex_lock_interruptible(&filter->notify_lock);
+	if (ret < 0)
+		return ret;
+
+	list_for_each_entry(cur, &filter->notifications, list) {
+		if (cur->state == SECCOMP_NOTIFY_INIT)
+			ret |= EPOLLIN | EPOLLRDNORM;
+		if (cur->state == SECCOMP_NOTIFY_SENT)
+			ret |= EPOLLOUT | EPOLLWRNORM;
+	}
+
+	mutex_unlock(&filter->notify_lock);
+
+	return ret;
+}
+
+static const struct file_operations seccomp_notify_ops = {
+	.read = seccomp_notify_read,
+	.write = seccomp_notify_write,
+	.poll = seccomp_notify_poll,
+	.release = seccomp_notify_release,
+};
+
+static struct file *init_listener(struct task_struct *task,
+				  struct seccomp_filter *filter)
+{
+	struct file *ret = ERR_PTR(-EBUSY);
+	struct seccomp_filter *cur;
+	bool have_listener = false;
+
+	for (cur = task->seccomp.filter; cur; cur = cur->prev) {
+		mutex_lock(&cur->notify_lock);
+		if (cur->has_listener)
+			have_listener = true;
+	}
+
+	if (have_listener)
+		goto out;
+
+	ret = anon_inode_getfile("seccomp notify", &seccomp_notify_ops,
+				 filter, O_RDWR);
+	if (IS_ERR(ret))
+		goto out;
+
+
+	/* The file has a reference to it now */
+	__get_seccomp_filter(filter);
+	filter->has_listener = true;
+
+out:
+	for (cur = task->seccomp.filter; cur; cur = cur->prev)
+		mutex_unlock(&cur->notify_lock);
+
+	return ret;
+}
+#endif
diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 168c66d74fc5..bb96df66222f 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -40,10 +40,12 @@
 #include <sys/fcntl.h>
 #include <sys/mman.h>
 #include <sys/times.h>
+#include <sys/socket.h>
 
 #define _GNU_SOURCE
 #include <unistd.h>
 #include <sys/syscall.h>
+#include <poll.h>
 
 #include "../kselftest_harness.h"
 
@@ -150,6 +152,24 @@ struct seccomp_metadata {
 };
 #endif
 
+#ifndef SECCOMP_FILTER_FLAG_GET_LISTENER
+#define SECCOMP_FILTER_FLAG_GET_LISTENER 4
+
+#define SECCOMP_RET_USER_NOTIF 0x7fc00000U
+
+struct seccomp_notif {
+	__u64 id;
+	pid_t pid;
+	struct seccomp_data data;
+};
+
+struct seccomp_notif_resp {
+	__u64 id;
+	__s32 error;
+	__s64 val;
+};
+#endif
+
 #ifndef seccomp
 int seccomp(unsigned int op, unsigned int flags, void *args)
 {
@@ -2072,7 +2092,8 @@ TEST(seccomp_syscall_mode_lock)
 TEST(detect_seccomp_filter_flags)
 {
 	unsigned int flags[] = { SECCOMP_FILTER_FLAG_TSYNC,
-				 SECCOMP_FILTER_FLAG_LOG };
+				 SECCOMP_FILTER_FLAG_LOG,
+				 SECCOMP_FILTER_FLAG_GET_LISTENER };
 	unsigned int flag, all_flags;
 	int i;
 	long ret;
@@ -2917,6 +2938,164 @@ TEST(get_metadata)
 	ASSERT_EQ(0, kill(pid, SIGKILL));
 }
 
+static int user_trap_syscall(int nr, unsigned int flags)
+{
+	struct sock_filter filter[] = {
+		BPF_STMT(BPF_LD+BPF_W+BPF_ABS,
+			offsetof(struct seccomp_data, nr)),
+		BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, nr, 0, 1),
+		BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_USER_NOTIF),
+		BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW),
+	};
+
+	struct sock_fprog prog = {
+		.len = (unsigned short)ARRAY_SIZE(filter),
+		.filter = filter,
+	};
+
+	return seccomp(SECCOMP_SET_MODE_FILTER, flags, &prog);
+}
+
+static int read_notif(int listener, struct seccomp_notif *req)
+{
+	int ret;
+
+	do {
+		errno = 0;
+		ret = read(listener, req, sizeof(*req));
+	} while (ret == -1 && errno == ENOENT);
+	return ret;
+}
+
+static void signal_handler(int signal)
+{
+}
+
+#define USER_NOTIF_MAGIC 116983961184613L
+TEST(get_user_notification_syscall)
+{
+	pid_t pid;
+	long ret;
+	int status, listener;
+	struct seccomp_notif req = {};
+	struct seccomp_notif_resp resp = {};
+	struct pollfd pollfd;
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	/* Check that we get -ENOSYS with no listener attached */
+	if (pid == 0) {
+		if (user_trap_syscall(__NR_getpid, 0) < 0)
+			exit(1);
+		ret = syscall(__NR_getpid);
+		exit(ret >= 0 || errno != ENOSYS);
+	}
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+
+	/* Check that the basic notification machinery works */
+	listener = user_trap_syscall(__NR_getpid,
+				     SECCOMP_FILTER_FLAG_GET_LISTENER);
+	EXPECT_GE(listener, 0);
+
+	/* Installing a second listener in the chain should EBUSY */
+	EXPECT_EQ(user_trap_syscall(__NR_getpid,
+				    SECCOMP_FILTER_FLAG_GET_LISTENER),
+		  -1);
+	EXPECT_EQ(errno, EBUSY);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		ret = syscall(__NR_getpid);
+		exit(ret != USER_NOTIF_MAGIC);
+	}
+
+	EXPECT_EQ(read(listener, &req, sizeof(req)), sizeof(req));
+
+	pollfd.fd = listener;
+	pollfd.events = POLLIN | POLLOUT;
+
+	EXPECT_GT(poll(&pollfd, 1, -1), 0);
+	EXPECT_EQ(pollfd.revents, POLLOUT);
+
+	EXPECT_EQ(req.data.nr,  __NR_getpid);
+
+	resp.id = req.id;
+	resp.error = 0;
+	resp.val = USER_NOTIF_MAGIC;
+
+	EXPECT_EQ(write(listener, &resp, sizeof(resp)), sizeof(resp));
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+
+	/*
+	 * Check that nothing bad happens when we kill the task in the middle
+	 * of a syscall.
+	 */
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		ret = syscall(__NR_getpid);
+		exit(ret != USER_NOTIF_MAGIC);
+	}
+
+	ret = read(listener, &req, sizeof(req));
+	EXPECT_EQ(ret, sizeof(req));
+
+	EXPECT_EQ(kill(pid, SIGKILL), 0);
+	EXPECT_EQ(waitpid(pid, NULL, 0), pid);
+
+	resp.id = req.id;
+	ret = write(listener, &resp, sizeof(resp));
+	EXPECT_EQ(ret, -1);
+	EXPECT_EQ(errno, EINVAL);
+
+	/*
+	 * Check that we get another notification about a signal in the middle
+	 * of a syscall.
+	 */
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		if (signal(SIGUSR1, signal_handler) == SIG_ERR) {
+			perror("signal");
+			exit(1);
+		}
+		ret = syscall(__NR_getpid);
+		exit(ret != USER_NOTIF_MAGIC);
+	}
+
+	ret = read_notif(listener, &req);
+	EXPECT_EQ(ret, sizeof(req));
+	EXPECT_EQ(errno, 0);
+
+	EXPECT_EQ(kill(pid, SIGUSR1), 0);
+
+	ret = read_notif(listener, &req);
+	EXPECT_EQ(ret, sizeof(req));
+	EXPECT_EQ(errno, 0);
+
+	resp.id = req.id;
+	ret = write(listener, &resp, sizeof(resp));
+	EXPECT_EQ(ret, sizeof(resp));
+	EXPECT_EQ(errno, 0);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+
+	close(listener);
+}
+
 /*
  * TODO:
  * - add microbenchmarks
-- 
2.17.0
