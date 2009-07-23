From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: [signal 2/3] checkpoint/restart of rlimit
Date: Thu, 23 Jul 2009 10:48:33 -0400
Message-ID: <1248360514-20710-2-git-send-email-orenl@librato.com>
References: <1248360514-20710-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248360514-20710-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
List-Id: containers.vger.kernel.org

This patch adds checkpoint and restart of rlimit information
that is part of shared signal_struct.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    2 ++
 checkpoint/restart.c           |    3 +++
 checkpoint/signal.c            |   27 +++++++++++++++++++++++----
 include/linux/checkpoint_hdr.h |   17 +++++++++++++++++
 include/linux/resource.h       |    4 ++++
 kernel/sys.c                   |   39 +++++++++++++++++++++++----------------
 6 files changed, 72 insertions(+), 20 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 1522e6f..64c2d4d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -199,6 +199,8 @@ static void fill_kernel_const(struct ckpt_hdr_const *h)
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
 	h->uts_domainname_len = sizeof(uts->domainname);
+	/* rlimit */
+	h->rlimit_nlimits = RLIM_NLIMITS;
 }
 
 /* write the checkpoint header */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 65cafd9..e80df05 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -317,6 +317,9 @@ static int check_kernel_const(struct ckpt_hdr_const *h)
 		return -EINVAL;
 	if (h->uts_domainname_len != sizeof(uts->domainname))
 		return -EINVAL;
+	/* rlimit */
+	if (h->rlimit_nlimits != RLIM_NLIMITS)
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 70df7c4..b3f1d3e 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/errno.h>
+#include <linux/resource.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -168,13 +169,22 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal *h;
+	struct signal_struct *signal;
+	struct rlimit *rlim;
 	int ret;
 
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
@@ -190,15 +200,24 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
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
+ out:
 	ckpt_hdr_put(ctx, h);
-	return 0;
+	return ret;
 }
 
 int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 63afdc7..0fd83b0 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -143,6 +143,8 @@ struct ckpt_hdr_const {
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
 	__u16 uts_domainname_len;
+	/* rlimit */
+	__u16 rlimit_nlimits;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -430,8 +432,23 @@ struct ckpt_hdr_sighand {
 	struct ckpt_hdr_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_rlimit {
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
+	struct ckpt_hdr_rlimit rlim[CKPT_RLIM_NLIMITS];
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/resource.h b/include/linux/resource.h
index 40fc7e6..87e1bf3 100644
--- a/include/linux/resource.h
+++ b/include/linux/resource.h
@@ -72,4 +72,8 @@ struct rlimit {
 
 int getrusage(struct task_struct *p, int who, struct rusage __user *ru);
 
+#ifdef __KERNEL__
+extern int do_setrlimit(unsigned int resource, struct rlimit *rlim);
+#endif
+
 #endif
diff --git a/kernel/sys.c b/kernel/sys.c
index da4f9e0..80561c3 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1144,40 +1144,34 @@ SYSCALL_DEFINE2(old_getrlimit, unsigned int, resource,
 
 #endif
 
-SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
+int do_setrlimit(unsigned int resource, struct rlimit *new_rlim)
 {
-	struct rlimit new_rlim, *old_rlim;
+	struct rlimit *old_rlim;
 	int retval;
 
-	if (resource >= RLIM_NLIMITS)
-		return -EINVAL;
-	if (copy_from_user(&new_rlim, rlim, sizeof(*rlim)))
-		return -EFAULT;
-	if (new_rlim.rlim_cur > new_rlim.rlim_max)
-		return -EINVAL;
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
@@ -1189,14 +1183,27 @@ SYSCALL_DEFINE2(setrlimit, unsigned int, resource, struct rlimit __user *, rlim)
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
+	if (new_rlim.rlim_cur > new_rlim.rlim_max)
+		return -EINVAL;
+	return do_setrlimit(resource, &new_rlim);
+}
+
 /*
  * It would make sense to put struct rusage in the task_struct,
  * except that would make the task_struct be *really big*.  After
-- 
1.6.0.4
