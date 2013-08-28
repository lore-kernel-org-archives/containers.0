From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/9] cgroup: make for_each_subsys() useable under
	cgroup_root_mutex
Date: Wed, 28 Aug 2013 17:03:43 -0400
Message-ID: <1377723829-22814-4-git-send-email-tj@kernel.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377723829-22814-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

We want to use for_each_subsys() in cgroupfs_root handling where only
cgroup_root_mutex is held.  The only way cgroup_subsys[] can change is
through module load/unload, make cgroup_[un]load_subsys() grab
cgroup_root_mutex too and update the lockdep annotation in
for_each_subsys() to allow either cgroup_mutex or cgroup_root_mutex.

* Lockdep annotation is moved from inner 'if' condition to outer 'for'
  init caluse.  There's no reason to execute the assertion every loop.

* Loop index @i is renamed to @ssid.  Indices iterating through subsys
  will be [re]named to @ssid gradually.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a10baf8..a65be0c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -291,14 +291,17 @@ static int notify_on_release(const struct cgroup *cgrp)
 /**
  * for_each_subsys - iterate all loaded cgroup subsystems
  * @ss: the iteration cursor
- * @i: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
+ * @ssid: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
  *
- * Should be called under cgroup_mutex.
+ * Iterates through all loaded subsystems.  Should be called under
+ * cgroup_mutex or cgroup_root_mutex.
  */
-#define for_each_subsys(ss, i)						\
-	for ((i) = 0; (i) < CGROUP_SUBSYS_COUNT; (i)++)			\
-		if (({ lockdep_assert_held(&cgroup_mutex);		\
-		       !((ss) = cgroup_subsys[i]); })) { }		\
+#define for_each_subsys(ss, ssid)					\
+	for (({ WARN_ON_ONCE(debug_locks &&				\
+			     (!lockdep_is_held(&cgroup_mutex) &&	\
+			      !lockdep_is_held(&cgroup_root_mutex)));	\
+	     (ssid) = 0; }); (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)	\
+		if (!((ss) = cgroup_subsys[(ssid)])) { }		\
 		else
 
 /**
@@ -4911,6 +4914,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	cgroup_init_cftsets(ss);
 
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 	cgroup_subsys[ss->subsys_id] = ss;
 
 	/*
@@ -4966,10 +4970,12 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		goto err_unload;
 
 	/* success! */
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	return 0;
 
 err_unload:
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	/* @ss can't be mounted here as try_module_get() would fail */
 	cgroup_unload_subsys(ss);
@@ -4999,6 +5005,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	BUG_ON(ss->root != &cgroup_dummy_root);
 
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 
 	offline_css(cgroup_css(cgroup_dummy_top, ss));
 
@@ -5037,6 +5044,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	ss->css_free(cgroup_css(cgroup_dummy_top, ss));
 	RCU_INIT_POINTER(cgroup_dummy_top->subsys[ss->subsys_id], NULL);
 
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 }
 EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
-- 
1.8.3.1
