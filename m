From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 18/25] userns: Convert nillfs2 to use kuid/kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:59 -0700
Message-ID: <1348141326-23355-18-git-send-email-ebiederm@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, KONISHI Ryusuke <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: KONISHI Ryusuke <konishi.ryusuke-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nilfs2/inode.c |    8 ++++----
 init/Kconfig      |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 6e2c3db..4d31d2c 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -401,8 +401,8 @@ int nilfs_read_inode_common(struct inode *inode,
 	int err;
 
 	inode->i_mode = le16_to_cpu(raw_inode->i_mode);
-	inode->i_uid = (uid_t)le32_to_cpu(raw_inode->i_uid);
-	inode->i_gid = (gid_t)le32_to_cpu(raw_inode->i_gid);
+	i_uid_write(inode, le32_to_cpu(raw_inode->i_uid));
+	i_gid_write(inode, le32_to_cpu(raw_inode->i_gid));
 	set_nlink(inode, le16_to_cpu(raw_inode->i_links_count));
 	inode->i_size = le64_to_cpu(raw_inode->i_size);
 	inode->i_atime.tv_sec = le64_to_cpu(raw_inode->i_mtime);
@@ -590,8 +590,8 @@ void nilfs_write_inode_common(struct inode *inode,
 	struct nilfs_inode_info *ii = NILFS_I(inode);
 
 	raw_inode->i_mode = cpu_to_le16(inode->i_mode);
-	raw_inode->i_uid = cpu_to_le32(inode->i_uid);
-	raw_inode->i_gid = cpu_to_le32(inode->i_gid);
+	raw_inode->i_uid = cpu_to_le32(i_uid_read(inode));
+	raw_inode->i_gid = cpu_to_le32(i_gid_read(inode));
 	raw_inode->i_links_count = cpu_to_le16(inode->i_nlink);
 	raw_inode->i_size = cpu_to_le64(inode->i_size);
 	raw_inode->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
diff --git a/init/Kconfig b/init/Kconfig
index c69e085..90c9e06 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -949,7 +949,6 @@ config UIDGID_CONVERTED
 	depends on NCP_FS = n
 	depends on NFSD = n
 	depends on NFS_FS = n
-	depends on NILFS2_FS = n
 	depends on NTFS_FS = n
 	depends on OCFS2_FS = n
 	depends on OMFS_FS = n
-- 
1.7.5.4
