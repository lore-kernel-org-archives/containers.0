From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/3] user namespaces: introduce user_struct->user_namespace
	relationship
Date: Fri, 3 Oct 2008 20:36:44 -0500
Message-ID: <20081004013644.GA24104@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754087AbYJDBg4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: James Morris <jmorris@redhat.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Hi James,

here are 3 patches to fix up the user namespaces a bit in preparation
for real userns work to begin.  Andrew had suggested that these be
rebased on top of your -next tree because they will conflict with
the credentials work.  But it looks like much of the credentials stuff
isn't in your next branch.  If you'd prefer that I port these to
creds-next, please let me know.  I'll have to do it eventually :)

Yet-another-ltp-test shows no regressions.

thanks,
-serge

Subject: [PATCH] user namespaces: introduce user_struct->user_namespace relationship
From: Serge Hallyn <serue@us.ibm.com>
Date: 1223047324 -0400

When a task does clone(CLONE_NEWNS), the task's user is the 'creator' of the
new user_namespace, and the user_namespace is tacked onto a list of those
created by this user.

Changelog:
	Aug 25: make free_user not inlined as it's not trivial.  (Eric
		Biederman suggestion)
	Aug 1: renamed user->user_namespace to user_ns, as the next
		patch did anyway.
	Aug 1: move put_user_ns call in one free_user() definition
		to move it outside the lock in free_user.  put_user_ns
		calls free_user on the user_ns->creator, which in
		turn would grab the lock again.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>

---

 include/linux/sched.h          |    1 +
 include/linux/user_namespace.h |    1 +
 kernel/user.c                  |   11 +++++++++--
 kernel/user_namespace.c        |   20 +++++++++++---------
 4 files changed, 22 insertions(+), 11 deletions(-)

02b90654b57d650819ff3265161d95f4cf91cc94
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3d9120c..1cf17d9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -601,6 +601,7 @@ struct user_struct {
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
index 865ecf5..ee841c7 100644
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
@@ -319,12 +321,13 @@ done:
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
 	/* restore back the count */
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
+	put_user_ns(up->user_ns);
 	INIT_WORK(&up->work, remove_user_sysfs_dir);
 	schedule_work(&up->work);
 }
@@ -340,13 +343,14 @@ static inline void uids_mutex_unlock(voi
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
  */
-static inline void free_user(struct user_struct *up, unsigned long flags)
+static void free_user(struct user_struct *up, unsigned long flags)
 {
 	uid_hash_remove(up);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
+	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
@@ -409,6 +413,8 @@ struct user_struct *alloc_uid(struct use
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
 
+		new->user_ns = get_user_ns(ns);
+
 		if (uids_user_create(new))
 			goto out_destoy_sched;
 
@@ -441,6 +447,7 @@ struct user_struct *alloc_uid(struct use
 
 out_destoy_sched:
 	sched_destroy_user(new);
+	put_user_ns(new->user_ns);
 out_free_user:
 	kmem_cache_free(uid_cachep, new);
 out_unlock:
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 532858f..f9f7ad7 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -18,7 +18,6 @@
 static struct user_namespace *clone_user_ns(struct user_namespace *old_ns)
 {
 	struct user_namespace *ns;
-	struct user_struct *new_user;
 	int n;
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
@@ -37,15 +36,17 @@ static struct user_namespace *clone_user
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
 
@@ -71,6 +72,7 @@ void free_user_ns(struct kref *kref)
 
 	ns = container_of(kref, struct user_namespace, kref);
 	release_uids(ns);
+	free_uid(ns->creator);
 	kfree(ns);
 }
 EXPORT_SYMBOL(free_user_ns);
-- 
1.1.6
