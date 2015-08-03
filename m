From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 1/6] mnt: Track which mounts use a dentry as root.
Date: Mon, 03 Aug 2015 16:26:07 -0500
Message-ID: <87vbcw9i8g.fsf_-___19307.0164918483$1438637591$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tfkawu9.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 03 Aug 2015 16:25:18 -0500")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


This is needed infrastructure for better handling of when files
or directories are moved out from under the root of a bind mount.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h             |   7 +++
 fs/namespace.c         | 120 +++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dcache.h |   7 +++
 3 files changed, 130 insertions(+), 4 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index 14db05d424f7..e8f22970fe59 100644
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
index 2b8aa15fd6df..2ce987af9afa 100644
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
@@ -779,6 +800,77 @@ static void put_mountpoint(struct mountpoint *mp)
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
+	read_seqlock_excl(&mount_lock);
+	if (d_mountroot(root))
+		mr = lookup_mountroot(root);
+	if (!mr) {
+		struct mountroot *new;
+		read_sequnlock_excl(&mount_lock);
+
+		new = kmalloc(sizeof(struct mountroot), GFP_KERNEL);
+		if (!new)
+			return -ENOMEM;
+
+		read_seqlock_excl(&mount_lock);
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
+	read_sequnlock_excl(&mount_lock);
+
+	return 0;
+}
+
+static void mnt_put_root(struct mount *mnt)
+{
+	struct dentry *root = mnt->mnt.mnt_root;
+	struct mountroot *mr;
+
+	read_seqlock_excl(&mount_lock);
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
+	read_sequnlock_excl(&mount_lock);
+	dput(root);
+}
+
 static inline int check_mnt(struct mount *mnt)
 {
 	return mnt->mnt_ns == current->nsproxy->mnt_ns;
@@ -934,6 +1026,7 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 {
 	struct mount *mnt;
 	struct dentry *root;
+	int err;
 
 	if (!type)
 		return ERR_PTR(-ENODEV);
@@ -952,8 +1045,16 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 		return ERR_CAST(root);
 	}
 
-	mnt->mnt.mnt_root = root;
 	mnt->mnt.mnt_sb = root->d_sb;
+	err = mnt_set_root(mnt, root);
+	if (err) {
+		dput(root);
+		deactivate_super(mnt->mnt.mnt_sb);
+		mnt_free_id(mnt);
+		free_vfsmnt(mnt);
+		return ERR_PTR(err);
+	}
+
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
 	mnt->mnt_parent = mnt;
 	lock_mount_hash();
@@ -985,6 +1086,10 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 			goto out_free;
 	}
 
+	err = mnt_set_root(mnt, root);
+	if (err)
+		goto out_free;
+
 	mnt->mnt.mnt_flags = old->mnt.mnt_flags & ~(MNT_WRITE_HOLD|MNT_MARKED);
 	/* Don't allow unprivileged users to change mount flags */
 	if (flag & CL_UNPRIVILEGED) {
@@ -1010,7 +1115,7 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 
 	atomic_inc(&sb->s_active);
 	mnt->mnt.mnt_sb = sb;
-	mnt->mnt.mnt_root = dget(root);
+	dget(root);
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
 	mnt->mnt_parent = mnt;
 	lock_mount_hash();
@@ -1063,7 +1168,7 @@ static void cleanup_mnt(struct mount *mnt)
 	if (unlikely(mnt->mnt_pins.first))
 		mnt_pin_kill(mnt);
 	fsnotify_vfsmount_delete(&mnt->mnt);
-	dput(mnt->mnt.mnt_root);
+	mnt_put_root(mnt);
 	deactivate_super(mnt->mnt.mnt_sb);
 	mnt_free_id(mnt);
 	call_rcu(&mnt->mnt_rcu, delayed_free_vfsmnt);
@@ -3120,14 +3225,21 @@ void __init mnt_init(void)
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
index d67ae119cf4e..52a5e6915f58 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -228,6 +228,8 @@ struct dentry_operations {
 #define DCACHE_FALLTHRU			0x01000000 /* Fall through to lower layer */
 #define DCACHE_OP_SELECT_INODE		0x02000000 /* Unioned entry: dcache op selects inode */
 
+#define DCACHE_MOUNTROOT		0x04000000 /* Root of a vfsmount */
+
 extern seqlock_t rename_lock;
 
 /*
@@ -404,6 +406,11 @@ static inline bool d_mountpoint(const struct dentry *dentry)
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
