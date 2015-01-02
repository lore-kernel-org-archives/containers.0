From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 4/9] mnt: Add MNT_UMOUNT flag
Date: Fri,  2 Jan 2015 15:52:49 -0600
Message-ID: <1420235574-15177-4-git-send-email-ebiederm__5566.10306161946$1420235769$gmane$org@xmission.com>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tncuaf6.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

In some instances it is necessary to know if the the unmounting
process has begun on a mount.  Add MNT_UMOUNT to make that reliably
testable.

This fix gets used in fixing locked mounts in MNT_DETACH

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c        | 4 +++-
 fs/pnode.c            | 1 +
 include/linux/mount.h | 1 +
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 44478b6e3719..60d4160cd2f4 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1336,8 +1336,10 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 	struct mount *p;
 
 	/* Gather the mounts to umount */
-	for (p = mnt; p; p = next_mnt(p, mnt))
+	for (p = mnt; p; p = next_mnt(p, mnt)) {
+		p->mnt.mnt_flags |= MNT_UMOUNT;
 		list_move(&p->mnt_list, &tmp_list);
+	}
 
 	/* Hide the mounts from lookup_mnt and mnt_mounts */
 	list_for_each_entry(p, &tmp_list, mnt_list) {
diff --git a/fs/pnode.c b/fs/pnode.c
index bf012af709dd..ac3aa0d43b90 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -384,6 +384,7 @@ static void __propagate_umount(struct mount *mnt)
 		if (child && list_empty(&child->mnt_mounts)) {
 			list_del_init(&child->mnt_child);
 			hlist_del_init_rcu(&child->mnt_hash);
+			child->mnt.mnt_flags |= MNT_UMOUNT;
 			list_move_tail(&child->mnt_list, &mnt->mnt_list);
 		}
 	}
diff --git a/include/linux/mount.h b/include/linux/mount.h
index c2c561dc0114..564beeec5d83 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -61,6 +61,7 @@ struct mnt_namespace;
 #define MNT_DOOMED		0x1000000
 #define MNT_SYNC_UMOUNT		0x2000000
 #define MNT_MARKED		0x4000000
+#define MNT_UMOUNT		0x8000000
 
 struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
-- 
2.2.1
