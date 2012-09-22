From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/11] userns: Convert the ufs filesystem to use kuid/kgid
	where appropriate
Date: Fri, 21 Sep 2012 18:35:12 -0700
Message-ID: <1348277712-30055-11-git-send-email-ebiederm@xmission.com>
References: <877grmj115.fsf@xmission.com>
	<1348277712-30055-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348277712-30055-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ufs/inode.c |   16 ++++++++--------
 init/Kconfig   |    1 -
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index dd7c89d..eb6d0b7 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -597,8 +597,8 @@ static int ufs1_read_inode(struct inode *inode, struct ufs_inode *ufs_inode)
 	/*
 	 * Linux now has 32-bit uid and gid, so we can support EFT.
 	 */
-	inode->i_uid = ufs_get_inode_uid(sb, ufs_inode);
-	inode->i_gid = ufs_get_inode_gid(sb, ufs_inode);
+	i_uid_write(inode, ufs_get_inode_uid(sb, ufs_inode));
+	i_gid_write(inode, ufs_get_inode_gid(sb, ufs_inode));
 
 	inode->i_size = fs64_to_cpu(sb, ufs_inode->ui_size);
 	inode->i_atime.tv_sec = fs32_to_cpu(sb, ufs_inode->ui_atime.tv_sec);
@@ -645,8 +645,8 @@ static int ufs2_read_inode(struct inode *inode, struct ufs2_inode *ufs2_inode)
         /*
          * Linux now has 32-bit uid and gid, so we can support EFT.
          */
-	inode->i_uid = fs32_to_cpu(sb, ufs2_inode->ui_uid);
-	inode->i_gid = fs32_to_cpu(sb, ufs2_inode->ui_gid);
+	i_uid_write(inode, fs32_to_cpu(sb, ufs2_inode->ui_uid));
+	i_gid_write(inode, fs32_to_cpu(sb, ufs2_inode->ui_gid));
 
 	inode->i_size = fs64_to_cpu(sb, ufs2_inode->ui_size);
 	inode->i_atime.tv_sec = fs64_to_cpu(sb, ufs2_inode->ui_atime);
@@ -745,8 +745,8 @@ static void ufs1_update_inode(struct inode *inode, struct ufs_inode *ufs_inode)
 	ufs_inode->ui_mode = cpu_to_fs16(sb, inode->i_mode);
 	ufs_inode->ui_nlink = cpu_to_fs16(sb, inode->i_nlink);
 
-	ufs_set_inode_uid(sb, ufs_inode, inode->i_uid);
-	ufs_set_inode_gid(sb, ufs_inode, inode->i_gid);
+	ufs_set_inode_uid(sb, ufs_inode, i_uid_read(inode));
+	ufs_set_inode_gid(sb, ufs_inode, i_gid_read(inode));
 		
 	ufs_inode->ui_size = cpu_to_fs64(sb, inode->i_size);
 	ufs_inode->ui_atime.tv_sec = cpu_to_fs32(sb, inode->i_atime.tv_sec);
@@ -789,8 +789,8 @@ static void ufs2_update_inode(struct inode *inode, struct ufs2_inode *ufs_inode)
 	ufs_inode->ui_mode = cpu_to_fs16(sb, inode->i_mode);
 	ufs_inode->ui_nlink = cpu_to_fs16(sb, inode->i_nlink);
 
-	ufs_inode->ui_uid = cpu_to_fs32(sb, inode->i_uid);
-	ufs_inode->ui_gid = cpu_to_fs32(sb, inode->i_gid);
+	ufs_inode->ui_uid = cpu_to_fs32(sb, i_uid_read(inode));
+	ufs_inode->ui_gid = cpu_to_fs32(sb, i_gid_read(inode));
 
 	ufs_inode->ui_size = cpu_to_fs64(sb, inode->i_size);
 	ufs_inode->ui_atime = cpu_to_fs64(sb, inode->i_atime.tv_sec);
diff --git a/init/Kconfig b/init/Kconfig
index 6f9819a..577916d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -939,7 +939,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on UFS_FS = n
 	depends on XFS_FS = n
 
 config UIDGID_STRICT_TYPE_CHECKS
-- 
1.7.5.4
