From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] kernel: show current values of ucounts
Date: Thu, 11 Aug 2016 00:02:13 -0700
Message-ID: <1470898933-5336-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds /proc/ucounts where all non-zero ucounts for a current
userns are shown.

$ cat /proc/ucounts
user:	      1000	         1
net:	      1000	         1
mnt:	      1000	         2
mnt:	         0	        10
cgroup:	         0	         1

There are three columns: type, uid, value.

Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 kernel/ucount.c | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 121 insertions(+)

diff --git a/kernel/ucount.c b/kernel/ucount.c
index 9d20d5d..02a7b7f 100644
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
@@ -232,4 +234,123 @@ static __init int user_namespace_sysctl_init(void)
 }
 subsys_initcall(user_namespace_sysctl_init);
 
+#ifdef CONFIG_PROC_FS
+struct ucounts_iterator {
+	int	hash;
+};
+
+static void *ucounts_start(struct seq_file *f, loff_t *pos)
+{
+	struct ucounts_iterator *iter = f->private;
+	struct user_namespace *ns = current_user_ns();
+	int h, i = 0;
+
+	spin_lock(&ucounts_lock);
+	for (h = 0; h < (1 << UCOUNTS_HASHTABLE_BITS); h++) {
+		struct ucounts *ucounts;
+
+		hlist_for_each_entry(ucounts, &ucounts_hashtable[h], node) {
+			if (ucounts->ns != ns)
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
+	struct user_namespace *ns = current_user_ns();
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
+			if (ucounts->ns != ns)
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
+				 "user", "pid", "uts", "ipc",
+				 "net", "mnt", "cgroup", NULL
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
+		seq_printf(f, "%s:\t%10u\t%10d\n", ns_strs[i], uid, val);
+	}
 
+	return 0;
+}
+
+static const struct seq_operations ucounts_seq_operations = {
+	.start	= ucounts_start,
+	.next	= ucounts_next,
+	.stop	= ucounts_stop,
+	.show	= ucounts_show,
+};
+
+static int ucounts_open(struct inode *inode, struct file *filp)
+{
+	return seq_open_private(filp, &ucounts_seq_operations,
+					sizeof(struct ucounts_iterator));
+}
+
+static const struct file_operations proc_ucounts_operations = {
+	.open		= ucounts_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+static int __init proc_ucounts_init(void)
+{
+	proc_create("ucounts", 0, NULL, &proc_ucounts_operations);
+	return 0;
+}
+fs_initcall(proc_ucounts_init);
+#endif /* CONFIG_PROC_FS */
-- 
2.5.5
