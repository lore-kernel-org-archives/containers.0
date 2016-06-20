From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 12/13] userns: Remove implicit MNT_NODEV fragility.
Date: Mon, 20 Jun 2016 12:21:29 -0500
Message-ID: <20160620172130.15712-12-ebiederm@xmission.com>
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

Replace the implict setting of MNT_NODEV on mounts that happen with
just user namespace permissions with an implicit setting of SB_I_NODEV
in s_iflags.  The visibility of the implicit MNT_NODEV has caused
problems in the past.

With this change the fragile case where an implicit MNT_NODEV needs to
be preserved in do_remount is removed.  Using SB_I_NODEV is much less
fragile as s_iflags are set during the original mount and never
changed.

In do_new_mount with the implicit setting of MNT_NODEV gone, the only
code that can affect mnt_flags is fs_fully_visible so simplify the if
statement and reduce the indentation of the code to make that clear.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 19 +------------------
 fs/super.c     |  3 +++
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index b1da7f8182c4..9786a38d1681 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2185,13 +2185,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	}
 	if ((mnt->mnt.mnt_flags & MNT_LOCK_NODEV) &&
 	    !(mnt_flags & MNT_NODEV)) {
-		/* Was the nodev implicitly added in mount? */
-		if ((mnt->mnt_ns->user_ns != &init_user_ns) &&
-		    !(sb->s_type->fs_flags & FS_USERNS_DEV_MOUNT)) {
-			mnt_flags |= MNT_NODEV;
-		} else {
-			return -EPERM;
-		}
+		return -EPERM;
 	}
 	if ((mnt->mnt.mnt_flags & MNT_LOCK_NOSUID) &&
 	    !(mnt_flags & MNT_NOSUID)) {
@@ -2385,7 +2379,6 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
 	struct file_system_type *type;
-	struct user_namespace *user_ns = current->nsproxy->mnt_ns->user_ns;
 	struct vfsmount *mnt;
 	int err;
 
@@ -2396,16 +2389,6 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 	if (!type)
 		return -ENODEV;
 
-	if (user_ns != &init_user_ns) {
-		/* Only in special cases allow devices from mounts
-		 * created outside the initial user namespace.
-		 */
-		if (!(type->fs_flags & FS_USERNS_DEV_MOUNT)) {
-			flags |= MS_NODEV;
-			mnt_flags |= MNT_NODEV | MNT_LOCK_NODEV;
-		}
-	}
-
 	mnt = vfs_kern_mount(type, flags, name, data);
 	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
 	    !mnt->mnt_sb->s_subtype)
diff --git a/fs/super.c b/fs/super.c
index 78790ada7191..25cdceed2ad3 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -206,6 +206,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	init_waitqueue_head(&s->s_writers.wait_unfrozen);
 	s->s_bdi = &noop_backing_dev_info;
 	s->s_flags = flags;
+	if ((s->s_user_ns != &init_user_ns) &&
+	    !(type->fs_flags & FS_USERNS_DEV_MOUNT))
+		s->s_iflags |= SB_I_NODEV;
 	INIT_HLIST_NODE(&s->s_instances);
 	INIT_HLIST_BL_HEAD(&s->s_anon);
 	mutex_init(&s->s_sync_lock);
-- 
2.8.3
