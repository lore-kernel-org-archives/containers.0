From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/7] Quick vmalloc vs kmalloc fix to the case where array size
	is too large
Date: Mon, 10 Aug 2009 17:57:46 -0700
Message-ID: <20090811005746.21950.12567.stgit__1612.83129496059$1249952320$gmane$org@hastromil.mtv.corp.google.com>
References: <20090811004737.21950.29188.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090811004737.21950.29188.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quick vmalloc vs kmalloc fix to the case where array size is too large

Separates all pidlist allocation requests to a separate function that judges
based on the requested size whether or not the array needs to be vmalloced or
can be gotten via kmalloc, and similar for kfree/vfree. Should be replaced
entirely with a kernel-wide solution to this general problem.

Depends on cgroup-pidlist-namespace.patch, cgroup-procs.patch

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 kernel/cgroup.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cdd0112..f6d5969 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -48,6 +48,7 @@
 #include <linux/namei.h>
 #include <linux/smp_lock.h>
 #include <linux/pid_namespace.h>
+#include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 
 #include <asm/atomic.h>
 
@@ -2123,6 +2124,42 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
  */
 
 /*
+ * The following two functions "fix" the issue where there are more pids
+ * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
+ * TODO: replace with a kernel-wide solution to this problem
+ */
+#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))
+static void *pidlist_allocate(int count)
+{
+	if (PIDLIST_TOO_LARGE(count))
+		return vmalloc(count * sizeof(pid_t));
+	else
+		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
+}
+static void pidlist_free(void *p)
+{
+	if (is_vmalloc_addr(p))
+		vfree(p);
+	else
+		kfree(p);
+}
+static void *pidlist_resize(void *p, int newcount)
+{
+	void *newlist;
+	/* note: if new alloc fails, old p will still be valid either way */
+	if (is_vmalloc_addr(p)) {
+		newlist = vmalloc(newcount * sizeof(pid_t));
+		if (!newlist)
+			return NULL;
+		memcpy(newlist, p, newcount * sizeof(pid_t));
+		vfree(p);
+	} else {
+		newlist = krealloc(p, newcount * sizeof(pid_t), GFP_KERNEL);
+	}
+	return newlist;
+}
+
+/*
  * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
  * If the new stripped list is sufficiently smaller and there's enough memory
  * to allocate a new buffer, will let go of the unneeded memory. Returns the
@@ -2161,7 +2198,7 @@ after:
 	 * we'll just stay with what we've got.
 	 */
 	if (PIDLIST_REALLOC_DIFFERENCE(length, dest)) {
-		newlist = krealloc(list, dest * sizeof(pid_t), GFP_KERNEL);
+		newlist = pidlist_resize(list, dest);
 		if (newlist)
 			*p = newlist;
 	}
@@ -2242,7 +2279,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	 * show up until sometime later on.
 	 */
 	length = cgroup_task_count(cgrp);
-	array = kmalloc(length * sizeof(pid_t), GFP_KERNEL);
+	array = pidlist_allocate(length);
 	if (!array)
 		return -ENOMEM;
 	/* now, populate the array */
@@ -2266,11 +2303,11 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 		length = pidlist_uniq(&array, length);
 	l = cgroup_pidlist_find(cgrp, type);
 	if (!l) {
-		kfree(array);
+		pidlist_free(array);
 		return -ENOMEM;
 	}
 	/* store array, freeing old if necessary - lock already held */
-	kfree(l->list);
+	pidlist_free(l->list);
 	l->list = array;
 	l->length = length;
 	l->use_count++;
@@ -2431,7 +2468,7 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 		/* we're the last user if refcount is 0; remove and free */
 		list_del(&l->links);
 		mutex_unlock(&l->owner->pidlist_mutex);
-		kfree(l->list);
+		pidlist_free(l->list);
 		put_pid_ns(l->key.ns);
 		up_write(&l->mutex);
 		kfree(l);
