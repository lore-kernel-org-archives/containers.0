From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 07/13] mnt: Move the FS_USERNS_MOUNT check into
	sget_userns
Date: Mon, 20 Jun 2016 12:21:24 -0500
Message-ID: <20160620172130.15712-7-ebiederm@xmission.com>
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

Allowing a filesystem to be mounted by other than root in the initial
user namespace is a filesystem property not a mount namespace property
and as such should be checked in filesystem specific code.  Move the
FS_USERNS_MOUNT test into super.c:sget_userns().

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 4 ----
 fs/super.c     | 4 ++++
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 1a69aa786975..2e13f6cfe5df 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2397,10 +2397,6 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 		return -ENODEV;
 
 	if (user_ns != &init_user_ns) {
-		if (!(type->fs_flags & FS_USERNS_MOUNT)) {
-			put_filesystem(type);
-			return -EPERM;
-		}
 		/* Only in special cases allow devices from mounts
 		 * created outside the initial user namespace.
 		 */
diff --git a/fs/super.c b/fs/super.c
index 874c7e3ebb8f..78790ada7191 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -466,6 +466,10 @@ struct super_block *sget_userns(struct file_system_type *type,
 	struct super_block *old;
 	int err;
 
+	if (!(flags & MS_KERNMOUNT) &&
+	    !(type->fs_flags & FS_USERNS_MOUNT) &&
+	    !capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
 retry:
 	spin_lock(&sb_lock);
 	if (test) {
-- 
2.8.3
