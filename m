From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 07/19] mnt: On an unmount propagate clearing of
	MNT_LOCKED
Date: Thu,  2 Apr 2015 20:56:11 -0500
Message-ID: <1428026183-14879-7-git-send-email-ebiederm__35885.1314559162$1428026483$gmane$org@xmission.com>
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

A prerequisite of calling umount_tree is that the point where the tree
is mounted at is valid to unmount.

If we are propagating the effect of the unmount clear MNT_LOCKED in
every instance where the same filesystem is mounted on the same
mountpoint in the mount tree, as we know (by virtue of the fact
that umount_tree was called) that it is safe to reveal what
is at that mountpoint.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c |  3 +++
 fs/pnode.c     | 20 ++++++++++++++++++++
 fs/pnode.h     |  1 +
 3 files changed, 24 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 083e3401a808..2b12b7a9455d 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1333,6 +1333,9 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 	LIST_HEAD(tmp_list);
 	struct mount *p;
 
+	if (how & UMOUNT_PROPAGATE)
+		propagate_mount_unlock(mnt);
+
 	/* Gather the mounts to umount */
 	for (p = mnt; p; p = next_mnt(p, mnt)) {
 		p->mnt.mnt_flags |= MNT_UMOUNT;
diff --git a/fs/pnode.c b/fs/pnode.c
index c27ae38ee250..89890293dd0a 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -362,6 +362,26 @@ int propagate_mount_busy(struct mount *mnt, int refcnt)
 }
 
 /*
+ * Clear MNT_LOCKED when it can be shown to be safe.
+ *
+ * mount_lock lock must be held for write
+ */
+void propagate_mount_unlock(struct mount *mnt)
+{
+	struct mount *parent = mnt->mnt_parent;
+	struct mount *m, *child;
+
+	BUG_ON(parent == mnt);
+
+	for (m = propagation_next(parent, parent); m;
+			m = propagation_next(m, parent)) {
+		child = __lookup_mnt_last(&m->mnt, mnt->mnt_mountpoint);
+		if (child)
+			child->mnt.mnt_flags &= ~MNT_LOCKED;
+	}
+}
+
+/*
  * NOTE: unmounting 'mnt' naturally propagates to all other mounts its
  * parent propagates to.
  */
diff --git a/fs/pnode.h b/fs/pnode.h
index aa6d65df7204..af47d4bd7b31 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -42,6 +42,7 @@ int propagate_mnt(struct mount *, struct mountpoint *, struct mount *,
 		struct hlist_head *);
 int propagate_umount(struct list_head *);
 int propagate_mount_busy(struct mount *, int);
+void propagate_mount_unlock(struct mount *);
 void mnt_release_group_id(struct mount *);
 int get_dominating_id(struct mount *mnt, const struct path *root);
 unsigned int mnt_get_count(struct mount *mnt);
-- 
2.2.1
