From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 03/12] vfs: Verify acls are valid within superblock's
	s_user_ns.
Date: Wed,  6 Jul 2016 13:12:03 -0500
Message-ID: <20160706181212.16267-3-ebiederm__32121.3594674648$1467829532$gmane$org@xmission.com>
References: <874m82bptc.fsf@x220.int.ebiederm.org>
	<20160706181212.16267-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160706181212.16267-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Update posix_acl_valid to verify that an acl is within a user namespace.

Update the callers of posix_acl_valid to pass in an appropriate
user namespace.  For posix_acl_xattr_set and v9fs_xattr_set_acl pass in
inode->i_sb->s_user_ns to posix_acl_valid.  For md_unpack_acl pass in
&init_user_ns as no inode or superblock is in sight.

Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 2 +-
 fs/9p/acl.c                                     | 2 +-
 fs/posix_acl.c                                  | 8 ++++----
 include/linux/posix_acl.h                       | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 86b7445365f4..40cf57fad581 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -434,7 +434,7 @@ static int mdc_unpack_acl(struct ptlrpc_request *req, struct lustre_md *md)
 		return rc;
 	}
 
-	rc = posix_acl_valid(acl);
+	rc = posix_acl_valid(&init_user_ns, acl);
 	if (rc) {
 		CERROR("validate acl: %d\n", rc);
 		posix_acl_release(acl);
diff --git a/fs/9p/acl.c b/fs/9p/acl.c
index 0576eaeb60b9..5b6a1743ea17 100644
--- a/fs/9p/acl.c
+++ b/fs/9p/acl.c
@@ -266,7 +266,7 @@ static int v9fs_xattr_set_acl(const struct xattr_handler *handler,
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
-			retval = posix_acl_valid(acl);
+			retval = posix_acl_valid(inode->i_sb->s_user_ns, acl);
 			if (retval)
 				goto err_out;
 		}
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 8a4a266beff3..647c28180675 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -205,7 +205,7 @@ posix_acl_clone(const struct posix_acl *acl, gfp_t flags)
  * Check if an acl is valid. Returns 0 if it is, or -E... otherwise.
  */
 int
-posix_acl_valid(const struct posix_acl *acl)
+posix_acl_valid(struct user_namespace *user_ns, const struct posix_acl *acl)
 {
 	const struct posix_acl_entry *pa, *pe;
 	int state = ACL_USER_OBJ;
@@ -225,7 +225,7 @@ posix_acl_valid(const struct posix_acl *acl)
 			case ACL_USER:
 				if (state != ACL_USER)
 					return -EINVAL;
-				if (!uid_valid(pa->e_uid))
+				if (!kuid_has_mapping(user_ns, pa->e_uid))
 					return -EINVAL;
 				needs_mask = 1;
 				break;
@@ -240,7 +240,7 @@ posix_acl_valid(const struct posix_acl *acl)
 			case ACL_GROUP:
 				if (state != ACL_GROUP)
 					return -EINVAL;
-				if (!gid_valid(pa->e_gid))
+				if (!kgid_has_mapping(user_ns, pa->e_gid))
 					return -EINVAL;
 				needs_mask = 1;
 				break;
@@ -845,7 +845,7 @@ posix_acl_xattr_set(const struct xattr_handler *handler,
 			return PTR_ERR(acl);
 
 		if (acl) {
-			ret = posix_acl_valid(acl);
+			ret = posix_acl_valid(inode->i_sb->s_user_ns, acl);
 			if (ret)
 				goto out;
 		}
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 5b5a80cc5926..1af6438fde3e 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -81,7 +81,7 @@ posix_acl_release(struct posix_acl *acl)
 
 extern void posix_acl_init(struct posix_acl *, int);
 extern struct posix_acl *posix_acl_alloc(int, gfp_t);
-extern int posix_acl_valid(const struct posix_acl *);
+extern int posix_acl_valid(struct user_namespace *, const struct posix_acl *);
 extern int posix_acl_permission(struct inode *, const struct posix_acl *, int);
 extern struct posix_acl *posix_acl_from_mode(umode_t, gfp_t);
 extern int posix_acl_equiv_mode(const struct posix_acl *, umode_t *);
-- 
2.8.3
