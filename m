From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review  16/19] mnt: Track which mounts use a dentry as root.
Date: Thu,  2 Apr 2015 20:56:20 -0500
Message-ID: <1428026183-14879-16-git-send-email-ebiederm__41297.4107814536$1428026565$gmane$org@xmission.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h             |   7 +++
 fs/namespace.c         | 122 +++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dcache.h |   7 +++
 3 files changed, 131 insertions(+), 5 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index 6a61c2b3e385..a8be3033e022 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -27,6 +27,12 @@ struct mountpoint {
 	int m_count;
 };
 
+struct mountroot {
+	struct hlist_node r_hash;
+	struct dentry *r_dentry;
+	struct hlist_head r_list;
+};
+
 struct mount {
 	struct hlist_node mnt_hash;
 	struct mount *mnt_parent;
@@ -55,6 +61,7 @@ struct mount {
 	struct mnt_namespace *mnt_ns;	/* containing namespace */
 	struct mountpoint *mnt_mp;	/* where is it mounted */
 	struct hlist_node mnt_mp_list;	/* list mounts with the same mountpoint */
+	struct hlist_node mnt_mr_list;	/* list mounts with the same mountroot */
 #ifdef CONFIG_FSNOTIFY
 	struct hlist_head mnt_fsnotify_marks;
 	__u32 mnt_fsnotify_mask;
diff --git a/fs/namespace.c b/fs/namespace.c
index 1f4f9dac6e5a..5b1b666439ac 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -31,6 +31,8 @@ static unsigned int m_hash_mask __read_mostly;
 static unsigned int m_hash_shift __read_mostly;
 static unsigned int mp_hash_mask __read_mostly;
 static unsigned int mp_hash_shift __read_mostly;
+static unsigned int mr_hash_mask __read_mostly;
+static unsigned int mr_hash_shift __read_mostly;
 
 static __initdata unsigned long mhash_entries;
 static int __init set_mhash_entries(char *str)
@@ -52,6 +54,16 @@ static int __init set_mphash_entries(char *str)
 }
 __setup("mphash_entries=", set_mphash_entries);
 
+static __initdata unsigned long mrhash_entries;
+static int __init set_mrhash_entries(char *str)
+{
+	if (!str)
+		return 0;
+	mrhash_entries = simple_strtoul(str, &str, 0);
+	return 1;
+}
+__setup("mrhash_entries=", set_mrhash_entries);
+
 static u64 event;
 static DEFINE_IDA(mnt_id_ida);
 static DEFINE_IDA(mnt_group_ida);
@@ -61,6 +73,7 @@ static int mnt_group_start = 1;
 
 static struct hlist_head *mount_hashtable __read_mostly;
 static struct hlist_head *mountpoint_hashtable __read_mostly;
+static struct hlist_head *mountroot_hashtable __read_mostly;
 static struct kmem_cache *mnt_cache __read_mostly;
 static DECLARE_RWSEM(namespace_sem);
 
@@ -93,6 +106,13 @@ static inline struct hlist_head *mp_hash(struct dentry *dentry)
 	return &mountpoint_hashtable[tmp & mp_hash_mask];
 }
 
