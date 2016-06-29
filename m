From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCH 4/4] inotify: Convert to using new userns infrastructure
Date: Wed, 29 Jun 2016 16:37:05 +0300
Message-ID: <1467207425-22072-5-git-send-email-kernel@kyup.com>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1467207425-22072-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 fs/notify/inotify/inotify_fsnotify.c | 16 ++++++++++++-
 fs/notify/inotify/inotify_user.c     | 46 ++++++++++++++++++++++++------------
 include/linux/sched.h                |  4 ----
 3 files changed, 46 insertions(+), 20 deletions(-)

diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 2cd900c2c737..bc2441c64809 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -166,7 +166,21 @@ static void inotify_free_group_priv(struct fsnotify_group *group)
 	idr_for_each(&group->inotify_data.idr, idr_callback, group);
 	idr_destroy(&group->inotify_data.idr);
 	if (group->inotify_data.user) {
-		atomic_dec(&group->inotify_data.user->inotify_devs);
+		struct inotify_state *state;
+
+		mutex_lock(&group->inotify_data.userns->inotify_lock);
+		state = __find_inotify_state(group->inotify_data.userns,
+					     group->inotify_data.uid);
+
+		BUG_ON(!state);
+
+		page_counter_uncharge(&state->instances, 1);
+		if (page_counter_read(&state->instances) == 0) {
+			hash_del(&state->node);
+			kfree(state);
+		}
+		mutex_unlock(&group->inotify_data.userns->inotify_lock);
+
 		free_uid(group->inotify_data.user);
 	}
 }
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 06797ae76527..9c857428a2e8 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -45,9 +45,7 @@
 #include <asm/ioctls.h>
 
 /* these are configurable via /proc/sys/fs/inotify/ */
-static int inotify_max_user_instances __read_mostly;
 static int inotify_max_queued_events __read_mostly;
-static int inotify_max_user_watches __read_mostly;
 int inotify_reserved_user_instances __read_mostly;
 int inotify_reserved_user_watches   __read_mostly;
 
@@ -73,7 +71,7 @@ static int proc_dointvec_minmax_root(struct ctl_table *table, int write,
 struct ctl_table inotify_table[] = {
 	{
 		.procname	= "max_user_instances",
-		.data		= &inotify_max_user_instances,
+		.data		= &init_user_ns.inotify_max_user_instances,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -81,7 +79,7 @@ struct ctl_table inotify_table[] = {
 	},
 	{
 		.procname	= "max_user_watches",
-		.data		= &inotify_max_user_watches,
+		.data		= &init_user_ns.inotify_max_user_watches,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -680,6 +678,7 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
 				    struct fsnotify_group *group)
 {
 	struct inotify_inode_mark *i_mark;
+	struct inotify_state *state;
 
 	/* Queue ignore event for the watch */
 	inotify_handle_event(group, NULL, fsn_mark, NULL, FS_IN_IGNORED,
@@ -689,7 +688,13 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
 	/* remove this mark from the idr */
 	inotify_remove_from_idr(group, i_mark);
 
-	atomic_dec(&group->inotify_data.user->inotify_watches);
+	mutex_lock(&group->inotify_data.userns->inotify_lock);
+	state = __find_inotify_state(group->inotify_data.userns,
+				     group->inotify_data.uid);
+	BUG_ON(!state);
+	page_counter_uncharge(&state->watches, 1);
+
+	mutex_unlock(&group->inotify_data.userns->inotify_lock);
 }
 
 /* ding dong the mark is dead */
@@ -762,6 +767,8 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	int ret;
 	struct idr *idr = &group->inotify_data.idr;
 	spinlock_t *idr_lock = &group->inotify_data.idr_lock;
+	struct inotify_state *state;
+	struct page_counter *cnt;
 
 	mask = inotify_arg_to_mask(arg);
 
@@ -773,10 +780,6 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	tmp_i_mark->fsn_mark.mask = mask;
 	tmp_i_mark->wd = -1;
 
-	ret = -ENOSPC;
-	if (atomic_read(&group->inotify_data.user->inotify_watches) >= inotify_max_user_watches)
-		goto out_err;
-
 	ret = inotify_add_to_idr(idr, idr_lock, tmp_i_mark);
 	if (ret)
 		goto out_err;
@@ -791,7 +794,18 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	}
 
 	/* increment the number of watches the user has */
-	atomic_inc(&group->inotify_data.user->inotify_watches);
+	mutex_lock(&group->inotify_data.userns->inotify_lock);
+	state = __find_inotify_state(group->inotify_data.userns,
+						    group->inotify_data.uid);
+	BUG_ON(!state);
+	ret = -ENOSPC;
+	if (!page_counter_try_charge(&state->watches, 1, &cnt)) {
+		mutex_unlock(&group->inotify_data.userns->inotify_lock);
+		inotify_remove_from_idr(group, tmp_i_mark);
+		goto out_err;
+	}
+
+	mutex_unlock(&group->inotify_data.userns->inotify_lock);
 
 	/* return the watch descriptor for this new mark */
 	ret = tmp_i_mark->wd;
@@ -822,6 +836,7 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 {
 	struct fsnotify_group *group;
 	struct inotify_event_info *oevent;
+	int ret;
 
 	group = fsnotify_alloc_group(&inotify_fsnotify_ops);
 	if (IS_ERR(group))
@@ -843,11 +858,14 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 	spin_lock_init(&group->inotify_data.idr_lock);
 	idr_init(&group->inotify_data.idr);
 	group->inotify_data.user = get_current_user();
+	group->inotify_data.userns = current_user_ns();
+	group->inotify_data.uid = from_kuid(current_user_ns(), current_uid());
+
+	ret = inotify_init_state(current_user_ns(), group->inotify_data.uid);
 
-	if (atomic_inc_return(&group->inotify_data.user->inotify_devs) >
-	    inotify_max_user_instances) {
+	if (ret < 0) {
 		fsnotify_destroy_group(group);
-		return ERR_PTR(-EMFILE);
+		return ERR_PTR(ret);
 	}
 
 	return group;
@@ -1008,8 +1026,6 @@ static int __init inotify_user_setup(void)
 	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
 
 	inotify_max_queued_events = 16384;
-	inotify_max_user_instances = 128;
-	inotify_max_user_watches = 8192;
 	init_user_ns.inotify_max_user_instances = 256;
 	init_user_ns.inotify_max_user_watches = 8192;
 	/* These reserves should allow for 8 levels of nesting in userns */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6e42ada26345..04ba3443aa36 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -838,10 +838,6 @@ struct user_struct {
 	atomic_t __count;	/* reference count */
 	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
-#ifdef CONFIG_INOTIFY_USER
-	atomic_t inotify_watches; /* How many inotify watches does this user have? */
-	atomic_t inotify_devs;	/* How many inotify devs does this user have opened? */
-#endif
 #ifdef CONFIG_FANOTIFY
 	atomic_t fanotify_listeners;
 #endif
-- 
2.5.0
