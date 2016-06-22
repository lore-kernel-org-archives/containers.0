From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] userns related changes for 4.7-rc5
Date: Wed, 22 Jun 2016 13:47:55 -0500
Message-ID: <87bn2tnjqc.fsf@x220.int.ebiederm.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 695e9df010e40f407f4830dc11d53dce957710ba mnt: Account for MS_RDONLY in fs_fully_visible

This contains just a single small patch that fixes a tiny hole in the
logic of allowing unprivileged mounting of proc and sysfs.  In practice
I don't think anyone is affected because having MNT_RDONLY clear in
mnt->mnt_flags but MS_RDONLY set in sb->s_flags is very weird for a
filesystem, and weirder for proc and sysfs.  However if it happens let's
handle it correctly and then no one has to to worry about this crazy
case.

Eric

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH] mnt: Account for MS_RDONLY in fs_fully_visible

In rare cases it is possible for s_flags & MS_RDONLY to be set but
MNT_READONLY to be clear.  This starting combination can cause
fs_fully_visible to fail to ensure that the new mount is readonly.
Therefore force MNT_LOCK_READONLY in the new mount if MS_RDONLY
is set on the source filesystem of the mount.

In general both MS_RDONLY and MNT_READONLY are set at the same for
mounts so I don't expect any programs to care.  Nor do I expect
MS_RDONLY to be set on proc or sysfs in the initial user namespace,
which further decreases the likelyhood of problems.

Which means this change should only affect system configurations by
paranoid sysadmins who should welcome the additional protection
as it keeps people from wriggling out of their policies.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Fixes: 8c6cf9cc829f ("mnt: Modify fs_fully_visible to deal with locked ro nodev and atime")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index a7ec92c051f5..783004af5707 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3247,6 +3247,10 @@ static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
 		if (mnt->mnt.mnt_sb->s_iflags & SB_I_NOEXEC)
 			mnt_flags &= ~(MNT_LOCK_NOSUID | MNT_LOCK_NOEXEC);
 
+		/* Don't miss readonly hidden in the superblock flags */
+		if (mnt->mnt.mnt_sb->s_flags & MS_RDONLY)
+			mnt_flags |= MNT_LOCK_READONLY;
+
 		/* Verify the mount flags are equal to or more permissive
 		 * than the proposed new mount.
 		 */
-- 
2.8.3
