From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 10/11] userns: Convert the udf filesystem to use kuid/kgid
	where appropriate
Date: Fri, 21 Sep 2012 18:35:11 -0700
Message-ID: <1348277712-30055-10-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/udf/inode.c |   20 ++++++++++++--------
 init/Kconfig   |    1 -
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index fafaad7..2e6fb4d 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -1250,6 +1250,8 @@ static void udf_fill_inode(struct inode *inode, struct buffer_head *bh)
 	struct udf_sb_info *sbi = UDF_SB(inode->i_sb);
 	struct udf_inode_info *iinfo = UDF_I(inode);
 	unsigned int link_count;
+	uid_t i_uid;
+	gid_t i_gid;
 
 	fe = (struct fileEntry *)bh->b_data;
 	efe = (struct extendedFileEntry *)bh->b_data;
@@ -1309,17 +1311,19 @@ static void udf_fill_inode(struct inode *inode, struct buffer_head *bh)
 	}
 
 	read_lock(&sbi->s_cred_lock);
-	inode->i_uid = le32_to_cpu(fe->uid);
-	if (inode->i_uid == -1 ||
+	i_uid = le32_to_cpu(fe->uid);
+	if (i_uid == -1 ||
 	    UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_UID_IGNORE) ||
 	    UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_UID_SET))
-		inode->i_uid = UDF_SB(inode->i_sb)->s_uid;
+		i_uid = UDF_SB(inode->i_sb)->s_uid;
+	i_uid_write(inode, i_uid);
 
-	inode->i_gid = le32_to_cpu(fe->gid);
-	if (inode->i_gid == -1 ||
+	i_gid = le32_to_cpu(fe->gid);
+	if (i_gid == -1 ||
 	    UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_GID_IGNORE) ||
 	    UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_GID_SET))
-		inode->i_gid = UDF_SB(inode->i_sb)->s_gid;
+		i_gid = UDF_SB(inode->i_sb)->s_gid;
+	i_gid_write(inode, i_gid);
 
 	if (fe->icbTag.fileType != ICBTAG_FILE_TYPE_DIRECTORY &&
 			sbi->s_fmode != UDF_INVALID_MODE)
@@ -1539,12 +1543,12 @@ static int udf_update_inode(struct inode *inode, int do_sync)
 	if (UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_UID_FORGET))
 		fe->uid = cpu_to_le32(-1);
 	else
-		fe->uid = cpu_to_le32(inode->i_uid);
+		fe->uid = cpu_to_le32(i_uid_read(inode));
 
 	if (UDF_QUERY_FLAG(inode->i_sb, UDF_FLAG_GID_FORGET))
 		fe->gid = cpu_to_le32(-1);
 	else
-		fe->gid = cpu_to_le32(inode->i_gid);
+		fe->gid = cpu_to_le32(i_gid_read(inode));
 
 	udfperms = ((inode->i_mode & S_IRWXO)) |
 		   ((inode->i_mode & S_IRWXG) << 2) |
diff --git a/init/Kconfig b/init/Kconfig
index 21adc1c..6f9819a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -939,7 +939,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on UDF_FS = n
 	depends on UFS_FS = n
 	depends on XFS_FS = n
 
-- 
1.7.5.4
