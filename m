From: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Subject: [PATCH 17/20] Create a slab-cache for 'struct pid_namespace'
Date: Tue, 07 Aug 2007 13:30:08 +0400
Message-ID: <46B83BA0.mailG6511S1OE@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This will help fixing memory leaks due to bad reference counting.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---

 pid.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

--- ./kernel/pid.c.ve16	2007-08-07 12:50:16.000000000 +0400
+++ ./kernel/pid.c	2007-08-07 12:51:13.000000000 +0400
@@ -34,6 +34,7 @@
 static struct hlist_head *pid_hash;
 static int pidhash_shift;
 struct pid init_struct_pid = INIT_STRUCT_PID;
+static struct kmem_cache *pid_ns_cachep;
 
 int pid_max = PID_MAX_DEFAULT;
 
@@ -480,7 +481,7 @@ static struct pid_namespace *create_pid_
 	struct pid_namespace *ns;
 	int i;
 
-	ns = kmalloc(sizeof(struct pid_namespace), GFP_KERNEL);
+	ns = kmem_cache_alloc(pid_ns_cachep, GFP_KERNEL);
 	if (ns == NULL)
 		goto out;
 
@@ -510,7 +511,7 @@ static struct pid_namespace *create_pid_
 out_free_map:
 	kfree(ns->pidmap[0].page);
 out_free:
-	kfree(ns);
+	kmem_cache_free(pid_ns_cachep, ns);
 out:
 	return ERR_PTR(-ENOMEM);
 }
@@ -521,7 +522,7 @@ static void destroy_pid_namespace(struct
 
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
-	kfree(ns);
+	kmem_cache_free(pid_ns_cachep, ns);
 }
 
 struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
@@ -595,4 +596,6 @@ void __init pidmap_init(void)
 	init_pid_ns.pid_cachep = create_pid_cachep(1);
 	if (init_pid_ns.pid_cachep == NULL)
 		panic("Can't create pid_1 cachep\n");
+
+	pid_ns_cachep = KMEM_CACHE(pid_namespace, SLAB_PANIC);
 }
