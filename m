From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 12/25] userns: Convert exofs to use kuid/kgid where appropriate
Date: Thu, 20 Sep 2012 04:41:53 -0700
Message-ID: <1348141326-23355-12-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Benny Halevy <bhalevy-4/WYdZTkCtzQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Cc: Benny Halevy <bhalevy-4/WYdZTkCtzQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/exofs/inode.c |    8 ++++----
 init/Kconfig     |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 5badb0c..190c3d6 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -1163,8 +1163,8 @@ struct inode *exofs_iget(struct super_block *sb, unsigned long ino)
 
 	/* copy stuff from on-disk struct to in-memory struct */
 	inode->i_mode = le16_to_cpu(fcb.i_mode);
-	inode->i_uid = le32_to_cpu(fcb.i_uid);
-	inode->i_gid = le32_to_cpu(fcb.i_gid);
+	i_uid_write(inode, le32_to_cpu(fcb.i_uid));
+	i_gid_write(inode, le32_to_cpu(fcb.i_gid));
 	set_nlink(inode, le16_to_cpu(fcb.i_links_count));
 	inode->i_ctime.tv_sec = (signed)le32_to_cpu(fcb.i_ctime);
 	inode->i_atime.tv_sec = (signed)le32_to_cpu(fcb.i_atime);
@@ -1376,8 +1376,8 @@ static int exofs_update_inode(struct inode *inode, int do_sync)
 	fcb = &args->fcb;
 
 	fcb->i_mode = cpu_to_le16(inode->i_mode);
-	fcb->i_uid = cpu_to_le32(inode->i_uid);
-	fcb->i_gid = cpu_to_le32(inode->i_gid);
+	fcb->i_uid = cpu_to_le32(i_uid_read(inode));
+	fcb->i_gid = cpu_to_le32(i_gid_read(inode));
 	fcb->i_links_count = cpu_to_le16(inode->i_nlink);
 	fcb->i_ctime = cpu_to_le32(inode->i_ctime.tv_sec);
 	fcb->i_atime = cpu_to_le32(inode->i_atime.tv_sec);
diff --git a/init/Kconfig b/init/Kconfig
index 51084b0..39e55d6 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -941,7 +941,6 @@ config UIDGID_CONVERTED
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-	depends on EXOFS_FS = n
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
 	depends on HFS_FS = n
-- 
1.7.5.4
