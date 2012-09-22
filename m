From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/11] userns: Convert reiserfs to use kuid and kgid where
	appropriate
Date: Fri, 21 Sep 2012 18:35:08 -0700
Message-ID: <1348277712-30055-7-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, reiserfs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: reiserfs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/reiserfs/inode.c     |   26 +++++++++++++-------------
 fs/reiserfs/xattr_acl.c |   20 +++++++++++++++++---
 init/Kconfig            |    1 -
 3 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index a6d4268..7119f48 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -1155,8 +1155,8 @@ static void init_inode(struct inode *inode, struct treepath *path)
 		set_inode_sd_version(inode, STAT_DATA_V1);
 		inode->i_mode = sd_v1_mode(sd);
 		set_nlink(inode, sd_v1_nlink(sd));
-		inode->i_uid = sd_v1_uid(sd);
-		inode->i_gid = sd_v1_gid(sd);
+		i_uid_write(inode, sd_v1_uid(sd));
+		i_gid_write(inode, sd_v1_gid(sd));
 		inode->i_size = sd_v1_size(sd);
 		inode->i_atime.tv_sec = sd_v1_atime(sd);
 		inode->i_mtime.tv_sec = sd_v1_mtime(sd);
@@ -1200,9 +1200,9 @@ static void init_inode(struct inode *inode, struct treepath *path)
 
 		inode->i_mode = sd_v2_mode(sd);
 		set_nlink(inode, sd_v2_nlink(sd));
-		inode->i_uid = sd_v2_uid(sd);
+		i_uid_write(inode, sd_v2_uid(sd));
 		inode->i_size = sd_v2_size(sd);
-		inode->i_gid = sd_v2_gid(sd);
+		i_gid_write(inode, sd_v2_gid(sd));
 		inode->i_mtime.tv_sec = sd_v2_mtime(sd);
 		inode->i_atime.tv_sec = sd_v2_atime(sd);
 		inode->i_ctime.tv_sec = sd_v2_ctime(sd);
@@ -1258,9 +1258,9 @@ static void inode2sd(void *sd, struct inode *inode, loff_t size)
 
 	set_sd_v2_mode(sd_v2, inode->i_mode);
 	set_sd_v2_nlink(sd_v2, inode->i_nlink);
-	set_sd_v2_uid(sd_v2, inode->i_uid);
+	set_sd_v2_uid(sd_v2, i_uid_read(inode));
 	set_sd_v2_size(sd_v2, size);
-	set_sd_v2_gid(sd_v2, inode->i_gid);
+	set_sd_v2_gid(sd_v2, i_gid_read(inode));
 	set_sd_v2_mtime(sd_v2, inode->i_mtime.tv_sec);
 	set_sd_v2_atime(sd_v2, inode->i_atime.tv_sec);
 	set_sd_v2_ctime(sd_v2, inode->i_ctime.tv_sec);
@@ -1280,8 +1280,8 @@ static void inode2sd_v1(void *sd, struct inode *inode, loff_t size)
 	struct stat_data_v1 *sd_v1 = (struct stat_data_v1 *)sd;
 
 	set_sd_v1_mode(sd_v1, inode->i_mode);
-	set_sd_v1_uid(sd_v1, inode->i_uid);
-	set_sd_v1_gid(sd_v1, inode->i_gid);
+	set_sd_v1_uid(sd_v1, i_uid_read(inode));
+	set_sd_v1_gid(sd_v1, i_gid_read(inode));
 	set_sd_v1_nlink(sd_v1, inode->i_nlink);
 	set_sd_v1_size(sd_v1, size);
 	set_sd_v1_atime(sd_v1, inode->i_atime.tv_sec);
