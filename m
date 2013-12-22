From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] binder: implement namepsace support for Android binder
	driver
Date: Sun, 22 Dec 2013 05:07:40 -0500
Message-ID: <45c5d62a35f19228a681f5be9834741baabfdb0d.1387706794.git.orenl@cellrox.com>
References: <cover.1387706794.git.orenl@cellrox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1387706794.git.orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Add namespaces support for the Android binder driver.
As binder is an IPC mechanism, tie its namespace to IPC_NS.

In binder, the first process to call BINDER_SET_CONTEXT_MGR ioctl
becomes the manager with context 0, and thereafter IPC is realized
through binder handles obtained from this manager.

For namespaces, associate a separate binder state with each namespace
so each namespace has its own context manager. Binder users within a
namespace interact only with the context manager there. This suffices
because binder does not allow IPC not via the context manager.

Currently, statistics remain global, except for the list of processes
that hold an open binder device (reported per namespace).

Signed-off-by: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Acked-by: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
---
 drivers/staging/android/Kconfig  |   1 +
 drivers/staging/android/binder.c | 172 ++++++++++++++++++++++++++++++++-------
 2 files changed, 143 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
index 1e9ab6d..208685e 100644
--- a/drivers/staging/android/Kconfig
+++ b/drivers/staging/android/Kconfig
@@ -11,6 +11,7 @@ if ANDROID
 config ANDROID_BINDER_IPC
 	bool "Android Binder IPC Driver"
 	depends on MMU
+	select SYSVIPC
 	default n
 	---help---
 	  Binder is used in Android for both communication between processes,
diff --git a/drivers/staging/android/binder.c b/drivers/staging/android/binder.c
index eaec1da..6f97f89 100644
--- a/drivers/staging/android/binder.c
+++ b/drivers/staging/android/binder.c
@@ -36,24 +36,104 @@
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
+#include <linux/ipc_namespace.h>
 #include <linux/pid_namespace.h>
 
 #include "binder.h"
 #include "binder_trace.h"
 
+/*
+ * Using a private context manager for each binder namespace is sufficient
+ * to isolate between namespaces, because in binder all IPC must be realized
+ * via hanldes obtained from the context manager.
+ *
+ * TODO: currently, most debugfs data is not tracked per binder namespaces.
+ * Except for "procs" which are properly virtualized, everything else is
+ * global, including stats, logs, and dead nodes.
+ */
+struct binder_namespace {
+	struct kref kref;
+
+	struct binder_node *context_mgr_node;
+	kuid_t context_mgr_uid;
+	int last_id;
+
+	struct hlist_head procs;
+};
+
+static struct binder_namespace *create_binder_ns(void)
+{
+	struct binder_namespace *binder_ns;
+
+	binder_ns = kzalloc(sizeof(struct binder_namespace), GFP_KERNEL);
+	if (binder_ns) {
+		kref_init(&binder_ns->kref);
+		binder_ns->context_mgr_uid = INVALID_UID;
+		INIT_HLIST_HEAD(&binder_ns->procs);
+	}
+	return binder_ns;
+}
+
+static void free_binder_ns(struct kref *kref)
+{
+	kfree(container_of(kref, struct binder_namespace, kref));
+}
+
+static void get_binder_ns(struct binder_namespace *binder_ns)
+{
+	kref_get(&binder_ns->kref);
+}
+
+static void put_binder_ns(struct binder_namespace *binder_ns)
+{
+	kref_put(&binder_ns->kref, free_binder_ns);
+}
+
+/*
+ * Binder is an IPC mechanism, so tie its namespace to IPC_NS
+ * using the generic data pointer and per-ipc operations.
+ */
+static struct binder_namespace *current_binder_ns(void)
+{
+	return ipc_access_generic(current->nsproxy->ipc_ns);
+}
+
+int binder_init_ns(struct ipc_namespace *ipcns)
+{
+	struct binder_namespace *binder_ns;
+	int ret = -ENOMEM;
+
+	binder_ns = create_binder_ns();
+	if (binder_ns) {
+		ipc_assign_generic(ipcns, binder_ns);
+		ret = 0;
+	}
+	return ret;
+}
+
+void binder_exit_ns(struct ipc_namespace *ipcns)
+{
+	struct binder_namespace *binder_ns;
+
+	binder_ns = ipc_access_generic(ipcns);
+	if (binder_ns)
+		put_binder_ns(binder_ns);
+}
+
+struct peripc_operations binder_peripc_ops = {
+	.init = binder_init_ns,
+	.exit = binder_exit_ns,
+};
+
 static DEFINE_MUTEX(binder_main_lock);
 static DEFINE_MUTEX(binder_deferred_lock);
 static DEFINE_MUTEX(binder_mmap_lock);
 
