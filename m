From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] userns related fixes for v4.7-rc3
Date: Tue, 07 Jun 2016 06:57:36 -0500
Message-ID: <874m95ky8f.fsf@x220.int.ebiederm.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: d71ed6c930ac7d8f88f3cef6624a7e826392d61f mnt: fs_fully_visible test the proper mount for MNT_LOCKED

This contains two small but significant fixes to fs/namespace.c.  The
first adds a drops the filesystem refcount drop on error.  The second
corrects a test in fs_fully_visible which could be abused to allow
mounting of proc or sysfs, when that should not be allowed.

To keep myself honest I have tested to ensure the incorrect test in
fs_fully_visible actually allows improper mounting of proc before the
fix and that when fixed the improper mounting is not allowed.

Eric W. Biederman (2):
      mnt: If fs_fully_visible fails call put_filesystem.
      mnt: fs_fully_visible test the proper mount for MNT_LOCKED

 fs/namespace.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 4fb1691b4355..a7ec92c051f5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2409,8 +2409,10 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 			mnt_flags |= MNT_NODEV | MNT_LOCK_NODEV;
 		}
 		if (type->fs_flags & FS_USERNS_VISIBLE) {
-			if (!fs_fully_visible(type, &mnt_flags))
+			if (!fs_fully_visible(type, &mnt_flags)) {
+				put_filesystem(type);
 				return -EPERM;
+			}
 		}
 	}
 
@@ -3271,7 +3273,7 @@ static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
 		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
 			struct inode *inode = child->mnt_mountpoint->d_inode;
 			/* Only worry about locked mounts */
-			if (!(mnt_flags & MNT_LOCKED))
+			if (!(child->mnt.mnt_flags & MNT_LOCKED))
 				continue;
 			/* Is the directory permanetly empty? */
 			if (!is_empty_dir_inode(inode))

Eric