@@ -1869,7 +1869,7 @@ int reiserfs_new_inode(struct reiserfs_transaction_handle *th,
 		goto out_bad_inode;
 	}
 	if (old_format_only(sb)) {
-		if (inode->i_uid & ~0xffff || inode->i_gid & ~0xffff) {
+		if (i_uid_read(inode) & ~0xffff || i_gid_read(inode) & ~0xffff) {
 			pathrelse(&path_to_key);
 			/* i_uid or i_gid is too big to be stored in stat data v3.5 */
 			err = -EINVAL;
@@ -3140,16 +3140,16 @@ int reiserfs_setattr(struct dentry *dentry, struct iattr *attr)
 		}
 	}
 
-	if ((((attr->ia_valid & ATTR_UID) && (attr->ia_uid & ~0xffff)) ||
-	     ((attr->ia_valid & ATTR_GID) && (attr->ia_gid & ~0xffff))) &&
+	if ((((attr->ia_valid & ATTR_UID) && (from_kuid(&init_user_ns, attr->ia_uid) & ~0xffff)) ||
+	     ((attr->ia_valid & ATTR_GID) && (from_kgid(&init_user_ns, attr->ia_gid) & ~0xffff))) &&
 	    (get_inode_sd_version(inode) == STAT_DATA_V1)) {
 		/* stat data of format v3.5 has 16 bit uid and gid */
 		error = -EINVAL;
 		goto out;
 	}
 
-	if ((ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
-	    (ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
+	if ((ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)) ||
+	    (ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid))) {
 		struct reiserfs_transaction_handle th;
 		int jbegin_count =
 		    2 *
diff --git a/fs/reiserfs/xattr_acl.c b/fs/reiserfs/xattr_acl.c
index 87d6911..d7c01ef 100644
--- a/fs/reiserfs/xattr_acl.c
+++ b/fs/reiserfs/xattr_acl.c
@@ -121,15 +121,23 @@ static struct posix_acl *posix_acl_from_disk(const void *value, size_t size)
 		case ACL_OTHER:
 			value = (char *)value +
 			    sizeof(reiserfs_acl_entry_short);
-			acl->a_entries[n].e_id = ACL_UNDEFINED_ID;
 			break;
 
 		case ACL_USER:
+			value = (char *)value + sizeof(reiserfs_acl_entry);
+			if ((char *)value > end)
+				goto fail;
+			acl->a_entries[n].e_uid = 
+				make_kuid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
 		case ACL_GROUP:
 			value = (char *)value + sizeof(reiserfs_acl_entry);
 			if ((char *)value > end)
 				goto fail;
-			acl->a_entries[n].e_id = le32_to_cpu(entry->e_id);
+			acl->a_entries[n].e_gid =
+				make_kgid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
 			break;
 
 		default:
@@ -164,13 +172,19 @@ static void *posix_acl_to_disk(const struct posix_acl *acl, size_t * size)
 	ext_acl->a_version = cpu_to_le32(REISERFS_ACL_VERSION);
 	e = (char *)ext_acl + sizeof(reiserfs_acl_header);
 	for (n = 0; n < acl->a_count; n++) {
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
 		reiserfs_acl_entry *entry = (reiserfs_acl_entry *) e;
 		entry->e_tag = cpu_to_le16(acl->a_entries[n].e_tag);
 		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
 		switch (acl->a_entries[n].e_tag) {
 		case ACL_USER:
+			entry->e_id = cpu_to_le32(
+				from_kuid(&init_user_ns, acl_e->e_uid));
+			e += sizeof(reiserfs_acl_entry);
+			break;
 		case ACL_GROUP:
-			entry->e_id = cpu_to_le32(acl->a_entries[n].e_id);
+			entry->e_id = cpu_to_le32(
+				from_kgid(&init_user_ns, acl_e->e_gid));
 			e += sizeof(reiserfs_acl_entry);
 			break;
 
diff --git a/init/Kconfig b/init/Kconfig
index 20d4a1b..8b11f29 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -939,7 +939,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on REISERFS_FS = n
 	depends on SQUASHFS = n
 	depends on UBIFS_FS = n
 	depends on UDF_FS = n
-- 
1.7.5.4
