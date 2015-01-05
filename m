From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/11] mnt: Delay removal from the mount hash.
Date: Mon,  5 Jan 2015 14:46:21 -0600
Message-ID: <1420490787-14387-5-git-send-email-ebiederm@xmission.com>
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

- Modify __lookup_mnt_hash_last to ignore mounts that have MNT_UMOUNTED set.
- Don't remove mounts from the mount hash table in propogate_umount
- Don't remove mounts from the mount hash table in umount_tree before
  the entire list of mounts to be umounted is selected.
- Remove mounts from the mount hash table as the last thing that
  happens in the case where a mount has a parent in umount_tree.
  Mounts without parents are not hashed (by definition).

This paves the way for delaying removal from the mount hash table even
farther and fixing the MNT_LOCKED vs MNT_DETACH issue.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 13 ++++++++-----
 fs/pnode.c     |  1 -
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 60d4160cd2f4..a8afec9c81b6 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -623,14 +623,17 @@ struct mount *__lookup_mnt(struct vfsmount *mnt, struct dentry *dentry)
  */
 struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
 {
-	struct mount *p, *res;
-	res = p = __lookup_mnt(mnt, dentry);
+	struct mount *p, *res = NULL;
+	p = __lookup_mnt(mnt, dentry);
 	if (!p)
 		goto out;
+	if (!(p->mnt.mnt_flags & MNT_UMOUNT))
+		res = p;
 	hlist_for_each_entry_continue(p, mnt_hash) {
 		if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
 			break;
-		res = p;
+		if (!(p->mnt.mnt_flags & MNT_UMOUNT))
+			res = p;
 	}
 out:
 	return res;
@@ -1341,9 +1344,8 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		list_move(&p->mnt_list, &tmp_list);
 	}
 
-	/* Hide the mounts from lookup_mnt and mnt_mounts */
+	/* Hide the mounts from mnt_mounts */
 	list_for_each_entry(p, &tmp_list, mnt_list) {
-		hlist_del_init_rcu(&p->mnt_hash);
 		list_del_init(&p->mnt_child);
 	}
 
@@ -1367,6 +1369,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 			p->mnt_mountpoint = p->mnt.mnt_root;
 			p->mnt_parent = p;
 			p->mnt_mp = NULL;
+			hlist_del_init_rcu(&p->mnt_hash);
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
diff --git a/fs/pnode.c b/fs/pnode.c
index ac3aa0d43b90..c27ae38ee250 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -383,7 +383,6 @@ static void __propagate_umount(struct mount *mnt)
 		 */
 		if (child && list_empty(&child->mnt_mounts)) {
 			list_del_init(&child->mnt_child);
-			hlist_del_init_rcu(&child->mnt_hash);
 			child->mnt.mnt_flags |= MNT_UMOUNT;
 			list_move_tail(&child->mnt_list, &mnt->mnt_list);
 		}
-- 
2.2.1
