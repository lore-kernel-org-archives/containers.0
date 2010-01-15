From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH] Fixes for
	cgroup-implement-eventfd-based-generic-api-for-notifications.patch
Date: Fri, 15 Jan 2010 07:33:34 +0200
Message-ID: <1263533614-23612-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Several random fixes.

Andrew, please fold it in cgroup-implement-eventfd-based-generic-api-for-notifications.patch

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |    1 +
 kernel/cgroup.c                   |   26 +++++++++++++++++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 5a052ff..47d5100 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -23,6 +23,7 @@ CONTENTS:
   2.1 Basic Usage
   2.2 Attaching processes
   2.3 Mounting hierarchies by name
+  2.4 Notification API
 3. Kernel API
   3.1 Overview
   3.2 Synchronization
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 44028a9..23315e5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2875,13 +2875,18 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 	return 0;
 }
 
+/*
+ * Unregister event and free resources.
+ *
+ * Gets called from workqueue.
+ */
 static void cgroup_event_remove(struct work_struct *work)
 {
 	struct cgroup_event *event = container_of(work, struct cgroup_event,
 			remove);
 	struct cgroup *cgrp = event->cgrp;
 
-	/* TODO: check return code*/
+	/* TODO: check return code */
 	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
 
 	eventfd_ctx_put(event->eventfd);
@@ -2889,6 +2894,11 @@ static void cgroup_event_remove(struct work_struct *work)
 	kfree(event);
 }
 
+/*
+ * Gets called on POLLHUP on eventfd when user closes it.
+ *
+ * Called with wqh->lock held and interrupts disabled.
+ */
 static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 		int sync, void *key)
 {
@@ -2901,6 +2911,10 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 		spin_lock(&cgrp->event_list_lock);
 		list_del(&event->list);
 		spin_unlock(&cgrp->event_list_lock);
+		/*
+		 * We are in atomic context, but cgroup_event_remove() may
+		 * sleep, so we have to call it in workqueue.
+		 */
 		schedule_work(&event->remove);
 	}
 
@@ -2917,6 +2931,12 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
 	add_wait_queue(wqh, &event->wait);
 }
 
+/*
+ * Parse input and register new cgroup event handler.
+ *
+ * Input must be in format '<event_fd> <control_fd> <args>'.
+ * Interpretation of args is defined by control file implementation.
+ */
 static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 				      const char *buffer)
 {
@@ -3001,13 +3021,13 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 
 fail:
-	if (!IS_ERR(cfile))
+	if (!cfile)
 		fput(cfile);
 
 	if (event && event->eventfd && !IS_ERR(event->eventfd))
 		eventfd_ctx_put(event->eventfd);
 
-	if (!IS_ERR(efile))
+	if (!IS_ERR_OR_NULL(efile))
 		fput(efile);
 
 	kfree(event);
-- 
1.6.5.7
