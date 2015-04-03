From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 18/19] vfs: Handle mounts whose parents are unreachable
	from their mountpoint
Date: Thu,  2 Apr 2015 20:56:22 -0500
Message-ID: <1428026183-14879-18-git-send-email-ebiederm__43079.7664485455$1428026516$gmane$org@xmission.com>
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

- Add a mount flag MNT_UNREACHABLE_PARENT to mark mounts that can not
  reach their parent mount's root from their mountpoint.

- In follup_up and follow_up_rcu don't follow up if the current
  mount's mountpoint can not reach the parent mount's root.

- In prepend_path and it's callers in the d_path family don't follow
  to the parent mount if the current mount's mountpoint can not reach
  the parent mount's root.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c           | 3 ++-
 fs/namei.c            | 4 ++--
 include/linux/mount.h | 1 +
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index e07eb03f6de6..cae4a42c1846 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2893,7 +2893,8 @@ restart:
 		if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
 			struct mount *parent = ACCESS_ONCE(mnt->mnt_parent);
 			/* Global root? */
-			if (mnt != parent) {
+			if ((mnt != parent) &&
+			    !(mnt->mnt.mnt_flags & MNT_UNREACHABLE_PARENT)) {
 				dentry = ACCESS_ONCE(mnt->mnt_mountpoint);
 				mnt = parent;
 				vfsmnt = &mnt->mnt;
diff --git a/fs/namei.c b/fs/namei.c
index ec09c90089a9..31a9c9a5787d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -938,7 +938,7 @@ static int follow_up_rcu(struct path *path)
 	struct dentry *mountpoint;
 
 	parent = mnt->mnt_parent;
-	if (&parent->mnt == path->mnt)
+	if ((mnt->mnt.mnt_flags & MNT_UNREACHABLE_PARENT) || (parent == mnt))
 		return 0;
 	mountpoint = mnt->mnt_mountpoint;
 	path->dentry = mountpoint;
@@ -964,7 +964,7 @@ int follow_up(struct path *path)
 
 	read_seqlock_excl(&mount_lock);
 	parent = mnt->mnt_parent;
-	if (parent == mnt) {
+	if ((mnt->mnt.mnt_flags & MNT_UNREACHABLE_PARENT) || (parent == mnt)) {
 		read_sequnlock_excl(&mount_lock);
 		return 0;
 	}
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 778d7cf65b9a..3249da1af130 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -63,6 +63,7 @@ struct mnt_namespace;
 #define MNT_MARKED		0x4000000
 #define MNT_UMOUNT		0x8000000
 #define MNT_VIOLATED		0x10000000
+#define MNT_UNREACHABLE_PARENT	0x20000000
 
 struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
-- 
2.2.1
