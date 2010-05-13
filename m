From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/9] cgroup: use kvmalloc, kvrealloc and kvfree
Date: Thu, 13 May 2010 17:58:16 +0800
Message-ID: <1273744696-10119-1-git-send-email-xiaosuo__22562.9731001847$1273744797$gmane$org@gmail.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

use kvmalloc, kvrealloc and kvfree

use kvmalloc, kvrealloc and kvfree

Signed-off-by: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
----
 kernel/cgroup.c |   47 +++++------------------------------------------
 1 file changed, 5 insertions(+), 42 deletions(-)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6d870f2..4a1dab7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -55,7 +55,6 @@
 #include <linux/smp_lock.h>
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
-#include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 #include <linux/eventfd.h>
 #include <linux/poll.h>
 
@@ -2553,42 +2552,6 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
  */
 
 /*
- * The following two functions "fix" the issue where there are more pids
- * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
- * TODO: replace with a kernel-wide solution to this problem
- */
-#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))
-static void *pidlist_allocate(int count)
-{
-	if (PIDLIST_TOO_LARGE(count))
-		return vmalloc(count * sizeof(pid_t));
-	else
-		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
-}
-static void pidlist_free(void *p)
-{
-	if (is_vmalloc_addr(p))
-		vfree(p);
-	else
-		kfree(p);
-}
-static void *pidlist_resize(void *p, int newcount)
-{
-	void *newlist;
-	/* note: if new alloc fails, old p will still be valid either way */
-	if (is_vmalloc_addr(p)) {
-		newlist = vmalloc(newcount * sizeof(pid_t));
-		if (!newlist)
-			return NULL;
-		memcpy(newlist, p, newcount * sizeof(pid_t));
-		vfree(p);
-	} else {
-		newlist = krealloc(p, newcount * sizeof(pid_t), GFP_KERNEL);
-	}
-	return newlist;
-}
-
-/*
  * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
  * If the new stripped list is sufficiently smaller and there's enough memory
  * to allocate a new buffer, will let go of the unneeded memory. Returns the
@@ -2627,7 +2590,7 @@ after:
 	 * we'll just stay with what we've got.
 	 */
 	if (PIDLIST_REALLOC_DIFFERENCE(length, dest)) {
-		newlist = pidlist_resize(list, dest);
+		newlist = kvrealloc(list, dest * sizeof(pid_t));
 		if (newlist)
 			*p = newlist;
 	}
@@ -2705,7 +2668,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	 * show up until sometime later on.
 	 */
 	length = cgroup_task_count(cgrp);
-	array = pidlist_allocate(length);
+	array = kvmalloc(length * sizeof(pid_t));
 	if (!array)
 		return -ENOMEM;
 	/* now, populate the array */
@@ -2729,11 +2692,11 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 		length = pidlist_uniq(&array, length);
 	l = cgroup_pidlist_find(cgrp, type);
 	if (!l) {
-		pidlist_free(array);
+		kvfree(array);
 		return -ENOMEM;
 	}
 	/* store array, freeing old if necessary - lock already held */
-	pidlist_free(l->list);
+	kvfree(l->list);
 	l->list = array;
 	l->length = length;
 	l->use_count++;
@@ -2894,7 +2857,7 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 		/* we're the last user if refcount is 0; remove and free */
 		list_del(&l->links);
 		mutex_unlock(&l->owner->pidlist_mutex);
-		pidlist_free(l->list);
+		kvfree(l->list);
 		put_pid_ns(l->key.ns);
 		up_write(&l->mutex);
 		kfree(l);
