From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH RFC v0 1/3] cgroup: implement eventfd-based generic API for
	notifications
Date: Thu, 26 Nov 2009 19:11:15 +0200
Message-ID: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259255307.git.kirill__20852.7962946848$1259255648$gmane$org@shutemov.name>
References: <cover.1259255307.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1259255307.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <cover.1259255307.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <cover.1259255307.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch introduces write-only file "cgroup.event_control" in every
cgroup.

To register new notification handler you need:
- create an eventfd;
- open a control file to be monitored. Callbacks register_event() and
  unregister_event() must be defined for the control file;
- write "<event_fd> <control_fd> <args>" to cgroup.event_control.
  Interpretation of args is defined by control file implementation;

eventfd will be woken up by control file implementation or when the
cgroup is removed.

To unregister notification handler just close eventfd.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 include/linux/cgroup.h |    8 ++
 kernel/cgroup.c        |  181 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 188 insertions(+), 1 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0008dee..285eaff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -220,6 +220,9 @@ struct cgroup {
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
+
+	struct list_head event_list;
+	struct mutex event_list_mutex;
 };
 
 /*
@@ -362,6 +365,11 @@ struct cftype {
 	int (*trigger)(struct cgroup *cgrp, unsigned int event);
 
 	int (*release)(struct inode *inode, struct file *file);
+
+	int (*register_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd, const char *args);
+	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd);
 };
 
 struct cgroup_scanner {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0249f4b..5438d46 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4,6 +4,10 @@
  *  Based originally on the cpuset system, extracted by Paul Menage
  *  Copyright (C) 2006 Google, Inc
  *
+ *  Notifiactions support
+ *  Copyright (C) 2009 Nokia Corporation
+ *  Author: Kirill A. Shutemov
+ *
  *  Copyright notices from the original cpuset code:
  *  --------------------------------------------------
  *  Copyright (C) 2003 BULL SA.
@@ -51,6 +55,8 @@
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
+#include <linux/eventfd.h>
+#include <linux/poll.h>
 
 #include <asm/atomic.h>
 
@@ -146,6 +152,16 @@ struct css_id {
 	unsigned short stack[0]; /* Array of Length (depth+1) */
 };
 
+struct cgroup_event {
+	struct cgroup *cgrp;
+	struct cftype *cft;
+	struct eventfd_ctx *eventfd;
+	struct list_head list;
+	poll_table pt;
+	wait_queue_head_t *wqh;
+	wait_queue_t wait;
+};
+static int cgroup_event_remove(struct cgroup_event *event);
 
 /* The list of hierarchy roots */
 
@@ -734,14 +750,26 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
+	struct cgroup_event *event, *tmp;
 	int ret = 0;
 
 	for_each_subsys(cgrp->root, ss)
 		if (ss->pre_destroy) {
 			ret = ss->pre_destroy(ss, cgrp);
 			if (ret)
-				break;
+				goto out;
 		}
+
+	mutex_lock(&cgrp->event_list_mutex);
+	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+		ret = cgroup_event_remove(event);
+		if (ret)
+			break;
+		eventfd_signal(event->eventfd, 1);
+	}
+	mutex_unlock(&cgrp->event_list_mutex);
+
+out:
 	return ret;
 }
 
@@ -1136,6 +1164,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
+	INIT_LIST_HEAD(&cgrp->event_list);
+	mutex_init(&cgrp->event_list_mutex);
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -1935,6 +1965,13 @@ static const struct inode_operations cgroup_dir_inode_operations = {
 	.rename = cgroup_rename,
 };
 
+static inline struct cftype *__file_cft(struct file *file)
+{
+	if (file->f_dentry->d_inode->i_fop != &cgroup_file_operations)
+		return ERR_PTR(-EINVAL);
+	return __d_cft(file->f_dentry);
+}
+
 static int cgroup_create_file(struct dentry *dentry, mode_t mode,
 				struct super_block *sb)
 {
@@ -2789,6 +2826,143 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 	return 0;
 }
 
