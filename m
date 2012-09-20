From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 22/25] userns: Convert the qnx6 filesystem to use kuid/kgid
	where appropriate
Date: Thu, 20 Sep 2012 04:42:03 -0700
Message-ID: <1348141326-23355-22-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kai Bankett <chaosman-VMqxFixGRh2sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Kai Bankett <chaosman-VMqxFixGRh2sTnJN9+BGXg@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/qnx6/inode.c |    4 ++--
 init/Kconfig    |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 2049c81..f4eef0b 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -574,8 +574,8 @@ struct inode *qnx6_iget(struct super_block *sb, unsigned ino)
 	raw_inode = ((struct qnx6_inode_entry *)page_address(page)) + offs;
 
 	inode->i_mode    = fs16_to_cpu(sbi, raw_inode->di_mode);
-	inode->i_uid     = (uid_t)fs32_to_cpu(sbi, raw_inode->di_uid);
-	inode->i_gid     = (gid_t)fs32_to_cpu(sbi, raw_inode->di_gid);
+	i_uid_write(inode, (uid_t)fs32_to_cpu(sbi, raw_inode->di_uid));
+	i_gid_write(inode, (gid_t)fs32_to_cpu(sbi, raw_inode->di_gid));
 	inode->i_size    = fs64_to_cpu(sbi, raw_inode->di_size);
 	inode->i_mtime.tv_sec   = fs32_to_cpu(sbi, raw_inode->di_mtime);
 	inode->i_mtime.tv_nsec = 0;
diff --git a/init/Kconfig b/init/Kconfig
index b9d6be5..1ff9f41 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -950,7 +950,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on QNX6FS_FS = n
 	depends on REISERFS_FS = n
 	depends on SQUASHFS = n
 	depends on SYSV_FS = n
-- 
1.7.5.4
