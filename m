From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH tty-next 6/6] devpts: Change the owner of /dev/pts/ptmx to the
	mounter of /dev/pts
Date: Wed, 14 Sep 2016 13:53:38 -0500
Message-ID: <20160914185338.15126-6-ebiederm__31533.8508029983$1473880108$gmane$org@xmission.com>
References: <87sht25n73.fsf@x220.int.ebiederm.org>
	<20160914185338.15126-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160914185338.15126-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

In 99.99% of the cases only root in a user namespace can mount /dev/pts
and in those cases the owner of /dev/pts/ptmx will remain root.root

In the oddball case where someone else has CAP_SYS_ADMIN this code
modifies the /dev/pts mount code to use current_fsuid and current_fsgid
as the values to use when creating the /dev/ptmx inode.  As is done
when any other file is created.

This is a code simplification, and it allows running without a root
user entirely.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 17593d3fcdbe..442d1a7e671b 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -272,13 +272,8 @@ static int mknod_ptmx(struct super_block *sb)
 	struct dentry *root = sb->s_root;
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
-	kuid_t root_uid;
-	kgid_t root_gid;
-
-	root_uid = make_kuid(current_user_ns(), 0);
-	root_gid = make_kgid(current_user_ns(), 0);
-	if (!uid_valid(root_uid) || !gid_valid(root_gid))
-		return -EINVAL;
+	kuid_t ptmx_uid = current_fsuid();
+	kgid_t ptmx_gid = current_fsgid();
 
 	inode_lock(d_inode(root));
 
@@ -309,8 +304,8 @@ static int mknod_ptmx(struct super_block *sb)
 
 	mode = S_IFCHR|opts->ptmxmode;
 	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
-	inode->i_uid = root_uid;
-	inode->i_gid = root_gid;
+	inode->i_uid = ptmx_uid;
+	inode->i_gid = ptmx_gid;
 
 	d_add(dentry, inode);
 
-- 
2.8.3
