From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 01/13] mnt: Account for MS_RDONLY in fs_fully_visible
Date: Mon, 20 Jun 2016 12:21:18 -0500
Message-ID: <20160620172130.15712-1-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fus77pns.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
