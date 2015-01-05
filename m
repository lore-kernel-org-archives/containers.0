From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/11] mnt: Don't propagate unmounts to locked mounts
Date: Mon,  5 Jan 2015 14:46:26 -0600
Message-ID: <1420490787-14387-10-git-send-email-ebiederm__35882.7297496193$1420491064$gmane$org@xmission.com>
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

If the first mount in shared subtree is locked don't unmount the
shared subtree.

This is ensured by walking through the mounts parents before children
and marking a mount as unmountable if it is not locked or it is locked
but it's parent is marked.

This allows recursive mount detach to propagate through a set of
mounts when unmounting them would not reveal what is under any locked
mount.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/pnode.c | 32 +++++++++++++++++++++++++++++---
 fs/pnode.h |  1 +
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/fs/pnode.c b/fs/pnode.c
index 89890293dd0a..6367e1e435c6 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -382,6 +382,26 @@ void propagate_mount_unlock(struct mount *mnt)
 }
 
 /*
+ * Mark all mounts that the MNT_LOCKED logic will allow to be unmounted.
+ */
+static void mark_umount_candidates(struct mount *mnt)
+{
+	struct mount *parent = mnt->mnt_parent;
+	struct mount *m;
+
+	BUG_ON(parent == mnt);
+
+	for (m = propagation_next(parent, parent); m;
+			m = propagation_next(m, parent)) {
+		struct mount *child = __lookup_mnt_last(&m->mnt,
+						mnt->mnt_mountpoint);
+		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
+			SET_MNT_MARK(child);
+		}
+	}
+}
+
+/*
  * NOTE: unmounting 'mnt' naturally propagates to all other mounts its
  * parent propagates to.
  */
@@ -398,10 +418,13 @@ static void __propagate_umount(struct mount *mnt)
 		struct mount *child = __lookup_mnt_last(&m->mnt,
 						mnt->mnt_mountpoint);
 		/*
-		 * umount the child only if the child has no
-		 * other children
+		 * umount the child only if the child has no children
+		 * and the child is marked safe to unmount.
 		 */
-		if (child && list_empty(&child->mnt_mounts)) {
+		if (!child || !IS_MNT_MARKED(child))
+			continue;
+		CLEAR_MNT_MARK(child);
+		if (list_empty(&child->mnt_mounts)) {
 			list_del_init(&child->mnt_child);
 			child->mnt.mnt_flags |= MNT_UMOUNT;
 			list_move_tail(&child->mnt_list, &mnt->mnt_list);
@@ -420,6 +443,9 @@ int propagate_umount(struct list_head *list)
 {
 	struct mount *mnt;
 
+	list_for_each_entry_reverse(mnt, list, mnt_list)
+		mark_umount_candidates(mnt);
+
 	list_for_each_entry(mnt, list, mnt_list)
 		__propagate_umount(mnt);
 	return 0;
diff --git a/fs/pnode.h b/fs/pnode.h
index af47d4bd7b31..0fcdbe7ca648 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -19,6 +19,7 @@
 #define IS_MNT_MARKED(m) ((m)->mnt.mnt_flags & MNT_MARKED)
 #define SET_MNT_MARK(m) ((m)->mnt.mnt_flags |= MNT_MARKED)
 #define CLEAR_MNT_MARK(m) ((m)->mnt.mnt_flags &= ~MNT_MARKED)
+#define IS_MNT_LOCKED(m) ((m)->mnt.mnt_flags & MNT_LOCKED)
 
 #define CL_EXPIRE    		0x01
 #define CL_SLAVE     		0x02
-- 
2.2.1
