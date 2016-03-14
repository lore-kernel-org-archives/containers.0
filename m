From: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] devpts: Make ptmx be owned by the userns owner instead of
	userns-local 0
Date: Sun, 13 Mar 2016 22:06:15 -0700
Message-ID: <fd99f5e7144be5de87c88e069cd5edb36136eefd.1457931898.git.luto@kernel.org>
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
To: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

We used to have ptmx be owned by the inner uid and gid 0.  Change
this: if the owner and group are both mapped but are not both 0,
then use the owner instead.

For container-style namespaces (LXC, etc), this should have no
effect -- UID 0 is will either be the owner or will be unmapped.

The important behavior change is for sandboxes: many sandboxes
intentionally do not create an inner uid 0.  Without this patch,
mounting devpts in such a sandbox is awkward.  With this patch, it
will just work and ptmx will be owned by the namespace owner.

Cc: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Signed-off-by: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 fs/devpts/inode.c | 34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 655f21f99160..d6fa2d1beee3 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -27,6 +27,7 @@
 #include <linux/parser.h>
 #include <linux/fsnotify.h>
 #include <linux/seq_file.h>
+#include <linux/user_namespace.h>
 
 #define DEVPTS_DEFAULT_MODE 0600
 /*
@@ -250,10 +251,35 @@ static int mknod_ptmx(struct super_block *sb)
 	kuid_t root_uid;
 	kgid_t root_gid;
 
-	root_uid = make_kuid(current_user_ns(), 0);
-	root_gid = make_kgid(current_user_ns(), 0);
-	if (!uid_valid(root_uid) || !gid_valid(root_gid))
-		return -EINVAL;
+	/*
+	 * For a new devpts instance, ptmx is owned by the creating user
+	 * namespace's owner.  Usually, that will be 0 as seen by the
+	 * user namespace, but for unprivileged sandbox namespaces,
+	 * there may not be a uid 0 or gid 0 at all.
+	 */
+	root_uid = current_user_ns()->owner;
+	root_gid = current_user_ns()->group;
+
+	if (!uid_valid(root_uid) || !gid_valid(root_gid)) {
+		/*
+		 * It's very unlikely for us to get here if the userns
+		 * owner is not mapped, but it's possible -- we'd have
+		 * to be running in the userns with capabilities granted
+		 * by unshare or setns, since there is no inner
+		 * privileged user.  Nonetheless, this could happen, and
+		 * we don't want ptmx to be owned by an unmapped user or
+		 * group.
+		 *
+		 * If this happens fall back to historical behavior:
+		 * try to have ptmx be owned by 0:0.
+		 */
+		root_uid = make_kuid(current_user_ns(), 0);
+		root_gid = make_kgid(current_user_ns(), 0);
+
+		/* If this still doesn't work, give up. */
+		if (!uid_valid(root_uid) || !gid_valid(root_gid))
+			return -EINVAL;
+	}
 
 	inode_lock(d_inode(root));
 
-- 
2.5.0
