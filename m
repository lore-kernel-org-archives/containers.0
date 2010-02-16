From: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Subject: [PATCH 1/1] RFC: Containerized syslog  (Take II)
Date: Tue, 16 Feb 2010 10:24:17 -0500
Message-ID: <201002161520.o1GFKC6Q013851@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-Id: <201002161524.o1GFOXCJ015572-4srrYzrIIfvCUzpuK5MMl/d9D2ou9A/h@public.gmane.org>
Resent-To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
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

	Containerized syslog is now part of nsproxy.
	A new flag CLONE_SYSLOG allow to unshare
	syslog area.
	Main containerized syslog purpose is to allow
	full container not to leak or compromise
	hosts syslog data.
---
 include/linux/init_task.h      |    2 +
 include/linux/nsproxy.h        |    2 +
 include/linux/sched.h          |    1 +
 include/linux/syslog.h         |    9 ++--
 include/linux/user_namespace.h |    1 -
 kernel/fork.c                  |    2 +-
 kernel/nsproxy.c               |   18 +++++++-
 kernel/printk.c                |   14 +++---
 kernel/syslog.c                |   84 ++++++++++++++++++++++++++++++++--------
 kernel/user.c                  |    3 -
 kernel/user_namespace.c        |    5 --
 11 files changed, 101 insertions(+), 40 deletions(-)

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
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 78efe7c..659cc81 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -9,6 +9,7 @@
 #define CLONE_FS	0x00000200	/* set if fs info shared between processes */
 #define CLONE_FILES	0x00000400	/* set if open files shared between processes */
 #define CLONE_SIGHAND	0x00000800	/* set if signal handlers and blocked signals shared */
+#define CLONE_SYSLOG	0x00001000	/* set if we need private syslog (/proc/kmsg)	*/
 #define CLONE_PTRACE	0x00002000	/* set if we want to let tracing continue on the child too */
 #define CLONE_VFORK	0x00004000	/* set if the parent wants the child to wake it up on mm_release */
 #define CLONE_PARENT	0x00008000	/* set if we want to have the same parent as the cloner */
diff --git a/include/linux/syslog.h b/include/linux/syslog.h
index 98c6898..cdbebee 100644
--- a/include/linux/syslog.h
+++ b/include/linux/syslog.h
@@ -3,6 +3,7 @@
 #include	<linux/spinlock_types.h>
 
 struct syslog_ns {
+	struct kref kref;	/*syslog_ns reference count & control			*/
         wait_queue_head_t wait;
 	spinlock_t logbuf_lock;	/* access conflict locker				*/
         unsigned log_start;	/* Index into log_buf: next char to be read by syslog() */
@@ -22,8 +23,8 @@ extern struct syslog_ns init_kernel_syslog_ns;
  * Syslog API
  *
  */
-extern struct syslog_ns *syslog_malloc(unsigned container_buf_len);
-extern struct syslog_ns *syslog_realloc(struct syslog_ns *syslog_ns, unsigned container_buf_len);
-extern struct syslog_ns *syslog_free(struct syslog_ns *syslog);
-extern struct syslog_ns *syslog_get_current(void);
+extern struct syslog_ns *realloc_syslog_ns(struct syslog_ns *syslog_ns, unsigned container_buf_len);
+extern struct syslog_ns *copy_syslog_ns(unsigned long flags,struct syslog_ns *current_syslog_ns);
+extern struct syslog_ns *release_syslog_ns(struct syslog_ns *current_syslog_ns);
+extern struct syslog_ns *get_current_syslog_ns(void);
 #endif /* _LINUX_SYSLOG_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 3d0c73e..cc4f453 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -14,7 +14,6 @@ struct user_namespace {
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*creator;
 	struct work_struct	destroyer;
-	struct syslog_ns        *syslog;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/fork.c b/kernel/fork.c
index f88bd98..38c8d8c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1647,7 +1647,7 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	err = -EINVAL;
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|CLONE_SYSLOG))
 		goto bad_unshare_out;
 
 	/*
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 09b4ff9..ff968db 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -44,6 +44,8 @@ static inline struct nsproxy *create_nsproxy(void)
 static struct nsproxy *create_new_namespaces(unsigned long flags,
 			struct task_struct *tsk, struct fs_struct *new_fs)
 {
+#define	CONTAINER_BUF_LEN	4096	/*should be enough for container syslog	*/
+
 	struct nsproxy *new_nsp;
 	int err;
 
@@ -80,9 +82,17 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
 	}
-
+	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk->nsproxy->syslog_ns);
+	if (IS_ERR(new_nsp->syslog_ns)) {
+		err = PTR_ERR(new_nsp->syslog_ns);
+		goto out_syslog;
+	}
+	
 	return new_nsp;
 
+out_syslog:
+	if (new_nsp->net_ns) 
+		put_net(new_nsp->net_ns);
 out_net:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
@@ -116,7 +126,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	get_nsproxy(old_ns);
 
 	if (!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-				CLONE_NEWPID | CLONE_NEWNET)))
