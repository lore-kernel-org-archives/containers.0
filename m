From: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2] devpts: Make ptmx be owned by the userns owner as a
	fallback
Date: Tue, 15 Mar 2016 13:05:13 -0700
Message-ID: <820e57306e342ca310414ed0f58e75ac99731871.1458072215.git.luto@kernel.org>
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
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

New devpts instances have ptmx owned by the inner uid and gid 0.

For container-style namespaces (LXC, etc), this should have no
effect, this is fine.

For sandbox-style namespaces (xdg-app and similar), this is
problematic -- there may not be an inner 0:0.  If that happens,
devpts mounts will fail.

Fix it by adding a fallback: if 0:0 is not mapped but the userns
owner and group are mapped, then ptmx will be owned by the namespace
owner.

This won't change behavior except in cases where mount would
currently return -EINVAL.

Cc: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Signed-off-by: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---

Changes from v1:
 - Reversed the preference order (Serge)
 - Fixed misuse of uid_valid on userns->owner

fs/devpts/inode.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 655f21f99160..42b1e04d8334 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -27,6 +27,7 @@
 #include <linux/parser.h>
 #include <linux/fsnotify.h>
 #include <linux/seq_file.h>
+#include <linux/user_namespace.h>
 
 #define DEVPTS_DEFAULT_MODE 0600
 /*
@@ -247,13 +248,33 @@ static int mknod_ptmx(struct super_block *sb)
 	struct dentry *root = sb->s_root;
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
+	struct user_namespace *userns = current_user_ns();
 	kuid_t root_uid;
 	kgid_t root_gid;
 
-	root_uid = make_kuid(current_user_ns(), 0);
-	root_gid = make_kgid(current_user_ns(), 0);
-	if (!uid_valid(root_uid) || !gid_valid(root_gid))
-		return -EINVAL;
+	/*
+	 * For a new devpts instance, ptmx is owned by 0:0 if that uid
+	 * and gid are mapped in the creating namespace.
+	 */
+	root_uid = make_kuid(userns, 0);
+	root_gid = make_kgid(userns, 0);
+
+	if (!uid_valid(root_uid) || !gid_valid(root_gid)) {
+		/*
+		 * If the creating namespace does not have 0:0 mapped
+		 * but does have the owner mapped (this is rare in
+		 * container-style namespaces but common in
+		 * sandbox-style namespaces), then let ptmx be owned by
+		 * the namespace owner.
+		 */
+		root_uid = userns->owner;
+		root_gid = userns->group;
+
+		/* If this still doesn't work, give up. */
+		if (!kuid_has_mapping(userns, root_uid) ||
+		    !kgid_has_mapping(userns, root_gid))
+			return -EINVAL;
+	}
 
 	inode_lock(d_inode(root));
 
-- 
2.5.0
