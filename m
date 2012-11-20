From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 09/12] userns: Convert ocfs2 to use kuid and kgid where
	appropriate
Date: Tue, 20 Nov 2012 04:43:37 -0800
Message-ID: <1353415420-5457-9-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>
Cc: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ocfs2/acl.c          |   31 +++++++++++++++++++++++++++++--
 fs/ocfs2/dlmglue.c      |    8 ++++----
 fs/ocfs2/file.c         |   11 ++++++-----
 fs/ocfs2/inode.c        |   12 ++++++------
 fs/ocfs2/namei.c        |    4 ++--
 fs/ocfs2/refcounttree.c |    2 +-
 init/Kconfig            |    1 -
 7 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
index 260b162..8a40457 100644
--- a/fs/ocfs2/acl.c
+++ b/fs/ocfs2/acl.c
@@ -65,7 +65,20 @@ static struct posix_acl *ocfs2_acl_from_xattr(const void *value, size_t size)
 
 		acl->a_entries[n].e_tag  = le16_to_cpu(entry->e_tag);
 		acl->a_entries[n].e_perm = le16_to_cpu(entry->e_perm);
-		acl->a_entries[n].e_id   = le32_to_cpu(entry->e_id);
+		switch(acl->a_entries[n].e_tag) {
+		case ACL_USER:
+			acl->a_entries[n].e_uid =
+				make_kuid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
+		case ACL_GROUP:
+			acl->a_entries[n].e_gid =
+				make_kgid(&init_user_ns,
+					  le32_to_cpu(entry->e_id));
+			break;
+		default:
+			break;
+		}
 		value += sizeof(struct posix_acl_entry);
 
 	}
@@ -91,7 +104,21 @@ static void *ocfs2_acl_to_xattr(const struct posix_acl *acl, size_t *size)
 	for (n = 0; n < acl->a_count; n++, entry++) {
 		entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
 		entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		entry->e_id   = cpu_to_le32(acl->a_entries[n].e_id);
+		switch(acl->a_entries[n].e_tag) {
+		case ACL_USER:
+			entry->e_id = cpu_to_le32(
+				from_kuid(&init_user_ns,
+					  acl->a_entries[n].e_uid));
+			break;
+		case ACL_GROUP:
+			entry->e_id = cpu_to_le32(
+				from_kgid(&init_user_ns,
+					  acl->a_entries[n].e_gid));
+			break;
+		default:
+			entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
+			break;
+		}
 	}
 	return ocfs2_acl;
 }
diff --git a/fs/ocfs2/dlmglue.c b/fs/ocfs2/dlmglue.c
index 4f7795f..f99af1c 100644
--- a/fs/ocfs2/dlmglue.c
+++ b/fs/ocfs2/dlmglue.c
@@ -2045,8 +2045,8 @@ static void __ocfs2_stuff_meta_lvb(struct inode *inode)
 	lvb->lvb_version   = OCFS2_LVB_VERSION;
 	lvb->lvb_isize	   = cpu_to_be64(i_size_read(inode));
 	lvb->lvb_iclusters = cpu_to_be32(oi->ip_clusters);
-	lvb->lvb_iuid      = cpu_to_be32(inode->i_uid);
-	lvb->lvb_igid      = cpu_to_be32(inode->i_gid);
+	lvb->lvb_iuid      = cpu_to_be32(i_uid_read(inode));
+	lvb->lvb_igid      = cpu_to_be32(i_gid_read(inode));
 	lvb->lvb_imode     = cpu_to_be16(inode->i_mode);
 	lvb->lvb_inlink    = cpu_to_be16(inode->i_nlink);
 	lvb->lvb_iatime_packed  =
@@ -2095,8 +2095,8 @@ static void ocfs2_refresh_inode_from_lvb(struct inode *inode)
 	else
 		inode->i_blocks = ocfs2_inode_sector_count(inode);
 
-	inode->i_uid     = be32_to_cpu(lvb->lvb_iuid);
-	inode->i_gid     = be32_to_cpu(lvb->lvb_igid);
+	i_uid_write(inode, be32_to_cpu(lvb->lvb_iuid));
+	i_gid_write(inode, be32_to_cpu(lvb->lvb_igid));
 	inode->i_mode    = be16_to_cpu(lvb->lvb_imode);
 	set_nlink(inode, be16_to_cpu(lvb->lvb_inlink));
 	ocfs2_unpack_timespec(&inode->i_atime,
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 5a4ee77..dc19b69 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -1116,7 +1116,8 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 			    (unsigned long long)OCFS2_I(inode)->ip_blkno,
 			    dentry->d_name.len, dentry->d_name.name,
 			    attr->ia_valid, attr->ia_mode,
-			    attr->ia_uid, attr->ia_gid);
+			    from_kuid(&init_user_ns, attr->ia_uid),
+			    from_kgid(&init_user_ns, attr->ia_gid));
 
 	/* ensuring we don't even attempt to truncate a symlink */
 	if (S_ISLNK(inode->i_mode))
@@ -1174,14 +1175,14 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 		}
 	}
 
