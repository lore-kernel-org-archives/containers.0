From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/14] xfs: Convert uids and gids in xfs acls to/from kuids
	and kgids
Date: Wed, 13 Mar 2013 15:23:02 -0700
Message-ID: <1363213395-10988-1-git-send-email-ebiederm@xmission.com>
References: <87boan3prc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87boan3prc.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- When reading from disk convert on disk uids and gids to kuids and kgids
- When writing to the disk convert in memory kuids and kgids to uids and gids.
- Don't write e_id as that field only exists when user namespace
  support is disabled.
- Use uid_eq when testing to see if current_fsuid() is allowed to set the
  acls for a file.

Cc: Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/xfs/xfs_acl.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index 1d32f1d..ca2aade 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -64,14 +64,17 @@ xfs_acl_from_disk(struct xfs_acl *aclp)
 
 		switch (acl_e->e_tag) {
 		case ACL_USER:
+			acl_e->e_uid = make_kuid(&init_user_ns,
+						 be32_to_cpu(ace->ae_id));
+			break;
 		case ACL_GROUP:
-			acl_e->e_id = be32_to_cpu(ace->ae_id);
+			acl_e->e_gid = make_kgid(&init_user_ns,
+						 be32_to_cpu(ace->ae_id));
 			break;
 		case ACL_USER_OBJ:
 		case ACL_GROUP_OBJ:
 		case ACL_MASK:
 		case ACL_OTHER:
-			acl_e->e_id = ACL_UNDEFINED_ID;
 			break;
 		default:
 			goto fail;
@@ -97,8 +100,20 @@ xfs_acl_to_disk(struct xfs_acl *aclp, const struct posix_acl *acl)
 		acl_e = &acl->a_entries[i];
 
 		ace->ae_tag = cpu_to_be32(acl_e->e_tag);
-		ace->ae_id = cpu_to_be32(acl_e->e_id);
 		ace->ae_perm = cpu_to_be16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
+		case ACL_USER:
+			ace->ae_id = cpu_to_be32(
+				from_kuid(&init_user_ns, acl_e->e_uid));
+			break;
+		case ACL_GROUP:
+			ace->ae_id = cpu_to_be32(
+				from_kgid(&init_user_ns, acl_e->e_gid));
+			break;
+		default:
+			ace->ae_id = cpu_to_be32(ACL_UNDEFINED_ID);
+			break;
+		}
 	}
 }
 
@@ -355,7 +370,7 @@ xfs_xattr_acl_set(struct dentry *dentry, const char *name,
 		return -EINVAL;
 	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return value ? -EACCES : 0;
-	if ((current_fsuid() != inode->i_uid) && !capable(CAP_FOWNER))
+	if ((!uid_eq(current_fsuid(), inode->i_uid)) && !capable(CAP_FOWNER))
 		return -EPERM;
 
 	if (!value)
-- 
1.7.5.4
