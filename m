From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/19] mnt: Factor out unhash_mnt from detach_mnt and
	umount_tree
Date: Thu,  2 Apr 2015 20:56:14 -0500
Message-ID: <1428026183-14879-10-git-send-email-ebiederm__25464.7098984153$1428026503$gmane$org@xmission.com>
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

Create a function unhash_mnt that contains the common code between
detach_mnt and umount_tree, and use unhash_mnt in place of the common
code.  This add a unncessary list_del_init(mnt->mnt_child) into
umount_tree but given that mnt_child is already empty this extra
line is a noop.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index acc5583764dc..e669a3bf86e7 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -798,10 +798,8 @@ static void __touch_mnt_namespace(struct mnt_namespace *ns)
 /*
  * vfsmount lock must be held for write
  */
-static void detach_mnt(struct mount *mnt, struct path *old_path)
+static void unhash_mnt(struct mount *mnt)
 {
-	old_path->dentry = mnt->mnt_mountpoint;
-	old_path->mnt = &mnt->mnt_parent->mnt;
 	mnt->mnt_parent = mnt;
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
 	list_del_init(&mnt->mnt_child);
@@ -814,6 +812,16 @@ static void detach_mnt(struct mount *mnt, struct path *old_path)
 /*
  * vfsmount lock must be held for write
  */
+static void detach_mnt(struct mount *mnt, struct path *old_path)
+{
+	old_path->dentry = mnt->mnt_mountpoint;
+	old_path->mnt = &mnt->mnt_parent->mnt;
+	unhash_mnt(mnt);
+}
+
+/*
+ * vfsmount lock must be held for write
+ */
 void mnt_set_mountpoint(struct mount *mnt,
 			struct mountpoint *mp,
 			struct mount *child_mnt)
@@ -1362,15 +1370,10 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 
 		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
 		if (mnt_has_parent(p)) {
-			hlist_del_init(&p->mnt_mp_list);
-			put_mountpoint(p->mnt_mp);
 			mnt_add_count(p->mnt_parent, -1);
 			/* old mountpoint will be dropped when we can do that */
 			p->mnt_ex_mountpoint = p->mnt_mountpoint;
-			p->mnt_mountpoint = p->mnt.mnt_root;
-			p->mnt_parent = p;
-			p->mnt_mp = NULL;
-			hlist_del_init_rcu(&p->mnt_hash);
+			unhash_mnt(p);
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
-- 
2.2.1
