From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 3/9] cgroup: make for_each_subsys() useable under
	cgroup_root_mutex
Date: Sat, 31 Aug 2013 09:59:49 -0400
Message-ID: <20130831135949.GB26539__39715.7621723183$1377957603$gmane$org@htj.dyndns.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
	<1377723829-22814-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377723829-22814-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

v2: cgroup_assert_mutex_or_root_locked() caused build failure if
    !CONFIG_LOCKEDP.  Conditionalize its definition.  The build failure
    was reported by kbuild test bot.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -93,6 +93,14 @@ static DEFINE_MUTEX(cgroup_root_mutex);
 			   lockdep_is_held(&cgroup_mutex),		\
 			   "cgroup_mutex or RCU read lock required");
 
+#ifdef CONFIG_LOCKDEP
+#define cgroup_assert_mutex_or_root_locked()				\
+	WARN_ON_ONCE(debug_locks && (!lockdep_is_held(&cgroup_mutex) &&	\
+				     !lockdep_is_held(&cgroup_root_mutex)))
+#else
+#define cgroup_assert_mutex_or_root_locked()	do { } while (0)
+#endif
+
 /*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
  * populated with the built in subsystems, and modular subsystems are
@@ -291,14 +299,15 @@ static int notify_on_release(const struc
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
+	for (({ cgroup_assert_mutex_or_root_locked(); (ssid) = 0; });	\
+	     (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)			\
+		if (!((ss) = cgroup_subsys[(ssid)])) { }		\
 		else
 
 /**
@@ -4911,6 +4920,7 @@ int __init_or_module cgroup_load_subsys(
 	cgroup_init_cftsets(ss);
 
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 	cgroup_subsys[ss->subsys_id] = ss;
 
 	/*
@@ -4966,10 +4976,12 @@ int __init_or_module cgroup_load_subsys(
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
@@ -4999,6 +5011,7 @@ void cgroup_unload_subsys(struct cgroup_
 	BUG_ON(ss->root != &cgroup_dummy_root);
 
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 
 	offline_css(cgroup_css(cgroup_dummy_top, ss));
 
@@ -5037,6 +5050,7 @@ void cgroup_unload_subsys(struct cgroup_
 	ss->css_free(cgroup_css(cgroup_dummy_top, ss));
 	RCU_INIT_POINTER(cgroup_dummy_top->subsys[ss->subsys_id], NULL);
 
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 }
 EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
