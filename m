From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] user namespaces: debug refcounts
Date: Mon, 18 May 2009 20:45:54 -0500
Message-ID: <20090519014554.GF28312@us.ibm.com>
References: <20090519014446.GA28277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090519014446.GA28277-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, alexey-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Create /proc/userns, which prints out all user namespaces.  It
prints the address of the user_ns itself, the uid and userns address
of the user who created it, and the reference count.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/user_namespace.h |    2 +
 kernel/user.c                  |    1 +
 kernel/user_namespace.c        |   84 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index a2b82d5..e64d602 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -14,8 +14,10 @@ struct user_namespace {
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*creator;
 	struct work_struct	destroyer;
+	struct list_head	list;
 };
 
+extern spinlock_t usernslist_lock;
 extern struct user_namespace init_user_ns;
 
 #ifdef CONFIG_USER_NS
diff --git a/kernel/user.c b/kernel/user.c
index 850e0ba..6474422 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -23,6 +23,7 @@ struct user_namespace init_user_ns = {
 		.refcount	= ATOMIC_INIT(2),
 	},
 	.creator = &root_user,
+	.list = LIST_HEAD_INIT(init_user_ns.list),
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e624b0f..8d7c725 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -10,6 +10,11 @@
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
 #include <linux/cred.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/spinlock.h>
+
+DEFINE_SPINLOCK(usernslist_lock);
 
 static struct user_namespace *_new_user_ns(struct user_struct *creator,
 				   struct user_struct **newroot)
@@ -40,6 +45,9 @@ static struct user_namespace *_new_user_ns(struct user_struct *creator,
 	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
 	kref_set(&ns->kref, 1);
 
+	spin_lock(&usernslist_lock);
+	list_add_tail(&ns->list, &init_user_ns.list);
+	spin_unlock(&usernslist_lock);
 	*newroot = root_user;
 	return ns;
 }
@@ -90,6 +98,9 @@ static void free_user_ns_work(struct work_struct *work)
 {
 	struct user_namespace *ns =
 		container_of(work, struct user_namespace, destroyer);
+	spin_lock(&usernslist_lock);
+	list_del(&ns->list);
+	spin_unlock(&usernslist_lock);
 	free_uid(ns->creator);
 	kfree(ns);
 }
@@ -103,3 +114,76 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+#ifdef CONFIG_PROC_FS
+static int proc_userns_show(struct seq_file *m, void *v)
+{
+	struct user_namespace *ns = v;
+	seq_printf(m, "userns %p creator (uid %d ns %p) count %d\n",
+		(void *)ns, ns->creator->uid, (void *) ns->creator->user_ns,
+		atomic_read(&ns->kref.refcount));
+	return 0;
+}
+
+static void *proc_userns_start(struct seq_file *p, loff_t *_pos)
+{
+	loff_t pos = *_pos;
+	struct user_namespace *ns = &init_user_ns;
+	spin_lock(&usernslist_lock);
+	while (pos) {
+		pos--;
+		ns = list_entry(ns->list.next, struct user_namespace, list);
+		if (ns  == &init_user_ns)
+			return NULL;
+	}
+	return ns;
+}
+
+static void *proc_userns_next(struct seq_file *p, void *v, loff_t *_pos)
+{
+	struct user_namespace *ns = v;
+	(*_pos)++;
+	ns = list_entry(ns->list.next, struct user_namespace, list);
+	if (ns == &init_user_ns)
+		return NULL;
+	return ns;
+}
+
+static void proc_userns_stop(struct seq_file *p, void *v)
+{
+	spin_unlock(&usernslist_lock);
+}
+
+static const struct seq_operations proc_userns_ops;
+
+static int proc_userns_open(struct inode *inode, struct file *filp)
+{
+	return seq_open(filp, &proc_userns_ops);
+}
+
+static const struct seq_operations proc_userns_ops = {
+	.start	= proc_userns_start,
+	.next	= proc_userns_next,
+	.stop	= proc_userns_stop,
+	.show	= proc_userns_show,
+};
+
+const struct file_operations proc_userns_fops = {
+	.open		= proc_userns_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static __init int user_ns_debug(void)
+{
+	struct proc_dir_entry *p;
+
+	p = proc_create("userns", 0, NULL, &proc_userns_fops);
+	if (!p)
+		panic("cannot create /proc/userns\n");
+	return 0;
+}
+
+__initcall(user_ns_debug);
+#endif
-- 
1.6.1
