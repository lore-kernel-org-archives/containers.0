From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 15/19] mnt: Update detach_mounts to leave mounts
	connected
Date: Thu,  2 Apr 2015 20:56:19 -0500
Message-ID: <1428026183-14879-15-git-send-email-ebiederm__43350.7430986085$1428026530$gmane$org@xmission.com>
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

Now that it is possible to lazily unmount an entire mount tree and
leave the individual mounts connected to each other add a new flag
UMOUNT_CONNECTED to umount_tree to force this behavior and use
this flag in detach_mounts.

This closes a bug where the deletion of a file or directory could
trigger an unmount and reveal data under a mount point.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index e8f7f8c58c3c..1f4f9dac6e5a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1348,6 +1348,7 @@ static inline void namespace_lock(void)
 enum umount_tree_flags {
 	UMOUNT_SYNC = 1,
 	UMOUNT_PROPAGATE = 2,
+	UMOUNT_CONNECTED = 4,
 };
 /*
  * mount_lock must be held
@@ -1386,7 +1387,10 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		if (how & UMOUNT_SYNC)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 
-		disconnect = !IS_MNT_LOCKED_AND_LAZY(p);
+		disconnect = !(((how & UMOUNT_CONNECTED) &&
+				mnt_has_parent(p) &&
+				(p->mnt_parent->mnt.mnt_flags & MNT_UMOUNT)) ||
+			       IS_MNT_LOCKED_AND_LAZY(p));
 
 		pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt,
 				 disconnect ? &unmounted : NULL);
@@ -1529,7 +1533,7 @@ void __detach_mounts(struct dentry *dentry)
 				umount_mnt(p);
 			}
 		}
-		else umount_tree(mnt, 0);
+		else umount_tree(mnt, UMOUNT_CONNECTED);
 	}
 	unlock_mount_hash();
 	put_mountpoint(mp);
-- 
2.2.1
