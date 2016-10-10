From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] [v3] mount: dont execute propagate_umount() many times for
	same mounts
Date: Mon, 10 Oct 2016 16:26:05 -0700
Message-ID: <1476141965-21429-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The reason of this optimization is that umount() can hold namespace_sem
for a long time, this semaphore is global, so it affects all users.
Recently Eric W. Biederman added a per mount namespace limit on the
number of mounts. The default number of mounts allowed per mount
namespace at 100,000. Currently this value is allowed to construct a tree
which requires hours to be umounted.

In a worse case the current complexity of umount_tree() is O(n^3).
* Enumirate all mounts in a target tree (propagate_umount)
* Enumirate mounts to find where these changes have to
  be propagated (mark_umount_candidates)
* Enumirate mounts to find a requered mount by parent and dentry
  (__lookup_mnt_lat)

The worse case is when all mounts from the tree live in the same shared
group. In this case we have to enumirate all mounts on each step.

Here we can optimize the second step. We don't need to make it for
mounts which we already met when we did this step for previous mounts.
It reduces the complexity of umount_tree() to O(n^2).

Here is a script to generate such mount tree:
$ cat run.sh
mount -t tmpfs xxx /mnt
mount --make-shared /mnt
for i in `seq $1`; do
	mount --bind /mnt `mktemp -d /mnt/test.XXXXXX`
done
time umount -l /mnt
$ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done

Here is performance measurements with and without this patch:

mounts | before	| after (sec)
-----------------------------
1024   |  0.07  |
2048   |  0.23  |
4096   |  1.0   |
8912   |  8.7   | 0.11
16384  | 75     | 0.26
32768  |        | 0.75
65536  |        | 3.0
131072 |        | 13.7

This patch is a second step to fix CVE-2016-6213.

v2: fix mark_umount_candidates() to not change the existing behaviour.
v3: mark umounted mounts in mark_umount_candidates() and
__propagate_umount() separately, because they enumerate mounts in
oposite directions.

Cc: Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 fs/mount.h     |  2 ++
 fs/namespace.c | 19 ++++++++++++++++---
 fs/pnode.c     | 48 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 62 insertions(+), 7 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index d2e25d7..741c8a7 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -90,6 +90,8 @@ static inline int is_mounted(struct vfsmount *mnt)
 
 extern struct mount *__lookup_mnt(struct vfsmount *, struct dentry *);
 extern struct mount *__lookup_mnt_last(struct vfsmount *, struct dentry *);
+extern struct mount *__lookup_mnt_cont(struct mount *,
+					struct vfsmount *, struct dentry *);
 
 extern int __legitimize_mnt(struct vfsmount *, unsigned);
 extern bool legitimize_mnt(struct vfsmount *, unsigned);
diff --git a/fs/namespace.c b/fs/namespace.c
index 704a1fe..b454660 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -652,9 +652,7 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
 		goto out;
 	if (!(p->mnt.mnt_flags & MNT_UMOUNT))
 		res = p;
-	hlist_for_each_entry_continue(p, mnt_hash) {
-		if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
-			break;
+	for (; p != NULL; p = __lookup_mnt_cont(p, mnt, dentry)) {
 		if (!(p->mnt.mnt_flags & MNT_UMOUNT))
 			res = p;
 	}
@@ -662,6 +660,21 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
 	return res;
 }
 
+struct mount *__lookup_mnt_cont(struct mount *p,
+				struct vfsmount *mnt, struct dentry *dentry)
+{
+	struct hlist_node *node = p->mnt_hash.next;
+
+	if (!node)
+		return NULL;
+
+	p = hlist_entry(node, struct mount, mnt_hash);
+	if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
+		return NULL;
+
+	return p;
+}
+
 /*
  * lookup_mnt - Return the first child mount mounted at path
  *
diff --git a/fs/pnode.c b/fs/pnode.c
index 234a9ac..b28f4fd 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -399,10 +399,28 @@ static void mark_umount_candidates(struct mount *mnt)
 
 	BUG_ON(parent == mnt);
 
+	if (IS_MNT_MARKED(mnt))
+		return;
+
+	SET_MNT_MARK(mnt);
+
 	for (m = propagation_next(parent, parent); m;
 			m = propagation_next(m, parent)) {
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
+		struct mount *child = NULL, *p;
+
+		for (p = __lookup_mnt(&m->mnt, mnt->mnt_mountpoint); p;
+		     p = __lookup_mnt_cont(p, &m->mnt, mnt->mnt_mountpoint)) {
+			/*
+			 * Do this work only once for mounts from
+			 * the same propagation chain.
+			 */
+			if (p->mnt.mnt_flags & MNT_UMOUNT) {
+				SET_MNT_MARK(p);
+				continue;
+			}
+			child = p;
+		}
+
 		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
 			SET_MNT_MARK(child);
 		}
@@ -420,11 +438,33 @@ static void __propagate_umount(struct mount *mnt)
 
 	BUG_ON(parent == mnt);
 
+	/*
+	 * All mounts has been marked in mark_umount_candidates(), so
+	 * here the absence of the mark means that it has been handled
+	 * already.
+	 */
+	if (!IS_MNT_MARKED(mnt))
+		return;
+
+	CLEAR_MNT_MARK(mnt);
+
 	for (m = propagation_next(parent, parent); m;
 			m = propagation_next(m, parent)) {
 
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
+		struct mount *child = NULL, *p;
+
+		for (p = __lookup_mnt(&m->mnt, mnt->mnt_mountpoint); p;
+		     p = __lookup_mnt_cont(p, &m->mnt, mnt->mnt_mountpoint)) {
+			/*
+			 * Do this work only once for mounts from
+			 * the same propagation chain.
+			 */
+			if (p->mnt.mnt_flags & MNT_UMOUNT) {
+				CLEAR_MNT_MARK(p);
+				continue;
+			}
+			child = p;
+		}
 		/*
 		 * umount the child only if the child has no children
 		 * and the child is marked safe to unmount.
-- 
2.5.5
