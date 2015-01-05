From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 01/11] mnt: Improve the umount_tree flags
Date: Mon,  5 Jan 2015 14:46:17 -0600
Message-ID: <1420490787-14387-1-git-send-email-ebiederm@xmission.com>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mw5xq7lt.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

- Remove the unneeded declaration from pnode.h
- Mark umount_tree static as it has no callers outside of namespace.c
- Define an enumeration of umount_tree's flags.
- Pass umount_tree's flags in by name

This removes the magic numbers 0, 1 and 2 making the code a little
clearer and makes it possible for there to be lazy unmounts that don't
propagate.  Which is what __detach_mounts actually wants for example.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 31 ++++++++++++++++---------------
 fs/pnode.h     |  1 -
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index cd1e9681a0cf..5bb96c440b31 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1323,14 +1323,15 @@ static inline void namespace_lock(void)
 	down_write(&namespace_sem);
 }
 
+enum umount_tree_flags {
+	UMOUNT_SYNC = 1,
+	UMOUNT_PROPAGATE = 2,
+};
 /*
  * mount_lock must be held
  * namespace_sem must be held for write
- * how = 0 => just this tree, don't propagate
- * how = 1 => propagate; we know that nobody else has reference to any victims
- * how = 2 => lazy umount
  */
-void umount_tree(struct mount *mnt, int how)
+static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 {
 	HLIST_HEAD(tmp_list);
 	struct mount *p;
@@ -1344,7 +1345,7 @@ void umount_tree(struct mount *mnt, int how)
 	hlist_for_each_entry(p, &tmp_list, mnt_hash)
 		list_del_init(&p->mnt_child);
 
-	if (how)
+	if (how & UMOUNT_PROPAGATE)
 		propagate_umount(&tmp_list);
 
 	hlist_for_each_entry(p, &tmp_list, mnt_hash) {
@@ -1352,7 +1353,7 @@ void umount_tree(struct mount *mnt, int how)
 		list_del_init(&p->mnt_list);
 		__touch_mnt_namespace(p->mnt_ns);
 		p->mnt_ns = NULL;
-		if (how < 2)
+		if (how & UMOUNT_SYNC)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 		if (mnt_has_parent(p)) {
 			hlist_del_init(&p->mnt_mp_list);
@@ -1457,14 +1458,14 @@ static int do_umount(struct mount *mnt, int flags)
 
 	if (flags & MNT_DETACH) {
 		if (!list_empty(&mnt->mnt_list))
-			umount_tree(mnt, 2);
+			umount_tree(mnt, UMOUNT_PROPAGATE);
 		retval = 0;
 	} else {
 		shrink_submounts(mnt);
 		retval = -EBUSY;
 		if (!propagate_mount_busy(mnt, 2)) {
 			if (!list_empty(&mnt->mnt_list))
-				umount_tree(mnt, 1);
+				umount_tree(mnt, UMOUNT_PROPAGATE|UMOUNT_SYNC);
 			retval = 0;
 		}
 	}
@@ -1496,7 +1497,7 @@ void __detach_mounts(struct dentry *dentry)
 	lock_mount_hash();
 	while (!hlist_empty(&mp->m_list)) {
 		mnt = hlist_entry(mp->m_list.first, struct mount, mnt_mp_list);
-		umount_tree(mnt, 2);
+		umount_tree(mnt, UMOUNT_PROPAGATE);
 	}
 	unlock_mount_hash();
 	put_mountpoint(mp);
@@ -1658,7 +1659,7 @@ struct mount *copy_tree(struct mount *mnt, struct dentry *dentry,
 out:
 	if (res) {
 		lock_mount_hash();
-		umount_tree(res, 0);
+		umount_tree(res, UMOUNT_SYNC);
 		unlock_mount_hash();
 	}
 	return q;
@@ -1682,7 +1683,7 @@ void drop_collected_mounts(struct vfsmount *mnt)
 {
 	namespace_lock();
 	lock_mount_hash();
-	umount_tree(real_mount(mnt), 0);
+	umount_tree(real_mount(mnt), UMOUNT_SYNC);
 	unlock_mount_hash();
 	namespace_unlock();
 }
@@ -1865,7 +1866,7 @@ static int attach_recursive_mnt(struct mount *source_mnt,
  out_cleanup_ids:
 	while (!hlist_empty(&tree_list)) {
 		child = hlist_entry(tree_list.first, struct mount, mnt_hash);
-		umount_tree(child, 0);
+		umount_tree(child, UMOUNT_SYNC);
 	}
 	unlock_mount_hash();
 	cleanup_group_ids(source_mnt, NULL);
@@ -2045,7 +2046,7 @@ static int do_loopback(struct path *path, const char *old_name,
 	err = graft_tree(mnt, parent, mp);
 	if (err) {
 		lock_mount_hash();
-		umount_tree(mnt, 0);
+		umount_tree(mnt, UMOUNT_SYNC);
 		unlock_mount_hash();
 	}
 out2:
@@ -2416,7 +2417,7 @@ void mark_mounts_for_expiry(struct list_head *mounts)
 	while (!list_empty(&graveyard)) {
 		mnt = list_first_entry(&graveyard, struct mount, mnt_expire);
 		touch_mnt_namespace(mnt->mnt_ns);
-		umount_tree(mnt, 1);
+		umount_tree(mnt, UMOUNT_PROPAGATE|UMOUNT_SYNC);
 	}
 	unlock_mount_hash();
 	namespace_unlock();
@@ -2487,7 +2488,7 @@ static void shrink_submounts(struct mount *mnt)
 			m = list_first_entry(&graveyard, struct mount,
 						mnt_expire);
 			touch_mnt_namespace(m->mnt_ns);
-			umount_tree(m, 1);
+			umount_tree(m, UMOUNT_PROPAGATE|UMOUNT_SYNC);
 		}
 	}
 }
diff --git a/fs/pnode.h b/fs/pnode.h
index 4a246358b031..16afc3d6d2f2 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -47,7 +47,6 @@ int get_dominating_id(struct mount *mnt, const struct path *root);
 unsigned int mnt_get_count(struct mount *mnt);
 void mnt_set_mountpoint(struct mount *, struct mountpoint *,
 			struct mount *);
-void umount_tree(struct mount *, int);
 struct mount *copy_tree(struct mount *, struct dentry *, int);
 bool is_path_reachable(struct mount *, struct dentry *,
 			 const struct path *root);
-- 
2.2.1
