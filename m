From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/3] xattr: Enable security.capability in user namespaces
Date: Thu, 22 Jun 2017 14:59:47 -0400
Message-ID: <1498157989-11814-2-git-send-email-stefanb__42038.449078291$1498158022$gmane$org@linux.vnet.ibm.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1498157989-11814-1-git-send-email-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: lkp-JC7UmRfGjtg@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This patch enables security.capability in user namespaces but also
takes a more general approach to enabling extended attributes in user
namespaces.

The following rules describe the approach using security.foo as a
'user namespace enabled' extended attribute:

Reading of extended attributes:

1) Reading security.foo from a user namespace will read
   security.foo@uid=<uid> of the parent user namespace instead with uid
   being the mapping of root in that parent user namespace. An
   exception is if root is mapped to uid 0 on the host, and in this case
   we will read security.foo directly.
   --> reading security.foo will read security.foo@uid=1000 for uid
       mapping of root to 1000.

2) All security.foo@uid=<uid> with valid uid mapping in the user namespace
   can be read. The uid within the user namespace will be mapped to the
   corresponding uid on the host and that uid will be used in the name of
   the extended attribute.
   -> reading security.foo@uid=1 will read security.foo@uid=1001 for uid
      mapping of root to 1000, size of at least 2.

   All security.foo@uid=<uid> can be read (by root) on the host with values
   of <uid> also being subject to checking for valid mappings.

3) No other security.foo* can be read.

The same rules for reading apply to writing and removing of user
namespace enabled extended attributes.

When listing extended attributes of a file, only those are presented
to the user namespace that have a valid mapping. Besides that, names
of the extended attributes are adjusted to represent the mapping.
This means that if root is mapped to uid 1000 on the host, the
security.foo@uid=1000 will be listed as security.foo in the user
namespace, security.foo@uid=1001 becomes security.foo@uid=1 and so on.

Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
---
 fs/xattr.c               | 433 ++++++++++++++++++++++++++++++++++++++++++++++-
 security/commoncap.c     |  36 ++--
 security/selinux/hooks.c |   9 +-
 3 files changed, 462 insertions(+), 16 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 464c94b..64c4b40 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -133,11 +133,405 @@ xattr_permission(struct inode *inode, const char *name, int mask)
 	return inode_permission(inode, mask);
 }
 
