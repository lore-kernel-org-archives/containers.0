From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Mon,  5 Jan 2015 14:46:27 -0600
Message-ID: <1420490787-14387-11-git-send-email-ebiederm__6380.4077370607$1420491140$gmane$org@xmission.com>
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

Modify umount(MNT_DETACH) to keep mounts in the hash table that are
locked to their parent mounts, when the parent is lazily unmounted.
In doing this invert the reference count so that the parent holds a
reference to the children instead of the children holding a reference
to the parent.

Then in mntput_no_expire detach the children and in cleanup_mnt mntput
the children and dput the dentry they were mounted on.

In __detach_mounts if there are any mounts that have been unmounted
but still are on the list of mounts of a mountpoint, detach those
mounts and schedule them to be mntput and their reference to the dentry
to be put when it becomes safe to sleep.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 46 ++++++++++++++++++++++++++++++++++++++++++----
 fs/pnode.h     |  2 ++
 2 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index ca801b41c643..689a27d6e950 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1017,6 +1017,17 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	return ERR_PTR(err);
 }
 
+static void mntput_children(struct mount *mnt)
+{
+	struct mount *p, *tmp;
+
+	list_for_each_entry_safe(p, tmp, &mnt->mnt_mounts, mnt_child) {
+		list_del_init(&p->mnt_child);
+		path_put(&p->mnt_ex_mountpoint);
+		mntput(&p->mnt);
+	}
+}
+
 static void cleanup_mnt(struct mount *mnt)
 {
 	/*
@@ -1030,6 +1041,8 @@ static void cleanup_mnt(struct mount *mnt)
 	 * so mnt_get_writers() below is safe.
 	 */
 	WARN_ON(mnt_get_writers(mnt));
+	if (unlikely(!list_empty(&mnt->mnt_mounts)))
+		mntput_children(mnt);
 	if (unlikely(mnt->mnt_pins.first))
 		mnt_pin_kill(mnt);
 	fsnotify_vfsmount_delete(&mnt->mnt);
@@ -1080,6 +1093,15 @@ static void mntput_no_expire(struct mount *mnt)
 	rcu_read_unlock();
 
 	list_del(&mnt->mnt_instance);
+
+	if (unlikely(!list_empty(&mnt->mnt_mounts))) {
+		struct mount *p;
+		list_for_each_entry(p, &mnt->mnt_mounts,  mnt_child) {
+			__detach_mnt(p, &p->mnt_ex_mountpoint);
+			/* No need to mntput mnt */
+			p->mnt_ex_mountpoint.mnt = NULL;
+		}
+	}
 	unlock_mount_hash();
 
 	if (likely(!(mnt->mnt.mnt_flags & MNT_INTERNAL))) {
@@ -1342,7 +1364,7 @@ enum umount_tree_flags {
 static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 {
 	LIST_HEAD(tmp_list);
-	struct mount *p;
+	struct mount *tmp, *p;
 
 	if (how & UMOUNT_PROPAGATE)
 		propagate_mount_unlock(mnt);
@@ -1362,7 +1384,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 	if (how & UMOUNT_PROPAGATE)
 		propagate_umount(&tmp_list);
 
-	list_for_each_entry(p, &tmp_list, mnt_list) {
+	list_for_each_entry_safe(p, tmp, &tmp_list, mnt_list) {
 		list_del_init(&p->mnt_expire);
 		__touch_mnt_namespace(p->mnt_ns);
 		p->mnt_ns = NULL;
@@ -1370,7 +1392,14 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 		if (mnt_has_parent(p)) {
 			mnt_add_count(p->mnt_parent, -1);
-			__detach_mnt(p, &p->mnt_ex_mountpoint);
+			if (IS_MNT_LOCKED_AND_LAZY(p)) {
+				/* Don't mntput p in namespace_unlock */
+				list_del_init(&p->mnt_list);
+				/* Don't forget about p */
+				list_add_tail(&p->mnt_child, &p->mnt_parent->mnt_mounts);
+			} else {
+				__detach_mnt(p, &p->mnt_ex_mountpoint);
+			}
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
@@ -1496,7 +1525,16 @@ void __detach_mounts(struct dentry *dentry)
 	lock_mount_hash();
 	while (!hlist_empty(&mp->m_list)) {
 		mnt = hlist_entry(mp->m_list.first, struct mount, mnt_mp_list);
-		umount_tree(mnt, 0);
+		if (mnt->mnt.mnt_flags & MNT_UMOUNT) {
+			struct mount *p, *tmp;
+			list_for_each_entry_safe(p, tmp, &mnt->mnt_mounts,  mnt_child) {
+				detach_mnt(p, &p->mnt_ex_mountpoint);
+				/* p->mnt_parent has already been mntput */
+				p->mnt_ex_mountpoint.mnt = NULL;
+				list_add_tail(&p->mnt_list, &unmounted);
+			}
+		}
+		else umount_tree(mnt, 0);
 	}
 	unlock_mount_hash();
 	put_mountpoint(mp);
diff --git a/fs/pnode.h b/fs/pnode.h
index 0fcdbe7ca648..7114ce6e6b9e 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -20,6 +20,8 @@
 #define SET_MNT_MARK(m) ((m)->mnt.mnt_flags |= MNT_MARKED)
 #define CLEAR_MNT_MARK(m) ((m)->mnt.mnt_flags &= ~MNT_MARKED)
 #define IS_MNT_LOCKED(m) ((m)->mnt.mnt_flags & MNT_LOCKED)
+#define IS_MNT_LOCKED_AND_LAZY(m) \
+	(((m)->mnt.mnt_flags & (MNT_LOCKED|MNT_SYNC_UMOUNT)) == MNT_LOCKED)
 
 #define CL_EXPIRE    		0x01
 #define CL_SLAVE     		0x02
-- 
2.2.1
