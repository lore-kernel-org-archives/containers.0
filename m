From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review  11/19] mnt: Factor umount_mnt from umount_tree
Date: Thu,  2 Apr 2015 20:56:15 -0500
Message-ID: <1428026183-14879-11-git-send-email-ebiederm__38025.3925141462$1428026572$gmane$org@xmission.com>
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

For future use factor out a function umount_mnt from umount_tree.
This function unhashes a mount and remembers where the mount
was mounted so that eventually when the code makes it to a
sleeping context the mountpoint can be dput.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index e669a3bf86e7..010d5bebcb7e 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -822,6 +822,16 @@ static void detach_mnt(struct mount *mnt, struct path *old_path)
 /*
  * vfsmount lock must be held for write
  */
+static void umount_mnt(struct mount *mnt)
+{
+	/* old mountpoint will be dropped when we can do that */
+	mnt->mnt_ex_mountpoint = mnt->mnt_mountpoint;
+	unhash_mnt(mnt);
+}
+
+/*
+ * vfsmount lock must be held for write
+ */
 void mnt_set_mountpoint(struct mount *mnt,
 			struct mountpoint *mp,
 			struct mount *child_mnt)
@@ -1371,9 +1381,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
 		if (mnt_has_parent(p)) {
 			mnt_add_count(p->mnt_parent, -1);
-			/* old mountpoint will be dropped when we can do that */
-			p->mnt_ex_mountpoint = p->mnt_mountpoint;
-			unhash_mnt(p);
+			umount_mnt(p);
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
-- 
2.2.1
