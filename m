From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 066/100] c/r: [signal 2/4] checkpoint/restart of rlimit
Date: Sat,  1 May 2010 10:15:48 -0400
Message-ID: <1272723382-19470-67-git-send-email-orenl__30471.4347505525$1272727897$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds checkpoint and restart of rlimit information
that is part of shared signal_struct.

Changelog[v21]:
  - [Matt Helsley] Move the signal c/r changes to kernel/signal.c
      Remove the "out" label in restore_signal(). It won't be
      used until a subsequent patch.

Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |   17 +++++++++++++++++
 include/linux/resource.h       |    1 +
 kernel/checkpoint/checkpoint.c |    2 ++
 kernel/checkpoint/restart.c    |    3 +++
 kernel/signal.c                |   28 +++++++++++++++++++++++-----
 kernel/sys.c                   |   36 +++++++++++++++++++++++-------------
 6 files changed, 69 insertions(+), 18 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 19c778b..0320bfa 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -217,6 +217,8 @@ struct ckpt_const {
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
 	__u16 uts_domainname_len;
+	/* rlimit */
+	__u16 rlimit_nlimits;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -543,8 +545,23 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_rlimit {
+	__u64 rlim_cur;
+	__u64 rlim_max;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/resource.h> from userspace, so define: */
+#define CKPT_RLIM_NLIMITS  16
+#ifdef __KERNEL__
+#include <linux/resource.h>
+#if CKPT_RLIM_NLIMITS != RLIM_NLIMITS
+#error CKPT_RLIM_NLIMIT size is wrong per asm-generic/resource.h
+#endif
+#endif
+
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/resource.h b/include/linux/resource.h
index f1e914e..35f6163 100644
--- a/include/linux/resource.h
+++ b/include/linux/resource.h
@@ -73,6 +73,7 @@ struct rlimit {
 struct task_struct;
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru);
+int do_setrlimit(unsigned int resource, struct rlimit *rlim);
 
 #endif /* __KERNEL__ */
 
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index d75f753..f72458d 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -123,6 +123,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
 	h->uts_domainname_len = sizeof(uts->domainname);
+	/* rlimit */
+	h->rlimit_nlimits = RLIM_NLIMITS;
 }
 
 /* write the checkpoint header */
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 92d3e00..3b2593d 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -585,6 +585,9 @@ static int check_kernel_const(struct ckpt_const *h)
 		return -EINVAL;
 	if (h->uts_domainname_len != sizeof(uts->domainname))
 		return -EINVAL;
+	/* rlimit */
+	if (h->rlimit_nlimits != RLIM_NLIMITS)
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/kernel/signal.c b/kernel/signal.c
index 0e71eee..aae1f73 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -32,6 +32,7 @@
 #include <trace/events/signal.h>
 #define CKPT_DFLAG  CKPT_DSYS
 #include <linux/errno.h>
+#include <linux/resource.h>
 #include <linux/checkpoint.h>
 
 #include <asm/param.h>
@@ -2913,13 +2914,22 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
 static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal *h;
-	int ret;
+	struct signal_struct *signal;
+	struct rlimit *rlim;
+	int i, ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
 		return -ENOMEM;
 
-	/* fill in later */
+	signal = t->signal;
+	rlim = signal->rlim;
+
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
+		h->rlim[i].rlim_max = rlim[i].rlim_max;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -2935,15 +2945,23 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 static int restore_signal(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_signal *h;
+	struct rlimit rlim;
+	int i, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	/* fill in later */
-
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		rlim.rlim_cur = h->rlim[i].rlim_cur;
+		rlim.rlim_max = h->rlim[i].rlim_max;
+		ret = do_setrlimit(i, &rlim);
+		if (ret < 0)
+			break;
+	}
 	ckpt_hdr_put(ctx, h);
-	return 0;
+	return ret;
 }
 
 int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
diff --git a/kernel/sys.c b/kernel/sys.c
index ec11a3f..9a98d05 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1211,40 +1211,39 @@ SYSCALL_DEFINE2(old_getrlimit, unsigned int, resource,
 
 #endif
 
-SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+int do_setrlimit(unsigned int resource, struct rlimit *new_rlim)
 {
-	struct rlimit new_rlim, *old_rlim;
+	struct rlimit *old_rlim;
 	int retval;
 
 	if (resource >= RLIM_NLIMITS)
 		return -EINVAL;
-	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
-		return -EFAULT;
-	if (new_rlim.rlim_cur > new_rlim.rlim_max)
+	if (new_rlim->rlim_cur > new_rlim->rlim_max)
 		return -EINVAL;
+
 	old_rlim = current->signal->rlim + resource;
-	if ((new_rlim.rlim_max > old_rlim->rlim_max) &&
+	if ((new_rlim->rlim_max > old_rlim->rlim_max) &&
 	    !capable(CAP_SYS_RESOURCE))
 		return -EPERM;
-	if (resource == RLIMIT_NOFILE && new_rlim.rlim_max > sysctl_nr_open)
+	if (resource == RLIMIT_NOFILE && new_rlim->rlim_max > sysctl_nr_open)
 		return -EPERM;
 
-	retval = security_task_setrlimit(resource, &new_rlim);
+	retval = security_task_setrlimit(resource, new_rlim);
 	if (retval)
 		return retval;
 
-	if (resource == RLIMIT_CPU && new_rlim.rlim_cur == 0) {
+	if (resource == RLIMIT_CPU && new_rlim->rlim_cur == 0) {
 		/*
 		 * The caller is asking for an immediate RLIMIT_CPU
 		 * expiry.  But we use the zero value to mean "it was
 		 * never set".  So let's cheat and make it one second
 		 * instead
 		 */
-		new_rlim.rlim_cur = 1;
+		new_rlim->rlim_cur = 1;
 	}
 
 	task_lock(current->group_leader);
-	*old_rlim = new_rlim;
+	*old_rlim = *new_rlim;
 	task_unlock(current->group_leader);
 
 	if (resource != RLIMIT_CPU)
@@ -1256,14 +1255,25 @@ SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
 	 * very long-standing error, and fixing it now risks breakage of
 	 * applications, so we live with it
 	 */
-	if (new_rlim.rlim_cur == RLIM_INFINITY)
+	if (new_rlim->rlim_cur == RLIM_INFINITY)
 		goto out;
 
-	update_rlimit_cpu(new_rlim.rlim_cur);
+	update_rlimit_cpu(new_rlim->rlim_cur);
 out:
 	return 0;
 }
 
+SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+{
+	struct rlimit new_rlim;
+
+	if (resource >= RLIM_NLIMITS)
+		return -EINVAL;
+	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
+		return -EFAULT;
+	return do_setrlimit(resource, &new_rlim);
+}
+
 /*
  * It would make sense to put struct rusage in the task_struct,
  * except that would make the task_struct be *really big*.  After
-- 
1.6.3.3
