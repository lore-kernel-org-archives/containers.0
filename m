From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 20/20] audit: introduce /proc/<pid>/audit_backlog_limit
Date: Thu, 24 Oct 2013 15:32:05 +0800
Message-ID: <1382599925-25143-21-git-send-email-gaofeng__3524.85652915693$1382600018$gmane$org@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1382599925-25143-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: toshi.okajima-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Since the backlog_limit of new created audit namespace
is zero, this audit namespace is unavailable, this patch
introdeces a proc file audit_backlog_limit. only privileged
user of host has rights to setup backlog_limit for audit
namespace. this prevents unprivileged user into costing
memory through create user namespace and then create audit
namespace.

Inder to keep the consistent behavior as before, for init
audit namespace, the backlog_limit can be changed only
through netlink interface.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/proc/base.c                  | 53 +++++++++++++++++++++++++
 include/linux/audit_namespace.h |  7 ++++
 kernel/audit_namespace.c        | 86 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 146 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1485e38..3553699 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -83,6 +83,7 @@
 #include <linux/elf.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/audit_namespace.h>
 #include <linux/fs_struct.h>
 #include <linux/slab.h>
 #include <linux/flex_array.h>
@@ -2545,6 +2546,52 @@ static const struct file_operations proc_projid_map_operations = {
 };
 #endif /* CONFIG_USER_NS */
 
+#ifdef CONFIG_AUDIT_NS
+ssize_t proc_audit_backlog_read(struct file *file,
+				char __user *buf,
+				size_t count,
+				loff_t *ppos)
+{
+	struct task_struct *task = NULL;
+	ssize_t ret;
+
+	task = get_proc_task(file_inode(file));
+	if (!task)
+		return -ESRCH;
+
+	ret = audit_backlog_read(task, buf, count, ppos);
+
+	put_task_struct(task);
+
+	return ret;
+}
+
+ssize_t proc_audit_backlog_write(struct file *file,
+				 const char __user *buf,
+				 size_t size,
+				 loff_t *ppos)
+{
+	int ret;
+	struct task_struct *task;
+
+	task = get_proc_task(file_inode(file));
+	if (!task)
+		return -ESRCH;
+
+	ret = audit_backlog_write(task, buf, size, ppos);
+
+	put_task_struct(task);
+
+	return ret;
+}
+
+static const struct file_operations proc_audit_backlog_operations = {
+	.read		= proc_audit_backlog_read,
+	.write		= proc_audit_backlog_write,
+	.llseek		= generic_file_llseek,
+};
+#endif /* CONFIG_AUDIT_NS */
+
 static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task)
 {
@@ -2635,6 +2682,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("loginuid",   S_IWUSR|S_IRUGO, proc_loginuid_operations),
 	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
 #endif
+#ifdef CONFIG_AUDIT_NS
+	REG("audit_backlog_limit", S_IRUGO|S_IWUSR, proc_audit_backlog_operations),
+#endif
 #ifdef CONFIG_FAULT_INJECTION
 	REG("make-it-fail", S_IRUGO|S_IWUSR, proc_fault_inject_operations),
 #endif
@@ -2973,6 +3023,9 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("loginuid",  S_IWUSR|S_IRUGO, proc_loginuid_operations),
 	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
 #endif
+#ifdef CONFIG_AUDIT_NS
+	REG("audit_backlog_limit", S_IRUGO|S_IWUSR, proc_audit_backlog_operations),
+#endif
 #ifdef CONFIG_FAULT_INJECTION
 	REG("make-it-fail", S_IRUGO|S_IWUSR, proc_fault_inject_operations),
 #endif
diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index 4648b4f..c913fe8 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -58,6 +58,13 @@ void put_audit_ns(struct audit_namespace *ns)
 }
 
 extern int unshare_audit_namespace(void);
+extern ssize_t audit_backlog_read(struct task_struct *,
+				  char __user *,
+				  size_t, loff_t *);
+extern ssize_t audit_backlog_write(struct task_struct *,
+				   const char __user *,
+				   size_t size, loff_t *);
+
 #else
 static inline
 struct audit_namespace *get_audit_ns(struct audit_namespace *ns)
diff --git a/kernel/audit_namespace.c b/kernel/audit_namespace.c
index 28c608e..e2319b8 100644
--- a/kernel/audit_namespace.c
+++ b/kernel/audit_namespace.c
@@ -1,5 +1,11 @@
 #include <linux/audit_namespace.h>
 #include <linux/export.h>
+#include <linux/proc_ns.h>
+#include <linux/seq_file.h>
+#include <linux/pid.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include "audit.h"
 
 struct audit_namespace init_audit_ns = {
 	.count = ATOMIC_INIT(1),
@@ -35,3 +41,83 @@ int unshare_audit_namespace(void)
 
 	return 0;
 }
+
+#define TMPBUFLEN 21
+ssize_t audit_backlog_read(struct task_struct *tsk,
+			   char __user *buf,
+			   size_t count,
+			   loff_t *ppos)
+{
+	ssize_t len;
+	char tmpbuf[TMPBUFLEN];
+	struct audit_namespace *ns = NULL;
+
+	rcu_read_lock();
+	ns = get_audit_ns(tsk->nsproxy->audit_ns);
+	rcu_read_unlock();
+
+	mutex_lock(&audit_cmd_mutex);
+	len = scnprintf(tmpbuf, TMPBUFLEN, "%d", ns->backlog_limit);
+	mutex_unlock(&audit_cmd_mutex);
+
+	put_audit_ns(ns);
+
+	return simple_read_from_buffer(buf, count, ppos, tmpbuf, len);
+}
+
+ssize_t audit_backlog_write(struct task_struct *tsk,
+			    const char __user *buf,
+			    size_t size,
+			    loff_t *ppos)
+{
+	ssize_t ret = 0;
+	char *page = NULL, *tmp;
+	int audit_log_limit = 0;
+	struct audit_namespace *ns = NULL;
+
+	if (!capable(CAP_AUDIT_CONTROL))
+		return -EPERM;
+
+	if (*ppos != 0)
+		return -EINVAL;
+
+	if (size >= PAGE_SIZE)
+		size = PAGE_SIZE - 1;
+
+	page = (char *)__get_free_page(GFP_TEMPORARY);
+	if (!page)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	ns = get_audit_ns(tsk->nsproxy->audit_ns);
+	rcu_read_unlock();
+
+	if (!ns)
+		goto out_free_page;
+
+	/* Disallow to change init_audit_ns through proc interface */
+	ret = -EPERM;
+	if (ns == &init_audit_ns)
+		goto out_put_audit;
+
+	ret = -EFAULT;
+	if (copy_from_user(page, buf, size))
+		goto out_put_audit;
+
+	ret = -EINVAL;
+	page[size] = '\0';
+	audit_log_limit = simple_strtoul(page, &tmp, 10);
+	if (tmp == page)
+		goto out_put_audit;
+
+	mutex_lock(&audit_cmd_mutex);
+	ns->backlog_limit = audit_log_limit;
+	mutex_unlock(&audit_cmd_mutex);
+
+	ret = size;
+out_put_audit:
+	put_audit_ns(ns);
+out_free_page:
+	free_page((unsigned long) page);
+	return ret;
+}
-- 
1.8.3.1
