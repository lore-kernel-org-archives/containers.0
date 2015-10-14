From: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v4 04/11] lsm: inode_pre_setxattr hook
Date: Wed, 14 Oct 2015 14:41:58 +0200
Message-ID: <1444826525-9758-5-git-send-email-l.pawelczyk__34711.8960381069$1444826610$gmane$org@samsung.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <1444826525-9758-1-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Add a new LSM hook called before inode's setxattr. It is required for
LSM to be able to reliably replace the xattr's value to be set to
filesystem in __vfs_setxattr_noperm(). Useful for mapped values, like in
the upcoming Smack namespace patches.

Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 fs/xattr.c                | 10 ++++++++++
 include/linux/lsm_hooks.h |  9 +++++++++
 include/linux/security.h  | 10 ++++++++++
 security/security.c       | 12 ++++++++++++
 4 files changed, 41 insertions(+)

diff --git a/fs/xattr.c b/fs/xattr.c
index 072fee1..cbc8d19 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -100,12 +100,22 @@ int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
 	if (issec)
 		inode->i_flags &= ~S_NOSEC;
 	if (inode->i_op->setxattr) {
+		bool alloc = false;
+
+		error = security_inode_pre_setxattr(dentry, name, &value,
+						    &size, flags, &alloc);
+		if (error)
+			return error;
+
 		error = inode->i_op->setxattr(dentry, name, value, size, flags);
 		if (!error) {
 			fsnotify_xattr(dentry);
 			security_inode_post_setxattr(dentry, name, value,
 						     size, flags);
 		}
+
+		if (alloc)
+			kfree(value);
 	} else if (issec) {
 		const char *suffix = name + XATTR_SECURITY_PREFIX_LEN;
 		error = security_inode_setsecurity(inode, suffix, value,
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 4f16640..85bfdde 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -349,6 +349,11 @@
  *	Check permission before setting the extended attributes
  *	@value identified by @name for @dentry.
  *	Return 0 if permission is granted.
+ * @inode_pre_setxattr:
+ *	Be able to do some operation before setting the @value identified
+ *	by @name on the filesystem. Replacing the @value and its @size is
+ *	possible. Useful for mapped values. Set @alloc to true if @value
+ *	needs to be kfreed afterwards.
  * @inode_post_setxattr:
  *	Update inode security field after successful setxattr operation.
  *	@value identified by @name for @dentry.
@@ -1448,6 +1453,9 @@ union security_list_options {
 	int (*inode_getattr)(const struct path *path);
 	int (*inode_setxattr)(struct dentry *dentry, const char *name,
 				const void *value, size_t size, int flags);
+	int (*inode_pre_setxattr)(struct dentry *dentry, const char *name,
+				  const void **value, size_t *size,
+				  int flags, bool *alloc);
 	void (*inode_post_setxattr)(struct dentry *dentry, const char *name,
 					const void *value, size_t size,
 					int flags);
@@ -1730,6 +1738,7 @@ struct security_hook_heads {
 	struct list_head inode_setattr;
 	struct list_head inode_getattr;
 	struct list_head inode_setxattr;
+	struct list_head inode_pre_setxattr;
 	struct list_head inode_post_setxattr;
 	struct list_head inode_getxattr;
 	struct list_head inode_listxattr;
diff --git a/include/linux/security.h b/include/linux/security.h
index 12bd011..4de4865 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -263,6 +263,9 @@ int security_inode_setattr(struct dentry *dentry, struct iattr *attr);
 int security_inode_getattr(const struct path *path);
 int security_inode_setxattr(struct dentry *dentry, const char *name,
 			    const void *value, size_t size, int flags);
+int security_inode_pre_setxattr(struct dentry *dentry, const char *name,
+				const void **value, size_t *size, int flags,
+				bool *alloc);
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags);
 int security_inode_getxattr(struct dentry *dentry, const char *name);
@@ -691,6 +694,13 @@ static inline int security_inode_setxattr(struct dentry *dentry,
 	return cap_inode_setxattr(dentry, name, value, size, flags);
 }
 
+static inline int security_inode_pre_setxattr(struct dentry *dentry,
+				const char *name, const void **value,
+				size_t *size, int flags, bool *alloc)
+{
+	return 0;
+}
+
 static inline void security_inode_post_setxattr(struct dentry *dentry,
 		const char *name, const void *value, size_t size, int flags)
 { }
diff --git a/security/security.c b/security/security.c
index abfc207..75d46b6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -644,6 +644,16 @@ int security_inode_setxattr(struct dentry *dentry, const char *name,
 	return evm_inode_setxattr(dentry, name, value, size);
 }
 
+int security_inode_pre_setxattr(struct dentry *dentry, const char *name,
+				const void **value, size_t *size, int flags,
+				bool *alloc)
+{
+	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+		return 0;
+	return call_int_hook(inode_pre_setxattr, 0, dentry, name, value, size,
+			     flags, alloc);
+}
+
 void security_inode_post_setxattr(struct dentry *dentry, const char *name,
 				  const void *value, size_t size, int flags)
 {
@@ -1662,6 +1672,8 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.inode_getattr),
 	.inode_setxattr =
 		LIST_HEAD_INIT(security_hook_heads.inode_setxattr),
+	.inode_pre_setxattr =
+		LIST_HEAD_INIT(security_hook_heads.inode_pre_setxattr),
 	.inode_post_setxattr =
 		LIST_HEAD_INIT(security_hook_heads.inode_post_setxattr),
 	.inode_getxattr =
-- 
2.4.3
