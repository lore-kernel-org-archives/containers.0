From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/25] userns: Convert efs to use kuid/kgid where appropriate
Date: Thu, 20 Sep 2012 04:41:52 -0700
Message-ID: <1348141326-23355-11-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/efs/inode.c |    4 ++--
 init/Kconfig   |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/efs/inode.c b/fs/efs/inode.c
index bc84f36..f3913eb 100644
--- a/fs/efs/inode.c
+++ b/fs/efs/inode.c
@@ -97,8 +97,8 @@ struct inode *efs_iget(struct super_block *super, unsigned long ino)
     
 	inode->i_mode  = be16_to_cpu(efs_inode->di_mode);
 	set_nlink(inode, be16_to_cpu(efs_inode->di_nlink));
-	inode->i_uid   = (uid_t)be16_to_cpu(efs_inode->di_uid);
-	inode->i_gid   = (gid_t)be16_to_cpu(efs_inode->di_gid);
+	i_uid_write(inode, (uid_t)be16_to_cpu(efs_inode->di_uid));
+	i_gid_write(inode, (gid_t)be16_to_cpu(efs_inode->di_gid));
 	inode->i_size  = be32_to_cpu(efs_inode->di_size);
 	inode->i_atime.tv_sec = be32_to_cpu(efs_inode->di_atime);
 	inode->i_mtime.tv_sec = be32_to_cpu(efs_inode->di_mtime);
diff --git a/init/Kconfig b/init/Kconfig
index 6120bae..51084b0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -941,7 +941,6 @@ config UIDGID_CONVERTED
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-	depends on EFS_FS = n
 	depends on EXOFS_FS = n
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
-- 
1.7.5.4