+static inline struct hlist_head *mr_hash(struct dentry *dentry)
+{
+	unsigned long tmp = ((unsigned long)dentry / L1_CACHE_BYTES);
+	tmp = tmp + (tmp >> mr_hash_shift);
+	return &mountroot_hashtable[tmp & mr_hash_mask];
+}
+
 /*
  * allocation is serialized by namespace_sem, but we need the spinlock to
  * serialize with freeing.
@@ -234,6 +254,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 		INIT_LIST_HEAD(&mnt->mnt_slave_list);
 		INIT_LIST_HEAD(&mnt->mnt_slave);
 		INIT_HLIST_NODE(&mnt->mnt_mp_list);
+		INIT_HLIST_NODE(&mnt->mnt_mr_list);
 #ifdef CONFIG_FSNOTIFY
 		INIT_HLIST_HEAD(&mnt->mnt_fsnotify_marks);
 #endif
@@ -768,6 +789,77 @@ static void put_mountpoint(struct mountpoint *mp)
 	}
 }
 
+static struct mountroot *lookup_mountroot(struct dentry *dentry)
+{
+	struct hlist_head *chain = mr_hash(dentry);
+	struct mountroot *mr;
+
+	hlist_for_each_entry(mr, chain, r_hash) {
+		if (mr->r_dentry == dentry)
+			return mr;
+	}
+	return NULL;
+}
+
+static int mnt_set_root(struct mount *mnt, struct dentry *root)
+{
+	struct mountroot *mr = NULL;
+
+	lock_mount_hash();
+	if (unlikely(d_mountroot(root)))
+		mr = lookup_mountroot(root);
+	if (!mr) {
+		struct mountroot *new;
+		unlock_mount_hash();
+
+		new = kmalloc(sizeof(struct mountroot), GFP_KERNEL);
+		if (!new)
+			return -ENOMEM;
+
+		lock_mount_hash();
+		mr = lookup_mountroot(root);
+		if (mr) {
+			kfree(new);
+		} else {
+			struct hlist_head *chain = mr_hash(root);
+
+			mr = new;
+			mr->r_dentry = root;
+			INIT_HLIST_HEAD(&mr->r_list);
+			hlist_add_head(&mr->r_hash, chain);
+
+			spin_lock(&root->d_lock);
+			root->d_flags |= DCACHE_MOUNTROOT;
+			spin_unlock(&root->d_lock);
+		}
+	}
+	mnt->mnt.mnt_root = root;
+	hlist_add_head(&mnt->mnt_mr_list, &mr->r_list);
+	unlock_mount_hash();
+
+	return 0;
+}
+
+static void mnt_put_root(struct mount *mnt)
+{
+	struct dentry *root = mnt->mnt.mnt_root;
+	struct mountroot *mr;
+
+	lock_mount_hash();
+	mr = lookup_mountroot(root);
+	BUG_ON(!mr);
+	hlist_del(&mnt->mnt_mr_list);
+	if (hlist_empty(&mr->r_list)) {
+		hlist_del(&mr->r_hash);
+		spin_lock(&root->d_lock);
+		root->d_flags &= ~DCACHE_MOUNTROOT;
+		spin_unlock(&root->d_lock);
+		kfree(mr);
+	}
+	unlock_mount_hash();
+	dput(root);
+}
+
 static inline int check_mnt(struct mount *mnt)
 {
 	return mnt->mnt_ns == current->nsproxy->mnt_ns;
@@ -923,6 +1015,7 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 {
 	struct mount *mnt;
 	struct dentry *root;
+	int err;
 
 	if (!type)
 		return ERR_PTR(-ENODEV);
@@ -941,7 +1034,15 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 		return ERR_CAST(root);
 	}
 
-	mnt->mnt.mnt_root = root;
+	err = mnt_set_root(mnt, root);
+	if (err) {
+		dput(mnt->mnt.mnt_root);
+		deactivate_super(root->d_sb);
+		mnt_free_id(mnt);
+		free_vfsmnt(mnt);
+		return ERR_PTR(err);
+	}
+
 	mnt->mnt.mnt_sb = root->d_sb;
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
 	mnt->mnt_parent = mnt;
@@ -974,6 +1075,10 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 			goto out_free;
 	}
 
+	err = mnt_set_root(mnt, root);
+	if (err)
+		goto out_free;
+
 	mnt->mnt.mnt_flags = old->mnt.mnt_flags & ~(MNT_WRITE_HOLD|MNT_MARKED);
 	/* Don't allow unprivileged users to change mount flags */
 	if (flag & CL_UNPRIVILEGED) {
@@ -997,9 +1102,9 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	    (!(flag & CL_EXPIRE) || list_empty(&old->mnt_expire)))
 		mnt->mnt.mnt_flags |= MNT_LOCKED;
 
-	atomic_inc(&sb->s_active);
 	mnt->mnt.mnt_sb = sb;
-	mnt->mnt.mnt_root = dget(root);
+	atomic_inc(&sb->s_active);
+	dget(root);
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
 	mnt->mnt_parent = mnt;
 	lock_mount_hash();
@@ -1052,7 +1157,7 @@ static void cleanup_mnt(struct mount *mnt)
 	if (unlikely(mnt->mnt_pins.first))
 		mnt_pin_kill(mnt);
 	fsnotify_vfsmount_delete(&mnt->mnt);
-	dput(mnt->mnt.mnt_root);
+	mnt_put_root(mnt);
 	deactivate_super(mnt->mnt.mnt_sb);
 	mnt_free_id(mnt);
 	call_rcu(&mnt->mnt_rcu, delayed_free_vfsmnt);
@@ -3079,14 +3184,21 @@ void __init mnt_init(void)
 				mphash_entries, 19,
 				0,
 				&mp_hash_shift, &mp_hash_mask, 0, 0);
+	mountroot_hashtable = alloc_large_system_hash("Mountroot-cache",
+				sizeof(struct hlist_head),
+				mrhash_entries, 19,
+				0,
+				&mr_hash_shift, &mr_hash_mask, 0, 0);
 
-	if (!mount_hashtable || !mountpoint_hashtable)
+	if (!mount_hashtable || !mountpoint_hashtable || !mountroot_hashtable)
 		panic("Failed to allocate mount hash table\n");
 
 	for (u = 0; u <= m_hash_mask; u++)
 		INIT_HLIST_HEAD(&mount_hashtable[u]);
 	for (u = 0; u <= mp_hash_mask; u++)
 		INIT_HLIST_HEAD(&mountpoint_hashtable[u]);
+	for (u = 0; u <= mr_hash_mask; u++)
+		INIT_HLIST_HEAD(&mountroot_hashtable[u]);
 
 	kernfs_init();
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index d8358799c594..dd987fb9e1f7 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -226,6 +226,8 @@ struct dentry_operations {
 #define DCACHE_MAY_FREE			0x00800000
 #define DCACHE_FALLTHRU			0x01000000 /* Fall through to lower layer */
 
+#define DCACHE_MOUNTROOT		0x01000000 /* is root of a vfsmount */
+
 extern seqlock_t rename_lock;
 
 /*
@@ -401,6 +403,11 @@ static inline bool d_mountpoint(const struct dentry *dentry)
 	return dentry->d_flags & DCACHE_MOUNTED;
 }
 
+static inline bool d_mountroot(const struct dentry *dentry)
+{
+	return dentry->d_flags & DCACHE_MOUNTROOT;
+}
+
 /*
  * Directory cache entry type accessor functions.
  */
-- 
2.2.1
