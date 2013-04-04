From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/5] cgroup: remove cgroup_lock_is_held()
Date: Thu,  4 Apr 2013 16:36:29 -0700
Message-ID: <1365118589-10619-6-git-send-email-tj@kernel.org>
References: <1365118589-10619-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365118589-10619-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

We don't want controllers to assume that the information is officially
available and do funky things with it.

The only user is task_subsys_state_check() which uses it to verify RCU
access context.  We can move cgroup_lock_is_held() inside
CONFIG_PROVE_RCU but that doesn't add meaningful protection compared
to conditionally exposing cgroup_mutex.

Remove cgroup_lock_is_held(), export cgroup_mutex iff CONFIG_PROVE_RCU
and use lockdep_is_held() directly on the mutex in
task_subsys_state_check().

While at it, add parentheses around macro arguments in
task_subsys_state_check().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 13 +++++++++----
 kernel/cgroup.c        | 20 ++++++--------------
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 63deb70..515927e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -30,7 +30,6 @@ struct css_id;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
-extern int cgroup_lock_is_held(void);
 extern void cgroup_fork(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
@@ -552,10 +551,16 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
  * rcu_dereference_check() conditions, such as locks used during the
  * cgroup_subsys::attach() methods.
  */
+#ifdef CONFIG_PROVE_RCU
+extern struct mutex cgroup_mutex;
 #define task_subsys_state_check(task, subsys_id, __c)			\
-	rcu_dereference_check(task->cgroups->subsys[subsys_id],		\
-			      lockdep_is_held(&task->alloc_lock) ||	\
-			      cgroup_lock_is_held() || (__c))
+	rcu_dereference_check((task)->cgroups->subsys[(subsys_id)],	\
+			      lockdep_is_held(&(task)->alloc_lock) ||	\
+			      lockdep_is_held(&cgroup_mutex) || (__c))
+#else
+#define task_subsys_state_check(task, subsys_id, __c)			\
+	rcu_dereference((task)->cgroups->subsys[(subsys_id)])
+#endif
 
 static inline struct cgroup_subsys_state *
 task_subsys_state(struct task_struct *task, int subsys_id)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1a65958..ba3e24a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -83,7 +83,13 @@
  * B happens only through cgroup_show_options() and using cgroup_root_mutex
  * breaks it.
  */
+#ifdef CONFIG_PROVE_RCU
+DEFINE_MUTEX(cgroup_mutex);
+EXPORT_SYMBOL_GPL(cgroup_mutex);	/* only for task_subsys_state_check() */
+#else
 static DEFINE_MUTEX(cgroup_mutex);
+#endif
+
 static DEFINE_MUTEX(cgroup_root_mutex);
 
 /*
@@ -251,20 +257,6 @@ static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			      struct cftype cfts[], bool is_add);
 
-#ifdef CONFIG_PROVE_LOCKING
-int cgroup_lock_is_held(void)
-{
-	return lockdep_is_held(&cgroup_mutex);
-}
-#else /* #ifdef CONFIG_PROVE_LOCKING */
-int cgroup_lock_is_held(void)
-{
-	return mutex_is_locked(&cgroup_mutex);
-}
-#endif /* #else #ifdef CONFIG_PROVE_LOCKING */
-
-EXPORT_SYMBOL_GPL(cgroup_lock_is_held);
-
 static int css_unbias_refcnt(int refcnt)
 {
 	return refcnt >= 0 ? refcnt : refcnt - CSS_DEACT_BIAS;
-- 
1.8.1.4
