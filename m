From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCH 4/4] inotify: Convert to using new userns infrastructure
Date: Wed, 13 Jul 2016 15:14:13 +0300
Message-ID: <1468412053-30130-5-git-send-email-kernel@kyup.com>
References: <1468412053-30130-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1468412053-30130-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org
List-Id: containers.vger.kernel.org

Modify the current inotify code to use the newly added perns/per user
counters. Also change the max_inotify_user_instances/watches to
apply only to the top level.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 fs/notify/inotify/inotify_fsnotify.c | 14 +++++++++---
 fs/notify/inotify/inotify_user.c     | 43 ++++++++++++++++++++++++------------
 include/linux/fsnotify_backend.h     |  1 -
 include/linux/sched.h                |  4 ----
 4 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 2cd900c2c737..e490887b064e 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h> /* kmem_* */
 #include <linux/types.h>
 #include <linux/sched.h>
+#include <linux/user_namespace.h>
 
 #include "inotify.h"
 
@@ -165,9 +166,16 @@ static void inotify_free_group_priv(struct fsnotify_group *group)
 	/* ideally the idr is empty and we won't hit the BUG in the callback */
 	idr_for_each(&group->inotify_data.idr, idr_callback, group);
 	idr_destroy(&group->inotify_data.idr);
-	if (group->inotify_data.user) {
-		atomic_dec(&group->inotify_data.user->inotify_devs);
-		free_uid(group->inotify_data.user);
+	if (group->inotify_data.userns) {
+		struct nsuser_state *state;
+
+		spin_lock_bh(&nsuser_state_lock);
+		state = get_nsuser_state(group->inotify_data.userns,
+					     group->inotify_data.uid);
+		spin_unlock_bh(&nsuser_state_lock);
+		BUG_ON(!state);
+
+		page_counter_uncharge(&state->inotify_instances, 1);
 	}
 }
 
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index 076a9990eff4..40956900a8a2 100644
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
 
@@ -62,7 +60,7 @@ static int zero;
 struct ctl_table inotify_table[] = {
 	{
 		.procname	= "max_user_instances",
-		.data		= &inotify_max_user_instances,
+		.data		= &init_user_ns.inotify_max_user_instances,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -70,7 +68,7 @@ struct ctl_table inotify_table[] = {
 	},
 	{
 		.procname	= "max_user_watches",
-		.data		= &inotify_max_user_watches,
+		.data		= &init_user_ns.inotify_max_user_watches,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
@@ -579,6 +577,7 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
 				    struct fsnotify_group *group)
 {
 	struct inotify_inode_mark *i_mark;
+	struct nsuser_state *state;
 
 	/* Queue ignore event for the watch */
 	inotify_handle_event(group, NULL, fsn_mark, NULL, FS_IN_IGNORED,
@@ -588,7 +587,13 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
 	/* remove this mark from the idr */
 	inotify_remove_from_idr(group, i_mark);
 
-	atomic_dec(&group->inotify_data.user->inotify_watches);
+	spin_lock_bh(&nsuser_state_lock);
+	state = get_nsuser_state(group->inotify_data.userns,
+				     group->inotify_data.uid);
+	BUG_ON(!state);
+	spin_unlock_bh(&nsuser_state_lock);
+
+	page_counter_uncharge(&state->inotify_watches, 1);
 }
 
 /* ding dong the mark is dead */
@@ -661,6 +666,8 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	int ret;
 	struct idr *idr = &group->inotify_data.idr;
 	spinlock_t *idr_lock = &group->inotify_data.idr_lock;
+	struct nsuser_state *state;
+	struct page_counter *cnt;
 
 	mask = inotify_arg_to_mask(arg);
 
@@ -672,10 +679,6 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	tmp_i_mark->fsn_mark.mask = mask;
 	tmp_i_mark->wd = -1;
 
-	ret = -ENOSPC;
-	if (atomic_read(&group->inotify_data.user->inotify_watches) >= inotify_max_user_watches)
-		goto out_err;
-
 	ret = inotify_add_to_idr(idr, idr_lock, tmp_i_mark);
 	if (ret)
 		goto out_err;
@@ -690,7 +693,16 @@ static int inotify_new_watch(struct fsnotify_group *group,
 	}
 
 	/* increment the number of watches the user has */
-	atomic_inc(&group->inotify_data.user->inotify_watches);
+	spin_lock_bh(&nsuser_state_lock);
+	state = get_nsuser_state(group->inotify_data.userns,
+				 group->inotify_data.uid);
+	spin_unlock_bh(&nsuser_state_lock);
+	BUG_ON(!state);
+	ret = -ENOSPC;
+	if (!page_counter_try_charge(&state->inotify_watches, 1, &cnt)) {
+		inotify_remove_from_idr(group, tmp_i_mark);
+		goto out_err;
+	}
 
 	/* return the watch descriptor for this new mark */
 	ret = tmp_i_mark->wd;
@@ -721,6 +733,7 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 {
 	struct fsnotify_group *group;
 	struct inotify_event_info *oevent;
+	int ret;
 
 	group = fsnotify_alloc_group(&inotify_fsnotify_ops);
 	if (IS_ERR(group))
@@ -741,12 +754,14 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
 
 	spin_lock_init(&group->inotify_data.idr_lock);
 	idr_init(&group->inotify_data.idr);
-	group->inotify_data.user = get_current_user();
+	group->inotify_data.userns = get_user_ns(current_user_ns());
+	group->inotify_data.uid = current_uid();
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
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index eb83a10afac7..19ca923521c7 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -169,7 +169,6 @@ struct fsnotify_group {
 		struct inotify_group_private_data {
 			spinlock_t	idr_lock;
 			struct idr      idr;
-			struct user_struct      *user;
 			struct user_namespace *userns;
 			kuid_t uid; /* id in the userns this group is
 				      associated with */
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
