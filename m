From: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: [PATCH 06/11] capabilities: Allow privileged user in s_user_ns to set
	security.* xattrs
Date: Fri, 22 Dec 2017 15:32:30 +0100
Message-ID: <5adc5e31c25beb987798ecc219df79671547a9ac.1512041070.git.dongsu@kinvolk.io>
References: <cover.1512741134.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1512741134.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

A privileged user in s_user_ns will generally have the ability to
manipulate the backing store and insert security.* xattrs into
the filesystem directly. Therefore the kernel must be prepared to
handle these xattrs from unprivileged mounts, and it makes little
sense for commoncap to prevent writing these xattrs to the
filesystem. The capability and LSM code have already been updated
to appropriately handle xattrs from unprivileged mounts, so it
is safe to loosen this restriction on setting xattrs.

The exception to this logic is that writing xattrs to a mounted
filesystem may also cause the LSM inode_post_setxattr or
inode_setsecurity callbacks to be invoked. SELinux will deny the
xattr update by virtue of applying mountpoint labeling to
unprivileged userns mounts, and Smack will deny the writes for
any user without global CAP_MAC_ADMIN, so loosening the
capability check in commoncap is safe in this respect as well.

Patch v4 is available: https://patchwork.kernel.org/patch/8944641/

Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
---
 security/commoncap.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index 4f8e0934..dd0afef9 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -920,6 +920,8 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
 int cap_inode_setxattr(struct dentry *dentry, const char *name,
 		       const void *value, size_t size, int flags)
 {
+	struct user_namespace *user_ns = dentry->d_sb->s_user_ns;
+
 	/* Ignore non-security xattrs */
 	if (strncmp(name, XATTR_SECURITY_PREFIX,
 			sizeof(XATTR_SECURITY_PREFIX) - 1) != 0)
@@ -932,7 +934,7 @@ int cap_inode_setxattr(struct dentry *dentry, const char *name,
 	if (strcmp(name, XATTR_NAME_CAPS) == 0)
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 	return 0;
 }
@@ -950,6 +952,8 @@ int cap_inode_setxattr(struct dentry *dentry, const char *name,
  */
 int cap_inode_removexattr(struct dentry *dentry, const char *name)
 {
+	struct user_namespace *user_ns = dentry->d_sb->s_user_ns;
+
 	/* Ignore non-security xattrs */
 	if (strncmp(name, XATTR_SECURITY_PREFIX,
 			sizeof(XATTR_SECURITY_PREFIX) - 1) != 0)
@@ -965,7 +969,7 @@ int cap_inode_removexattr(struct dentry *dentry, const char *name)
 		return 0;
 	}
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 	return 0;
 }
-- 
2.13.6