-	if ((attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
-	    (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
+	if ((attr->ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)) ||
+	    (attr->ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid))) {
 		/*
 		 * Gather pointers to quota structures so that allocation /
 		 * freeing of quota structures happens here and not inside
 		 * dquot_transfer() where we have problems with lock ordering
 		 */
-		if (attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid
+		if (attr->ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_USRQUOTA)) {
 			transfer_to[USRQUOTA] = dqget(sb, make_kqid_uid(attr->ia_uid));
@@ -1190,7 +1191,7 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
 				goto bail_unlock;
 			}
 		}
-		if (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid
+		if (attr->ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid)
 		    && OCFS2_HAS_RO_COMPAT_FEATURE(sb,
 		    OCFS2_FEATURE_RO_COMPAT_GRPQUOTA)) {
 			transfer_to[GRPQUOTA] = dqget(sb, make_kqid_gid(attr->ia_gid));
diff --git a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
index d89e08a..f87f9bd 100644
--- a/fs/ocfs2/inode.c
+++ b/fs/ocfs2/inode.c
@@ -269,8 +269,8 @@ void ocfs2_populate_inode(struct inode *inode, struct ocfs2_dinode *fe,
 	inode->i_generation = le32_to_cpu(fe->i_generation);
 	inode->i_rdev = huge_decode_dev(le64_to_cpu(fe->id1.dev1.i_rdev));
 	inode->i_mode = le16_to_cpu(fe->i_mode);
-	inode->i_uid = le32_to_cpu(fe->i_uid);
-	inode->i_gid = le32_to_cpu(fe->i_gid);
+	i_uid_write(inode, le32_to_cpu(fe->i_uid));
+	i_gid_write(inode, le32_to_cpu(fe->i_gid));
 
 	/* Fast symlinks will have i_size but no allocated clusters. */
 	if (S_ISLNK(inode->i_mode) && !fe->i_clusters) {
@@ -1259,8 +1259,8 @@ int ocfs2_mark_inode_dirty(handle_t *handle,
 
 	fe->i_size = cpu_to_le64(i_size_read(inode));
 	ocfs2_set_links_count(fe, inode->i_nlink);
-	fe->i_uid = cpu_to_le32(inode->i_uid);
-	fe->i_gid = cpu_to_le32(inode->i_gid);
+	fe->i_uid = cpu_to_le32(i_uid_read(inode));
+	fe->i_gid = cpu_to_le32(i_gid_read(inode));
 	fe->i_mode = cpu_to_le16(inode->i_mode);
 	fe->i_atime = cpu_to_le64(inode->i_atime.tv_sec);
 	fe->i_atime_nsec = cpu_to_le32(inode->i_atime.tv_nsec);
@@ -1290,8 +1290,8 @@ void ocfs2_refresh_inode(struct inode *inode,
 	ocfs2_set_inode_flags(inode);
 	i_size_write(inode, le64_to_cpu(fe->i_size));
 	set_nlink(inode, ocfs2_read_links_count(fe));
-	inode->i_uid = le32_to_cpu(fe->i_uid);
-	inode->i_gid = le32_to_cpu(fe->i_gid);
+	i_uid_write(inode, le32_to_cpu(fe->i_uid));
+	i_gid_write(inode, le32_to_cpu(fe->i_gid));
 	inode->i_mode = le16_to_cpu(fe->i_mode);
 	if (S_ISLNK(inode->i_mode) && le32_to_cpu(fe->i_clusters) == 0)
 		inode->i_blocks = 0;
diff --git a/fs/ocfs2/namei.c b/fs/ocfs2/namei.c
index f1fd074..04ee1b5 100644
--- a/fs/ocfs2/namei.c
+++ b/fs/ocfs2/namei.c
@@ -512,8 +512,8 @@ static int __ocfs2_mknod_locked(struct inode *dir,
 	fe->i_suballoc_loc = cpu_to_le64(suballoc_loc);
 	fe->i_suballoc_bit = cpu_to_le16(suballoc_bit);
 	fe->i_suballoc_slot = cpu_to_le16(inode_ac->ac_alloc_slot);
-	fe->i_uid = cpu_to_le32(inode->i_uid);
-	fe->i_gid = cpu_to_le32(inode->i_gid);
+	fe->i_uid = cpu_to_le32(i_uid_read(inode));
+	fe->i_gid = cpu_to_le32(i_gid_read(inode));
 	fe->i_mode = cpu_to_le16(inode->i_mode);
 	if (S_ISCHR(inode->i_mode) || S_ISBLK(inode->i_mode))
 		fe->id1.dev1.i_rdev = cpu_to_le64(huge_encode_dev(dev));
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 30a0550..934a4ac 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4407,7 +4407,7 @@ static int ocfs2_vfs_reflink(struct dentry *old_dentry, struct inode *dir,
 	 * rights to do so.
 	 */
 	if (preserve) {
-		if ((current_fsuid() != inode->i_uid) && !capable(CAP_CHOWN))
+		if (!uid_eq(current_fsuid(), inode->i_uid) && !capable(CAP_CHOWN))
 			return -EPERM;
 		if (!in_group_p(inode->i_gid) && !capable(CAP_CHOWN))
 			return -EPERM;
diff --git a/init/Kconfig b/init/Kconfig
index 1bcc523..ee7e5b6 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -999,7 +999,6 @@ config UIDGID_CONVERTED
 	default y
 
 	# Filesystems
-	depends on OCFS2_FS = n
 	depends on XFS_FS = n
 
 config UIDGID_STRICT_TYPE_CHECKS
-- 
1.7.5.4
