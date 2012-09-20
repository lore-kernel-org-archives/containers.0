From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 16/25] userns: Convert logfs to use kuid/kgid where appropriate
Date: Thu, 20 Sep 2012 04:41:57 -0700
Message-ID: <1348141326-23355-16-git-send-email-ebiederm__429.923370438878$1348143187$gmane$org@xmission.com>
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
Cc: Joern Engel <joern-PCqxUs/MD9bYtjvyW6yDsg@public.gmane.org>, Prasad Joshi <prasadjoshi.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Joern Engel <joern-PCqxUs/MD9bYtjvyW6yDsg@public.gmane.org>
Cc: Prasad Joshi <prasadjoshi.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/logfs/inode.c     |    4 ++--
 fs/logfs/readwrite.c |    8 ++++----
 init/Kconfig         |    1 -
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/logfs/inode.c b/fs/logfs/inode.c
index a422f42..43f61c2 100644
--- a/fs/logfs/inode.c
+++ b/fs/logfs/inode.c
@@ -192,8 +192,8 @@ static void logfs_init_inode(struct super_block *sb, struct inode *inode)
 	li->li_height	= 0;
 	li->li_used_bytes = 0;
 	li->li_block	= NULL;
-	inode->i_uid	= 0;
-	inode->i_gid	= 0;
+	i_uid_write(inode, 0);
+	i_gid_write(inode, 0);
 	inode->i_size	= 0;
 	inode->i_blocks	= 0;
 	inode->i_ctime	= CURRENT_TIME;
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index f1cb512..a8d492d 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -119,8 +119,8 @@ static void logfs_disk_to_inode(struct logfs_disk_inode *di, struct inode*inode)
 	inode->i_mode	= be16_to_cpu(di->di_mode);
 	li->li_height	= di->di_height;
 	li->li_flags	= be32_to_cpu(di->di_flags);
-	inode->i_uid	= be32_to_cpu(di->di_uid);
-	inode->i_gid	= be32_to_cpu(di->di_gid);
+	i_uid_write(inode, be32_to_cpu(di->di_uid));
+	i_gid_write(inode, be32_to_cpu(di->di_gid));
 	inode->i_size	= be64_to_cpu(di->di_size);
 	logfs_set_blocks(inode, be64_to_cpu(di->di_used_bytes));
 	inode->i_atime	= be64_to_timespec(di->di_atime);
@@ -156,8 +156,8 @@ static void logfs_inode_to_disk(struct inode *inode, struct logfs_disk_inode*di)
 	di->di_height	= li->li_height;
 	di->di_pad	= 0;
 	di->di_flags	= cpu_to_be32(li->li_flags);
-	di->di_uid	= cpu_to_be32(inode->i_uid);
-	di->di_gid	= cpu_to_be32(inode->i_gid);
+	di->di_uid	= cpu_to_be32(i_uid_read(inode));
+	di->di_gid	= cpu_to_be32(i_gid_read(inode));
 	di->di_size	= cpu_to_be64(i_size_read(inode));
 	di->di_used_bytes = cpu_to_be64(li->li_used_bytes);
 	di->di_atime	= timespec_to_be64(inode->i_atime);
diff --git a/init/Kconfig b/init/Kconfig
index 88f6571..80edba8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -946,7 +946,6 @@ config UIDGID_CONVERTED
 	depends on HPFS_FS = n
 	depends on JFFS2_FS = n
 	depends on JFS_FS = n
-	depends on LOGFS = n
 	depends on MINIX_FS = n
 	depends on NCP_FS = n
 	depends on NFSD = n
-- 
1.7.5.4
