From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 11/13] mnt: Simplify mount_too_revealing
Date: Mon, 20 Jun 2016 12:21:28 -0500
Message-ID: <20160620172130.15712-11-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Verify all filesystems that we check in mount_too_revealing set
SB_I_NOEXEC and SB_I_NODEV in sb->s_iflags.  That is true for today
and it should remain true in the future.

Remove the now unnecessary checks from mnt_already_visibile that
ensure MNT_LOCK_NOSUID, MNT_LOCK_NOEXEC, and MNT_LOCK_NODEV are
preserved.  Making the code shorter and easier to read.

Relying on SB_I_NOEXEC and SB_I_NODEV instead of the user visible
MNT_NOSUID, MNT_NOEXEC, and MNT_NODEV ensures the many current
systems where proc and sysfs are mounted with "nosuid, nodev, noexec"
and several slightly buggy container applications don't bother to
set those flags continue to work.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 2e13f6cfe5df..b1da7f8182c4 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3232,12 +3232,8 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 		if (mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
 			continue;
 
-		/* Read the mount flags and filter out flags that
-		 * may safely be ignored.
-		 */
+		/* A local view of the mount flags */
 		mnt_flags = mnt->mnt.mnt_flags;
-		if (mnt->mnt.mnt_sb->s_iflags & SB_I_NOEXEC)
-			mnt_flags &= ~(MNT_LOCK_NOSUID | MNT_LOCK_NOEXEC);
 
 		/* Don't miss readonly hidden in the superblock flags */
 		if (mnt->mnt.mnt_sb->s_flags & MS_RDONLY)
@@ -3249,15 +3245,6 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 		if ((mnt_flags & MNT_LOCK_READONLY) &&
 		    !(new_flags & MNT_READONLY))
 			continue;
-		if ((mnt_flags & MNT_LOCK_NODEV) &&
-		    !(new_flags & MNT_NODEV))
-			continue;
-		if ((mnt_flags & MNT_LOCK_NOSUID) &&
-		    !(new_flags & MNT_NOSUID))
-			continue;
-		if ((mnt_flags & MNT_LOCK_NOEXEC) &&
-		    !(new_flags & MNT_NOEXEC))
-			continue;
 		if ((mnt_flags & MNT_LOCK_ATIME) &&
 		    ((mnt_flags & MNT_ATIME_MASK) != (new_flags & MNT_ATIME_MASK)))
 			continue;
@@ -3277,9 +3264,6 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 		}
 		/* Preserve the locked attributes */
 		*new_mnt_flags |= mnt_flags & (MNT_LOCK_READONLY | \
-					       MNT_LOCK_NODEV    | \
-					       MNT_LOCK_NOSUID   | \
-					       MNT_LOCK_NOEXEC   | \
 					       MNT_LOCK_ATIME);
 		visible = true;
 		goto found;
@@ -3292,6 +3276,7 @@ found:
 
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags)
 {
+	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
 	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
 	unsigned long s_iflags;
 
@@ -3303,6 +3288,12 @@ static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags)
 	if (!(s_iflags & SB_I_USERNS_VISIBLE))
 		return false;
 
+	if ((s_iflags & required_iflags) != required_iflags) {
+		WARN_ONCE(1, "Expected s_iflags to contain 0x%lx\n",
+			  required_iflags);
+		return true;
+	}
+
 	return !mnt_already_visible(ns, mnt, new_mnt_flags);
 }
 
-- 
2.8.3
