From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 04/19] mnt: In umount_tree reuse mnt_list instead of
	mnt_hash
Date: Thu,  2 Apr 2015 20:56:08 -0500
Message-ID: <1428026183-14879-4-git-send-email-ebiederm__1354.92986669323$1428026469$gmane$org@xmission.com>
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

umount_tree builds a list of mounts that need to be unmounted.
Utilize mnt_list for this purpose instead of mnt_hash.  This begins to
allow keeping a mount on the mnt_hash after it is unmounted, which is
necessary for a properly functioning MNT_LOCKED implementation.

The fact that mnt_list is an ordinary list makding available list_move
is nice bonus.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 20 +++++++++++---------
 fs/pnode.c     |  6 +++---
 fs/pnode.h     |  2 +-
 3 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c68d9fc912e7..54cbef129f4a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1327,23 +1327,25 @@ enum umount_tree_flags {
  */
 static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 {
-	HLIST_HEAD(tmp_list);
+	LIST_HEAD(tmp_list);
 	struct mount *p;
 
-	for (p = mnt; p; p = next_mnt(p, mnt)) {
-		hlist_del_init_rcu(&p->mnt_hash);
-		hlist_add_head(&p->mnt_hash, &tmp_list);
-	}
+	/* Gather the mounts to umount */
+	for (p = mnt; p; p = next_mnt(p, mnt))
+		list_move(&p->mnt_list, &tmp_list);
 
-	hlist_for_each_entry(p, &tmp_list, mnt_hash)
+	/* Hide the mounts from lookup_mnt and mnt_mounts */
+	list_for_each_entry(p, &tmp_list, mnt_list) {
+		hlist_del_init_rcu(&p->mnt_hash);
 		list_del_init(&p->mnt_child);
+	}
 
+	/* Add propogated mounts to the tmp_list */
 	if (how & UMOUNT_PROPAGATE)
 		propagate_umount(&tmp_list);
 
-	while (!hlist_empty(&tmp_list)) {
-		p = hlist_entry(tmp_list.first, struct mount, mnt_hash);
-		hlist_del_init_rcu(&p->mnt_hash);
+	while (!list_empty(&tmp_list)) {
+		p = list_first_entry(&tmp_list, struct mount, mnt_list);
 		list_del_init(&p->mnt_expire);
 		list_del_init(&p->mnt_list);
 		__touch_mnt_namespace(p->mnt_ns);
diff --git a/fs/pnode.c b/fs/pnode.c
index 260ac8f898a4..bf012af709dd 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -384,7 +384,7 @@ static void __propagate_umount(struct mount *mnt)
 		if (child && list_empty(&child->mnt_mounts)) {
 			list_del_init(&child->mnt_child);
 			hlist_del_init_rcu(&child->mnt_hash);
-			hlist_add_before_rcu(&child->mnt_hash, &mnt->mnt_hash);
+			list_move_tail(&child->mnt_list, &mnt->mnt_list);
 		}
 	}
 }
@@ -396,11 +396,11 @@ static void __propagate_umount(struct mount *mnt)
  *
  * vfsmount lock must be held for write
  */
-int propagate_umount(struct hlist_head *list)
+int propagate_umount(struct list_head *list)
 {
 	struct mount *mnt;
 
-	hlist_for_each_entry(mnt, list, mnt_hash)
+	list_for_each_entry(mnt, list, mnt_list)
 		__propagate_umount(mnt);
 	return 0;
 }
diff --git a/fs/pnode.h b/fs/pnode.h
index 16afc3d6d2f2..aa6d65df7204 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -40,7 +40,7 @@ static inline void set_mnt_shared(struct mount *mnt)
 void change_mnt_propagation(struct mount *, int);
 int propagate_mnt(struct mount *, struct mountpoint *, struct mount *,
 		struct hlist_head *);
-int propagate_umount(struct hlist_head *);
+int propagate_umount(struct list_head *);
 int propagate_mount_busy(struct mount *, int);
 void mnt_release_group_id(struct mount *);
 int get_dominating_id(struct mount *mnt, const struct path *root);
-- 
2.2.1