-static HLIST_HEAD(binder_procs);
 static HLIST_HEAD(binder_deferred_list);
 static HLIST_HEAD(binder_dead_nodes);
 
 static struct dentry *binder_debugfs_dir_entry_root;
 static struct dentry *binder_debugfs_dir_entry_proc;
-static struct binder_node *binder_context_mgr_node;
-static kuid_t binder_context_mgr_uid = INVALID_UID;
-static int binder_last_id;
 static struct workqueue_struct *binder_deferred_workqueue;
 
 #define BINDER_DEBUG_ENTRY(name) \
@@ -319,6 +399,8 @@ struct binder_proc {
 	int ready_threads;
 	long default_priority;
 	struct dentry *debugfs_entry;
+
+	struct binder_namespace *binder_ns;
 };
 
 enum {
@@ -900,7 +982,7 @@ static struct binder_node *binder_new_node(struct binder_proc *proc,
 	binder_stats_created(BINDER_STAT_NODE);
 	rb_link_node(&node->rb_node, parent, p);
 	rb_insert_color(&node->rb_node, &proc->nodes);
-	node->debug_id = ++binder_last_id;
+	node->debug_id = ++proc->binder_ns->last_id;
 	node->proc = proc;
 	node->ptr = ptr;
 	node->cookie = cookie;
@@ -921,7 +1003,7 @@ static int binder_inc_node(struct binder_node *node, int strong, int internal,
 		if (internal) {
 			if (target_list == NULL &&
 			    node->internal_strong_refs == 0 &&
-			    !(node == binder_context_mgr_node &&
+			    !(node == node->proc->binder_ns->context_mgr_node &&
 			    node->has_strong_ref)) {
 				pr_err("invalid inc strong node for %d\n",
 					node->debug_id);
@@ -1035,13 +1117,13 @@ static struct binder_ref *binder_get_ref_for_node(struct binder_proc *proc,
 	if (new_ref == NULL)
 		return NULL;
 	binder_stats_created(BINDER_STAT_REF);
-	new_ref->debug_id = ++binder_last_id;
+	new_ref->debug_id = ++proc->binder_ns->last_id;
 	new_ref->proc = proc;
 	new_ref->node = node;
 	rb_link_node(&new_ref->rb_node_node, parent, p);
 	rb_insert_color(&new_ref->rb_node_node, &proc->refs_by_node);
 
-	new_ref->desc = (node == binder_context_mgr_node) ? 0 : 1;
+	new_ref->desc = (node == proc->binder_ns->context_mgr_node) ? 0 : 1;
 	for (n = rb_first(&proc->refs_by_desc); n != NULL; n = rb_next(n)) {
 		ref = rb_entry(n, struct binder_ref, rb_node_desc);
 		if (ref->desc > new_ref->desc)
@@ -1371,7 +1453,7 @@ static void binder_transaction(struct binder_proc *proc,
 			}
 			target_node = ref->node;
 		} else {
-			target_node = binder_context_mgr_node;
+			target_node = proc->binder_ns->context_mgr_node;
 			if (target_node == NULL) {
 				return_error = BR_DEAD_REPLY;
 				goto err_no_context_mgr_node;
@@ -1427,7 +1509,7 @@ static void binder_transaction(struct binder_proc *proc,
 	}
 	binder_stats_created(BINDER_STAT_TRANSACTION_COMPLETE);
 
-	t->debug_id = ++binder_last_id;
+	t->debug_id = ++proc->binder_ns->last_id;
 	e->debug_id = t->debug_id;
 
 	if (reply)
@@ -1730,10 +1812,10 @@ static int binder_thread_write(struct binder_proc *proc,
 			if (get_user(target, (uint32_t __user *)ptr))
 				return -EFAULT;
 			ptr += sizeof(uint32_t);
-			if (target == 0 && binder_context_mgr_node &&
+			if (target == 0 && proc->binder_ns->context_mgr_node &&
 			    (cmd == BC_INCREFS || cmd == BC_ACQUIRE)) {
 				ref = binder_get_ref_for_node(proc,
-					       binder_context_mgr_node);
+				       proc->binder_ns->context_mgr_node);
 				if (ref->desc != target) {
 					binder_user_error("%d:%d tried to acquire reference to desc 0, got %d instead\n",
 						proc->pid, thread->pid,
@@ -2549,6 +2631,7 @@ static long binder_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
 	int ret;
 	struct binder_proc *proc = filp->private_data;
+	struct binder_namespace *binder_ns = proc->binder_ns;
 	struct binder_thread *thread;
 	unsigned int size = _IOC_SIZE(cmd);
 	void __user *ubuf = (void __user *)arg;
@@ -2622,30 +2705,30 @@ static long binder_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		}
 		break;
 	case BINDER_SET_CONTEXT_MGR:
-		if (binder_context_mgr_node != NULL) {
+		if (binder_ns->context_mgr_node != NULL) {
 			pr_err("BINDER_SET_CONTEXT_MGR already set\n");
 			ret = -EBUSY;
 			goto err;
 		}
-		if (uid_valid(binder_context_mgr_uid)) {
-			if (!uid_eq(binder_context_mgr_uid, current->cred->euid)) {
+		if (uid_valid(binder_ns->context_mgr_uid)) {
+			if (!uid_eq(binder_ns->context_mgr_uid, current->cred->euid)) {
 				pr_err("BINDER_SET_CONTEXT_MGR bad uid %d != %d\n",
 				       from_kuid(&init_user_ns, current->cred->euid),
-				       from_kuid(&init_user_ns, binder_context_mgr_uid));
+				       from_kuid(&init_user_ns, binder_ns->context_mgr_uid));
 				ret = -EPERM;
 				goto err;
 			}
 		} else
-			binder_context_mgr_uid = current->cred->euid;
-		binder_context_mgr_node = binder_new_node(proc, NULL, NULL);
-		if (binder_context_mgr_node == NULL) {
+			binder_ns->context_mgr_uid = current->cred->euid;
+		binder_ns->context_mgr_node = binder_new_node(proc, NULL, NULL);
+		if (binder_ns->context_mgr_node == NULL) {
 			ret = -ENOMEM;
 			goto err;
 		}
-		binder_context_mgr_node->local_weak_refs++;
-		binder_context_mgr_node->local_strong_refs++;
-		binder_context_mgr_node->has_strong_ref = 1;
-		binder_context_mgr_node->has_weak_ref = 1;
+		binder_ns->context_mgr_node->local_weak_refs++;
+		binder_ns->context_mgr_node->local_strong_refs++;
+		binder_ns->context_mgr_node->has_strong_ref = 1;
+		binder_ns->context_mgr_node->has_weak_ref = 1;
 		break;
 	case BINDER_THREAD_EXIT:
 		binder_debug(BINDER_DEBUG_THREADS, "%d:%d exit\n",
@@ -2810,10 +2893,15 @@ err_bad_arg:
 static int binder_open(struct inode *nodp, struct file *filp)
 {
 	struct binder_proc *proc;
+	struct binder_namespace *binder_ns;
 
 	binder_debug(BINDER_DEBUG_OPEN_CLOSE, "binder_open: %d:%d\n",
 		     current->group_leader->pid, current->pid);
 
+	binder_ns = current_binder_ns();
+	if (binder_ns == NULL)
+		return -ENOMEM;
+
 	proc = kzalloc(sizeof(*proc), GFP_KERNEL);
 	if (proc == NULL)
 		return -ENOMEM;
@@ -2823,10 +2911,13 @@ static int binder_open(struct inode *nodp, struct file *filp)
 	init_waitqueue_head(&proc->wait);
 	proc->default_priority = task_nice(current);
 
+	proc->binder_ns = binder_ns;
+	get_binder_ns(binder_ns);
+
 	binder_lock(__func__);
 
 	binder_stats_created(BINDER_STAT_PROC);
-	hlist_add_head(&proc->proc_node, &binder_procs);
+	hlist_add_head(&proc->proc_node, &binder_ns->procs);
 	proc->pid = current->group_leader->pid;
 	INIT_LIST_HEAD(&proc->delivered_death);
 	filp->private_data = proc;
@@ -2927,6 +3018,7 @@ out:
 
 static void binder_deferred_release(struct binder_proc *proc)
 {
+	struct binder_namespace *binder_ns = proc->binder_ns;
 	struct binder_transaction *t;
 	struct rb_node *n;
 	int threads, nodes, incoming_refs, outgoing_refs, buffers,
@@ -2937,11 +3029,12 @@ static void binder_deferred_release(struct binder_proc *proc)
 
 	hlist_del(&proc->proc_node);
 
-	if (binder_context_mgr_node && binder_context_mgr_node->proc == proc) {
+	if (binder_ns->context_mgr_node &&
+	    binder_ns->context_mgr_node->proc == proc) {
 		binder_debug(BINDER_DEBUG_DEAD_BINDER,
 			     "%s: %d context_mgr_node gone\n",
 			     __func__, proc->pid);
-		binder_context_mgr_node = NULL;
+		binder_ns->context_mgr_node = NULL;
 	}
 
 	threads = 0;
@@ -3020,6 +3113,7 @@ static void binder_deferred_release(struct binder_proc *proc)
 		vfree(proc->buffer);
 	}
 
+	put_binder_ns(proc->binder_ns);
 	put_task_struct(proc->tsk);
 
 	binder_debug(BINDER_DEBUG_OPEN_CLOSE,
@@ -3398,10 +3492,14 @@ static void print_binder_proc_stats(struct seq_file *m,
 
 static int binder_state_show(struct seq_file *m, void *unused)
 {
+	struct binder_namespace *binder_ns = current_binder_ns();
 	struct binder_proc *proc;
 	struct binder_node *node;
 	int do_lock = !binder_debug_no_lock;
 
+	if (binder_ns == NULL)
+		return 0;
+
 	if (do_lock)
 		binder_lock(__func__);
 
@@ -3412,7 +3510,7 @@ static int binder_state_show(struct seq_file *m, void *unused)
 	hlist_for_each_entry(node, &binder_dead_nodes, dead_node)
 		print_binder_node(m, node);
 
-	hlist_for_each_entry(proc, &binder_procs, proc_node)
+	hlist_for_each_entry(proc, &binder_ns->procs, proc_node)
 		print_binder_proc(m, proc, 1);
 	if (do_lock)
 		binder_unlock(__func__);
@@ -3421,9 +3519,13 @@ static int binder_state_show(struct seq_file *m, void *unused)
 
 static int binder_stats_show(struct seq_file *m, void *unused)
 {
+	struct binder_namespace *binder_ns = current_binder_ns();
 	struct binder_proc *proc;
 	int do_lock = !binder_debug_no_lock;
 
+	if (binder_ns == NULL)
+		return 0;
+
 	if (do_lock)
 		binder_lock(__func__);
 
@@ -3431,7 +3533,7 @@ static int binder_stats_show(struct seq_file *m, void *unused)
 
 	print_binder_stats(m, "", &binder_stats);
 
-	hlist_for_each_entry(proc, &binder_procs, proc_node)
+	hlist_for_each_entry(proc,  &binder_ns->procs, proc_node)
 		print_binder_proc_stats(m, proc);
 	if (do_lock)
 		binder_unlock(__func__);
@@ -3440,14 +3542,18 @@ static int binder_stats_show(struct seq_file *m, void *unused)
 
 static int binder_transactions_show(struct seq_file *m, void *unused)
 {
+	struct binder_namespace *binder_ns = current_binder_ns();
 	struct binder_proc *proc;
 	int do_lock = !binder_debug_no_lock;
 
+	if (binder_ns == NULL)
+		return 0;
+
 	if (do_lock)
 		binder_lock(__func__);
 
 	seq_puts(m, "binder transactions:\n");
-	hlist_for_each_entry(proc, &binder_procs, proc_node)
+	hlist_for_each_entry(proc, &binder_ns->procs, proc_node)
 		print_binder_proc(m, proc, 0);
 	if (do_lock)
 		binder_unlock(__func__);
@@ -3518,9 +3624,15 @@ static int __init binder_init(void)
 {
 	int ret;
 
+	ret = register_peripc_ops(&binder_peripc_ops);
+	if (ret < 0)
+		return ret;
+
 	binder_deferred_workqueue = create_singlethread_workqueue("binder");
-	if (!binder_deferred_workqueue)
+	if (!binder_deferred_workqueue) {
+		unregister_peripc_ops(&binder_peripc_ops);
 		return -ENOMEM;
+	}
 
 	binder_debugfs_dir_entry_root = debugfs_create_dir("binder", NULL);
 	if (binder_debugfs_dir_entry_root)
-- 
1.8.3.2
