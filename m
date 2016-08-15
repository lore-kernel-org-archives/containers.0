From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] kernel: show current values of user namespace counters
Date: Mon, 15 Aug 2016 13:10:21 -0700
Message-ID: <1471291822-539-2-git-send-email-avagin@openvz.org>
References: <1471291822-539-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1471291822-539-1-git-send-email-avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Recently Eric added user namespace counters.  User namespace counters is
a feature that allows to limit the number of various kernel objects a
user can create. These limits are set via /proc/sys/user/ sysctls on a
per user namespace basis and are applicable to all users in that
namespace.

This patch adds /proc/PID/userns_counts files to provide current usage
of user namespace counters.

  > cat /proc/813/userns_counts
  user_namespaces          101000               1
  pid_namespaces           101000               1
  ipc_namespaces           101000               4
  net_namespaces           101000               2
  mnt_namespaces           101000               5
  mnt_namespaces           100000               1

The meanings of the columns are as follows, from left to right:

  Name         Object name
  UID          User ID
  Usage        Current usage

Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 fs/proc/array.c                |  57 +++++++++++++++++++++++
 fs/proc/base.c                 |   3 ++
 fs/proc/internal.h             |   1 +
 include/linux/user_namespace.h |   8 ++++
 kernel/ucount.c                | 102 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 171 insertions(+)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 88c7de1..f186625 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -734,3 +734,60 @@ const struct file_operations proc_tid_children_operations = {
 	.release = children_seq_release,
 };
 #endif /* CONFIG_PROC_CHILDREN */
+
+#ifdef CONFIG_USER_NS
+static int ucounts_open(struct inode *inode, struct file *filp)
+{
+	struct ucounts_iterator *iter;
+	struct seq_file *seq;
+	int ret;
+
+	struct task_struct *task;
+	struct user_namespace *ns;
+
+	task = get_proc_task(inode);
+	if (!task)
+		return -ESRCH;
+
+	rcu_read_lock();
+	ns = get_user_ns(__task_cred(task)->user_ns);
+	rcu_read_unlock();
+
+	put_task_struct(task);
+
+	if (ns == NULL)
+		return -ESRCH;
+
+	ret = seq_open_private(filp, &ucounts_seq_operations,
+					sizeof(struct ucounts_iterator));
+
+	if (ret) {
+		put_user_ns(ns);
+		return ret;
+	}
+
+	seq = filp->private_data;
+	iter = seq->private;
+	iter->ns = ns;
+
+	return 0;
+}
+
+int ucounts_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct ucounts_iterator *iter = seq->private;
+
+	put_user_ns(iter->ns);
+
+	return seq_release_private(inode, file);
+}
+
+
+const struct file_operations proc_ucounts_operations = {
+	.open		= ucounts_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= ucounts_release,
+};
+#endif /* CONFIG_USER_NS */
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 54e2702..4252f7a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2910,6 +2910,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
 	REG("timerslack_ns", S_IRUGO|S_IWUGO, proc_pid_set_timerslack_ns_operations),
+#ifdef CONFIG_USER_NS
+	REG("userns_counts",  S_IRUGO, proc_ucounts_operations),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7931c55..845cadb 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -298,6 +298,7 @@ extern const struct file_operations proc_pid_smaps_operations;
 extern const struct file_operations proc_tid_smaps_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_ucounts_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 30ffe10..5f824dd 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -106,6 +106,14 @@ extern ssize_t proc_setgroups_write(struct file *, const char __user *, size_t,
 extern int proc_setgroups_show(struct seq_file *m, void *v);
 extern bool userns_may_setgroups(const struct user_namespace *ns);
 extern bool current_in_userns(const struct user_namespace *target_ns);
+
+struct ucounts_iterator {
+	struct user_namespace *ns;
+	int	hash;
+};
+
+extern const struct seq_operations ucounts_seq_operations;
+
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 6ebbe9b..cef09e3 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -9,6 +9,8 @@
 #include <linux/sysctl.h>
 #include <linux/slab.h>
 #include <linux/hash.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
 #include <linux/user_namespace.h>
 
 #define UCOUNTS_HASHTABLE_BITS 10
@@ -232,4 +234,104 @@ static __init int user_namespace_sysctl_init(void)
 }
 subsys_initcall(user_namespace_sysctl_init);
 
+#ifdef CONFIG_PROC_FS
+static void *ucounts_start(struct seq_file *f, loff_t *pos)
+{
+	struct ucounts_iterator *iter = f->private;
+	int h, i = 0;
+
+	spin_lock(&ucounts_lock);
+	for (h = 0; h < (1 << UCOUNTS_HASHTABLE_BITS); h++) {
+		struct ucounts *ucounts;
+
+		hlist_for_each_entry(ucounts, &ucounts_hashtable[h], node) {
+			if (ucounts->ns != iter->ns)
+				continue;
+			if (i++ < *pos)
+				continue;
+
+			iter->hash = h;
+
+			return ucounts;
+		}
+	}
+
+	return NULL;
+}
+
+static void ucounts_stop(struct seq_file *f, void *v)
+{
+	spin_unlock(&ucounts_lock);
+}
+
+static void *ucounts_next(struct seq_file *f, void *v, loff_t *pos)
+{
+	struct ucounts_iterator *iter = f->private;
+	struct ucounts *ucounts = v;
+	int h;
+
+	++*pos;
+
+	for (h = iter->hash; h < (1 << UCOUNTS_HASHTABLE_BITS); h++) {
+		struct hlist_node *node;
+
+		if (ucounts == NULL) {
+			node = ucounts_hashtable[h].first;
+			iter->hash = h;
+		} else
+			node = ucounts->node.next;
+
+		ucounts = hlist_entry(node, struct ucounts, node);
+
+		hlist_for_each_entry_from(ucounts, node) {
+			if (ucounts->ns != iter->ns)
+				continue;
+
+			return ucounts;
+		}
+
+		ucounts = NULL;
+	}
+
+	return NULL;
+}
+
+static int ucounts_show(struct seq_file *f, void *v)
+{
+	static const char * const ns_strs[] = {
+				"user_namespaces",
+				"pid_namespaces",
+				"uts_namespaces",
+				"ipc_namespaces",
+				"net_namespaces",
+				"mnt_namespaces",
+				"cgroup_namespaces",
+				NULL
+	};
+	struct user_namespace *ns = current_user_ns();
+	struct ucounts *ucounts = v;
+	uid_t uid;
+	int i;
+
+	uid = from_kuid_munged(ns, ucounts->uid);
+
+	for (i = 0; ns_strs[i]; i++) {
+		int val = atomic_read(&ucounts->ucount[i]);
+
+		if (val == 0)
+			continue;
+
+		seq_printf(f, "%-20s %10u\t%10d\n", ns_strs[i], uid, val);
+	}
+
+	return 0;
+}
+
+const struct seq_operations ucounts_seq_operations = {
+	.start	= ucounts_start,
+	.next	= ucounts_next,
+	.stop	= ucounts_stop,
+	.show	= ucounts_show,
+};
 
+#endif /* CONFIG_PROC_FS */
-- 
2.5.5