+				CLONE_NEWPID | CLONE_NEWNET | CLONE_SYSLOG)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN)) {
@@ -151,6 +161,8 @@ out:
 
 void free_nsproxy(struct nsproxy *ns)
 {
+	if (ns->syslog_ns)
+		ns->syslog_ns=release_syslog_ns(ns->syslog_ns);
 	if (ns->mnt_ns)
 		put_mnt_ns(ns->mnt_ns);
 	if (ns->uts_ns)
@@ -173,7 +185,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWNET)))
+			       CLONE_NEWNET | CLONE_SYSLOG )))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/printk.c b/kernel/printk.c
index fd0a05c..3c7f213 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -148,7 +148,7 @@ static int saved_console_loglevel = -1;
  */
 void log_buf_kexec_setup(void)
 {
-	struct syslog_ns *syslog_ns = syslog_get_current();
+	struct syslog_ns *syslog_ns = get_current_syslog_ns();
 
 	VMCOREINFO_SYMBOL(sys_log_buf);
 	VMCOREINFO_SYMBOL(sys_log_end);
@@ -163,7 +163,7 @@ static int __init log_buf_len_setup(char *str)
 
 	if (size) {
 		size = roundup_pow_of_two(size);
-		(void) syslog_realloc(&init_kernel_syslog_ns,size);
+		(void) realloc_syslog_ns(&init_kernel_syslog_ns,size);
 	}
 	return 1;
 }
@@ -244,7 +244,7 @@ int do_syslog(int type, char __user *buf, int len)
 	int do_clear = 0;
 	char c;
 	int error = 0;
-	struct syslog_ns *syslog_ns = syslog_get_current();
+	struct syslog_ns *syslog_ns = get_current_syslog_ns();
 
 	error = security_syslog(type);
 	if (error)
