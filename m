From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review  13/19] mnt: Honor MNT_LOCKED when detaching mounts
Date: Thu,  2 Apr 2015 20:56:17 -0500
Message-ID: <1428026183-14879-13-git-send-email-ebiederm__5246.87153888426$1428026558$gmane$org@xmission.com>
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

Modify umount(MNT_DETACH) to keep mounts in the hash table that are
locked to their parent mounts, when the parent is lazily unmounted.

In mntput_no_expire detach the children from the hash table, depending
on mnt_pin_kill in cleanup_mnt to decrement the mnt_count of the children.

In __detach_mounts if there are any mounts that have been unmounted
but still are on the list of mounts of a mountpoint, remove their
children from the mount hash table and those children to the unmounted
list so they won't linger potentially indefinitely waiting for their
final mntput, now that the mounts serve no purpose.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 29 ++++++++++++++++++++++++++---
 fs/pnode.h     |  2 ++
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 010d5bebcb7e..1894d1878dbc 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1099,6 +1099,13 @@ static void mntput_no_expire(struct mount *mnt)
 	rcu_read_unlock();
 
 	list_del(&mnt->mnt_instance);
+
+	if (unlikely(!list_empty(&mnt->mnt_mounts))) {
+		struct mount *p, *tmp;
+		list_for_each_entry_safe(p, tmp, &mnt->mnt_mounts,  mnt_child) {
+			umount_mnt(p);
+		}
+	}
 	unlock_mount_hash();
 
 	if (likely(!(mnt->mnt.mnt_flags & MNT_INTERNAL))) {
@@ -1370,6 +1377,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		propagate_umount(&tmp_list);
 
 	while (!list_empty(&tmp_list)) {
+		bool disconnect;
 		p = list_first_entry(&tmp_list, struct mount, mnt_list);
 		list_del_init(&p->mnt_expire);
 		list_del_init(&p->mnt_list);
@@ -1378,10 +1386,18 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		if (how & UMOUNT_SYNC)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 
-		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
+		disconnect = !IS_MNT_LOCKED_AND_LAZY(p);
+
+		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt,
+				 disconnect ? &unmounted : NULL);
 		if (mnt_has_parent(p)) {
 			mnt_add_count(p->mnt_parent, -1);
-			umount_mnt(p);
+			if (!disconnect) {
+				/* Don't forget about p */
+				list_add_tail(&p->mnt_child, &p->mnt_parent->mnt_mounts);
+			} else {
+				umount_mnt(p);
+			}
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
@@ -1506,7 +1522,14 @@ void __detach_mounts(struct dentry *dentry)
 	lock_mount_hash();
 	while (!hlist_empty(&mp->m_list)) {
 		mnt = hlist_entry(mp->m_list.first, struct mount, mnt_mp_list);
-		umount_tree(mnt, 0);
+		if (mnt->mnt.mnt_flags & MNT_UMOUNT) {
+			struct mount *p, *tmp;
+			list_for_each_entry_safe(p, tmp, &mnt->mnt_mounts,  mnt_child) {
+				hlist_add_head(&p->mnt_umount.s_list, &unmounted);
+				umount_mnt(p);
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
