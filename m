From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 21/54] Define subtree flag and unpriv_allowed sysctl
Date: Tue, 28 Apr 2009 19:23:51 -0400
Message-ID: <1240961064-13991-22-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Define a sysctl 'ckpt_unpriv_allowed' which determines whether all
checkpoints and restarts require CAP_SYS_ADMIN.  If it is 1, then
regular permission checks are intended to prevent privilege
escalation, but leaving it at 0 prevents unprivileged users from
exploiting any privilege escalation bugs.

Define a CHECKPOINT_SUBTREE flag for sys_checkpoint() which allows to
checkpoint a subtree of processes. Otherwise, the syscall expects to
checkpoint an entire container (in the sense of a pid namespace),
starting with the container init task.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c          |    4 ++++
 checkpoint/restart.c             |    2 +-
 checkpoint/sys.c                 |   17 +++++++++++++++--
 include/linux/checkpoint_types.h |   12 +++++++++++-
 kernel/sysctl.c                  |   19 +++++++++++++++++++
 5 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 0299046..6305e5d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -423,6 +423,10 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->root_nsproxy = nsproxy;
 	ctx->root_init = is_container_init(task);
 
+	/* FIX: does this error code makes sense here ? */
+	if (!(ctx->flags & CHECKPOINT_SUBTREE) && !ctx->root_init)
+		return -EBUSY;
+
 	return 0;
 
  out:
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index edc89ba..e5a29fb 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -287,7 +287,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
 	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
 		goto out;
-	if (h->flags & ~CKPT_CTX_CHECKPOINT)
+	if (h->flags & ~(CKPT_CTX_CHECKPOINT | CKPT_USER_FLAGS))
 		goto out;
 	if (h->uts_release_len != sizeof(uts->release) ||
 	    h->uts_version_len != sizeof(uts->version) ||
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index a613748..e3f7012 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -21,6 +21,13 @@
 #include <linux/checkpoint.h>
 
 /*
+ * ckpt_unpriv_allowed - sysctl_controlled, do not allow checkpoint of
+ * a set of tasks which do not form a fully isolated container, if 0.
+ */
+int ckpt_unpriv_allowed = 1;	/* default: yes */
+
+
+/*
  * Helpers to write(read) from(to) kernel space to(from) the checkpoint
  * image file descriptor (similar to how a core-dump is performed).
  *
@@ -296,10 +303,13 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 	struct ckpt_ctx *ctx;
 	int ret;
 
-	/* no flags for now */
-	if (flags)
+	/* check user flags */
+	if (flags & ~CKPT_USER_FLAGS)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	if (pid == 0)
 		pid = current->pid;
 	ctx = ckpt_ctx_alloc(fd, flags | CKPT_CTX_CHECKPOINT);
@@ -334,6 +344,9 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
 	if (flags)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	/* FIXME: for now, we use 'crid' as a pid */
 	pid = (pid_t) crid;
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 85eb184..09d3238 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -10,6 +10,13 @@
  *  distribution for more details.
  */
 
+#define CKPT_VERSION  1
+
+#define CHECKPOINT_SUBTREE	0x4
+
+
+#ifdef __KERNEL__
+
 struct ckpt_ctx;
 
 #include <linux/list.h>
@@ -19,7 +26,6 @@ struct ckpt_ctx;
 #include <linux/sched.h>
 #include <asm/atomic.h>
 
-#define CKPT_VERSION  1
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
@@ -67,5 +73,9 @@ struct ckpt_ctx {
 #define CKPT_CTX_CHECKPOINT	0x1
 #define CKPT_CTX_RESTART	0x2
 
+#define CKPT_USER_FLAGS		(CHECKPOINT_SUBTREE)
+
+
+#endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e3d2c7d..21f9c48 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -192,6 +192,10 @@ int sysctl_legacy_va_layout;
 extern int prove_locking;
 extern int lock_stat;
 
+#ifdef CONFIG_CHECKPOINT
+extern int ckpt_unpriv_allowed;
+#endif
+
 /* The default sysctl tables: */
 
 static struct ctl_table root_table[] = {
@@ -910,6 +914,20 @@ static struct ctl_table kern_table[] = {
 		.child		= slow_work_sysctls,
 	},
 #endif
+#ifdef CONFIG_CHECKPOINT
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "ckpt_unpriv_allowed",
+		.data		= &ckpt_unpriv_allowed,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
+
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
@@ -1302,6 +1320,7 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= &scan_unevictable_handler,
 	},
 #endif
+
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
-- 
1.5.4.3
