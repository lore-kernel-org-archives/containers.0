From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/3] Enable capabilities of files from shared filesystem
Date: Thu, 22 Jun 2017 14:59:48 -0400
Message-ID: <1498157989-11814-3-git-send-email-stefanb@linux.vnet.ibm.com>
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

The previous patch changed existing behavior in so far as the
capabilities of files from a shared filesystem or bind-mounted files
were hidden from a user namespace. This patch makes these capabilties
visible to the user namespace again, unless the user namespace has set
its own capabilities, which will hide them until those set by the
user namespace are removed.

Also the listing of xattrs is adjusted. To avoid double listing of
names of extended attributes, which can happen if the container and the
host for example have security.capability, we now check that we do not
add the same extended attribute to the list twice.

Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
---
 fs/xattr.c | 90 ++++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 64 insertions(+), 26 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 64c4b40..045be85 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -339,6 +339,26 @@ xattr_rewrite_userns_xattr(char *name)
 }
 
 /*
+ * xattr_list_contains - check whether an xattr list already contains a needle
+ *
+ * @list    : 0-byte separated strings
+ * @listlen : length of the list
+ * @needle  : the needle to search for
+ */
+static int
+xattr_list_contains(const char *list, size_t listlen, const char *needle)
+{
+	size_t o = 0;
+
+	while (o < listlen) {
+		if (!strcmp(&list[o], needle))
+			return true;
+		o += strlen(&list[o]) + 1;
+	}
+	return false;
+}
+
+/*
  * xattr_list_userns_rewrite - Rewrite list of xattr names for user namespaces
  *                             or determine needed size for attribute list
  *                             in case size == 0
@@ -377,12 +397,16 @@ xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
 		if (!len)
 			break;
 
-		newname = xattr_rewrite_userns_xattr(name);
-		if (IS_ERR(newname)) {
-			d_off = PTR_ERR(newname);
-			goto out_free;
+		if (xattr_is_userns_supported(name, false) >= 0)
+			newname = name;
+		else {
+			newname = xattr_rewrite_userns_xattr(name);
+			if (IS_ERR(newname)) {
+				d_off = PTR_ERR(newname);
+				goto out_free;
+			}
 		}
-		if (newname) {
+		if (newname && !xattr_list_contains(nlist, d_off, newname)) {
 			nlen = strlen(newname);
 
 			if (nlist) {
@@ -413,13 +437,19 @@ xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
  * security.foo to protect these extended attributes.
  *
  * Reading:
- * 1) Reading security.foo from a user namespace will read
- *    security.foo@uid=<uid> of the parent user namespace instead with uid
- *    being the mapping of root in that parent user namespace. An
- *    exception is if root is mapped to uid 0 on the host, and in this case
- *    we will read security.foo directly.
- *    -> reading security.foo will read security.foo@uid=1000 for a uid
- *       mapping of root to 1000.
+ * 1a) Reading security.foo from a user namespace will read
+ *     security.foo@uid=<uid> of the parent user namespace instead with uid
+ *     being the mapping of root in that parent user namespace. An
+ *     exception is if root is mapped to uid 0 on the host, and in this case
+ *     we will read security.foo directly.
+ *     -> reading security.foo will read security.foo@uid=1000 for a uid
+ *        mapping of root to 1000.
+ *
+ * 1b) If security.foo@uid=<uid> is not available, the security.foo of the
+ *     parent namespace is tried to be read. This procedure is repeated up to
+ *     the init user namespace. This step only applies for reading of extended
+ *     attributes and provides the same behavior as older systems where the
+ *     host's extended attributes applied to user namespaces.
  *
  * 2) All security.foo@uid=<uid> with valid uid mappings in the user namespace
  *    an be read. The uid within the user namespace will be mapped to the
@@ -434,7 +464,7 @@ xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
  * 3) No other security.foo* can be read.
  *
  * Writing and removing:
- * The same rules for reading apply to writing and removing.
+ * The same rules for reading apply to writing and removing, except for 1b).
  *
  * This function returns a buffer with either the original name or the
  * user namespace adjusted name of the extended attribute.
@@ -444,11 +474,12 @@ xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
  * @is_write: whether this is for writing an xattr
  */
 char *
