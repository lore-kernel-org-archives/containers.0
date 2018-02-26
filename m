From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [net-next v3 1/2] bpf, seccomp: Add eBPF filter capabilities
Date: Mon, 26 Feb 2018 07:27:05 +0000
Message-ID: <20180226072702.GA27057@ircssh-2.c.rugged-nimbus-611.internal>
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
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

This introduces the BPF_PROG_TYPE_SECCOMP bpf program type. It is meant
to be used for seccomp filters as an alternative to cBPF filters. The
program type has relatively limited capabilities in terms of helpers,
but that can be extended later on.

The eBPF code loading is separated from attachment of the filter, so
a privileged user can load the filter, and pass it back to an
unprivileged user who can attach it and use it at a later time.

In order to attach the filter itself, you need to supply a flag to the
seccomp syscall indicating that a eBPF filter is being attached, as
opposed to a cBPF one. Verification occurs at program load time,
so the user should only receive errors related to attachment.

Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
---
 arch/Kconfig                 |   8 +++
 include/linux/bpf_types.h    |   3 +
 include/linux/seccomp.h      |   3 +-
 include/uapi/linux/bpf.h     |   2 +
 include/uapi/linux/seccomp.h |   7 +-
 kernel/bpf/syscall.c         |   1 +
 kernel/seccomp.c             | 159 ++++++++++++++++++++++++++++++++++++-------
 7 files changed, 156 insertions(+), 27 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 76c0b54443b1..8490d35e59d6 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -401,6 +401,14 @@ config SECCOMP_FILTER
 
 	  See Documentation/prctl/seccomp_filter.txt for details.
 
+config SECCOMP_FILTER_EXTENDED
+	bool "Extended BPF seccomp filters"
+	depends on SECCOMP_FILTER && BPF_SYSCALL
+	depends on !CHECKPOINT_RESTORE
+	help
+	  Enables seccomp filters to be written in eBPF, as opposed
+	  to just cBPF filters.
+
 config HAVE_GCC_PLUGINS
 	bool
 	help
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 19b8349a3809..945c65c4e461 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -22,6 +22,9 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event)
 #ifdef CONFIG_CGROUP_BPF
 BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_DEVICE, cg_dev)
 #endif
+#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
+BPF_PROG_TYPE(BPF_PROG_TYPE_SECCOMP, seccomp)
+#endif
 
 BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
 BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index c723a5c4e3ff..a7df3ba6cf25 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -5,7 +5,8 @@
 #include <uapi/linux/seccomp.h>
 
 #define SECCOMP_FILTER_FLAG_MASK	(SECCOMP_FILTER_FLAG_TSYNC | \
-					 SECCOMP_FILTER_FLAG_LOG)
+					 SECCOMP_FILTER_FLAG_LOG | \
+					 SECCOMP_FILTER_FLAG_EXTENDED)
 
 #ifdef CONFIG_SECCOMP
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index db6bdc375126..5f96cb7ed954 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -1,3 +1,4 @@
+
 /* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
  *
@@ -133,6 +134,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SOCK_OPS,
 	BPF_PROG_TYPE_SK_SKB,
 	BPF_PROG_TYPE_CGROUP_DEVICE,
+	BPF_PROG_TYPE_SECCOMP,
 };
 
 enum bpf_attach_type {
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 2a0bd9dd104d..730af6c7ec2e 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -16,10 +16,11 @@
 #define SECCOMP_SET_MODE_FILTER		1
 #define SECCOMP_GET_ACTION_AVAIL	2
 
-/* Valid flags for SECCOMP_SET_MODE_FILTER */
-#define SECCOMP_FILTER_FLAG_TSYNC	1
-#define SECCOMP_FILTER_FLAG_LOG		2
 
