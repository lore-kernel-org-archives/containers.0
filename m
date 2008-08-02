From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] user namespaces: introduce user_struct->user_namespace
	relationship
Date: Fri, 1 Aug 2008 19:54:05 -0500
Message-ID: <20080802005405.GA1269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Here's just a repost given some of the feedback from the last round.

Question: do we really want a patch renaming kernel/user_namespace.c,
include/linux/user_namespace.c, and struct user_namespace all to
user_ns?  I'm fine with it if we are, but it'll be a pretty big 
patch with no other effect.

-serge

From aa31de8d2e62d1903f8dfaa97e71cca7560632ce Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 22 Jul 2008 13:31:37 -0500
Subject: [PATCH 1/3] user namespaces: introduce user_struct->user_namespace relationship

When a task does clone(CLONE_NEWNS), the task's user is the 'creator' of the
new user_namespace, and the user_namespace is tacked onto a list of those
created by this user.

Changelog:
	Aug 1: renamed user->user_namespace to user_ns, as the next
		patch did anyway.
	Aug 1: move put_user_ns call in one free_user() definition
		to move it outside the lock in free_user.  put_user_ns
		calls free_user on the user_ns->creator, which in
		turn would grab the lock again.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/sched.h          |    1 +
 include/linux/user_namespace.h |    1 +
 kernel/user.c                  |    7 +++++++
 kernel/user_namespace.c        |   20 +++++++++++---------
 4 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5270d44..0149e77 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -600,6 +600,7 @@ struct user_struct {
 	/* Hash table maintenance information */
 	struct hlist_node uidhash_node;
 	uid_t uid;
+	struct user_namespace *user_ns;
 
 #ifdef CONFIG_USER_SCHED
 	struct task_group *tg;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b5f41d4..f9477c3 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -13,6 +13,7 @@ struct user_namespace {
 	struct kref		kref;
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*root_user;
+	struct user_struct	*creator;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/user.c b/kernel/user.c
index 865ecf5..aedb3a1 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -22,6 +22,7 @@ struct user_namespace init_user_ns = {
 		.refcount	= ATOMIC_INIT(2),
 	},
 	.root_user = &root_user,
+	.creator = &root_user,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
@@ -53,6 +54,7 @@ struct user_struct root_user = {
 	.files		= ATOMIC_INIT(0),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
+	.user_ns	= &init_user_ns,
 #ifdef CONFIG_USER_SCHED
 	.tg		= &init_task_group,
 #endif
@@ -325,6 +327,7 @@ static inline void free_user(struct user_struct *up, unsigned long flags)
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
+	put_user_ns(up->user_ns);
 	INIT_WORK(&up->work, remove_user_sysfs_dir);
 	schedule_work(&up->work);
 }
@@ -347,6 +350,7 @@ static inline void free_user(struct user_struct *up, unsigned long flags)
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
+	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
@@ -409,6 +413,8 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
 
+		new->user_ns = get_user_ns(ns);
+
 		if (uids_user_create(new))
 			goto out_destoy_sched;
 
@@ -441,6 +447,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 
 out_destoy_sched:
 	sched_destroy_user(new);
+	put_user_ns(new->user_ns);
 out_free_user:
 	kmem_cache_free(uid_cachep, new);
 out_unlock:
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index a9ab059..e8db443 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -19,7 +19,6 @@
 static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 {
 	struct user_namespace *ns;
-	struct user_struct *new_user;
 	int n;
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
@@ -38,15 +37,17 @@ static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	/* Reset current->user with a new one */
-	new_user = alloc_uid(ns, current->uid);
-	if (!new_user) {
-		free_uid(ns->root_user);
-		kfree(ns);
-		return ERR_PTR(-ENOMEM);
-	}
+	/* pin the creating user */
+	ns->creator = current->user;
+	atomic_inc(&ns->creator->__count);
+
+	/*
+	 * The alloc_uid() incremented the userns refcount,
+	 * so drop it again 
+	 */
+	put_user_ns(ns);
 
-	switch_uid(new_user);
+	switch_uid(ns->root_user);
 	return ns;
 }
 
@@ -72,6 +73,7 @@ void free_user_ns(struct kref *kref)
 
 	ns = container_of(kref, struct user_namespace, kref);
 	release_uids(ns);
+	free_uid(ns->creator);
 	kfree(ns);
 }
 EXPORT_SYMBOL(free_user_ns);
-- 
1.5.4.3
