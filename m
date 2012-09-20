From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 21/25] userns: Convert the qnx4 filesystem to use kuid/kgid
	where appropriate
Date: Thu, 20 Sep 2012 04:42:02 -0700
Message-ID: <1348141326-23355-21-git-send-email-ebiederm__20331.426538951$1348143186$gmane$org@xmission.com>
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
Cc: Anders Larsen <al-V9/YLgxv/GvR7s880joybQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Anders Larsen <al-V9/YLgxv/GvR7s880joybQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/qnx4/inode.c |    4 ++--
 init/Kconfig    |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index 552e994..5c3c7b0 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -312,8 +312,8 @@ struct inode *qnx4_iget(struct super_block *sb, unsigned long ino)
 	    (ino % QNX4_INODES_PER_BLOCK);
 
 	inode->i_mode    = le16_to_cpu(raw_inode->di_mode);
-	inode->i_uid     = (uid_t)le16_to_cpu(raw_inode->di_uid);
-	inode->i_gid     = (gid_t)le16_to_cpu(raw_inode->di_gid);
+	i_uid_write(inode, (uid_t)le16_to_cpu(raw_inode->di_uid));
+	i_gid_write(inode, (gid_t)le16_to_cpu(raw_inode->di_gid));
 	set_nlink(inode, le16_to_cpu(raw_inode->di_nlink));
 	inode->i_size    = le32_to_cpu(raw_inode->di_size);
 	inode->i_mtime.tv_sec   = le32_to_cpu(raw_inode->di_mtime);
diff --git a/init/Kconfig b/init/Kconfig
index 390e629..b9d6be5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -950,7 +950,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on QNX4FS_FS = n
 	depends on QNX6FS_FS = n
 	depends on REISERFS_FS = n
 	depends on SQUASHFS = n
-- 
1.7.5.4