+/* Valid flags for SECCOMP_SET_MODE_FILTER */
+#define SECCOMP_FILTER_FLAG_TSYNC	(1 << 0)
+#define SECCOMP_FILTER_FLAG_LOG		(1 << 1)
+#define SECCOMP_FILTER_FLAG_EXTENDED	(1 << 2)
 /*
  * All BPF programs must return a 32-bit value.
  * The bottom 16-bits are for optional return data.
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index e24aa3241387..86d6ec8b916d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1202,6 +1202,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 
 	if (type != BPF_PROG_TYPE_SOCKET_FILTER &&
 	    type != BPF_PROG_TYPE_CGROUP_SKB &&
+	    type != BPF_PROG_TYPE_SECCOMP &&
 	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index dc77548167ef..d95c24181a6c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -37,6 +37,7 @@
 #include <linux/security.h>
 #include <linux/tracehook.h>
 #include <linux/uaccess.h>
+#include <linux/bpf.h>
 
 /**
  * struct seccomp_filter - container for seccomp BPF programs
@@ -367,17 +368,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
 
-	/*
-	 * Installing a seccomp filter requires that the task has
-	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
-	 * This avoids scenarios where unprivileged tasks can affect the
-	 * behavior of privileged children.
-	 */
-	if (!task_no_new_privs(current) &&
-	    security_capable_noaudit(current_cred(), current_user_ns(),
-				     CAP_SYS_ADMIN) != 0)
-		return ERR_PTR(-EACCES);
-
 	/* Allocate a new seccomp_filter */
 	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
 	if (!sfilter)
@@ -423,6 +413,48 @@ seccomp_prepare_user_filter(const char __user *user_filter)
 	return filter;
 }
 
+#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
+/**
+ * seccomp_prepare_extended_filter - prepares a user-supplied eBPF fd
+ * @user_filter: pointer to the user data containing an fd.
+ *
+ * Returns 0 on success and non-zero otherwise.
+ */
+static struct seccomp_filter *
+seccomp_prepare_extended_filter(const char __user *user_fd)
+{
+	struct seccomp_filter *sfilter;
+	struct bpf_prog *fp;
+	int fd;
+
+	/* Fetch the fd from userspace */
+	if (get_user(fd, (int __user *)user_fd))
+		return ERR_PTR(-EFAULT);
+
+	/* Allocate a new seccomp_filter */
+	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
+	if (!sfilter)
+		return ERR_PTR(-ENOMEM);
+
+	fp = bpf_prog_get_type(fd, BPF_PROG_TYPE_SECCOMP);
+	if (IS_ERR(fp)) {
+		kfree(sfilter);
+		return ERR_CAST(fp);
+	}
+
+	sfilter->prog = fp;
+	refcount_set(&sfilter->usage, 1);
+
+	return sfilter;
+}
+#else
+static struct seccomp_filter *
+seccomp_prepare_extended_filter(const char __user *filter_fd)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif
+
 /**
  * seccomp_attach_filter: validate and attach filter
  * @flags:  flags to change filter behavior
@@ -492,7 +524,10 @@ void get_seccomp_filter(struct task_struct *tsk)
 static inline void seccomp_filter_free(struct seccomp_filter *filter)
 {
 	if (filter) {
-		bpf_prog_destroy(filter->prog);
+		if (bpf_prog_was_classic(filter->prog))
+			bpf_prog_destroy(filter->prog);
+		else
+			bpf_prog_put(filter->prog);
 		kfree(filter);
 	}
 }
@@ -844,7 +879,8 @@ static long seccomp_set_mode_strict(void)
 static long seccomp_set_mode_filter(unsigned int flags,
 				    const char __user *filter)
 {
-	const unsigned long seccomp_mode = SECCOMP_MODE_FILTER;
+	/* We use SECCOMP_MODE_FILTER for both eBPF and cBPF filters */
+	const unsigned long filter_mode = SECCOMP_MODE_FILTER;
 	struct seccomp_filter *prepared = NULL;
 	long ret = -EINVAL;
 
