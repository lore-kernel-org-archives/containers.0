From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/11] userns: Convert bfs to use kuid/kgid where appropriate
Date: Fri, 21 Sep 2012 18:35:03 -0700
Message-ID: <1348277712-30055-2-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Tigran A. Aivazian" <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: "Tigran A. Aivazian" <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/bfs/inode.c |    8 ++++----
 init/Kconfig   |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 9870417..b242beb 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -76,8 +76,8 @@ struct inode *bfs_iget(struct super_block *sb, unsigned long ino)
 	BFS_I(inode)->i_sblock =  le32_to_cpu(di->i_sblock);
 	BFS_I(inode)->i_eblock =  le32_to_cpu(di->i_eblock);
 	BFS_I(inode)->i_dsk_ino = le16_to_cpu(di->i_ino);
-	inode->i_uid =  le32_to_cpu(di->i_uid);
-	inode->i_gid =  le32_to_cpu(di->i_gid);
+	i_uid_write(inode, le32_to_cpu(di->i_uid));
+	i_gid_write(inode,  le32_to_cpu(di->i_gid));
 	set_nlink(inode, le32_to_cpu(di->i_nlink));
 	inode->i_size = BFS_FILESIZE(di);
 	inode->i_blocks = BFS_FILEBLOCKS(di);
@@ -139,8 +139,8 @@ static int bfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 
 	di->i_ino = cpu_to_le16(ino);
 	di->i_mode = cpu_to_le32(inode->i_mode);
-	di->i_uid = cpu_to_le32(inode->i_uid);
-	di->i_gid = cpu_to_le32(inode->i_gid);
+	di->i_uid = cpu_to_le32(i_uid_read(inode));
+	di->i_gid = cpu_to_le32(i_gid_read(inode));
 	di->i_nlink = cpu_to_le32(inode->i_nlink);
 	di->i_atime = cpu_to_le32(inode->i_atime.tv_sec);
 	di->i_mtime = cpu_to_le32(inode->i_mtime.tv_sec);
diff --git a/init/Kconfig b/init/Kconfig
index a358f4a..fd91d2b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -930,7 +930,6 @@ config UIDGID_CONVERTED
 	depends on 9P_FS = n
 	depends on AFS_FS = n
 	depends on AUTOFS4_FS = n
-	depends on BFS_FS = n
 	depends on BTRFS_FS = n
 	depends on CEPH_FS = n
 	depends on CIFS = n
-- 
1.7.5.4