@@ -638,7 +638,7 @@ asmlinkage int vprintk(const char *fmt, va_list args)
 {
 	int printed_len = 0;
 	int current_log_level = default_message_loglevel;
-	struct syslog_ns *syslog_ns = syslog_get_current();
+	struct syslog_ns *syslog_ns = get_current_syslog_ns();
 	unsigned long flags;
 	int this_cpu;
 	char *p;
@@ -1012,7 +1012,7 @@ void release_console_sem(void)
 		unsigned long flags;
 		unsigned _con_start, _log_end;
 		unsigned wake_klogd = 0;
-		struct syslog_ns *syslog_ns = syslog_get_current();
+		struct syslog_ns *syslog_ns = get_current_syslog_ns();
 
 		for ( ; ; ) {
 			spin_lock_irqsave(&sys_log_lock, flags);
@@ -1252,7 +1252,7 @@ void register_console(struct console *newcon)
 		 * for us.
 		 */
 
-		struct syslog_ns *syslog_ns = syslog_get_current();
+		struct syslog_ns *syslog_ns = get_current_syslog_ns();
 
 		spin_lock_irqsave(&sys_log_lock, flags);
 		sys_log_con_start = sys_log_start;
@@ -1462,7 +1462,7 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 	const char *s1, *s2;
 	unsigned long l1, l2;
 	unsigned long flags;
-	struct syslog_ns *syslog_ns = syslog_get_current();
+	struct syslog_ns *syslog_ns = get_current_syslog_ns();
 
 	/* Theoretically, the log could move on after we do this, but
 	   there's not a lot we can do about that. The new messages
diff --git a/kernel/syslog.c b/kernel/syslog.c
index 69d30a9..0088a85 100644
--- a/kernel/syslog.c
+++ b/kernel/syslog.c
@@ -22,35 +22,66 @@
  *
  */
 
+#include <linux/module.h>
 #include <linux/bootmem.h>
 #include <linux/slab.h>
 #include <linux/cred.h>
+#include <linux/kref.h>
 #include <linux/user_namespace.h>
 #include <linux/syslog.h>
 
+#ifdef CONFIG_PRINTK
 /*
  * Static memory definition, used to assign a syslog
  * to the kernel itself
  *
  */
-
-#ifdef CONFIG_PRINTK
 #define __LOG_BUF_LEN   (1 << CONFIG_LOG_BUF_SHIFT)
 
 static char __log_buf[__LOG_BUF_LEN];
 
 struct syslog_ns init_kernel_syslog_ns = {
+	.kref = {
+		.refcount	= ATOMIC_INIT(2),
+	},
         .wait = __WAIT_QUEUE_HEAD_INITIALIZER(init_kernel_syslog_ns.wait),
         .buf_len = __LOG_BUF_LEN,
         .buf = __log_buf
 };
+EXPORT_SYMBOL_GPL(init_kernel_syslog_ns);
 #endif
+/*
+ * Procedure to free all ressources tied to syslog
+ *
+ */
+struct syslog_ns *syslog_free(struct syslog_ns *syslog)
+
+{
+	if (syslog != (struct syslog_ns *)0) {
+		(void) kfree(syslog->buf);
+		(void) kfree(syslog);
+		syslog = (struct syslog_ns *)0;
+		}
+	return syslog;
+}
 
 /*
+ * Procedure to interface kref _put with syslog_free
+ *
+ */
+static void syslog_out(struct kref *kref)
+
+{
+	struct syslog_ns *sl;
+
+	sl=container_of(kref, struct syslog_ns, kref);	
+	sl=syslog_free(sl);
+}
+/*
  * Procedure to assign memory for syslog area
  *
  */
-struct syslog_ns * syslog_malloc(unsigned container_buf_len)
+static struct syslog_ns * malloc_syslog_ns(unsigned container_buf_len)
 {
 	struct syslog_ns *ns;
 
@@ -61,6 +92,8 @@ struct syslog_ns * syslog_malloc(unsigned container_buf_len)
 	if (!ns)
 		return ERR_PTR(-ENOMEM);
 
+	(void) kref_init(&(ns->kref));
+
 	ns->buf_len = container_buf_len;
 	ns->buf = kzalloc(container_buf_len, GFP_KERNEL);
 	if (!ns->buf) {
@@ -77,7 +110,7 @@ struct syslog_ns * syslog_malloc(unsigned container_buf_len)
  * If syslog_ns is NULL, assign a brand new syslog_ns
  *
  */
-struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned container_buf_len)
+struct syslog_ns * realloc_syslog_ns(struct syslog_ns *syslog_ns, unsigned container_buf_len)
 
 {
 	if ((syslog_ns == &init_kernel_syslog_ns ) && (container_buf_len > syslog_ns->buf_len)) {
@@ -102,7 +135,7 @@ struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned containe
 			(void) free_bootmem((unsigned long)old_buf, old_buf_len);
 		}
 	if (!syslog_ns)
-		return syslog_malloc(container_buf_len);
+		return malloc_syslog_ns(container_buf_len);
 	if (syslog_ns->buf_len > container_buf_len) {
 		(void) printk(KERN_WARNING "log_buf_len: Not allowed to decrease syslog buffer\n");
 		return ERR_PTR(-EINVAL);
@@ -126,32 +159,51 @@ struct syslog_ns * syslog_realloc(struct syslog_ns *syslog_ns, unsigned containe
 	(void) printk(KERN_NOTICE "log_buf_len: %u\n", syslog_ns->buf_len);
 	return syslog_ns;
 }
+
 /*
- * Procedure to free all ressources tied to syslog
+ * Procedure to use current syslog unless a CLONE_SYSLOG is set
+ * such a new syslog area is defined and used
  *
  */
-struct syslog_ns *syslog_free(struct syslog_ns *syslog)
+struct syslog_ns *copy_syslog_ns(unsigned long flags,struct syslog_ns *current_syslog_ns)
 
 {
-	if (syslog != (struct syslog_ns *)0) {
-		(void) kfree(syslog->buf);
-		(void) kfree(syslog);
-		syslog = (struct syslog_ns *)0;
-		}
-	return syslog;
+#define	CONTAINER_BUF_LEN	4096	/*should be enough for container syslog	*/
+
+	BUG_ON(!current_syslog_ns);
+	if ((flags & CLONE_SYSLOG) == 0) /*incrementing usage reference count	*/
+		(void) kref_get(&(current_syslog_ns->kref));
+	else
+		current_syslog_ns=malloc_syslog_ns(CONTAINER_BUF_LEN);
+	return current_syslog_ns;
+	
+}
+
+/*
+ * Procedure to decrement syslog usage count and free memory
+ * if syslog usage count reach zero.
+ *
+ */
+struct syslog_ns *release_syslog_ns(struct syslog_ns *current_syslog_ns)
+
+{
+	if (kref_put(&(current_syslog_ns->kref), syslog_out)==0)
+	   current_syslog_ns=(struct syslog_ns *)0;
+	return current_syslog_ns;
 }
 
 /*
- * Procedure to get the current syslog area linked to a container (by CLONE_USER)
+ * Procedure to get the current syslog area linked to a container (by CLONE_SYSLOG)
  * if trouble, pin down the problem before it propagate.
  *
  */
-struct syslog_ns *syslog_get_current(void) 
+struct syslog_ns *get_current_syslog_ns(void) 
 
 {
+
 	struct syslog_ns *ns;
 
-	ns = current_user_ns()->syslog;
+	ns = current->nsproxy->syslog_ns;
 	BUG_ON(!ns);
 	return ns;
 }
diff --git a/kernel/user.c b/kernel/user.c
index cb2d4ba..d9bea1f 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -23,9 +23,6 @@ struct user_namespace init_user_ns = {
 	.kref = {
 		.refcount	= ATOMIC_INIT(2),
 	},
-#ifdef CONFIG_PRINTK
-	.syslog = &init_kernel_syslog_ns,
-#endif
 	.creator = &root_user
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 9d8014f..db72d1b 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -38,11 +38,6 @@ int create_user_ns(struct cred *new)
 		INIT_HLIST_HEAD(ns->uidhash_table + n);
 
 	
-	ns->syslog = syslog_malloc(CONTAINER_BUF_LEN);
-        if (!ns->syslog) {
-                kfree(ns);
-                return -ENOMEM;
-        }
 	/* Alloc new root user.  */
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
-- 
1.6.6