+static int cgroup_event_remove(struct cgroup_event *event)
+{
+	struct cgroup *cgrp = event->cgrp;
+	int ret;
+
+	BUG_ON(!mutex_is_locked(&cgrp->event_list_mutex));
+	ret = event->cft->unregister_event(cgrp, event->cft, event->eventfd);
+	eventfd_ctx_put(event->eventfd);
+	remove_wait_queue(event->wqh, &event->wait);
+	list_del(&event->list);
+	kfree(event);
+
+	return ret;
+}
+
+static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct cgroup_event *event = container_of(wait,
+			struct cgroup_event, wait);
+	struct cgroup *cgrp = event->cgrp;
+	unsigned long flags = (unsigned long)key;
+	int ret;
+
+	if (!(flags & POLLHUP))
+		return 0;
+
+	mutex_lock(&cgrp->event_list_mutex);
+	ret = cgroup_event_remove(event);
+	mutex_unlock(&cgrp->event_list_mutex);
+
+	return ret;
+}
+
+static void cgroup_event_ptable_queue_proc(struct file *file,
+		wait_queue_head_t *wqh, poll_table *pt)
+{
+	struct cgroup_event *event = container_of(pt,
+			struct cgroup_event, pt);
+
+	event->wqh = wqh;
+	add_wait_queue(wqh, &event->wait);
+}
+
+static int cgroup_write_event_control(struct cgroup *cont, struct cftype *cft,
+				      const char *buffer)
+{
+	struct cgroup_event *event = NULL;
+	unsigned int efd, cfd;
+	struct file *efile = NULL;
+	struct file *cfile = NULL;
+	char *endp;
+	int ret;
+
+	efd = simple_strtoul(buffer, &endp, 10);
+	if (*endp != ' ')
+		return -EINVAL;
+	buffer = endp + 1;
+
+	cfd = simple_strtoul(buffer, &endp, 10);
+	if ((*endp != ' ') && (*endp != '\0'))
+		return -EINVAL;
+	buffer = endp + 1;
+
+	event = kzalloc(sizeof(*event), GFP_KERNEL);
+	if (!event)
+		return -ENOMEM;
+	event->cgrp = cont;
+	INIT_LIST_HEAD(&event->list);
+	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
+	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
+
+	efile = eventfd_fget(efd);
+	if (IS_ERR(efile)) {
+		ret = PTR_ERR(efile);
+		goto fail;
+	}
+
+	event->eventfd = eventfd_ctx_fileget(efile);
+	if (IS_ERR(event->eventfd)) {
+		ret = PTR_ERR(event->eventfd);
+		goto fail;
+	}
+
+	cfile = fget(cfd);
+	if (!cfile) {
+		ret = -EBADF;
+		goto fail;
+	}
+
+	ret = file_permission(cfile, MAY_READ);
+	if (ret < 0)
+		goto fail;
+
+	event->cft = __file_cft(cfile);
+	if (IS_ERR(event->cft)) {
+		ret = PTR_ERR(event->cft);
+		goto fail;
+	}
+
+	if (!event->cft->register_event || !event->cft->unregister_event) {
+		ret = -EINVAL;
+		goto fail;
+	}
+
+	ret = event->cft->register_event(cont, event->cft,
+			event->eventfd, buffer);
+	if (ret)
+		goto fail;
+
+	efile->f_op->poll(efile, &event->pt);
+
+	mutex_lock(&cont->event_list_mutex);
+	list_add(&event->list, &cont->event_list);
+	mutex_unlock(&cont->event_list_mutex);
+
+	fput(cfile);
+	fput(efile);
+
+	return 0;
+
+fail:
+	if (!IS_ERR(cfile))
+		fput(cfile);
+
+	if (event && event->eventfd && !IS_ERR(event->eventfd))
+		eventfd_ctx_put(event->eventfd);
+
+	if (!IS_ERR(efile))
+		fput(efile);
+
+	if (event)
+		kfree(event);
+
+	return ret;
+}
+
 /*
  * for the common functions, 'private' gives the type of file
  */
@@ -2814,6 +2988,11 @@ static struct cftype files[] = {
 		.read_u64 = cgroup_read_notify_on_release,
 		.write_u64 = cgroup_write_notify_on_release,
 	},
+	{
+		.name = CGROUP_FILE_GENERIC_PREFIX "event_control",
+		.write_string = cgroup_write_event_control,
+		.mode = S_IWUGO,
+	},
 };
 
 static struct cftype cft_release_agent = {
-- 
1.6.5.3