+/*
+ * A list of extended attributes that are supported in user namespaces
+ */
+static const char *const userns_xattrs[] = {
+	XATTR_NAME_CAPS,
+	NULL
+};
+
+/*
+ * xattrs_is_userns_supported - Check whether an xattr is supported in userns
+ *
+ * @name:   full name of the extended attribute
+ * @prefix: do a prefix match (true) or a full match (false)
+ *
+ * This function returns < 0 if not supported, an index into userns_xattrs[]
+ * otherwise.
+ */
+static int
+xattr_is_userns_supported(const char *name, int prefix)
+{
+	int i;
+
+	if (!name)
+		return -1;
+
+	for (i = 0; userns_xattrs[i]; i++) {
+		if (prefix) {
+			if (!strncmp(userns_xattrs[i], name,
+				     strlen(userns_xattrs[i])))
+				return i;
+		} else {
+			if (!strcmp(userns_xattrs[i], name))
+				return i;
+		}
+	}
+	return -1;
+}
+
+/*
+ * xattr_write_uid - print a string in the format of "%s@uid=%u", which
+ *                   includes a prefix strig
+ *
+ * @uid:     the uid
+ * @prefix:  prefix string; may be NULL
+ *
+ * This function returns a buffer with the string, or a NULL pointer in
+ * case of out-of-memory error.
+ */
+static char *
+xattr_write_uid(uid_t uid, const char *prefix)
+{
+	size_t buflen;
+	char *buffer;
+
+	buflen = sizeof("@uid=") - 1 + sizeof("4294967295") - 1 + 1;
+	if (prefix)
+		buflen += strlen(prefix);
+
+	buffer = kmalloc(buflen, GFP_KERNEL);
+	if (!buffer)
+		return NULL;
+
+	if (uid == 0)
+		*buffer = 0;
+	else
+		sprintf(buffer, "%s@uid=%u",
+			(prefix) ? prefix : "",
+			uid);
+
+	return buffer;
+}
+
+/*
+ * xattr_parse_uid_from_kuid - parse string in the format @uid=<uid>; consider
+ *                             user namespaces and check mappings
+ *
+ * @uidstr   : string in the format "@uid=<uid>"
+ * @userns   : the user namespace to consult for uid mappings
+ * @n_uidstr : returned pointer holding the rewritten @uid=<uid> string with
+ *             the uid remapped
+ *
+ * This function returns an error code or 0 in case of success. In case
+ * of success, 'n_uidstr' will hold a valid string.
+ */
+static int
+xattr_parse_uid_from_kuid(const char *uidstr, struct user_namespace *userns,
+			  char **n_uidstr)
+{
+	int n;
+	uid_t muid, p_uid;
+	char d;
+	kuid_t tuid;
+
+	*n_uidstr = NULL;
+
+	n = sscanf(uidstr, "@uid=%u%c", &p_uid, &d);
+	if (n != 1)
+		return -EINVAL;
+
+	/* do we have a mapping of the uid? */
+	tuid = KUIDT_INIT(p_uid);
+	muid = from_kuid(userns, tuid);
+	if (muid == -1)
+		return -ENOENT;
+
+	*n_uidstr = xattr_write_uid(muid, NULL);
+	if (!*n_uidstr)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/*
+ * xattr_parse_uid_make_kuid - parse string in the format @uid=<uid>; consider
+ *                             user namespaces and check mappings
+ *
+ * @uidstr   : string in the format "@uid=<uid>"
+ * @userns   : the user namespace to consult for uid mappings
+ * @N_uidstr : returned pointer holding the rewritten @uid=<uid> string with
+ *             the uid remapped
+ *
+ * This function returns an error code or 0 in case of success. In case
+ * of success, 'n_uidstr' will hold a valid string.
+ */
+static int
+xattr_parse_uid_make_kuid(const char *uidstr, struct user_namespace *userns,
+			  char **n_uidstr)
+{
+	int n;
+	uid_t p_uid;
+	char d;
+	kuid_t tuid;
+
+	*n_uidstr = NULL;
+
+	n = sscanf(uidstr, "@uid=%u%c", &p_uid, &d);
+	if (n != 1)
+		return -EINVAL;
+
+	tuid = make_kuid(userns, p_uid);
+	if (!uid_valid(tuid))
+		return -ENOENT;
+
+	*n_uidstr = xattr_write_uid(__kuid_val(tuid), NULL);
+	if (!*n_uidstr)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/*
+ * xattr_rewrite_userns_xattr - Rewrite and filter an extended attribute
+ *                              considering user namespace uid mappings and
+ *                              user namespace support extended attributes
+ *
+ * @name: full name of the extended attribute
+ *
+ * This function returns NULL if the name is to be filtered. Otherwise it can
+ * return the input buffer or a new buffer that the caller needs to free. The
+ * new buffer contains a rewritten extended attribute whose string length may
+ * exceed that of the given name.
+ */
+static char *
+xattr_rewrite_userns_xattr(char *name)
+{
+	int idx, error;
+	size_t len = 0, buflen;
+	char *buffer, *n_uidstr;
+
+	/* prefix-match name against supported attributes */
+	idx = xattr_is_userns_supported(name, true);
+	if (idx < 0)
+		return NULL;
+
+	/* exact match ? */
+	len = strlen(userns_xattrs[idx]);
+	if (name[len] == 0)
+		return NULL;
+
+	/*
+	 * We must have a name[len] == '@'.
+	 */
+	error = xattr_parse_uid_from_kuid(&name[len], current_user_ns(),
+					  &n_uidstr);
+	if (error)
+		return NULL;
+
+	buflen = len + strlen(n_uidstr) + 1;
+	buffer = kmalloc(buflen, GFP_KERNEL);
+	if (!buffer) {
+		kfree(n_uidstr);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	name[len] = 0;
+
+	snprintf(buffer, buflen, "%s%s", name, n_uidstr);
+
+	name[len] = '@';
+
+	kfree(n_uidstr);
+
+	return buffer;
+}
+
+/*
+ * xattr_list_userns_rewrite - Rewrite list of xattr names for user namespaces
+ *                             or determine needed size for attribute list
+ *                             in case size == 0
+ *
+ * In a user namespace we do not present all extended attributes to the
+ * user. We filter out those that are in the list of userns supported xattr.
+ * Besides that we filter out those with @uid=<uid> when there is no mapping
+ * for that uid in the current user namespace.
+ *
+ * @list:        list of 0-byte separated xattr names
+ * @size:        the size of the list; may be 0 to determine needed list size
+ * @list_maxlen: allocated buffer size of list
+ */
+static ssize_t
+xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
+{
+	char *nlist = NULL;
+	size_t s_off, len, nlen;
+	ssize_t d_off;
+	char *name, *newname;
+
+	if (!list || size < 0 || current_user_ns() == &init_user_ns)
+		return size;
+
+	if (size) {
+		nlist = kmalloc(list_maxlen, GFP_KERNEL);
+		if (!nlist)
+			return -ENOMEM;
+	}
+
+	s_off = d_off = 0;
+	while (s_off < size || size == 0) {
+		name = &list[s_off];
+
+		len = strlen(name);
+		if (!len)
+			break;
+
+		newname = xattr_rewrite_userns_xattr(name);
+		if (IS_ERR(newname)) {
+			d_off = PTR_ERR(newname);
+			goto out_free;
+		}
+		if (newname) {
+			nlen = strlen(newname);
+
+			if (nlist) {
+				if (nlen + 1 > list_maxlen)
+					break;
+				strcpy(&nlist[d_off], newname);
+			}
+
+			d_off += nlen + 1;
+			if (newname != name)
+				kfree(newname);
+		}
+		s_off += len + 1;
+	}
+	if (nlist)
+		memcpy(list, nlist, d_off);
+out_free:
+	kfree(nlist);
+
+	return d_off;
+}
+
+/*
+ * xattr_userns_name - modify the name of a user namespace supported
+ *                     extended attribute
+ *
+ * In a user namespace we prevent read/write accesses to the host's
+ * security.foo to protect these extended attributes.
+ *
+ * Reading:
+ * 1) Reading security.foo from a user namespace will read
+ *    security.foo@uid=<uid> of the parent user namespace instead with uid
+ *    being the mapping of root in that parent user namespace. An
+ *    exception is if root is mapped to uid 0 on the host, and in this case
+ *    we will read security.foo directly.
+ *    -> reading security.foo will read security.foo@uid=1000 for a uid
+ *       mapping of root to 1000.
+ *
+ * 2) All security.foo@uid=<uid> with valid uid mappings in the user namespace
+ *    an be read. The uid within the user namespace will be mapped to the
+ *    corresponding uid on the host and that uid will be used in the name of
+ *    the extended attribute.
+ *    -> reading security.foo@uid=1 will read security.foo@uid=1001 for a uid
+ *       mapping of root to 1000, size of at least 2.
+ *
+ *    All security.foo@uid=<uid> can be read (by root) on the host with values
+ *    of <uid> also being subject to checking for valid mappings.
+ *
+ * 3) No other security.foo* can be read.
+ *
+ * Writing and removing:
+ * The same rules for reading apply to writing and removing.
+ *
+ * This function returns a buffer with either the original name or the
+ * user namespace adjusted name of the extended attribute.
+ *
+ * @fullname: the full name of the extended attribute, e.g. security.foo
+ * @suffix:   the suffix of the extended attribute, e.g. foo
+ * @is_write: whether this is for writing an xattr
+ */
+char *
+xattr_userns_name(const char *fullname, const char *suffix)
+{
+	size_t buflen;
+	char *buffer, *ptr, *n_uidstr;
+	kuid_t root_uid = make_kuid(current_user_ns(), 0);
+	int idx, error;
+	size_t len = 0, slen;
+
+	if (!suffix)
+		return ERR_PTR(-EINVAL);
+
+	/* only security.foo will be changed here - prefix match here */
+	idx = xattr_is_userns_supported(fullname, true);
+	if (idx == -1)
+		goto out_copy;
+
+	/* read security.foo? --> read security.foo@uid=<uid> instead */
+	len = strlen(userns_xattrs[idx]);
+	if (fullname[len] == 0) {
+		/*
+		 * init_user_ns or userns with root mapped to uid 0
+		 * may read security.foo directly
+		 */
+		if (current_user_ns() == &init_user_ns ||
+		    __kuid_val(root_uid) == 0)
+			goto out_copy;
+
+		if (!uid_valid(root_uid))
+			return ERR_PTR(-EINVAL);
+
+		buffer = xattr_write_uid(__kuid_val(root_uid), suffix);
+		if (!buffer)
+			return ERR_PTR(-ENOMEM);
+
+		return buffer;
+	}
+
+	/*
+	 * We must have fullname[len] == '@'.
+	 */
+	error = xattr_parse_uid_make_kuid(&fullname[len],
+					  current_user_ns(),
+					  &n_uidstr);
+	if (error)
+		return ERR_PTR(error);
+
+	/* suffix of fullname must have '@' */
+	ptr = strchr(suffix, '@');
+	if (!ptr) {
+		kfree(n_uidstr);
+		goto err_eperm;
+	}
+	slen = ptr - suffix;
+
+	/* suffix[slen] = '@' */
+	buflen = strlen(suffix) + strlen(n_uidstr) + 1;
+	buffer = kmalloc(buflen, GFP_KERNEL);
+	if (!buffer) {
+		kfree(n_uidstr);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	snprintf(buffer, slen + 1, "%s", suffix);
+	snprintf(&buffer[slen], buflen - slen, "%s", n_uidstr);
+	kfree(n_uidstr);
+
+	return buffer;
+
+out_copy:
+	buffer = kmalloc(strlen(suffix) + 1, GFP_KERNEL);
+	if (!buffer)
+		return ERR_PTR(-ENOMEM);
+	strcpy(buffer, suffix);
+
+	return buffer;
+
+err_eperm:
+	return ERR_PTR(-EPERM);
+}
+
 int
 __vfs_setxattr(struct dentry *dentry, struct inode *inode, const char *name,
 	       const void *value, size_t size, int flags)
 {
 	const struct xattr_handler *handler;
+	char *nsuffix;
+	const char *fullname = name;
+	int ret;
 
 	handler = xattr_resolve_name(inode, &name);
 	if (IS_ERR(handler))
@@ -146,7 +540,12 @@ __vfs_setxattr(struct dentry *dentry, struct inode *inode, const char *name,
 		return -EOPNOTSUPP;
 	if (size == 0)
 		value = "";  /* empty EA, do not remove */
-	return handler->set(handler, dentry, inode, name, value, size, flags);
+	nsuffix = xattr_userns_name(fullname, name);
+	if (IS_ERR(nsuffix))
+		return PTR_ERR(nsuffix);
+	ret = handler->set(handler, dentry, inode, nsuffix, value, size, flags);
+	kfree(nsuffix);
+	return ret;
 }
 EXPORT_SYMBOL(__vfs_setxattr);
 
@@ -302,13 +701,21 @@ __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
 	       void *value, size_t size)
 {
 	const struct xattr_handler *handler;
+	char *nsuffix;
+	const char *fullname = name;
+	int ret;
 
 	handler = xattr_resolve_name(inode, &name);
 	if (IS_ERR(handler))
 		return PTR_ERR(handler);
 	if (!handler->get)
 		return -EOPNOTSUPP;
-	return handler->get(handler, dentry, inode, name, value, size);
+	nsuffix = xattr_userns_name(fullname, name);
+	if (IS_ERR(nsuffix))
+		return PTR_ERR(nsuffix);
+	ret = handler->get(handler, dentry, inode, nsuffix, value, size);
+	kfree(nsuffix);
+	return ret;
 }
 EXPORT_SYMBOL(__vfs_getxattr);
 
@@ -328,8 +735,14 @@ vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_t size)
 
 	if (!strncmp(name, XATTR_SECURITY_PREFIX,
 				XATTR_SECURITY_PREFIX_LEN)) {
+		int ret;
 		const char *suffix = name + XATTR_SECURITY_PREFIX_LEN;
-		int ret = xattr_getsecurity(inode, suffix, value, size);
+		char *nsuffix = xattr_userns_name(name, suffix);
+
+		if (IS_ERR(nsuffix))
+			return PTR_ERR(nsuffix);
+		ret = xattr_getsecurity(inode, nsuffix, value, size);
+		kfree(nsuffix);
 		/*
 		 * Only overwrite the return value if a security module
 		 * is actually active.
@@ -360,6 +773,9 @@ vfs_listxattr(struct dentry *dentry, char *list, size_t size)
 		if (size && error > size)
 			error = -ERANGE;
 	}
+	if (error > 0)
+		error = xattr_list_userns_rewrite(list, error, size);
+
 	return error;
 }
 EXPORT_SYMBOL_GPL(vfs_listxattr);
@@ -369,13 +785,22 @@ __vfs_removexattr(struct dentry *dentry, const char *name)
 {
 	struct inode *inode = d_inode(dentry);
 	const struct xattr_handler *handler;
+	char *nsuffix;
+	const char *fullname = name;
+	int ret;
 
 	handler = xattr_resolve_name(inode, &name);
 	if (IS_ERR(handler))
 		return PTR_ERR(handler);
 	if (!handler->set)
 		return -EOPNOTSUPP;
-	return handler->set(handler, dentry, inode, name, NULL, 0, XATTR_REPLACE);
+	nsuffix = xattr_userns_name(fullname, name);
+	if (IS_ERR(nsuffix))
+		return PTR_ERR(nsuffix);
+	ret = handler->set(handler, dentry, inode, nsuffix, NULL, 0,
+			   XATTR_REPLACE);
+	kfree(nsuffix);
+	return ret;
 }
 EXPORT_SYMBOL(__vfs_removexattr);
 
diff --git a/security/commoncap.c b/security/commoncap.c
index 7abebd7..c842690 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -660,15 +660,23 @@ int cap_bprm_secureexec(struct linux_binprm *bprm)
 int cap_inode_setxattr(struct dentry *dentry, const char *name,
 		       const void *value, size_t size, int flags)
 {
-	if (!strcmp(name, XATTR_NAME_CAPS)) {
-		if (!capable(CAP_SETFCAP))
+	if (strncmp(name, XATTR_SECURITY_PREFIX,
+		    sizeof(XATTR_SECURITY_PREFIX) - 1) != 0)
+		return 0;
+
+	if (strncmp(name, XATTR_NAME_CAPS,
+		    sizeof(XATTR_NAME_CAPS) - 1) == 0) {
+		struct inode *inode = d_backing_inode(dentry);
+
+		if (!inode)
+			return -EINVAL;
+		if (!capable_wrt_inode_uidgid(inode, CAP_SETFCAP))
 			return -EPERM;
+
 		return 0;
 	}
 
-	if (!strncmp(name, XATTR_SECURITY_PREFIX,
-		     sizeof(XATTR_SECURITY_PREFIX) - 1) &&
-	    !capable(CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	return 0;
 }
@@ -686,15 +694,23 @@ int cap_inode_setxattr(struct dentry *dentry, const char *name,
  */
 int cap_inode_removexattr(struct dentry *dentry, const char *name)
 {
-	if (!strcmp(name, XATTR_NAME_CAPS)) {
-		if (!capable(CAP_SETFCAP))
+	if (strncmp(name, XATTR_SECURITY_PREFIX,
+		    sizeof(XATTR_SECURITY_PREFIX) - 1) != 0)
+		return 0;
+
+	if (strncmp(name, XATTR_NAME_CAPS,
+		    sizeof(XATTR_NAME_CAPS) - 1) == 0) {
+		struct inode *inode = d_backing_inode(dentry);
+
+		if (!inode)
+			return -EINVAL;
+		if (!capable_wrt_inode_uidgid(inode, CAP_SETFCAP))
 			return -EPERM;
+
 		return 0;
 	}
 
-	if (!strncmp(name, XATTR_SECURITY_PREFIX,
-		     sizeof(XATTR_SECURITY_PREFIX) - 1) &&
-	    !capable(CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	return 0;
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 819fd68..702c225 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3091,8 +3091,13 @@ static int selinux_inode_setotherxattr(struct dentry *dentry, const char *name)
 
 	if (!strncmp(name, XATTR_SECURITY_PREFIX,
 		     sizeof XATTR_SECURITY_PREFIX - 1)) {
-		if (!strcmp(name, XATTR_NAME_CAPS)) {
-			if (!capable(CAP_SETFCAP))
+		if (!strncmp(name, XATTR_NAME_CAPS,
+			     sizeof(XATTR_NAME_CAPS) - 1)) {
+			struct inode *inode = d_backing_inode(dentry);
+
+			if (!inode)
+				return -EINVAL;
+			if (!capable_wrt_inode_uidgid(inode, CAP_SETFCAP))
 				return -EPERM;
 		} else if (!capable(CAP_SYS_ADMIN)) {
 			/* A different attribute in the security namespace.
-- 
2.7.4