@@ -853,10 +889,31 @@ static long seccomp_set_mode_filter(unsigned int flags,
 		return -EINVAL;
 
 	/* Prepare the new filter before holding any locks. */
-	prepared = seccomp_prepare_user_filter(filter);
+	if (flags & SECCOMP_FILTER_FLAG_EXTENDED)
+		prepared = seccomp_prepare_extended_filter(filter);
+	else
+		prepared = seccomp_prepare_user_filter(filter);
+
 	if (IS_ERR(prepared))
 		return PTR_ERR(prepared);
 
+	/*
+	 * Installing a seccomp filter requires that the task has
+	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
+	 * This avoids scenarios where unprivileged tasks can affect the
+	 * behavior of privileged children.
+	 *
+	 * This is checked after filter preparation because the user
+	 * will get an EINVAL if their filter is invalid prior to the
+	 * EPERM.
+	 */
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(), current_user_ns(),
+				     CAP_SYS_ADMIN) != 0) {
+		ret = -EACCES;
+		goto out_free;
+	}
+
 	/*
 	 * Make sure we cannot change seccomp or nnp state via TSYNC
 	 * while another thread is in the middle of calling exec.
@@ -867,7 +924,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
 
 	spin_lock_irq(&current->sighand->siglock);
 
-	if (!seccomp_may_assign_mode(seccomp_mode))
+	if (!seccomp_may_assign_mode(filter_mode))
 		goto out;
 
 	ret = seccomp_attach_filter(flags, prepared);
@@ -876,7 +933,7 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	/* Do not free the successfully attached filter. */
 	prepared = NULL;
 
-	seccomp_assign_mode(current, seccomp_mode);
+	seccomp_assign_mode(current, filter_mode);
 out:
 	spin_unlock_irq(&current->sighand->siglock);
 	if (flags & SECCOMP_FILTER_FLAG_TSYNC)
@@ -1040,15 +1097,16 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 	if (IS_ERR(filter))
 		return PTR_ERR(filter);
 
+	/* This must be a new non-cBPF filter, since we save
+	 * every cBPF filter's orig_prog above when
+	 * CONFIG_CHECKPOINT_RESTORE is enabled.
+	 */
+	ret = -EMEDIUMTYPE;
 	fprog = filter->prog->orig_prog;
-	if (!fprog) {
-		/* This must be a new non-cBPF filter, since we save
-		 * every cBPF filter's orig_prog above when
-		 * CONFIG_CHECKPOINT_RESTORE is enabled.
-		 */
-		ret = -EMEDIUMTYPE;
+	if (!fprog)
+		goto out;
+	if (!bpf_prog_was_classic(filter->prog))
 		goto out;
-	}
 
 	ret = fprog->len;
 	if (!data)
@@ -1241,6 +1299,61 @@ static int seccomp_actions_logged_handler(struct ctl_table *ro_table, int write,
 	return 0;
 }
 
+#ifdef CONFIG_SECCOMP_FILTER_EXTENDED
+static bool seccomp_is_valid_access(int off, int size,
+				    enum bpf_access_type type,
+				    struct bpf_insn_access_aux *info)
+{
+	if (type != BPF_READ)
+		return false;
+
+	if (off < 0 || off + size > sizeof(struct seccomp_data))
+		return false;
+
+	if (off % size != 0)
+		return false;
+
+	switch (off) {
+	case bpf_ctx_range_till(struct seccomp_data, args[0], args[5]):
+		return (size == sizeof(__u64));
+	case bpf_ctx_range(struct seccomp_data, nr):
+		return (size == FIELD_SIZEOF(struct seccomp_data, nr));
+	case bpf_ctx_range(struct seccomp_data, arch):
+		return (size == FIELD_SIZEOF(struct seccomp_data, arch));
+	case bpf_ctx_range(struct seccomp_data, instruction_pointer):
+		return (size == FIELD_SIZEOF(struct seccomp_data,
+					     instruction_pointer));
+	default:
+		return false;
+	}
+}
+
+static const struct bpf_func_proto *
+seccomp_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	case BPF_FUNC_ktime_get_ns:
+		return &bpf_ktime_get_ns_proto;
+	case BPF_FUNC_get_prandom_u32:
+		return &bpf_get_prandom_u32_proto;
+	case BPF_FUNC_get_current_pid_tgid:
+		return &bpf_get_current_pid_tgid_proto;
+	default:
+		return NULL;
+	}
+}
+
+const struct bpf_prog_ops seccomp_prog_ops = {
+};
+
+const struct bpf_verifier_ops seccomp_verifier_ops = {
+	.get_func_proto		= seccomp_func_proto,
+	.is_valid_access	= seccomp_is_valid_access,
+};
+#endif /* CONFIG_SECCOMP_FILTER_EXTENDED */
+
 static struct ctl_path seccomp_sysctl_path[] = {
 	{ .procname = "kernel", },
 	{ .procname = "seccomp", },
-- 
2.14.1