-xattr_userns_name(const char *fullname, const char *suffix)
+xattr_userns_name(const char *fullname, const char *suffix,
+		  struct user_namespace *userns)
 {
 	size_t buflen;
 	char *buffer, *ptr, *n_uidstr;
-	kuid_t root_uid = make_kuid(current_user_ns(), 0);
+	kuid_t root_uid = make_kuid(userns, 0);
 	int idx, error;
 	size_t len = 0, slen;
 
@@ -467,7 +498,7 @@ xattr_userns_name(const char *fullname, const char *suffix)
 		 * init_user_ns or userns with root mapped to uid 0
 		 * may read security.foo directly
 		 */
-		if (current_user_ns() == &init_user_ns ||
+		if (userns == &init_user_ns ||
 		    __kuid_val(root_uid) == 0)
 			goto out_copy;
 
@@ -485,7 +516,7 @@ xattr_userns_name(const char *fullname, const char *suffix)
 	 * We must have fullname[len] == '@'.
 	 */
 	error = xattr_parse_uid_make_kuid(&fullname[len],
-					  current_user_ns(),
+					  userns,
 					  &n_uidstr);
 	if (error)
 		return ERR_PTR(error);
@@ -540,7 +571,7 @@ __vfs_setxattr(struct dentry *dentry, struct inode *inode, const char *name,
 		return -EOPNOTSUPP;
 	if (size == 0)
 		value = "";  /* empty EA, do not remove */
-	nsuffix = xattr_userns_name(fullname, name);
+	nsuffix = xattr_userns_name(fullname, name, current_user_ns());
 	if (IS_ERR(nsuffix))
 		return PTR_ERR(nsuffix);
 	ret = handler->set(handler, dentry, inode, nsuffix, value, size, flags);
@@ -703,18 +734,24 @@ __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
 	const struct xattr_handler *handler;
 	char *nsuffix;
 	const char *fullname = name;
-	int ret;
+	int ret, userns_supt_xattr;
+	struct user_namespace *userns = current_user_ns();
 
 	handler = xattr_resolve_name(inode, &name);
 	if (IS_ERR(handler))
 		return PTR_ERR(handler);
 	if (!handler->get)
 		return -EOPNOTSUPP;
-	nsuffix = xattr_userns_name(fullname, name);
-	if (IS_ERR(nsuffix))
-		return PTR_ERR(nsuffix);
-	ret = handler->get(handler, dentry, inode, nsuffix, value, size);
-	kfree(nsuffix);
+	userns_supt_xattr = (xattr_is_userns_supported(fullname, false) >= 0);
+	do {
+		nsuffix = xattr_userns_name(fullname, name, userns);
+		if (IS_ERR(nsuffix))
+			return PTR_ERR(nsuffix);
+		ret = handler->get(handler, dentry, inode, nsuffix, value,
+				   size);
+		kfree(nsuffix);
+		userns = userns->parent;
+	} while ((ret == -ENODATA) && userns && userns_supt_xattr);
 	return ret;
 }
 EXPORT_SYMBOL(__vfs_getxattr);
@@ -737,7 +774,8 @@ vfs_getxattr(struct dentry *dentry, const char *name, void *value, size_t size)
 				XATTR_SECURITY_PREFIX_LEN)) {
 		int ret;
 		const char *suffix = name + XATTR_SECURITY_PREFIX_LEN;
-		char *nsuffix = xattr_userns_name(name, suffix);
+		char *nsuffix = xattr_userns_name(name, suffix,
+						  current_user_ns());
 
 		if (IS_ERR(nsuffix))
 			return PTR_ERR(nsuffix);
@@ -794,7 +832,7 @@ __vfs_removexattr(struct dentry *dentry, const char *name)
 		return PTR_ERR(handler);
 	if (!handler->set)
 		return -EOPNOTSUPP;
-	nsuffix = xattr_userns_name(fullname, name);
+	nsuffix = xattr_userns_name(fullname, name, current_user_ns());
 	if (IS_ERR(nsuffix))
 		return PTR_ERR(nsuffix);
 	ret = handler->set(handler, dentry, inode, nsuffix, NULL, 0,
-- 
2.7.4
