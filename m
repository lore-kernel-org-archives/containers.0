From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 23/25] userns: Convert the sysv filesystem to use kuid/kgid
	where appropriate
Date: Thu, 20 Sep 2012 04:42:04 -0700
Message-ID: <1348141326-23355-23-git-send-email-ebiederm@xmission.com>
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
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysv/inode.c |    8 ++++----
 init/Kconfig    |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index 80e1e2b..b23ab73 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -202,8 +202,8 @@ struct inode *sysv_iget(struct super_block *sb, unsigned int ino)
 	}
 	/* SystemV FS: kludge permissions if ino==SYSV_ROOT_INO ?? */
 	inode->i_mode = fs16_to_cpu(sbi, raw_inode->i_mode);
-	inode->i_uid = (uid_t)fs16_to_cpu(sbi, raw_inode->i_uid);
-	inode->i_gid = (gid_t)fs16_to_cpu(sbi, raw_inode->i_gid);
+	i_uid_write(inode, (uid_t)fs16_to_cpu(sbi, raw_inode->i_uid));
+	i_gid_write(inode, (gid_t)fs16_to_cpu(sbi, raw_inode->i_gid));
 	set_nlink(inode, fs16_to_cpu(sbi, raw_inode->i_nlink));
 	inode->i_size = fs32_to_cpu(sbi, raw_inode->i_size);
 	inode->i_atime.tv_sec = fs32_to_cpu(sbi, raw_inode->i_atime);
@@ -256,8 +256,8 @@ static int __sysv_write_inode(struct inode *inode, int wait)
 	}
 
 	raw_inode->i_mode = cpu_to_fs16(sbi, inode->i_mode);
-	raw_inode->i_uid = cpu_to_fs16(sbi, fs_high2lowuid(inode->i_uid));
-	raw_inode->i_gid = cpu_to_fs16(sbi, fs_high2lowgid(inode->i_gid));
+	raw_inode->i_uid = cpu_to_fs16(sbi, fs_high2lowuid(i_uid_read(inode)));
+	raw_inode->i_gid = cpu_to_fs16(sbi, fs_high2lowgid(i_gid_read(inode)));
 	raw_inode->i_nlink = cpu_to_fs16(sbi, inode->i_nlink);
 	raw_inode->i_size = cpu_to_fs32(sbi, inode->i_size);
 	raw_inode->i_atime = cpu_to_fs32(sbi, inode->i_atime.tv_sec);
diff --git a/init/Kconfig b/init/Kconfig
index 1ff9f41..3427832 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -952,7 +952,6 @@ config UIDGID_CONVERTED
 	depends on OCFS2_FS = n
 	depends on REISERFS_FS = n
 	depends on SQUASHFS = n
-	depends on SYSV_FS = n
 	depends on UBIFS_FS = n
 	depends on UDF_FS = n
 	depends on UFS_FS = n
-- 
1.7.5.4
