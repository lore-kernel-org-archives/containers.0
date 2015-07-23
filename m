From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace: Infinite loop bugfixes for 4.2-rc4
Date: Thu, 23 Jul 2015 11:52:48 -0500
Message-ID: <87r3nyak9r.fsf@x220.int.ebiederm.org>
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: fe78fcc85a2046c51f1535710996860557eeec20 mnt: In detach_mounts detach the appropriate unmounted mount

While reading through the code of detach_mounts I realized the code was
a slightly off.  Testing it revealed two buggy corner cases that can send
the code of detach_mounts into an infinite loop.  Fixing the code to do
the right thing removes the possibility of these user triggered infinite
loops in the code.

Eric W. Biederman (2):
      mnt: Clarify and correct the disconnect logic in umount_tree
      mnt: In detach_mounts detach the appropriate unmounted mount

 fs/namespace.c | 42 +++++++++++++++++++++++++++++++++---------
 fs/pnode.h     |  2 --
 2 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c7cb8a526c05..2b8aa15fd6df 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1361,6 +1361,36 @@ enum umount_tree_flags {
 	UMOUNT_PROPAGATE = 2,
 	UMOUNT_CONNECTED = 4,
 };
+
+static bool disconnect_mount(struct mount *mnt, enum umount_tree_flags how)
+{
+	/* Leaving mounts connected is only valid for lazy umounts */
+	if (how & UMOUNT_SYNC)
+		return true;
+
+	/* A mount without a parent has nothing to be connected to */
+	if (!mnt_has_parent(mnt))
+		return true;
+
+	/* Because the reference counting rules change when mounts are
+	 * unmounted and connected, umounted mounts may not be
+	 * connected to mounted mounts.
+	 */
+	if (!(mnt->mnt_parent->mnt.mnt_flags & MNT_UMOUNT))
+		return true;
+
+	/* Has it been requested that the mount remain connected? */
+	if (how & UMOUNT_CONNECTED)
+		return false;
+
+	/* Is the mount locked such that it needs to remain connected? */
+	if (IS_MNT_LOCKED(mnt))
+		return false;
+
+	/* By default disconnect the mount */
+	return true;
+}
+
 /*
  * mount_lock must be held
  * namespace_sem must be held for write
@@ -1398,10 +1428,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		if (how & UMOUNT_SYNC)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 
-		disconnect = !(((how & UMOUNT_CONNECTED) &&
-				mnt_has_parent(p) &&
-				(p->mnt_parent->mnt.mnt_flags & MNT_UMOUNT)) ||
-			       IS_MNT_LOCKED_AND_LAZY(p));
+		disconnect = disconnect_mount(p, how);
 
 		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt,
 				 disconnect ? &unmounted : NULL);
@@ -1538,11 +1565,8 @@ void __detach_mounts(struct dentry *dentry)
 	while (!hlist_empty(&mp->m_list)) {
 		mnt = hlist_entry(mp->m_list.first, struct mount, mnt_mp_list);
 		if (mnt->mnt.mnt_flags & MNT_UMOUNT) {
-			struct mount *p, *tmp;
-			list_for_each_entry_safe(p, tmp, &mnt->mnt_mounts,  mnt_child) {
-				hlist_add_head(&p->mnt_umount.s_list, &unmounted);
-				umount_mnt(p);
-			}
+			hlist_add_head(&mnt->mnt_umount.s_list, &unmounted);
+			umount_mnt(mnt);
 		}
 		else umount_tree(mnt, UMOUNT_CONNECTED);
 	}
diff --git a/fs/pnode.h b/fs/pnode.h
index 7114ce6e6b9e..0fcdbe7ca648 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -20,8 +20,6 @@
 #define SET_MNT_MARK(m) ((m)->mnt.mnt_flags |= MNT_MARKED)
 #define CLEAR_MNT_MARK(m) ((m)->mnt.mnt_flags &= ~MNT_MARKED)
 #define IS_MNT_LOCKED(m) ((m)->mnt.mnt_flags & MNT_LOCKED)
-#define IS_MNT_LOCKED_AND_LAZY(m) \
-	(((m)->mnt.mnt_flags & (MNT_LOCKED|MNT_SYNC_UMOUNT)) == MNT_LOCKED)
 
 #define CL_EXPIRE    		0x01
 #define CL_SLAVE     		0x02
